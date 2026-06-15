import React, { useCallback, useEffect, useState } from 'react';
import { invoke } from '@tauri-apps/api/core';
import { ADDON_GAMES } from '../constants';
import {
  Puzzle, Download, Loader2, AlertTriangle, Play, Lock,
  CheckCircle2, RefreshCw, PackageSearch,
} from 'lucide-react';

const isTauri = () => '__TAURI_INTERNALS__' in window;

type AddonStatus = 'checking' | 'not-installed' | 'installed' | 'unsupported';

const AddonsSection: React.FC = () => {
  const [status, setStatus] = useState<AddonStatus>('checking');
  const [installing, setInstalling] = useState(false);
  const [installError, setInstallError] = useState<string | null>(null);
  const [availability, setAvailability] = useState<Record<string, boolean>>({});
  const [launchError, setLaunchError] = useState<string | null>(null);
  const [launching, setLaunching] = useState<string | null>(null);

  const refreshAvailability = useCallback(async () => {
    const result: Record<string, boolean> = {};
    for (const addon of ADDON_GAMES) {
      try {
        result[addon.id] = await invoke<boolean>('check_addon_game_exists', { addonId: addon.id });
      } catch {
        result[addon.id] = false;
      }
    }
    setAvailability(result);
  }, []);

  const refresh = useCallback(async () => {
    if (!isTauri()) { setStatus('unsupported'); return; }
    setStatus('checking');
    try {
      const installed = await invoke<boolean>('check_addons_installed');
      if (installed) {
        await refreshAvailability();
        setStatus('installed');
      } else {
        setStatus('not-installed');
      }
    } catch {
      setStatus('not-installed');
    }
  }, [refreshAvailability]);

  useEffect(() => { refresh(); }, [refresh]);

  const handleInstall = async () => {
    if (installing) return;
    setInstalling(true);
    setInstallError(null);
    try {
      await invoke('install_addons');
      await refresh();
    } catch (e: unknown) {
      setInstallError(e instanceof Error ? e.message : String(e));
    } finally {
      setInstalling(false);
    }
  };

  const handleLaunch = async (addonId: string) => {
    if (launching) return;
    setLaunching(addonId);
    setLaunchError(null);
    try {
      await invoke('launch_addon_game', { addonId });
      setTimeout(() => setLaunching(null), 2000);
    } catch (e: unknown) {
      setLaunchError(e instanceof Error ? e.message : String(e));
      setLaunching(null);
    }
  };

  return (
    <div style={{ padding: '32px', height: '100%', overflowY: 'auto' }}>
    <div style={{ marginBottom: '28px', display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between', flexWrap: 'wrap', gap: '12px' }}>
    <div>
    <div style={{
      fontFamily: 'Orbitron, monospace', fontSize: '16px', fontWeight: 700,
      color: 'var(--text)', letterSpacing: '4px', marginBottom: '6px',
    }}>
    ADDONS <span style={{ color: 'var(--text-dim)', fontSize: '11px', fontWeight: 400 }}>// COMMUNITY ADDON PACK</span>
    </div>
    <div style={{ fontSize: '10px', color: 'var(--text-dim)', letterSpacing: '1px', maxWidth: '560px', lineHeight: '1.7' }}>
    Extra games and content distributed through the HackerOS Games addon pack.
    Installs into <code style={{ color: 'var(--yellow)' }}>/usr/share/HackerOS/Scripts/HackerOS-Games/addons/</code>.
    </div>
    </div>
    {status === 'installed' && (
      <button onClick={refresh} style={ghostBtn}>
      <RefreshCw size={11} /> RESCAN
      </button>
    )}
    </div>

    {status === 'unsupported' && (
      <Notice icon={<AlertTriangle size={13} />} color="var(--yellow)">
      Addon management requires the HackerOS Games desktop app — run this from the installed launcher to install or play addons.
      </Notice>
    )}

    {status === 'checking' && (
      <Notice icon={<Loader2 size={13} className="spin" />} color="var(--text-dim)">
      Checking addon installation status…
      </Notice>
    )}

    {status === 'not-installed' && (
      <div style={{
        maxWidth: '560px', padding: '32px',
        background: 'var(--surface)', border: '1px dashed var(--border)',
                                    textAlign: 'center',
      }}>
      <PackageSearch size={32} style={{ margin: '0 auto 14px', opacity: 0.5, color: 'var(--accent)' }} />
      <div style={{
        fontFamily: 'Orbitron, monospace', fontSize: '13px', fontWeight: 700,
        color: 'var(--text)', letterSpacing: '2px', marginBottom: '10px',
      }}>
      ADDON PACK NOT INSTALLED
      </div>
      <p style={{ fontSize: '11px', color: 'var(--text-dim)', lineHeight: '1.8', marginBottom: '22px' }}>
      No addons directory was found on this system. Installing the addon pack downloads{' '}
      <code style={{ color: 'var(--yellow)' }}>addons.hl</code> from the HackerOS-Games repository to{' '}
      <code style={{ color: 'var(--yellow)' }}>/tmp</code> and runs it with{' '}
      <code style={{ color: 'var(--yellow)' }}>hl run</code>. Additional addon games (like{' '}
      <span style={{ color: 'var(--accent)' }}>Parkour Runner</span>) will appear here automatically once installed.
      </p>
      <button onClick={handleInstall} disabled={installing} style={primaryBtn(installing)}>
      {installing ? <Loader2 size={13} className="spin" /> : <Download size={13} />}
      {installing ? 'INSTALLING…' : 'INSTALL ADDONS'}
      </button>
      {installError && (
        <div style={{ marginTop: '16px' }}>
        <Notice icon={<AlertTriangle size={13} />} color="var(--red)">{installError}</Notice>
        </div>
      )}
      </div>
    )}

    {status === 'installed' && (
      <>
      <div style={{ marginBottom: '20px' }}>
      <Notice icon={<CheckCircle2 size={13} />} color="var(--green)">
      Addon pack detected. {ADDON_GAMES.length} addon {ADDON_GAMES.length === 1 ? 'title' : 'titles'} registered.
      </Notice>
      </div>

      {launchError && (
        <div style={{ marginBottom: '16px' }}>
        <Notice icon={<AlertTriangle size={13} />} color="var(--red)">{launchError}</Notice>
        </div>
      )}

      <div style={{
        display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(270px,1fr))',
                                gap: '14px', maxWidth: '880px',
      }}>
      {ADDON_GAMES.map(addon => {
        const available = availability[addon.id];
        const isLaunching = launching === addon.id;
        const canLaunch = available === true && !isLaunching;
        return (
          <div
          key={addon.id}
          className="game-card"
          style={{ padding: '20px', '--card-color': addon.color } as React.CSSProperties}
          >
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '12px' }}>
          <div style={{
            width: '38px', height: '38px', flexShrink: 0,
            border: `1px solid ${addon.color}33`,
            background: `rgba(${addon.rgb},0.06)`,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                overflow: 'hidden',
          }}>
          <img
          src={addon.icon} alt={addon.name}
          style={{ width: '30px', height: '30px', objectFit: 'contain' }}
          onError={e => { (e.currentTarget as HTMLImageElement).style.display = 'none'; }}
          />
          </div>
          <div style={{
            display: 'inline-flex', alignItems: 'center', gap: '4px',
            padding: '3px 8px',
            background: `rgba(${addon.rgb},0.08)`,
                border: `1px solid ${addon.color}30`,
                fontSize: '9px', color: addon.color, letterSpacing: '1px',
          }}>
          ADDON
          </div>
          </div>
          <div style={{
            fontFamily: 'Orbitron, monospace', fontSize: '12px', fontWeight: 700,
            color: 'var(--text)', letterSpacing: '1px', marginBottom: '6px',
          }}>
          {addon.name}
          </div>
          <div style={{ fontSize: '9px', color: 'var(--text-dim)', letterSpacing: '1px', marginBottom: '8px' }}>
          {addon.genre.toUpperCase()}
          </div>
          <div style={{ fontSize: '11px', color: 'var(--text-dim)', lineHeight: '1.6', marginBottom: '16px' }}>
          {addon.description}
          </div>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <span style={{ fontSize: '9px', color: 'var(--text-dim)' }}>{addon.version}</span>
          <button
          disabled={!canLaunch}
          onClick={() => handleLaunch(addon.id)}
          style={{
            display: 'flex', alignItems: 'center', gap: '5px',
            padding: '5px 12px',
            background: canLaunch ? `rgba(${addon.rgb},0.1)` : 'transparent',
                border: `1px solid ${canLaunch ? addon.color : '#2a2a2a'}`,
                color: canLaunch ? addon.color : '#3a3a3a',
                fontSize: '9px', letterSpacing: '2px', textTransform: 'uppercase',
                cursor: canLaunch ? 'pointer' : 'not-allowed',
                fontFamily: 'Share Tech Mono, monospace', transition: 'all 0.15s',
          }}
          >
          {isLaunching
            ? <><Loader2 size={9} className="spin" /> LAUNCHING</>
            : available === false
            ? <><Lock size={9} /> MISSING</>
            : <><Play size={9} /> LAUNCH</>}
            </button>
            </div>
            </div>
        );
      })}
      </div>
      </>
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

const primaryBtn = (busy: boolean): React.CSSProperties => ({
  display: 'inline-flex', alignItems: 'center', gap: '8px',
  padding: '12px 28px',
  background: busy ? 'rgba(var(--accent-rgb),0.18)' : 'rgba(var(--accent-rgb),0.08)',
                                                            border: '1px solid var(--accent)',
                                                            color: 'var(--accent)', cursor: busy ? 'wait' : 'pointer',
                                                            fontFamily: 'Orbitron, monospace', fontSize: '11px', fontWeight: 700,
                                                            letterSpacing: '3px', textTransform: 'uppercase', transition: 'all 0.2s',
});

export default AddonsSection;
