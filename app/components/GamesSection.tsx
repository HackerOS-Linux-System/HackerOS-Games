import React, { useState, useEffect } from 'react';
import { invoke } from '@tauri-apps/api/core';
import { GameConfig, GamePlaytime } from '../types';
import { Clock, Zap, Play, AlertTriangle, Star, Layers } from 'lucide-react';

interface Props {
  games: GameConfig[];
  playtime: Record<string, GamePlaytime>;
  onLaunch: (gameId: string) => void;
}

const isTauri = () => '__TAURI_INTERNALS__' in window;

const fmtTime = (s: number) => {
  if (s < 60) return `${s}s`;
  if (s < 3600) return `${Math.floor(s / 60)}m`;
  const h = Math.floor(s / 3600);
  const m = Math.floor((s % 3600) / 60);
  return m ? `${h}h ${m}m` : `${h}h`;
};

const fmtLast = (ts: number) => {
  if (!ts) return 'Never';
  const d = Math.floor(Date.now() / 1000) - ts;
  if (d < 3600) return `${Math.floor(d / 60)}m ago`;
  if (d < 86400) return `${Math.floor(d / 3600)}h ago`;
  if (d < 604800) return `${Math.floor(d / 86400)}d ago`;
  return new Date(ts * 1000).toLocaleDateString('pl-PL');
};

/* ── Small card in sidebar ── */
const SideCard: React.FC<{
  game: GameConfig;
  pt?: GamePlaytime;
  selected: boolean;
  onClick: () => void;
}> = ({ game, pt, selected, onClick }) => (
  <div
    onClick={onClick}
    className="game-card"
    style={{
      padding: '14px',
      marginBottom: '6px',
      borderColor: selected ? game.color : undefined,
      boxShadow: selected ? `0 0 16px rgba(${game.rgb},0.18), inset 0 0 30px rgba(${game.rgb},0.04)` : undefined,
      opacity: game.available ? 1 : 0.55,
    }}
  >
    <div style={{ display: 'flex', gap: '12px', alignItems: 'center' }}>
      {/* Icon */}
      <div style={{
        width: '44px', height: '44px', flexShrink: 0,
        border: `1px solid ${game.color}33`,
        background: `rgba(${game.rgb},0.05)`,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        overflow: 'hidden',
      }}>
        <img
          src={game.icon} alt={game.name}
          style={{ width: '36px', height: '36px', objectFit: 'contain' }}
          onError={e => { (e.currentTarget as HTMLImageElement).style.display = 'none'; }}
        />
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{
          fontFamily: 'Orbitron, monospace', fontSize: '11px', fontWeight: 700,
          color: game.color, letterSpacing: '1px', textTransform: 'uppercase',
          marginBottom: '3px',
          textShadow: `0 0 6px rgba(${game.rgb},0.4)`,
        }}>
          {game.name}
        </div>
        <div style={{ fontSize: '9px', color: 'var(--text-dim)', letterSpacing: '1px' }}>
          {game.genre}
        </div>
        <div style={{ display: 'flex', gap: '10px', marginTop: '5px', fontSize: '9px', color: 'var(--text-dim)' }}>
          <span style={{ display: 'flex', alignItems: 'center', gap: '3px' }}>
            <Clock size={8} />{fmtTime(pt?.total_seconds ?? 0)}
          </span>
          <span style={{ display: 'flex', alignItems: 'center', gap: '3px' }}>
            <Zap size={8} />{fmtLast(pt?.last_played ?? 0)}
          </span>
        </div>
      </div>
      {/* Status dot */}
      <div style={{
        width: '6px', height: '6px', borderRadius: '50%', flexShrink: 0,
        background: game.available ? game.color : '#333',
        boxShadow: game.available ? `0 0 5px ${game.color}` : 'none',
      }} />
    </div>
  </div>
);

/* ── Detail panel ── */
const Detail: React.FC<{
  game: GameConfig;
  pt?: GamePlaytime;
  onLaunch: (id: string) => void;
}> = ({ game, pt, onLaunch }) => {
  const [launching, setLaunching] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [exists, setExists] = useState<boolean | null>(null);

  useEffect(() => {
    setError(null);
    setLaunching(false);
    if (!game.available) { setExists(false); return; }
    if (isTauri()) {
      invoke<boolean>('check_game_exists', { gameId: game.id })
        .then(setExists).catch(() => setExists(false));
    } else {
      setExists(false);
    }
  }, [game.id, game.available]);

  const launch = async () => {
    if (!exists || launching) return;
    setLaunching(true);
    setError(null);
    try {
      await invoke('launch_game', { gameId: game.id });
      onLaunch(game.id);
      setTimeout(() => setLaunching(false), 3000);
    } catch (e: unknown) {
      setError(e instanceof Error ? e.message : String(e));
      setLaunching(false);
    }
  };

  const canLaunch = exists === true && game.available;

  const btnLabel = launching
    ? 'LAUNCHING...'
    : !game.available
    ? 'COMING SOON'
    : exists === false
    ? 'NOT INSTALLED'
    : 'LAUNCH GAME';

  return (
    <div style={{ padding: '36px 40px', height: '100%', overflowY: 'auto', display: 'flex', flexDirection: 'column' }}>

      {/* Header */}
      <div style={{ display: 'flex', gap: '28px', marginBottom: '32px', alignItems: 'flex-start' }}>
        <div style={{
          width: '110px', height: '110px', flexShrink: 0,
          border: `1px solid ${game.color}44`,
          background: `rgba(${game.rgb},0.06)`,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          boxShadow: `0 0 40px rgba(${game.rgb},0.12)`,
        }}>
          <img
            src={game.icon} alt={game.name}
            style={{ width: '90px', height: '90px', objectFit: 'contain' }}
            onError={e => { (e.currentTarget as HTMLImageElement).style.display = 'none'; }}
          />
        </div>
        <div style={{ flex: 1 }}>
          <div style={{
            fontFamily: 'Orbitron, monospace', fontSize: '26px', fontWeight: 900,
            color: game.color, letterSpacing: '4px', textTransform: 'uppercase',
            textShadow: `0 0 24px rgba(${game.rgb},0.5)`, marginBottom: '6px',
          }}>
            {game.name}
          </div>
          <div style={{ fontSize: '10px', color: 'var(--text-dim)', letterSpacing: '2px', marginBottom: '14px' }}>
            {game.genre.toUpperCase()} &nbsp;// &nbsp;v{game.version}
          </div>
          <div style={{ fontSize: '12px', color: 'var(--text)', lineHeight: '1.8', maxWidth: '480px' }}>
            {game.longDescription}
          </div>
        </div>
      </div>

      {/* Stats */}
      {pt && (
        <div style={{
          display: 'grid', gridTemplateColumns: 'repeat(3,1fr)',
          gap: '12px', marginBottom: '28px',
        }}>
          {[
            { label: 'TOTAL TIME', val: fmtTime(pt.total_seconds), icon: <Clock size={13} /> },
            { label: 'SESSIONS',   val: String(pt.sessions),       icon: <Layers size={13} /> },
            { label: 'LAST PLAYED',val: fmtLast(pt.last_played),   icon: <Star size={13} /> },
          ].map(({ label, val, icon }) => (
            <div key={label} style={{
              background: 'var(--surface)', border: `1px solid ${game.color}22`, padding: '14px 18px',
            }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '6px', color: game.color, marginBottom: '6px' }}>
                {icon}
                <span style={{ fontSize: '9px', letterSpacing: '2px' }}>{label}</span>
              </div>
              <div style={{ fontFamily: 'Orbitron, monospace', fontSize: '20px', fontWeight: 700, color: 'var(--text)' }}>
                {val}
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Error */}
      {error && (
        <div style={{
          display: 'flex', alignItems: 'center', gap: '8px',
          background: 'rgba(255,23,68,0.08)', border: '1px solid rgba(255,23,68,0.25)',
          padding: '10px 14px', fontSize: '11px', color: 'var(--red)', marginBottom: '16px',
        }}>
          <AlertTriangle size={13} />{error}
        </div>
      )}

      {/* Launch */}
      <button
        onClick={launch}
        disabled={!canLaunch || launching}
        style={{
          display: 'inline-flex', alignItems: 'center', gap: '10px',
          padding: '15px 36px', maxWidth: '280px',
          background: canLaunch ? `rgba(${game.rgb},0.1)` : 'transparent',
          border: `1px solid ${canLaunch ? game.color : '#2a2a2a'}`,
          color: canLaunch ? game.color : '#3a3a3a',
          fontFamily: 'Orbitron, monospace', fontSize: '12px', fontWeight: 700,
          letterSpacing: '3px', textTransform: 'uppercase',
          cursor: canLaunch ? 'pointer' : 'not-allowed',
          transition: 'all 0.2s',
          boxShadow: launching ? `0 0 30px rgba(${game.rgb},0.35)` : 'none',
        }}
        onMouseEnter={e => {
          if (canLaunch) {
            const el = e.currentTarget as HTMLButtonElement;
            el.style.background = `rgba(${game.rgb},0.2)`;
            el.style.boxShadow = `0 0 20px rgba(${game.rgb},0.25)`;
          }
        }}
        onMouseLeave={e => {
          if (canLaunch && !launching) {
            const el = e.currentTarget as HTMLButtonElement;
            el.style.background = `rgba(${game.rgb},0.1)`;
            el.style.boxShadow = 'none';
          }
        }}
      >
        <Play size={15} fill="currentColor" />
        {btnLabel}
      </button>

      {!canLaunch && game.available && exists === false && (
        <p style={{ fontSize: '10px', color: 'var(--text-dim)', marginTop: '10px', lineHeight: '1.6' }}>
          Game binary not found at expected path.<br />
          Check your HackerOS-Games installation.
        </p>
      )}
    </div>
  );
};

/* ── Section ── */
const GamesSection: React.FC<Props> = ({ games, playtime, onLaunch }) => {
  const [selected, setSelected] = useState(games[0]?.id ?? '');
  const game = games.find(g => g.id === selected) ?? games[0];

  return (
    <div style={{ display: 'flex', height: '100%', overflow: 'hidden' }}>
      {/* Sidebar */}
      <div style={{
        width: '300px', borderRight: '1px solid var(--border)',
        background: 'rgba(0,0,0,0.35)', flexShrink: 0,
        overflowY: 'auto', padding: '12px',
      }}>
        <div style={{
          fontSize: '9px', color: 'var(--text-dim)', letterSpacing: '3px',
          padding: '4px 4px 10px', borderBottom: '1px solid var(--border)', marginBottom: '8px',
        }}>
          LIBRARY — {games.length} TITLES
        </div>
        {games.map(g => (
          <SideCard
            key={g.id} game={g}
            pt={playtime[g.id]}
            selected={selected === g.id}
            onClick={() => setSelected(g.id)}
          />
        ))}
      </div>

      {/* Detail */}
      <div style={{ flex: 1, overflow: 'hidden', background: 'rgba(0,0,0,0.12)' }}>
        {game && <Detail game={game} pt={playtime[game.id]} onLaunch={onLaunch} />}
      </div>
    </div>
  );
};

export default GamesSection;
