import React, { useEffect, useMemo, useState } from 'react';
import { invoke } from '@tauri-apps/api/core';
import { COMMUNITY_GAMES_URL } from '../constants';
import { CommunityGame } from '../types';
import { Store, Search, Github, Download, AlertTriangle, Loader2, RefreshCw, ImageOff } from 'lucide-react';

const isTauri = () => '__TAURI_INTERNALS__' in window;

const openLink = async (url: string) => {
    if (!url) return;
    if (isTauri()) {
        try {
            await invoke('open_url', { url });
            return;
        } catch {
            // fall through to window.open as a last resort
        }
    }
    window.open(url, '_blank', 'noopener,noreferrer');
};

const StoreSection: React.FC = () => {
    const [games, setGames] = useState<CommunityGame[] | null>(null);
    const [error, setError] = useState<string | null>(null);
    const [loading, setLoading] = useState(true);
    const [query, setQuery] = useState('');

    const load = async () => {
        setLoading(true);
        setError(null);
        try {
            const res = await fetch(COMMUNITY_GAMES_URL, { cache: 'no-store' });
            if (!res.ok) throw new Error(`HTTP ${res.status}`);
            const data = await res.json();
            const list: CommunityGame[] = Array.isArray(data?.['HackerOS-Community-Games'])
            ? data['HackerOS-Community-Games']
            : [];
            setGames(list);
        } catch (e: unknown) {
            setError(e instanceof Error ? e.message : String(e));
            setGames(null);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => { load(); }, []);

    const filtered = useMemo(() => {
        if (!games) return [];
        const q = query.trim().toLowerCase();
        if (!q) return games;
        return games.filter(g =>
        g.title.toLowerCase().includes(q) ||
        g.genre.toLowerCase().includes(q) ||
        g.description.toLowerCase().includes(q)
        );
    }, [games, query]);

    return (
        <div style={{ padding: '32px', height: '100%', overflowY: 'auto' }}>
        <div style={{ marginBottom: '24px', display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between', flexWrap: 'wrap', gap: '14px' }}>
        <div>
        <div style={{
            fontFamily: 'Orbitron, monospace', fontSize: '16px', fontWeight: 700,
            color: 'var(--text)', letterSpacing: '4px', marginBottom: '6px',
        }}>
        STORE <span style={{ color: 'var(--text-dim)', fontSize: '11px', fontWeight: 400 }}>// HACKEROS COMMUNITY GAMES</span>
        </div>
        <div style={{ fontSize: '10px', color: 'var(--text-dim)', letterSpacing: '1px', maxWidth: '560px', lineHeight: '1.7' }}>
        Community-submitted games and mods, curated by the HackerOS team. Each entry links to its
        source repository and a ready-to-run download.
        </div>
        </div>

        <div style={{ display: 'flex', gap: '8px' }}>
        <div style={{ position: 'relative' }}>
        <Search size={12} style={{ position: 'absolute', left: '10px', top: '50%', transform: 'translateY(-50%)', color: 'var(--text-dim)' }} />
        <input
        value={query}
        onChange={e => setQuery(e.target.value)}
        placeholder="SEARCH GAMES…"
        style={{
            width: '200px', padding: '8px 10px 8px 28px',
            background: 'var(--surface)', border: '1px solid var(--border)',
            color: 'var(--text)', fontSize: '10px', letterSpacing: '2px',
            fontFamily: 'Share Tech Mono, monospace', outline: 'none',
        }}
        />
        </div>
        <button onClick={load} style={ghostBtn} title="Refresh list">
        <RefreshCw size={11} className={loading ? 'spin' : undefined} /> REFRESH
        </button>
        </div>
        </div>

        {loading && (
            <Notice icon={<Loader2 size={13} className="spin" />} color="var(--text-dim)">
            Fetching community games list from GitHub…
            </Notice>
        )}

        {!loading && error && (
            <div style={{ maxWidth: '660px' }}>
            <Notice icon={<AlertTriangle size={13} />} color="var(--red)">
            Failed to load the store listing ({error}). Check your internet connection and try again.
            </Notice>
            </div>
        )}

        {!loading && !error && games && games.length === 0 && (
            <Notice icon={<Store size={13} />} color="var(--text-dim)">
            No community games have been published yet — check back soon.
            </Notice>
        )}

        {!loading && !error && filtered.length > 0 && (
            <div style={{
                display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(280px,1fr))',
                                                       gap: '16px', maxWidth: '1100px',
            }}>
            {filtered.map(game => (
                <div key={game.id} className="game-card" style={{ padding: 0, display: 'flex', flexDirection: 'column' }}>
                <div style={{
                    height: '140px', background: 'var(--surface2)',
                                   display: 'flex', alignItems: 'center', justifyContent: 'center',
                                   borderBottom: '1px solid var(--border)', overflow: 'hidden',
                }}>
                {game.image ? (
                    <img
                    src={game.image} alt={game.title}
                    style={{ width: '100%', height: '100%', objectFit: 'cover' }}
                    onError={e => {
                        const el = e.currentTarget as HTMLImageElement;
                        el.style.display = 'none';
                        const fallback = el.nextElementSibling as HTMLElement | null;
                        if (fallback) fallback.style.display = 'flex';
                    }}
                    />
                ) : null}
                <div style={{
                    display: game.image ? 'none' : 'flex',
                    alignItems: 'center', justifyContent: 'center',
                    width: '100%', height: '100%', color: 'var(--text-dim)',
                }}>
                <ImageOff size={28} style={{ opacity: 0.4 }} />
                </div>
                </div>
                <div style={{ padding: '16px', display: 'flex', flexDirection: 'column', flex: 1 }}>
                <div style={{
                    fontFamily: 'Orbitron, monospace', fontSize: '12px', fontWeight: 700,
                    color: 'var(--text)', letterSpacing: '1px', marginBottom: '6px',
                }}>
                {game.title}
                </div>
                <div style={{
                    display: 'inline-flex', alignSelf: 'flex-start',
                    padding: '3px 8px', marginBottom: '10px',
                    background: 'rgba(42,143,255,0.08)', border: '1px solid var(--accent)30',
                                   fontSize: '9px', color: 'var(--accent)', letterSpacing: '1px',
                }}>
                {game.genre.toUpperCase()}
                </div>
                <div style={{ fontSize: '11px', color: 'var(--text-dim)', lineHeight: '1.6', marginBottom: '16px', flex: 1 }}>
                {game.description}
                </div>
                <div style={{ display: 'flex', gap: '8px' }}>
                <button onClick={() => openLink(game.repo)} disabled={!game.repo} style={linkBtn(!!game.repo)}>
                <Github size={11} /> REPO
                </button>
                <button onClick={() => openLink(game.install)} disabled={!game.install} style={linkBtn(!!game.install, true)}>
                <Download size={11} /> DOWNLOAD
                </button>
                </div>
                </div>
                </div>
            ))}
            </div>
        )}

        {!loading && !error && games && games.length > 0 && filtered.length === 0 && (
            <Notice icon={<Search size={13} />} color="var(--text-dim)">
            No games match “{query}”.
            </Notice>
        )}
        </div>
    );
};

const Notice: React.FC<{ icon: React.ReactNode; color: string; children: React.ReactNode }> = ({ icon, color, children }) => (
    <div style={{
        display: 'flex', alignItems: 'center', gap: '8px',
        padding: '11px 16px', maxWidth: '660px',
        background: `${color}0d`, border: `1px solid ${color}30`,
        fontSize: '11px', color, lineHeight: '1.6',
    }}>
    {icon}
    <span>{children}</span>
    </div>
);

const ghostBtn: React.CSSProperties = {
    display: 'flex', alignItems: 'center', gap: '6px',
    padding: '7px 14px', background: 'transparent',
    border: '1px solid var(--border)', color: 'var(--text-dim)', cursor: 'pointer',
    fontSize: '10px', fontFamily: 'Share Tech Mono, monospace',
    letterSpacing: '2px', textTransform: 'uppercase', transition: 'all 0.15s',
};

const linkBtn = (enabled: boolean, primary = false): React.CSSProperties => ({
    flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '6px',
    padding: '8px 10px',
    background: enabled ? (primary ? 'rgba(var(--accent-rgb),0.1)' : 'transparent') : 'transparent',
                                                                             border: `1px solid ${enabled ? (primary ? 'var(--accent)' : 'var(--border)') : '#2a2a2a'}`,
                                                                             color: enabled ? (primary ? 'var(--accent)' : 'var(--text-dim)') : '#3a3a3a',
                                                                             cursor: enabled ? 'pointer' : 'not-allowed',
                                                                             fontSize: '9px', letterSpacing: '2px', textTransform: 'uppercase',
                                                                             fontFamily: 'Share Tech Mono, monospace', transition: 'all 0.15s',
});

export default StoreSection;
