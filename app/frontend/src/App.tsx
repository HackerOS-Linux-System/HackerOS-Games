import { createEffect, createSignal, For, Match, onCleanup, onMount, Show, Switch } from 'solid-js';
import type { JSX } from 'solid-js';
import { api, isSilver, windowControl } from './api';
import { DEFAULT_APP_SETTINGS, GAMES, hexToRgb, LAUNCHER_VERSION } from './constants';
import { fmtClock } from './format';
import type { AppSettings, GamePlaytime, GameSettings, NavSection } from './types';
import { Gamepad2, Info, Minus, Puzzle, Settings, Square, Store, X } from './icons';
import GamesSection from './components/GamesSection';
import AddonsSection from './components/AddonsSection';
import StoreSection from './components/StoreSection';
import SettingsSection from './components/SettingsSection';
import AboutSection from './components/AboutSection';
import { Particles } from './components/Particles';

const NAV: { id: NavSection; label: string; icon: () => JSX.Element }[] = [
  { id: 'games', label: 'Library', icon: () => <Gamepad2 size={13} /> },
  { id: 'addons', label: 'Addons', icon: () => <Puzzle size={13} /> },
  { id: 'store', label: 'Store', icon: () => <Store size={13} /> },
  { id: 'settings', label: 'Settings', icon: () => <Settings size={13} /> },
  { id: 'about', label: 'About', icon: () => <Info size={13} /> },
];

const App = () => {
  const [section, setSection] = createSignal<NavSection>('games');
  const [playtime, setPlaytime] = createSignal<Record<string, GamePlaytime>>({});
  const [gameSettings, setGameSettings] = createSignal<Record<string, GameSettings>>({});
  const [appSettings, setAppSettings] = createSignal<AppSettings>(DEFAULT_APP_SETTINGS);
  const [loaded, setLoaded] = createSignal(false);
  const [clock, setClock] = createSignal(new Date());

  const accentRgb = () => hexToRgb(appSettings().accentColor);

  // accent colour → CSS variables on :root (everything in style.css reads var(--accent) / var(--accent-rgb))
  createEffect(() => {
    const root = document.documentElement;
    root.style.setProperty('--accent', appSettings().accentColor);
    root.style.setProperty('--accent-rgb', accentRgb());
  });

  const refreshPlaytime = () => {
    if (isSilver()) api.getAllPlaytime().then(setPlaytime).catch(() => {});
  };

  onMount(() => {
    if (isSilver()) {
      refreshPlaytime();
      api.getAllGameSettings().then(setGameSettings).catch(() => {});
      api.getAppSettings().then(s => setAppSettings(s)).catch(() => {}).finally(() => setLoaded(true));
      // playtime is written when a game exits — pick it up when the launcher regains focus
      const off = silver.listen('silver://focus', refreshPlaytime);
      onCleanup(off);
    } else {
      setLoaded(true);
    }
    // minute resolution, refreshed twice a minute: every repaint costs memory in Silver 0.5, so no per-second ticks
    const id = setInterval(() => setClock(new Date()), 30000);
    onCleanup(() => clearInterval(id));
  });

  let pollTimer: ReturnType<typeof setInterval> | undefined;
  const handleGameLaunch = (gameId: string) => {
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
    // keep the library fresh while the game runs (one poller, stops after an hour)
    if (pollTimer) clearInterval(pollTimer);
    pollTimer = setInterval(refreshPlaytime, 30000);
    setTimeout(() => { if (pollTimer) clearInterval(pollTimer); }, 3600000);
  };
  onCleanup(() => { if (pollTimer) clearInterval(pollTimer); });

  const handleSaveGameSettings = async (gameId: string, settings: GameSettings) => {
    setGameSettings(prev => ({ ...prev, [gameId]: settings }));
    if (isSilver()) await api.saveGameSettings(gameId, settings).catch(() => {});
  };

  const handleSaveAppSettings = async (settings: AppSettings) => {
    setAppSettings(settings);
    if (isSilver()) await api.saveAppSettings(settings).catch(() => {});
  };

  const onClose = () => windowControl(appSettings().minimizeOnClose ? 'minimize' : 'close');

  return (
    <div class="app scanlines crt-vignette">
      <Show when={appSettings().particlesEnabled}>
        <Particles accentRgb={accentRgb()} />
      </Show>

      {/* Title bar — `app-region: drag` makes it the window drag handle (frameless window) */}
      <div class="titlebar">
        <div class="logo">
          <div class="logo-dot" />
          <span class="logo-text">HACKEROS<span class="logo-games">GAMES</span></span>
          <span class="dim s9 ls1">v{LAUNCHER_VERSION.split('.').slice(0, 2).join('.')}</span>
        </div>

        <div class="nav">
          <For each={NAV}>
            {item => (
              <button class={`nav-tab${section() === item.id ? ' active' : ''}`} onClick={() => setSection(item.id)}>
                {item.icon()}{item.label}
              </button>
            )}
          </For>
        </div>

        <div class="tb-right">
          <span class="clock">{fmtClock(clock())}</span>
          <div class="row">
            <button class="wc wc-min" title="Minimize" onClick={() => windowControl('minimize')}><Minus size={11} /></button>
            <button class="wc wc-max" title="Maximize / Restore" onClick={() => windowControl('maximize')}><Square size={10} /></button>
            <button class="wc wc-close" title={appSettings().minimizeOnClose ? 'Minimize (close button set to minimize)' : 'Close'} onClick={onClose}><X size={11} /></button>
          </div>
        </div>
      </div>

      {/* Main content */}
      <div class="content">
        <Switch>
          <Match when={section() === 'games'}>
            <GamesSection games={GAMES} playtime={playtime()} onLaunch={handleGameLaunch} />
          </Match>
          <Match when={section() === 'addons'}>
            <AddonsSection autoCheck={appSettings().autoCheckAddons} />
          </Match>
          <Match when={section() === 'store'}>
            <StoreSection language={appSettings().language} />
          </Match>
          <Match when={section() === 'settings'}>
            {/* wait for the saved settings so the form starts from them */}
            <Show when={loaded()}>
              <SettingsSection
                games={GAMES}
                gameSettings={gameSettings()}
                appSettings={appSettings()}
                onSaveGame={handleSaveGameSettings}
                onSaveApp={handleSaveAppSettings}
              />
            </Show>
          </Match>
          <Match when={section() === 'about'}>
            <AboutSection />
          </Match>
        </Switch>
      </div>

      {/* Status bar */}
      <div class="statusbar">
        <span class="dim s9 ls2">SECURE CONNECTION ESTABLISHED // HACKEROS CORP © 2077</span>
        <span class="s9 ls1" style="color:#1a6fcc;">{GAMES.filter(g => g.available).length} GAMES INSTALLED</span>
      </div>
    </div>
  );
};

export default App;
