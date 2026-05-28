// Core flow screens. Each is a function component receiving `app` (controller).
// Presentational + light local animation state. Uses window.DS primitives.

const { useState, useEffect, useRef } = React;

// Small helper: app header used on Home
function AppHeader({ app }) {
  const c = DS.color;
  return (
    <div style={{ height: 56, flexShrink: 0, display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '0 18px' }}>
      <span style={{ fontSize: 20, fontWeight: 800, letterSpacing: -0.5, color: c.ink }}>Quietly</span>
      <div style={{ display: 'flex', gap: 6 }}>
        <button className="ds-press" onClick={() => app.go('history')} style={iconBtn(c)}><Icon name="clock" size={20} color={c.sub} /></button>
        <button className="ds-press" onClick={() => app.go('settings')} style={iconBtn(c)}><Icon name="settings" size={20} color={c.sub} /></button>
      </div>
    </div>
  );
}
function iconBtn(c) { return { width: 40, height: 40, borderRadius: 20, border: 'none', background: c.surface, boxShadow: DS.shadow.sm, display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer' }; }

// ── HOME ─────────────────────────────────────────────────────
function HomeScreen({ app }) {
  const c = DS.color;
  return (
    <div className="ds-screen" style={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
      <AppHeader app={app} />
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center', padding: '0 22px 8px' }}>
        <div style={{ width: 54, height: 54, borderRadius: 17, background: c.accentSoft, display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: 20 }}>
          <Icon name="link" size={25} color={c.accent} />
        </div>
        <div style={{ fontSize: 28, fontWeight: 700, letterSpacing: -0.7, color: c.ink, lineHeight: 1.12 }}>Paste a link<br />to get started.</div>
        <div style={{ fontSize: 14.5, color: c.sub, marginTop: 11, lineHeight: 1.5, maxWidth: 280 }}>We’ll check what media is publicly available for you to save.</div>

        {/* clipboard-detected */}
        <div className="ds-press" onClick={() => app.paste('clip')} style={{ marginTop: 24, background: c.surface, border: `1px solid ${c.hair}`, borderRadius: DS.radius.lg, padding: '13px 14px', display: 'flex', alignItems: 'center', gap: 12, boxShadow: DS.shadow.sm, cursor: 'pointer' }}>
          <div style={{ width: 36, height: 36, borderRadius: 11, background: c.accentSoft, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}><Icon name="paste" size={17} color={c.accent} /></div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ fontSize: 11, fontWeight: 700, letterSpacing: 0.5, color: c.accent, textTransform: 'uppercase' }}>From your clipboard</div>
            <div style={{ fontSize: 13, color: c.ink, fontFamily: DS.font.mono, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis', marginTop: 2 }}>share.example.com/p/8fa2c91b</div>
          </div>
          <Icon name="arrowRight" size={18} color={c.faint} />
        </div>
      </div>

      {/* recent peek (lightweight history from B) */}
      {app.history.length > 0 && (
        <div style={{ padding: '0 22px 4px' }}>
          <div style={{ display: 'flex', alignItems: 'center', marginBottom: 11 }}>
            <SectionLabel>Recent saves</SectionLabel>
            <button className="ds-press" onClick={() => app.go('history')} style={{ marginLeft: 'auto', border: 'none', background: 'none', color: c.accent, fontSize: 13, fontWeight: 600, cursor: 'pointer' }}>See all</button>
          </div>
          <div className="ds-stagger" style={{ display: 'flex', gap: 9 }}>
            {app.history.slice(0, 4).map((h, i) => (
              <div key={i} style={{ flex: 1, animationDelay: `${i * 50}ms`, position: 'relative' }}>
                <MediaTile kind={h.kind} tone={h.kind === 'video' ? 'cool' : 'neutral'} radius={13} aspect="1" badge={h.kind === 'video' ? <Icon name="play" size={9} color="#fff" /> : null} />
              </div>
            ))}
          </div>
        </div>
      )}

      <div style={{ padding: '16px 22px 14px' }}>
        <Button icon="paste" onClick={() => app.paste('manual')}>Paste link</Button>
        <div style={{ marginTop: 13 }}><RightsNote>Save only content you have the rights to. Private or protected media isn’t supported.</RightsNote></div>
      </div>
    </div>
  );
}

// ── ANALYZING (explainable, C-style) ─────────────────────────
function AnalyzingScreen({ app }) {
  const c = DS.color;
  const steps = ['Reaching the page', 'Checking it’s public', 'Listing available media'];
  const [done, setDone] = useState(0);
  const [pct, setPct] = useState(8);
  useEffect(() => {
    const t1 = setTimeout(() => setDone(1), 650);
    const t2 = setTimeout(() => setDone(2), 1450);
    const t3 = setTimeout(() => setDone(3), 2200);
    const t4 = setTimeout(() => app.onAnalyzed(), 2700);
    const pi = setInterval(() => setPct((p) => Math.min(96, p + 6 + Math.random() * 8)), 180);
    return () => { [t1, t2, t3, t4].forEach(clearTimeout); clearInterval(pi); };
  }, []);
  return (
    <div className="ds-screen" style={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
      <TopBar onBack={() => app.go('home')} title="" />
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '0 30px', textAlign: 'center' }}>
        <Ring size={96} stroke={7} pct={pct} color={c.accent} track={c.hair}>
          <Icon name="search" size={27} color={c.accent} />
        </Ring>
        <div style={{ fontSize: 22, fontWeight: 700, color: c.ink, marginTop: 26, letterSpacing: -0.4, display: 'flex', alignItems: 'center', gap: 9 }}>Reading this link <Dots /></div>
        <div style={{ fontSize: 14, color: c.sub, marginTop: 9, maxWidth: 250, lineHeight: 1.5 }}>Finding media that’s publicly available for you to save.</div>
        <div style={{ marginTop: 30, width: '100%', maxWidth: 270, display: 'flex', flexDirection: 'column', gap: 13 }}>
          {steps.map((t, i) => {
            const isDone = i < done, isActive = i === done;
            return (
              <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 12, fontSize: 14, color: isDone ? c.ink : isActive ? c.ink : c.faint, transition: 'color .3s ease' }}>
                <span style={{ width: 22, height: 22, borderRadius: 11, flexShrink: 0, background: isDone ? c.success : 'transparent', border: isDone ? 'none' : `2px solid ${isActive ? c.accent : c.hair}`, display: 'flex', alignItems: 'center', justifyContent: 'center', transition: 'all .3s ease' }}>
                  {isDone ? <Icon name="checkSmall" size={13} color="#fff" stroke={2.8} /> : isActive ? <span style={{ width: 9, height: 9, borderRadius: 5, background: c.accent, animation: 'ds-pulse 1s infinite' }} /> : null}
                </span>
                <span style={{ fontWeight: isActive ? 600 : 500 }}>{t}</span>
              </div>
            );
          })}
        </div>
      </div>
      <div style={{ padding: '0 22px 18px' }}>
        <UrlChip url="share.example.com/p/8fa2c91b" />
      </div>
    </div>
  );
}

function UrlChip({ url }) {
  const c = DS.color;
  return (
    <div style={{ background: c.surface, border: `1px solid ${c.hair}`, borderRadius: DS.radius.md, padding: '11px 14px', display: 'flex', alignItems: 'center', gap: 9 }}>
      <Icon name="globe" size={15} color={c.faint} />
      <span style={{ flex: 1, fontSize: 12.5, color: c.sub, fontFamily: DS.font.mono, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{url}</span>
      <Pill tone="success" icon="shield">Public</Pill>
    </div>
  );
}

// ── RESULT · single video ────────────────────────────────────
function ResultScreen({ app }) {
  const c = DS.color;
  const q = app.qualityMeta();
  return (
    <div className="ds-screen" style={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
      <TopBar onBack={() => app.go('home')} title="Available media" right={<button className="ds-press" style={{ border: 'none', background: 'none', cursor: 'pointer', padding: 8 }}><Icon name="share" size={19} color={c.sub} /></button>} />
      <div style={{ flex: 1, minHeight: 0, padding: '4px 20px 0', display: 'flex', flexDirection: 'column' }} className="ds-stagger">
        <div style={{ animationDelay: '0ms' }}>
          <MediaTile kind="video" tone="cool" radius={DS.radius.xl} aspect="4 / 3" label="video" badge={<><Icon name="play" size={11} color="#fff" /> 0:42</>} />
        </div>
        <div style={{ marginTop: 16, animationDelay: '60ms' }}>
          <div style={{ fontSize: 18, fontWeight: 700, color: c.ink, letterSpacing: -0.3 }}>Public post · 1 video</div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginTop: 7 }}>
            <Pill icon="globe">example.com</Pill>
            <Pill>Landscape · MP4</Pill>
          </div>
        </div>
        {/* explainable note (C) */}
        <div style={{ marginTop: 14, display: 'flex', gap: 9, alignItems: 'flex-start', animationDelay: '110ms' }}>
          <Icon name="info" size={15} color={c.faint} stroke={1.8} style={{ marginTop: 1, flexShrink: 0 }} />
          <span style={{ fontSize: 12.5, color: c.sub, lineHeight: 1.5 }}>This media is publicly accessible. Choose a quality below, then save it to your gallery.</span>
        </div>
        {/* quality selector */}
        <div style={{ marginTop: 16, animationDelay: '160ms' }}>
          <Card onClick={() => app.openSheet('quality')} pad={14} style={{ display: 'flex', alignItems: 'center', gap: 13 }}>
            <div style={{ width: 38, height: 38, borderRadius: 11, background: c.accentSoft, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}><Icon name="sliders" size={19} color={c.accent} /></div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 14.5, fontWeight: 600, color: c.ink }}>{q.label} · {q.tag}</div>
              <div style={{ fontSize: 12, color: c.faint }}>≈ {q.size} · tap to change quality</div>
            </div>
            <Icon name="chevronDown" size={18} color={c.faint} />
          </Card>
        </div>
      </div>
      <div style={{ padding: '16px 20px 14px' }}>
        <Button icon="download" onClick={() => app.requestSave(['video'])}>Save to gallery</Button>
        <div style={{ marginTop: 13 }}><RightsNote>By saving, you confirm you have the right to keep this content.</RightsNote></div>
      </div>
    </div>
  );
}

// ── CAROUSEL multi-select ────────────────────────────────────
function CarouselScreen({ app }) {
  const c = DS.color;
  const items = app.carousel;
  const selCount = items.filter((i) => i.sel).length;
  const totalMB = items.filter((i) => i.sel).reduce((s, i) => s + i.mb, 0);
  return (
    <div className="ds-screen" style={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
      <TopBar onBack={() => app.go('home')} title={`${items.length} items found`} right={
        <button className="ds-press" onClick={app.toggleAll} style={{ border: 'none', background: 'none', color: c.accent, fontSize: 13.5, fontWeight: 600, cursor: 'pointer', padding: '6px 4px' }}>{selCount === items.length ? 'Clear' : 'Select all'}</button>
      } />
      <div style={{ padding: '0 20px 8px', display: 'flex', gap: 9, alignItems: 'center' }}>
        <Pill tone="accent" icon="layers">Carousel</Pill>
        <span style={{ fontSize: 12.5, color: c.sub }}>{selCount} selected</span>
      </div>
      <div className="ds-noscroll" style={{ flex: 1, minHeight: 0, overflowY: 'auto', padding: '4px 20px 0' }}>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          {items.map((it, i) => (
            <Card key={i} active={it.sel} onClick={() => app.toggleItem(i)} pad={10} style={{ display: 'flex', alignItems: 'center', gap: 13 }}>
              <div style={{ width: 56, height: 56, flexShrink: 0, position: 'relative' }}>
                <MediaTile kind={it.kind} tone={it.kind === 'video' ? 'cool' : 'neutral'} radius={10} height={56} />
              </div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontSize: 14, fontWeight: 600, color: c.ink }}>{it.kind === 'video' ? 'Video clip' : 'Image ' + (i + 1)}</div>
                <div style={{ fontSize: 12, color: c.faint }}>{it.kind === 'video' ? `0:${it.dur} · MP4 · ≈ ${it.mb} MB` : `JPG · ≈ ${it.mb} MB`}</div>
              </div>
              <CheckCircle on={it.sel} />
            </Card>
          ))}
        </div>
      </div>
      <div style={{ padding: '14px 20px 14px', borderTop: `1px solid ${c.hair2}`, background: c.surface2 }}>
        <Button icon="download" disabled={selCount === 0} onClick={() => selCount > 0 && app.requestSave(items.filter(i => i.sel).map(i => i.kind))}>
          {selCount === 0 ? 'Select items to save' : `Save ${selCount} item${selCount > 1 ? 's' : ''} · ≈ ${totalMB.toFixed(1)} MB`}
        </Button>
      </div>
    </div>
  );
}

// ── QUALITY sheet content ────────────────────────────────────
function QualitySheet({ app }) {
  const c = DS.color;
  const opts = app.qualityOptions;
  return (
    <Sheet open title="Choose quality" sub="Higher quality looks sharper but uses more storage." onClose={app.closeSheet}>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
        {opts.map((o) => {
          const on = app.quality === o.id;
          return (
            <div key={o.id} className="ds-press" onClick={() => app.setQuality(o.id)} style={{ display: 'flex', alignItems: 'center', gap: 13, padding: '13px 15px', borderRadius: DS.radius.md, border: `1.5px solid ${on ? c.accent : c.hair}`, background: on ? c.accentSoft : c.surface, cursor: 'pointer', transition: 'all .18s ease' }}>
              <div style={{ flex: 1 }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                  <span style={{ fontSize: 15.5, fontWeight: 650, color: c.ink }}>{o.label}</span>
                  {o.rec && <Pill tone="accent">Recommended</Pill>}
                </div>
                <div style={{ fontSize: 12, color: c.faint, marginTop: 2 }}>{o.tag} · ≈ {o.size}</div>
              </div>
              <span style={{ width: 22, height: 22, borderRadius: 11, border: `2px solid ${on ? c.accent : c.hair}`, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>{on && <span style={{ width: 11, height: 11, borderRadius: 6, background: c.accent }} />}</span>
            </div>
          );
        })}
      </div>
      <div style={{ marginTop: 18 }}>
        <Button icon="download" onClick={() => { app.closeSheet(); app.requestSave(['video']); }}>Save · {app.qualityMeta().label}</Button>
      </div>
    </Sheet>
  );
}

// ── DOWNLOAD progress (with lightweight queue, B) ────────────
function DownloadScreen({ app }) {
  const c = DS.color;
  const multi = app.queue.length > 1;
  const overall = app.queue.length ? Math.round(app.queue.reduce((s, j) => s + j.pct, 0) / app.queue.length) : app.progress;
  return (
    <div className="ds-screen" style={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
      <TopBar title={multi ? 'Saving items' : ''} />
      {!multi ? (
        <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '0 30px' }}>
          <Ring size={150} stroke={11} pct={app.progress} color={c.accent} track={c.hair}>
            <div style={{ fontSize: 36, fontWeight: 700, color: c.ink, letterSpacing: -1, fontVariantNumeric: 'tabular-nums' }}>{app.progress}<span style={{ fontSize: 18 }}>%</span></div>
          </Ring>
          <div style={{ fontSize: 18, fontWeight: 700, color: c.ink, marginTop: 28, letterSpacing: -0.3 }}>Saving video…</div>
          <div style={{ fontSize: 13.5, color: c.sub, marginTop: 6, fontVariantNumeric: 'tabular-nums' }}>{(app.progress * 0.24).toFixed(1)} MB of 24 MB · 3.2 MB/s</div>
        </div>
      ) : (
        <div style={{ flex: 1, minHeight: 0, padding: '4px 20px 0', display: 'flex', flexDirection: 'column' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 14, padding: '6px 2px 18px' }}>
            <Ring size={62} stroke={6} pct={overall} color={c.accent} track={c.hair}><span style={{ fontSize: 15, fontWeight: 700, color: c.ink }}>{overall}%</span></Ring>
            <div>
              <div style={{ fontSize: 17, fontWeight: 700, color: c.ink }}>Saving {app.queue.length} items</div>
              <div style={{ fontSize: 13, color: c.sub }}>{app.queue.filter(j => j.pct >= 100).length} done · {app.queue.filter(j => j.pct < 100).length} remaining</div>
            </div>
          </div>
          <div className="ds-noscroll" style={{ flex: 1, overflowY: 'auto', display: 'flex', flexDirection: 'column', gap: 9 }}>
            {app.queue.map((j, i) => (
              <Card key={i} pad={11}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 11, marginBottom: j.pct < 100 ? 9 : 0 }}>
                  <div style={{ width: 26, height: 26, borderRadius: 8, background: j.pct >= 100 ? c.successSoft : c.accentSoft, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                    {j.pct >= 100 ? <Icon name="check" size={15} color={c.success} stroke={2.6} /> : <Icon name={j.kind === 'video' ? 'film' : 'image'} size={14} color={c.accent} />}
                  </div>
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <div style={{ fontSize: 13.5, fontWeight: 600, color: c.ink }}>{j.name}</div>
                    <div style={{ fontSize: 11.5, color: c.faint }}>{j.meta}{j.pct < 100 ? ` · ${j.pct}%` : ' · done'}</div>
                  </div>
                  {j.pct >= 100 && <Icon name="check" size={16} color={c.success} stroke={2.4} />}
                </div>
                {j.pct < 100 && <Bar pct={j.pct} color={c.accent} track={c.bgSunken} height={5} />}
              </Card>
            ))}
          </div>
        </div>
      )}
      <div style={{ padding: '14px 22px 16px' }}>
        <Button variant="outline" icon="x" onClick={() => app.go('home')}>Cancel</Button>
      </div>
    </div>
  );
}

// ── SUCCESS ──────────────────────────────────────────────────
function SuccessScreen({ app }) {
  const c = DS.color;
  const n = app.lastSaved.length;
  return (
    <div className="ds-screen" style={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
      <TopBar title="" right={<button className="ds-press" onClick={() => app.go('home')} style={{ border: 'none', background: 'none', cursor: 'pointer', padding: 8 }}><Icon name="x" size={20} color={c.sub} /></button>} />
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '0 30px', textAlign: 'center' }}>
        <div style={{ width: 92, height: 92, borderRadius: 46, background: c.success, display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: '0 12px 30px rgba(46,158,107,0.34)', animation: `ds-pop .5s ${DS.motion.spring} both` }}>
          <svg width="46" height="46" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2.6" strokeLinecap="round" strokeLinejoin="round"><path d="M5 12.5l4.5 4.5L19 7" /></svg>
        </div>
        <div style={{ fontSize: 24, fontWeight: 700, color: c.ink, marginTop: 26, letterSpacing: -0.4 }}>{n > 1 ? `${n} items saved` : 'Saved to gallery'}</div>
        <div style={{ fontSize: 14.5, color: c.sub, marginTop: 9, lineHeight: 1.5, maxWidth: 260 }}>{n > 1 ? 'They’re in your gallery, ready offline.' : 'Your video is in Photos, ready offline.'}</div>
        <div className="ds-stagger" style={{ marginTop: 24, display: 'flex', gap: 8 }}>
          {app.lastSaved.slice(0, 4).map((k, i) => (
            <div key={i} style={{ width: n > 1 ? 58 : 76, animationDelay: `${200 + i * 70}ms` }}><MediaTile kind={k} tone={k === 'video' ? 'cool' : 'neutral'} radius={13} aspect="1" /></div>
          ))}
        </div>
        <div style={{ marginTop: 18 }}><Pill tone="success" icon="check">Added to your history</Pill></div>
      </div>
      <div style={{ padding: '0 22px 16px', display: 'flex', flexDirection: 'column', gap: 11 }}>
        <Button icon="photo" onClick={() => app.go('history')}>Open in gallery</Button>
        <Button variant="ghost" icon="paste" onClick={() => app.go('home')}>Save another link</Button>
      </div>
    </div>
  );
}

Object.assign(window, { HomeScreen, AnalyzingScreen, ResultScreen, CarouselScreen, QualitySheet, DownloadScreen, SuccessScreen, UrlChip });
