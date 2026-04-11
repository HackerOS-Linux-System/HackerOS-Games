import React, { useState } from 'react';
import { GameConfig, GameSettings } from '../types';
import { RESOLUTIONS } from '../constants';
import { Save, RotateCcw, Monitor, Volume2, Maximize2, ChevronRight } from 'lucide-react';

interface Props {
  games: GameConfig[];
  gameSettings: Record<string, GameSettings>;
  onSave: (gameId: string, settings: GameSettings) => void;
}

const DEFAULT: GameSettings = { fullscreen: false, resolution: '1920x1080', volume: 80 };

const SettingsSection: React.FC<Props> = ({ games, gameSettings, onSave }) => {
  const [sel, setSel] = useState(games[0]?.id ?? '');
  const [local, setLocal] = useState<Record<string, GameSettings>>(() =>
    Object.fromEntries(games.map(g => [g.id, gameSettings[g.id] ?? { ...DEFAULT }]))
  );
  const [saved, setSaved] = useState<string | null>(null);

  const game = games.find(g => g.id === sel);
  const cfg = local[sel] ?? { ...DEFAULT };

  const set = <K extends keyof GameSettings>(k: K, v: GameSettings[K]) =>
    setLocal(p => ({ ...p, [sel]: { ...p[sel], [k]: v } }));

  const save = () => {
    onSave(sel, cfg);
    setSaved(sel);
    setTimeout(() => setSaved(null), 2200);
  };

  const reset = () => setLocal(p => ({ ...p, [sel]: { ...DEFAULT } }));

  return (
    <div style={{ display: 'flex', height: '100%', overflow: 'hidden' }}>
      {/* Sidebar */}
      <div style={{
        width: '210px', borderRight: '1px solid var(--border)',
        background: 'rgba(0,0,0,0.35)', flexShrink: 0,
        overflowY: 'auto', padding: '12px',
      }}>
        <div style={{
          fontSize: '9px', color: 'var(--text-dim)', letterSpacing: '3px',
          padding: '4px 4px 10px', borderBottom: '1px solid var(--border)', marginBottom: '8px',
        }}>
          SELECT GAME
        </div>
        {games.map(g => (
          <button
            key={g.id}
            onClick={() => setSel(g.id)}
            style={{
              width: '100%', display: 'flex', alignItems: 'center', justifyContent: 'space-between',
              padding: '10px 10px', marginBottom: '3px',
              background: sel === g.id ? `rgba(${g.rgb},0.08)` : 'transparent',
              border: `1px solid ${sel === g.id ? g.color + '40' : 'transparent'}`,
              color: sel === g.id ? g.color : 'var(--text-dim)',
              cursor: 'pointer', fontSize: '11px',
              fontFamily: 'Share Tech Mono, monospace',
              letterSpacing: '1px', textAlign: 'left', transition: 'all 0.15s',
            }}
            onMouseEnter={e => {
              if (sel !== g.id) {
                const el = e.currentTarget as HTMLButtonElement;
                el.style.color = 'var(--text)';
                el.style.borderColor = 'var(--border)';
              }
            }}
            onMouseLeave={e => {
              if (sel !== g.id) {
                const el = e.currentTarget as HTMLButtonElement;
                el.style.color = 'var(--text-dim)';
                el.style.borderColor = 'transparent';
              }
            }}
          >
            {g.name}
            {sel === g.id && <ChevronRight size={11} />}
          </button>
        ))}
      </div>

      {/* Panel */}
      <div style={{ flex: 1, padding: '32px', overflowY: 'auto' }}>
        {game && (
          <>
            <div style={{ marginBottom: '28px' }}>
              <div style={{
                fontFamily: 'Orbitron, monospace', fontSize: '15px', fontWeight: 700,
                color: game.color, letterSpacing: '3px', textTransform: 'uppercase',
                marginBottom: '4px', textShadow: `0 0 10px rgba(${game.rgb},0.4)`,
              }}>
                {game.name}
              </div>
              <div style={{ fontSize: '9px', color: 'var(--text-dim)', letterSpacing: '2px' }}>
                LAUNCH SETTINGS — applied on next game start
              </div>
            </div>

            <div style={{ maxWidth: '480px', display: 'flex', flexDirection: 'column', gap: '14px' }}>

              {/* Fullscreen */}
              <Card icon={<Maximize2 size={14} />} title="Fullscreen" desc="Start the game in full screen." color={game.color}>
                <div style={{ display: 'flex', gap: '6px' }}>
                  {['Off', 'On'].map((label, i) => {
                    const active = cfg.fullscreen === (i === 1);
                    return (
                      <Btn key={label} active={active} color={game.color} rgb={game.rgb} onClick={() => set('fullscreen', i === 1)}>
                        {label}
                      </Btn>
                    );
                  })}
                </div>
              </Card>

              {/* Resolution */}
              <Card icon={<Monitor size={14} />} title="Resolution" desc="Target resolution." color={game.color}>
                <div style={{ display: 'flex', flexWrap: 'wrap', gap: '5px' }}>
                  {RESOLUTIONS.map(r => (
                    <Btn key={r} active={cfg.resolution === r} color={game.color} rgb={game.rgb} onClick={() => set('resolution', r)}>
                      {r}
                    </Btn>
                  ))}
                </div>
              </Card>

              {/* Volume */}
              <Card icon={<Volume2 size={14} />} title="Volume" desc={`Master volume: ${cfg.volume}%`} color={game.color}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '14px' }}>
                  <input
                    type="range" min={0} max={100} value={cfg.volume}
                    onChange={e => set('volume', Number(e.target.value))}
                    style={{ width: '180px', accentColor: game.color, cursor: 'pointer' }}
                  />
                  <span style={{
                    fontFamily: 'Orbitron, monospace', fontSize: '16px',
                    fontWeight: 700, color: game.color, minWidth: '40px',
                  }}>
                    {cfg.volume}%
                  </span>
                </div>
              </Card>

              {/* Actions */}
              <div style={{ display: 'flex', gap: '10px', marginTop: '6px' }}>
                <button
                  onClick={save}
                  style={{
                    display: 'flex', alignItems: 'center', gap: '7px',
                    padding: '10px 22px',
                    background: saved === sel ? `rgba(${game.rgb},0.2)` : `rgba(${game.rgb},0.08)`,
                    border: `1px solid ${game.color}`,
                    color: game.color, cursor: 'pointer',
                    fontSize: '11px', fontFamily: 'Share Tech Mono, monospace',
                    letterSpacing: '2px', textTransform: 'uppercase', transition: 'all 0.2s',
                    boxShadow: saved === sel ? `0 0 14px rgba(${game.rgb},0.3)` : 'none',
                  }}
                >
                  <Save size={12} />
                  {saved === sel ? 'SAVED!' : 'SAVE'}
                </button>
                <button
                  onClick={reset}
                  style={{
                    display: 'flex', alignItems: 'center', gap: '7px',
                    padding: '10px 18px', background: 'transparent',
                    border: '1px solid #2a2a2a', color: 'var(--text-dim)', cursor: 'pointer',
                    fontSize: '11px', fontFamily: 'Share Tech Mono, monospace',
                    letterSpacing: '2px', textTransform: 'uppercase', transition: 'all 0.15s',
                  }}
                  onMouseEnter={e => {
                    const el = e.currentTarget as HTMLButtonElement;
                    el.style.borderColor = 'var(--text-dim)';
                    el.style.color = 'var(--text)';
                  }}
                  onMouseLeave={e => {
                    const el = e.currentTarget as HTMLButtonElement;
                    el.style.borderColor = '#2a2a2a';
                    el.style.color = 'var(--text-dim)';
                  }}
                >
                  <RotateCcw size={12} /> RESET
                </button>
              </div>

              <p style={{ fontSize: '10px', color: 'var(--text-dim)', lineHeight: '1.7', marginTop: '4px' }}>
                Settings are passed as launch flags where supported by each game.
                Not all games honour every option.
              </p>
            </div>
          </>
        )}
      </div>
    </div>
  );
};

const Card: React.FC<{ icon: React.ReactNode; title: string; desc: string; color: string; children: React.ReactNode }> =
  ({ icon, title, desc, color, children }) => (
    <div style={{ background: 'var(--surface)', border: '1px solid var(--border)', padding: '18px' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: '7px', marginBottom: '5px' }}>
        <span style={{ color }}>{icon}</span>
        <span style={{
          fontFamily: 'Orbitron, monospace', fontSize: '11px', fontWeight: 700,
          color: 'var(--text)', letterSpacing: '2px',
        }}>
          {title.toUpperCase()}
        </span>
      </div>
      <div style={{ fontSize: '10px', color: 'var(--text-dim)', letterSpacing: '1px', marginBottom: '12px' }}>{desc}</div>
      {children}
    </div>
  );

const Btn: React.FC<{
  active: boolean; color: string; rgb: string;
  onClick: () => void; children: React.ReactNode;
}> = ({ active, color, rgb, onClick, children }) => (
  <button
    onClick={onClick}
    style={{
      padding: '5px 14px',
      background: active ? `rgba(${rgb},0.14)` : 'transparent',
      border: `1px solid ${active ? color : '#2a2a2a'}`,
      color: active ? color : 'var(--text-dim)',
      cursor: 'pointer', fontSize: '10px',
      fontFamily: 'Share Tech Mono, monospace',
      letterSpacing: '1px', transition: 'all 0.15s',
    }}
    onMouseEnter={e => {
      if (!active) {
        const el = e.currentTarget as HTMLButtonElement;
        el.style.borderColor = '#444';
        el.style.color = 'var(--text)';
      }
    }}
    onMouseLeave={e => {
      if (!active) {
        const el = e.currentTarget as HTMLButtonElement;
        el.style.borderColor = '#2a2a2a';
        el.style.color = 'var(--text-dim)';
      }
    }}
  >
    {children}
  </button>
);

export default SettingsSection;
