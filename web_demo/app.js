// ============================================================================
// LINGOAI ENGLISH - INTERACTIVE OFFLINE WEB APPLICATION ENGINE
// ============================================================================

(function () {
  const STORAGE_KEY = 'lingoai_offline_state_v1';
  const CURRICULUM = window.OFFLINE_CURRICULUM;

  // Merge stored cards with enriched curriculum cards so new grammar/usage fields & new cards always appear
  function mergeEnrichedCards(savedCards) {
    const baseMap = new Map();
    CURRICULUM.srsFlashcards.forEach(c => {
      baseMap.set(c.id, { ...c, nextReviewTime: Date.now() - 1000 });
    });

    if (Array.isArray(savedCards)) {
      savedCards.forEach(saved => {
        if (baseMap.has(saved.id)) {
          const fresh = baseMap.get(saved.id);
          baseMap.set(saved.id, {
            ...fresh,
            repetition: saved.repetition ?? fresh.repetition,
            easeFactor: saved.easeFactor ?? fresh.easeFactor,
            intervalDays: saved.intervalDays ?? fresh.intervalDays,
            nextReviewTime: saved.nextReviewTime ?? fresh.nextReviewTime
          });
        } else {
          // Keep user's custom added cards
          baseMap.set(saved.id, {
            cefr: 'B1',
            grammarNote: 'Từ vựng cá nhân do bạn tự thêm vào bộ thẻ Offline.',
            usageTip: 'Hãy đặt ít nhất 2 câu thực tế với từ này để ghi nhớ chủ động.',
            collocations: [saved.word + ' in context'],
            wordFamily: saved.word,
            synonyms: [],
            antonyms: [],
            ...saved
          });
        }
      });
    }
    return Array.from(baseMap.values());
  }

  function loadState() {
    const defaults = {
      userName: 'Minh Anh',
      learningGoal: 'Giao tiếp Công việc & Phỏng vấn Quốc tế',
      cefrLevel: 'B1',
      dailyGoalXp: 75,
      dailyXpEarned: 35,
      xp: 340,
      streakDays: 7,
      hearts: 5,
      darkMode: false,
      completedLessons: ['lesson_1_1'],
      srsCards: mergeEnrichedCards([]),
      wordChallengeStats: {
        selectedTier: 'B1-B2',
        levelTestCount: 10,
        bestEndlessScore: 0,
        bestEndlessCombo: 0,
        dailyStreak: 1,
        lastDailyDate: '',
        dailyHistory: [
          // Seed yesterday baseline so "Better Every Day" comparison works right away
          { date: 'Hôm qua', accuracy: 60, avgTimeSec: 11.8, score: 120 }
        ],
        mistakeWordIds: []
      }
    };

    try {
      const raw = localStorage.getItem(STORAGE_KEY);
      if (raw) {
        const parsed = JSON.parse(raw);
        return {
          ...defaults,
          ...parsed,
          srsCards: mergeEnrichedCards(parsed.srsCards),
          wordChallengeStats: {
            ...defaults.wordChallengeStats,
            ...(parsed.wordChallengeStats || {})
          }
        };
      }
    } catch (e) {
      console.warn('LocalStorage fallback:', e);
    }
    return defaults;
  }

  let state = loadState();
  let currentTab = 'home';

  // SRS UI State
  let srsTopicFilter = 'ALL';
  let srsPracticeAllMode = false;
  let srsCardRevealed = false;
  let srsActiveIndex = 0;

  // ==========================================================================
  // MASKED WORD CHALLENGE ENGINE STATE
  // ==========================================================================
  const CEFR_TIMER_CONFIG = {
    'A1-A2': { seconds: 30, label: '🟢 Sơ cấp A1-A2 (30s/từ)', initialHints: 2, xpMultiplier: 1.0 },
    'B1-B2': { seconds: 20, label: '🔵 Trung cấp B1-B2 (20s/từ)', initialHints: 2, xpMultiplier: 1.5 },
    'C1-C2': { seconds: 12, label: '🟣 Cao cấp C1-C2 (12s/từ)', initialHints: 1, xpMultiplier: 2.0 }
  };

  let wcSession = null; // null = lobby, object = active game or summary
  let wcTimerInterval = null;

  function stopWcTimer() {
    if (wcTimerInterval) {
      clearInterval(wcTimerInterval);
      wcTimerInterval = null;
    }
  }

  // AI Tutor UI State
  let activeScenarioId = CURRICULUM.aiScenarios[0].id;
  let aiChatHistory = [];
  let aiTurnCounter = 0;

  // Pronunciation UI State
  let activeDrillIndex = 0;
  let isRecordingDrill = false;

  // Modal State
  let activeModal = null;

  function saveState() {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
    } catch (e) {
      console.warn('Could not save state:', e);
    }
  }

  // Native Offline Browser Text-to-Speech (Web Speech API)
  window.speakText = function (text, rate = 1.0) {
    if ('speechSynthesis' in window) {
      window.speechSynthesis.cancel();
      const utterance = new SpeechSynthesisUtterance(text);
      utterance.lang = 'en-US';
      utterance.rate = rate;
      window.speechSynthesis.speak(utterance);
    } else {
      alert('🔊 [Offline Audio]: ' + text);
    }
  };

  function addXp(amount) {
    const prevDaily = state.dailyXpEarned;
    state.xp += amount;
    state.dailyXpEarned += amount;
    if (prevDaily < state.dailyGoalXp && state.dailyXpEarned >= state.dailyGoalXp) {
      state.streakDays += 1;
    }
    saveState();
  }

  function initAiScenario(scenarioId) {
    activeScenarioId = scenarioId;
    aiTurnCounter = 0;
    const sc = CURRICULUM.aiScenarios.find(s => s.id === scenarioId) || CURRICULUM.aiScenarios[0];
    aiChatHistory = [
      {
        isUser: false,
        text: sc.initialGreeting,
        translation: sc.initialTranslation,
        suggestions: sc.initialSuggestions
      }
    ];
  }

  initAiScenario(activeScenarioId);

  // ==========================================================================
  // RENDER ROOT
  // ==========================================================================
  function render() {
    document.body.classList.toggle('dark-mode', !!state.darkMode);

    document.getElementById('stat-cefr').textContent = 'CEFR ' + state.cefrLevel;
    document.getElementById('stat-streak').textContent = '🔥 ' + state.streakDays + ' ngày';
    document.getElementById('stat-xp').textContent = '⚡ ' + state.xp + ' XP';
    document.getElementById('stat-hearts').textContent = '❤️ ' + state.hearts;
    document.getElementById('theme-btn').textContent = state.darkMode ? '☀️ Sáng' : '🌙 Tối';

    document.querySelectorAll('.nav-tab').forEach(btn => {
      btn.classList.toggle('active', btn.dataset.tab === currentTab);
    });

    const mainEl = document.getElementById('app-main');
    if (currentTab === 'home') {
      mainEl.innerHTML = renderHomeTab();
    } else if (currentTab === 'photo_vault') {
      mainEl.innerHTML = window.renderPhotoVaultTab ? window.renderPhotoVaultTab() : '';
    } else if (currentTab === 'word_challenge') {
      mainEl.innerHTML = renderWordChallengeTab();
      focusWordChallengeInputIfNeeded();
    } else if (currentTab === 'srs') {
      mainEl.innerHTML = renderSrsTab();
    } else if (currentTab === 'ai') {
      mainEl.innerHTML = renderAiTab();
    } else if (currentTab === 'pronunciation') {
      mainEl.innerHTML = renderPronunciationTab();
    } else if (currentTab === 'analytics') {
      mainEl.innerHTML = renderAnalyticsTab();
    }

    renderModal();
  }

  window.rerenderCurrentTab = render;
  window.getCurrentTab = function () { return currentTab; };
  window.awardCustomXp = addXp;

  function focusWordChallengeInputIfNeeded() {
    if (currentTab === 'word_challenge' && wcSession && wcSession.phase === 'playing') {
      const inp = document.getElementById('wc-answer-input');
      if (inp) {
        inp.focus();
        const len = inp.value.length;
        inp.setSelectionRange(len, len);
      }
    }
  }

  // ==========================================================================
  // TAB 1: HOME LEARNING PATH
  // ==========================================================================
  function renderHomeTab() {
    const pct = Math.min(100, Math.round((state.dailyXpEarned / state.dailyGoalXp) * 100));

    let unitsHtml = CURRICULUM.units.map(unit => {
      const doneCount = unit.lessons.filter(l => state.completedLessons.includes(l.id)).length;
      const unitPct = Math.round((doneCount / unit.lessons.length) * 100);

      const lessonsHtml = unit.lessons.map(lesson => {
        const isDone = state.completedLessons.includes(lesson.id);
        return `
          <div class="lesson-item ${isDone ? 'completed' : ''}">
            <div class="lesson-info">
              <div class="lesson-status-icon" style="background:${isDone ? 'rgba(34,197,94,0.16);color:#16a34a' : 'rgba(16,185,129,0.14);color:#10B981'}">
                ${isDone ? '✓' : '▶'}
              </div>
              <div>
                <div style="font-weight:800;font-size:16px">${lesson.title}</div>
                <div style="font-size:13px;color:var(--text-muted)">${lesson.subtitle}</div>
              </div>
            </div>
            <div class="lesson-actions">
              <button class="btn btn-outline" onclick="window.openStudyGuide('${lesson.id}')">
                📖 Lý thuyết & Từ vựng
              </button>
              <button class="btn btn-primary" onclick="window.startLessonQuiz('${lesson.id}')">
                🎯 Làm bài tập (+${lesson.xpReward} XP)
              </button>
            </div>
          </div>
        `;
      }).join('');

      return `
        <div class="card">
          <div class="unit-header">
            <span class="badge-tag">UNIT ${unit.unitNumber} • CEFR ${unit.cefrLevel}</span>
            <span style="font-size:13px;font-weight:800;color:var(--primary)">${unitPct}% hoàn thành (${doneCount}/${unit.lessons.length})</span>
          </div>
          <div class="unit-title">${unit.title}</div>
          <div class="unit-desc">${unit.description}</div>
          ${lessonsHtml}
        </div>
      `;
    }).join('');

    return `
      <div class="hero-banner">
        <div class="hero-top">
          <div>
            <div class="hero-title">Xin chào, ${state.userName}! 👋 (Chế độ Học Offline 100%)</div>
            <div class="hero-sub">Mục tiêu: ${state.learningGoal} • Trình độ hiện tại: CEFR ${state.cefrLevel}</div>
          </div>
          <div style="display:flex;gap:8px;flex-wrap:wrap">
            <button class="hero-btn" onclick="window.switchTab('word_challenge')">
              ⚡ Đấu Trường Đoán Từ Ẩn Mới!
            </button>
            <button class="hero-btn" onclick="window.openPlacementModal()">
              🎯 Kiểm tra trình độ
            </button>
          </div>
        </div>
        <div class="progress-wrap">
          <div class="progress-labels">
            <span>Tiến độ mục tiêu học tập hôm nay</span>
            <span>${state.dailyXpEarned} / ${state.dailyGoalXp} XP (${pct}%)</span>
          </div>
          <div class="progress-track">
            <div class="progress-fill" style="width:${pct}%"></div>
          </div>
        </div>
      </div>
      ${unitsHtml}
    `;
  }

  // ==========================================================================
  // TAB 2: MASKED WORD RECALL ARENA (ĐOÁN TỪ ẨN & ĐẾM NGƯỢC CEFR - 3 MODES)
  // ==========================================================================
  function generateInitialRevealedIndices(word, tierKey) {
    const cleanIndices = [];
    for (let i = 0; i < word.length; i++) {
      if (/[a-zA-Z]/.test(word[i])) cleanIndices.push(i);
    }
    if (cleanIndices.length === 0) return [];

    const revealed = new Set();
    // Always reveal the first letter as anchor
    revealed.add(cleanIndices[0]);

    const cfg = CEFR_TIMER_CONFIG[tierKey] || CEFR_TIMER_CONFIG['B1-B2'];
    if (cfg.initialHints >= 2 && cleanIndices.length >= 6) {
      // Reveal 1 strategic middle-to-late letter so 2 letters total are shown
      const midIdx = cleanIndices[Math.floor(cleanIndices.length * 0.6)];
      revealed.add(midIdx);
    }
    if (tierKey === 'A1-A2' && cleanIndices.length >= 9) {
      // For beginners on long words (9+ chars), reveal 1 extra anchor
      revealed.add(cleanIndices[cleanIndices.length - 1]);
    }
    return Array.from(revealed);
  }

  function maskWordInSentence(sentence, targetWord) {
    if (!sentence || !targetWord) return sentence;
    // Mask base word and common inflections (e.g. collaborate -> collaborated)
    const stem = targetWord.length > 5 ? targetWord.slice(0, -1) : targetWord;
    const escaped = stem.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    const regex = new RegExp('\\b' + escaped + '[a-zA-Z]*\\b', 'gi');
    const maskBar = '[' + '_'.repeat(Math.max(5, targetWord.length)) + ']';
    if (regex.test(sentence)) {
      return sentence.replace(regex, maskBar);
    }
    return sentence;
  }

  function levenshteinDistance(a, b) {
    const m = a.length;
    const n = b.length;
    const dp = Array.from({ length: m + 1 }, () => Array(n + 1).fill(0));
    for (let i = 0; i <= m; i++) dp[i][0] = i;
    for (let j = 0; j <= n; j++) dp[0][j] = j;
    for (let i = 1; i <= m; i++) {
      for (let j = 1; j <= n; j++) {
        const cost = a[i - 1] === b[j - 1] ? 0 : 1;
        dp[i][j] = Math.min(
          dp[i - 1][j] + 1,
          dp[i][j - 1] + 1,
          dp[i - 1][j - 1] + cost
        );
      }
    }
    return dp[m][n];
  }

  function shuffleArray(arr) {
    const copy = [...arr];
    for (let i = copy.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [copy[i], copy[j]] = [copy[j], copy[i]];
    }
    return copy;
  }

  function getSingleWordPool(tierFilter) {
    // Filter single/clean words suitable for spelling & active recall
    const all = state.srsCards.filter(c => c.word && c.word.trim().length >= 4);
    if (!tierFilter || tierFilter === 'ALL') return all;
    if (tierFilter === 'A1-A2') {
      const subset = all.filter(c => c.cefr === 'A1' || c.cefr === 'A2');
      return subset.length >= 5 ? subset : all;
    }
    if (tierFilter === 'B1-B2') {
      const subset = all.filter(c => c.cefr === 'B1' || c.cefr === 'B2');
      return subset.length >= 5 ? subset : all;
    }
    if (tierFilter === 'C1-C2') {
      const subset = all.filter(c => c.cefr === 'C1' || c.cefr === 'C2' || c.cefr === 'B2');
      return subset.length >= 5 ? subset : all;
    }
    return all;
  }

  window.setWcTier = function (tier) {
    state.wordChallengeStats.selectedTier = tier;
    saveState();
    render();
  };

  window.setWcTestCount = function (count) {
    state.wordChallengeStats.levelTestCount = count;
    saveState();
    render();
  };

  window.startWordChallenge = function (mode, customPoolIds) {
    stopWcTimer();
    const wcStats = state.wordChallengeStats;
    const tier = wcStats.selectedTier || 'B1-B2';
    const timerCfg = CEFR_TIMER_CONFIG[tier] || CEFR_TIMER_CONFIG['B1-B2'];

    let queue = [];
    if (Array.isArray(customPoolIds) && customPoolIds.length > 0) {
      queue = state.srsCards.filter(c => customPoolIds.includes(c.id));
    } else if (mode === 'level_test') {
      const pool = shuffleArray(getSingleWordPool(tier));
      queue = pool.slice(0, wcStats.levelTestCount || 10);
    } else if (mode === 'daily') {
      // Prioritize mistake words + deterministic/varied 5 daily words
      const mistakes = state.srsCards.filter(c => wcStats.mistakeWordIds.includes(c.id));
      const others = shuffleArray(
        state.srsCards.filter(c => !wcStats.mistakeWordIds.includes(c.id))
      );
      queue = [...mistakes, ...others].slice(0, 5);
    } else {
      // Endless mode starts with shuffled full deck and recycles infinitely
      queue = shuffleArray(getSingleWordPool('ALL'));
    }

    if (queue.length === 0) {
      queue = shuffleArray(state.srsCards).slice(0, 5);
    }

    wcSession = {
      mode, // 'level_test' | 'endless' | 'daily'
      tier,
      maxSeconds: timerCfg.seconds,
      xpMultiplier: timerCfg.xpMultiplier,
      queue,
      currentIndex: 0,
      phase: 'playing', // 'playing' | 'feedback' | 'summary'
      currentInput: '',
      revealedIndices: [],
      extraLetterHintsUsed: 0,
      synonymHintShown: false,
      remainingSeconds: timerCfg.seconds,
      questionStartTime: Date.now(),

      // Scoring & Tracking
      score: 0,
      combo: 0,
      maxCombo: 0,
      lives: 3, // Used in endless mode
      correctCount: 0,
      answeredCount: 0,
      totalResponseTimeSec: 0,
      wrongWords: [],
      lastResult: null
    };

    prepareCurrentWcWord();
    render();
  };

  window.startWordChallengeWithExternalCards = function (mode, externalCards, livePoolGetter) {
    stopWcTimer();
    const wcStats = state.wordChallengeStats;
    const tier = wcStats.selectedTier || 'B1-B2';
    const timerCfg = CEFR_TIMER_CONFIG[tier] || CEFR_TIMER_CONFIG['B1-B2'];

    currentTab = 'word_challenge';
    wcSession = {
      mode,
      isPhotoVaultSession: true,
      livePoolGetter,
      tier,
      maxSeconds: timerCfg.seconds,
      xpMultiplier: timerCfg.xpMultiplier,
      queue: shuffleArray(externalCards),
      currentIndex: 0,
      phase: 'playing',
      currentInput: '',
      revealedIndices: [],
      extraLetterHintsUsed: 0,
      synonymHintShown: false,
      remainingSeconds: timerCfg.seconds,
      questionStartTime: Date.now(),
      score: 0,
      combo: 0,
      maxCombo: 0,
      lives: 3,
      correctCount: 0,
      answeredCount: 0,
      totalResponseTimeSec: 0,
      wrongWords: [],
      lastResult: null
    };
    prepareCurrentWcWord();
    render();
  };

  window.appendNewCardsToActiveWcSession = function (newCards) {
    if (!wcSession || !wcSession.isPhotoVaultSession || !Array.isArray(newCards)) return;
    newCards.forEach(card => {
      if (!wcSession.queue.some(existing => existing.id === card.id)) {
        wcSession.queue.push(card);
      }
    });
  };

  function prepareCurrentWcWord() {
    stopWcTimer();
    if (!wcSession) return;

    // In endless mode, if we reach end of queue, reshuffle (from Photo Vault live pool if active, else full deck)!
    if (wcSession.mode === 'endless' && wcSession.currentIndex >= wcSession.queue.length) {
      if (wcSession.isPhotoVaultSession && typeof wcSession.livePoolGetter === 'function') {
        const latestPhotoCards = wcSession.livePoolGetter();
        wcSession.queue = shuffleArray(latestPhotoCards.length > 0 ? latestPhotoCards : wcSession.queue);
      } else {
        wcSession.queue = shuffleArray(getSingleWordPool('ALL'));
      }
      wcSession.currentIndex = 0;
    }

    const card = wcSession.queue[wcSession.currentIndex];
    wcSession.phase = 'playing';
    wcSession.currentInput = '';
    wcSession.revealedIndices = generateInitialRevealedIndices(card.word, wcSession.tier);
    wcSession.extraLetterHintsUsed = 0;
    wcSession.synonymHintShown = false;
    wcSession.remainingSeconds = wcSession.maxSeconds;
    wcSession.questionStartTime = Date.now();
    wcSession.lastResult = null;

    wcTimerInterval = setInterval(() => {
      if (!wcSession || wcSession.phase !== 'playing') {
        stopWcTimer();
        return;
      }
      const elapsed = (Date.now() - wcSession.questionStartTime) / 1000;
      const left = Math.max(0, wcSession.maxSeconds - elapsed);
      wcSession.remainingSeconds = left;

      // Update DOM directly so user's text input focus & IME composition are NEVER interrupted!
      const timerTextEl = document.getElementById('wc-timer-text');
      const timerBarEl = document.getElementById('wc-timer-bar');
      if (timerTextEl && timerBarEl) {
        timerTextEl.textContent = '⏱️ ' + left.toFixed(1) + 's / ' + wcSession.maxSeconds + 's';
        const pct = Math.max(0, Math.min(100, (left / wcSession.maxSeconds) * 100));
        timerBarEl.style.width = pct + '%';
        if (left <= 5) {
          timerBarEl.style.backgroundColor = 'var(--error)';
          timerTextEl.style.color = 'var(--error)';
          timerTextEl.classList.add('timer-urgent');
        } else if (pct <= 50) {
          timerBarEl.style.backgroundColor = 'var(--warning)';
          timerTextEl.style.color = 'var(--warning)';
          timerTextEl.classList.remove('timer-urgent');
        } else {
          timerBarEl.style.backgroundColor = 'var(--primary)';
          timerTextEl.style.color = 'var(--primary)';
          timerTextEl.classList.remove('timer-urgent');
        }
      }

      if (left <= 0) {
        stopWcTimer();
        evaluateWcSubmission(true);
      }
    }, 100);
  }

  window.onWcInputKeydown = function (event) {
    if (event.key === 'Enter') {
      event.preventDefault();
      window.submitWcAnswer();
    }
  };

  window.onWcInputChange = function (val) {
    if (!wcSession) return;
    wcSession.currentInput = val;
    const counterEl = document.getElementById('wc-char-counter');
    if (counterEl) {
      const targetLen = wcSession.queue[wcSession.currentIndex].word.length;
      counterEl.textContent = 'Độ dài đang gõ: ' + val.trim().length + ' / ' + targetLen + ' ký tự';
    }
  };

  window.useWcLetterHint = function () {
    if (!wcSession || wcSession.phase !== 'playing') return;
    if (wcSession.extraLetterHintsUsed >= 2) return;
    const card = wcSession.queue[wcSession.currentIndex];
    const hiddenIndices = [];
    for (let i = 0; i < card.word.length; i++) {
      if (/[a-zA-Z]/.test(card.word[i]) && !wcSession.revealedIndices.includes(i)) {
        hiddenIndices.push(i);
      }
    }
    if (hiddenIndices.length <= 1) return; // Always leave at least 1 hidden letter for user
    const pick = hiddenIndices[Math.floor(Math.random() * hiddenIndices.length)];
    wcSession.revealedIndices.push(pick);
    wcSession.extraLetterHintsUsed++;
    render();
  };

  window.useWcSynonymHint = function () {
    if (!wcSession || wcSession.phase !== 'playing') return;
    wcSession.synonymHintShown = true;
    render();
  };

  window.submitWcAnswer = function () {
    if (!wcSession || wcSession.phase !== 'playing') return;
    const inp = document.getElementById('wc-answer-input');
    if (inp) wcSession.currentInput = inp.value;
    evaluateWcSubmission(false);
  };

  function evaluateWcSubmission(timedOut) {
    stopWcTimer();
    if (!wcSession) return;

    const card = wcSession.queue[wcSession.currentIndex];
    const userRaw = (wcSession.currentInput || '').trim();
    const cleanUser = userRaw.toLowerCase();
    const cleanTarget = card.word.trim().toLowerCase();

    const elapsedSec = Math.min(
      wcSession.maxSeconds,
      Number(((Date.now() - wcSession.questionStartTime) / 1000).toFixed(1))
    );

    const isExact = !timedOut && cleanUser === cleanTarget;
    const dist = (!timedOut && cleanUser.length > 0)
      ? levenshteinDistance(cleanUser, cleanTarget)
      : 99;
    const isNearMiss = !isExact && dist === 1 && cleanTarget.length >= 5;

    wcSession.answeredCount++;
    wcSession.totalResponseTimeSec += elapsedSec;

    let earnedPoints = 0;
    let bonusHeartEarned = false;

    if (isExact) {
      wcSession.correctCount++;
      wcSession.combo++;
      if (wcSession.combo > wcSession.maxCombo) {
        wcSession.maxCombo = wcSession.combo;
      }

      const comboMult = wcSession.combo >= 5 ? 3.0 : (wcSession.combo >= 3 ? 2.0 : (wcSession.combo >= 2 ? 1.5 : 1.0));
      const speedBonus = Math.round((wcSession.remainingSeconds / wcSession.maxSeconds) * 15);
      const hintPenalty = wcSession.extraLetterHintsUsed * 3;
      earnedPoints = Math.max(10, Math.round((20 + speedBonus - hintPenalty) * wcSession.xpMultiplier * comboMult));
      wcSession.score += earnedPoints;

      // Endless mode bonus heart every 5 combo!
      if (wcSession.mode === 'endless' && wcSession.combo % 5 === 0 && wcSession.lives < 3) {
        wcSession.lives++;
        bonusHeartEarned = true;
      }

      // Remove from mistake bank if mastered
      state.wordChallengeStats.mistakeWordIds = state.wordChallengeStats.mistakeWordIds.filter(id => id !== card.id);
      // Sync with SM-2 SRS
      window.gradeSrsCardSilent(card.id, elapsedSec <= wcSession.maxSeconds * 0.5 ? 'easy' : 'good');
      addXp(10);
    } else {
      wcSession.combo = 0;
      if (wcSession.mode === 'endless') {
        wcSession.lives = Math.max(0, wcSession.lives - 1);
      }
      if (!wcSession.wrongWords.some(w => w.id === card.id)) {
        wcSession.wrongWords.push(card);
      }
      if (!state.wordChallengeStats.mistakeWordIds.includes(card.id)) {
        state.wordChallengeStats.mistakeWordIds.push(card.id);
      }
      window.gradeSrsCardSilent(card.id, 'again');
    }

    // Auto pronounce the word on reveal to reinforce auditory memory!
    window.speakText(card.word, 1.0);

    wcSession.phase = 'feedback';
    wcSession.lastResult = {
      isExact,
      isNearMiss,
      timedOut,
      userAnswer: userRaw,
      elapsedSec,
      earnedPoints,
      bonusHeartEarned
    };

    saveState();
    render();
  };

  window.gradeSrsCardSilent = function (cardId, grade) {
    const card = state.srsCards.find(c => c.id === cardId);
    if (!card) return;
    if (grade === 'again') {
      card.repetition = 0;
      card.intervalDays = 1;
      card.easeFactor = Math.max(1.3, Number(((card.easeFactor || 2.5) - 0.2).toFixed(2)));
      card.nextReviewTime = Date.now() + 60 * 1000;
    } else {
      card.repetition = (card.repetition || 0) + 1;
      const mult = grade === 'easy' ? 7 : 4;
      card.intervalDays = mult;
      card.nextReviewTime = Date.now() + mult * 86400 * 1000;
    }
  };

  window.nextWcStep = function () {
    if (!wcSession) return;

    // Check termination conditions
    if (wcSession.mode === 'endless' && wcSession.lives <= 0) {
      finishWcSession();
      return;
    }
    if (wcSession.mode !== 'endless' && wcSession.currentIndex >= wcSession.queue.length - 1) {
      finishWcSession();
      return;
    }

    wcSession.currentIndex++;
    prepareCurrentWcWord();
    render();
  };

  function finishWcSession() {
    stopWcTimer();
    if (!wcSession) return;
    wcSession.phase = 'summary';

    const wcStats = state.wordChallengeStats;
    const accuracy = wcSession.answeredCount > 0
      ? Math.round((wcSession.correctCount / wcSession.answeredCount) * 100)
      : 0;
    const avgTimeSec = wcSession.answeredCount > 0
      ? Number((wcSession.totalResponseTimeSec / wcSession.answeredCount).toFixed(1))
      : 0;

    if (wcSession.mode === 'endless') {
      if (wcSession.score > (wcStats.bestEndlessScore || 0)) {
        wcStats.bestEndlessScore = wcSession.score;
      }
      if (wcSession.maxCombo > (wcStats.bestEndlessCombo || 0)) {
        wcStats.bestEndlessCombo = wcSession.maxCombo;
      }
    }

    if (wcSession.mode === 'daily') {
      const todayLabel = new Date().toLocaleDateString('vi-VN');
      if (wcStats.lastDailyDate !== todayLabel) {
        wcStats.dailyStreak = (wcStats.dailyStreak || 0) + 1;
        wcStats.lastDailyDate = todayLabel;
      }
      const prevEntry = wcStats.dailyHistory.length > 0
        ? wcStats.dailyHistory[wcStats.dailyHistory.length - 1]
        : null;
      wcSession.dailyComparison = prevEntry;

      wcStats.dailyHistory.push({
        date: todayLabel,
        accuracy,
        avgTimeSec,
        score: wcSession.score
      });
      if (wcStats.dailyHistory.length > 14) {
        wcStats.dailyHistory.shift();
      }
    }

    saveState();
    render();
  }

  window.exitWcToLobby = function () {
    stopWcTimer();
    wcSession = null;
    render();
  };

  function renderWordChallengeTab() {
    if (!wcSession) {
      return renderWcLobby();
    }
    if (wcSession.phase === 'summary') {
      return renderWcSummary();
    }
    return renderWcActiveArena();
  }

  function renderWcLobby() {
    const wcStats = state.wordChallengeStats;
    const tier = wcStats.selectedTier || 'B1-B2';
    const lastDaily = wcStats.dailyHistory[wcStats.dailyHistory.length - 1];
    const mistakeCards = state.srsCards.filter(c => wcStats.mistakeWordIds.includes(c.id));

    const tierButtons = Object.keys(CEFR_TIMER_CONFIG).map(key => {
      const cfg = CEFR_TIMER_CONFIG[key];
      return `
        <button class="word-chip ${tier === key ? 'selected' : ''}" onclick="window.setWcTier('${key}')">
          ${cfg.label} • Nhân ${cfg.xpMultiplier}x điểm
        </button>
      `;
    }).join('');

    return `
      <div class="hero-banner" style="background:linear-gradient(135deg, #059669, #4F46E5)">
        <div class="hero-title">⚡ Đấu Trường Phản Xạ Đoán Từ Vựng Ẩn</div>
        <div class="hero-sub">
          Từ vựng sẽ bị ẩn đi và chỉ mở <strong>1 - 2 chữ cái gợi ý</strong>. Hãy gõ đúng từ trước khi đồng hồ đếm ngược kết thúc để mở khóa phân tích <strong>Ngữ pháp, Cách dùng, Collocations & Đồng/Trái nghĩa</strong>!
        </div>
      </div>

      <div class="card">
        <div class="unit-title">Bước 1: Chọn Tốc Độ Đếm Ngược Theo Trình Độ Tiếng Anh</div>
        <div class="unit-desc">Trình độ càng cao, số chữ gợi ý càng ít, thời gian đếm ngược càng ngắn và điểm thưởng càng lớn:</div>
        <div class="chip-wrap">${tierButtons}</div>
      </div>

      <div class="mode-grid">
        <!-- MODE 1: LEVEL TEST -->
        <div class="mode-card">
          <div>
            <span class="badge-tag">CHẾ ĐỘ 1 • KIỂM TRA TRÌNH ĐỘ</span>
            <div class="unit-title" style="margin-top:10px">🎯 Test Số Lượng Cố Định</div>
            <div class="unit-desc">
              Kiểm tra năng lực nhớ chính tả & phản xạ từ vựng theo gói câu hỏi cố định. Chấm điểm tốc độ trung bình và xếp loại trình độ cuối bài.
            </div>
            <div class="chip-wrap" style="margin-bottom:14px">
              <button class="word-chip ${wcStats.levelTestCount === 5 ? 'selected' : ''}" onclick="window.setWcTestCount(5)">Gói 5 từ nhanh</button>
              <button class="word-chip ${wcStats.levelTestCount === 10 ? 'selected' : ''}" onclick="window.setWcTestCount(10)">Gói 10 từ chuẩn</button>
            </div>
          </div>
          <button class="btn btn-primary btn-block" onclick="window.startWordChallenge('level_test')">
            ▶ Bắt đầu Test ${wcStats.levelTestCount} từ (${tier})
          </button>
        </div>

        <!-- MODE 2: ENDLESS SURVIVAL -->
        <div class="mode-card">
          <div>
            <span class="badge-tag" style="background:rgba(249,115,22,0.15);color:var(--streak)">CHẾ ĐỘ 2 • VÔ TẬN SINH TỒN</span>
            <div class="unit-title" style="margin-top:10px">🔥 Chế Độ Vô Tận (Endless)</div>
            <div class="unit-desc">
              Thử thách liên tục không giới hạn với <strong>3 Tim (❤️❤️❤️)</strong> & nhân điểm <strong>Combo x1 → x3</strong>. Cứ đúng 5 câu liên tiếp được hồi +1 Tim!
            </div>
            <div style="padding:10px 12px;border-radius:12px;background:var(--surface-alt);font-size:13px;font-weight:700;margin-bottom:14px">
              🏆 Kỷ lục của bạn: <span style="color:var(--primary)">${wcStats.bestEndlessScore} điểm</span><br>
              ⚡ Combo dài nhất: <span style="color:var(--streak)">${wcStats.bestEndlessCombo} từ liên tiếp</span>
            </div>
          </div>
          <button class="btn btn-secondary btn-block" onclick="window.startWordChallenge('endless')">
            🔥 Chiến Chế Độ Vô Tận
          </button>
        </div>

        <!-- MODE 3: DAILY BETTER EVERY DAY -->
        <div class="mode-card">
          <div>
            <span class="badge-tag" style="background:rgba(16,185,129,0.15);color:var(--primary)">CHẾ ĐỘ 3 • TỐT HƠN MỖI NGÀY</span>
            <div class="unit-title" style="margin-top:10px">📅 Thử Thách Mỗi Ngày (5 Từ)</div>
            <div class="unit-desc">
              5 từ chọn lọc mỗi ngày (kết hợp từ mới & từ bạn từng sai). Đo lường chỉ số <strong>"Tốt hơn mỗi ngày 1%"</strong> về tốc độ & độ chính xác!
            </div>
            <div style="padding:10px 12px;border-radius:12px;background:var(--surface-alt);font-size:13px;font-weight:700;margin-bottom:14px">
              📈 Chuỗi Daily Recall: <span style="color:var(--primary)">${wcStats.dailyStreak} ngày</span><br>
              ⏱️ Phiên gần nhất: ${lastDaily ? `${lastDaily.accuracy}% đúng • ${lastDaily.avgTimeSec}s/từ` : 'Chưa có dữ liệu'}
            </div>
          </div>
          <button class="btn btn-primary btn-block" onclick="window.startWordChallenge('daily')">
            🌱 Chinh Phục 5 Từ Hôm Nay
          </button>
        </div>
      </div>

      <div class="card">
        <div style="display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:10px">
          <div>
            <div class="unit-title" style="margin:0">📕 Sổ Tay Từ Cần Khắc Phục (${mistakeCards.length} từ)</div>
            <div class="unit-desc" style="margin:4px 0 0">Các từ bạn từng gõ sai hoặc hết giờ được tự động gom vào đây để luyện lại tới khi thuộc nằm lòng.</div>
          </div>
          ${mistakeCards.length > 0 ? `
            <button class="btn btn-outline" onclick='window.startWordChallenge("level_test", ${JSON.stringify(mistakeCards.map(c => c.id))})'>
              🎯 Ôn tập ngay ${mistakeCards.length} từ hay sai
            </button>
          ` : ''}
        </div>
        ${mistakeCards.length > 0 ? `
          <div class="chip-wrap" style="margin-top:12px">
            ${mistakeCards.map(c => `<span class="badge-tag" style="background:rgba(239,68,68,0.13);color:var(--error)">${c.word} (${c.vietnameseMeaning})</span>`).join('')}
          </div>
        ` : `
          <div style="margin-top:10px;font-size:13px;color:var(--success);font-weight:700">
            ✨ Tuyệt vời! Hiện tại bạn không có từ nào bị tồn đọng trong Sổ tay từ sai.
          </div>
        `}
      </div>
    `;
  }

  function renderWcActiveArena() {
    const card = wcSession.queue[wcSession.currentIndex];
    const modeTitle = wcSession.mode === 'level_test'
      ? `🎯 Kiểm tra trình độ (${wcSession.currentIndex + 1}/${wcSession.queue.length})`
      : (wcSession.mode === 'daily'
        ? `📅 Thử thách mỗi ngày (${wcSession.currentIndex + 1}/${wcSession.queue.length})`
        : `🔥 Vô tận Sinh tồn • Câu #${wcSession.answeredCount + (wcSession.phase === 'playing' ? 1 : 0)}`);

    // Build Masked Letter Tiles
    const tilesHtml = Array.from(card.word).map((ch, idx) => {
      if (ch === ' ') {
        return `<span class="letter-tile space-tile"></span>`;
      }
      const showChar = wcSession.phase === 'feedback' || wcSession.revealedIndices.includes(idx);
      return `
        <span class="letter-tile ${showChar ? 'hint-revealed' : ''}">
          ${showChar ? ch : '_'}
        </span>
      `;
    }).join('');

    const maskedSentence = maskWordInSentence(card.exampleSentence, card.word);

    if (wcSession.phase === 'playing') {
      const pct = Math.max(0, Math.min(100, (wcSession.remainingSeconds / wcSession.maxSeconds) * 100));
      return `
        <div class="card">
          <div style="display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:10px">
            <div style="display:flex;align-items:center;gap:8px;flex-wrap:wrap">
              <span class="badge-tag">${modeTitle}</span>
              <span class="badge-tag">${wcSession.tier}</span>
              <span class="combo-badge">⚡ Điểm: ${wcSession.score} • Combo x${Math.max(1, wcSession.combo)}</span>
              ${wcSession.mode === 'endless' ? `<span class="stat-pill stat-heart">${'❤️'.repeat(wcSession.lives)}${'🖤'.repeat(3 - wcSession.lives)}</span>` : ''}
            </div>
            <button class="icon-btn" onclick="window.exitWcToLobby()">✕ Dừng chơi</button>
          </div>

          <div style="display:flex;justify-content:space-between;align-items:center;margin-top:14px">
            <span style="font-size:13px;font-weight:700;color:var(--text-muted)">Thời gian đếm ngược</span>
            <span id="wc-timer-text" style="font-size:16px;font-weight:800;color:var(--primary)">
              ⏱️ ${wcSession.remainingSeconds.toFixed(1)}s / ${wcSession.maxSeconds}s
            </span>
          </div>
          <div class="timer-bar-track">
            <div id="wc-timer-bar" class="timer-bar-fill" style="width:${pct}%"></div>
          </div>

          <!-- Meaning & Masked Word -->
          <div style="text-align:center;padding:10px 0">
            <span class="badge-tag">${card.topic} • ${card.partOfSpeech}</span>
            <div style="font-size:22px;font-weight:800;margin-top:10px;color:var(--text)">
              🇻🇳 ${card.vietnameseMeaning}
            </div>
            <div style="font-size:13px;color:var(--text-muted);margin-top:4px">
              (${card.word.length} chữ cái — Hãy nhập đầy đủ từ tiếng Anh bên dưới)
            </div>

            <div class="masked-tiles-wrap">
              ${tilesHtml}
            </div>

            <div style="padding:12px 16px;border-radius:14px;background:var(--surface-alt);display:inline-block;max-width:620px;font-size:15px;font-style:italic">
              📝 Ngữ cảnh: "${maskedSentence}"
            </div>

            ${wcSession.synonymHintShown && card.synonyms && card.synonyms.length > 0 ? `
              <div style="margin-top:10px;font-size:13px;font-weight:700;color:var(--secondary)">
                🧩 Gợi ý từ đồng nghĩa: ${card.synonyms.join(', ')}
              </div>
            ` : ''}
          </div>

          <!-- Hint Lifelines -->
          <div style="display:flex;justify-content:center;gap:8px;flex-wrap:wrap;margin:14px 0">
            <button class="icon-btn" ${wcSession.extraLetterHintsUsed >= 2 ? 'disabled style="opacity:0.45"' : ''} onclick="window.useWcLetterHint()">
              💡 Mở thêm 1 chữ cái (${2 - wcSession.extraLetterHintsUsed} lượt)
            </button>
            <button class="icon-btn" onclick="window.speakText('${card.word.replace(/'/g, "\\'")}', 0.85)">
              🔊 Nghe phát âm gợi ý
            </button>
            ${(card.synonyms && card.synonyms.length > 0 && !wcSession.synonymHintShown) ? `
              <button class="icon-btn" onclick="window.useWcSynonymHint()">
                🧩 Xem từ đồng nghĩa
              </button>
            ` : ''}
          </div>

          <!-- Input & Submit -->
          <div style="max-width:500px;margin:14px auto 0">
            <div class="input-row">
              <input id="wc-answer-input"
                     type="text"
                     autocomplete="off"
                     autocapitalize="none"
                     spellcheck="false"
                     class="text-input"
                     style="font-size:18px;font-weight:700;text-align:center;letter-spacing:1px"
                     value="${wcSession.currentInput.replace(/"/g, '&quot;')}"
                     placeholder="Gõ từ tiếng Anh đầy đủ rồi nhấn Enter..."
                     oninput="window.onWcInputChange(this.value)"
                     onkeydown="window.onWcInputKeydown(event)" />
              <button class="btn btn-primary" onclick="window.submitWcAnswer()">Kiểm tra ↵</button>
            </div>
            <div id="wc-char-counter" style="text-align:center;font-size:12px;color:var(--text-muted);margin-top:6px">
              Độ dài đang gõ: ${wcSession.currentInput.trim().length} / ${card.word.length} ký tự
            </div>
          </div>
        </div>
      `;
    }

    // ========================================================================
    // POST-ANSWER DEEP KNOWLEDGE REVEAL PHASE
    // ========================================================================
    const res = wcSession.lastResult;
    const statusBannerClass = res.isExact ? 'correct' : 'incorrect';
    let statusHeadline = '';
    if (res.isExact) {
      statusHeadline = `✅ Chính xác tuyệt đối trong ${res.elapsedSec}s! (+${res.earnedPoints} điểm${res.bonusHeartEarned ? ' • ❤️ Thưởng hồi +1 Tim Combo 5!' : ''})`;
    } else if (res.timedOut) {
      statusHeadline = `⏰ Hết thời gian (${wcSession.maxSeconds}s)! Đáp án đúng là "${card.word}".`;
    } else if (res.isNearMiss) {
      statusHeadline = `🤏 Rất sát! Bạn gõ "${res.userAnswer}" (chỉ lệch 1 ký tự so với "${card.word}"). Chú ý chính tả nhé!`;
    } else {
      statusHeadline = `❌ Chưa chính xác (Bạn nhập: "${res.userAnswer || 'trống'}"). Đáp án chuẩn là "${card.word}".`;
    }

    const collocationsHtml = (card.collocations || []).map(col =>
      `<span class="badge-tag" style="margin:3px 4px 3px 0">${col}</span>`
    ).join('');

    const synHtml = (card.synonyms && card.synonyms.length > 0)
      ? card.synonyms.join(', ')
      : 'Đang cập nhật';
    const antHtml = (card.antonyms && card.antonyms.length > 0)
      ? card.antonyms.join(', ')
      : '—';

    const isGameOver = wcSession.mode === 'endless' && wcSession.lives <= 0;
    const isLastFixed = wcSession.mode !== 'endless' && wcSession.currentIndex >= wcSession.queue.length - 1;

    return `
      <div class="card">
        <div style="display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:8px;margin-bottom:10px">
          <span class="badge-tag">${modeTitle}</span>
          <span class="combo-badge">⚡ Tổng điểm: ${wcSession.score} • Combo hiện tại: x${wcSession.combo}</span>
        </div>

        <div class="feedback-box ${statusBannerClass}">
          <div style="font-weight:800;font-size:16px">${statusHeadline}</div>
        </div>

        <!-- Word Header + Audio + Full Example -->
        <div style="padding:18px;border-radius:18px;border:1.5px solid var(--primary);background:rgba(16,185,129,0.05);margin-top:12px">
          <div style="display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:10px">
            <div>
              <span style="font-size:30px;font-weight:800">${card.word}</span>
              <span class="ipa-text" style="font-size:17px;margin-left:10px">${card.ipa}</span>
              <span class="badge-tag" style="margin-left:8px">${card.partOfSpeech}</span>
            </div>
            <div style="display:flex;gap:8px">
              <button class="btn btn-outline" onclick="window.speakText('${card.word.replace(/'/g, "\\'")}', 1.0)">🔊 Phát âm chuẩn</button>
              <button class="btn btn-outline" onclick="window.speakText('${card.word.replace(/'/g, "\\'")}', 0.7)">🐢 Nghe chậm</button>
            </div>
          </div>

          <div style="font-size:18px;font-weight:800;color:var(--primary);margin-top:8px">
            🇻🇳 Nghĩa: ${card.vietnameseMeaning}
          </div>
          <div style="margin-top:8px;font-size:15px">
            <strong>📌 Câu ví dụ chuẩn:</strong> "${card.exampleSentence}"
            <button class="icon-btn" style="margin-left:6px;padding:3px 8px;font-size:12px" onclick="window.speakText('${card.exampleSentence.replace(/'/g, "\\'")}', 1.0)">🔊 Nghe cả câu</button>
          </div>
        </div>

        <!-- 4 Deep-Dive Linguistic Cards (Grammar, Usage, Collocations, Synonyms) -->
        <div class="deep-dive-grid">
          <div class="deep-dive-box">
            <div class="deep-dive-title" style="color:var(--secondary)">📐 Ngữ pháp & Cấu trúc đi kèm</div>
            <div style="font-size:14px">${card.grammarNote || 'Đứng đúng vị trí từ loại trong câu.'}</div>
          </div>

          <div class="deep-dive-box">
            <div class="deep-dive-title" style="color:var(--primary)">💬 Cách dùng thực tế & Lưu ý lỗi sai</div>
            <div style="font-size:14px">${card.usageTip || 'Sử dụng trong giao tiếp và viết email công việc.'}</div>
          </div>

          <div class="deep-dive-box">
            <div class="deep-dive-title" style="color:var(--streak)">🔗 Cụm từ cố định (Collocations) & Gia đình từ</div>
            <div style="margin-bottom:6px">${collocationsHtml}</div>
            <div style="font-size:13px;color:var(--text-muted)"><strong>Word Family:</strong> ${card.wordFamily || card.word}</div>
          </div>

          <div class="deep-dive-box">
            <div class="deep-dive-title" style="color:var(--info)">🔄 Mở rộng Đồng nghĩa & Trái nghĩa</div>
            <div style="font-size:14px"><strong>Đồng nghĩa (Synonyms):</strong> ${synHtml}</div>
            <div style="font-size:14px;margin-top:4px"><strong>Trái nghĩa (Antonyms):</strong> ${antHtml}</div>
          </div>
        </div>

        <div style="margin-top:18px">
          <button class="btn btn-primary btn-block" onclick="window.nextWcStep()">
            ${isGameOver
              ? '🏁 Hết Tim Sinh Tồn — Xem Bảng Tổng Kết Kỷ Lục'
              : (isLastFixed
                ? '🏆 Xem Bảng Đánh Giá Tổng Kết'
                : 'Từ tiếp theo →')}
          </button>
        </div>
      </div>
    `;
  }

  function renderWcSummary() {
    const accuracy = wcSession.answeredCount > 0
      ? Math.round((wcSession.correctCount / wcSession.answeredCount) * 100)
      : 0;
    const avgTime = wcSession.answeredCount > 0
      ? Number((wcSession.totalResponseTimeSec / wcSession.answeredCount).toFixed(1))
      : 0;

    let rankLabel = 'Cần luyện thêm (A1-A2)';
    if (accuracy >= 90 && avgTime <= 8) rankLabel = '🌟 Phản xạ Xuất thần (C1 Master)';
    else if (accuracy >= 80) rankLabel = '🔥 Thành thạo Chủ động (B2 Upper-Intermediate)';
    else if (accuracy >= 60) rankLabel = '👍 Nền tảng Vững (B1 Intermediate)';

    let dailyDiffHtml = '';
    if (wcSession.mode === 'daily' && wcSession.dailyComparison) {
      const prev = wcSession.dailyComparison;
      const accDiff = accuracy - prev.accuracy;
      const speedDiff = Number((prev.avgTimeSec - avgTime).toFixed(1));
      dailyDiffHtml = `
        <div style="padding:16px;border-radius:16px;background:rgba(16,185,129,0.1);border:1.5px solid var(--primary);margin:16px 0;text-align:left">
          <div style="font-weight:800;color:var(--primary);margin-bottom:6px">
            🌱 Báo Cáo "Tốt Hơn Mỗi Ngày 1%" (So với phiên trước: ${prev.date})
          </div>
          <div style="font-size:14px">
            • Độ chính xác: <strong>${accuracy}%</strong> (${accDiff >= 0 ? `<span style="color:var(--success)">+${accDiff}% tiến bộ ▲</span>` : `<span style="color:var(--warning)">${accDiff}%</span>`})<br>
            • Tốc độ phản xạ trung bình: <strong>${avgTime}s / từ</strong> (${speedDiff >= 0 ? `<span style="color:var(--success)">Nhanh hơn ${speedDiff}s ⚡</span>` : `<span style="color:var(--warning)">Chậm hơn ${Math.abs(speedDiff)}s</span>`})
          </div>
        </div>
      `;
    }

    const wrongListHtml = wcSession.wrongWords.length > 0 ? `
      <div style="text-align:left;margin-top:16px">
        <div style="font-weight:800;margin-bottom:8px">📌 Các từ cần ôn kỹ lại (đã lưu vào Sổ tay):</div>
        ${wcSession.wrongWords.map(w => `
          <div class="lesson-item">
            <div>
              <strong>${w.word}</strong> <span class="ipa-text">${w.ipa}</span> — ${w.vietnameseMeaning}
              <div style="font-size:12px;color:var(--text-muted)">${w.grammarNote || ''}</div>
            </div>
            <button class="icon-btn" onclick="window.speakText('${w.word.replace(/'/g, "\\'")}', 1.0)">🔊 Nghe</button>
          </div>
        `).join('')}
      </div>
    ` : `
      <div style="margin:16px 0;color:var(--success);font-weight:800">
        🎯 Tuyệt đỉnh! Bạn không sai bất kỳ từ nào trong lượt chơi này!
      </div>
    `;

    return `
      <div class="card" style="text-align:center">
        <div style="font-size:44px">🏆</div>
        <div class="unit-title" style="font-size:24px;margin-top:6px">Hoàn Thành Thử Thách Phản Xạ Từ Vựng!</div>
        <div class="unit-desc">Đánh giá năng lực: <strong style="color:var(--primary)">${rankLabel}</strong></div>

        <div class="grid-3" style="margin-top:16px">
          <div class="deep-dive-box">
            <div style="font-size:24px;font-weight:800;color:var(--primary)">${wcSession.score}</div>
            <div style="font-size:12px;font-weight:700">Tổng Điểm Đạt Được</div>
          </div>
          <div class="deep-dive-box">
            <div style="font-size:24px;font-weight:800;color:var(--secondary)">${accuracy}% (${wcSession.correctCount}/${wcSession.answeredCount})</div>
            <div style="font-size:12px;font-weight:700">Độ Chính Xác</div>
          </div>
          <div class="deep-dive-box">
            <div style="font-size:24px;font-weight:800;color:var(--streak)">${avgTime}s / từ</div>
            <div style="font-size:12px;font-weight:700">Tốc Độ Phản Xạ TB</div>
          </div>
        </div>

        ${dailyDiffHtml}
        ${wrongListHtml}

        <div style="display:flex;gap:10px;margin-top:20px;flex-wrap:wrap">
          <button class="btn btn-outline" style="flex:1" onclick="window.exitWcToLobby()">
            ← Về Sảnh Chọn Chế Độ
          </button>
          <button class="btn btn-primary" style="flex:1" onclick="window.startWordChallenge('${wcSession.mode}')">
            🔄 Chơi Lại Chế Độ Này
          </button>
        </div>
      </div>
    `;
  }

  // ==========================================================================
  // TAB 3: SRS VOCABULARY FLASHCARDS (SM-2 ALGORITHM)
  // ==========================================================================
  function renderSrsTab() {
    const now = Date.now();
    const topics = ['ALL', ...Array.from(new Set(state.srsCards.map(c => c.topic)))];

    const filteredCards = state.srsCards.filter(c =>
      srsTopicFilter === 'ALL' ? true : c.topic === srsTopicFilter
    );

    const dueCards = filteredCards.filter(c => srsPracticeAllMode || (c.nextReviewTime || 0) <= now);
    const masteredCount = state.srsCards.filter(c => (c.repetition || 0) >= 2).length;
    const activeCard = dueCards[srsActiveIndex % Math.max(1, dueCards.length)];

    const topicChips = topics.map(t => `
      <button class="word-chip ${srsTopicFilter === t ? 'selected' : ''}" onclick="window.setSrsTopic('${t}')">
        ${t === 'ALL' ? 'Tất cả chủ đề (' + state.srsCards.length + ')' : t}
      </button>
    `).join('');

    let reviewerHtml = '';
    if (activeCard) {
      reviewerHtml = `
        <div class="flashcard-box">
          <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:12px">
            <span class="badge-tag">${activeCard.topic} • ${activeCard.partOfSpeech}</span>
            <div style="display:flex;gap:6px">
              <button class="icon-btn" onclick="window.speakText('${activeCard.word.replace(/'/g, "\\'")}', 1.0)">🔊 Nghe chuẩn</button>
              <button class="icon-btn" onclick="window.speakText('${activeCard.word.replace(/'/g, "\\'")}', 0.7)">🐢 Nghe chậm</button>
            </div>
          </div>
          <div style="font-size:34px;font-weight:800;margin:10px 0 4px">${activeCard.word}</div>
          <div class="ipa-text" style="font-size:17px;margin-bottom:18px">${activeCard.ipa}</div>

          ${!srsCardRevealed ? `
            <button class="btn btn-outline" style="min-width:240px" onclick="window.revealSrsCard()">
              🔄 Lật thẻ xem nghĩa, ngữ pháp & ví dụ
            </button>
          ` : `
            <div style="border-top:1.5px solid var(--border);padding-top:16px;margin-top:10px;text-align:left">
              <div style="font-size:20px;font-weight:800;color:var(--primary);margin-bottom:6px">
                ${activeCard.vietnameseMeaning}
              </div>
              <div style="font-size:15px;font-style:italic;margin-bottom:8px">
                "${activeCard.exampleSentence}"
                <button class="icon-btn" style="margin-left:8px;padding:3px 8px" onclick="window.speakText('${activeCard.exampleSentence.replace(/'/g, "\\'")}', 1.0)">🔊 Nghe câu</button>
              </div>
              ${activeCard.grammarNote ? `<div style="font-size:13px;margin-top:6px"><strong>📐 Ngữ pháp:</strong> ${activeCard.grammarNote}</div>` : ''}
              ${activeCard.usageTip ? `<div style="font-size:13px;margin-top:4px"><strong>💬 Cách dùng:</strong> ${activeCard.usageTip}</div>` : ''}
              <div style="font-size:13px;color:var(--text-muted);margin-top:14px">
                Đánh giá mức độ nhớ của bạn để thuật toán SM-2 tính lịch ôn tập (+5 XP):
              </div>
              <div class="srs-grade-grid">
                <button class="grade-btn" style="background:rgba(239,68,68,0.15);color:#ef4444;border-color:#ef4444" onclick="window.gradeSrsCard('${activeCard.id}', 'again')">
                  Quên<br>(Ôn lại ngay)
                </button>
                <button class="grade-btn" style="background:rgba(245,158,11,0.15);color:#f59e0b;border-color:#f59e0b" onclick="window.gradeSrsCard('${activeCard.id}', 'hard')">
                  Khó<br>(2 ngày)
                </button>
                <button class="grade-btn" style="background:rgba(59,130,246,0.15);color:#3b82f6;border-color:#3b82f6" onclick="window.gradeSrsCard('${activeCard.id}', 'good')">
                  Nhớ tốt<br>(4 ngày)
                </button>
                <button class="grade-btn" style="background:rgba(34,197,94,0.15);color:#22c55e;border-color:#22c55e" onclick="window.gradeSrsCard('${activeCard.id}', 'easy')">
                  Rất dễ<br>(7 ngày)
                </button>
              </div>
            </div>
          `}
        </div>
      `;
    } else {
      reviewerHtml = `
        <div class="card" style="text-align:center;padding:28px">
          <div style="font-size:40px;margin-bottom:8px">🎉</div>
          <div class="unit-title">Bạn đã hoàn thành toàn bộ thẻ đến hạn!</div>
          <div class="unit-desc">Hãy thử chuyển sang Đấu Trường Đoán Từ Ẩn hoặc ôn lại toàn bộ kho thẻ Offline.</div>
          <div style="display:flex;justify-content:center;gap:10px;flex-wrap:wrap">
            <button class="btn btn-primary" onclick="window.switchTab('word_challenge')">
              ⚡ Vào Đấu Trường Đoán Từ Ẩn
            </button>
            <button class="btn btn-outline" onclick="window.togglePracticeAllSrs()">
              🔄 Lật lại toàn bộ ${filteredCards.length} thẻ
            </button>
          </div>
        </div>
      `;
    }

    const deckListHtml = filteredCards.map(c => `
      <div class="lesson-item">
        <div>
          <div style="display:flex;align-items:center;gap:8px;flex-wrap:wrap">
            <span style="font-weight:800;font-size:16px">${c.word}</span>
            <span class="ipa-text" style="font-size:13px">${c.ipa}</span>
            <span class="badge-tag">${c.topic}</span>
          </div>
          <div style="font-size:14px;font-weight:600;margin-top:3px">${c.vietnameseMeaning}</div>
          <div style="font-size:13px;color:var(--text-muted);font-style:italic">"${c.exampleSentence}"</div>
          <div style="font-size:11px;color:var(--text-muted);margin-top:4px">
            SM-2: Lặp lại ${c.repetition || 0} lần • Hệ số EF: ${c.easeFactor || 2.5} • Chu kỳ: ${c.intervalDays || 0} ngày
          </div>
        </div>
        <button class="icon-btn" onclick="window.speakText('${c.word.replace(/'/g, "\\'")}', 1.0)">🔊 Phát âm</button>
      </div>
    `).join('');

    return `
      <div class="card" style="background:linear-gradient(135deg, rgba(16,185,129,0.12), rgba(99,102,241,0.12));border-color:var(--primary)">
        <div style="display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:12px">
          <div>
            <div class="unit-title" style="margin:0">⚡ Muốn nhớ chính tả & phản xạ nhanh gấp 3 lần?</div>
            <div style="font-size:14px;color:var(--text-muted)">Chuyển sang chế độ <strong>Đoán Từ Ẩn có Đếm Ngược</strong> (Test trình độ, Vô tận, hoặc 5 Từ Mỗi Ngày).</div>
          </div>
          <button class="btn btn-primary" onclick="window.switchTab('word_challenge')">
            ⚡ Mở Đấu Trường Đoán Từ Ẩn
          </button>
        </div>
      </div>

      <div class="grid-3">
        <div class="card" style="margin-bottom:0;text-align:center">
          <div style="font-size:24px;font-weight:800;color:var(--streak)">${dueCards.length}</div>
          <div style="font-size:13px;font-weight:700">Thẻ sẵn sàng ôn tập</div>
        </div>
        <div class="card" style="margin-bottom:0;text-align:center">
          <div style="font-size:24px;font-weight:800;color:var(--secondary)">${state.srsCards.length}</div>
          <div style="font-size:13px;font-weight:700">Tổng từ vựng Offline</div>
        </div>
        <div class="card" style="margin-bottom:0;text-align:center">
          <div style="font-size:24px;font-weight:800;color:var(--success)">${masteredCount}</div>
          <div style="font-size:13px;font-weight:700">Từ đã thuộc sâu</div>
        </div>
      </div>

      <div class="card">
        <div style="display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:10px;margin-bottom:10px">
          <div class="unit-title" style="margin:0">Lọc theo Chủ đề Từ vựng</div>
          <button class="btn btn-primary" onclick="window.openAddCardModal()">+ Thêm thẻ từ vựng mới</button>
        </div>
        <div class="chip-wrap">${topicChips}</div>
      </div>

      ${reviewerHtml}

      <div class="card">
        <div class="unit-title">Danh sách toàn bộ Kho từ vựng (${filteredCards.length} từ)</div>
        <div class="unit-desc">Bấm vào nút Loa ở từng từ để nghe giọng đọc tiếng Anh bản xứ Offline.</div>
        ${deckListHtml}
      </div>
    `;
  }

  // ==========================================================================
  // TAB 4: AI TUTOR ROLEPLAY (OFFLINE MULTI-TURN ENGINE)
  // ==========================================================================
  function renderAiTab() {
    const activeSc = CURRICULUM.aiScenarios.find(s => s.id === activeScenarioId) || CURRICULUM.aiScenarios[0];
    const lastAi = [...aiChatHistory].reverse().find(m => !m.isUser) || aiChatHistory[0];

    const scenarioChips = CURRICULUM.aiScenarios.map(s => `
      <button class="word-chip ${s.id === activeScenarioId ? 'selected' : ''}" onclick="window.selectAiScenario('${s.id}')">
        🎭 ${s.title} (${s.cefr})
      </button>
    `).join('');

    const targetVocabBadges = activeSc.targetVocabulary.map(w => {
      const used = aiChatHistory.some(m => m.isUser && m.text.toLowerCase().includes(w.toLowerCase()));
      return `
        <span class="badge-tag" style="margin-right:6px;background:${used ? 'rgba(34,197,94,0.18);color:#16a34a' : 'rgba(99,102,241,0.14);color:var(--secondary)'}">
          ${used ? '✓ ' : ''}${w}
        </span>
      `;
    }).join('');

    const messagesHtml = aiChatHistory.map(m => `
      <div class="chat-bubble ${m.isUser ? 'user' : ''}">
        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:4px">
          <span style="font-size:12px;font-weight:800;color:${m.isUser ? 'var(--primary-dark)' : 'var(--secondary)'}">
            ${m.isUser ? '🧑 Bạn' : '🤖 AI Tutor (' + activeSc.title + ')'}
          </span>
          <button class="icon-btn" style="padding:2px 8px;font-size:12px" onclick="window.speakText('${m.text.replace(/'/g, "\\'")}', 1.0)">
            🔊 Nghe
          </button>
        </div>
        <div style="font-size:15px;font-weight:500">${m.text}</div>
        ${m.translation ? `<div style="font-size:13px;color:var(--text-muted);font-style:italic;margin-top:5px">🇻🇳 ${m.translation}</div>` : ''}
        ${m.grammarFeedback ? `
          <div style="margin-top:8px;padding:8px 10px;border-radius:10px;background:rgba(34,197,94,0.12);font-size:12px;font-weight:700">
            ${m.grammarFeedback}
          </div>
        ` : ''}
      </div>
    `).join('');

    const suggestionsHtml = (lastAi && lastAi.suggestions || []).map(sug => `
      <button class="word-chip" onclick="window.sendAiMessage('${sug.replace(/'/g, "\\'")}')">
        💡 ${sug}
      </button>
    `).join('');

    return `
      <div class="card">
        <div class="unit-title">Chọn Kịch bản Hội thoại Thực tế (Offline Roleplay)</div>
        <div class="chip-wrap">${scenarioChips}</div>
        <div style="font-size:13px;color:var(--text-muted);margin-top:6px">
          ${activeSc.roleDescription}
        </div>
        <div style="margin-top:10px">
          <span style="font-size:12px;font-weight:800">Từ vựng mục tiêu cần dùng trong hội thoại: </span>
          ${targetVocabBadges}
        </div>
      </div>

      <div class="card">
        <div class="chat-list" id="ai-chat-list">
          ${messagesHtml}
        </div>

        <div style="margin-bottom:10px">
          <div style="font-size:12px;font-weight:800;color:var(--text-muted);margin-bottom:6px">
            Gợi ý câu trả lời mẫu (Chạm để gửi nhanh):
          </div>
          <div class="chip-wrap">${suggestionsHtml}</div>
        </div>

        <div class="input-row">
          <input type="text" id="ai-chat-input" class="text-input" placeholder="Nhập câu tiếng Anh của bạn tại đây..." onkeydown="if(event.key==='Enter') window.submitAiInput()" />
          <button class="btn btn-primary" onclick="window.submitAiInput()">Gửi (+10 XP)</button>
        </div>
      </div>
    `;
  }

  // ==========================================================================
  // TAB 5: IPA PRONUNCIATION COACH
  // ==========================================================================
  function renderPronunciationTab() {
    const drill = CURRICULUM.pronunciationDrills[activeDrillIndex];
    const avgScore = Math.round(
      drill.words.reduce((acc, w) => acc + w.score, 0) / drill.words.length
    );

    const drillTabs = CURRICULUM.pronunciationDrills.map((d, idx) => `
      <button class="word-chip ${idx === activeDrillIndex ? 'selected' : ''}" onclick="window.selectPronunciationDrill(${idx})">
        Mẫu câu #${idx + 1} (${d.level})
      </button>
    `).join('');

    const wordCards = drill.words.map(w => {
      const cls = w.score >= 85 ? 'green' : (w.score >= 70 ? 'yellow' : 'red');
      return `
        <div class="phoneme-word ${cls}" onclick="window.speakText('${w.word.replace(/'/g, "\\'")}', 0.85)" style="cursor:pointer" title="Chạm để nghe phát âm từ này">
          <span style="font-weight:800;font-size:17px">${w.word}</span>
          <span class="ipa-text" style="font-size:12px">${w.ipa}</span>
          <span style="font-size:11px;font-weight:800;margin-top:2px">${w.score}%</span>
        </div>
      `;
    }).join('');

    const tipsList = drill.words.map(w => {
      const color = w.score >= 85 ? 'var(--success)' : (w.score >= 70 ? 'var(--warning)' : 'var(--error)');
      return `
        <div style="padding:8px 0;border-bottom:1px solid var(--border);font-size:14px">
          <strong style="color:${color}">${w.word}</strong>
          <span class="ipa-text">${w.ipa}</span> (${w.score}%): ${w.tip}
        </div>
      `;
    }).join('');

    return `
      <div class="card">
        <div class="unit-title">Luyện Phát Âm Chuẩn Quốc Tế IPA (Phoneme Coach)</div>
        <div class="unit-desc">Chạm vào từng từ để nghe phát âm riêng lẻ, hoặc thu âm cả câu để phân tích âm vị.</div>
        <div class="chip-wrap">${drillTabs}</div>
      </div>

      <div class="card">
        <div style="display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:8px;margin-bottom:14px">
          <span class="badge-tag">${drill.level}</span>
          <div style="display:flex;gap:8px">
            <button class="btn btn-outline" onclick="window.speakText('${drill.sentence.replace(/'/g, "\\'")}', 1.0)">
              🔊 Nghe tốc độ chuẩn (1.0x)
            </button>
            <button class="btn btn-outline" onclick="window.speakText('${drill.sentence.replace(/'/g, "\\'")}', 0.7)">
              🐢 Nghe tốc độ chậm (0.7x)
            </button>
          </div>
        </div>

        <div style="margin:12px 0">
          ${wordCards}
        </div>

        <div class="ipa-text" style="margin-top:10px;font-size:15px">${drill.fullIpa}</div>
        <div style="color:var(--text-muted);font-size:14px;margin-top:4px">🇻🇳 ${drill.vietnameseMeaning}</div>

        <div style="margin-top:20px;text-align:center">
          <button class="btn btn-primary" style="min-width:280px;padding:14px 20px" onclick="window.recordPronunciationDrill()">
            ${isRecordingDrill ? '🎙️ Đang lắng nghe & chấm điểm IPA...' : '🎤 Thu âm giọng đọc của bạn (+15 XP)'}
          </button>
        </div>
      </div>

      <div class="card">
        <div style="display:flex;align-items:center;gap:14px;margin-bottom:12px">
          <div style="width:52px;height:52px;border-radius:50%;background:rgba(16,185,129,0.15);color:var(--primary);display:flex;align-items:center;justify-content:center;font-weight:800;font-size:18px">
            ${avgScore}%
          </div>
          <div>
            <div class="unit-title" style="margin:0">Hướng dẫn Khẩu hình & Trọng âm Chi tiết</div>
            <div style="font-size:12px;color:var(--text-muted)">
              Xanh (>=85%): Phát âm chuẩn • Vàng (70-84%): Cần chú ý trọng âm • Đỏ (<70%): Âm câm / Phụ âm dễ sai
            </div>
          </div>
        </div>
        ${tipsList}
      </div>
    `;
  }

  // ==========================================================================
  // TAB 6: ANALYTICS & PROFILE
  // ==========================================================================
  function renderAnalyticsTab() {
    const level = Math.floor(state.xp / 100) + 1;
    const wcStats = state.wordChallengeStats;
    return `
      <div class="card">
        <div style="display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:12px">
          <div>
            <div class="unit-title">${state.userName} • Level ${level} (CEFR ${state.cefrLevel})</div>
            <div class="unit-desc">Mục tiêu: ${state.learningGoal} • Đã hoàn thành ${state.completedLessons.length} bài học</div>
          </div>
          <div style="display:flex;gap:8px">
            <button class="btn btn-outline" onclick="window.refillHearts()">❤️ Hồi phục 5 Tim</button>
            <button class="btn btn-outline" onclick="window.resetOfflineData()">🔄 Đặt lại dữ liệu Demo</button>
          </div>
        </div>
      </div>

      <div class="grid-3">
        <div class="card" style="margin-bottom:0;text-align:center">
          <div style="font-size:26px;font-weight:800;color:var(--streak)">🔥 ${state.streakDays} ngày</div>
          <div style="font-size:13px;font-weight:700">Chuỗi ngày học (Streak)</div>
        </div>
        <div class="card" style="margin-bottom:0;text-align:center">
          <div style="font-size:26px;font-weight:800;color:var(--xp)">🏆 ${wcStats.bestEndlessScore} điểm</div>
          <div style="font-size:13px;font-weight:700">Kỷ lục Đoán Từ Vô Tận</div>
        </div>
        <div class="card" style="margin-bottom:0;text-align:center">
          <div style="font-size:26px;font-weight:800;color:var(--primary)">📚 ${state.srsCards.length} từ</div>
          <div style="font-size:13px;font-weight:700">Kho từ vựng SRS Offline</div>
        </div>
      </div>

      <div class="card">
        <div class="unit-title">Phân tích 4 Kỹ năng Ngôn ngữ (AI Skill Radar)</div>
        <div style="margin-top:14px">
          ${renderSkillBar('Listening (Nghe hiểu & Chép chính tả)', 86, '#3B82F6')}
          ${renderSkillBar('Speaking & IPA (Phát âm & Trọng âm)', 81, '#10B981')}
          ${renderSkillBar('Active Recall & Spelling (Đoán từ ẩn & SRS)', 91, '#6366F1')}
          ${renderSkillBar('Grammar & Roleplay (Phản xạ hội thoại)', 79, '#F59E0B')}
        </div>
      </div>

      <div class="card">
        <div class="unit-title">Bảng xếp hạng Tuần (Emerald League)</div>
        <div class="lesson-item">
          <span>🥇 1. Hoàng Nam (Senior Dev)</span>
          <strong style="color:var(--primary)">${state.xp + 80} XP</strong>
        </div>
        <div class="lesson-item completed">
          <span>🥈 2. ${state.userName} (Bạn)</span>
          <strong style="color:var(--primary)">${state.xp} XP</strong>
        </div>
        <div class="lesson-item">
          <span>🥉 3. Thanh Thảo (Product Designer)</span>
          <strong style="color:var(--primary)">${Math.max(120, state.xp - 45)} XP</strong>
        </div>
      </div>
    `;
  }

  function renderSkillBar(label, pct, color) {
    return `
      <div style="margin-bottom:14px">
        <div style="display:flex;justify-content:space-between;font-size:14px;font-weight:700;margin-bottom:5px">
          <span>${label}</span>
          <span style="color:${color}">${pct}%</span>
        </div>
        <div style="height:9px;background:var(--surface-alt);border-radius:999px;overflow:hidden">
          <div style="width:${pct}%;height:100%;background:${color};border-radius:999px"></div>
        </div>
      </div>
    `;
  }

  // ==========================================================================
  // MODALS: STUDY GUIDE, INTERACTIVE QUIZ PLAYER, PLACEMENT TEST, ADD CARD
  // ==========================================================================
  function findLessonById(lessonId) {
    for (const u of CURRICULUM.units) {
      for (const l of u.lessons) {
        if (l.id === lessonId) return { unit: u, lesson: l };
      }
    }
    return null;
  }

  function renderModal() {
    const root = document.getElementById('modal-root');
    if (!activeModal) {
      root.innerHTML = '';
      return;
    }

    if (activeModal.type === 'study_guide') {
      const { unit, lesson } = findLessonById(activeModal.lessonId);
      const vocabHtml = (lesson.keyVocab || []).map(v => `
        <div class="lesson-item">
          <div>
            <div>
              <strong style="font-size:16px">${v.word}</strong>
              <span class="ipa-text" style="margin-left:8px">${v.ipa}</span>
            </div>
            <div style="font-weight:700;color:var(--primary);margin-top:2px">${v.meaning}</div>
            <div style="font-size:13px;color:var(--text-muted);font-style:italic">"${v.example}"</div>
          </div>
          <button class="icon-btn" onclick="window.speakText('${v.word.replace(/'/g, "\\'")}', 1.0)">🔊 Nghe</button>
        </div>
      `).join('');

      root.innerHTML = `
        <div class="modal-backdrop">
          <div class="modal-card">
            <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:12px">
              <span class="badge-tag">SỔ TAY LÝ THUYẾT • UNIT ${unit.unitNumber}</span>
              <button class="icon-btn" onclick="window.closeModal()">✕ Đóng</button>
            </div>
            <div class="unit-title">${lesson.title}</div>
            <div class="unit-desc">${lesson.subtitle}</div>

            <div style="padding:14px;border-radius:14px;background:rgba(99,102,241,0.1);border:1.5px solid var(--secondary);margin-bottom:16px">
              <div style="font-weight:800;color:var(--secondary);margin-bottom:4px">💡 Trọng tâm Ngữ pháp & Mẫu câu Giao tiếp:</div>
              <div style="font-size:14px">${lesson.grammarNote}</div>
            </div>

            <div style="font-weight:800;margin-bottom:10px">Từ vựng & Mẫu câu cốt lõi trong bài:</div>
            ${vocabHtml}

            <div style="margin-top:18px;display:flex;gap:10px">
              <button class="btn btn-outline" style="flex:1" onclick="window.closeModal()">Quay lại</button>
              <button class="btn btn-primary" style="flex:2" onclick="window.startLessonQuiz('${lesson.id}')">
                🎯 Bắt đầu làm 5 bài tập tương tác (+${lesson.xpReward} XP)
              </button>
            </div>
          </div>
        </div>
      `;
      return;
    }

    if (activeModal.type === 'quiz') {
      const { lesson } = findLessonById(activeModal.lessonId);
      const q = lesson.questions[activeModal.qIndex];
      const progressPct = Math.round(((activeModal.qIndex + 1) / lesson.questions.length) * 100);

      let bodyHtml = '';
      if (q.type === 'multiple_choice') {
        bodyHtml = q.options.map((opt, idx) => `
          <button class="option-btn ${activeModal.selectedOption === idx ? 'selected' : ''}"
                  ${activeModal.checked ? 'disabled' : ''}
                  onclick="window.selectQuizOption(${idx})">
            <span style="width:26px;height:26px;border-radius:50%;background:var(--surface-alt);display:inline-flex;align-items:center;justify-content:center;font-weight:800;font-size:12px">
              ${String.fromCharCode(65 + idx)}
            </span>
            <span>${opt}</span>
          </button>
        `).join('');
      } else if (q.type === 'fill_blank') {
        const displaySentence = q.sentence.replace(
          '_____',
          activeModal.selectedWord ? `<strong style="color:var(--primary)">[${activeModal.selectedWord}]</strong>` : '_____'
        );
        const chips = q.wordBank.map(w => `
          <button class="word-chip ${activeModal.selectedWord === w ? 'selected' : ''}"
                  ${activeModal.checked ? 'disabled' : ''}
                  onclick="window.selectQuizBlank('${w}')">
            ${w}
          </button>
        `).join('');
        bodyHtml = `
          <div style="padding:18px;border:1.5px solid var(--border);border-radius:14px;font-size:18px;font-weight:700;margin-bottom:14px">
            ${displaySentence}
          </div>
          <div class="chip-wrap">${chips}</div>
        `;
      } else if (q.type === 'sentence_order') {
        const chosenChips = activeModal.orderedTokens.map((t, i) => `
          <button class="word-chip selected" ${activeModal.checked ? 'disabled' : ''} onclick="window.removeOrderedToken(${i})">${t}</button>
        `).join('');
        const bankChips = q.shuffledTokens.map(t => {
          const used = activeModal.orderedTokens.includes(t);
          return `
            <button class="word-chip" ${used || activeModal.checked ? 'disabled style="opacity:0.35"' : ''} onclick="window.addOrderedToken('${t.replace(/'/g, "\\'")}')">
              ${t}
            </button>
          `;
        }).join('');
        bodyHtml = `
          <div style="padding:12px;border-radius:12px;background:rgba(99,102,241,0.1);font-weight:700;margin-bottom:12px">
            🇻🇳 Nghĩa tiếng Việt: "${q.vietnameseMeaning}"
          </div>
          <div style="min-height:64px;padding:12px;border:1.8px dashed var(--primary);border-radius:14px;margin-bottom:12px">
            ${chosenChips || '<span style="color:var(--text-muted)">Chạm vào các từ bên dưới để ghép thành câu hoàn chỉnh...</span>'}
          </div>
          <div class="chip-wrap">${bankChips}</div>
        `;
      } else if (q.type === 'listening') {
        bodyHtml = `
          <div style="text-align:center;margin:14px 0">
            <button class="btn btn-primary" onclick="window.speakText('${q.audioText.replace(/'/g, "\\'")}', 1.0)">
              🔊 Nghe câu phát âm (Tốc độ chuẩn)
            </button>
            <button class="btn btn-outline" style="margin-left:8px" onclick="window.speakText('${q.audioText.replace(/'/g, "\\'")}', 0.72)">
              🐢 Nghe chậm
            </button>
            <div class="ipa-text" style="margin-top:10px;font-size:14px">Gợi ý IPA: ${q.ipaHint}</div>
          </div>
          <input type="text" id="quiz-dictation-input" class="text-input" style="width:100%"
                 value="${activeModal.dictationText || ''}"
                 ${activeModal.checked ? 'disabled' : ''}
                 placeholder="Nhập lại câu tiếng Anh bạn nghe được..."
                 oninput="window.updateDictationInput(this.value)" />
        `;
      } else if (q.type === 'speaking') {
        bodyHtml = `
          <div style="padding:16px;border:1.5px solid var(--border);border-radius:16px;margin-bottom:16px">
            <div style="display:flex;justify-content:space-between;align-items:center">
              <strong style="font-size:18px">${q.targetSentence}</strong>
              <button class="icon-btn" onclick="window.speakText('${q.targetSentence.replace(/'/g, "\\'")}', 1.0)">🔊 Nghe mẫu</button>
            </div>
            <div class="ipa-text" style="margin-top:6px">${q.ipaTranscription}</div>
            <div style="font-size:14px;color:var(--text-muted);margin-top:4px">🇻🇳 ${q.vietnameseTranslation}</div>
          </div>
          <div style="text-align:center;margin:18px 0">
            <button class="btn ${activeModal.speechRecorded ? 'btn-secondary' : 'btn-primary'}"
                    ${activeModal.checked ? 'disabled' : ''}
                    onclick="window.simulateQuizSpeechRecording()">
              ${activeModal.speechRecorded ? '✓ Đã thu âm giọng đọc (Độ khớp IPA: 95%)' : '🎤 Chạm để thu âm câu tiếng Anh trên'}
            </button>
          </div>
        `;
      }

      const feedbackHtml = activeModal.checked ? `
        <div class="feedback-box ${activeModal.isCorrect ? 'correct' : 'incorrect'}">
          <div style="font-weight:800;font-size:16px;margin-bottom:4px">
            ${activeModal.isCorrect ? '✅ Chính xác! Xuất sắc!' : '❌ Chưa chính xác'}
          </div>
          <div style="font-size:14px">${q.explanation}</div>
        </div>
      ` : '';

      root.innerHTML = `
        <div class="modal-backdrop">
          <div class="modal-card">
            <div style="display:flex;justify-content:space-between;align-items:center;gap:12px;margin-bottom:14px">
              <span style="font-weight:800;font-size:13px;color:var(--primary)">
                ${lesson.title} • Câu ${activeModal.qIndex + 1}/${lesson.questions.length}
              </span>
              <span style="font-weight:800;color:var(--heart)">❤️ ${state.hearts}</span>
              <button class="icon-btn" onclick="window.closeModal()">✕ Thoát</button>
            </div>
            <div style="height:8px;background:var(--surface-alt);border-radius:999px;overflow:hidden;margin-bottom:18px">
              <div style="width:${progressPct}%;height:100%;background:var(--primary)"></div>
            </div>

            <div style="font-size:18px;font-weight:800;margin-bottom:16px">${q.prompt}</div>
            ${bodyHtml}
            ${feedbackHtml}

            <div style="margin-top:18px">
              ${!activeModal.checked ? `
                <button class="btn btn-primary btn-block" onclick="window.checkQuizAnswer()">
                  Kiểm tra đáp án
                </button>
              ` : `
                <button class="btn btn-primary btn-block" onclick="window.nextQuizQuestion()">
                  ${activeModal.qIndex === lesson.questions.length - 1
                    ? '🎉 Hoàn tất bài học & Nhận +' + lesson.xpReward + ' XP'
                    : 'Câu tiếp theo →'}
                </button>
              `}
            </div>
          </div>
        </div>
      `;
      return;
    }

    if (activeModal.type === 'placement') {
      const q = CURRICULUM.placementQuestions[activeModal.qIndex];
      const optionsHtml = q.options.map((opt, idx) => `
        <button class="option-btn ${activeModal.selectedOption === idx ? 'selected' : ''}"
                onclick="window.selectPlacementOption(${idx})">
          <strong>${String.fromCharCode(65 + idx)}.</strong>
          <span>${opt}</span>
        </button>
      `).join('');

      root.innerHTML = `
        <div class="modal-backdrop">
          <div class="modal-card">
            <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:12px">
              <span class="badge-tag">PLACEMENT TEST • Câu ${activeModal.qIndex + 1}/${CURRICULUM.placementQuestions.length} (Mức ${q.level})</span>
              <button class="icon-btn" onclick="window.closeModal()">✕ Đóng</button>
            </div>
            <div style="font-size:18px;font-weight:800;white-space:pre-line;margin-bottom:16px">${q.question}</div>
            ${optionsHtml}
            <button class="btn btn-primary btn-block" style="margin-top:12px"
                    ${activeModal.selectedOption === null ? 'disabled' : ''}
                    onclick="window.nextPlacementQuestion()">
              ${activeModal.qIndex === CURRICULUM.placementQuestions.length - 1 ? 'Hoàn tất & Xếp trình độ CEFR' : 'Câu tiếp theo →'}
            </button>
          </div>
        </div>
      `;
      return;
    }

    if (activeModal.type === 'add_card') {
      root.innerHTML = `
        <div class="modal-backdrop">
          <div class="modal-card">
            <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:14px">
              <div class="unit-title" style="margin:0">Thêm Thẻ Từ Vựng SRS Offline Mới</div>
              <button class="icon-btn" onclick="window.closeModal()">✕ Đóng</button>
            </div>
            <div style="display:flex;flex-direction:column;gap:12px">
              <input id="new-card-word" class="text-input" placeholder="Từ vựng tiếng Anh (VD: Accomplish) *" />
              <input id="new-card-ipa" class="text-input" placeholder="Phiên âm IPA (VD: /əˈkʌmplɪʃ/)" />
              <input id="new-card-meaning" class="text-input" placeholder="Nghĩa tiếng Việt (VD: Hoàn thành xuất sắc) *" />
              <input id="new-card-grammar" class="text-input" placeholder="Ghi chú ngữ pháp / cách dùng (tùy chọn)..." />
              <input id="new-card-example" class="text-input" placeholder="Câu ví dụ tiếng Anh..." />
              <button class="btn btn-primary btn-block" onclick="window.saveCustomCard()">
                💾 Lưu vào Kho từ vựng & Đấu Trường Đoán Từ
              </button>
            </div>
          </div>
        </div>
      `;
    }
  }

  // ==========================================================================
  // GLOBAL EVENT HANDLERS
  // ==========================================================================
  window.switchTab = function (tab) {
    if (tab !== 'word_challenge') {
      stopWcTimer();
    }
    currentTab = tab;
    render();
  };

  window.toggleTheme = function () {
    state.darkMode = !state.darkMode;
    saveState();
    render();
  };

  window.closeModal = function () {
    activeModal = null;
    render();
  };

  window.openStudyGuide = function (lessonId) {
    activeModal = { type: 'study_guide', lessonId };
    render();
  };

  window.startLessonQuiz = function (lessonId) {
    activeModal = {
      type: 'quiz',
      lessonId,
      qIndex: 0,
      correctCount: 0,
      selectedOption: null,
      selectedWord: null,
      orderedTokens: [],
      dictationText: '',
      speechRecorded: false,
      checked: false,
      isCorrect: false
    };
    render();
  };

  window.selectQuizOption = function (idx) {
    activeModal.selectedOption = idx;
    render();
  };

  window.selectQuizBlank = function (word) {
    activeModal.selectedWord = word;
    render();
  };

  window.addOrderedToken = function (token) {
    activeModal.orderedTokens.push(token);
    render();
  };

  window.removeOrderedToken = function (idx) {
    activeModal.orderedTokens.splice(idx, 1);
    render();
  };

  window.updateDictationInput = function (val) {
    activeModal.dictationText = val;
  };

  window.simulateQuizSpeechRecording = function () {
    const { lesson } = findLessonById(activeModal.lessonId);
    const q = lesson.questions[activeModal.qIndex];
    window.speakText(q.targetSentence, 1.0);
    activeModal.speechRecorded = true;
    render();
  };

  function normalizeStr(s) {
    return (s || '').trim().toLowerCase().replace(/[^\w\s]/g, '').replace(/\s+/g, ' ');
  }

  window.checkQuizAnswer = function () {
    const { lesson } = findLessonById(activeModal.lessonId);
    const q = lesson.questions[activeModal.qIndex];
    let correct = false;

    if (q.type === 'multiple_choice') {
      if (activeModal.selectedOption === null) return;
      correct = activeModal.selectedOption === q.correctIndex;
    } else if (q.type === 'fill_blank') {
      if (!activeModal.selectedWord) return;
      correct = activeModal.selectedWord.toLowerCase() === q.correctAnswer.toLowerCase();
    } else if (q.type === 'sentence_order') {
      if (activeModal.orderedTokens.length === 0) return;
      correct = activeModal.orderedTokens.join(' ') === q.correctOrder.join(' ');
    } else if (q.type === 'listening') {
      if (!activeModal.dictationText.trim()) return;
      correct = normalizeStr(activeModal.dictationText) === normalizeStr(q.audioText);
    } else if (q.type === 'speaking') {
      correct = true;
    }

    activeModal.checked = true;
    activeModal.isCorrect = correct;
    if (correct) {
      activeModal.correctCount++;
    } else if (state.hearts > 0) {
      state.hearts--;
      saveState();
    }
    render();
  };

  window.nextQuizQuestion = function () {
    const { lesson } = findLessonById(activeModal.lessonId);
    if (activeModal.qIndex < lesson.questions.length - 1) {
      activeModal.qIndex++;
      activeModal.selectedOption = null;
      activeModal.selectedWord = null;
      activeModal.orderedTokens = [];
      activeModal.dictationText = '';
      activeModal.speechRecorded = false;
      activeModal.checked = false;
      activeModal.isCorrect = false;
      render();
    } else {
      if (!state.completedLessons.includes(lesson.id)) {
        state.completedLessons.push(lesson.id);
      }
      addXp(lesson.xpReward);
      activeModal = null;
      render();
    }
  };

  // SRS Actions
  window.setSrsTopic = function (topic) {
    srsTopicFilter = topic;
    srsActiveIndex = 0;
    srsCardRevealed = false;
    render();
  };

  window.revealSrsCard = function () {
    srsCardRevealed = true;
    render();
  };

  window.togglePracticeAllSrs = function () {
    srsPracticeAllMode = true;
    srsActiveIndex = 0;
    srsCardRevealed = false;
    render();
  };

  window.gradeSrsCard = function (cardId, grade) {
    const card = state.srsCards.find(c => c.id === cardId);
    if (card) {
      if (grade === 'again') {
        card.repetition = 0;
        card.intervalDays = 1;
        card.easeFactor = Math.max(1.3, Number(((card.easeFactor || 2.5) - 0.2).toFixed(2)));
        card.nextReviewTime = Date.now() + 60 * 1000;
      } else {
        card.repetition = (card.repetition || 0) + 1;
        const mult = grade === 'hard' ? 2 : (grade === 'good' ? 4 : 7);
        card.intervalDays = mult;
        const delta = grade === 'hard' ? -0.15 : (grade === 'easy' ? 0.15 : 0);
        card.easeFactor = Math.max(1.3, Number(((card.easeFactor || 2.5) + delta).toFixed(2)));
        card.nextReviewTime = Date.now() + mult * 86400 * 1000;
      }
      addXp(5);
    }
    srsCardRevealed = false;
    srsActiveIndex++;
    render();
  };

  window.openAddCardModal = function () {
    activeModal = { type: 'add_card' };
    render();
  };

  window.saveCustomCard = function () {
    const word = document.getElementById('new-card-word').value.trim();
    const ipa = document.getElementById('new-card-ipa').value.trim();
    const meaning = document.getElementById('new-card-meaning').value.trim();
    const grammar = document.getElementById('new-card-grammar').value.trim();
    const example = document.getElementById('new-card-example').value.trim();
    if (!word || !meaning) return;

    state.srsCards.unshift({
      id: 'custom_' + Date.now(),
      word,
      ipa: ipa || '/' + word.toLowerCase() + '/',
      cefr: state.cefrLevel || 'B1',
      partOfSpeech: 'Personal Deck',
      topic: 'Từ vựng Cá nhân',
      vietnameseMeaning: meaning,
      grammarNote: grammar || 'Từ vựng cá nhân bạn tự lưu để luyện phản xạ.',
      usageTip: 'Hãy chú ý cách dùng từ này trong câu ví dụ thực tế.',
      collocations: [word],
      wordFamily: word,
      synonyms: [],
      antonyms: [],
      exampleSentence: example || 'This is a practical example sentence with ' + word + '.',
      repetition: 0,
      easeFactor: 2.5,
      intervalDays: 0,
      nextReviewTime: Date.now() - 1000
    });
    saveState();
    activeModal = null;
    render();
  };

  // AI Tutor Actions
  window.selectAiScenario = function (scenarioId) {
    initAiScenario(scenarioId);
    render();
  };

  function analyzeOfflineGrammar(text, scenario) {
    const lower = text.toLowerCase();
    if (lower.includes('i work on') && lower.includes('yesterday')) {
      return '💡 Sửa lỗi ngữ pháp: Với "yesterday", hãy chia thì quá khứ đơn: "I worked on...".';
    }
    if (lower.includes('discuss about')) {
      return '💡 Sửa lỗi ngữ pháp: "Discuss" không đi kèm "about" (chỉ dùng "discuss something").';
    }
    if (lower.includes('more better')) {
      return '💡 Sửa lỗi ngữ pháp: Dùng "much better" thay vì "more better".';
    }
    const usedVocab = scenario.targetVocabulary.filter(w => lower.includes(w.toLowerCase()));
    if (usedVocab.length > 0) {
      return '🌟 Xuất sắc! Bạn đã áp dụng từ vựng mục tiêu "' + usedVocab.join(', ') + '" rất tự nhiên và đúng ngữ cảnh!';
    }
    return '✅ Câu đúng ngữ pháp và truyền đạt rõ ý!';
  }

  window.sendAiMessage = function (text) {
    const trimmed = (text || '').trim();
    if (!trimmed) return;
    const sc = CURRICULUM.aiScenarios.find(s => s.id === activeScenarioId) || CURRICULUM.aiScenarios[0];
    const feedback = analyzeOfflineGrammar(trimmed, sc);

    aiChatHistory.push({
      isUser: true,
      text: trimmed,
      grammarFeedback: feedback
    });

    const nextTurn = sc.turns[aiTurnCounter % sc.turns.length];
    aiTurnCounter++;

    aiChatHistory.push({
      isUser: false,
      text: nextTurn.reply,
      translation: nextTurn.translation,
      suggestions: nextTurn.suggestions
    });

    addXp(10);
    render();
    const listEl = document.getElementById('ai-chat-list');
    if (listEl) listEl.scrollTop = listEl.scrollHeight;
  };

  window.submitAiInput = function () {
    const input = document.getElementById('ai-chat-input');
    if (!input || !input.value.trim()) return;
    window.sendAiMessage(input.value);
  };

  // Pronunciation Actions
  window.selectPronunciationDrill = function (idx) {
    activeDrillIndex = idx;
    render();
  };

  window.recordPronunciationDrill = function () {
    if (isRecordingDrill) return;
    isRecordingDrill = true;
    render();

    setTimeout(() => {
      const drill = CURRICULUM.pronunciationDrills[activeDrillIndex];
      drill.words.forEach(w => {
        w.score = Math.min(99, w.score + 3);
      });
      isRecordingDrill = false;
      addXp(15);
      render();
    }, 1100);
  };

  // Placement Test Actions
  window.openPlacementModal = function () {
    activeModal = {
      type: 'placement',
      qIndex: 0,
      score: 0,
      selectedOption: null
    };
    render();
  };

  window.selectPlacementOption = function (idx) {
    activeModal.selectedOption = idx;
    render();
  };

  window.nextPlacementQuestion = function () {
    const q = CURRICULUM.placementQuestions[activeModal.qIndex];
    if (activeModal.selectedOption === q.correctIndex) {
      activeModal.score++;
    }
    if (activeModal.qIndex < CURRICULUM.placementQuestions.length - 1) {
      activeModal.qIndex++;
      activeModal.selectedOption = null;
      render();
    } else {
      const levels = ['A1', 'A2', 'B1', 'B2', 'C1'];
      state.cefrLevel = levels[Math.min(levels.length - 1, activeModal.score)];
      state.wordChallengeStats.selectedTier =
        (state.cefrLevel === 'A1' || state.cefrLevel === 'A2') ? 'A1-A2'
        : (state.cefrLevel === 'C1' ? 'C1-C2' : 'B1-B2');
      saveState();
      activeModal = null;
      render();
    }
  };

  window.refillHearts = function () {
    state.hearts = 5;
    saveState();
    render();
  };

  window.resetOfflineData = function () {
    stopWcTimer();
    wcSession = null;
    localStorage.removeItem(STORAGE_KEY);
    state = loadState();
    render();
  };

  // Global Enter shortcut on Word Challenge feedback screen to move fast
  document.addEventListener('keydown', function (e) {
    if (
      e.key === 'Enter' &&
      currentTab === 'word_challenge' &&
      wcSession &&
      wcSession.phase === 'feedback' &&
      document.activeElement.tagName !== 'INPUT'
    ) {
      e.preventDefault();
      window.nextWcStep();
    }
  });

  // Initial mount
  document.addEventListener('DOMContentLoaded', render);
})();
