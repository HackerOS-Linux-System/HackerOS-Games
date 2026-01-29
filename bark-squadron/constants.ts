// Physics - JET STYLE
export const GRAVITY = 0.06;
export const DRAG = 0.99;   // Less drag for jets
export const THRUST = 0.25;  // Higher thrust
export const TURN_SPEED = 0.045; // Wider turns at high speed
export const MAX_SPEED = 9.0;   // Much faster
export const MIN_SPEED = 2.5;   // Stall speed higher

// Combat
export const BULLET_SPEED = 14; // Vulcan cannon speed
export const BULLET_LIFE = 100;
export const BULLET_COOLDOWN = 6; // High rate of fire
export const PLAYER_HP = 100;

// Water Level (Y position from center 0)
export const SEA_LEVEL = 350;

// Enemy Stats
export const ENEMY_STATS = {
  grunt: { hp: 40, speed: 7.0, turn: 0.04, color: '#475569', size: 24 }, // Grey MiG-ish
  ace: { hp: 80, speed: 9.5, turn: 0.06, color: '#1e293b', size: 22 },   // Black Stealth
  bomber: { hp: 200, speed: 4.5, turn: 0.02, color: '#3f6212', size: 35 } // Green Bomber
};

// Dimensions
export const PLAYER_SIZE = 24;
export const BULLET_SIZE = 3;

// Colors
export const COLOR_SKY_TOP = '#1e3a8a'; // Stratosphere Blue
export const COLOR_SKY_BOTTOM = '#93c5fd'; // Horizon Blue
export const COLOR_WATER_TOP = '#0284c7'; // Ocean
export const COLOR_WATER_BOTTOM = '#0c4a6e'; // Deep
export const COLOR_PLAYER = '#cbd5e1'; // Silver/Grey Jet
export const COLOR_BULLET_PLAYER = '#facc15'; // Tracer Yellow
export const COLOR_BULLET_ENEMY = '#f87171'; // Enemy Red Tracer
