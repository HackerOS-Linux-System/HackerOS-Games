import { GameConfig, AddonGameConfig, AppSettings, AccentPreset, GameSettings } from './types';

export const GAMES: GameConfig[] = [
  {
    id: 'the-racer',
    name: 'The Racer',
    description: 'Motorsport management sim — build your team to glory.',
    longDescription: 'Take the role of a team principal across 5 prestigious racing series: Formula 1 2026, IndyCar, Formula E, WEC and GT3. Manage drivers, pit stops, strategy and R&D to climb the standings.',
    color: '#ff1744',
    rgb: '255,23,68',
    icon: './images/the-racer.png',
    genre: 'Management / Sim',
    version: '1.0.0',
    available: true,
  },
{
  id: 'cosmonaut',
  name: 'Cosmonaut',
  description: "Explore the cosmos in humanity's boldest space program.",
  longDescription: 'Take command of a fledgling space agency. Design rockets, plan missions, recruit astronauts and unravel the mysteries of the solar system — all inspired by the golden age of NASA exploration.',
  color: '#00cfff',
  rgb: '0,207,255',
  icon: './images/cosmonaut.png',
  genre: 'Exploration / Strategy',
  version: '0.1.0',
  available: false,
},
{
  id: 'starblaster',
  name: 'Starblaster',
  description: 'Dodge, graze and blast your way through enemy swarms.',
  longDescription: 'A bullet-hell space shooter with dynamic difficulty, combo multipliers, graze mechanics and a full save/load system. Survive endless waves of increasingly dangerous foes.',
  color: '#00ff41',
  rgb: '0,255,65',
  icon: './images/starblaster.png',
  genre: 'Shooter / Arcade',
  version: '0.6.0',
  available: true,
},
{
  id: 'bark-squadron',
  name: 'Bark Squadron',
  description: 'Physics-based dogfighting with jets, waves and water.',
  longDescription: 'Command a fighter jet in arcade dogfights with realistic physics — gravity, drag, stall speed, water skimming and afterburner effects. Three enemy types with unique AI, plus wave-based progression.',
  color: '#ff2d9b',
  rgb: '255,45,155',
  icon: './images/bark-squadron.png',
  genre: 'Action / Flight',
  version: '0.6.0',
  available: true,
},
{
  id: 'bit-jump',
  name: 'Bit Jump',
  description: 'Precision platformer across 8 hand-crafted levels.',
  longDescription: 'A Geometry Dash-inspired platformer built in LÖVE2D. Features moving platforms, rotating hazards, power-ups, a boss fight, multiple game modes (Normal, Time Attack, Endless, Practice), and full achievement support.',
  color: '#ffd600',
  rgb: '255,214,0',
  icon: './images/bit-jump.png',
  genre: 'Platformer',
  version: '0.6.0',
  available: true,
},
];

/**
 * Games shipped via the HackerOS Games addon pack
 * (https://github.com/HackerOS-Linux-System/HackerOS-Games/blob/main/addons.hl).
 * These only become available once the addon pack has been installed into
 * /usr/share/HackerOS/Scripts/HackerOS-Games/addons/.
 */
export const ADDON_GAMES: AddonGameConfig[] = [
  {
    id: 'parkour-runner',
    name: 'Parkour Runner',
    description: 'A fast, momentum-driven parkour platformer from the HackerOS community addon pack. Chain wall-runs, slides and jumps to clear every course as fast as possible.',
    genre: 'Action / Parkour',
    version: 'Addon',
    color: '#ff6b00',
    rgb: '255,107,0',
    icon: './images/parkour-runner.png',
    loveFile: 'parkour-runner.love',
  },
];

/** Raw GitHub URL the addon installer script (.hl) is downloaded from. */
export const ADDONS_HL_URL =
'https://raw.githubusercontent.com/HackerOS-Linux-System/HackerOS-Games/main/addons.hl';

/** Directory that, once present, indicates the addon pack is installed. */
export const ADDONS_DIR = '/usr/share/HackerOS/Scripts/HackerOS-Games/addons';

/** Raw GitHub URL of the HackerOS Community Games store listing. */
export const COMMUNITY_GAMES_URL =
'https://raw.githubusercontent.com/HackerOS-Linux-System/HackerOS-Games/main/HackerOS-Community-Games/list.json';

export const RESOLUTIONS = [
  '1280x720',
'1366x768',
'1600x900',
'1920x1080',
'2560x1440',
'3840x2160',
];

export const LANGUAGES: { id: AppSettings['language']; label: string }[] = [
  { id: 'en', label: 'English' },
{ id: 'pl', label: 'Polski' },
];

/** Accent color presets selectable in Settings → General. */
export const ACCENT_PRESETS: AccentPreset[] = [
  { name: 'Blue',   hex: '#2a8fff', rgb: '42,143,255' },
{ name: 'Green',  hex: '#00ff41', rgb: '0,255,65' },
{ name: 'Red',    hex: '#ff1744', rgb: '255,23,68' },
{ name: 'Pink',   hex: '#ff2d9b', rgb: '255,45,155' },
{ name: 'Yellow', hex: '#ffd600', rgb: '255,214,0' },
{ name: 'Orange', hex: '#ff6b00', rgb: '255,107,0' },
{ name: 'Purple', hex: '#9d4eff', rgb: '157,78,255' },
];

export const DEFAULT_APP_SETTINGS: AppSettings = {
  language: 'en',
  particlesEnabled: true,
  minimizeOnClose: false,
  autoCheckAddons: true,
  accentColor: '#2a8fff',
};

export const DEFAULT_GAME_SETTINGS: GameSettings = {
  fullscreen: false,
  resolution: '1920x1080',
  volume: 80,
  launchArgs: '',
};

/** Converts a "#rrggbb" hex string to an "r,g,b" string for use in rgba(). */
export const hexToRgb = (hex: string): string => {
  const m = hex.replace('#', '').match(/.{1,2}/g);
  if (!m || m.length !== 3) return '42,143,255';
  return m.map(c => parseInt(c, 16)).join(',');
};
