import { createSignal, For, Match, Show, Switch } from 'solid-js';
import type { JSX } from 'solid-js';
import type { AppSettings, GameConfig, GameSettings } from '../types';
import {
  ACCENT_PRESETS, DEFAULT_GAME_SETTINGS, hexToRgb, LANGUAGES, LAUNCHER_VERSION, RESOLUTIONS,
} from '../constants';
import {
  ChevronRight, Cpu, Globe, HardDrive, Info, Maximize2, Monitor, Palette, PowerOff, Puzzle, RotateCcw,
  Save, Shield, SlidersHorizontal, Sparkles, Terminal, Volume2,
} from '../icons';
import { ToggleBtn } from './ui';

interface Props {
  games: GameConfig[];
  gameSettings: Record<string, GameSettings>;
  appSettings: AppSettings;
  onSaveGame: (gameId: string, settings: GameSettings) => void;
  onSaveApp: (settings: AppSettings) => void;
}

const GENERAL = '__general__';
const ABOUT_SYSTEM = '__system__';

const SettingsSection = (p: Props) => {
  const [sel, setSel] = createSignal<string>(GENERAL);
  const [local, setLocal] = createSignal<Record<string, GameSettings>>(
    Object.fromEntries(p.games.map(g => [g.id, { ...(p.gameSettings[g.id] ?? DEFAULT_GAME_SETTINGS) }])),
  );
  const [localApp, setLocalApp] = createSignal<AppSettings>({ ...p.appSettings });
  const [saved, setSaved] = createSignal<string | null>(null);

  const game = () => p.games.find(g => g.id === sel());
  const cfg = (): GameSettings => local()[sel()] ?? { ...DEFAULT_GAME_SETTINGS };

  const set = <K extends keyof GameSettings>(k: K, v: GameSettings[K]) =>
    setLocal(prev => ({ ...prev, [sel()]: { ...(prev[sel()] ?? DEFAULT_GAME_SETTINGS), [k]: v } }));
  const setApp = <K extends keyof AppSettings>(k: K, v: AppSettings[K]) =>
    setLocalApp(prev => ({ ...prev, [k]: v }));

  const save = () => {
    if (sel() === GENERAL) p.onSaveApp(localApp());
    else if (sel() !== ABOUT_SYSTEM) p.onSaveGame(sel(), cfg());
    const id = sel();
    setSaved(id);
    setTimeout(() => setSaved(s => (s === id ? null : s)), 2200);
  };

  const reset = () => {
    if (sel() === GENERAL) setLocalApp({ ...p.appSettings });
    else if (sel() !== ABOUT_SYSTEM) setLocal(prev => ({ ...prev, [sel()]: { ...DEFAULT_GAME_SETTINGS } }));
  };

  const accentColor = () => (sel() === GENERAL ? localApp().accentColor : (game()?.color ?? '#2a8fff'));
  const accentRgb = () => (sel() === GENERAL ? hexToRgb(localApp().accentColor) : (game()?.rgb ?? '42,143,255'));

  const OffOn = (pp: { value: boolean; onChange: (v: boolean) => void; color: string; rgb: string }) => (
    <div class="row gap6">
      <For each={['Off', 'On']}>
        {(label, i) => (
          <ToggleBtn active={pp.value === (i() === 1)} color={pp.color} rgb={pp.rgb} onClick={() => pp.onChange(i() === 1)}>
            {label}
          </ToggleBtn>
        )}
      </For>
    </div>
  );

  return (
    <div class="split">
      {/* Sidebar */}
      <div class="sidebar w210">
        <SidebarBtn label="General" icon={<SlidersHorizontal size={12} />} active={sel() === GENERAL} color="#2a8fff" rgb="42,143,255" accent onClick={() => setSel(GENERAL)} />
        <SidebarBtn label="System Info" icon={<Cpu size={12} />} active={sel() === ABOUT_SYSTEM} color="#9d4eff" rgb="157,78,255" onClick={() => setSel(ABOUT_SYSTEM)} />
        <div class="side-head mid">GAME SETTINGS</div>
        <For each={p.games}>
          {g => <SidebarBtn label={g.name} active={sel() === g.id} color={g.color} rgb={g.rgb} onClick={() => setSel(g.id)} />}
        </For>
      </div>

      {/* Panel */}
      <div class="grow panel">
        <Switch>
          {/* ── General ── */}
          <Match when={sel() === GENERAL}>
            <PanelHeader title="General" subtitle="APPLICATION PREFERENCES — applied across HackerOS Games" color="var(--accent)" />
            <div class="form">
              <Card icon={<Globe size={14} />} title="Language" desc="Interface and date/time language." color={accentColor()}>
                <div class="row gap6">
                  <For each={LANGUAGES}>
                    {l => (
                      <ToggleBtn active={localApp().language === l.id} color={accentColor()} rgb={accentRgb()} onClick={() => setApp('language', l.id)}>
                        {l.label}
                      </ToggleBtn>
                    )}
                  </For>
                </div>
              </Card>

              <Card icon={<Sparkles size={14} />} title="Background Particles" desc="Animated particle field behind the UI." color={accentColor()}>
                <OffOn value={localApp().particlesEnabled} onChange={v => setApp('particlesEnabled', v)} color={accentColor()} rgb={accentRgb()} />
              </Card>

              <Card icon={<PowerOff size={14} />} title="Close Button" desc="What the titlebar close button does." color={accentColor()}>
                <div class="row gap6">
                  <For each={[{ label: 'Quit App', value: false }, { label: 'Minimize', value: true }]}>
                    {opt => (
                      <ToggleBtn active={localApp().minimizeOnClose === opt.value} color={accentColor()} rgb={accentRgb()} onClick={() => setApp('minimizeOnClose', opt.value)}>
                        {opt.label}
                      </ToggleBtn>
                    )}
                  </For>
                </div>
              </Card>

              <Card icon={<Puzzle size={14} />} title="Addon Auto-Detect" desc="Re-check addon installation whenever the Addons tab opens." color={accentColor()}>
                <OffOn value={localApp().autoCheckAddons} onChange={v => setApp('autoCheckAddons', v)} color={accentColor()} rgb={accentRgb()} />
              </Card>

              <Card icon={<Palette size={14} />} title="Accent Color" desc="Tints the UI, logo and particle field." color={accentColor()}>
                <div class="row gap8 wrap">
                  <For each={ACCENT_PRESETS}>
                    {pr => {
                      const active = () => localApp().accentColor.toLowerCase() === pr.hex.toLowerCase();
                      return (
                        <button
                          class="swatch"
                          title={pr.name}
                          onClick={() => setApp('accentColor', pr.hex)}
                          style={`background:${pr.hex};border:${active() ? '2px solid #c8d8e8' : '1px solid #2a2a2a'};box-shadow:${active() ? `0 0 10px rgba(${pr.rgb},0.6)` : 'none'};`}
                        />
                      );
                    }}
                  </For>
                </div>
              </Card>

              <Actions color={accentColor()} rgb={accentRgb()} saved={saved() === GENERAL} onSave={save} onReset={reset} />
              <p class="note">General preferences are stored alongside per-game configuration and restored next time HackerOS Games launches.</p>
            </div>
          </Match>

          {/* ── System Info ── */}
          <Match when={sel() === ABOUT_SYSTEM}>
            <SystemInfoPanel />
          </Match>

          {/* ── Per-game ── */}
          <Match when={game()}>
            <PanelHeader title={game()!.name} subtitle="LAUNCH SETTINGS — applied on next game start" color={game()!.color} />
            <div class="form">
              <Card icon={<Maximize2 size={14} />} title="Fullscreen" desc="Start the game in full screen." color={game()!.color}>
                <OffOn value={cfg().fullscreen} onChange={v => set('fullscreen', v)} color={game()!.color} rgb={game()!.rgb} />
              </Card>

              <Card icon={<Monitor size={14} />} title="Resolution" desc="Target resolution." color={game()!.color}>
                <div class="row gap5 wrap">
                  <For each={RESOLUTIONS}>
                    {r => (
                      <ToggleBtn active={cfg().resolution === r} color={game()!.color} rgb={game()!.rgb} onClick={() => set('resolution', r)}>{r}</ToggleBtn>
                    )}
                  </For>
                </div>
              </Card>

              <Card icon={<Volume2 size={14} />} title="Volume" desc={`Master volume: ${cfg().volume}%`} color={game()!.color}>
                <div class="row gap14 center">
                  <VolumeBar value={cfg().volume} color={game()!.color} rgb={game()!.rgb} onChange={v => set('volume', v)} />
                  <span class="vol-num" style={`color:${game()!.color};`}>{cfg().volume}%</span>
                </div>
              </Card>

              <Card icon={<Terminal size={14} />} title="Launch Arguments" desc="Extra command-line flags passed to the game binary." color={game()!.color}>
                <input
                  class="text-input"
                  value={cfg().launchArgs}
                  onInput={e => set('launchArgs', e.currentTarget.value)}
                  placeholder="e.g. --debug --no-vsync"
                />
              </Card>

              <Card icon={<Shield size={14} />} title="Sandbox" desc="This game runs inside an isolated environment." color="#00ff41">
                <div class="dim s10 lh18">
                  <div class="row gap6 center mb4"><span class="ok s9">✓</span> Network access: <span class="bad">disabled</span></div>
                  <div class="row gap6 center mb4"><span class="ok s9">✓</span> Filesystem: read-only (game dir only)</div>
                  <div class="row gap6 center"><span class="ok s9">✓</span> Isolation: bubblewrap / firejail</div>
                </div>
              </Card>

              <Actions color={game()!.color} rgb={game()!.rgb} saved={saved() === sel()} onSave={save} onReset={reset} />
              <p class="note">Settings are passed as launch flags where supported by each game. Not all games honour every option.</p>
            </div>
          </Match>
        </Switch>
      </div>
    </div>
  );
};

/** Silver has no <input type=range>: a bar of 20 clickable 5 % segments plus −/+ steppers. */
const VolumeBar = (p: { value: number; color: string; rgb: string; onChange: (v: number) => void }) => {
  const clamp = (v: number) => Math.max(0, Math.min(100, v));
  return (
    <div class="row gap6 center">
      <button class="step" onClick={() => p.onChange(clamp(p.value - 5))}>−</button>
      <div class="vbar">
        <For each={Array.from({ length: 20 }, (_, i) => i)}>
          {i => (
            <div
              class="vseg"
              onClick={() => p.onChange((i + 1) * 5)}
              style={`background:${(i + 1) * 5 <= p.value ? p.color : '#1a2535'};`}
            />
          )}
        </For>
      </div>
      <button class="step" onClick={() => p.onChange(clamp(p.value + 5))}>+</button>
    </div>
  );
};

const SystemInfoPanel = () => {
  const rows: [string, string][] = [
    ['Launcher', `HackerOS Games v${LAUNCHER_VERSION}`],
    ['Framework', 'H# + TypeScript + Solid.js + Silver'],
    ['Game base path', '/usr/share/HackerOS/Scripts/HackerOS-Games'],
    ['Save data', '~/.hackeros-games/'],
    ['Sandbox', 'bubblewrap (bwrap) — kernel namespaces'],
    ['Fallback', 'firejail → none'],
    ['Store installs', '~/.hackeros-games/community_installs.json'],
    ['Config file', '~/.hackeros-games/app_settings.json'],
  ];
  return (
    <>
      <PanelHeader title="System Info" subtitle="RUNTIME ENVIRONMENT & PATHS" color="#9d4eff" />
      <div class="info-wrap">
        <div class="info-box">
          <For each={rows}>
            {([k, v]) => (
              <div class="info-row">
                <span class="dim ls1 noshrink">{k}</span>
                <span class="info-val">{v}</span>
              </div>
            )}
          </For>
        </div>
        <div class="callout green">
          <div class="callout-head" style="color:#00ff41;"><Info size={12} /> SANDBOX MODEL</div>
          <p class="callout-text">
            All games (built-in and community) are launched inside a lightweight bubblewrap sandbox.
            The sandbox binds <code class="code">/usr</code>, <code class="code">/bin</code> and <code class="code">/lib</code> read-only,
            mounts a private <code class="code">/tmp</code>, disables network access, and isolates PID/UTS namespaces.
            Only the save-data directory <code class="code">~/.hackeros-games</code> is writable.
            If bubblewrap is not available, firejail is used as a fallback; otherwise games run directly.
            Performance impact is negligible — namespace isolation is kernel-native.
          </p>
        </div>
        <div class="callout red">
          <div class="callout-head" style="color:#ff1744;"><HardDrive size={12} /> COMMUNITY GAME TYPES</div>
          <p class="callout-text">
            Git repos → cloned and auto-detected (Python / Ruby / Lua / binary).
            ZIP / TAR.GZ archives → extracted.
            Direct binaries / EXEs → downloaded (EXE files are not sandboxable on Linux).
            The detected type is shown on the Store card after install.
          </p>
        </div>
      </div>
    </>
  );
};

const PanelHeader = (p: { title: string; subtitle: string; color: string }) => (
  <div class="mb28">
    <div class="panel-title" style={`color:${p.color};`}>{p.title}</div>
    <div class="dim s9 ls2">{p.subtitle}</div>
  </div>
);

const SidebarBtn = (p: {
  label: string; icon?: JSX.Element; active: boolean; color: string; rgb: string; accent?: boolean; onClick: () => void;
}) => (
  <button
    class={`side-btn${p.active ? ' active' : ''}`}
    onClick={p.onClick}
    style={p.active ? `background:rgba(${p.rgb},0.08);border:1px solid ${p.color}40;color:${p.accent ? 'var(--accent)' : p.color};` : ''}
  >
    <span class="row gap8 center">{p.icon}{p.label}</span>
    <Show when={p.active}><ChevronRight size={11} /></Show>
  </button>
);

const Actions = (p: { color: string; rgb: string; saved: boolean; onSave: () => void; onReset: () => void }) => (
  <div class="row gap10 mt6">
    <button
      class="save-btn"
      onClick={p.onSave}
      style={`background:rgba(${p.rgb},${p.saved ? 0.2 : 0.08});border:1px solid ${p.color};color:${p.color};box-shadow:${p.saved ? `0 0 14px rgba(${p.rgb},0.3)` : 'none'};`}
    >
      <Save size={12} />{p.saved ? 'SAVED!' : 'SAVE'}
    </button>
    <button class="reset-btn" onClick={p.onReset}><RotateCcw size={12} /> RESET</button>
  </div>
);

const Card = (p: { icon: JSX.Element; title: string; desc: string; color: string; children: JSX.Element }) => (
  <div class="card">
    <div class="row gap7 center mb5">
      <span style={`color:${p.color};`}>{p.icon}</span>
      <span class="card-h">{p.title.toUpperCase()}</span>
    </div>
    <div class="dim s10 ls1 mb12">{p.desc}</div>
    {p.children}
  </div>
);

export default SettingsSection;
