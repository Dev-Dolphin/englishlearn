// ============================================================================
// LINGOAI PHOTO VOCAB VAULT - SEPARATE STORAGE, REAL-TIME SYNC & SELECTIVE STUDY
// ============================================================================

(function () {
  const PHOTO_VAULT_LOCAL_KEY = 'lingoai_photo_vault_separate_v1';

  let vaultState = loadLocalVaultFallback();
  let selectedWordIds = new Set();
  let autoSelectNewUploads = true;
  let isUploading = false;
  let uploadStatusMsg = '';
  let liveStreamConnected = false;

  // Dedicated Flashcard Flipper inside Photo Vault (separate from system SRS)
  let photoFlashcardSession = null; // { cards: [], index: 0, revealed: false }
  let editingWordModal = null; // { photoId, wordObj }

  function loadLocalVaultFallback() {
    try {
      const raw = localStorage.getItem(PHOTO_VAULT_LOCAL_KEY);
      if (raw) {
        const parsed = JSON.parse(raw);
        if (parsed && Array.isArray(parsed.photos)) return parsed;
      }
    } catch (_) {}
    return {
      updatedAt: Date.now(),
      photos: [
        {
          id: 'photo_seed_local',
          title: 'Ảnh mẫu: Ghi chú IELTS & Công nghệ',
          imageUrl: '',
          uploadedAt: new Date().toISOString(),
          ocrText: 'Sustainable innovation drives remarkable growth.\nStreamline: Tinh gọn tối ưu quy trình\nPrerequisite: Điều kiện tiên quyết',
          words: [
            {
              id: 'pv_local_1',
              word: 'Sustainable',
              ipa: '/səˈsteɪnəbl/',
              cefr: 'B2',
              partOfSpeech: 'Adjective • B2',
              topic: '📸 Ghi chú IELTS & Công nghệ',
              vietnameseMeaning: 'Bền vững, thân thiện lâu dài',
              exampleSentence: 'Sustainable innovation drives remarkable growth.',
              grammarNote: 'sustainable development / growth / energy',
              usageTip: 'Trích xuất từ ảnh chụp của bạn.',
              collocations: ['sustainable growth'],
              wordFamily: 'Sustainable (adj)',
              synonyms: ['Viable', 'Eco-friendly'],
              antonyms: []
            },
            {
              id: 'pv_local_2',
              word: 'Streamline',
              ipa: '/ˈstriːmlaɪn/',
              cefr: 'C1',
              partOfSpeech: 'Verb • C1',
              topic: '📸 Ghi chú IELTS & Công nghệ',
              vietnameseMeaning: 'Tinh gọn tối ưu quy trình',
              exampleSentence: 'We need to streamline our daily workflow.',
              grammarNote: 'streamline workflow / operations',
              usageTip: 'Trích xuất trực tiếp từ dòng ghi chú trong ảnh.',
              collocations: ['streamline operations'],
              wordFamily: 'Streamline (v)',
              synonyms: ['Optimize', 'Simplify'],
              antonyms: []
            },
            {
              id: 'pv_local_3',
              word: 'Prerequisite',
              ipa: '/ˌpriːˈrɛkwɪzɪt/',
              cefr: 'C1',
              partOfSpeech: 'Noun • C1',
              topic: '📸 Ghi chú IELTS & Công nghệ',
              vietnameseMeaning: 'Điều kiện tiên quyết',
              exampleSentence: ' Vocabulary is a prerequisite for fluent speaking.',
              grammarNote: 'a prerequisite FOR something',
              usageTip: 'Trích xuất trực tiếp từ dòng ghi chú trong ảnh.',
              collocations: ['prerequisite for'],
              wordFamily: 'Prerequisite (n)',
              synonyms: ['Requirement'],
              antonyms: []
            }
          ]
        }
      ]
    };
  }

  function saveLocalVault() {
    try {
      localStorage.setItem(PHOTO_VAULT_LOCAL_KEY, JSON.stringify(vaultState));
    } catch (_) {}
  }

  function syncNewVaultData(incomingPhotos, isInitial = false) {
    const previousKnownWordIds = new Set();
    vaultState.photos.forEach(p => (p.words || []).forEach(w => previousKnownWordIds.add(w.id)));

    vaultState.photos = incomingPhotos || [];
    vaultState.updatedAt = Date.now();
    saveLocalVault();

    const newlyAddedWords = [];
    vaultState.photos.forEach(p => {
      (p.words || []).forEach(w => {
        if (isInitial && selectedWordIds.size === 0) {
          selectedWordIds.add(w.id);
        } else if (!isInitial && !previousKnownWordIds.has(w.id)) {
          newlyAddedWords.push(w);
          if (autoSelectNewUploads) {
            selectedWordIds.add(w.id);
          }
        }
      });
    });

    // Clean up deleted word IDs
    const validIds = new Set();
    vaultState.photos.forEach(p => (p.words || []).forEach(w => validIds.add(w.id)));
    Array.from(selectedWordIds).forEach(id => {
      if (!validIds.has(id)) selectedWordIds.delete(id);
    });

    // If user is currently playing Photo Endless/Study mode, push newly uploaded words straight into active queue!
    if (newlyAddedWords.length > 0) {
      if (window.appendNewCardsToActiveWcSession) {
        window.appendNewCardsToActiveWcSession(newlyAddedWords);
      }
      if (photoFlashcardSession) {
        photoFlashcardSession.cards.push(...newlyAddedWords);
      }
    }

    if (window.getCurrentTab && window.getCurrentTab() === 'photo_vault') {
      window.rerenderCurrentTab();
    }
  }

  // Select initial seed words on boot
  vaultState.photos.forEach(p => (p.words || []).forEach(w => selectedWordIds.add(w.id)));

  // Connect to Server API + Real-Time SSE Stream for continuous updates
  function initServerSync() {
    if (!location.protocol.startsWith('http')) return;

    fetch('/api/photo-vault')
      .then(r => r.json())
      .then(data => {
        if (data && Array.isArray(data.photos)) {
          selectedWordIds.clear();
          syncNewVaultData(data.photos, true);
        }
      })
      .catch(() => {});

    if ('EventSource' in window) {
      const es = new EventSource('/api/photo-vault/stream');
      es.onopen = () => {
        liveStreamConnected = true;
        if (window.getCurrentTab && window.getCurrentTab() === 'photo_vault') {
          window.rerenderCurrentTab();
        }
      };
      es.onmessage = event => {
        try {
          const msg = JSON.parse(event.data);
          if (msg && Array.isArray(msg.photos)) {
            syncNewVaultData(msg.photos, msg.type === 'vault_init' && selectedWordIds.size === 0);
          }
        } catch (_) {}
      };
      es.onerror = () => {
        liveStreamConnected = false;
      };
    }
  }

  initServerSync();

  // Global Ctrl+V Clipboard Image Paste support when user is in Photo Vault tab!
  document.addEventListener('paste', function (e) {
    if (!window.getCurrentTab || window.getCurrentTab() !== 'photo_vault') return;
    if (!e.clipboardData || !e.clipboardData.items) return;

    const imageFiles = [];
    for (const item of e.clipboardData.items) {
      if (item.type && item.type.startsWith('image/')) {
        const blob = item.getAsFile();
        if (blob) {
          const namedFile = new File([blob], `Screenshot_${new Date().toLocaleTimeString('vi-VN').replace(/:/g, '-')}.png`, { type: blob.type });
          imageFiles.push(namedFile);
        }
      }
    }
    if (imageFiles.length > 0) {
      e.preventDefault();
      window.handlePhotoFilesUpload(imageFiles);
    }
  });

  function readFileAsDataUrl(file) {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.onload = () => resolve(reader.result);
      reader.onerror = reject;
      reader.readAsDataURL(file);
    });
  }

  // Client-side fallback parser when running pure file:// without server.js
  function parseManualTextOffline(manualText, title) {
    const lines = (manualText || '').split(/\r?\n/).map(s => s.trim()).filter(Boolean);
    const results = [];
    lines.forEach((line, idx) => {
      const pair = line.match(/^([A-Za-z][A-Za-z\-]{2,24})\s*[:\-–=]\s*(.+)$/);
      if (pair) {
        const w = pair[1].trim();
        results.push({
          id: `pv_client_${Date.now()}_${idx}`,
          word: w.charAt(0).toUpperCase() + w.slice(1),
          ipa: `/${w.toLowerCase()}/`,
          cefr: 'B1',
          partOfSpeech: 'Photo Vocab • B1',
          topic: `📸 ${title}`,
          vietnameseMeaning: pair[2].trim(),
          exampleSentence: `Context from "${title}": ${w}.`,
          grammarNote: 'Từ trích xuất từ ghi chú ảnh của bạn.',
          usageTip: 'Hãy luyện gõ đoán từ ẩn để thuộc chính tả từ này.',
          collocations: [w.toLowerCase()],
          wordFamily: w,
          synonyms: [],
          antonyms: []
        });
      }
    });
    return results;
  }

  window.handlePhotoInputChange = function (inputEl) {
    if (!inputEl || !inputEl.files || inputEl.files.length === 0) return;
    window.handlePhotoFilesUpload(Array.from(inputEl.files));
    inputEl.value = '';
  };

  window.handlePhotoDrop = function (event) {
    event.preventDefault();
    if (!event.dataTransfer || !event.dataTransfer.files) return;
    const files = Array.from(event.dataTransfer.files).filter(f => f.type.startsWith('image/'));
    if (files.length > 0) {
      window.handlePhotoFilesUpload(files);
    }
  };

  window.handlePhotoFilesUpload = async function (files) {
    if (isUploading || !files || files.length === 0) return;
    const titleInput = document.getElementById('pv-custom-title');
    const manualInput = document.getElementById('pv-manual-notes');
    const customTitle = titleInput ? titleInput.value.trim() : '';
    const manualText = manualInput ? manualInput.value.trim() : '';

    isUploading = true;
    for (let i = 0; i < files.length; i++) {
      const file = files[i];
      uploadStatusMsg = `⏳ Đang lưu ảnh & quét OCR Offline (${i + 1}/${files.length}): ${file.name}...`;
      window.rerenderCurrentTab();

      try {
        const dataUrl = await readFileAsDataUrl(file);
        const photoTitle = customTitle
          ? (files.length > 1 ? `${customTitle} #${i + 1}` : customTitle)
          : file.name.replace(/\.[^.]+$/, '');

        if (location.protocol.startsWith('http')) {
          const resp = await fetch('/api/photo-vault/upload', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              title: photoTitle,
              fileName: file.name,
              imageBase64: dataUrl,
              manualText
            })
          });
          const result = await resp.json();
          if (result && result.ok && result.vault) {
            syncNewVaultData(result.vault.photos, false);
          }
        } else {
          // Pure file:// offline fallback
          const newPhoto = {
            id: `photo_local_${Date.now()}_${i}`,
            title: photoTitle,
            imageUrl: dataUrl,
            uploadedAt: new Date().toISOString(),
            ocrText: manualText || '(Đang mở trực tiếp file:// — hãy chạy qua server http://localhost:3000 để quét OCR tự động từ ảnh)',
            words: parseManualTextOffline(manualText, photoTitle)
          };
          syncNewVaultData([newPhoto, ...vaultState.photos], false);
        }
      } catch (err) {
        console.warn('Upload error:', err);
      }
    }

    isUploading = false;
    uploadStatusMsg = `✅ Đã cập nhật ${files.length} ảnh mới vào Kho Từ Ảnh Riêng!`;
    window.rerenderCurrentTab();
    setTimeout(() => {
      uploadStatusMsg = '';
      if (window.getCurrentTab && window.getCurrentTab() === 'photo_vault') {
        window.rerenderCurrentTab();
      }
    }, 3500);
  };

  window.uploadTextOnlyPhotoNote = async function () {
    const titleInput = document.getElementById('pv-custom-title');
    const manualInput = document.getElementById('pv-manual-notes');
    const title = (titleInput && titleInput.value.trim()) || 'Ghi chú nhanh';
    const manualText = manualInput ? manualInput.value.trim() : '';
    if (!manualText) {
      alert('Vui lòng chọn file ảnh hoặc nhập nội dung từ vựng vào ô ghi chú!');
      return;
    }

    isUploading = true;
    uploadStatusMsg = '⏳ Đang trích xuất từ vựng vào Kho Riêng...';
    window.rerenderCurrentTab();

    try {
      if (location.protocol.startsWith('http')) {
        const resp = await fetch('/api/photo-vault/upload', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ title, fileName: 'note.png', imageBase64: '', manualText })
        });
        const res = await resp.json();
        if (res && res.ok && res.vault) {
          syncNewVaultData(res.vault.photos, false);
        }
      } else {
        const newPhoto = {
          id: `photo_note_${Date.now()}`,
          title,
          imageUrl: '',
          uploadedAt: new Date().toISOString(),
          ocrText: manualText,
          words: parseManualTextOffline(manualText, title)
        };
        syncNewVaultData([newPhoto, ...vaultState.photos], false);
      }
    } catch (_) {}

    isUploading = false;
    uploadStatusMsg = '✅ Đã lưu và trích xuất từ vựng thành công!';
    window.rerenderCurrentTab();
  };

  // ==========================================================================
  // SELECTION CONTROLS (SELECT BY PHOTO OR BY INDIVIDUAL WORD)
  // ==========================================================================
  function getSelectedPhotoWords() {
    const chosen = [];
    vaultState.photos.forEach(p => {
      (p.words || []).forEach(w => {
        if (selectedWordIds.has(w.id)) chosen.push(w);
      });
    });
    return chosen;
  }

  window.togglePhotoSelection = function (photoId) {
    const photo = vaultState.photos.find(p => p.id === photoId);
    if (!photo || !photo.words) return;
    const allSelected = photo.words.length > 0 && photo.words.every(w => selectedWordIds.has(w.id));
    photo.words.forEach(w => {
      if (allSelected) selectedWordIds.delete(w.id);
      else selectedWordIds.add(w.id);
    });
    window.rerenderCurrentTab();
  };

  window.toggleSinglePhotoWord = function (wordId) {
    if (selectedWordIds.has(wordId)) selectedWordIds.delete(wordId);
    else selectedWordIds.add(wordId);
    window.rerenderCurrentTab();
  };

  window.selectAllVaultWords = function (selectAll) {
    selectedWordIds.clear();
    if (selectAll) {
      vaultState.photos.forEach(p => (p.words || []).forEach(w => selectedWordIds.add(w.id)));
    }
    window.rerenderCurrentTab();
  };

  window.toggleAutoSelectNewUploads = function () {
    autoSelectNewUploads = !autoSelectNewUploads;
    window.rerenderCurrentTab();
  };

  // ==========================================================================
  // LAUNCH STUDY MODES EXCLUSIVELY WITH SELECTED PHOTO DATA
  // ==========================================================================
  window.studySelectedPhotoWordsInArena = function (mode) {
    const chosen = getSelectedPhotoWords();
    if (chosen.length === 0) {
      alert('Hãy tick chọn ít nhất 1 từ hoặc 1 bức ảnh để bắt đầu học nhé!');
      return;
    }
    if (window.startWordChallengeWithExternalCards) {
      window.startWordChallengeWithExternalCards(mode, chosen, () => getSelectedPhotoWords());
    }
  };

  window.startPhotoFlashcardFlipper = function () {
    const chosen = getSelectedPhotoWords();
    if (chosen.length === 0) {
      alert('Hãy tick chọn ít nhất 1 từ hoặc 1 bức ảnh để lật thẻ học nhé!');
      return;
    }
    photoFlashcardSession = {
      cards: [...chosen],
      index: 0,
      revealed: false
    };
    window.rerenderCurrentTab();
  };

  window.exitPhotoFlashcardFlipper = function () {
    photoFlashcardSession = null;
    window.rerenderCurrentTab();
  };

  window.revealPhotoFlashcard = function () {
    if (!photoFlashcardSession) return;
    photoFlashcardSession.revealed = true;
    window.rerenderCurrentTab();
  };

  window.nextPhotoFlashcard = function (awardXpFlag) {
    if (!photoFlashcardSession) return;
    if (awardXpFlag && window.awardCustomXp) {
      window.awardCustomXp(5);
    }
    photoFlashcardSession.revealed = false;
    photoFlashcardSession.index = (photoFlashcardSession.index + 1) % photoFlashcardSession.cards.length;
    window.rerenderCurrentTab();
  };

  // ==========================================================================
  // EDIT / ADD WORD TO SPECIFIC PHOTO & DELETE PHOTO
  // ==========================================================================
  window.openPhotoWordEditor = function (photoId, wordId) {
    const photo = vaultState.photos.find(p => p.id === photoId);
    if (!photo) return;
    const existing = wordId ? (photo.words || []).find(w => w.id === wordId) : null;
    editingWordModal = {
      photoId,
      wordId: existing ? existing.id : '',
      word: existing ? existing.word : '',
      ipa: existing ? existing.ipa : '',
      meaning: existing ? existing.vietnameseMeaning : '',
      grammar: existing ? (existing.grammarNote || '') : '',
      example: existing ? (existing.exampleSentence || '') : ''
    };
    window.rerenderCurrentTab();
  };

  window.closePhotoWordEditor = function () {
    editingWordModal = null;
    window.rerenderCurrentTab();
  };

  window.submitPhotoWordEditor = async function () {
    if (!editingWordModal) return;
    const word = document.getElementById('pve-word').value.trim();
    const ipa = document.getElementById('pve-ipa').value.trim();
    const meaning = document.getElementById('pve-meaning').value.trim();
    const grammar = document.getElementById('pve-grammar').value.trim();
    const example = document.getElementById('pve-example').value.trim();
    if (!word || !meaning) return;

    if (location.protocol.startsWith('http')) {
      const resp = await fetch('/api/photo-vault/save-word', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          photoId: editingWordModal.photoId,
          wordId: editingWordModal.wordId || undefined,
          word,
          ipa,
          vietnameseMeaning: meaning,
          grammarNote: grammar,
          exampleSentence: example
        })
      });
      const data = await resp.json();
      if (data && data.ok && data.vault) {
        syncNewVaultData(data.vault.photos, false);
      }
    } else {
      const photo = vaultState.photos.find(p => p.id === editingWordModal.photoId);
      if (photo) {
        if (editingWordModal.wordId) {
          const target = photo.words.find(w => w.id === editingWordModal.wordId);
          if (target) {
            target.word = word;
            target.ipa = ipa || target.ipa;
            target.vietnameseMeaning = meaning;
            target.grammarNote = grammar;
            target.exampleSentence = example;
          }
        } else {
          const created = {
            id: `pv_manual_${Date.now()}`,
            word,
            ipa: ipa || `/${word.toLowerCase()}/`,
            cefr: 'B1',
            partOfSpeech: 'Photo Note • B1',
            topic: `📸 ${photo.title}`,
            vietnameseMeaning: meaning,
            exampleSentence: example || `Example with ${word}.`,
            grammarNote: grammar || 'Ghi chú ngữ pháp riêng.',
            usageTip: `Thuộc ảnh "${photo.title}".`,
            collocations: [word.toLowerCase()],
            wordFamily: word,
            synonyms: [],
            antonyms: []
          };
          photo.words.unshift(created);
          selectedWordIds.add(created.id);
        }
        saveLocalVault();
      }
    }

    editingWordModal = null;
    window.rerenderCurrentTab();
  };

  window.deletePhotoFromVault = async function (photoId) {
    if (!confirm('Bạn có chắc muốn xóa bức ảnh này và các từ đi kèm khỏi Kho Riêng không?')) return;
    if (location.protocol.startsWith('http')) {
      const resp = await fetch('/api/photo-vault/delete-photo', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ photoId })
      });
      const data = await resp.json();
      if (data && data.ok && data.vault) {
        syncNewVaultData(data.vault.photos, false);
      }
    } else {
      vaultState.photos = vaultState.photos.filter(p => p.id !== photoId);
      saveLocalVault();
      window.rerenderCurrentTab();
    }
  };

  // ==========================================================================
  // RENDER PHOTO VAULT TAB (SEPARATE DISPLAY & SELECTIVE LEARNING)
  // ==========================================================================
  window.renderPhotoVaultTab = function () {
    const totalPhotos = vaultState.photos.length;
    const totalVaultWords = vaultState.photos.reduce((acc, p) => acc + (p.words ? p.words.length : 0), 0);
    const chosenWords = getSelectedPhotoWords();

    // Dedicated Flashcard Flipper View for Selected Photo Words
    if (photoFlashcardSession && photoFlashcardSession.cards.length > 0) {
      const c = photoFlashcardSession.cards[photoFlashcardSession.index % photoFlashcardSession.cards.length];
      return `
        <div class="card">
          <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:14px">
            <span class="badge-tag">📸 LẬT THẺ RIÊNG TỪ ẢNH ĐÃ CHỌN (${photoFlashcardSession.index + 1}/${photoFlashcardSession.cards.length})</span>
            <button class="icon-btn" onclick="window.exitPhotoFlashcardFlipper()">✕ Quay về Kho Ảnh</button>
          </div>

          <div class="flashcard-box">
            <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:10px">
              <span class="badge-tag">${c.topic}</span>
              <div style="display:flex;gap:6px">
                <button class="icon-btn" onclick="window.speakText('${c.word.replace(/'/g, "\\'")}', 1.0)">🔊 Chuẩn</button>
                <button class="icon-btn" onclick="window.speakText('${c.word.replace(/'/g, "\\'")}', 0.7)">🐢 Chậm</button>
              </div>
            </div>

            <div style="font-size:34px;font-weight:800;margin:12px 0 4px">${c.word}</div>
            <div class="ipa-text" style="font-size:17px;margin-bottom:16px">${c.ipa}</div>

            ${!photoFlashcardSession.revealed ? `
              <button class="btn btn-outline" style="min-width:240px" onclick="window.revealPhotoFlashcard()">
                🔄 Lật xem nghĩa & câu gốc trong ảnh
              </button>
            ` : `
              <div style="border-top:1.5px solid var(--border);padding-top:14px;text-align:left">
                <div style="font-size:20px;font-weight:800;color:var(--primary);margin-bottom:6px">
                  🇻🇳 ${c.vietnameseMeaning}
                </div>
                <div style="font-size:15px;font-style:italic;margin-bottom:8px">
                  📌 Ngữ cảnh ảnh: "${c.exampleSentence}"
                </div>
                <div style="font-size:13px;margin-bottom:14px">
                  <strong>📐 Ngữ pháp:</strong> ${c.grammarNote || ''}
                </div>
                <div style="display:flex;gap:10px">
                  <button class="btn btn-outline" style="flex:1" onclick="window.nextPhotoFlashcard(false)">Ôn lại sau</button>
                  <button class="btn btn-primary" style="flex:2" onclick="window.nextPhotoFlashcard(true)">✅ Đã nhớ từ này (+5 XP) →</button>
                </div>
              </div>
            `}
          </div>
        </div>
      `;
    }

    const photosListHtml = vaultState.photos.map(photo => {
      const words = photo.words || [];
      const selectedInPhoto = words.filter(w => selectedWordIds.has(w.id)).length;
      const allSelected = words.length > 0 && selectedInPhoto === words.length;
      const timeStr = new Date(photo.uploadedAt).toLocaleString('vi-VN');

      const wordsHtml = words.map(w => {
        const checked = selectedWordIds.has(w.id);
        return `
          <div class="lesson-item ${checked ? 'completed' : ''}" style="padding:10px 14px">
            <div style="display:flex;align-items:flex-start;gap:12px;flex:1">
              <input type="checkbox" ${checked ? 'checked' : ''}
                     style="width:19px;height:19px;margin-top:4px;accent-color:var(--primary);cursor:pointer"
                     onchange="window.toggleSinglePhotoWord('${w.id}')" />
              <div style="flex:1">
                <div style="display:flex;align-items:center;gap:8px;flex-wrap:wrap">
                  <strong style="font-size:16px">${w.word}</strong>
                  <span class="ipa-text" style="font-size:13px">${w.ipa}</span>
                  <span class="badge-tag" style="font-size:11px">${w.partOfSpeech}</span>
                </div>
                <div style="font-weight:700;color:var(--primary);font-size:14px;margin-top:2px">
                  ${w.vietnameseMeaning}
                </div>
                <div style="font-size:12px;color:var(--text-muted);font-style:italic">
                  "${w.exampleSentence}"
                </div>
              </div>
            </div>
            <div style="display:flex;gap:6px">
              <button class="icon-btn" title="Nghe phát âm" onclick="window.speakText('${w.word.replace(/'/g, "\\'")}', 1.0)">🔊</button>
              <button class="icon-btn" title="Sửa nghĩa / ví dụ" onclick="window.openPhotoWordEditor('${photo.id}', '${w.id}')">✏️</button>
            </div>
          </div>
        `;
      }).join('');

      return `
        <div class="card">
          <div style="display:flex;justify-content:space-between;align-items:flex-start;gap:14px;flex-wrap:wrap;margin-bottom:12px">
            <div style="display:flex;gap:14px;align-items:center;flex:1;min-width:240px">
              ${photo.imageUrl ? `
                <a href="${photo.imageUrl}" target="_blank" title="Bấm để xem ảnh gốc phóng to">
                  <img src="${photo.imageUrl}" alt="${photo.title}" style="width:76px;height:76px;object-fit:cover;border-radius:12px;border:1.5px solid var(--border)" />
                </a>
              ` : `
                <div style="width:76px;height:76px;border-radius:12px;background:var(--surface-alt);display:flex;align-items:center;justify-content:center;font-size:28px">
                  📸
                </div>
              `}
              <div>
                <div class="unit-title" style="margin-bottom:2px">${photo.title}</div>
                <div style="font-size:12px;color:var(--text-muted)">
                  🕒 Upload: ${timeStr} • Đã chọn <strong>${selectedInPhoto}/${words.length}</strong> từ
                </div>
                <div style="margin-top:6px;display:flex;gap:8px;flex-wrap:wrap">
                  <button class="icon-btn" onclick="window.togglePhotoSelection('${photo.id}')">
                    ${allSelected ? '☑️ Bỏ chọn ảnh này' : '✅ Chọn tất cả từ trong ảnh này'}
                  </button>
                  <button class="icon-btn" onclick="window.openPhotoWordEditor('${photo.id}', '')">
                    + Thêm từ vào ảnh này
                  </button>
                  <button class="icon-btn" style="color:var(--error)" onclick="window.deletePhotoFromVault('${photo.id}')">
                    🗑️ Xóa
                  </button>
                </div>
              </div>
            </div>
          </div>

          <details style="margin-bottom:12px;font-size:13px;color:var(--text-muted)">
            <summary style="cursor:pointer;font-weight:700">📄 Xem văn bản gốc quét được từ ảnh (OCR Text)</summary>
            <div style="margin-top:6px;padding:10px;border-radius:10px;background:var(--surface-alt);white-space:pre-line">
              ${photo.ocrText}
            </div>
          </details>

          ${wordsHtml || '<div style="font-size:13px;color:var(--text-muted)">Chưa có từ nào — hãy bấm "+ Thêm từ vào ảnh này" để bổ sung.</div>'}
        </div>
      `;
    }).join('');

    const editorModalHtml = editingWordModal ? `
      <div class="modal-backdrop">
        <div class="modal-card">
          <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:12px">
            <div class="unit-title" style="margin:0">${editingWordModal.wordId ? '✏️ Chỉnh sửa từ vựng trong ảnh' : '+ Thêm từ vựng vào bộ ảnh'}</div>
            <button class="icon-btn" onclick="window.closePhotoWordEditor()">✕ Đóng</button>
          </div>
          <div style="display:flex;flex-direction:column;gap:10px">
            <input id="pve-word" class="text-input" value="${editingWordModal.word.replace(/"/g, '&quot;')}" placeholder="Từ tiếng Anh *" />
            <input id="pve-ipa" class="text-input" value="${editingWordModal.ipa.replace(/"/g, '&quot;')}" placeholder="Phiên âm IPA (VD: /səˈsteɪnəbl/)" />
            <input id="pve-meaning" class="text-input" value="${editingWordModal.meaning.replace(/"/g, '&quot;')}" placeholder="Nghĩa tiếng Việt *" />
            <input id="pve-grammar" class="text-input" value="${editingWordModal.grammar.replace(/"/g, '&quot;')}" placeholder="Ghi chú ngữ pháp / cách dùng" />
            <input id="pve-example" class="text-input" value="${editingWordModal.example.replace(/"/g, '&quot;')}" placeholder="Câu ví dụ trong ảnh" />
            <button class="btn btn-primary btn-block" onclick="window.submitPhotoWordEditor()">💾 Lưu cập nhật vào Kho Ảnh</button>
          </div>
        </div>
      </div>
    ` : '';

    return `
      <div class="hero-banner" style="background:linear-gradient(135deg, #0EA5E9, #6366F1)">
        <div class="hero-top">
          <div>
            <div class="hero-title">📸 Kho Dữ Liệu Từ Ảnh Chụp (Lưu Trữ & Học Riêng Biệt)</div>
            <div class="hero-sub">
              Upload ảnh sách, vở ghi, tài liệu hoặc bấm <strong>Ctrl + V</strong> để dán ảnh chụp màn hình. Hệ thống tự động quét OCR lưu vào <code>uploaded_vault/</code> riêng biệt và cập nhật liên tục!
            </div>
          </div>
          <span class="hero-btn" style="cursor:default">
            ${liveStreamConnected ? '🟢 Live Sync: Tự động cập nhật tức thì' : '💾 Offline Local Vault'}
          </span>
        </div>
      </div>

      <!-- UPLOAD & PASTE ZONE -->
      <div class="card"
           ondragover="event.preventDefault()"
           ondrop="window.handlePhotoDrop(event)"
           style="border:2px dashed var(--primary);background:rgba(16,185,129,0.03)">
        <div style="text-align:center;padding:8px 0 14px">
          <div style="font-size:34px;margin-bottom:6px">📤</div>
          <div class="unit-title">Tải Ảnh Lên / Kéo Thả / Dán Ảnh Chụp Màn Hình (Ctrl + V)</div>
          <div class="unit-desc" style="margin-bottom:12px">
            Bạn cũng có thể thả file ảnh trực tiếp vào thư mục <code>f:\\EnglishApp\\uploaded_vault\\drop_images_here</code> — danh sách bên dưới sẽ tự động nhảy thêm từ mới ngay lập tức!
          </div>

          <div style="max-width:560px;margin:0 auto 12px;display:flex;flex-direction:column;gap:8px">
            <input id="pv-custom-title" class="text-input" placeholder="Tên bộ ảnh (tùy chọn — VD: Sách Reading Cam 18 Test 2)..." />
            <textarea id="pv-manual-notes" class="text-input" rows="2" placeholder="Ghi chú thêm từ vựng kèm theo ảnh (tùy chọn — VD: ubiquitous: phổ biến khắp nơi)..."></textarea>
          </div>

          <input id="pv-file-input" type="file" accept="image/*" multiple style="display:none" onchange="window.handlePhotoInputChange(this)" />
          <div style="display:flex;justify-content:center;gap:10px;flex-wrap:wrap">
            <button class="btn btn-primary" ${isUploading ? 'disabled' : ''} onclick="document.getElementById('pv-file-input').click()">
              📸 Chọn 1 hoặc nhiều Ảnh để Quét Từ Vựng
            </button>
            <button class="btn btn-outline" ${isUploading ? 'disabled' : ''} onclick="window.uploadTextOnlyPhotoNote()">
              📝 Lưu nhanh từ ô ghi chú
            </button>
          </div>

          ${uploadStatusMsg ? `
            <div style="margin-top:12px;font-weight:800;color:var(--primary)">${uploadStatusMsg}</div>
          ` : ''}
        </div>
      </div>

      <!-- SELECTIVE STUDY ACTION BAR -->
      <div class="card" style="border-color:var(--secondary)">
        <div style="display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:10px;margin-bottom:12px">
          <div>
            <div class="unit-title" style="margin:0">
              🎯 Bảng Chọn Dữ Liệu Để Học (${chosenWords.length} / ${totalVaultWords} từ từ ${totalPhotos} ảnh)
            </div>
            <div style="font-size:13px;color:var(--text-muted)">
              Chỉ những bức ảnh / từ vựng bạn tick chọn mới được đưa vào phiên học bên dưới.
            </div>
          </div>
          <div style="display:flex;gap:8px;flex-wrap:wrap">
            <button class="icon-btn" onclick="window.selectAllVaultWords(true)">☑️ Chọn tất cả</button>
            <button class="icon-btn" onclick="window.selectAllVaultWords(false)">⬜ Bỏ chọn hết</button>
            <button class="icon-btn" onclick="window.toggleAutoSelectNewUploads()">
              ${autoSelectNewUploads ? '🔄 Tự gộp ảnh mới upload: BẬT' : '⏸️ Tự gộp ảnh mới upload: TẮT'}
            </button>
          </div>
        </div>

        <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:10px">
          <button class="btn btn-primary" ${chosenWords.length === 0 ? 'disabled' : ''} onclick="window.studySelectedPhotoWordsInArena('level_test')">
            ⚡ Đoán Từ Ẩn (${chosenWords.length} từ đã chọn)
          </button>
          <button class="btn btn-secondary" ${chosenWords.length === 0 ? 'disabled' : ''} onclick="window.studySelectedPhotoWordsInArena('endless')">
            🔥 Vô Tận Liên Tục (Tự nạp khi thêm ảnh)
          </button>
          <button class="btn btn-outline" ${chosenWords.length === 0 ? 'disabled' : ''} onclick="window.startPhotoFlashcardFlipper()">
            🗂️ Lật Thẻ Flashcard Riêng (${chosenWords.length} từ)
          </button>
        </div>
      </div>

      <!-- SEPARATE LIST OF UPLOADED PHOTOS & EXTRACTED WORDS -->
      ${photosListHtml}
      ${editorModalHtml}
    `;
  };
})();
