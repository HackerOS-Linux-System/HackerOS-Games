import { createEffect, createSignal, For, on, Show } from 'solid-js';
import { api, isSilver } from '../api';
import { fmtLast, fmtTime, errText } from '../format';
import type { GameConfig, GamePlaytime } from '../types';
import { AlertTriangle, Clock, Layers, Play, Star, Zap } from '../icons';
import { IconBox } from './ui';

interface Props {
  games: GameConfig[];
  playtime: Record<string, GamePlaytime>;
  onLaunch: (gameId: string) => void;
}

/* ── Small card in the sidebar ── */
const SideCard = (p: { game: GameConfig; pt?: GamePlaytime; selected: boolean; onClick: () => void }) => (
  <div
    class="game-card side-card"
    onClick={p.onClick}
    style={`${p.selected ? `border-color:${p.game.color};box-shadow:0 0 16px rgba(${p.game.rgb},0.18), inset 0 0 30px rgba(${p.game.rgb},0.04);` : ''}opacity:${p.game.available ? 1 : 0.55};`}
  >
    <div class="row gap12 center">
      <IconBox name={p.game.name} icon={p.game.icon} color={p.game.color} rgb={p.game.rgb} box={44} img={36} />
      <div class="grow minw0">
        <div class="side-name" style={`color:${p.game.color};text-shadow:0 0 6px rgba(${p.game.rgb},0.4);`}>{p.game.name}</div>
        <div class="dim s9 ls1">{p.game.genre}</div>
        <div class="row gap10 dim s9 mt5">
          <span class="row gap3 center"><Clock size={8} />{fmtTime(p.pt?.total_seconds ?? 0)}</span>
          <span class="row gap3 center"><Zap size={8} />{fmtLast(p.pt?.last_played ?? 0)}</span>
        </div>
      </div>
      <div
        class="status-dot"
        style={`background:${p.game.available ? p.game.color : '#333'};box-shadow:${p.game.available ? `0 0 5px ${p.game.color}` : 'none'};`}
      />
    </div>
  </div>
);

/* ── Detail panel ── */
const Detail = (p: { game: GameConfig; pt?: GamePlaytime; onLaunch: (id: string) => void }) => {
  const [launching, setLaunching] = createSignal(false);
  const [error, setError] = createSignal<string | null>(null);
  const [exists, setExists] = createSignal<boolean | null>(null);

  // re-check whenever another game is selected
  createEffect(on(() => p.game.id, id => {
    setError(null);
    setLaunching(false);
    if (!p.game.available || !isSilver()) { setExists(false); return; }
    setExists(null);
    api.checkGameExists(id)
      .then(v => { if (p.game.id === id) setExists(v); })
      .catch(() => { if (p.game.id === id) setExists(false); });
  }));

  const canLaunch = () => exists() === true && p.game.available;

  const launch = async () => {
    if (!canLaunch() || launching()) return;
    setLaunching(true);
    setError(null);
    try {
      await api.launchGame(p.game.id);
      p.onLaunch(p.game.id);
      setTimeout(() => setLaunching(false), 3000);
    } catch (e) {
      setError(errText(e));
      setLaunching(false);
    }
  };

  const label = () =>
    launching() ? 'LAUNCHING...' : !p.game.available ? 'COMING SOON' : exists() === false ? 'NOT INSTALLED' : 'LAUNCH GAME';

  const stats = () => [
    { label: 'TOTAL TIME', val: fmtTime(p.pt?.total_seconds ?? 0), icon: <Clock size={13} /> },
    { label: 'SESSIONS', val: String(p.pt?.sessions ?? 0), icon: <Layers size={13} /> },
    { label: 'LAST PLAYED', val: fmtLast(p.pt?.last_played ?? 0), icon: <Star size={13} /> },
  ];

  return (
    <div class="detail">
      <div class="row gap28 mb32 start">
        <IconBox name={p.game.name} icon={p.game.icon} color={p.game.color} rgb={p.game.rgb} box={110} img={90} glow />
        <div class="grow">
          <div class="detail-title" style={`color:${p.game.color};text-shadow:0 0 24px rgba(${p.game.rgb},0.5);`}>{p.game.name}</div>
          <div class="dim s10 ls2 mb14">{p.game.genre.toUpperCase()} &nbsp;// &nbsp;v{p.game.version}</div>
          <div class="detail-desc">{p.game.longDescription}</div>
        </div>
      </div>

      <Show when={p.pt}>
        <div class="grid3 mb28">
          <For each={stats()}>
            {s => (
              <div class="stat" style={`border:1px solid ${p.game.color}22;`}>
                <div class="row gap6 center mb6" style={`color:${p.game.color};`}>
                  {s.icon}<span class="s9 ls2">{s.label}</span>
                </div>
                <div class="stat-val">{s.val}</div>
              </div>
            )}
          </For>
        </div>
      </Show>

      <Show when={error()}>
        <div class="err-strip"><AlertTriangle size={13} />{error()}</div>
      </Show>

      <button
        class={`launch-btn${canLaunch() ? ' can' : ''}`}
        disabled={!canLaunch() || launching()}
        onClick={launch}
        style={canLaunch()
          ? `background:rgba(${p.game.rgb},${launching() ? 0.2 : 0.1});border:1px solid ${p.game.color};color:${p.game.color};box-shadow:${launching() ? `0 0 30px rgba(${p.game.rgb},0.35)` : 'none'};`
          : ''}
      >
        <Play size={15} fill="currentColor" />
        {label()}
      </button>

      <Show when={!canLaunch() && p.game.available && exists() === false}>
        <p class="dim s10 lh16 mt10">
          Game binary not found at expected path.<br />
          Check your HackerOS-Games installation.
        </p>
      </Show>
    </div>
  );
};

/* ── Section ── */
const GamesSection = (p: Props) => {
  const [selected, setSelected] = createSignal(p.games[0]?.id ?? '');
  const game = () => p.games.find(g => g.id === selected()) ?? p.games[0];

  return (
    <div class="split">
      <div class="sidebar w300">
        <div class="side-head">LIBRARY — {p.games.length} TITLES</div>
        <For each={p.games}>
          {g => (
            <SideCard game={g} pt={p.playtime[g.id]} selected={selected() === g.id} onClick={() => setSelected(g.id)} />
          )}
        </For>
      </div>
      <div class="grow detail-wrap">
        <Show when={game()}>
          <Detail game={game()} pt={p.playtime[game().id]} onLaunch={p.onLaunch} />
        </Show>
      </div>
    </div>
  );
};

export default GamesSection;
