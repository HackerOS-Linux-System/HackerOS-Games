import { COMMUNITY_GAMES_URL } from './constants';
import type {
  AppSettings, CommunityGame, CommunityGameInstall, GamePlaytime, GameSettings,
} from './types';

/** True when running inside the Silver shell (false in a plain browser / unit test). */
export const isSilver = (): boolean => typeof silver !== 'undefined' && silver !== null;

const call = <T>(command: string, args?: Record<string, unknown>): Promise<T> =>
  silver.invoke<T>(command, args);

// ───────────────────────── background jobs ─────────────────────────
// Long operations (git clone, downloads, the addon installer) run as Silver tasks: the H# command
// queues the job and the result arrives later as the `silver://task` event {id, output}.

const waiters = new Map<string, (output: string) => void>();
let listening = false;
let jobSeq = 0;

const ensureTaskListener = () => {
  if (listening || !isSilver()) return;
  listening = true;
  silver.listen<SilverTaskPayload | string>('silver://task', raw => {
    const p: SilverTaskPayload = typeof raw === 'string' ? JSON.parse(raw) : raw;
    const done = waiters.get(p.id);
    if (done) {
      waiters.delete(p.id);
      done(p.output ?? '');
    }
  });
};

/** Registers the waiter first (so a fast job can't finish unnoticed), then starts the job. */
const runJob = async (jobId: string, start: () => Promise<unknown>): Promise<string> => {
  ensureTaskListener();
  const finished = new Promise<string>(resolve => waiters.set(jobId, resolve));
  try {
    await start();
  } catch (e) {
    waiters.delete(jobId);
    throw e;
  }
  return finished;
};

/** Job scripts print "OK" on success or "ERR:<message>" on failure. */
const expectOk = (output: string) => {
  const out = output.trim();
  if (out === 'OK' || out.endsWith('\nOK')) return;
  const m = out.match(/ERR:([^\n]*)/);
  throw new Error(m ? m[1].trim() : out || 'The task ended without a result');
};

// ───────────────────────── community list ─────────────────────────

/** The published list.json has had trailing commas before — tolerate them. */
export const parseLooseJson = <T>(text: string): T =>
  JSON.parse(text.replace(/,\s*([\]}])/g, '$1')) as T;

export const fetchCommunityGames = async (): Promise<CommunityGame[]> => {
  const res = await fetch(COMMUNITY_GAMES_URL);
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  const data = parseLooseJson<Record<string, CommunityGame[]>>(await res.text());
  const list = data?.['HackerOS-Community-Games'];
  return Array.isArray(list) ? list.filter(g => g && g.title) : [];
};

// ───────────────────────── commands ─────────────────────────

export const api = {
  // built-in games
  checkGameExists: async (gameId: string) =>
    (await call<{ exists: boolean }>('check_game_exists', { gameId })).exists,
  launchGame: (gameId: string) => call<{ ok: boolean }>('launch_game', { gameId }),
  getAllPlaytime: () => call<Record<string, GamePlaytime>>('get_all_playtime'),

  // settings
  getAllGameSettings: () => call<Record<string, GameSettings>>('get_all_game_settings'),
  saveGameSettings: (gameId: string, settings: GameSettings) =>
    call<{ ok: boolean }>('save_game_settings', { gameId, settings }),
  getAppSettings: () => call<AppSettings>('get_app_settings'),
  saveAppSettings: (settings: AppSettings) =>
    call<{ ok: boolean }>('save_app_settings', { settings }),

  // addon pack
  checkAddonsInstalled: async () =>
    (await call<{ installed: boolean }>('check_addons_installed')).installed,
  checkAddonGameExists: async (addonId: string) =>
    (await call<{ exists: boolean }>('check_addon_game_exists', { addonId })).exists,
  launchAddonGame: (addonId: string) => call<{ ok: boolean }>('launch_addon_game', { addonId }),
  installAddons: async () => {
    const out = await runJob('addons', () => call('install_addons', { jobId: 'addons' }));
    expectOk(out);
  },

  // community store
  installCommunityGame: async (gameId: string, title: string, installUrl: string) => {
    const jobId = `install-${gameId}`;
    const out = await runJob(jobId, () => call('install_community_game', { gameId, title, installUrl, jobId }));
    expectOk(out);
    return call<CommunityGameInstall>('finalize_community_install', { gameId, title });
  },
  launchCommunityGame: (gameId: string) => call<{ ok: boolean }>('launch_community_game', { gameId }),
  uninstallCommunityGame: (gameId: string) => call<{ ok: boolean }>('uninstall_community_game', { gameId }),
  getCommunityInstalls: () => call<Record<string, CommunityGameInstall>>('get_community_installs'),

  openUrl: (url: string) => call<{ ok: boolean }>('open_url', { url }),

  /** Downloads remote artwork into the local cache (Silver draws local files only) → {url: localPath}. */
  cacheImages: async (urls: string[]): Promise<Record<string, string>> => {
    if (urls.length === 0) return {};
    const jobId = `images-${++jobSeq}`;
    const out = await runJob(jobId, () => call('cache_images', { urls, jobId }));
    const map: Record<string, string> = {};
    for (const line of out.split('\n')) {
      const [url, path] = line.split('\t');
      if (url && path) map[url] = path.trim();
    }
    return map;
  },
};

// ───────────────────────── window ─────────────────────────

let maximized = false;

export const windowControl = (action: 'minimize' | 'maximize' | 'close') => {
  if (!isSilver()) return;
  if (action === 'minimize') void silver.window.minimize();
  else if (action === 'close') void silver.window.close();
  else {
    // Silver has no isMaximized(); track the toggle ourselves.
    maximized = !maximized;
    void (maximized ? silver.window.maximize() : silver.window.restore());
  }
};
