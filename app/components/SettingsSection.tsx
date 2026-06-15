import React, { useState } from 'react';
import { GameConfig, GameSettings, AppSettings } from '../types';
import { RESOLUTIONS, LANGUAGES, ACCENT_PRESETS, DEFAULT_GAME_SETTINGS, hexToRgb } from '../constants';
import {
  Save, RotateCcw, Monitor, Volume2, Maximize2, ChevronRight,
  SlidersHorizontal, Sparkles, Globe, Palette, PowerOff, Puzzle, Terminal,
} from 'lucide-react';

interface Props {
  games: GameConfig[];
  gameSettings: Record<string, GameSettings>;
  appSettings: AppSettings;
  onSaveGame: (gameId: string, settings: GameSettings) => void;
  onSaveApp: (settings: AppSettings) => void;
}

const GENERAL = '__general__';

const SettingsSection: React.FC<Props> = ({ games, gameSettings, appSettings, onSaveGame, onSaveApp }) => {
  const [sel, setSel] = useState<string>(GENERAL);
  const [local, setLocal] = useState<Record<string, GameSettings>>(() =>
  Object.fromEntries(games.map(g => [g.id, gameSettings[g.id] ?? { ...DEFAULT_GAME_SETTINGS }]))
  );
  const [localApp, setLocalApp] = useState<AppSettings>(appSettings);
  const [saved, setSaved] = useState<string | null>(null);

  const game = games.find(g => g.id === sel);
  const cfg = local[sel] ?? { ...DEFAULT_GAME_SETTINGS };

  const set = <K extends keyof GameSettings>(k: K, v: GameSettings[K]) =>
  setLocal(p => ({ ...p, [sel]: { ...(p[sel] ?? DEFAULT_GAME_SETTINGS), [k]: v } }));

  const setApp = <K extends keyof AppSettings>(k: K, v: AppSettings[K]) =>
  setLocalApp(p => ({ ...p, [k]: v }));

  const save = () => {
    if (sel === GENERAL) {
      onSaveApp(localApp);
    } else {
      onSaveGame(sel, cfg);
    }
    setSaved(sel);
    setTimeout(() => setSaved(null), 2200);
  };

  const reset = () => {
    if (sel === GENERAL) setLocalApp(appSettings);
    else setLocal(p => ({ ...p, [sel]: { ...DEFAULT_GAME_SETTINGS } }));
  };

  const accentColor = sel === GENERAL ? localApp.accentColor : (game?.color ?? 'var(--accent)');
  const accentRgb = sel === GENERAL ? hexToRgb(localApp.accentColor) : (game?.rgb ?? '42,143,255');

  return (
    <div style={{ display: 'flex', height: '100%', overflow: 'hidden' }}>
    {/* Sidebar */}
    <div style={{
      width: '210px', borderRight: '1px solid var(--border)',
          background: 'rgba(0,0,0,0.35)', flexShrink: 0,
          overflowY: 'auto', padding: '12px',
    }}>
    <SidebarBtn
    label="General"
    icon={<SlidersHorizontal size={12} />}
    active={sel === GENERAL}
    color="var(--accent)"
    rgb="42,143,255"
    onClick={() => setSel(GENERAL)}
    />

    <div style={{
      fontSize: '9px', color: 'var(--text-dim)', letterSpacing: '3px',
          padding: '14px 4px 10px', borderBottom: '1px solid var(--border)', marginBottom: '8px',
          borderTop: '1px solid var(--border)', marginTop: '10px',
    }}>
    SELECT GAME
    </div>
    {games.map(g => (
      <SidebarBtn
      key={g.id}
      label={g.name}
      active={sel === g.id}
      color={g.color}
      rgb={g.rgb}
      onClick={() => setSel(g.id)}
      />
    ))}
    </div>

    {/* Panel */}
    <div style={{ flex: 1, padding: '32px', overflowY: 'auto' }}>
    {sel === GENERAL && (
      <>
      <div style={{ marginBottom: '28px' }}>
      <div style={{
        fontFamily: 'Orbitron, monospace', fontSize: '15px', fontWeight: 700,
        color: 'var(--accent)', letterSpacing: '3px', textTransform: 'uppercase',
                         marginBottom: '4px', textShadow: '0 0 10px rgba(var(--accent-rgb),0.4)',
      }}>
      General
      </div>
      <div style={{ fontSize: '9px', color: 'var(--text-dim)', letterSpacing: '2px' }}>
      APPLICATION PREFERENCES — applied across HackerOS Games
      </div>
      </div>

      <div style={{ maxWidth: '480px', display: 'flex', flexDirection: 'column', gap: '14px' }}>

      {/* Language */}
      <Card icon={<Globe size={14} />} title="Language" desc="Interface and date/time language." color={accentColor}>
      <div style={{ display: 'flex', gap: '6px' }}>
      {LANGUAGES.map(l => (
        <Btn key={l.id} active={localApp.language === l.id} color={accentColor} rgb={accentRgb} onClick={() => setApp('language', l.id)}>
        {l.label}
        </Btn>
      ))}
      </div>
      </Card>

      {/* Particles */}
      <Card icon={<Sparkles size={14} />} title="Background Particles" desc="Animated particle field behind the UI." color={accentColor}>
      <div style={{ display: 'flex', gap: '6px' }}>
      {['Off', 'On'].map((label, i) => {
        const active = localApp.particlesEnabled === (i === 1);
        return (
          <Btn key={label} active={active} color={accentColor} rgb={accentRgb} onClick={() => setApp('particlesEnabled', i === 1)}>
          {label}
          </Btn>
        );
      })}
      </div>
      </Card>

      {/* Close button behaviour */}
      <Card icon={<PowerOff size={14} />} title="Close Button" desc="What the titlebar close button does." color={accentColor}>
      <div style={{ display: 'flex', gap: '6px' }}>
      {[
        { label: 'Quit App', value: false },
        { label: 'Minimize', value: true },
      ].map(opt => (
        <Btn key={opt.label} active={localApp.minimizeOnClose === opt.value} color={accentColor} rgb={accentRgb} onClick={() => setApp('minimizeOnClose', opt.value)}>
        {opt.label}
        </Btn>
      ))}
      </div>
      </Card>

      {/* Addon auto-check */}
      <Card icon={<Puzzle size={14} />} title="Addon Auto-Detect" desc="Re-check addon installation whenever the Addons tab opens." color={accentColor}>
      <div style={{ display: 'flex', gap: '6px' }}>
      {['Off', 'On'].map((label, i) => {
        const active = localApp.autoCheckAddons === (i === 1);
        return (
          <Btn key={label} active={active} color={accentColor} rgb={accentRgb} onClick={() => setApp('autoCheckAddons', i === 1)}>
          {label}
          </Btn>
        );
      })}
      </div>
      </Card>

      {/* Accent color */}
      <Card icon={<Palette size={14} />} title="Accent Color" desc="Tints the UI, logo and particle field." color={accentColor}>
      <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px' }}>
      {ACCENT_PRESETS.map(p => {
        const active = localApp.accentColor.toLowerCase() === p.hex.toLowerCase();
        return (
          <button
          key={p.hex}
          onClick={() => setApp('accentColor', p.hex)}
          title={p.name}
          style={{
            width: '28px', height: '28px',
            background: p.hex,
            border: active ? '2px solid var(--text)' : '1px solid #2a2a2a',
                boxShadow: active ? `0 0 10px rgba(${p.rgb},0.6)` : 'none',
                cursor: 'pointer', transition: 'all 0.15s',
          }}
          />
        );
      })}
      </div>
      </Card>

      <Actions
      color={accentColor} rgb={accentRgb}
      saved={saved === GENERAL}
      onSave={save} onReset={reset}
      />

      <p style={{ fontSize: '10px', color: 'var(--text-dim)', lineHeight: '1.7', marginTop: '4px' }}>
      General preferences are stored alongside per-game configuration and restored next time
      HackerOS Games launches.
      </p>
      </div>
      </>
    )}

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

      {/* Launch arguments */}
      <Card icon={<Terminal size={14} />} title="Launch Arguments" desc="Extra command-line flags passed to the game binary." color={game.color}>
      <input
      value={cfg.launchArgs}
      onChange={e => set('launchArgs', e.target.value)}
      placeholder="e.g. --debug --no-vsync"
      style={{
        width: '100%', padding: '8px 10px',
        background: 'var(--bg)', border: '1px solid var(--border)',
              color: 'var(--text)', fontSize: '11px',
              fontFamily: 'Share Tech Mono, monospace', outline: 'none',
      }}
      onFocus={e => { e.currentTarget.style.borderColor = game.color; }}
      onBlur={e => { e.currentTarget.style.borderColor = 'var(--border)'; }}
      />
      </Card>

      <Actions
      color={game.color} rgb={game.rgb}
      saved={saved === sel}
      onSave={save} onReset={reset}
      />

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

const SidebarBtn: React.FC<{
  label: string; icon?: React.ReactNode; active: boolean;
  color: string; rgb: string; onClick: () => void;
}> = ({ label, icon, active, color, rgb, onClick }) => (
  <button
  onClick={onClick}
  style={{
    width: '100%', display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: '8px',
    padding: '10px 10px', marginBottom: '3px',
    background: active ? `rgba(${rgb},0.08)` : 'transparent',
                                                        border: `1px solid ${active ? color + '40' : 'transparent'}`,
                                                        color: active ? color : 'var(--text-dim)',
                                                        cursor: 'pointer', fontSize: '11px',
                                                        fontFamily: 'Share Tech Mono, monospace',
                                                        letterSpacing: '1px', textAlign: 'left', transition: 'all 0.15s',
  }}
  onMouseEnter={e => {
    if (!active) {
      const el = e.currentTarget as HTMLButtonElement;
      el.style.color = 'var(--text)';
      el.style.borderColor = 'var(--border)';
    }
  }}
  onMouseLeave={e => {
    if (!active) {
      const el = e.currentTarget as HTMLButtonElement;
      el.style.color = 'var(--text-dim)';
      el.style.borderColor = 'transparent';
    }
  }}
  >
  <span style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
  {icon}{label}
  </span>
  {active && <ChevronRight size={11} />}
  </button>
);

const Actions: React.FC<{
  color: string; rgb: string; saved: boolean;
  onSave: () => void; onReset: () => void;
}> = ({ color, rgb, saved, onSave, onReset }) => (
  <div style={{ display: 'flex', gap: '10px', marginTop: '6px' }}>
  <button
  onClick={onSave}
  style={{
    display: 'flex', alignItems: 'center', gap: '7px',
    padding: '10px 22px',
    background: saved ? `rgba(${rgb},0.2)` : `rgba(${rgb},0.08)`,
                                                  border: `1px solid ${color}`,
                                                  color, cursor: 'pointer',
                                                  fontSize: '11px', fontFamily: 'Share Tech Mono, monospace',
                                                  letterSpacing: '2px', textTransform: 'uppercase', transition: 'all 0.2s',
                                                  boxShadow: saved ? `0 0 14px rgba(${rgb},0.3)` : 'none',
  }}
  >
  <Save size={12} />
  {saved ? 'SAVED!' : 'SAVE'}
  </button>
  <button
  onClick={onReset}
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
);

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
