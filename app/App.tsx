import React, { useState, useEffect, useCallback, useRef } from 'react';
import { invoke } from '@tauri-apps/api/core';
import { Window } from '@tauri-apps/api/window';
import { GAMES, ADDONS } from './constants';
import { GamePlaytime, GameSettings, NavSection } from './types';
import GamesSection from './components/GamesSection';
import AddonsSection from './components/AddonsSection';
import SettingsSection from './components/SettingsSection';
import ParticlesBackground from './components/ParticlesBackground';
import { Gamepad2, Puzzle, Settings, Info, Minus, Square, X } from 'lucide-react';

const isTauri = () => '__TAURI_INTERNALS__' in window;

const winMinimize = () => { if (isTauri()) new Window('main').minimize(); };
const winMaximize = () => { if (isTauri()) new Window('main').toggleMaximize(); };
const winClose    = () => { if (isTauri()) new Window('main').close(); };

// ── Playtime tracker ─────────────────────────────────────────────────────────
// For each launched game we record the wall-clock start time.
// Every TICK_MS we compute elapsed seconds and call record_playtime on the backend.
const TICK_MS = 15_000; // sync every 15 s

function usePlaytimeTracker(
  playtime: Record<string, GamePlaytime>,
  setPlaytime: React.Dispatch<React.SetStateAction<Record<string, GamePlaytime>>>
) {
  // gameId → unix-ms when launch was registered this session
  const sessionStarts = useRef<Record<string, number>>({});
  // last amount flushed to backend per game
  const flushed = useRef<Record<string, number>>({});

  // Flush a game's elapsed time to the Rust backend + local state
  const flush = useCallback(async (gameId: string) => {
    const start = sessionStarts.current[gameId];
    if (!start) return;
    const elapsed = Math.floor((Date.now() - start) / 1000);
    const alreadyFlushed = flushed.current[gameId] ?? 0;
    const delta = elapsed - alreadyFlushed;
    if (delta < 1) return;

    flushed.current[gameId] = elapsed;

    // Optimistic UI update
    setPlaytime(prev => {
      const old = prev[gameId];
      if (!old) return prev;
      return {
        ...prev,
        [gameId]: { ...old, total_seconds: old.total_seconds + delta },
      };
    });

    // Persist to disk via Tauri
    if (isTauri()) {
      await invoke('record_playtime', { gameId, seconds: delta }).catch(() => {});
    }
  }, [setPlaytime]);

  // Register a new launch
  const trackLaunch = useCallback((gameId: string) => {
    sessionStarts.current[gameId] = Date.now();
    flushed.current[gameId] = 0;

    // Increment session count + set last_played immediately in UI
    const now = Math.floor(Date.now() / 1000);
    setPlaytime(prev => ({
      ...prev,
      [gameId]: {
        game_id: gameId,
        total_seconds: prev[gameId]?.total_seconds ?? 0,
        last_played: now,
        sessions: (prev[gameId]?.sessions ?? 0) + 1,
      },
    }));
  }, [setPlaytime]);

  // Periodic flush ticker
  useEffect(() => {
    const id = setInterval(() => {
      for (const gameId of Object.keys(sessionStarts.current)) {
        flush(gameId);
      }
    }, TICK_MS);
    return () => clearInterval(id);
  }, [flush]);

  // Flush everything when tab/window loses focus or unloads
  useEffect(() => {
    const onBlur = () => {
      for (const gameId of Object.keys(sessionStarts.current)) flush(gameId);
    };
      window.addEventListener('blur', onBlur);
      window.addEventListener('beforeunload', onBlur);
      return () => {
        window.removeEventListener('blur', onBlur);
        window.removeEventListener('beforeunload', onBlur);
      };
  }, [flush]);

  return { trackLaunch };
}

// ── App ───────────────────────────────────────────────────────────────────────

const App: React.FC = () => {
  const [activeSection, setActiveSection] = useState<NavSection>('games');
  const [playtime, setPlaytime]           = useState<Record<string, GamePlaytime>>({});
  const [gameSettings, setGameSettings]   = useState<Record<string, GameSettings>>({});
  const [clock, setClock]                 = useState(new Date());

  const { trackLaunch } = usePlaytimeTracker(playtime, setPlaytime);

  // Load persisted data on mount
  useEffect(() => {
    if (!isTauri()) return;
    invoke<Record<string, GamePlaytime>>('get_all_playtime')
    .then(setPlaytime).catch(() => {});
    invoke<Record<string, GameSettings>>('get_all_game_settings')
    .then(setGameSettings).catch(() => {});
  }, []);

  // Clock
  useEffect(() => {
    const id = setInterval(() => setClock(new Date()), 1000);
    return () => clearInterval(id);
  }, []);

  const handleGameLaunch = useCallback((gameId: string) => {
    trackLaunch(gameId);
  }, [trackLaunch]);

  const handleSaveSettings = useCallback(async (gameId: string, settings: GameSettings) => {
    setGameSettings(prev => ({ ...prev, [gameId]: settings }));
    if (isTauri()) {
      await invoke('save_game_settings', { gameId, settings }).catch(() => {});
    }
  }, []);

  const navItems: { id: NavSection; label: string; icon: React.ReactNode }[] = [
    { id: 'games',    label: 'Library',  icon: <Gamepad2 size={13} /> },
    { id: 'addons',   label: 'Addons',   icon: <Puzzle size={13} /> },
    { id: 'settings', label: 'Settings', icon: <Settings size={13} /> },
    { id: 'about',    label: 'About',    icon: <Info size={13} /> },
  ];

  const timeStr = clock.toLocaleTimeString('pl-PL', {
    hour: '2-digit', minute: '2-digit', second: '2-digit',
  });

  const winBtns = [
    { icon: <Minus size={11} />,  action: winMinimize, color: '#ffd600', label: 'minimize' },
    { icon: <Square size={10} />, action: winMaximize, color: '#00cfff', label: 'maximize' },
    { icon: <X size={11} />,      action: winClose,    color: '#ff1744', label: 'close'    },
  ];

  return (
    <div
    className="scanlines crt-vignette"
    style={{ height: '100vh', display: 'flex', flexDirection: 'column', background: 'var(--bg)', position: 'relative' }}
    >
    <ParticlesBackground />

    {/* ── Title bar ── */}
    <div
    data-tauri-drag-region
    style={{
      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      height: '40px', padding: '0 12px',
      background: 'rgba(3,5,8,0.97)',
          borderBottom: '1px solid #0d1a0d',
          flexShrink: 0, position: 'relative', zIndex: 100,
    }}
    >
    {/* Logo — pointer-events none so drag region works */}
    <div style={{ display: 'flex', alignItems: 'center', gap: '10px', pointerEvents: 'none' }}>
    <div style={{
      width: '8px', height: '8px', borderRadius: '50%',
      background: 'var(--green)',
          animation: 'pulse-green 2s ease-in-out infinite',
    }} />
    <span style={{
      fontFamily: 'Orbitron, monospace', fontSize: '12px', fontWeight: 900,
      color: 'var(--green)', letterSpacing: '4px', textTransform: 'uppercase',
          textShadow: '0 0 12px rgba(0,255,65,0.5)',
    }}>
    HACKEROS<span style={{ color: 'var(--text-dim)', fontWeight: 400, marginLeft: '6px' }}>GAMES</span>
    </span>
    <span style={{ fontSize: '9px', color: 'var(--text-dim)', letterSpacing: '1px' }}>v0.7</span>
    </div>

    {/* Nav — stop mouse-down from propagating to drag region */}
    <div style={{ display: 'flex' }} onMouseDown={e => e.stopPropagation()}>
    {navItems.map(item => (
      <button
      key={item.id}
      onClick={() => setActiveSection(item.id)}
      className={`nav-tab${activeSection === item.id ? ' active' : ''}`}
      >
      {item.icon}
      {item.label}
      </button>
    ))}
    </div>

    {/* Clock + window controls */}
    <div style={{ display: 'flex', alignItems: 'center', gap: '14px' }} onMouseDown={e => e.stopPropagation()}>
    <span style={{ fontSize: '10px', color: 'var(--text-dim)', fontFamily: 'Share Tech Mono', letterSpacing: '1px' }}>
    {timeStr}
    </span>
    <div style={{ display: 'flex', gap: '4px' }}>
    {winBtns.map(btn => (
      <button
      key={btn.label}
      onClick={btn.action}
      title={btn.label}
      style={{
        width: '24px', height: '24px', background: 'transparent',
        border: `1px solid ${btn.color}30`, color: btn.color,
        cursor: 'pointer', display: 'flex', alignItems: 'center',
        justifyContent: 'center', borderRadius: '2px',
        transition: 'all 0.15s', opacity: 0.65, flexShrink: 0,
      }}
      onMouseEnter={e => {
        const el = e.currentTarget as HTMLButtonElement;
        el.style.background = `${btn.color}22`;
        el.style.opacity = '1';
        el.style.borderColor = btn.color;
      }}
      onMouseLeave={e => {
        const el = e.currentTarget as HTMLButtonElement;
        el.style.background = 'transparent';
        el.style.opacity = '0.65';
        el.style.borderColor = `${btn.color}30`;
      }}
      >
      {btn.icon}
      </button>
    ))}
    </div>
    </div>
    </div>

    {/* ── Main content ── */}
    <div style={{ flex: 1, overflow: 'hidden', position: 'relative', zIndex: 10 }}>
    {activeSection === 'games'    && <GamesSection games={GAMES} playtime={playtime} onLaunch={handleGameLaunch} />}
    {activeSection === 'addons'   && <AddonsSection addons={ADDONS} games={GAMES} />}
    {activeSection === 'settings' && <SettingsSection games={GAMES} gameSettings={gameSettings} onSave={handleSaveSettings} />}
    {activeSection === 'about'    && <AboutSection />}
    </div>

    {/* ── Status bar ── */}
    <div style={{
      height: '22px', background: 'rgba(3,5,8,0.98)',
          borderTop: '1px solid #0d1a0d',
          display: 'flex', alignItems: 'center', justifyContent: 'space-between',
          padding: '0 14px', flexShrink: 0, zIndex: 100,
    }}>
    <span style={{ fontSize: '9px', color: 'var(--text-dim)', letterSpacing: '2px' }}>
    SECURE CONNECTION ESTABLISHED // HACKEROS CORP © 2077
    </span>
    <span style={{ fontSize: '9px', color: 'var(--green-dim)', letterSpacing: '1px' }}>
    {GAMES.filter(g => g.available).length} GAMES INSTALLED
    </span>
    </div>
    </div>
  );
};

const AboutSection: React.FC = () => (
  <div style={{ padding: '40px', overflowY: 'auto', height: '100%' }}>
  <div style={{ maxWidth: '620px', margin: '0 auto' }}>
  <div style={{
    fontFamily: 'Orbitron, monospace', fontSize: '26px', fontWeight: 900,
    color: 'var(--green)', letterSpacing: '6px', marginBottom: '6px',
                                      textShadow: '0 0 20px rgba(0,255,65,0.4)',
  }}>HACKEROS GAMES</div>
  <div style={{ fontSize: '10px', color: 'var(--text-dim)', letterSpacing: '3px', marginBottom: '28px' }}>
  LAUNCHER // VERSION 0.7.0 // TAURI 2
  </div>
  <div style={{ background: 'var(--surface)', border: '1px solid var(--border)', padding: '22px', marginBottom: '18px' }}>
  <p style={{ fontSize: '12px', lineHeight: '1.9', color: 'var(--text)', marginBottom: '14px' }}>
  HackerOS Games is the native game launcher bundled with every HackerOS edition.
  Unified interface for launching, tracking playtime and configuring all HackerOS-native games.
  </p>
  <p style={{ fontSize: '12px', lineHeight: '1.9', color: 'var(--text-dim)' }}>
  Built with <span style={{ color: 'var(--blue)' }}>Tauri 2</span> + <span style={{ color: 'var(--pink)' }}>React 18</span> + <span style={{ color: 'var(--orange)' }}>Rust</span>.{' '}
  Games at <code style={{ color: 'var(--yellow)', fontSize: '11px' }}>/usr/share/HackerOS/Scripts/HackerOS-Games</code>.
  </p>
  </div>
  {(['The Racer','Cosmonaut','Starblaster','Bark Squadron','Bit Jump'] as const).map((name, i) => {
    const techs = ['Rust + macroquad','In Development','Rust + macroquad','TypeScript + React + Tauri','Lua + LÖVE2D'];
    const colors = ['var(--red)','var(--blue)','var(--green)','var(--pink)','var(--yellow)'];
    return (
      <div key={name} style={{
        display: 'flex', justifyContent: 'space-between', alignItems: 'center',
        padding: '10px 0', borderBottom: '1px solid var(--border)', fontSize: '11px',
      }}>
      <span style={{ color: colors[i] }}>{name}</span>
      <span style={{ color: 'var(--text-dim)' }}>{techs[i]}</span>
      </div>
    );
  })}
  </div>
  </div>
);

export default App;
