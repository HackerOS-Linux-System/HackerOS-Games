import React, { useEffect, useMemo, useState } from 'react';
import { invoke } from '@tauri-apps/api/core';
import { COMMUNITY_GAMES_URL } from '../constants';
import { CommunityGame, CommunityGameInstall } from '../types';
import {
  Store, Search, Github, Download, AlertTriangle, Loader2,
  RefreshCw, ImageOff, Trash2, Play, CheckCircle2, User,
} from 'lucide-react';

const isTauri = () => '__TAURI_INTERNALS__' in window;

const openLink = async (url: string) => {
  if (!url) return;
  if (isTauri()) {
    try { await invoke('open_url', { url }); return; } catch {}
  }
  window.open(url, '_blank', 'noopener,noreferrer');
};

const StoreSection: React.FC<{ language?: 'en' | 'pl' }> = ({ language = 'en' }) => {
  const [games, setGames] = useState<CommunityGame[] | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [query, setQuery] = useState('');
  const [installs, setInstalls] = useState<Record<string, CommunityGameInstall>>({});
  const [installing, setInstalling] = useState<Record<number, boolean>>({});
  const [uninstalling, setUninstalling] = useState<Record<number, boolean>>({});
  const [launching, setLaunching] = useState<Record<number, boolean>>({});
  const [actionErr, setActionErr] = useState<Record<number, string>>({});

  const load = async () => {
    setLoading(true);
    setError(null);
    try {
      const res = await fetch(COMMUNITY_GAMES_URL, { cache: 'no-store' });
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const data = await res.json();
      const list: CommunityGame[] = Array.isArray(data?.['HackerOS-Community-Games'])
        ? data['HackerOS-Community-Games'].filter((g: CommunityGame) => g.title)
        : [];
      setGames(list);
    } catch (e: unknown) {
      setError(e instanceof Error ? e.message : String(e));
      setGames(null);
    } finally {
      setLoading(false);
    }
  };

  const loadInstalls = async () => {
    if (!isTauri()) return;
    try {
      const data = await invoke<Record<string, CommunityGameInstall>>('get_community_installs');
      setInstalls(data);
    } catch {}
  };

  useEffect(() => {
    load();
    loadInstalls();
  }, []);

  const filtered = useMemo(() => {
    if (!games) return [];
    const q = query.trim().toLowerCase();
    if (!q) return games;
    const desc = language === 'pl' ? 'description-pl' : 'description-en';
    return games.filter(g =>
      g.title.toLowerCase().includes(q) ||
      g.genre.toLowerCase().includes(q) ||
      (g[desc] ?? '').toLowerCase().includes(q) ||
      (g.authors ?? '').toLowerCase().includes(q)
    );
  }, [games, query, language]);

  const gameSlug = (g: CommunityGame) => `community-${g.id}`;

  const handleInstall = async (g: CommunityGame) => {
    if (!isTauri() || !g.install) return;
    setInstalling(p => ({ ...p, [g.id]: true }));
    setActionErr(p => ({ ...p, [g.id]: '' }));
    try {
      const install = await invoke<CommunityGameInstall>('install_community_game', {
        gameId: gameSlug(g),
        title: g.title,
        installUrl: g.install,
      });
      setInstalls(p => ({ ...p, [gameSlug(g)]: install }));
    } catch (e: unknown) {
      setActionErr(p => ({ ...p, [g.id]: e instanceof Error ? e.message : String(e) }));
    } finally {
      setInstalling(p => ({ ...p, [g.id]: false }));
    }
  };

  const handleUninstall = async (g: CommunityGame) => {
    if (!isTauri()) return;
    setUninstalling(p => ({ ...p, [g.id]: true }));
    try {
      await invoke('uninstall_community_game', { gameId: gameSlug(g) });
      setInstalls(p => { const n = { ...p }; delete n[gameSlug(g)]; return n; });
    } catch (e: unknown) {
      setActionErr(p => ({ ...p, [g.id]: e instanceof Error ? e.message : String(e) }));
    } finally {
      setUninstalling(p => ({ ...p, [g.id]: false }));
    }
  };

  const handleLaunch = async (g: CommunityGame) => {
    if (!isTauri()) return;
    setLaunching(p => ({ ...p, [g.id]: true }));
    try {
      await invoke('launch_community_game', { gameId: gameSlug(g) });
      setTimeout(() => setLaunching(p => ({ ...p, [g.id]: false })), 3000);
    } catch (e: unknown) {
      setActionErr(p => ({ ...p, [g.id]: e instanceof Error ? e.message : String(e) }));
      setLaunching(p => ({ ...p, [g.id]: false }));
    }
  };

  return (
    <div style={{ padding: '32px', height: '100%', overflowY: 'auto' }}>
      {/* Header */}
      <div style={{ marginBottom: '24px', display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between', flexWrap: 'wrap', gap: '14px' }}>
        <div>
          <div style={{ fontFamily: 'Orbitron, monospace', fontSize: '16px', fontWeight: 700, color: 'var(--text)', letterSpacing: '4px', marginBottom: '6px' }}>
            STORE <span style={{ color: 'var(--text-dim)', fontSize: '11px', fontWeight: 400 }}>// HACKEROS COMMUNITY GAMES</span>
          </div>
          <div style={{ fontSize: '10px', color: 'var(--text-dim)', letterSpacing: '1px', maxWidth: '560px', lineHeight: '1.7' }}>
            Community-submitted games curated by the HackerOS team. Each game runs in an isolated sandbox — click Install to download, then Launch to play.
          </div>
        </div>
        <div style={{ display: 'flex', gap: '8px' }}>
          <div style={{ position: 'relative' }}>
            <Search size={12} style={{ position: 'absolute', left: '10px', top: '50%', transform: 'translateY(-50%)', color: 'var(--text-dim)' }} />
            <input
              value={query} onChange={e => setQuery(e.target.value)}
              placeholder="SEARCH GAMES…"
              style={{ width: '200px', padding: '8px 10px 8px 28px', background: 'var(--surface)', border: '1px solid var(--border)', color: 'var(--text)', fontSize: '10px', letterSpacing: '2px', fontFamily: 'Share Tech Mono, monospace', outline: 'none' }}
            />
          </div>
          <button onClick={() => { load(); loadInstalls(); }} style={ghostBtn} title="Refresh list">
            <RefreshCw size={11} style={{ animation: loading ? 'spin 1s linear infinite' : 'none' }} /> REFRESH
          </button>
        </div>
      </div>

      {loading && <Notice icon={<Loader2 size={13} style={{ animation: 'spin 1s linear infinite' }} />} color="var(--text-dim)">Fetching community games list from GitHub…</Notice>}
      {!loading && error && <Notice icon={<AlertTriangle size={13} />} color="var(--red)">Failed to load the store listing ({error}). Check your internet connection and try again.</Notice>}
      {!loading && !error && games && games.length === 0 && <Notice icon={<Store size={13} />} color="var(--text-dim)">No community games have been published yet — check back soon.</Notice>}

      {!loading && !error && filtered.length > 0 && (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(300px,1fr))', gap: '16px', maxWidth: '1200px' }}>
          {filtered.map(g => {
            const slug = gameSlug(g);
            const installed = !!installs[slug];
            const desc = language === 'pl' ? g['description-pl'] : g['description-en'];
            const err = actionErr[g.id];

            return (
              <div key={g.id} className="game-card" style={{ padding: 0, display: 'flex', flexDirection: 'column' }}>
                {/* Image */}
                <div style={{ height: '140px', background: 'var(--surface2)', display: 'flex', alignItems: 'center', justifyContent: 'center', borderBottom: '1px solid var(--border)', overflow: 'hidden', position: 'relative' }}>
                  {g.image ? (
                    <img src={g.image} alt={g.title} style={{ width: '100%', height: '100%', objectFit: 'cover' }}
                      onError={e => { (e.currentTarget as HTMLImageElement).style.display = 'none'; }} />
                  ) : (
                    <ImageOff size={28} style={{ opacity: 0.4, color: 'var(--text-dim)' }} />
                  )}
                  {installed && (
                    <div style={{ position: 'absolute', top: '8px', right: '8px', background: 'rgba(0,255,65,0.15)', border: '1px solid #00ff41', borderRadius: '2px', padding: '3px 7px', fontSize: '9px', color: '#00ff41', letterSpacing: '1px', display: 'flex', alignItems: 'center', gap: '4px' }}>
                      <CheckCircle2 size={9} /> INSTALLED
                    </div>
                  )}
                </div>

                {/* Body */}
                <div style={{ padding: '16px', display: 'flex', flexDirection: 'column', flex: 1 }}>
                  <div style={{ fontFamily: 'Orbitron, monospace', fontSize: '12px', fontWeight: 700, color: 'var(--text)', letterSpacing: '1px', marginBottom: '6px' }}>
                    {g.title}
                  </div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '10px', flexWrap: 'wrap' }}>
                    <span style={{ display: 'inline-flex', padding: '3px 8px', background: 'rgba(42,143,255,0.08)', border: '1px solid rgba(42,143,255,0.3)', fontSize: '9px', color: 'var(--accent)', letterSpacing: '1px' }}>
                      {g.genre.toUpperCase()}
                    </span>
                    {g.authors && (
                      <span style={{ fontSize: '9px', color: 'var(--text-dim)', display: 'flex', alignItems: 'center', gap: '4px' }}>
                        <User size={9} />{g.authors}
                      </span>
                    )}
                  </div>
                  <div style={{ fontSize: '11px', color: 'var(--text-dim)', lineHeight: '1.6', marginBottom: '14px', flex: 1 }}>
                    {desc || g['description-en']}
                  </div>

                  {err && (
                    <div style={{ fontSize: '10px', color: 'var(--red)', marginBottom: '10px', display: 'flex', alignItems: 'center', gap: '6px' }}>
                      <AlertTriangle size={10} />{err}
                    </div>
                  )}

                  {/* Actions */}
                  <div style={{ display: 'flex', gap: '6px', flexWrap: 'wrap' }}>
                    {installed ? (
                      <>
                        <button
                          onClick={() => handleLaunch(g)}
                          disabled={launching[g.id]}
                          style={actionBtn('#00ff41', '0,255,65', !launching[g.id])}
                        >
                          <Play size={10} fill="currentColor" />
                          {launching[g.id] ? 'LAUNCHING…' : 'LAUNCH'}
                        </button>
                        <button
                          onClick={() => handleUninstall(g)}
                          disabled={uninstalling[g.id]}
                          style={actionBtn('#ff1744', '255,23,68', !uninstalling[g.id], false)}
                        >
                          <Trash2 size={10} />
                          {uninstalling[g.id] ? 'REMOVING…' : 'UNINSTALL'}
                        </button>
                      </>
                    ) : (
                      <button
                        onClick={() => handleInstall(g)}
                        disabled={installing[g.id] || !g.install}
                        style={actionBtn('var(--accent)', '42,143,255', !installing[g.id] && !!g.install)}
                      >
                        <Download size={10} />
                        {installing[g.id] ? 'INSTALLING…' : 'INSTALL'}
                      </button>
                    )}
                    {g.repo && (
                      <button onClick={() => openLink(g.repo!)} style={ghostBtnSm}>
                        <Github size={10} /> REPO
                      </button>
                    )}
                  </div>

                  {installing[g.id] && (
                    <div style={{ fontSize: '9px', color: 'var(--text-dim)', marginTop: '8px', letterSpacing: '1px', display: 'flex', alignItems: 'center', gap: '5px' }}>
                      <Loader2 size={9} style={{ animation: 'spin 1s linear infinite' }} />
                      Downloading &amp; installing in sandbox…
                    </div>
                  )}

                  {installed && installs[slug] && (
                    <div style={{ fontSize: '9px', color: 'var(--text-dim)', marginTop: '8px', letterSpacing: '1px' }}>
                      Type: <span style={{ color: 'var(--accent)' }}>{installs[slug].install_type}</span>
                      {' '}// Installed {new Date(installs[slug].installed_at * 1000).toLocaleDateString()}
                    </div>
                  )}
                </div>
              </div>
            );
          })}
        </div>
      )}

      {!loading && !error && games && games.length > 0 && filtered.length === 0 && (
        <Notice icon={<Search size={13} />} color="var(--text-dim)">No games match "{query}".</Notice>
      )}
    </div>
  );
};

const Notice: React.FC<{ icon: React.ReactNode; color: string; children: React.ReactNode }> = ({ icon, color, children }) => (
  <div style={{ display: 'flex', alignItems: 'center', gap: '8px', padding: '11px 16px', maxWidth: '660px', background: `${color}0d`, border: `1px solid ${color}30`, fontSize: '11px', color, lineHeight: '1.6' }}>
    {icon}<span>{children}</span>
  </div>
);

const ghostBtn: React.CSSProperties = {
  display: 'flex', alignItems: 'center', gap: '6px',
  padding: '7px 14px', background: 'transparent',
  border: '1px solid var(--border)', color: 'var(--text-dim)', cursor: 'pointer',
  fontSize: '10px', fontFamily: 'Share Tech Mono, monospace',
  letterSpacing: '2px', textTransform: 'uppercase', transition: 'all 0.15s',
};

const ghostBtnSm: React.CSSProperties = {
  display: 'flex', alignItems: 'center', gap: '5px',
  padding: '6px 10px', background: 'transparent',
  border: '1px solid var(--border)', color: 'var(--text-dim)', cursor: 'pointer',
  fontSize: '9px', fontFamily: 'Share Tech Mono, monospace',
  letterSpacing: '1px', textTransform: 'uppercase', transition: 'all 0.15s',
};

const actionBtn = (color: string, rgb: string, enabled: boolean, primary = true): React.CSSProperties => ({
  flex: primary ? 1 : undefined,
  display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '5px',
  padding: '7px 12px',
  background: enabled ? `rgba(${rgb},0.1)` : 'transparent',
  border: `1px solid ${enabled ? color : '#2a2a2a'}`,
  color: enabled ? color : '#3a3a3a',
  cursor: enabled ? 'pointer' : 'not-allowed',
  fontSize: '9px', letterSpacing: '2px', textTransform: 'uppercase',
  fontFamily: 'Share Tech Mono, monospace', transition: 'all 0.15s',
});

export default StoreSection;
