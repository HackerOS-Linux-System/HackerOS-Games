import { createSignal, For, onMount, Show } from 'solid-js';
import { isSilver } from '../api';
import { LAUNCHER_VERSION } from '../constants';

const TITLES: [string, string, string][] = [
  ['The Racer', 'H# + H2D (binary)', 'var(--red)'],
  ['Cosmonaut', 'Lua + LÖVE2D (.love file)', 'var(--blue)'],
  ['Starblaster', 'H# + H2D (binary)', 'var(--green)'],
  ['Bark Squadron', 'TypeScript + React + Tauri (binary)', 'var(--pink)'],
  ['Bit Jump', 'H# + H2D (binary) · LÖVE2D fallback', 'var(--yellow)'],
];

const AboutSection = () => {
  const [runtime, setRuntime] = createSignal('');

  // Silver reports its version and the video backend in use (wayland / x11 …).
  onMount(async () => {
    if (!isSilver()) return;
    try {
      const info = await silver.info();
      setRuntime(`Silver ${info.version} · ${info.backend}${info.embeddedAssets ? ` · ${info.embeddedAssets} embedded files` : ''}`);
    } catch { /* optional */ }
  });

  return (
    <div class="page about">
      <div class="about-inner">
        <div class="about-title">HACKEROS GAMES</div>
        <div class="dim s10 ls3 mb28">LAUNCHER // VERSION {LAUNCHER_VERSION}</div>

        <div class="about-box">
          <p class="about-p">
            HackerOS Games is the native game launcher bundled with every HackerOS edition.
            Unified interface for launching, tracking and configuring all HackerOS-native games.
          </p>
          <p class="about-p dim mb0">
            Built with <span style="color:var(--yellow);">H#</span> +{' '}
            <span style="color:var(--blue);">TypeScript</span> +{' '}
            <span style="color:var(--pink);">Solid.js</span> +{' '}
            <span style="color:var(--green);">Silver</span>.
            Games launch from{' '}
            <code class="code">/usr/share/HackerOS/Scripts/HackerOS-Games</code>.
            All games run inside a <span style="color:var(--green);">bubblewrap sandbox</span>.
          </p>
          <Show when={runtime()}>
            <p class="about-p dim mb0 mt10 s10">{runtime()}</p>
          </Show>
        </div>

        <For each={TITLES}>
          {([name, tech, color]) => (
            <div class="about-row">
              <span style={`color:${color};`}>{name}</span>
              <span class="dim">{tech}</span>
            </div>
          )}
        </For>
      </div>
    </div>
  );
};

export default AboutSection;
