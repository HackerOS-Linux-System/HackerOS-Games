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

/** Global, application-wide preferences. */
export interface AppSettings {
  language: 'en' | 'pl';
  particlesEnabled: boolean;
  /** When enabled, the title bar close button minimizes instead of quitting. */
  minimizeOnClose: boolean;
  /** Re-check addon installation status whenever the Addons tab is opened. */
  autoCheckAddons: boolean;
  /** Hex color used for the UI accent. */
  accentColor: string;
}

export interface AccentPreset {
  name: string;
  hex: string;
  rgb: string;
}

/** A single entry from the HackerOS Community Games store listing (list.json). */
export interface CommunityGame {
  id: number;
  title: string;
  genre: string;
  /** Description in English. */
  'description-en': string;
  /** Description in Polish. */
  'description-pl': string;
  /** URL used to install (git repo, zip, binary, etc.) */
  install: string;
  /** Optional direct repository URL for browsing source. */
  repo?: string;
  authors: string;
  image: string;
}

/** A community game that has been installed locally. */
export interface CommunityGameInstall {
  game_id: string;
  title: string;
  /** Detected type: binary | python | ruby | love | zip | tar | unknown */
  install_type: string;
  install_path: string;
  installed_at: number;
}

