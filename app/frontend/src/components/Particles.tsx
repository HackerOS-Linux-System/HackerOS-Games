import { For } from 'solid-js';

// Silver has no <canvas>, so the particle field is a set of absolutely positioned dots (DOM elements).
// They are static on purpose: every animation frame (CSS @keyframes or JS) is a repaint, and Silver 0.5
// leaks memory on each repaint. The drifting motion and connecting lines of the canvas version are not reproduced.

interface Dot { x: number; y: number; size: number; opacity: number }

const rand = (a: number, b: number) => a + Math.random() * (b - a);

const makeDots = (n: number): Dot[] =>
  Array.from({ length: n }, () => ({
    x: rand(0, 100),
    y: rand(0, 100),
    size: rand(1.5, 3.2),
    opacity: rand(0.15, 0.65),
  }));

const DOTS = makeDots(48);

/** `accentRgb` is an "r,g,b" string (same prop the React version took). */
export const Particles = (p: { accentRgb: string }) => (
  <div class="particles">
    <For each={DOTS}>
      {d => (
        <div
          class="dot"
          style={`left:${d.x}%;top:${d.y}%;width:${d.size}px;height:${d.size}px;background:rgba(${p.accentRgb},${d.opacity});`}
        />
      )}
    </For>
  </div>
);
