// Design-system reference doc. Self-contained renderer using DS primitives.

function Swatch({ name, value, dark }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
      <div style={{ height: 56, borderRadius: 12, background: value, border: '1px solid rgba(0,0,0,0.08)' }} />
      <div>
        <div style={{ fontSize: 12.5, fontWeight: 650, color: DS.color.ink }}>{name}</div>
        <div style={{ fontSize: 11, color: DS.color.faint, fontFamily: DS.font.mono }}>{value}</div>
      </div>
    </div>
  );
}

function DocSection({ title, kicker, children }) {
  const c = DS.color;
  return (
    <section style={{ marginBottom: 44 }}>
      <div style={{ fontSize: 12, fontWeight: 700, letterSpacing: 1.4, color: c.accent, textTransform: 'uppercase', marginBottom: 6 }}>{kicker}</div>
      <h2 style={{ fontSize: 24, fontWeight: 700, letterSpacing: -0.5, color: c.ink, margin: '0 0 22px' }}>{title}</h2>
      {children}
    </section>
  );
}

function Panel({ children, style }) {
  return <div style={{ background: DS.color.surface, border: `1px solid ${DS.color.hair}`, borderRadius: DS.radius.lg, padding: 24, boxShadow: DS.shadow.sm, ...style }}>{children}</div>;
}

function Label({ children }) {
  return <div style={{ fontSize: 11, fontWeight: 700, letterSpacing: 0.6, color: DS.color.faint, textTransform: 'uppercase', marginBottom: 12 }}>{children}</div>;
}

function DocToggle({ on }) {
  const c = DS.color;
  const [v, setV] = React.useState(on);
  return (
    <button onClick={() => setV(!v)} style={{ width: 46, height: 28, borderRadius: 14, border: 'none', background: v ? c.accent : c.hair, position: 'relative', cursor: 'pointer', transition: 'background .2s ease' }}>
      <span style={{ position: 'absolute', top: 3, left: v ? 21 : 3, width: 22, height: 22, borderRadius: 11, background: '#fff', boxShadow: '0 1px 3px rgba(0,0,0,0.2)', transition: `left .22s ${DS.motion.spring}` }} />
    </button>
  );
}

function TypeRow({ size, weight, label, sample, mono }) {
  return (
    <div style={{ display: 'flex', alignItems: 'baseline', gap: 18, padding: '12px 0', borderBottom: `1px solid ${DS.color.hair2}` }}>
      <div style={{ width: 150, flexShrink: 0 }}>
        <div style={{ fontSize: 13, fontWeight: 650, color: DS.color.ink }}>{label}</div>
        <div style={{ fontSize: 11.5, color: DS.color.faint, fontFamily: DS.font.mono }}>{size}px · {weight}</div>
      </div>
      <div style={{ fontSize: size, fontWeight: weight, color: DS.color.ink, letterSpacing: size > 20 ? -0.5 : 0, fontFamily: mono ? DS.font.mono : DS.font.sans, lineHeight: 1.2 }}>{sample}</div>
    </div>
  );
}

function Docs() {
  const c = DS.color;
  return (
    <div style={{ minHeight: '100%', background: c.bg, fontFamily: DS.font.sans, padding: '0 0 80px' }}>
      {/* header */}
      <div style={{ maxWidth: 980, margin: '0 auto', padding: '44px 32px 0' }}>
        <a href="Quietly — Interactive Prototype.html" style={{ display: 'inline-flex', alignItems: 'center', gap: 7, fontSize: 13.5, fontWeight: 600, color: c.accent, textDecoration: 'none', marginBottom: 26 }}>
          <Icon name="chevronLeft" size={17} color={c.accent} />Back to prototype
        </a>
        <div style={{ display: 'flex', alignItems: 'center', gap: 14, marginBottom: 14 }}>
          <div style={{ width: 52, height: 52, borderRadius: 15, background: c.accent, display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: DS.shadow.accentSm }}><Icon name="download" size={26} color="#fff" stroke={2.2} /></div>
          <div>
            <h1 style={{ fontSize: 34, fontWeight: 800, letterSpacing: -1, color: c.ink, margin: 0, lineHeight: 1 }}>Quietly Design System</h1>
            <div style={{ fontSize: 14.5, color: c.sub, marginTop: 6 }}>Calm, trustworthy mobile utility · hybrid direction A</div>
          </div>
        </div>
        <p style={{ fontSize: 15, color: c.sub, lineHeight: 1.6, maxWidth: 680, marginTop: 16 }}>
          A restrained, premium system for a rights-aware media saver. Architecture follows <strong style={{ color: c.ink }}>Direction A</strong> (single-focus wizard), with explainable microcopy, a lightweight queue, and subtle motion polish. Built on Flutter-friendly primitives: one accent, generous space, bottom-sheet-driven actions, one-thumb reach.
        </p>
      </div>

      <div style={{ maxWidth: 980, margin: '0 auto', padding: '40px 32px 0' }}>
        {/* COLOR */}
        <DocSection kicker="Foundations" title="Color">
          <Panel style={{ marginBottom: 16 }}>
            <Label>Surfaces & ink (warm neutrals)</Label>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 16 }}>
              <Swatch name="Canvas" value={c.bg} /><Swatch name="Sunken" value={c.bgSunken} /><Swatch name="Surface" value={c.surface} /><Swatch name="Hairline" value="#E9E5DD" />
              <Swatch name="Ink" value={c.ink} /><Swatch name="Sub" value={c.sub} /><Swatch name="Faint" value={c.faint} /><Swatch name="On accent" value={c.onAccent} />
            </div>
          </Panel>
          <div style={{ display: 'grid', gridTemplateColumns: '1.4fr 1fr', gap: 16 }}>
            <Panel>
              <Label>Accent · Indigo (single confident primary)</Label>
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 16 }}>
                <Swatch name="Accent" value={c.accent} /><Swatch name="Press" value={c.accentPress} /><Swatch name="Soft" value={c.accentSoft} /><Swatch name="Ink" value={c.accentInk} />
              </div>
            </Panel>
            <Panel>
              <Label>Status (used sparingly)</Label>
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 16 }}>
                <Swatch name="Success" value={c.success} /><Swatch name="Warn" value={c.warn} /><Swatch name="Danger" value={c.danger} />
              </div>
            </Panel>
          </div>
        </DocSection>

        {/* TYPE */}
        <DocSection kicker="Foundations" title="Typography">
          <Panel>
            <TypeRow size={28} weight={700} label="Display" sample="Paste a link" />
            <TypeRow size={21} weight={700} label="Title" sample="Available media" />
            <TypeRow size={17} weight={650} label="Headline" sample="Saving video…" />
            <TypeRow size={15} weight={400} label="Body" sample="We’ll check what’s public." />
            <TypeRow size={13} weight={500} label="Caption" sample="≈ 24 MB · tap to change" />
            <TypeRow size={12.5} weight={600} label="Mono · meta" sample="share.example.com/p/8fa2c" mono />
          </Panel>
          <p style={{ fontSize: 13, color: c.sub, marginTop: 12, lineHeight: 1.5 }}>System sans for everything human; monospace reserved for URLs, file names, codecs, and sizes — it reads as “technically competent” without feeling like a hacker tool.</p>
        </DocSection>

        {/* SPACING / RADII / ELEVATION / MOTION */}
        <DocSection kicker="Foundations" title="Shape, elevation & motion">
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16 }}>
            <Panel>
              <Label>Radii</Label>
              <div style={{ display: 'flex', gap: 14, alignItems: 'flex-end' }}>
                {[['sm', 10], ['md', 14], ['lg', 18], ['xl', 22], ['xxl', 28]].map(([n, r]) => (
                  <div key={n} style={{ textAlign: 'center' }}>
                    <div style={{ width: 54, height: 54, background: c.accentSoft, border: `1.5px solid ${c.accent}`, borderRadius: r, borderBottomLeftRadius: 0, borderBottomRightRadius: 0 }} />
                    <div style={{ fontSize: 11, color: c.faint, marginTop: 6, fontFamily: DS.font.mono }}>{n}·{r}</div>
                  </div>
                ))}
              </div>
            </Panel>
            <Panel>
              <Label>Elevation</Label>
              <div style={{ display: 'flex', gap: 18 }}>
                {[['sm', DS.shadow.sm], ['md', DS.shadow.md], ['lg', DS.shadow.lg]].map(([n, s]) => (
                  <div key={n} style={{ textAlign: 'center' }}>
                    <div style={{ width: 64, height: 48, background: c.surface, borderRadius: 12, boxShadow: s }} />
                    <div style={{ fontSize: 11, color: c.faint, marginTop: 8, fontFamily: DS.font.mono }}>{n}</div>
                  </div>
                ))}
              </div>
            </Panel>
          </div>
          <Panel style={{ marginTop: 16 }}>
            <Label>Motion</Label>
            <div style={{ display: 'flex', gap: 28, flexWrap: 'wrap', fontSize: 13, color: c.ink }}>
              <div><div style={{ fontWeight: 650 }}>Decel ease</div><div style={{ fontSize: 11.5, color: c.faint, fontFamily: DS.font.mono }}>cubic-bezier(.22,.61,.36,1)</div><div style={{ fontSize: 12, color: c.sub, marginTop: 2 }}>screens · lists</div></div>
              <div><div style={{ fontWeight: 650 }}>Gentle spring</div><div style={{ fontSize: 11.5, color: c.faint, fontFamily: DS.font.mono }}>cubic-bezier(.34,1.3,.5,1)</div><div style={{ fontSize: 12, color: c.sub, marginTop: 2 }}>sheets · success</div></div>
              <div><div style={{ fontWeight: 650 }}>Durations</div><div style={{ fontSize: 11.5, color: c.faint, fontFamily: DS.font.mono }}>180 / 260 / 380ms</div><div style={{ fontSize: 12, color: c.sub, marginTop: 2 }}>fast · base · slow</div></div>
            </div>
          </Panel>
        </DocSection>

        {/* COMPONENTS */}
        <DocSection kicker="Library" title="Components">
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16 }}>
            <Panel>
              <Label>Buttons</Label>
              <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
                <Button icon="download">Primary</Button>
                <Button variant="soft" icon="paste">Soft</Button>
                <div style={{ display: 'flex', gap: 10 }}>
                  <Button variant="outline" full={false} size="md">Outline</Button>
                  <Button variant="ghost" full={false} size="md">Ghost</Button>
                </div>
              </div>
            </Panel>
            <Panel>
              <Label>Chips · status tones</Label>
              <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8 }}>
                <Pill tone="accent" icon="layers">Carousel</Pill>
                <Pill tone="success" icon="shield">Public</Pill>
                <Pill tone="warn" icon="alert">Low space</Pill>
                <Pill tone="danger" icon="lock">Protected</Pill>
                <Pill icon="globe">example.com</Pill>
              </div>
              <Label style={{ marginTop: 20 }}>Selection & toggle</Label>
              <div style={{ display: 'flex', alignItems: 'center', gap: 16 }}>
                <CheckCircle on={true} /><CheckCircle on={false} /><DocToggle on={true} /><DocToggle on={false} />
              </div>
            </Panel>
            <Panel>
              <Label>Progress</Label>
              <div style={{ display: 'flex', alignItems: 'center', gap: 22 }}>
                <Ring size={72} stroke={7} pct={62} color={c.accent} track={c.hair}><span style={{ fontSize: 15, fontWeight: 700, color: c.ink }}>62%</span></Ring>
                <div style={{ flex: 1 }}>
                  <Bar pct={62} color={c.accent} track={c.bgSunken} height={6} />
                  <div style={{ fontSize: 11.5, color: c.faint, marginTop: 8, fontFamily: DS.font.mono }}>14.9 / 24 MB · 3.2 MB/s</div>
                </div>
              </div>
            </Panel>
            <Panel>
              <Label>Media placeholder</Label>
              <div style={{ display: 'flex', gap: 10 }}>
                <div style={{ width: 80 }}><MediaTile kind="video" tone="cool" radius={12} aspect="1" label="video" /></div>
                <div style={{ width: 80 }}><MediaTile kind="image" tone="neutral" radius={12} aspect="1" /></div>
                <div style={{ width: 80 }}><MediaTile kind="video" tone="cool" radius={12} aspect="1" locked /></div>
              </div>
              <div style={{ fontSize: 12, color: c.sub, marginTop: 10, lineHeight: 1.5 }}>Abstract, low-chroma blocks — never real platform content.</div>
            </Panel>
          </div>
        </DocSection>

        {/* PRINCIPLES */}
        <DocSection kicker="Principles" title="Trust & async patterns">
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16 }}>
            {[
              ['shield', 'Rights-aware by default', 'Every save action carries a plain-language note. Protected, private, and DRM content is explained — never bypassed.'],
              ['search', 'Explainable analysis', 'The analyzing state shows real steps (“reaching the page · checking it’s public”) so the wait feels honest, not magical.'],
              ['layers', 'Clear multi-media', 'Carousels become scannable checklists with per-item size and a live selected count — no dense grids to decode.'],
              ['clock', 'Lightweight queue & history', 'Multiple saves run in a simple per-file queue; everything kept lands in a calm, day-grouped history.'],
            ].map(([ic, t, b], i) => (
              <Panel key={i}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 10 }}>
                  <div style={{ width: 34, height: 34, borderRadius: 10, background: c.accentSoft, display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Icon name={ic} size={18} color={c.accent} /></div>
                  <div style={{ fontSize: 15, fontWeight: 700, color: c.ink }}>{t}</div>
                </div>
                <div style={{ fontSize: 13, color: c.sub, lineHeight: 1.55 }}>{b}</div>
              </Panel>
            ))}
          </div>
        </DocSection>
      </div>
    </div>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<Docs />);
