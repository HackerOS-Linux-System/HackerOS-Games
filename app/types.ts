export interface GameConfig {
  id: string;
  name: string;
  description: string;
  longDescription: string;
  color: string;
  rgb: string;
  icon: string;
  genre: string;
  version: string;
  available: boolean;
}

export interface GamePlaytime {
  game_id: string;
  total_seconds: number;
  last_played: number;
  sessions: number;
}

export interface GameSettings {
  fullscreen: boolean;
  resolution: string;
  volume: number;
  /** Extra command-line arguments appended when launching the game. */
  launchArgs: string;
}

export type NavSection = 'games' | 'addons' | 'store' | 'settings' | 'about';

/** A game shipped through the HackerOS Games addon pack. */
export interface AddonGameConfig {
  id: string;
  name: string;
  description: string;
  genre: string;
  version: string;
  color: string;
  rgb: string;
  icon: string;
  /** Filename of the .love archive inside the addons directory. */
  loveFile: string;
}

/** Global, application-wide preferences (separate from per-game settings). */
export interface AppSettings {
  language: 'en' | 'pl';
  particlesEnabled: boolean;
  /** When enabled, the title bar's close button minimizes instead of quitting. */
  minimizeOnClose: boolean;
  /** Re-check addon installation status whenever the Addons tab is opened. */
  autoCheckAddons: boolean;
  /** Hex color used for the UI accent (logo, active tab, highlights, particles). */
  accentColor: string;
}

export interface AccentPreset {
  name: string;
  hex: string;
  rgb: string;
}

/** A single entry from the HackerOS Community Games store listing. */
export interface CommunityGame {
  id: number;
  title: string;
  genre: string;
  description: string;
  install: string;
  repo: string;
  image: string;
}
