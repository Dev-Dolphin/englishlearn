const http = require('http');
const fs = require('fs');
const path = require('path');
const { execFile } = require('child_process');
const { extractVocabFromOcr } = require('./offline_lexicon');

const PORT = process.env.PORT || 3000;
const PUBLIC_DIR = path.join(__dirname, 'web_demo');
const VAULT_DIR = path.join(__dirname, 'uploaded_vault');
const VAULT_IMAGES_DIR = path.join(VAULT_DIR, 'images');
const DROP_FOLDER_DIR = path.join(VAULT_DIR, 'drop_images_here');
const VAULT_DB_FILE = path.join(VAULT_DIR, 'photo_vocab_db.json');
const OCR_SCRIPT = path.join(__dirname, 'scripts', 'ocr_extract.ps1');

// Ensure separate storage directories exist
[VAULT_DIR, VAULT_IMAGES_DIR, DROP_FOLDER_DIR].forEach(dir => {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
});

// Initialize separate Photo Vault JSON DB if not present
function loadVaultDb() {
  try {
    if (fs.existsSync(VAULT_DB_FILE)) {
      return JSON.parse(fs.readFileSync(VAULT_DB_FILE, 'utf8'));
    }
  } catch (err) {
    console.warn('Re-initializing vault DB:', err.message);
  }
  const initialDb = {
    updatedAt: Date.now(),
    photos: [
      {
        id: 'photo_seed_1',
        title: 'Ảnh mẫu: Ghi chú IELTS & Công nghệ',
        fileName: '',
        imageUrl: '',
        uploadedAt: new Date().toISOString(),
        ocrText: 'Sustainable innovation drives remarkable growth.\nStreamline: Tinh gọn tối ưu quy trình\nPrerequisite: Điều kiện tiên quyết',
        words: extractVocabFromOcr({
          fullText: 'Sustainable innovation drives remarkable growth.\nStreamline: Tinh gọn tối ưu quy trình\nPrerequisite: Điều kiện tiên quyết',
          lines: [
            'Sustainable innovation drives remarkable growth.',
            'Streamline: Tinh gọn tối ưu quy trình',
            'Prerequisite: Điều kiện tiên quyết'
          ],
          photoTitle: 'Ghi chú IELTS & Công nghệ'
        }).map((w, idx) => ({ ...w, id: `pv_seed_${idx + 1}` }))
      }
    ]
  };
  fs.writeFileSync(VAULT_DB_FILE, JSON.stringify(initialDb, null, 2), 'utf8');
  return initialDb;
}

function saveVaultDb(db) {
  db.updatedAt = Date.now();
  fs.writeFileSync(VAULT_DB_FILE, JSON.stringify(db, null, 2), 'utf8');
  broadcastVaultUpdate(db);
}

// Connected SSE clients for continuous real-time updates
const sseClients = new Set();

function broadcastVaultUpdate(db) {
  const payload = `data: ${JSON.stringify({ type: 'vault_updated', updatedAt: db.updatedAt, photos: db.photos })}\n\n`;
  for (const clientRes of sseClients) {
    try {
      clientRes.write(payload);
    } catch (_) {
      sseClients.delete(clientRes);
    }
  }
}

// Run Windows Offline OCR on a saved image file
function runOfflineOcr(imagePath) {
  return new Promise(resolve => {
    if (process.platform !== 'win32' || !fs.existsSync(OCR_SCRIPT)) {
      return resolve({ fullText: '', lines: [] });
    }
    execFile(
      'powershell.exe',
      ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', OCR_SCRIPT, '-ImagePath', imagePath],
      { timeout: 15000, maxBuffer: 4 * 1024 * 1024 },
      (err, stdout) => {
        if (err || !stdout) {
          return resolve({ fullText: '', lines: [] });
        }
        try {
          const parsed = JSON.parse(stdout.trim());
          resolve({
            fullText: parsed.fullText || '',
            lines: Array.isArray(parsed.lines) ? parsed.lines : []
          });
        } catch (_) {
          resolve({ fullText: stdout.trim(), lines: [stdout.trim()] });
        }
      }
    );
  });
}

async function processAndStorePhoto({ title, originalFileName, imageBuffer, manualText = '' }) {
  const safeExt = (path.extname(originalFileName || '.png') || '.png').toLowerCase();
  const storedName = `photo_${Date.now()}_${Math.random().toString(36).slice(2, 7)}${safeExt}`;
  const storedPath = path.join(VAULT_IMAGES_DIR, storedName);

  let ocrData = { fullText: '', lines: [] };
  let imageUrl = '';

  if (imageBuffer && imageBuffer.length > 0) {
    fs.writeFileSync(storedPath, imageBuffer);
    imageUrl = `/vault-images/${storedName}`;
    ocrData = await runOfflineOcr(storedPath);
  }

  const combinedText = [ocrData.fullText, manualText].filter(Boolean).join('\n').trim();
  const combinedLines = [
    ...(ocrData.lines || []),
    ...manualText.split(/\r?\n/).map(s => s.trim()).filter(Boolean)
  ];

  const cleanTitle = (title || originalFileName || 'Ảnh chụp mới').replace(/\.[^.]+$/, '');
  const extractedWords = extractVocabFromOcr({
    fullText: combinedText,
    lines: combinedLines,
    photoTitle: cleanTitle
  }).map((w, idx) => ({
    ...w,
    id: `pv_${Date.now()}_${idx}`
  }));

  const db = loadVaultDb();
  const newPhoto = {
    id: `photo_${Date.now()}`,
    title: cleanTitle,
    fileName: storedName,
    imageUrl,
    uploadedAt: new Date().toISOString(),
    ocrText: combinedText || '(Không phát hiện văn bản rõ nét — bạn có thể thêm từ thủ công vào ảnh này)',
    words: extractedWords
  };

  db.photos.unshift(newPhoto);
  saveVaultDb(db);
  return newPhoto;
}

// Watch `uploaded_vault/drop_images_here/` for continuous automatic ingestion when user drops screenshots!
const processingDropFiles = new Set();
try {
  fs.watch(DROP_FOLDER_DIR, (eventType, filename) => {
    if (!filename) return;
    const ext = path.extname(filename).toLowerCase();
    if (!['.png', '.jpg', '.jpeg', '.bmp', '.webp'].includes(ext)) return;
    const fullDropPath = path.join(DROP_FOLDER_DIR, filename);
    if (processingDropFiles.has(fullDropPath)) return;

    processingDropFiles.add(fullDropPath);
    setTimeout(async () => {
      try {
        if (fs.existsSync(fullDropPath)) {
          const buf = fs.readFileSync(fullDropPath);
          if (buf.length > 0) {
            await processAndStorePhoto({
              title: filename.replace(/\.[^.]+$/, ''),
              originalFileName: filename,
              imageBuffer: buf
            });
            fs.unlinkSync(fullDropPath);
          }
        }
      } catch (e) {
        console.warn('Drop folder ingest error:', e.message);
      } finally {
        processingDropFiles.delete(fullDropPath);
      }
    }, 500);
  });
} catch (e) {
  console.warn('Folder watch unavailable:', e.message);
}

const MIME_TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.js': 'application/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.webp': 'image/webp',
  '.bmp': 'image/bmp',
  '.svg': 'image/svg+xml'
};

function readJsonBody(req) {
  return new Promise((resolve, reject) => {
    const chunks = [];
    let total = 0;
    req.on('data', chunk => {
      total += chunk.length;
      if (total > 25 * 1024 * 1024) {
        reject(new Error('Payload too large (max 25MB)'));
        req.destroy();
        return;
      }
      chunks.push(chunk);
    });
    req.on('end', () => {
      try {
        const str = Buffer.concat(chunks).toString('utf8');
        resolve(str ? JSON.parse(str) : {});
      } catch (e) {
        reject(e);
      }
    });
    req.on('error', reject);
  });
}

function sendJson(res, status, obj) {
  res.writeHead(status, {
    'Content-Type': 'application/json; charset=utf-8',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Cache-Control': 'no-cache'
  });
  res.end(JSON.stringify(obj));
}

// Ensure DB exists on startup
loadVaultDb();

const server = http.createServer(async (req, res) => {
  if (req.method === 'OPTIONS') {
    res.writeHead(204, {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type'
    });
    return res.end();
  }

  const parsedUrl = req.url.split('?')[0];

  // 1. Real-time SSE Stream for Photo Vault continuous updates
  if (req.method === 'GET' && parsedUrl === '/api/photo-vault/stream') {
    res.writeHead(200, {
      'Content-Type': 'text/event-stream; charset=utf-8',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive',
      'Access-Control-Allow-Origin': '*'
    });
    const db = loadVaultDb();
    res.write(`data: ${JSON.stringify({ type: 'vault_init', updatedAt: db.updatedAt, photos: db.photos })}\n\n`);
    sseClients.add(res);
    req.on('close', () => sseClients.delete(res));
    return;
  }

  // 2. Fetch Photo Vault JSON
  if (req.method === 'GET' && parsedUrl === '/api/photo-vault') {
    return sendJson(res, 200, loadVaultDb());
  }

  // 3. Upload a new photo (Base64 data URL or raw base64 + optional manual notes)
  if (req.method === 'POST' && parsedUrl === '/api/photo-vault/upload') {
    try {
      const body = await readJsonBody(req);
      let imgBuf = null;
      if (body.imageBase64) {
        const base64Clean = body.imageBase64.replace(/^data:image\/[a-zA-Z0-9+.-]+;base64,/, '');
        imgBuf = Buffer.from(base64Clean, 'base64');
      }
      const created = await processAndStorePhoto({
        title: body.title || body.fileName || 'Ảnh chụp từ vựng',
        originalFileName: body.fileName || 'upload.png',
        imageBuffer: imgBuf,
        manualText: body.manualText || ''
      });
      return sendJson(res, 200, { ok: true, photo: created, vault: loadVaultDb() });
    } catch (err) {
      return sendJson(res, 400, { ok: false, error: err.message });
    }
  }

  // 4. Add or edit a word inside a specific photo entry
  if (req.method === 'POST' && parsedUrl === '/api/photo-vault/save-word') {
    try {
      const body = await readJsonBody(req);
      const db = loadVaultDb();
      const photo = db.photos.find(p => p.id === body.photoId);
      if (!photo) return sendJson(res, 404, { ok: false, error: 'Photo not found' });

      if (body.wordId) {
        const existing = photo.words.find(w => w.id === body.wordId);
        if (existing) {
          existing.word = body.word || existing.word;
          existing.ipa = body.ipa || existing.ipa;
          existing.vietnameseMeaning = body.vietnameseMeaning ?? existing.vietnameseMeaning;
          existing.grammarNote = body.grammarNote ?? existing.grammarNote;
          existing.exampleSentence = body.exampleSentence ?? existing.exampleSentence;
        }
      } else if (body.word) {
        photo.words.unshift({
          id: `pv_manual_${Date.now()}`,
          word: body.word.trim(),
          ipa: body.ipa || `/${body.word.trim().toLowerCase()}/`,
          cefr: 'B1',
          partOfSpeech: 'Photo Note • B1',
          topic: `📸 ${photo.title}`,
          vietnameseMeaning: body.vietnameseMeaning || 'Từ bổ sung từ ảnh',
          exampleSentence: body.exampleSentence || `Example with ${body.word.trim()}.`,
          grammarNote: body.grammarNote || 'Ghi chú ngữ pháp từ ảnh chụp của bạn.',
          usageTip: `Thuộc bộ ảnh "${photo.title}".`,
          collocations: [body.word.trim().toLowerCase()],
          wordFamily: body.word.trim(),
          synonyms: [],
          antonyms: []
        });
      }
      saveVaultDb(db);
      return sendJson(res, 200, { ok: true, vault: db });
    } catch (err) {
      return sendJson(res, 400, { ok: false, error: err.message });
    }
  }

  // 5. Delete a photo entry from the separate vault
  if (req.method === 'POST' && parsedUrl === '/api/photo-vault/delete-photo') {
    try {
      const body = await readJsonBody(req);
      const db = loadVaultDb();
      const target = db.photos.find(p => p.id === body.photoId);
      if (target && target.fileName) {
        const imgPath = path.join(VAULT_IMAGES_DIR, target.fileName);
        if (fs.existsSync(imgPath)) fs.unlinkSync(imgPath);
      }
      db.photos = db.photos.filter(p => p.id !== body.photoId);
      saveVaultDb(db);
      return sendJson(res, 200, { ok: true, vault: db });
    } catch (err) {
      return sendJson(res, 400, { ok: false, error: err.message });
    }
  }

  // 6. Serve uploaded images from separate `uploaded_vault/images/`
  if (req.method === 'GET' && parsedUrl.startsWith('/vault-images/')) {
    const imgName = path.basename(parsedUrl);
    const imgPath = path.join(VAULT_IMAGES_DIR, imgName);
    if (!fs.existsSync(imgPath)) {
      res.writeHead(404);
      return res.end('Image Not Found');
    }
    const ext = path.extname(imgPath).toLowerCase();
    res.writeHead(200, {
      'Content-Type': MIME_TYPES[ext] || 'image/png',
      'Access-Control-Allow-Origin': '*'
    });
    return fs.createReadStream(imgPath).pipe(res);
  }

  // 7. Serve static Web Demo / PWA files
  const safeUrl = parsedUrl === '/' ? '/index.html' : parsedUrl;
  const filePath = path.join(PUBLIC_DIR, safeUrl);
  if (!filePath.startsWith(PUBLIC_DIR)) {
    res.writeHead(403);
    return res.end('Forbidden');
  }

  fs.readFile(filePath, (err, content) => {
    if (err) {
      res.writeHead(404, { 'Content-Type': 'text/plain; charset=utf-8' });
      return res.end('Not Found');
    }
    const ext = path.extname(filePath).toLowerCase();
    res.writeHead(200, {
      'Content-Type': MIME_TYPES[ext] || 'application/octet-stream',
      'Cache-Control': 'no-cache'
    });
    res.end(content);
  });
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`LingoAI Server + Photo Vault OCR running at http://localhost:${PORT}`);
});
