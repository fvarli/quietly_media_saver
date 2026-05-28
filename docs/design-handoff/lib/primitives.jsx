// Shared primitives for the 4-direction media-saver exploration.
// Phone shell, status bar, a small line-icon set, and neutral media
// placeholders. Exports to window for use across direction files.

// ── Icon set ─────────────────────────────────────────────────
// Simple lucide-ish line icons. Most stroke; a few fill (play, dots, star).
const ICONS = {
  link: { d: 'M9.5 13.5a3.5 3.5 0 0 0 5 0l3-3a3.5 3.5 0 1 0-5-5l-1.3 1.3 M14.5 10.5a3.5 3.5 0 0 0-5 0l-3 3a3.5 3.5 0 1 0 5 5l1.3-1.3' },
  paste: { d: 'M9 4h6v3H9z M7 5H5v15h14V5h-2 M9 12h6 M9 16h4' },
  arrowRight: { d: 'M5 12h13 M13 6l6 6-6 6' },
  arrowDown: { d: 'M12 5v13 M6 12l6 6 6-6' },
  check: { d: 'M5 12.5l4.5 4.5L19 7' },
  checkSmall: { d: 'M4 8.5l3 3L13 5' },
  x: { d: 'M6 6l12 12 M18 6L6 18' },
  download: { d: 'M12 4v11 M7.5 10.5L12 15l4.5-4.5 M5 19h14' },
  play: { d: 'M8 5.5v13l11-6.5z', fill: true },
  image: { d: 'M4 5h16v14H4z M4 16l4.5-4.5 3.5 3.5 4-4 4 4', extra: '<circle cx="9" cy="9.5" r="1.4"/>' },
  layers: { d: 'M12 3l8.5 4.5L12 12 3.5 7.5 12 3z M4 12l8 4.5 8-4.5 M4 16.5l8 4.5 8-4.5' },
  clock: { d: 'M12 7v5l3.5 2', extra: '<circle cx="12" cy="12" r="8.5"/>' },
  sliders: { d: 'M5 7h9 M18 7h1 M5 12h3 M12 12h7 M5 17h7 M16 17h3', extra: '<circle cx="16" cy="7" r="2"/><circle cx="10" cy="12" r="2"/><circle cx="14" cy="17" r="2"/>' },
  shield: { d: 'M12 3l7 2.5v5.5c0 4.2-3 7.3-7 8.5-4-1.2-7-4.3-7-8.5V5.5L12 3z M9 12l2 2 4-4' },
  chevronDown: { d: 'M6 9.5l6 6 6-6' },
  chevronUp: { d: 'M6 14.5l6-6 6 6' },
  chevronLeft: { d: 'M15 5l-6 7 6 7' },
  chevronRight: { d: 'M9 5l6 7-6 7' },
  lock: { d: 'M6 11h12v9H6z M8.5 11V8a3.5 3.5 0 0 1 7 0v3' },
  alert: { d: 'M12 4l9 16H3L12 4z M12 10v4 M12 17.5v.5' },
  folder: { d: 'M3 7h6l2 2.5h10V19H3z' },
  grid: { d: 'M4 4h7v7H4z M13 4h7v7h-7z M4 13h7v7H4z M13 13h7v7h-7z' },
  star: { d: 'M12 3l2.4 6.2 6.6.4-5.1 4.2 1.7 6.4L12 16.9 6.4 20.2l1.7-6.4-5.1-4.2 6.6-.4L12 3z', fill: true },
  sparkle: { d: 'M12 3c.5 4 1.5 5 5.5 5.5-4 .5-5 1.5-5.5 5.5-.5-4-1.5-5-5.5-5.5 4-.5 5-1.5 5.5-5.5z M19 15c.3 2 .8 2.5 2.8 2.8-2 .3-2.5.8-2.8 2.8-.3-2-.8-2.5-2.8-2.8 2-.3 2.5-.8 2.8-2.8z', fill: true },
  more: { d: '', extra: '<circle cx="5" cy="12" r="1.8"/><circle cx="12" cy="12" r="1.8"/><circle cx="19" cy="12" r="1.8"/>', fill: true },
  moreV: { d: '', extra: '<circle cx="12" cy="5" r="1.8"/><circle cx="12" cy="12" r="1.8"/><circle cx="12" cy="19" r="1.8"/>', fill: true },
  plus: { d: 'M12 5v14 M5 12h14' },
  trash: { d: 'M5 7h14 M9 7V5h6v2 M7 7l1 13h8l1-13 M10 11v6 M14 11v6' },
  search: { d: 'M11 4a7 7 0 1 0 0 14 7 7 0 0 0 0-14z M16.5 16.5L21 21' },
  film: { d: 'M4 4h16v16H4z M4 8h16 M4 16h16 M9 4v16 M15 4v16' },
  photo: { d: 'M4 5h16v14H4z M4 16l4.5-4.5 3.5 3.5 4-4 4 4', extra: '<circle cx="9" cy="9.5" r="1.4"/>' },
  gallery: { d: 'M7 3h14v14H7z M3 7v14h14', extra: '' },
  home: { d: 'M4 11l8-7 8 7 M6 9.5V20h12V9.5' },
  bolt: { d: 'M13 3L5 13h5l-1 8 8-10h-5l1-8z', fill: true },
  refresh: { d: 'M20 8a8 8 0 1 0 1 6 M20 4v4h-4' },
  pause: { d: 'M8 5h3v14H8z M13 5h3v14h-3z', fill: true },
  globe: { d: 'M3 12h18 M12 3c3 3.5 3 14.5 0 18 M12 3c-3 3.5-3 14.5 0 18', extra: '<circle cx="12" cy="12" r="9"/>' },
  wifi: { d: 'M2 8.5C5 6 9 4.5 12 4.5s7 1.5 10 4 M5 11.5C7 10 9.5 9 12 9s5 1 7 2.5 M8 14.5c1.2-.9 2.6-1.4 4-1.4s2.8.5 4 1.4', extra: '<circle cx="12" cy="18" r="1.1" fill="currentColor" stroke="none"/>' },
  wifiOff: { d: 'M3 3l18 18 M8 14.5c1.2-.9 2.6-1.4 4-1.4 M2 8.5C4 7 6.4 5.8 9 5.1 M15 5.2c2.6.6 5 1.8 7 3.3 M17.8 11.2c.4.2.8.5 1.2.8', extra: '<circle cx="12" cy="18" r="1.1" fill="currentColor" stroke="none"/>' },
  settings: { d: 'M12 3v2.6 M12 18.4V21 M5.6 5.6l1.9 1.9 M16.5 16.5l1.9 1.9 M3 12h2.6 M18.4 12H21 M5.6 18.4l1.9-1.9 M16.5 7.5l1.9-1.9', extra: '<circle cx="12" cy="12" r="3.4"/>' },
  share: { d: 'M12 14V4 M8.5 7.5L12 4l3.5 3.5 M6 12v7h12v-7' },
  info: { d: 'M12 11v5.5 M12 7.6v.4', extra: '<circle cx="12" cy="12" r="8.5"/>' },
  help: { d: 'M9.4 9.2a2.6 2.6 0 1 1 3.6 2.5c-.9.5-1.2 1-1.2 2 M12 16.6v.3', extra: '<circle cx="12" cy="12" r="8.5"/>' },
  bell: { d: 'M6 9a6 6 0 1 1 12 0c0 4 1.2 5.5 2 6.5H4c.8-1 2-2.5 2-6.5z M9.5 19a2.5 2.5 0 0 0 5 0' },
  sun: { d: 'M12 6V3.5 M12 20.5V18 M6 12H3.5 M20.5 12H18 M6.7 6.7L5 5 M19 19l-1.7-1.7 M6.7 17.3L5 19 M19 5l-1.7 1.7', extra: '<circle cx="12" cy="12" r="4"/>' },
  moon: { d: 'M20 13.5A8 8 0 0 1 10.5 4 7 7 0 1 0 20 13.5z' },
  copy: { d: 'M9 9h10v11H9z M5 15H4V4h11v1' },
  music: { d: 'M9 18V6l11-2v12', extra: '<circle cx="6" cy="18" r="3"/><circle cx="17" cy="16" r="3"/>' },
  hd: { d: 'M3 6h18v12H3z M7 10v4 M10 10v4 M7 12h3 M14 10v4h1.5a2 2 0 0 0 0-4H14z' },
  scissors: { d: 'M8 8l12 8 M8 16l12-8', extra: '<circle cx="6" cy="6.5" r="2.5"/><circle cx="6" cy="17.5" r="2.5"/>' },
  cloud: { d: 'M7 18a4 4 0 0 1 .6-7.96A5.5 5.5 0 0 1 18 11a3.5 3.5 0 0 1-.5 7H7z' },
  external: { d: 'M14 5h5v5 M19 5l-8 8 M18 14v5H5V6h5' },
  chevRightSm: { d: 'M10 7l5 5-5 5' },
  list: { d: 'M8 6h12 M8 12h12 M8 18h12 M4 6h.01 M4 12h.01 M4 18h.01' },
};

function Icon({ name, size = 22, color = 'currentColor', stroke = 1.7, style }) {
  const ic = ICONS[name] || ICONS.link;
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none"
      stroke={ic.fill ? 'none' : color} strokeWidth={stroke} strokeLinecap="round" strokeLinejoin="round"
      style={{ display: 'block', flexShrink: 0, ...style }}
      dangerouslySetInnerHTML={{ __html: (ic.d ? `<path d="${ic.d}" ${ic.fill ? `fill="${color}"` : ''}/>` : '') + (ic.extra ? ic.extra.replaceAll('currentColor', color).replace(/<(circle|path)/g, ic.fill ? `<$1 fill="${color}"` : `<$1 fill="none" stroke="${color}"`) : '') }} />
  );
}

// ── Status bar ───────────────────────────────────────────────
function StatusBar({ dark, time = '9:41', accent }) {
  const fg = dark ? 'rgba(255,255,255,0.92)' : 'rgba(20,20,22,0.9)';
  return (
    <div style={{ height: 44, flexShrink: 0, display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '0 22px', fontSize: 14, fontWeight: 600, color: fg, letterSpacing: 0.2 }}>
      <span style={{ fontVariantNumeric: 'tabular-nums' }}>{time}</span>
      <span style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
        <Icon name="wifi" size={15} color={fg} stroke={1.6} />
        <svg width="22" height="12" viewBox="0 0 22 12" fill="none" style={{ display: 'block' }}>
          <rect x="0.5" y="0.5" width="18" height="11" rx="2.5" stroke={fg} strokeOpacity="0.5" />
          <rect x="2" y="2" width="13" height="8" rx="1.2" fill={fg} />
          <rect x="20" y="3.5" width="1.6" height="5" rx="0.8" fill={fg} fillOpacity="0.5" />
        </svg>
      </span>
    </div>
  );
}

// Android-style gesture home indicator
function HomeBar({ dark }) {
  return (
    <div style={{ height: 26, flexShrink: 0, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
      <div style={{ width: 120, height: 4.5, borderRadius: 3, background: dark ? 'rgba(255,255,255,0.4)' : 'rgba(20,20,22,0.28)' }} />
    </div>
  );
}

// ── Phone shell ──────────────────────────────────────────────
// Fills the artboard (360 x H). Pass bg + dark, children fill the middle.
function PhoneShell({ bg, dark, children, time, font = '-apple-system, BlinkMacSystemFont, "Segoe UI", system-ui, sans-serif', showHome = true, statusBar = true }) {
  return (
    <div style={{ height: '100%', width: '100%', background: bg, color: dark ? '#fff' : '#16161a', fontFamily: font, display: 'flex', flexDirection: 'column', overflow: 'hidden', position: 'relative' }}>
      {statusBar && <StatusBar dark={dark} time={time} />}
      <div style={{ flex: 1, minHeight: 0, display: 'flex', flexDirection: 'column', position: 'relative' }}>{children}</div>
      {showHome && <HomeBar dark={dark} />}
    </div>
  );
}

// ── Media placeholder ────────────────────────────────────────
// Neutral, low-chroma block with a media-type glyph + tiny label.
// Deliberately abstract — never real platform content.
function MediaTile({ kind = 'video', tone = 'cool', radius = 14, height, aspect, label, dim, locked, selected, badge, style, dark }) {
  // tone -> hue family for the soft gradient (low chroma, trustworthy)
  const tones = {
    cool: ['#aebbcf', '#8b9bb5'],
    coolDark: ['#3a4250', '#2a313c'],
    warm: ['#e2d6c1', '#cdbb9d'],
    neutral: ['#d9d7d1', '#c2bfb7'],
    neutralDark: ['#3c3a37', '#2c2a27'],
    green: ['#bcd2c4', '#9bbaa6'],
  };
  const [c1, c2] = tones[tone] || tones.cool;
  const glyph = kind === 'video' ? 'play' : kind === 'image' ? 'image' : 'layers';
  const glyphColor = dark ? 'rgba(255,255,255,0.62)' : 'rgba(40,45,60,0.5)';
  return (
    <div style={{ position: 'relative', width: '100%', height, aspectRatio: aspect, borderRadius: radius, background: `linear-gradient(140deg, ${c1}, ${c2})`, overflow: 'hidden', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0, ...style }}>
      {/* subtle diagonal texture so it reads as a placeholder, not real media */}
      <div style={{ position: 'absolute', inset: 0, backgroundImage: 'repeating-linear-gradient(135deg, rgba(255,255,255,0.05) 0 12px, rgba(0,0,0,0.025) 12px 24px)', opacity: 0.6 }} />
      <div style={{ position: 'relative', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 7 }}>
        <Icon name={glyph} size={kind === 'video' ? 30 : 26} color={glyphColor} stroke={1.6} />
        {label && <span style={{ fontSize: 10, fontWeight: 700, letterSpacing: 1.2, color: glyphColor, textTransform: 'uppercase' }}>{label}</span>}
      </div>
      {dim && <div style={{ position: 'absolute', inset: 0, background: 'rgba(10,12,18,0.45)' }} />}
      {locked && (
        <div style={{ position: 'absolute', inset: 0, background: 'rgba(12,14,20,0.55)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <Icon name="lock" size={22} color="rgba(255,255,255,0.85)" />
        </div>
      )}
      {badge && (
        <div style={{ position: 'absolute', top: 8, left: 8, padding: '3px 7px', borderRadius: 7, background: 'rgba(12,14,20,0.62)', color: '#fff', fontSize: 10, fontWeight: 700, letterSpacing: 0.4, display: 'flex', alignItems: 'center', gap: 4 }}>{badge}</div>
      )}
      {selected !== undefined && (
        <div style={{ position: 'absolute', top: 8, right: 8, width: 24, height: 24, borderRadius: 12, background: selected ? 'var(--sel,#4b53c4)' : 'rgba(255,255,255,0.28)', border: selected ? 'none' : '2px solid rgba(255,255,255,0.85)', display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: '0 1px 4px rgba(0,0,0,0.2)' }}>
          {selected && <Icon name="checkSmall" size={15} color="#fff" stroke={2.4} />}
        </div>
      )}
    </div>
  );
}

// Circular progress ring
function Ring({ size = 120, stroke = 9, pct = 60, color = '#4b53c4', track = 'rgba(0,0,0,0.08)', children }) {
  const r = (size - stroke) / 2;
  const c = 2 * Math.PI * r;
  return (
    <div style={{ position: 'relative', width: size, height: size }}>
      <svg width={size} height={size} style={{ transform: 'rotate(-90deg)', display: 'block' }}>
        <circle cx={size / 2} cy={size / 2} r={r} fill="none" stroke={track} strokeWidth={stroke} />
        <circle cx={size / 2} cy={size / 2} r={r} fill="none" stroke={color} strokeWidth={stroke} strokeLinecap="round" strokeDasharray={c} strokeDashoffset={c * (1 - pct / 100)} />
      </svg>
      <div style={{ position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center' }}>{children}</div>
    </div>
  );
}

// Linear progress bar
function Bar({ pct = 50, color = '#4b53c4', track = 'rgba(0,0,0,0.08)', height = 6, radius = 4 }) {
  return (
    <div style={{ width: '100%', height, borderRadius: radius, background: track, overflow: 'hidden' }}>
      <div style={{ width: pct + '%', height: '100%', borderRadius: radius, background: color }} />
    </div>
  );
}

Object.assign(window, { Icon, StatusBar, HomeBar, PhoneShell, MediaTile, Ring, Bar });
