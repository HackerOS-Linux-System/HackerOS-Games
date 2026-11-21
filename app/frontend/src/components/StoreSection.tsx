import { createEffect, createMemo, createSignal, For, on, onMount, Show } from 'solid-js';
import { api, fetchCommunityGames, isSilver } from '../api';
import { fmtDate, errText } from '../format';
import type { CommunityGame, CommunityGameInstall } from '../types';
import {
  AlertTriangle, CheckCircle2, Download, Github, ImageOff, Play, RefreshCw, Search, Store, Trash2, User,
} from '../icons';
import { Notice, Spinner } from './ui';

const openLink = async (url: string) => {
  if (!url || !isSilver()) return;
  try { await api.openUrl(url); } catch { /* ignore */ }
};

const slug = (g: CommunityGame) => `community-${g.id}`;

const StoreSection = (p: { language?: 'en' | 'pl' }) => {
  const [games, setGames] = createSignal<CommunityGame[] | null>(null);
  const [error, setError] = createSignal<string | null>(null);
  const [loading, setLoading] = createSignal(true);
  const [query, setQuery] = createSignal('');
  const [installs, setInstalls] = createSignal<Record<string, CommunityGameInstall>>({});
  const [installing, setInstalling] = createSignal<Record<number, boolean>>({});
  const [uninstalling, setUninstalling] = createSignal<Record<number, boolean>>({});
  const [launching, setLaunching] = createSignal<Record<number, boolean>>({});
  const [actionErr, setActionErr] = createSignal<Record<number, string>>({});
  const [images, setImages] = createSignal<Record<string, string>>({});

  const flag = (set: (f: (p: Record<number, boolean>) => Record<number, boolean>) => void, id: number, v: boolean) =>
    set(prev => ({ ...prev, [id]: v }));
  const setErr = (id: number, msg: string) => setActionErr(prev => ({ ...prev, [id]: msg }));

  const load = async () => {
    setLoading(true);
    setError(null);
    try {
      const list = await fetchCommunityGames();
      setGames(list);
      // Silver only draws local files → fetch the artwork into the cache in the background.
      if (isSilver()) {
        const urls = list.map(g => g.image).filter(Boolean);
        api.cacheImages(urls).then(setImages).catch(() => { /* artwork is optional */ });
      }
    } catch (e) {
      setError(errText(e));
      setGames(null);
    } finally {
      setLoading(false);
    }
  };

  const loadInstalls = async () => {
    if (!isSilver()) return;
    try { setInstalls(await api.getCommunityInstalls()); } catch { /* ignore */ }
  };

  onMount(() => { void load(); void loadInstalls(); });

  const filtered = createMemo(() => {
    const list = games();
    if (!list) return [];
    const q = query().trim().toLowerCase();
    if (!q) return list;
    const desc = p.language === 'pl' ? 'description-pl' : 'description-en';
    return list.filter(g =>
      g.title.toLowerCase().includes(q) ||
      (g.genre ?? '').toLowerCase().includes(q) ||
      (g[desc] ?? '').toLowerCase().includes(q) ||
      (g.authors ?? '').toLowerCase().includes(q));
  });

  const handleInstall = async (g: CommunityGame) => {
    if (!isSilver() || !g.install) return;
    flag(setInstalling, g.id, true);
    setErr(g.id, '');
    try {
      const rec = await api.installCommunityGame(slug(g), g.title, g.install);
      setInstalls(prev => ({ ...prev, [slug(g)]: rec }));
    } catch (e) {
      setErr(g.id, errText(e));
    } finally {
      flag(setInstalling, g.id, false);
    }
  };

  const handleUninstall = async (g: CommunityGame) => {
    if (!isSilver()) return;
    flag(setUninstalling, g.id, true);
    try {
      await api.uninstallCommunityGame(slug(g));
      setInstalls(prev => { const n = { ...prev }; delete n[slug(g)]; return n; });
    } catch (e) {
      setErr(g.id, errText(e));
    } finally {
      flag(setUninstalling, g.id, false);
    }
  };

  const handleLaunch = async (g: CommunityGame) => {
    if (!isSilver()) return;
    flag(setLaunching, g.id, true);
    try {
      await api.launchCommunityGame(slug(g));
      setTimeout(() => flag(setLaunching, g.id, false), 3000);
    } catch (e) {
      setErr(g.id, errText(e));
      flag(setLaunching, g.id, false);
    }
  };

  // reset action errors when the list is reloaded
  createEffect(on(games, () => setActionErr({}), { defer: true }));

  return (
    <div class="page">
      <div class="page-head">
        <div>
          <div class="page-title">
            STORE <span class="page-sub">// HACKEROS COMMUNITY GAMES</span>
          </div>
          <div class="page-lead">
            Community-submitted games curated by the HackerOS team. Each game runs in an isolated sandbox — click Install to download, then Launch to play.
          </div>
        </div>
        <div class="row gap8">
          <div class="search-wrap">
            <span class="search-ico"><Search size={12} /></span>
            <input
              class="search"
              value={query()}
              onInput={e => setQuery(e.currentTarget.value)}
              placeholder="SEARCH GAMES…"
            />
          </div>
          <button class="ghost-btn" title="Refresh list" onClick={() => { void load(); void loadInstalls(); }}>
            <Show when={loading()} fallback={<RefreshCw size={11} />}><Spinner size={11} /></Show> REFRESH
          </button>
        </div>
      </div>

      <Show when={loading()}>
        <Notice icon={<Spinner />} color="var(--text-dim)" hex="#556677">Fetching community games list from GitHub…</Notice>
      </Show>
      <Show when={!loading() && error()}>
        <Notice icon={<AlertTriangle size={13} />} color="var(--red)" hex="#ff1744">
          Failed to load the store listing ({error()}). Check your internet connection and try again.
        </Notice>
      </Show>
      <Show when={!loading() && !error() && games() && games()!.length === 0}>
        <Notice icon={<Store size={13} />} color="var(--text-dim)" hex="#556677">
          No community games have been published yet — check back soon.
        </Notice>
      </Show>

      <Show when={!loading() && !error() && filtered().length > 0}>
        <div class="cards store-cards">
          <For each={filtered()}>
            {g => {
              const installed = () => !!installs()[slug(g)];
              const rec = () => installs()[slug(g)];
              const desc = () => (p.language === 'pl' ? g['description-pl'] : g['description-en']) || g['description-en'];
              const art = () => images()[g.image];
              return (
                <div class="game-card store-card">
                  <div class="store-img">
                    <Show when={art()} fallback={<span class="ghost-ico"><ImageOff size={28} /></span>}>
                      <img src={art()} alt={g.title} style="width:100%;height:100%;object-fit:cover;" />
                    </Show>
                    <Show when={installed()}>
                      <div class="installed-badge"><CheckCircle2 size={9} /> INSTALLED</div>
                    </Show>
                  </div>

                  <div class="store-body">
                    <div class="card-title">{g.title}</div>
                    <div class="row gap8 center mb10 wrap">
                      <span class="genre-tag">{(g.genre ?? '').toUpperCase()}</span>
                      <Show when={g.authors}>
                        <span class="dim s9 row gap4 center"><User size={9} />{g.authors}</span>
                      </Show>
                    </div>
                    <div class="card-desc grow mb14 pl">{desc()}</div>

                    <Show when={actionErr()[g.id]}>
                      <div class="card-err"><AlertTriangle size={10} />{actionErr()[g.id]}</div>
                    </Show>

                    <div class="row gap6 wrap">
                      <Show
                        when={installed()}
                        fallback={
                          <button
                            class="act-btn primary accent-btn"
                            disabled={installing()[g.id] || !g.install}
                            onClick={() => handleInstall(g)}
                          >
                            <Download size={10} />
                            {installing()[g.id] ? 'INSTALLING…' : 'INSTALL'}
                          </button>
                        }
                      >
                        <button
                          class="act-btn primary green-btn"
                          disabled={launching()[g.id]}
                          onClick={() => handleLaunch(g)}
                        >
                          <Play size={10} fill="currentColor" />
                          {launching()[g.id] ? 'LAUNCHING…' : 'LAUNCH'}
                        </button>
                        <button
                          class="act-btn red-btn"
                          disabled={uninstalling()[g.id]}
                          onClick={() => handleUninstall(g)}
                        >
                          <Trash2 size={10} />
                          {uninstalling()[g.id] ? 'REMOVING…' : 'UNINSTALL'}
                        </button>
                      </Show>
                      <Show when={g.repo}>
                        <button class="ghost-btn small" onClick={() => openLink(g.repo!)}>
                          <Github size={10} /> REPO
                        </button>
                      </Show>
                    </div>

                    <Show when={installing()[g.id]}>
                      <div class="dim s9 ls1 mt8 row gap5 center">
                        <Spinner size={9} /> Downloading &amp; installing in sandbox…
                      </div>
                    </Show>

                    <Show when={installed() && rec()}>
                      <div class="dim s9 ls1 mt8">
                        Type: <span class="accent">{rec()!.installType}</span>
                        {' '}// Installed {fmtDate(rec()!.installedAt)}
                      </div>
                    </Show>
                  </div>
                </div>
              );
            }}
          </For>
        </div>
      </Show>

      <Show when={!loading() && !error() && (games()?.length ?? 0) > 0 && filtered().length === 0}>
        <Notice icon={<Search size={13} />} color="var(--text-dim)" hex="#556677">No games match "{query()}".</Notice>
      </Show>
    </div>
  );
};

export default StoreSection;
