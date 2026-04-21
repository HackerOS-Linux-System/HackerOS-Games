import React, { useState, useEffect, useCallback } from 'react';
import { invoke } from '@tauri-apps/api/core';
import { getCurrentWindow } from '@tauri-apps/api/window';
import { GAMES, ADDONS } from './constants';
import { GamePlaytime, GameSettings, NavSection } from './types';
import GamesSection from './components/GamesSection';
import AddonsSection from './components/AddonsSection';
import SettingsSection from './components/SettingsSection';
import ParticlesBackground from './components/ParticlesBackground';
import { Gamepad2, Puzzle, Settings, Info, Minus, Square, X } from 'lucide-react';

const isTauri = () => '__TAURI_INTERNALS__' in window;

const App: React.FC = () => {
  const [activeSection, setActiveSection] = useState<NavSection>('games');
  const [playtime, setPlaytime] = useState<Record<string, GamePlaytime>>({});
  const [gameSettings, setGameSettings] = useState<Record<string, GameSettings>>({});
  const [clock, setClock] = useState(new Date());

  useEffect(() => {
    if (!isTauri()) return;
    invoke<Record<string, GamePlaytime>>('get_all_playtime').then(setPlaytime).catch(() => {});
    invoke<Record<string, GameSettings>>('get_all_game_settings').then(setGameSettings).catch(() => {});
  }, []);

  useEffect(() => {
    const id = setInterval(() => setClock(new Date()), 1000);
    return () => clearInterval(id);
  }, []);

  const handleGameLaunch = useCallback((gameId: string) => {
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

    // Poll playtime every 30s while game might be running
    const interval = setInterval(() => {
      if (isTauri()) {
        invoke<Record<string, GamePlaytime>>('get_all_playtime')
        .then(setPlaytime)
        .catch(() => {});
      }
    }, 30000);
    setTimeout(() => clearInterval(interval), 3600000); // stop after 1h
  }, []);

  const handleSaveSettings = useCallback(async (gameId: string, settings: GameSettings) => {
    setGameSettings(prev => ({ ...prev, [gameId]: settings }));
    if (isTauri()) {
      await invoke('save_game_settings', { gameId, settings }).catch(() => {});
    }
  }, []);

  const winControl = async (action: 'minimize' | 'maximize' | 'close') => {
    if (!isTauri()) return;
    const win = getCurrentWindow();
    if (action === 'minimize') win.minimize();
    else if (action === 'maximize') win.toggleMaximize();
    else win.close();
  };

    const navItems: { id: NavSection; label: string; icon: React.ReactNode }[] = [
      { id: 'games',    label: 'Library',  icon: <Gamepad2 size={13} /> },
      { id: 'addons',   label: 'Addons',   icon: <Puzzle size={13} /> },
      { id: 'settings', label: 'Settings', icon: <Settings size={13} /> },
      { id: 'about',    label: 'About',    icon: <Info size={13} /> },
    ];

    const timeStr = clock.toLocaleTimeString('pl-PL', {
      hour: '2-digit', minute: '2-digit', second: '2-digit',
    });

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
      {/* Left – logo */}
      <div style={{ display: 'flex', alignItems: 'center', gap: '10px', pointerEvents: 'none' }}>
      <div style={{
        width: '8px', height: '8px', borderRadius: '50%',
        background: '#2a8fff',
        animation: 'pulse-green 2s ease-in-out infinite',
        boxShadow: '0 0 8px rgba(42,143,255,0.7)',
      }} />
      <span style={{
        fontFamily: 'Orbitron, monospace', fontSize: '12px', fontWeight: 900,
        color: '#2a8fff', letterSpacing: '4px', textTransform: 'uppercase',
        textShadow: '0 0 12px rgba(42,143,255,0.5)',
      }}>
      HACKEROS<span style={{ color: 'var(--text-dim)', fontWeight: 400, marginLeft: '6px' }}>GAMES</span>
      </span>
      <span style={{ fontSize: '9px', color: 'var(--text-dim)', letterSpacing: '1px' }}>v0.7</span>
      </div>

      {/* Center – nav */}
      <div style={{ display: 'flex' }}>
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

      {/* Right – clock + window controls */}
      <div style={{ display: 'flex', alignItems: 'center', gap: '14px' }}>
      <span style={{ fontSize: '10px', color: 'var(--text-dim)', fontFamily: 'Share Tech Mono', pointerEvents: 'none' }}>
      {timeStr}
      </span>
      <div style={{ display: 'flex', gap: '4px' }}>
      {(
        [
          { icon: <Minus size={11} />,  action: 'minimize' as const, color: '#ffd600' },
        { icon: <Square size={10} />, action: 'maximize' as const, color: '#00cfff' },
        { icon: <X size={11} />,      action: 'close' as const,    color: '#ff1744' },
        ] as const
      ).map((btn, i) => (
        <button
        key={i}
        onClick={() => winControl(btn.action)}
        style={{
          width: '24px', height: '24px',
          background: 'transparent',
          border: `1px solid ${btn.color}30`,
          color: btn.color,
          cursor: 'pointer',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          borderRadius: '2px',
          transition: 'all 0.15s',
          opacity: 0.65,
        }}
        onMouseEnter={e => {
          const el = e.currentTarget as HTMLButtonElement;
          el.style.background = `${btn.color}20`;
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
      {activeSection === 'games' && (
        <GamesSection games={GAMES} playtime={playtime} onLaunch={handleGameLaunch} />
      )}
      {activeSection === 'addons' && (
        <AddonsSection addons={ADDONS} games={GAMES} />
      )}
      {activeSection === 'settings' && (
        <SettingsSection games={GAMES} gameSettings={gameSettings} onSave={handleSaveSettings} />
      )}
      {activeSection === 'about' && <AboutSection />}
      </div>

      {/* ── Status bar ── */}
      <div style={{
        height: '22px',
        background: 'rgba(3,5,8,0.98)',
            borderTop: '1px solid #0d1a0d',
            display: 'flex', alignItems: 'center', justifyContent: 'space-between',
            padding: '0 14px', flexShrink: 0, zIndex: 100,
      }}>
      <span style={{ fontSize: '9px', color: 'var(--text-dim)', letterSpacing: '2px' }}>
      SECURE CONNECTION ESTABLISHED // HACKEROS CORP © 2077
      </span>
      <span style={{ fontSize: '9px', color: '#1a6fcc', letterSpacing: '1px' }}>
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
  }}>
  HACKEROS GAMES
  </div>
  <div style={{ fontSize: '10px', color: 'var(--text-dim)', letterSpacing: '3px', marginBottom: '28px' }}>
  LAUNCHER // VERSION 0.7.0
  </div>

  <div style={{
    background: 'var(--surface)', border: '1px solid var(--border)',
                                      padding: '22px', marginBottom: '18px',
  }}>
  <p style={{ fontSize: '12px', lineHeight: '1.9', color: 'var(--text)', marginBottom: '14px' }}>
  HackerOS Games is the native game launcher bundled with every HackerOS edition.
  Unified interface for launching, tracking and configuring all HackerOS-native games.
  </p>
  <p style={{ fontSize: '12px', lineHeight: '1.9', color: 'var(--text-dim)' }}>
  Built with{' '}
  <span style={{ color: 'var(--blue)' }}>Tauri 2</span> +{' '}
  <span style={{ color: 'var(--pink)' }}>React 18</span> +{' '}
  <span style={{ color: 'var(--orange)' }}>Rust</span>.
  Games launch from{' '}
  <code style={{ color: 'var(--yellow)', fontSize: '11px' }}>
  /usr/share/HackerOS/Scripts/HackerOS-Games
  </code>.
  </p>
  </div>

  {(
    [
      ['The Racer',      'Rust + Tauri',           'var(--red)'],
    ['Cosmonaut',      'In Development',          'var(--blue)'],
    ['Starblaster',    'Rust + macroquad',        'var(--green)'],
    ['Bark Squadron',  'TypeScript + React + Tauri', 'var(--pink)'],
    ['Bit Jump',       'Lua + LÖVE2D',            'var(--yellow)'],
    ] as const
  ).map(([name, tech, color]) => (
    <div key={name} style={{
      display: 'flex', justifyContent: 'space-between', alignItems: 'center',
      padding: '10px 0', borderBottom: '1px solid var(--border)',
                                  fontSize: '11px',
    }}>
    <span style={{ color }}>{name}</span>
    <span style={{ color: 'var(--text-dim)' }}>{tech}</span>
    </div>
  ))}
  </div>
  </div>
);

export default App;
