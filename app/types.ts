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
}

export type NavSection = 'games' | 'addons' | 'settings' | 'about';

export interface AddonConfig {
  id: string;
  name: string;
  description: string;
  targetGame: string;
  version: string;
  installed: boolean;
}
