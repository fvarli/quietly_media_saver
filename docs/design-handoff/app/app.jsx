// App controller: state machine + premium phone frame + states explorer.

const { useState: uS, useEffect: uE, useRef: uR, useCallback } = React;

const QUALITY_OPTIONS = [
  { id: '1080p', label: '1080p', tag: 'High · landscape', size: '24 MB', rec: true },
  { id: '720p', label: '720p', tag: 'Standard', size: '14 MB' },
  { id: '480p', label: '480p', tag: 'Data saver', size: '7 MB' },
  { id: 'audio', label: 'Audio only', tag: 'M4A', size: '2 MB' },
];

const SEED_HISTORY = [
  { kind: 'video', title: 'Video clip', meta: '1080p · 24 MB', time: '2:14 PM', g: 'Today' },
  { kind: 'image', title: '3 images', meta: 'JPG · 4.1 MB', time: '11:02 AM', g: 'Today' },
  { kind: 'image', title: 'Image', meta: 'PNG · 0.9 MB', time: '8:40 PM', g: 'Yesterday' },
  { kind: 'video', title: 'Video clip', meta: '720p · 12 MB', time: '6:15 PM', g: 'Yesterday' },
  { kind: 'image', title: 'Image', meta: 'JPG · 1.4 MB', time: 'Mon', g: 'Earlier' },
  { kind: 'video', title: 'Video clip', meta: '1080p · 30 MB', time: 'Sun', g: 'Earlier' },
];

const SEED_CAROUSEL = [
  { kind: 'image', mb: 1.4, sel: true },
  { kind: 'image', mb: 1.3, sel: true },
  { kind: 'video', mb: 9.0, dur: '18', sel: false },
  { kind: 'image', mb: 1.5, sel: true },
  { kind: 'image', mb: 1.2, sel: false },
  { kind: 'video', mb: 7.5, dur: '12', sel: false },
];

function App() {
  const c = DS.color;
  const [screen, setScreen] = uS('home');
  const [sheet, setSheet] = uS(null);
  const [error, setError] = uS('protected');
  const [quality, setQ] = uS('1080p');
  const [progress, setProgress] = uS(0);
  const [queue, setQueue] = uS([]);
  const [permission, setPermission] = uS(false);
  const [history, setHistory] = uS(SEED_HISTORY);
  const [carousel, setCarousel] = uS(SEED_CAROUSEL);
  const [toggles, setToggles] = uS({ ask: false, wifi: true, notify: true });
  const [lastSaved, setLastSaved] = uS(['video']);
  const [scale, setScale] = uS(1);
  const [menuOpen, setMenuOpen] = uS(false);

  const dlKinds = uR(['video']);
  const pendingSave = uR(['video']);

  // responsive scale of phone frame
  uE(() => {
    const fit = () => {
      const s = Math.min((window.innerWidth - 40) / 384, (window.innerHeight - 40) / 832, 1.12);
      setScale(Math.max(0.5, s));
    };
    fit();
    window.addEventListener('resize', fit);
    return () => window.removeEventListener('resize', fit);
  }, []);

  // download animation
  uE(() => {
    if (screen !== 'downloading') return;
    const single = dlKinds.current.length <= 1;
    const id = setInterval(() => {
      if (single) {
        setProgress((p) => {
          const np = Math.min(100, p + 4 + Math.random() * 9);
          if (np >= 100) { clearInterval(id); setTimeout(finishDownload, 480); }
          return np;
        });
      } else {
        setQueue((q) => {
          let all = true;
          const nq = q.map((j) => {
            const np = Math.min(100, j.pct + Math.random() * 13);
            if (np < 100) all = false;
            return { ...j, pct: Math.round(np) };
          });
          if (all) { clearInterval(id); setTimeout(finishDownload, 540); }
          return nq;
        });
      }
    }, 160);
    return () => clearInterval(id);
    // eslint-disable-next-line
  }, [screen]);

  function finishDownload() {
    const kinds = dlKinds.current;
    const now = kinds.length > 1
      ? [{ kind: kinds.includes('video') ? 'video' : 'image', title: `${kinds.length} items`, meta: 'Mixed · saved', time: 'Just now', g: 'Today' }]
      : [{ kind: kinds[0] || 'video', title: kinds[0] === 'image' ? 'Image' : 'Video clip', meta: `${quality} · saved`, time: 'Just now', g: 'Today' }];
    setHistory((h) => [...now, ...h]);
    setScreen('success');
  }

  const app = {
    history, carousel, quality, progress: Math.round(progress), queue, toggles, lastSaved, error,
    qualityOptions: QUALITY_OPTIONS,
    qualityMeta: () => QUALITY_OPTIONS.find((o) => o.id === quality) || QUALITY_OPTIONS[0],
    go: (s) => { setSheet(null); setMenuOpen(false); setScreen(s); },
    paste: () => { setSheet(null); setScreen('analyzing'); },
    onAnalyzed: () => setScreen('result'),
    openSheet: (n) => setSheet(n),
    closeSheet: () => setSheet(null),
    setQuality: (id) => setQ(id),
    toggleItem: (i) => setCarousel((cs) => cs.map((it, j) => j === i ? { ...it, sel: !it.sel } : it)),
    toggleAll: () => setCarousel((cs) => { const all = cs.every((i) => i.sel); return cs.map((i) => ({ ...i, sel: !all })); }),
    toggle: (k) => setToggles((t) => ({ ...t, [k]: !t[k] })),
    requestSave: (kinds) => {
      setLastSaved(kinds);
      pendingSave.current = kinds;
      if (!permission) { setSheet('permission'); return; }
      startDownload(kinds);
    },
    grantPermission: () => { setPermission(true); setSheet(null); startDownload(pendingSave.current); },
    startDownload,
    showError: (e) => { setError(e); setSheet(null); setScreen('error'); },
    historyGroups: () => {
      const order = ['Today', 'Yesterday', 'Earlier'];
      return order.map((g) => [g, history.filter((h) => h.g === g)]).filter(([, r]) => r.length);
    },
  };

  function startDownload(kinds) {
    dlKinds.current = kinds;
    setLastSaved(kinds);
    if (kinds.length > 1) {
      setQueue(kinds.map((k, i) => ({ kind: k, name: k === 'video' ? `clip_${i + 1}.mp4` : `image_${i + 1}.jpg`, meta: k === 'video' ? 'MP4 · 1080p' : 'JPG · 1440px', pct: 0 })));
    } else {
      setProgress(0);
    }
    setSheet(null);
    setScreen('downloading');
  }

  // render active screen
  function renderScreen() {
    switch (screen) {
      case 'home': return <HomeScreen app={app} />;
      case 'analyzing': return <AnalyzingScreen app={app} />;
      case 'result': return <ResultScreen app={app} />;
      case 'carousel': return <CarouselScreen app={app} />;
      case 'downloading': return <DownloadScreen app={app} />;
      case 'success': return <SuccessScreen app={app} />;
      case 'history': return <HistoryScreen app={app} />;
      case 'settings': return <SettingsScreen app={app} />;
      case 'error': return <ErrorScreen app={app} />;
      default: return <HomeScreen app={app} />;
    }
  }

  return (
    <div style={{ position: 'fixed', inset: 0, background: 'radial-gradient(120% 90% at 50% 0%, #efece6 0%, #e7e3db 60%, #e0dbd2 100%)', display: 'flex', alignItems: 'center', justifyContent: 'center', overflow: 'hidden', fontFamily: DS.font.sans }}>
      {/* brand tag */}
      <div style={{ position: 'fixed', top: 22, left: 24, display: 'flex', alignItems: 'center', gap: 9, zIndex: 5 }}>
        <div style={{ width: 30, height: 30, borderRadius: 9, background: c.accent, display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Icon name="download" size={17} color="#fff" stroke={2.2} /></div>
        <div>
          <div style={{ fontSize: 13.5, fontWeight: 700, color: c.ink, letterSpacing: -0.2, lineHeight: 1 }}>Quietly</div>
          <div style={{ fontSize: 10.5, color: c.faint, marginTop: 2 }}>Hi-fi prototype · hybrid A</div>
        </div>
      </div>

      {/* phone */}
      <div style={{ transform: `scale(${scale})`, transformOrigin: 'center center', transition: 'transform .2s ease' }}>
        <PhoneFrame>
          <div key={screen} style={{ flex: 1, minHeight: 0, position: 'relative', display: 'flex', flexDirection: 'column', overflow: 'hidden' }}>
            {renderScreen()}
            {sheet === 'quality' && <QualitySheet app={app} />}
            {sheet === 'permission' && <PermissionSheet app={app} />}
          </div>
        </PhoneFrame>
      </div>

      <StatesMenu app={app} screen={screen} sheet={sheet} open={menuOpen} setOpen={setMenuOpen} />
    </div>
  );
}

// ── Premium phone frame ──────────────────────────────────────
function PhoneFrame({ children }) {
  const c = DS.color;
  return (
    <div style={{ width: 384, height: 832, borderRadius: 46, background: '#15151a', padding: 11, boxShadow: '0 40px 90px rgba(40,32,20,0.28), 0 12px 30px rgba(40,32,20,0.18), inset 0 0 0 1px rgba(255,255,255,0.06)' }}>
      <div style={{ width: '100%', height: '100%', borderRadius: 36, background: c.bg, overflow: 'hidden', display: 'flex', flexDirection: 'column', position: 'relative' }}>
        <StatusBar dark={false} time="9:41" />
        {children}
        <HomeBar dark={false} />
      </div>
    </div>
  );
}

// ── States explorer (review affordance + dev nav) ────────────
function StatesMenu({ app, screen, sheet, open, setOpen }) {
  const c = DS.color;
  const groups = [
    { g: 'Core flow', items: [
      ['Home', () => app.go('home'), screen === 'home'],
      ['Analyzing', () => app.go('analyzing'), screen === 'analyzing'],
      ['Result · video', () => app.go('result'), screen === 'result' && !sheet],
      ['Carousel select', () => app.go('carousel'), screen === 'carousel'],
      ['Downloading', () => app.startDownload(['video']), screen === 'downloading'],
      ['Saved · success', () => { app.go('success'); }, screen === 'success'],
    ] },
    { g: 'Sheets', items: [
      ['Quality picker', () => { app.go('result'); setTimeout(() => app.openSheet('quality'), 30); }, sheet === 'quality'],
      ['Multi-download queue', () => app.startDownload(['image', 'image', 'video']), screen === 'downloading' && app.queue.length > 1],
      ['Permission request', () => { app.go('result'); setTimeout(() => app.openSheet('permission'), 30); }, sheet === 'permission'],
    ] },
    { g: 'Library', items: [
      ['History', () => app.go('history'), screen === 'history'],
      ['Settings & legal', () => app.go('settings'), screen === 'settings'],
    ] },
    { g: 'Edge & error states', items: [
      ['Protected / private', () => app.showError('protected'), screen === 'error' && app.error === 'protected'],
      ['Invalid URL', () => app.showError('invalid'), screen === 'error' && app.error === 'invalid'],
      ['Network failure', () => app.showError('network'), screen === 'error' && app.error === 'network'],
      ['Unsupported source', () => app.showError('unsupported'), screen === 'error' && app.error === 'unsupported'],
      ['Storage full', () => app.showError('storage'), screen === 'error' && app.error === 'storage'],
      ['Already saved', () => app.showError('exists'), screen === 'error' && app.error === 'exists'],
    ] },
  ];
  return (
    <React.Fragment>
      <button className="ds-press" onClick={() => setOpen((o) => !o)} style={{ position: 'fixed', top: 22, right: 24, zIndex: 30, height: 40, padding: '0 16px', borderRadius: 20, border: 'none', background: c.ink, color: '#fff', fontSize: 13, fontWeight: 650, fontFamily: DS.font.sans, display: 'flex', alignItems: 'center', gap: 8, cursor: 'pointer', boxShadow: '0 6px 18px rgba(33,29,24,0.25)' }}>
        <Icon name={open ? 'x' : 'list'} size={17} color="#fff" stroke={2} />{open ? 'Close' : 'All states'}
      </button>
      <div style={{ position: 'fixed', top: 0, right: 0, bottom: 0, width: 286, background: '#fffdfa', borderLeft: `1px solid ${c.hair}`, boxShadow: open ? '-16px 0 50px rgba(40,32,20,0.16)' : 'none', transform: open ? 'none' : 'translateX(100%)', transition: `transform .36s ${DS.motion.ease}`, zIndex: 25, display: 'flex', flexDirection: 'column', fontFamily: DS.font.sans }}>
        <div style={{ padding: '70px 22px 14px', borderBottom: `1px solid ${c.hair}` }}>
          <div style={{ fontSize: 17, fontWeight: 750, color: c.ink, letterSpacing: -0.3 }}>Explore states</div>
          <div style={{ fontSize: 12.5, color: c.sub, marginTop: 4, lineHeight: 1.45 }}>Jump to any screen or edge case. The core flow is also fully clickable from Home.</div>
        </div>
        <div className="ds-noscroll" style={{ flex: 1, overflowY: 'auto', padding: '14px 14px 24px' }}>
          {groups.map((grp, gi) => (
            <div key={gi} style={{ marginBottom: 16 }}>
              <div style={{ fontSize: 11, fontWeight: 700, letterSpacing: 0.6, textTransform: 'uppercase', color: c.faint, padding: '0 8px 7px' }}>{grp.g}</div>
              <div style={{ display: 'flex', flexDirection: 'column', gap: 3 }}>
                {grp.items.map(([label, fn, active], i) => (
                  <button key={i} className="ds-press" onClick={fn} style={{ display: 'flex', alignItems: 'center', gap: 9, padding: '9px 10px', borderRadius: 10, border: 'none', background: active ? c.accentSoft : 'transparent', color: active ? c.accentInk : c.ink, fontSize: 13.5, fontWeight: active ? 650 : 500, fontFamily: DS.font.sans, cursor: 'pointer', textAlign: 'left', width: '100%' }}>
                    <span style={{ width: 6, height: 6, borderRadius: 3, background: active ? c.accent : c.hair, flexShrink: 0 }} />
                    {label}
                  </button>
                ))}
              </div>
            </div>
          ))}
        </div>
        <div style={{ padding: '12px 22px', borderTop: `1px solid ${c.hair}`, fontSize: 11, color: c.faint }}>
          <a href="design-system.html" style={{ color: c.accent, fontWeight: 600, textDecoration: 'none' }}>View design system →</a>
        </div>
      </div>
    </React.Fragment>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<App />);
