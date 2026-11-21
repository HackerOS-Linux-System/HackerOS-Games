import type { JSX } from 'solid-js';

export interface IconProps {
  size?: number;
  /** Truthy → solid glyph (fill: currentColor) instead of an outline icon. */
  fill?: string;
  class?: string;
  style?: string | JSX.CSSProperties;
}

export const Gamepad2 = (p: IconProps) => (
  <svg width={p.size ?? 24} height={p.size ?? 24} viewBox="0 0 24 24" class={`ic${p.fill ? ' ic-fill' : ''}${p.class ? ' ' + p.class : ''}`} style={p.style}>
    <line x1="6" x2="10" y1="11" y2="11" />
    <line x1="8" x2="8" y1="9" y2="13" />
    <line x1="15" x2="15.01" y1="12" y2="12" />
    <line x1="18" x2="18.01" y1="10" y2="10" />
    <path d="M17.32 5H6.68a4 4 0 0 0-3.978 3.59c-.006.052-.01.101-.017.152C2.604 9.416 2 14.456 2 16a3 3 0 0 0 3 3c1 0 1.5-.5 2-1l1.414-1.414A2 2 0 0 1 9.828 16h4.344a2 2 0 0 1 1.414.586L17 18c.5.5 1 1 2 1a3 3 0 0 0 3-3c0-1.545-.604-6.584-.685-7.258-.007-.05-.011-.1-.017-.151A4 4 0 0 0 17.32 5z" />
  </svg>
);

export const Puzzle = (p: IconProps) => (
  <svg width={p.size ?? 24} height={p.size ?? 24} viewBox="0 0 24 24" class={`ic${p.fill ? ' ic-fill' : ''}${p.class ? ' ' + p.class : ''}`} style={p.style}>
    <path d="M19.439 7.85c-.049.322.059.648.289.878l1.568 1.568c.47.47.706 1.087.706 1.704s-.235 1.233-.706 1.704l-1.611 1.611a.98.98 0 0 1-.837.276c-.47-.07-.802-.48-.968-.925a2.501 2.501 0 1 0-3.214 3.214c.446.166.855.497.925.968a.979.979 0 0 1-.276.837l-1.61 1.61a2.404 2.404 0 0 1-1.705.707 2.402 2.402 0 0 1-1.704-.706l-1.568-1.568a1.026 1.026 0 0 0-.877-.29c-.493.074-.84.504-1.02.968a2.5 2.5 0 1 1-3.237-3.237c.464-.18.894-.527.967-1.02a1.026 1.026 0 0 0-.289-.877l-1.568-1.568A2.402 2.402 0 0 1 1.998 12c0-.617.236-1.234.706-1.704L4.23 8.77c.24-.24.581-.353.917-.303.515.077.877.528 1.073 1.01a2.5 2.5 0 1 0 3.259-3.259c-.482-.196-.933-.558-1.01-1.073-.05-.336.062-.676.303-.917l1.525-1.525A2.402 2.402 0 0 1 12 1.998c.617 0 1.234.236 1.704.706l1.568 1.568c.23.23.556.338.877.29.493-.074.84-.504 1.02-.968a2.5 2.5 0 1 1 3.237 3.237c-.464.18-.894.527-.967 1.02Z" />
  </svg>
);

export const Store = (p: IconProps) => (
  <svg width={p.size ?? 24} height={p.size ?? 24} viewBox="0 0 24 24" class={`ic${p.fill ? ' ic-fill' : ''}${p.class ? ' ' + p.class : ''}`} style={p.style}>
    <path d="m2 7 4.41-4.41A2 2 0 0 1 7.83 2h8.34a2 2 0 0 1 1.42.59L22 7" />
    <path d="M4 12v8a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-8" />
    <path d="M15 22v-4a2 2 0 0 0-2-2h-2a2 2 0 0 0-2 2v4" />
    <path d="M2 7h20" />
    <path d="M22 7v3a2 2 0 0 1-2 2v0a2.7 2.7 0 0 1-1.59-.63.7.7 0 0 0-.82 0A2.7 2.7 0 0 1 16 12a2.7 2.7 0 0 1-1.59-.63.7.7 0 0 0-.82 0A2.7 2.7 0 0 1 12 12a2.7 2.7 0 0 1-1.59-.63.7.7 0 0 0-.82 0A2.7 2.7 0 0 1 8 12a2.7 2.7 0 0 1-1.59-.63.7.7 0 0 0-.82 0A2.7 2.7 0 0 1 4 12v0a2 2 0 0 1-2-2V7" />
  </svg>
);

export const Settings = (p: IconProps) => (
  <svg width={p.size ?? 24} height={p.size ?? 24} viewBox="0 0 24 24" class={`ic${p.fill ? ' ic-fill' : ''}${p.class ? ' ' + p.class : ''}`} style={p.style}>
    <path d="M12.22 2h-.44a2 2 0 0 0-2 2v.18a2 2 0 0 1-1 1.73l-.43.25a2 2 0 0 1-2 0l-.15-.08a2 2 0 0 0-2.73.73l-.22.38a2 2 0 0 0 .73 2.73l.15.1a2 2 0 0 1 1 1.72v.51a2 2 0 0 1-1 1.74l-.15.09a2 2 0 0 0-.73 2.73l.22.38a2 2 0 0 0 2.73.73l.15-.08a2 2 0 0 1 2 0l.43.25a2 2 0 0 1 1 1.73V20a2 2 0 0 0 2 2h.44a2 2 0 0 0 2-2v-.18a2 2 0 0 1 1-1.73l.43-.25a2 2 0 0 1 2 0l.15.08a2 2 0 0 0 2.73-.73l.22-.39a2 2 0 0 0-.73-2.73l-.15-.08a2 2 0 0 1-1-1.74v-.5a2 2 0 0 1 1-1.74l.15-.09a2 2 0 0 0 .73-2.73l-.22-.38a2 2 0 0 0-2.73-.73l-.15.08a2 2 0 0 1-2 0l-.43-.25a2 2 0 0 1-1-1.73V4a2 2 0 0 0-2-2z" />
    <circle cx="12" cy="12" r="3" />
  </svg>
);

export const Info = (p: IconProps) => (
  <svg width={p.size ?? 24} height={p.size ?? 24} viewBox="0 0 24 24" class={`ic${p.fill ? ' ic-fill' : ''}${p.class ? ' ' + p.class : ''}`} style={p.style}>
    <circle cx="12" cy="12" r="10" />
    <path d="M12 16v-4" />
    <path d="M12 8h.01" />
  </svg>
);

export const Minus = (p: IconProps) => (
  <svg width={p.size ?? 24} height={p.size ?? 24} viewBox="0 0 24 24" class={`ic${p.fill ? ' ic-fill' : ''}${p.class ? ' ' + p.class : ''}`} style={p.style}>
    <path d="M5 12h14" />
  </svg>
);

export const Square = (p: IconProps) => (
  <svg width={p.size ?? 24} height={p.size ?? 24} viewBox="0 0 24 24" class={`ic${p.fill ? ' ic-fill' : ''}${p.class ? ' ' + p.class : ''}`} style={p.style}>
    <rect width="18" height="18" x="3" y="3" rx="2" />
  </svg>
);

export const X = (p: IconProps) => (
  <svg width={p.size ?? 24} height={p.size ?? 24} viewBox="0 0 24 24" class={`ic${p.fill ? ' ic-fill' : ''}${p.class ? ' ' + p.class : ''}`} style={p.style}>
    <path d="M18 6 6 18" />
    <path d="m6 6 12 12" />
  </svg>
);

export const Clock = (p: IconProps) => (
  <svg width={p.size ?? 24} height={p.size ?? 24} viewBox="0 0 24 24" class={`ic${p.fill ? ' ic-fill' : ''}${p.class ? ' ' + p.class : ''}`} style={p.style}>
    <circle cx="12" cy="12" r="10" />
    <polyline points="12 6 12 12 16 14" />
  </svg>
);

export const Zap = (p: IconProps) => (
  <svg width={p.size ?? 24} height={p.size ?? 24} viewBox="0 0 24 24" class={`ic${p.fill ? ' ic-fill' : ''}${p.class ? ' ' + p.class : ''}`} style={p.style}>
    <polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2" />
  </svg>
);

export const Play = (p: IconProps) => (
  <svg width={p.size ?? 24} height={p.size ?? 24} viewBox="0 0 24 24" class={`ic${p.fill ? ' ic-fill' : ''}${p.class ? ' ' + p.class : ''}`} style={p.style}>
    <polygon points="5 3 19 12 5 21 5 3" />
  </svg>
);

export const AlertTriangle = (p: IconProps) => (
  <svg width={p.size ?? 24} height={p.size ?? 24} viewBox="0 0 24 24" class={`ic${p.fill ? ' ic-fill' : ''}${p.class ? ' ' + p.class : ''}`} style={p.style}>
    <path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3Z" />
    <path d="M12 9v4" />
    <path d="M12 17h.01" />
  </svg>
);

export const Star = (p: IconProps) => (
  <svg width={p.size ?? 24} height={p.size ?? 24} viewBox="0 0 24 24" class={`ic${p.fill ? ' ic-fill' : ''}${p.class ? ' ' + p.class : ''}`} style={p.style}>
    <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2" />
  </svg>
);

export const Layers = (p: IconProps) => (
  <svg width={p.size ?? 24} height={p.size ?? 24} viewBox="0 0 24 24" class={`ic${p.fill ? ' ic-fill' : ''}${p.class ? ' ' + p.class : ''}`} style={p.style}>
    <path d="m12.83 2.18a2 2 0 0 0-1.66 0L2.6 6.08a1 1 0 0 0 0 1.83l8.58 3.91a2 2 0 0 0 1.66 0l8.58-3.9a1 1 0 0 0 0-1.83Z" />
    <path d="m22 17.65-9.17 4.16a2 2 0 0 1-1.66 0L2 17.65" />
    <path d="m22 12.65-9.17 4.16a2 2 0 0 1-1.66 0L2 12.65" />
  </svg>
);

export const Download = (p: IconProps) => (
  <svg width={p.size ?? 24} height={p.size ?? 24} viewBox="0 0 24 24" class={`ic${p.fill ? ' ic-fill' : ''}${p.class ? ' ' + p.class : ''}`} style={p.style}>
    <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
    <polyline points="7 10 12 15 17 10" />
    <line x1="12" x2="12" y1="15" y2="3" />
  </svg>
);

export const Loader2 = (p: IconProps) => (
  <svg width={p.size ?? 24} height={p.size ?? 24} viewBox="0 0 24 24" class={`ic${p.fill ? ' ic-fill' : ''}${p.class ? ' ' + p.class : ''}`} style={p.style}>
    <path d="M21 12a9 9 0 1 1-6.219-8.56" />
  </svg>
);

export const Lock = (p: IconProps) => (
  <svg width={p.size ?? 24} height={p.size ?? 24} viewBox="0 0 24 24" class={`ic${p.fill ? ' ic-fill' : ''}${p.class ? ' ' + p.class : ''}`} style={p.style}>
    <rect width="18" height="11" x="3" y="11" rx="2" ry="2" />
    <path d="M7 11V7a5 5 0 0 1 10 0v4" />
  </svg>
);

export const CheckCircle2 = (p: IconProps) => (
  <svg width={p.size ?? 24} height={p.size ?? 24} viewBox="0 0 24 24" class={`ic${p.fill ? ' ic-fill' : ''}${p.class ? ' ' + p.class : ''}`} style={p.style}>
    <circle cx="12" cy="12" r="10" />
    <path d="m9 12 2 2 4-4" />
  </svg>
);

export const RefreshCw = (p: IconProps) => (
  <svg width={p.size ?? 24} height={p.size ?? 24} viewBox="0 0 24 24" class={`ic${p.fill ? ' ic-fill' : ''}${p.class ? ' ' + p.class : ''}`} style={p.style}>
    <path d="M3 12a9 9 0 0 1 9-9 9.75 9.75 0 0 1 6.74 2.74L21 8" />
    <path d="M21 3v5h-5" />
    <path d="M21 12a9 9 0 0 1-9 9 9.75 9.75 0 0 1-6.74-2.74L3 16" />
    <path d="M8 16H3v5" />
  </svg>
);

export const PackageSearch = (p: IconProps) => (
  <svg width={p.size ?? 24} height={p.size ?? 24} viewBox="0 0 24 24" class={`ic${p.fill ? ' ic-fill' : ''}${p.class ? ' ' + p.class : ''}`} style={p.style}>
    <path d="M21 10V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l2-1.14" />
    <path d="m7.5 4.27 9 5.15" />
    <polyline points="3.29 7 12 12 20.71 7" />
    <line x1="12" x2="12" y1="22" y2="12" />
    <circle cx="18.5" cy="15.5" r="2.5" />
    <path d="M20.27 17.27 22 19" />
  </svg>
);

export const Search = (p: IconProps) => (
  <svg width={p.size ?? 24} height={p.size ?? 24} viewBox="0 0 24 24" class={`ic${p.fill ? ' ic-fill' : ''}${p.class ? ' ' + p.class : ''}`} style={p.style}>
    <circle cx="11" cy="11" r="8" />
    <path d="m21 21-4.3-4.3" />
  </svg>
);

export const Github = (p: IconProps) => (
  <svg width={p.size ?? 24} height={p.size ?? 24} viewBox="0 0 24 24" class={`ic${p.fill ? ' ic-fill' : ''}${p.class ? ' ' + p.class : ''}`} style={p.style}>
    <path d="M15 22v-4a4.8 4.8 0 0 0-1-3.5c3 0 6-2 6-5.5.08-1.25-.27-2.48-1-3.5.28-1.15.28-2.35 0-3.5 0 0-1 0-3 1.5-2.64-.5-5.36-.5-8 0C6 2 5 2 5 2c-.3 1.15-.3 2.35 0 3.5A5.403 5.403 0 0 0 4 9c0 3.5 3 5.5 6 5.5-.39.49-.68 1.05-.85 1.65-.17.6-.22 1.23-.15 1.85v4" />
    <path d="M9 18c-4.51 2-5-2-7-2" />
  </svg>
);

export const ImageOff = (p: IconProps) => (
  <svg width={p.size ?? 24} height={p.size ?? 24} viewBox="0 0 24 24" class={`ic${p.fill ? ' ic-fill' : ''}${p.class ? ' ' + p.class : ''}`} style={p.style}>
    <line x1="2" x2="22" y1="2" y2="22" />
    <path d="M10.41 10.41a2 2 0 1 1-2.83-2.83" />
    <line x1="13.5" x2="6" y1="13.5" y2="21" />
    <line x1="18" x2="21" y1="12" y2="15" />
    <path d="M3.59 3.59A1.99 1.99 0 0 0 3 5v14a2 2 0 0 0 2 2h14c.55 0 1.052-.22 1.41-.59" />
    <path d="M21 15V5a2 2 0 0 0-2-2H9" />
  </svg>
);

export const Trash2 = (p: IconProps) => (
  <svg width={p.size ?? 24} height={p.size ?? 24} viewBox="0 0 24 24" class={`ic${p.fill ? ' ic-fill' : ''}${p.class ? ' ' + p.class : ''}`} style={p.style}>
    <path d="M3 6h18" />
    <path d="M19 6v14c0 1-1 2-2 2H7c-1 0-2-1-2-2V6" />
    <path d="M8 6V4c0-1 1-2 2-2h4c1 0 2 1 2 2v2" />
    <line x1="10" x2="10" y1="11" y2="17" />
    <line x1="14" x2="14" y1="11" y2="17" />
  </svg>
);

export const User = (p: IconProps) => (
  <svg width={p.size ?? 24} height={p.size ?? 24} viewBox="0 0 24 24" class={`ic${p.fill ? ' ic-fill' : ''}${p.class ? ' ' + p.class : ''}`} style={p.style}>
    <path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2" />
    <circle cx="12" cy="7" r="4" />
  </svg>
);

export const Save = (p: IconProps) => (
  <svg width={p.size ?? 24} height={p.size ?? 24} viewBox="0 0 24 24" class={`ic${p.fill ? ' ic-fill' : ''}${p.class ? ' ' + p.class : ''}`} style={p.style}>
    <path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z" />
    <polyline points="17 21 17 13 7 13 7 21" />
    <polyline points="7 3 7 8 15 8" />
  </svg>
);

export const RotateCcw = (p: IconProps) => (
  <svg width={p.size ?? 24} height={p.size ?? 24} viewBox="0 0 24 24" class={`ic${p.fill ? ' ic-fill' : ''}${p.class ? ' ' + p.class : ''}`} style={p.style}>
    <path d="M3 12a9 9 0 1 0 9-9 9.75 9.75 0 0 0-6.74 2.74L3 8" />
    <path d="M3 3v5h5" />
  </svg>
);

export const Monitor = (p: IconProps) => (
  <svg width={p.size ?? 24} height={p.size ?? 24} viewBox="0 0 24 24" class={`ic${p.fill ? ' ic-fill' : ''}${p.class ? ' ' + p.class : ''}`} style={p.style}>
    <rect width="20" height="14" x="2" y="3" rx="2" />
    <line x1="8" x2="16" y1="21" y2="21" />
    <line x1="12" x2="12" y1="17" y2="21" />
  </svg>
);

export const Volume2 = (p: IconProps) => (
  <svg width={p.size ?? 24} height={p.size ?? 24} viewBox="0 0 24 24" class={`ic${p.fill ? ' ic-fill' : ''}${p.class ? ' ' + p.class : ''}`} style={p.style}>
    <polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5" />
    <path d="M15.54 8.46a5 5 0 0 1 0 7.07" />
    <path d="M19.07 4.93a10 10 0 0 1 0 14.14" />
  </svg>
);

export const Maximize2 = (p: IconProps) => (
  <svg width={p.size ?? 24} height={p.size ?? 24} viewBox="0 0 24 24" class={`ic${p.fill ? ' ic-fill' : ''}${p.class ? ' ' + p.class : ''}`} style={p.style}>
    <polyline points="15 3 21 3 21 9" />
    <polyline points="9 21 3 21 3 15" />
    <line x1="21" x2="14" y1="3" y2="10" />
    <line x1="3" x2="10" y1="21" y2="14" />
  </svg>
);

export const ChevronRight = (p: IconProps) => (
  <svg width={p.size ?? 24} height={p.size ?? 24} viewBox="0 0 24 24" class={`ic${p.fill ? ' ic-fill' : ''}${p.class ? ' ' + p.class : ''}`} style={p.style}>
    <path d="m9 18 6-6-6-6" />
  </svg>
);

export const SlidersHorizontal = (p: IconProps) => (
  <svg width={p.size ?? 24} height={p.size ?? 24} viewBox="0 0 24 24" class={`ic${p.fill ? ' ic-fill' : ''}${p.class ? ' ' + p.class : ''}`} style={p.style}>
    <line x1="21" x2="14" y1="4" y2="4" />
    <line x1="10" x2="3" y1="4" y2="4" />
    <line x1="21" x2="12" y1="12" y2="12" />
    <line x1="8" x2="3" y1="12" y2="12" />
    <line x1="21" x2="16" y1="20" y2="20" />
    <line x1="12" x2="3" y1="20" y2="20" />
    <line x1="14" x2="14" y1="2" y2="6" />
    <line x1="8" x2="8" y1="10" y2="14" />
    <line x1="16" x2="16" y1="18" y2="22" />
  </svg>
);

export const Sparkles = (p: IconProps) => (
  <svg width={p.size ?? 24} height={p.size ?? 24} viewBox="0 0 24 24" class={`ic${p.fill ? ' ic-fill' : ''}${p.class ? ' ' + p.class : ''}`} style={p.style}>
    <path d="m12 3-1.912 5.813a2 2 0 0 1-1.275 1.275L3 12l5.813 1.912a2 2 0 0 1 1.275 1.275L12 21l1.912-5.813a2 2 0 0 1 1.275-1.275L21 12l-5.813-1.912a2 2 0 0 1-1.275-1.275L12 3Z" />
    <path d="M5 3v4" />
    <path d="M19 17v4" />
    <path d="M3 5h4" />
    <path d="M17 19h4" />
  </svg>
);

export const Globe = (p: IconProps) => (
  <svg width={p.size ?? 24} height={p.size ?? 24} viewBox="0 0 24 24" class={`ic${p.fill ? ' ic-fill' : ''}${p.class ? ' ' + p.class : ''}`} style={p.style}>
    <circle cx="12" cy="12" r="10" />
    <path d="M12 2a14.5 14.5 0 0 0 0 20 14.5 14.5 0 0 0 0-20" />
    <path d="M2 12h20" />
  </svg>
);

export const Palette = (p: IconProps) => (
  <svg width={p.size ?? 24} height={p.size ?? 24} viewBox="0 0 24 24" class={`ic${p.fill ? ' ic-fill' : ''}${p.class ? ' ' + p.class : ''}`} style={p.style}>
    <circle cx="13.5" cy="6.5" r=".5" fill="currentColor" />
    <circle cx="17.5" cy="10.5" r=".5" fill="currentColor" />
    <circle cx="8.5" cy="7.5" r=".5" fill="currentColor" />
    <circle cx="6.5" cy="12.5" r=".5" fill="currentColor" />
    <path d="M12 2C6.5 2 2 6.5 2 12s4.5 10 10 10c.926 0 1.648-.746 1.648-1.688 0-.437-.18-.835-.437-1.125-.29-.289-.438-.652-.438-1.125a1.64 1.64 0 0 1 1.668-1.668h1.996c3.051 0 5.555-2.503 5.555-5.554C21.965 6.012 17.461 2 12 2z" />
  </svg>
);

export const PowerOff = (p: IconProps) => (
  <svg width={p.size ?? 24} height={p.size ?? 24} viewBox="0 0 24 24" class={`ic${p.fill ? ' ic-fill' : ''}${p.class ? ' ' + p.class : ''}`} style={p.style}>
    <path d="M18.36 6.64A9 9 0 0 1 20.77 15" />
    <path d="M6.16 6.16a9 9 0 1 0 12.68 12.68" />
    <path d="M12 2v4" />
    <path d="m2 2 20 20" />
  </svg>
);

export const Terminal = (p: IconProps) => (
  <svg width={p.size ?? 24} height={p.size ?? 24} viewBox="0 0 24 24" class={`ic${p.fill ? ' ic-fill' : ''}${p.class ? ' ' + p.class : ''}`} style={p.style}>
    <polyline points="4 17 10 11 4 5" />
    <line x1="12" x2="20" y1="19" y2="19" />
  </svg>
);

export const Shield = (p: IconProps) => (
  <svg width={p.size ?? 24} height={p.size ?? 24} viewBox="0 0 24 24" class={`ic${p.fill ? ' ic-fill' : ''}${p.class ? ' ' + p.class : ''}`} style={p.style}>
    <path d="M20 13c0 5-3.5 7.5-7.66 8.95a1 1 0 0 1-.67-.01C7.5 20.5 4 18 4 13V6a1 1 0 0 1 1-1c2 0 4.5-1.2 6.24-2.72a1.17 1.17 0 0 1 1.52 0C14.51 3.81 17 5 19 5a1 1 0 0 1 1 1z" />
  </svg>
);

export const Cpu = (p: IconProps) => (
  <svg width={p.size ?? 24} height={p.size ?? 24} viewBox="0 0 24 24" class={`ic${p.fill ? ' ic-fill' : ''}${p.class ? ' ' + p.class : ''}`} style={p.style}>
    <rect x="4" y="4" width="16" height="16" rx="2" />
    <rect x="9" y="9" width="6" height="6" />
    <path d="M15 2v2" />
    <path d="M15 20v2" />
    <path d="M2 15h2" />
    <path d="M2 9h2" />
    <path d="M20 15h2" />
    <path d="M20 9h2" />
    <path d="M9 2v2" />
    <path d="M9 20v2" />
  </svg>
);

export const HardDrive = (p: IconProps) => (
  <svg width={p.size ?? 24} height={p.size ?? 24} viewBox="0 0 24 24" class={`ic${p.fill ? ' ic-fill' : ''}${p.class ? ' ' + p.class : ''}`} style={p.style}>
    <line x1="22" x2="2" y1="12" y2="12" />
    <path d="M5.45 5.11 2 12v6a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2v-6l-3.45-6.89A2 2 0 0 0 16.76 4H7.24a2 2 0 0 0-1.79 1.11z" />
    <line x1="6" x2="6.01" y1="16" y2="16" />
    <line x1="10" x2="10.01" y1="16" y2="16" />
  </svg>
);
