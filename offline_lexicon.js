// ============================================================================
// OFFLINE ENGLISH-VIETNAMESE LEXICON & MORPHOLOGY ANALYZER FOR PHOTO OCR VAULT
// ============================================================================

const STOPWORDS = new Set([
  'the', 'and', 'for', 'that', 'this', 'with', 'from', 'your', 'have', 'more',
  'will', 'been', 'were', 'they', 'their', 'what', 'when', 'where', 'which',
  'there', 'about', 'into', 'than', 'them', 'then', 'some', 'only', 'other',
  'also', 'very', 'just', 'much', 'most', 'many', 'such', 'like', 'make',
  'made', 'does', 'done', 'take', 'took', 'come', 'came', 'know', 'knew',
  'want', 'need', 'good', 'well', 'time', 'year', 'work', 'back', 'even',
  'give', 'gave', 'over', 'after', 'before', 'under', 'between', 'through',
  'because', 'while', 'during', 'without', 'within', 'along', 'across',
  'should', 'would', 'could', 'might', 'must', 'shall', 'here', 'those',
  'these', 'each', 'every', 'both', 'same', 'used', 'using', 'able', 'being'
]);

// High-frequency IELTS / TOEIC / Business / Tech / Daily Lexicon for instant offline lookup
const LEXICON = {
  sustainable: { ipa: '/səˈsteɪnəbl/', cefr: 'B2', pos: 'Adjective', meaning: 'Bền vững, thân thiện lâu dài', grammar: 'sustainable development / growth / energy', syn: ['Eco-friendly', 'Viable'] },
  innovation: { ipa: '/ˌɪnəˈveɪʃn/', cefr: 'B2', pos: 'Noun', meaning: 'Sự đổi mới sáng tạo', grammar: 'technological innovation; drive innovation IN...', syn: ['Breakthrough', 'Novelty'] },
  remarkable: { ipa: '/rɪˈmɑːkəbl/', cefr: 'B2', pos: 'Adjective', meaning: 'Đáng kinh ngạc, xuất sắc nổi bật', grammar: 'remarkable achievement / progress / recovery', syn: ['Extraordinary', 'Notable'] },
  growth: { ipa: '/ɡrəʊθ/', cefr: 'B1', pos: 'Noun', meaning: 'Sự tăng trưởng, phát triển', grammar: 'economic / rapid / sustainable growth', syn: ['Expansion', 'Increase'] },
  abundant: { ipa: '/əˈbʌndənt/', cefr: 'C1', pos: 'Adjective', meaning: 'Dồi dào, phong phú', grammar: 'be abundant IN something; abundant resources', syn: ['Plentiful', 'Ample'] },
  opportunity: { ipa: '/ˌɒpəˈtjuːnəti/', cefr: 'B1', pos: 'Noun', meaning: 'Cơ hội, thời cơ', grammar: 'seize / miss an opportunity TO do sth', syn: ['Chance', 'Prospect'] },
  opportunities: { base: 'opportunity', ipa: '/ˌɒpəˈtjuːnətiz/', cefr: 'B1', pos: 'Noun', meaning: 'Cơ hội, thời cơ', grammar: 'career opportunities; equal opportunities', syn: ['Chances', 'Prospects'] },
  curious: { ipa: '/ˈkjʊəriəs/', cefr: 'B1', pos: 'Adjective', meaning: 'Tò mò, ham học hỏi', grammar: 'be curious ABOUT something', syn: ['Inquisitive', 'Eager'] },
  resilient: { ipa: '/rɪˈzɪliənt/', cefr: 'B2', pos: 'Adjective', meaning: 'Kiên cường, chịu lỗi/phục hồi nhanh', grammar: 'remain resilient TO change', syn: ['Robust', 'Tough'] },
  negotiate: { ipa: '/nɪˈɡəʊʃieɪt/', cefr: 'B1', pos: 'Verb', meaning: 'Đàm phán, thương lượng', grammar: 'negotiate something WITH somebody', syn: ['Bargain'] },
  elaborate: { ipa: '/ɪˈlæbəreɪt/', cefr: 'B2', pos: 'Verb', meaning: 'Giải thích chi tiết hơn', grammar: 'elaborate ON a topic/proposal', syn: ['Expand on', 'Clarify'] },
  feasible: { ipa: '/ˈfiːzəbl/', cefr: 'B2', pos: 'Adjective', meaning: 'Khả thi, thực hiện được', grammar: 'technically / economically feasible', syn: ['Viable', 'Practical'] },
  prioritize: { ipa: '/praɪˈɒrətaɪz/', cefr: 'B1', pos: 'Verb', meaning: 'Ưu tiên việc quan trọng', grammar: 'prioritize A over B', syn: ['Focus on'] },
  bottleneck: { ipa: '/ˈbɒtlnɛk/', cefr: 'B2', pos: 'Noun', meaning: 'Điểm nghẽn cổ chai', grammar: 'identify / eliminate a bottleneck IN...', syn: ['Obstacle', 'Constraint'] },
  mitigate: { ipa: '/ˈmɪtɪɡeɪt/', cefr: 'C1', pos: 'Verb', meaning: 'Giảm thiểu rủi ro/tác động xấu', grammar: 'mitigate risks / damage / effects', syn: ['Alleviate', 'Minimize'] },
  indispensable: { ipa: '/ˌɪndɪˈspɛnsəbl/', cefr: 'C1', pos: 'Adjective', meaning: 'Không thể thiếu được', grammar: 'be indispensable TO / FOR somebody', syn: ['Essential', 'Vital'] },
  ubiquitous: { ipa: '/juːˈbɪkwɪtəs/', cefr: 'C1', pos: 'Adjective', meaning: 'Phổ biến ở khắp mọi nơi', grammar: 'become ubiquitous IN modern life', syn: ['Omnipresent', 'Pervasive'] },
  collaborate: { ipa: '/kəˈlæbəreɪt/', cefr: 'B1', pos: 'Verb', meaning: 'Hợp tác, phối hợp cùng nhau', grammar: 'collaborate WITH sb ON sth', syn: ['Cooperate', 'Partner'] },
  scalable: { ipa: '/ˈskeɪləbl/', cefr: 'B2', pos: 'Adjective', meaning: 'Có khả năng mở rộng quy mô lớn', grammar: 'scalable architecture / system', syn: ['Expandable'] },
  accommodate: { ipa: '/əˈkɒmədeɪt/', cefr: 'B2', pos: 'Verb', meaning: 'Đáp ứng yêu cầu / cung cấp chỗ chứa', grammar: 'accommodate guests / a request (2 chữ c, 2 chữ m)', syn: ['Fulfill', 'House'] },
  substantial: { ipa: '/səbˈstænʃl/', cefr: 'C1', pos: 'Adjective', meaning: 'Đáng kể, lớn lao', grammar: 'substantial improvement / amount', syn: ['Significant', 'Considerable'] },
  contingency: { ipa: '/kənˈtɪndʒənsi/', cefr: 'C1', pos: 'Noun', meaning: 'Phương án dự phòng rủi ro', grammar: 'contingency plan / fund', syn: ['Fallback', 'Backup plan'] },
  pivotal: { ipa: '/ˈpɪvətl/', cefr: 'C1', pos: 'Adjective', meaning: 'Then chốt, mang tính quyết định', grammar: 'play a pivotal role IN + V-ing', syn: ['Crucial', 'Decisive'] },
  efficient: { ipa: '/ɪˈfɪʃnt/', cefr: 'B1', pos: 'Adjective', meaning: 'Hiệu quả, tiết kiệm thời gian/năng lượng', grammar: 'highly efficient; energy-efficient', syn: ['Productive', 'Streamlined'] },
  strategy: { ipa: '/ˈstrætədʒi/', cefr: 'B1', pos: 'Noun', meaning: 'Chiến lược', grammar: 'develop / implement a strategy FOR...', syn: ['Plan', 'Approach'] },
  implement: { ipa: '/ˈɪmplɪmɛnt/', cefr: 'B2', pos: 'Verb', meaning: 'Triển khai, thực thi', grammar: 'implement a policy / feature / plan', syn: ['Execute', 'Carry out'] },
  enhance: { ipa: '/ɪnˈhɑːns/', cefr: 'B2', pos: 'Verb', meaning: 'Nâng cao, cải thiện chất lượng', grammar: 'enhance user experience / performance', syn: ['Boost', 'Improve'] },
  comprehensive: { ipa: '/ˌkɒmprɪˈhɛnsɪv/', cefr: 'B2', pos: 'Adjective', meaning: 'Toàn diện, đầy đủ chi tiết', grammar: 'a comprehensive guide / review', syn: ['Thorough', 'Complete'] },
  inevitable: { ipa: '/ɪnˈɛvɪtəbl/', cefr: 'C1', pos: 'Adjective', meaning: 'Tất yếu, không thể tránh khỏi', grammar: 'an inevitable consequence / change', syn: ['Unavoidable', 'Certain'] },
  proficient: { ipa: '/prəˈfɪʃnt/', cefr: 'C1', pos: 'Adjective', meaning: 'Thành thạo, tinh thông kỹ năng', grammar: 'be proficient IN / AT English', syn: ['Skilled', 'Competent'] },
  deadline: { ipa: '/ˈdɛdlaɪn/', cefr: 'A2', pos: 'Noun', meaning: 'Hạn chót hoàn thành', grammar: 'meet / miss / extend a deadline', syn: ['Due date'] },
  schedule: { ipa: '/ˈskɛdʒuːl/', cefr: 'A2', pos: 'Noun / Verb', meaning: 'Lịch trình / Sắp xếp lịch', grammar: 'on schedule; behind schedule', syn: ['Timetable', 'Agenda'] },
  itinerary: { ipa: '/aɪˈtɪnərəri/', cefr: 'B1', pos: 'Noun', meaning: 'Lịch trình chuyến đi', grammar: 'travel itinerary; on the itinerary', syn: ['Route', 'Schedule'] },
  complimentary: { ipa: '/ˌkɒmplɪˈmɛntəri/', cefr: 'B1', pos: 'Adjective', meaning: 'Miễn phí tặng kèm dịch vụ', grammar: 'complimentary breakfast / upgrade', syn: ['Free of charge'] },
  perspective: { ipa: '/pəˈspɛktɪv/', cefr: 'B2', pos: 'Noun', meaning: 'Góc nhìn, quan điểm', grammar: 'from a technical/business perspective', syn: ['Viewpoint', 'Outlook'] },
  milestone: { ipa: '/ˈmaɪlstəʊn/', cefr: 'B1', pos: 'Noun', meaning: 'Cột mốc quan trọng', grammar: 'reach / hit a major milestone', syn: ['Landmark', 'Achievement'] },
  accurate: { ipa: '/ˈækjərət/', cefr: 'B1', pos: 'Adjective', meaning: 'Chính xác, chuẩn xác', grammar: 'highly accurate prediction / data', syn: ['Precise', 'Exact'] },
  analyze: { ipa: '/ˈænəlaɪz/', cefr: 'B1', pos: 'Verb', meaning: 'Phân tích kỹ lưỡng', grammar: 'analyze data / trends / requirements', syn: ['Examine', 'Evaluate'] },
  significant: { ipa: '/sɪɡˈnɪfɪkənt/', cefr: 'B2', pos: 'Adjective', meaning: 'Đáng kể, quan trọng', grammar: 'a significant impact ON...', syn: ['Substantial', 'Major'] },
  fundamental: { ipa: '/ˌfʌndəˈmɛntl/', cefr: 'B2', pos: 'Adjective', meaning: 'Cốt lõi, nền tảng cơ bản', grammar: 'fundamental principle / difference', syn: ['Core', 'Basic'] },
  reluctant: { ipa: '/rɪˈlʌktənt/', cefr: 'C1', pos: 'Adjective', meaning: 'Miễn cưỡng, ngần ngại', grammar: 'be reluctant TO do something', syn: ['Hesitant', 'Unwilling'] },
  versatile: { ipa: '/ˈvɜːsətaɪl/', cefr: 'C1', pos: 'Adjective', meaning: 'Đa năng, linh hoạt nhiều việc', grammar: 'a versatile tool / developer', syn: ['Adaptable', 'Multifaceted'] },
  transparent: { ipa: '/trænsˈpærənt/', cefr: 'B2', pos: 'Adjective', meaning: 'Minh bạch, rõ ràng / trong suốt', grammar: 'transparent process / communication', syn: ['Clear', 'Open'] },
  consistent: { ipa: '/kənˈsɪstənt/', cefr: 'B2', pos: 'Adjective', meaning: 'Nhất quán, kiên trì đều đặn', grammar: 'be consistent WITH something', syn: ['Steady', 'Coherent'] },
  revenue: { ipa: '/ˈrɛvənjuː/', cefr: 'B2', pos: 'Noun', meaning: 'Doanh thu', grammar: 'generate annual / quarterly revenue', syn: ['Income', 'Turnover'] },
  forecast: { ipa: '/ˈfɔːkɑːst/', cefr: 'B2', pos: 'Noun / Verb', meaning: 'Dự báo (thời tiết, doanh thu)', grammar: 'quarterly revenue forecast', syn: ['Prediction', 'Projection'] },
  architecture: { ipa: '/ˈɑːkɪtɛktʃə/', cefr: 'B2', pos: 'Noun', meaning: 'Kiến trúc (hệ thống / xây dựng)', grammar: 'clean software architecture', syn: ['Structure', 'Design'] },
  prerequisite: { ipa: '/ˌpriːˈrɛkwɪzɪt/', cefr: 'C1', pos: 'Noun', meaning: 'Điều kiện tiên quyết', grammar: 'a prerequisite FOR something', syn: ['Requirement', 'Precondition'] },
  ambiguous: { ipa: '/æmˈbɪɡjuəs/', cefr: 'C1', pos: 'Adjective', meaning: 'Mơ hồ, nhập nhằng đa nghĩa', grammar: 'ambiguous wording / statement', syn: ['Vague', 'Unclear'] },
  streamline: { ipa: '/ˈstriːmlaɪn/', cefr: 'C1', pos: 'Verb', meaning: 'Tinh gọn, tối ưu hóa quy trình', grammar: 'streamline workflow / operations', syn: ['Simplify', 'Optimize'] }
};

function guessPartOfSpeechAndGrammar(word) {
  const lower = word.toLowerCase();
  if (/(tion|sion|ment|ness|ity|ance|ence)$/.test(lower)) {
    return {
      pos: 'Noun',
      cefr: word.length >= 9 ? 'B2' : 'B1',
      grammar: 'Danh từ trích xuất từ ảnh (thường nhận biết qua hậu tố -tion/-ment/-ity).'
    };
  }
  if (/(ous|ive|able|ible|al|ful|less|ic|ant|ent)$/.test(lower)) {
    return {
      pos: 'Adjective',
      cefr: word.length >= 9 ? 'B2' : 'B1',
      grammar: 'Tính từ trích xuất từ ảnh (bổ nghĩa cho danh từ hoặc đứng sau động từ nối).'
    };
  }
  if (/ly$/.test(lower)) {
    return {
      pos: 'Adverb',
      cefr: 'B1',
      grammar: 'Trạng từ bổ nghĩa cho động từ hoặc tính từ trong câu.'
    };
  }
  if (/(ize|ise|ate|fy)$/.test(lower)) {
    return {
      pos: 'Verb',
      cefr: 'B2',
      grammar: 'Động từ hành động trích xuất từ ngữ cảnh trong ảnh.'
    };
  }
  return {
    pos: 'Vocabulary',
    cefr: word.length >= 8 ? 'B2' : 'B1',
    grammar: 'Từ vựng trích xuất từ ảnh chụp của bạn — hãy xem câu ngữ cảnh đi kèm.'
  };
}

/**
 * Parses OCR lines & text from an uploaded photo into structured vocabulary cards.
 */
function extractVocabFromOcr({ fullText = '', lines = [], photoTitle = 'Ảnh chụp từ vựng' }) {
  const extractedMap = new Map();
  const cleanLines = (lines && lines.length > 0 ? lines : fullText.split(/\r?\n/))
    .map(l => l.trim())
    .filter(Boolean);

  // 1. First pass: detect explicit glossary lines like "Word: Nghĩa" or "1. Word (adj) - Nghĩa"
  const pairRegex = /^(?:\d+[\.\)]\s*)?([A-Za-z][A-Za-z\-]{2,24})(?:\s*\([^)]+\))?\s*[:\-–=]\s*(.+)$/;
  for (const line of cleanLines) {
    const match = line.match(pairRegex);
    if (match) {
      const rawWord = match[1].trim();
      const rawMeaning = match[2].trim();
      const key = rawWord.toLowerCase();
      const lex = LEXICON[key];
      const morph = guessPartOfSpeechAndGrammar(rawWord);
      const displayWord = rawWord.charAt(0).toUpperCase() + rawWord.slice(1);

      extractedMap.set(key, {
        word: lex && lex.base ? (lex.base.charAt(0).toUpperCase() + lex.base.slice(1)) : displayWord,
        ipa: lex ? lex.ipa : `/${key}/`,
        cefr: lex ? lex.cefr : morph.cefr,
        partOfSpeech: `${lex ? lex.pos : morph.pos} • ${lex ? lex.cefr : morph.cefr}`,
        topic: `📸 ${photoTitle}`,
        vietnameseMeaning: rawMeaning,
        exampleSentence: lex
          ? `Example from note: ${displayWord} — ${rawMeaning}.`
          : `Từ trong ảnh "${photoTitle}": ${displayWord}.`,
        grammarNote: lex ? lex.grammar : morph.grammar,
        usageTip: 'Trích xuất trực tiếp từ bảng từ vựng trong ảnh bạn đã upload.',
        collocations: [rawWord.toLowerCase()],
        wordFamily: displayWord,
        synonyms: lex && lex.syn ? lex.syn : [],
        antonyms: []
      });
    }
  }

  // 2. Second pass: extract meaningful English words from sentences in the photo
  const sentences = fullText
    .replace(/\r?\n/g, ' ')
    .split(/(?<=[.!?])\s+/)
    .map(s => s.trim())
    .filter(Boolean);

  const tokens = fullText.match(/\b[A-Za-z]{4,20}\b/g) || [];
  for (const tok of tokens) {
    const lower = tok.toLowerCase();
    if (STOPWORDS.has(lower)) continue;
    if (extractedMap.has(lower)) continue;

    // Also normalize simple plural/past inflections if base exists in LEXICON
    let lookupKey = lower;
    if (!LEXICON[lookupKey] && lower.endsWith('s') && LEXICON[lower.slice(0, -1)]) {
      lookupKey = lower.slice(0, -1);
    } else if (!LEXICON[lookupKey] && lower.endsWith('ed') && LEXICON[lower.slice(0, -2)]) {
      lookupKey = lower.slice(0, -2);
    } else if (!LEXICON[lookupKey] && lower.endsWith('ed') && LEXICON[lower.slice(0, -1)]) {
      lookupKey = lower.slice(0, -1);
    }
    if (extractedMap.has(lookupKey)) continue;

    const lex = LEXICON[lookupKey];
    // Prioritize words found in lexicon or longer academic/content words (>= 5 chars)
    if (!lex && lower.length < 5) continue;

    const canonical = lex && lex.base ? lex.base : lookupKey;
    const displayWord = canonical.charAt(0).toUpperCase() + canonical.slice(1);
    const morph = guessPartOfSpeechAndGrammar(displayWord);

    const matchingSentence = sentences.find(s =>
      new RegExp('\\b' + tok.replace(/[.*+?^${}()|[\]\\]/g, '\\$&') + '\\b', 'i').test(s)
    ) || cleanLines.find(l => l.toLowerCase().includes(lower)) || `Context with ${displayWord}.`;

    extractedMap.set(canonical, {
      word: displayWord,
      ipa: lex ? lex.ipa : `/${canonical}/`,
      cefr: lex ? lex.cefr : morph.cefr,
      partOfSpeech: `${lex ? lex.pos : morph.pos} • ${lex ? lex.cefr : morph.cefr}`,
      topic: `📸 ${photoTitle}`,
      vietnameseMeaning: lex
        ? lex.meaning
        : `(Từ trong ảnh "${photoTitle}" — bấm ✏️ để ghi nghĩa riêng của bạn)`,
      exampleSentence: matchingSentence,
      grammarNote: lex ? lex.grammar : morph.grammar,
      usageTip: `Xuất hiện trong ảnh chụp "${photoTitle}". Học theo câu ngữ cảnh gốc giúp nhớ lâu hơn!`,
      collocations: [canonical],
      wordFamily: displayWord,
      synonyms: lex && lex.syn ? lex.syn : [],
      antonyms: []
    });

    if (extractedMap.size >= 18) break;
  }

  return Array.from(extractedMap.values());
}

module.exports = {
  extractVocabFromOcr,
  LEXICON
};
