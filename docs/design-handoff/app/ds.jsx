// ───────────────────────────────────────────────────────────────
// Quietly — Design System (Stage 2 hybrid)
// Tokens + premium primitives. Exposed on window.DS and window.*
// Base architecture = Direction A. Microcopy warmth from C, lightweight
// queue/history from B, subtle motion polish from D.
// ───────────────────────────────────────────────────────────────

const DS = {
  color: {
    bg: '#FAF8F4',          // warm off-white canvas
    bgSunken: '#F4F1EB',    // grouped section bg
    surface: '#FFFFFF',
    surface2: '#FBFAF7',
    ink: '#211D18',         // near-black, warm
    sub: '#6F685E',         // secondary text
    faint: '#A39C92',       // tertiary / placeholders
    hair: 'rgba(0,0,0,0.07)',
    hair2: 'rgba(0,0,0,0.045)',
    accent: '#4B53C4',      // indigo primary
    accentPress: '#3A41A8',
    accentSoft: '#EEEFFB',
    accentSoft2: '#E3E5F7',
    accentInk: '#2E348C',
    success: '#2E9E6B',
    successSoft: '#E3F4EC',
    warn: '#C98A2B',
    warnSoft: '#FAF0DE',
    danger: '#C5503F',
    dangerSoft: '#FBEAE6',
    onAccent: '#FFFFFF',
  },
  radius: { sm: 10, md: 14, lg: 18, xl: 22, xxl: 28, pill: 999 },
  space: (n) => n * 4,
  font: {
    sans: '-apple-system, BlinkMacSystemFont, "Segoe UI Variable", "Segoe UI", Roboto, system-ui, sans-serif',
    mono: 'ui-monospace, SFMono-Regular, "Roboto Mono", Menlo, monospace',
  },
  motion: {
    spring: 'cubic-bezier(0.34, 1.3, 0.5, 1)',   // gentle overshoot
    ease: 'cubic-bezier(0.22, 0.61, 0.36, 1)',   // decel
    fast: 180, base: 260, slow: 380,
  },
  shadow: {
    sm: '0 1px 2px rgba(30,24,16,0.05), 0 1px 3px rgba(30,24,16,0.04)',
    md: '0 4px 14px rgba(30,24,16,0.07), 0 1px 3px rgba(30,24,16,0.05)',
    lg: '0 14px 40px rgba(30,24,16,0.12), 0 4px 12px rgba(30,24,16,0.06)',
    accent: '0 8px 22px rgba(75,83,196,0.32)',
    accentSm: '0 4px 12px rgba(75,83,196,0.28)',
  },
};

// Inject keyframes + base once.
(function injectCSS() {
  if (document.getElementById('ds-css')) return;
  const s = document.createElement('style');
  s.id = 'ds-css';
  s.textContent = `
    @keyframes ds-spin { to { transform: rotate(360deg); } }
    /* entrance animations are transform-only so content ALWAYS rests visible
       (opacity:1) even if the animation clock is throttled/frozen) */
    @keyframes ds-fade-up { from { transform: translateY(9px);} to {transform:none;} }
    @keyframes ds-fade { from { transform: translateY(4px);} to {transform:none;} }
    @keyframes ds-sheet-in { from { transform: translateY(100%);} to { transform: none;} }
    @keyframes ds-scrim-in { from { opacity:0;} to { opacity:1;} }
    @keyframes ds-pop { 0%{transform:scale(0.72);} 60%{transform:scale(1.07);} 100%{transform:scale(1);} }
    @keyframes ds-pulse { 0%,100%{opacity:1;} 50%{opacity:0.45;} }
    @keyframes ds-shimmer { 0%{background-position: -200% 0;} 100%{background-position: 200% 0;} }
    @keyframes ds-bar-indef { 0%{transform:translateX(-100%);} 100%{transform:translateX(250%);} }
    @keyframes ds-dot { 0%,80%,100%{opacity:0.25;transform:translateY(0);} 40%{opacity:1;transform:translateY(-3px);} }
    .ds-press { transition: transform .12s ${DS.motion.ease}, background .15s ease, box-shadow .2s ease; }
    .ds-press:active { transform: scale(0.965); }
    .ds-screen { animation: ds-fade-up .34s ${DS.motion.ease} backwards; }
    .ds-stagger > * { animation: ds-fade-up .44s ${DS.motion.ease} backwards; }
    .ds-noscroll::-webkit-scrollbar { display: none; }
    .ds-noscroll { scrollbar-width: none; -ms-overflow-style: none; }
  `;
  document.head.appendChild(s);
})();

// ── Button ───────────────────────────────────────────────────
function Button({ children, icon, onClick, variant = 'primary', size = 'lg', full = true, disabled, style }) {
  const c = DS.color;
  const H = size === 'lg' ? 56 : size === 'md' ? 48 : 40;
  const variants = {
    primary: { background: disabled ? c.accentSoft2 : c.accent, color: disabled ? c.faint : c.onAccent, boxShadow: disabled ? 'none' : DS.shadow.accentSm },
    soft: { background: c.accentSoft, color: c.accentInk, boxShadow: 'none' },
    ghost: { background: 'transparent', color: c.accent, boxShadow: 'none' },
    outline: { background: c.surface, color: c.sub, boxShadow: 'none', border: `1.5px solid ${c.hair}` },
    danger: { background: c.dangerSoft, color: c.danger, boxShadow: 'none' },
  };
  return (
    <button className="ds-press" onClick={disabled ? undefined : onClick} style={{
      height: H, width: full ? '100%' : 'auto', padding: full ? 0 : '0 20px', border: 'none',
      borderRadius: size === 'lg' ? DS.radius.lg : DS.radius.md, cursor: disabled ? 'default' : 'pointer',
      display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 9,
      fontSize: size === 'lg' ? 16.5 : 15, fontWeight: 650, fontFamily: DS.font.sans, letterSpacing: -0.1,
      ...variants[variant], ...style,
    }}>
      {icon && <Icon name={icon} size={size === 'lg' ? 20 : 18} color={variants[variant].color} stroke={2} />}
      {children}
    </button>
  );
}

// ── Top bar (wizard) ─────────────────────────────────────────
function TopBar({ title, onBack, right, dark }) {
  const c = DS.color;
  return (
    <div style={{ height: 52, flexShrink: 0, display: 'flex', alignItems: 'center', padding: '0 8px', gap: 4 }}>
      {onBack ? (
        <button className="ds-press" onClick={onBack} style={{ width: 40, height: 40, borderRadius: 20, border: 'none', background: 'transparent', display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer' }}>
          <Icon name="chevronLeft" size={24} color={c.ink} />
        </button>
      ) : <div style={{ width: 40 }} />}
      <span style={{ flex: 1, textAlign: 'center', fontSize: 16, fontWeight: 650, color: c.ink, letterSpacing: -0.2 }}>{title}</span>
      <div style={{ minWidth: 40, display: 'flex', justifyContent: 'flex-end' }}>{right}</div>
    </div>
  );
}

// ── Rights / trust note ──────────────────────────────────────
function RightsNote({ children, icon = 'shield' }) {
  const c = DS.color;
  return (
    <div style={{ display: 'flex', gap: 8, alignItems: 'flex-start', color: c.faint, fontSize: 11.5, lineHeight: 1.45 }}>
      <Icon name={icon} size={15} color={c.faint} stroke={1.7} style={{ marginTop: 1, flexShrink: 0 }} />
      <span style={{ textWrap: 'pretty' }}>{children}</span>
    </div>
  );
}

// ── Bottom sheet (scrim + spring-in panel) ───────────────────
function Sheet({ open, onClose, children, title, sub }) {
  const c = DS.color;
  if (!open) return null;
  return (
    <div style={{ position: 'absolute', inset: 0, zIndex: 40 }}>
      <div onClick={onClose} style={{ position: 'absolute', inset: 0, background: 'rgba(28,22,14,0.34)', animation: `ds-scrim-in .26s ${DS.motion.ease} backwards`, backdropFilter: 'blur(1px)' }} />
      <div style={{ position: 'absolute', left: 0, right: 0, bottom: 0, background: c.surface, borderRadius: `${DS.radius.xxl}px ${DS.radius.xxl}px 0 0`, padding: '12px 20px 22px', boxShadow: '0 -10px 40px rgba(28,22,14,0.18)', animation: `ds-sheet-in .38s ${DS.motion.spring} backwards` }}>
        <div style={{ width: 40, height: 4.5, borderRadius: 3, background: c.hair, margin: '0 auto 16px' }} />
        {title && <div style={{ fontSize: 19, fontWeight: 700, color: c.ink, letterSpacing: -0.3 }}>{title}</div>}
        {sub && <div style={{ fontSize: 13, color: c.sub, marginTop: 4, marginBottom: 4, lineHeight: 1.45 }}>{sub}</div>}
        <div style={{ marginTop: title ? 16 : 0 }}>{children}</div>
      </div>
    </div>
  );
}

// ── Section label ────────────────────────────────────────────
function SectionLabel({ children, style }) {
  return <div style={{ fontSize: 12, fontWeight: 700, letterSpacing: 0.5, color: DS.color.faint, textTransform: 'uppercase', ...style }}>{children}</div>;
}

// ── Card row (list item shell) ───────────────────────────────
function Card({ children, active, onClick, style, pad = 12 }) {
  const c = DS.color;
  return (
    <div className={onClick ? 'ds-press' : ''} onClick={onClick} style={{
      background: c.surface, border: `1px solid ${active ? c.accent + '66' : c.hair}`, borderRadius: DS.radius.md,
      padding: pad, boxShadow: active ? DS.shadow.accentSm : DS.shadow.sm, cursor: onClick ? 'pointer' : 'default',
      transition: `border-color .2s ease, box-shadow .2s ease`, ...style,
    }}>{children}</div>
  );
}

// ── Animated dots (thinking) ─────────────────────────────────
function Dots({ color = DS.color.accent, size = 7 }) {
  return (
    <span style={{ display: 'inline-flex', gap: 4, alignItems: 'center' }}>
      {[0, 1, 2].map((i) => <span key={i} style={{ width: size, height: size, borderRadius: size, background: color, animation: `ds-dot 1.2s ${i * 0.16}s infinite ${DS.motion.ease}` }} />)}
    </span>
  );
}

// ── Selection check circle ───────────────────────────────────
function CheckCircle({ on, size = 26, accent = DS.color.accent }) {
  const c = DS.color;
  return (
    <span style={{ width: size, height: size, borderRadius: size / 2, flexShrink: 0, background: on ? accent : 'transparent', border: on ? 'none' : `2px solid ${c.hair}`, display: 'flex', alignItems: 'center', justifyContent: 'center', transition: `background .18s ${DS.motion.ease}` }}>
      {on && <Icon name="checkSmall" size={size * 0.56} color="#fff" stroke={2.6} />}
    </span>
  );
}

// ── Pill chip ────────────────────────────────────────────────
function Pill({ children, icon, tone = 'neutral', style }) {
  const c = DS.color;
  const tones = {
    neutral: { bg: c.bgSunken, fg: c.sub },
    accent: { bg: c.accentSoft, fg: c.accentInk },
    success: { bg: c.successSoft, fg: c.success },
    warn: { bg: c.warnSoft, fg: c.warn },
    danger: { bg: c.dangerSoft, fg: c.danger },
  };
  const t = tones[tone];
  return (
    <span style={{ display: 'inline-flex', alignItems: 'center', gap: 5, padding: '5px 10px', borderRadius: DS.radius.pill, background: t.bg, color: t.fg, fontSize: 11.5, fontWeight: 650, lineHeight: 1, whiteSpace: 'nowrap', ...style }}>
      {icon && <Icon name={icon} size={13} color={t.fg} stroke={2} />}{children}
    </span>
  );
}

Object.assign(window, { DS, Button, TopBar, RightsNote, Sheet, SectionLabel, Card, Dots, CheckCircle, Pill });
