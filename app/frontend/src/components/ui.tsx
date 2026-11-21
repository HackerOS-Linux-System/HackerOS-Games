import type { JSX } from 'solid-js';
import { Show } from 'solid-js';
import { Loader2 } from '../icons';

/** Busy indicator. Static on purpose — Silver 0.5 leaks memory on every animation frame, and installs can run for minutes. */
export const Spinner = (p: { size?: number }) => (
  <span class="spin"><Loader2 size={p.size ?? 13} /></span>
);

/** Coloured information strip. `color` is a CSS color (hex or var(--x)); the tint is built with rgba-free alpha suffixes. */
export const Notice = (p: { icon: JSX.Element; color: string; children: JSX.Element; hex?: string }) => (
  <div class="notice" style={`color:${p.color};background:${p.hex ?? p.color}0d;border:1px solid ${p.hex ?? p.color}30;`}>
    {p.icon}
    <span>{p.children}</span>
  </div>
);

/** Square artwork box; draws a glyph with the first letter when the game ships no PNG. */
export const IconBox = (p: {
  name: string; icon?: string; color: string; rgb: string; box: number; img: number; glow?: boolean;
}) => (
  <div
    class="icon-box"
    style={`width:${p.box}px;height:${p.box}px;border:1px solid ${p.color}${p.glow ? '44' : '33'};background:rgba(${p.rgb},${p.glow ? 0.06 : 0.05});${p.glow ? `box-shadow:0 0 40px rgba(${p.rgb},0.12);` : ''}`}
  >
    <Show
      when={p.icon}
      fallback={<span class="glyph" style={`color:${p.color};font-size:${Math.round(p.img * 0.55)}px;`}>{p.name.charAt(0)}</span>}
    >
      <img src={p.icon} alt={p.name} style={`width:${p.img}px;height:${p.img}px;object-fit:contain;`} />
    </Show>
  </div>
);

/** Solid-colour toggle button used throughout Settings. */
export const ToggleBtn = (p: {
  active: boolean; color: string; rgb: string; onClick: () => void; children: JSX.Element;
}) => (
  <button
    class={`tbtn${p.active ? ' active' : ''}`}
    style={p.active ? `background:rgba(${p.rgb},0.14);border:1px solid ${p.color};color:${p.color};` : ''}
    onClick={p.onClick}
  >
    {p.children}
  </button>
);
