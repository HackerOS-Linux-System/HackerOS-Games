import { invoke } from '@tauri-apps/api/core';
import { GameSettings, HighScore } from '../types';

const isTauri = () => '__TAURI_INTERNALS__' in window;

const BRIEFINGS = [
  "Commander Bark! The Meow Luftwaffe is stealing our bones. Intercept them!",
  "Squirrel Squadron spotted over the Atlantic. Try not to get distracted!",
  "Enemy Ace 'Red Laser' is inbound. He's fast, but you're a good boy.",
  "Protect the fire hydrants at all costs. Scramble!",
  "Intelligence reports a large shipment of catnip. Shoot it down!",
  "They called you a 'Bad Dog'. Show them who's a Good Boy.",
  "Wave incoming! Remember: Aim for the tail!",
  "Dogfight Night protocol engaged. Bark loud, bite hard.",
  "The postman has joined the enemy fleet. This is personal.",
  "Tailwinds are strong today. Use the clouds for cover!",
  "Multiple bogeys detected at 3 o'clock. Afterburners engaged!",
  "The Squirrel High Command has deployed their Acorn Bombers. Take them down!",
];

export const generateBriefing = async (wave: number, _score: number): Promise<string> => {
  await new Promise(r => setTimeout(r, 700));
  const msg = BRIEFINGS[Math.floor(Math.random() * BRIEFINGS.length)];
  return `Wave ${wave} // ${msg}`;
};

export const submitScore = async (score: HighScore): Promise<HighScore[]> => {
  if (!isTauri()) return [];
  try {
    return await invoke<HighScore[]>('submit_score', { score });
  } catch {
    return [];
  }
};

export const getTopScores = async (difficulty: string, limit = 10): Promise<HighScore[]> => {
  if (!isTauri()) return [];
  try {
    return await invoke<HighScore[]>('get_top_scores', { difficulty, limit });
  } catch {
    return [];
  }
};

export const getPrefs = async (): Promise<GameSettings | null> => {
  if (!isTauri()) return null;
  try {
    const p = await invoke<{ difficulty: string; particles: boolean; highQuality: boolean; sensitivity: number; showHitboxes: boolean; volume: number }>('get_prefs');
    return {
      difficulty: p.difficulty as GameSettings['difficulty'],
      particles: p.particles,
      highQuality: p.highQuality,
      sensitivity: p.sensitivity,
      showHitboxes: p.showHitboxes,
      volume: p.volume,
    };
  } catch {
    return null;
  }
};

export const savePrefs = async (settings: GameSettings): Promise<void> => {
  if (!isTauri()) return;
  try {
    await invoke('save_prefs_cmd', { prefs: {
      difficulty: settings.difficulty,
      particles: settings.particles,
      highQuality: settings.highQuality,
      sensitivity: settings.sensitivity,
      showHitboxes: settings.showHitboxes,
      volume: settings.volume,
    }});
  } catch {}
};
