// Auxiliary screens: History, Settings/Legal, Error states, Permission sheet.

// ── HISTORY ──────────────────────────────────────────────────
function HistoryScreen({ app }) {
  const c = DS.color;
  const groups = app.historyGroups();
  return (
    <div className="ds-screen" style={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
      <TopBar onBack={() => app.go('home')} title="History" right={<button className="ds-press" style={{ border: 'none', background: 'none', cursor: 'pointer', padding: 8 }}><Icon name="search" size={20} color={c.ink} /></button>} />
      {/* storage summary */}
      <div style={{ padding: '0 20px 12px' }}>
        <div style={{ background: c.accentSoft, borderRadius: DS.radius.md, padding: '13px 15px', display: 'flex', alignItems: 'center', gap: 12 }}>
          <div style={{ width: 36, height: 36, borderRadius: 11, background: c.surface, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}><Icon name="folder" size={18} color={c.accent} /></div>
          <div style={{ flex: 1 }}>
            <div style={{ fontSize: 13.5, fontWeight: 650, color: c.accentInk }}>{app.history.length} saves · 248 MB used</div>
            <div style={{ fontSize: 11.5, color: c.accentInk, opacity: 0.7 }}>Stored in your gallery</div>
          </div>
          <Icon name="chevRightSm" size={18} color={c.accentInk} />
        </div>
      </div>
      <div className="ds-noscroll" style={{ flex: 1, minHeight: 0, overflowY: 'auto', padding: '0 20px 12px' }}>
        {groups.map(([label, rows], gi) => (
          <div key={gi} style={{ marginBottom: 16 }}>
            <SectionLabel style={{ margin: '2px 2px 10px' }}>{label}</SectionLabel>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 9 }}>
              {rows.map((h, i) => (
                <Card key={i} pad={10} style={{ display: 'flex', alignItems: 'center', gap: 13 }}>
                  <div style={{ width: 50, height: 50, flexShrink: 0, position: 'relative' }}>
                    <MediaTile kind={h.kind} tone={h.kind === 'video' ? 'cool' : 'neutral'} radius={10} height={50} badge={h.kind === 'video' ? <Icon name="play" size={8} color="#fff" /> : null} />
                  </div>
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <div style={{ fontSize: 14, fontWeight: 600, color: c.ink }}>{h.title}</div>
                    <div style={{ fontSize: 12, color: c.faint, fontFamily: DS.font.mono }}>{h.meta}</div>
                  </div>
                  <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'flex-end', gap: 7 }}>
                    <span style={{ fontSize: 11.5, color: c.faint }}>{h.time}</span>
                    <button className="ds-press" style={{ border: 'none', background: 'none', cursor: 'pointer', padding: 2 }}><Icon name="moreV" size={16} color={c.faint} /></button>
                  </div>
                </Card>
              ))}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

// ── SETTINGS / LEGAL / PERMISSIONS ───────────────────────────
function SettingsRow({ icon, label, value, toggle, on, onToggle, danger, last, onClick }) {
  const c = DS.color;
  return (
    <div className={onClick ? 'ds-press' : ''} onClick={onClick} style={{ display: 'flex', alignItems: 'center', gap: 13, padding: '13px 15px', borderBottom: last ? 'none' : `1px solid ${c.hair2}`, cursor: onClick ? 'pointer' : 'default' }}>
      <div style={{ width: 32, height: 32, borderRadius: 9, background: danger ? c.dangerSoft : c.bgSunken, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}><Icon name={icon} size={17} color={danger ? c.danger : c.sub} /></div>
      <span style={{ flex: 1, fontSize: 14.5, color: danger ? c.danger : c.ink, fontWeight: 500 }}>{label}</span>
      {value && <span style={{ fontSize: 13.5, color: c.faint }}>{value}</span>}
      {toggle && <Toggle on={on} onToggle={onToggle} />}
      {onClick && !toggle && !value && <Icon name="chevRightSm" size={17} color={c.faint} />}
      {value && onClick && <Icon name="chevRightSm" size={17} color={c.faint} />}
    </div>
  );
}

function Toggle({ on, onToggle }) {
  const c = DS.color;
  return (
    <button onClick={(e) => { e.stopPropagation(); onToggle && onToggle(); }} style={{ width: 46, height: 28, borderRadius: 14, border: 'none', background: on ? c.accent : c.hair, position: 'relative', cursor: 'pointer', transition: 'background .2s ease', flexShrink: 0 }}>
      <span style={{ position: 'absolute', top: 3, left: on ? 21 : 3, width: 22, height: 22, borderRadius: 11, background: '#fff', boxShadow: '0 1px 3px rgba(0,0,0,0.2)', transition: `left .22s ${DS.motion.spring}` }} />
    </button>
  );
}

function SettingsGroup({ label, children }) {
  const c = DS.color;
  return (
    <div style={{ marginBottom: 18 }}>
      <SectionLabel style={{ margin: '0 4px 9px' }}>{label}</SectionLabel>
      <div style={{ background: c.surface, borderRadius: DS.radius.md, border: `1px solid ${c.hair}`, overflow: 'hidden', boxShadow: DS.shadow.sm }}>{children}</div>
    </div>
  );
}

function SettingsScreen({ app }) {
  const c = DS.color;
  const t = app.toggles;
  return (
    <div className="ds-screen" style={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
      <TopBar onBack={() => app.go('home')} title="Settings" />
      <div className="ds-noscroll" style={{ flex: 1, minHeight: 0, overflowY: 'auto', padding: '6px 20px 20px' }}>
        <SettingsGroup label="Downloads">
          <SettingsRow icon="sliders" label="Default quality" value="1080p" onClick={() => {}} />
          <SettingsRow icon="help" label="Ask quality every time" toggle on={t.ask} onToggle={() => app.toggle('ask')} />
          <SettingsRow icon="wifi" label="Save on Wi-Fi only" toggle on={t.wifi} onToggle={() => app.toggle('wifi')} last />
        </SettingsGroup>

        <SettingsGroup label="Permissions">
          <SettingsRow icon="photo" label="Save to gallery" value="Allowed" onClick={() => {}} />
          <SettingsRow icon="bell" label="Download notifications" toggle on={t.notify} onToggle={() => app.toggle('notify')} last />
        </SettingsGroup>

        <SettingsGroup label="Storage">
          <SettingsRow icon="folder" label="Save location" value="Gallery" onClick={() => {}} />
          <SettingsRow icon="trash" label="Clear history" onClick={() => {}} last />
        </SettingsGroup>

        <SettingsGroup label="About & legal">
          <SettingsRow icon="info" label="How Quietly works" onClick={() => {}} />
          <SettingsRow icon="shield" label="Acceptable use & your rights" onClick={() => {}} />
          <SettingsRow icon="lock" label="Privacy policy" onClick={() => {}} />
          <SettingsRow icon="external" label="Terms of service" onClick={() => {}} last />
        </SettingsGroup>

        {/* rights statement */}
        <div style={{ background: c.bgSunken, borderRadius: DS.radius.md, padding: '14px 16px' }}>
          <div style={{ display: 'flex', gap: 9, alignItems: 'flex-start' }}>
            <Icon name="shield" size={16} color={c.faint} stroke={1.8} style={{ marginTop: 1, flexShrink: 0 }} />
            <span style={{ fontSize: 12, color: c.sub, lineHeight: 1.55, textWrap: 'pretty' }}>Quietly saves only publicly accessible media. You’re responsible for ensuring you have the rights to save and use any content. Private, login-only, and DRM-protected media isn’t supported.</span>
          </div>
        </div>
        <div style={{ textAlign: 'center', marginTop: 18, fontSize: 11.5, color: c.faint }}>Quietly · version 1.0.0</div>
      </div>
    </div>
  );
}

// ── ERROR / EDGE STATES ──────────────────────────────────────
// One flexible component, configured by `app.error`.
const ERROR_CONFIG = {
  protected: {
    icon: 'lock', title: 'This content is protected',
    body: 'It looks private, login-only, or rights-protected. Quietly can only save media that’s publicly available and permitted.',
    tip: ['A public version of the same post', 'A direct link you have rights to'],
    cta: 'Try another link', ctaIcon: 'link', tone: 'neutral',
  },
  invalid: {
    icon: 'alert', title: 'That doesn’t look like a link',
    body: 'Make sure you’ve copied a full web address — it should start with https:// and point to a public post or page.',
    cta: 'Paste again', ctaIcon: 'paste', tone: 'warn',
  },
  network: {
    icon: 'wifiOff', title: 'Couldn’t reach this link',
    body: 'We weren’t able to connect. Check your connection and try again — your link is still here.',
    cta: 'Retry', ctaIcon: 'refresh', tone: 'neutral', secondary: 'Edit link',
  },
  unsupported: {
    icon: 'globe', title: 'We can’t read this source yet',
    body: 'This site isn’t supported for media analysis. We only work with public sources that allow saving.',
    cta: 'Try another link', ctaIcon: 'link', tone: 'neutral',
  },
  storage: {
    icon: 'folder', title: 'Not enough space',
    body: 'Your device is low on storage. Free up some space, or choose a smaller quality, then try again.',
    cta: 'Choose smaller quality', ctaIcon: 'sliders', tone: 'warn', secondary: 'Manage storage',
  },
  exists: {
    icon: 'check', title: 'Already in your gallery',
    body: 'You’ve already saved this exact media. You can open it, or save it again as a copy.',
    cta: 'Open in gallery', ctaIcon: 'photo', tone: 'success', secondary: 'Save a copy',
  },
};

function ErrorScreen({ app }) {
  const c = DS.color;
  const cfg = ERROR_CONFIG[app.error] || ERROR_CONFIG.protected;
  const toneColor = { neutral: c.faint, warn: c.warn, success: c.success, danger: c.danger }[cfg.tone];
  const toneBg = { neutral: c.bgSunken, warn: c.warnSoft, success: c.successSoft, danger: c.dangerSoft }[cfg.tone];
  return (
    <div className="ds-screen" style={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
      <TopBar onBack={() => app.go('home')} title="" />
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '0 30px', textAlign: 'center' }}>
        <div style={{ width: 84, height: 84, borderRadius: 42, background: toneBg, display: 'flex', alignItems: 'center', justifyContent: 'center', animation: `ds-pop .45s ${DS.motion.spring} both` }}>
          <Icon name={cfg.icon} size={34} color={toneColor} stroke={cfg.tone === 'success' ? 2.4 : 1.9} />
        </div>
        <div style={{ fontSize: 21, fontWeight: 700, color: c.ink, marginTop: 24, letterSpacing: -0.3, textWrap: 'balance' }}>{cfg.title}</div>
        <div style={{ fontSize: 14.5, color: c.sub, marginTop: 11, lineHeight: 1.55, textWrap: 'pretty' }}>{cfg.body}</div>
        {cfg.tip && (
          <div style={{ marginTop: 20, background: c.surface, border: `1px solid ${c.hair}`, borderRadius: DS.radius.md, padding: '13px 16px', textAlign: 'left', width: '100%', boxShadow: DS.shadow.sm }}>
            <div style={{ fontSize: 12.5, fontWeight: 700, color: c.ink, marginBottom: 7 }}>You can try</div>
            {cfg.tip.map((t, i) => (
              <div key={i} style={{ display: 'flex', gap: 9, alignItems: 'center', fontSize: 13, color: c.sub, padding: '4px 0' }}><span style={{ width: 5, height: 5, borderRadius: 3, background: c.faint, flexShrink: 0 }} />{t}</div>
            ))}
          </div>
        )}
      </div>
      <div style={{ padding: '0 22px 16px', display: 'flex', flexDirection: 'column', gap: 10 }}>
        <Button icon={cfg.ctaIcon} onClick={() => app.go(app.error === 'exists' ? 'history' : 'home')}>{cfg.cta}</Button>
        {cfg.secondary && <Button variant="ghost" onClick={() => app.go('home')}>{cfg.secondary}</Button>}
        {(app.error === 'protected' || app.error === 'unsupported') && (
          <div style={{ marginTop: 4 }}><RightsNote>Quietly respects platform rules and creators’ rights. Some media simply can’t be saved.</RightsNote></div>
        )}
      </div>
    </div>
  );
}

// ── PERMISSION sheet (storage / gallery access) ──────────────
function PermissionSheet({ app }) {
  const c = DS.color;
  return (
    <Sheet open onClose={app.closeSheet}>
      <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center', padding: '4px 4px 0' }}>
        <div style={{ width: 64, height: 64, borderRadius: 20, background: c.accentSoft, display: 'flex', alignItems: 'center', justifyContent: 'center', animation: `ds-pop .45s ${DS.motion.spring} both` }}>
          <Icon name="photo" size={30} color={c.accent} />
        </div>
        <div style={{ fontSize: 19, fontWeight: 700, color: c.ink, marginTop: 16, letterSpacing: -0.3 }}>Allow saving to your gallery</div>
        <div style={{ fontSize: 13.5, color: c.sub, marginTop: 9, lineHeight: 1.5 }}>Quietly needs permission to save media to your device’s gallery. We only write the files you choose — nothing else.</div>
      </div>
      <div style={{ marginTop: 20, display: 'flex', flexDirection: 'column', gap: 10 }}>
        <Button icon="check" onClick={app.grantPermission}>Allow access</Button>
        <Button variant="ghost" onClick={app.closeSheet}>Not now</Button>
      </div>
    </Sheet>
  );
}

Object.assign(window, { HistoryScreen, SettingsScreen, ErrorScreen, PermissionSheet, ERROR_CONFIG, Toggle });
