import { createSignal, For, Match, onMount, Show, Switch } from 'solid-js';
import { api, isSilver } from '../api';
import { ADDON_GAMES, ADDONS_DIR } from '../constants';
import { errText } from '../format';
import {
  AlertTriangle, CheckCircle2, Download, Lock, PackageSearch, Play, RefreshCw,
} from '../icons';
import { IconBox, Notice, Spinner } from './ui';

type AddonStatus = 'checking' | 'not-installed' | 'installed' | 'unsupported';

// last known result, reused when auto-detect is off
let cache: { status: AddonStatus; availability: Record<string, boolean> } | null = null;

const AddonsSection = (p: { autoCheck?: boolean }) => {
  const [status, setStatus] = createSignal<AddonStatus>('checking');
  const [installing, setInstalling] = createSignal(false);
  const [installError, setInstallError] = createSignal<string | null>(null);
  const [availability, setAvailability] = createSignal<Record<string, boolean>>({});
  const [launchError, setLaunchError] = createSignal<string | null>(null);
  const [launching, setLaunching] = createSignal<string | null>(null);

  const refreshAvailability = async () => {
    const result: Record<string, boolean> = {};
    for (const addon of ADDON_GAMES) {
      try { result[addon.id] = await api.checkAddonGameExists(addon.id); }
      catch { result[addon.id] = false; }
    }
    setAvailability(result);
  };

  const refresh = async () => {
    if (!isSilver()) { setStatus('unsupported'); return; }
    setStatus('checking');
    try {
      if (await api.checkAddonsInstalled()) {
        await refreshAvailability();
        setStatus('installed');
      } else {
        setStatus('not-installed');
      }
    } catch {
      setStatus('not-installed');
    }
    cache = { status: status(), availability: availability() };
  };

  // The tab is re-created every time it opens. With "Addon Auto-Detect" on we re-check on every
  // open; with it off we reuse the last known result and only check the first time (or on RESCAN).
  onMount(() => {
    if (p.autoCheck === false && cache) {
      setStatus(cache.status);
      setAvailability(cache.availability);
      return;
    }
    void refresh();
  });

  const handleInstall = async () => {
    if (installing()) return;
    setInstalling(true);
    setInstallError(null);
    try {
      await api.installAddons();
      await refresh();
    } catch (e) {
      setInstallError(errText(e));
    } finally {
      setInstalling(false);
    }
  };

  const handleLaunch = async (addonId: string) => {
    if (launching()) return;
    setLaunching(addonId);
    setLaunchError(null);
    try {
      await api.launchAddonGame(addonId);
      setTimeout(() => setLaunching(null), 2000);
    } catch (e) {
      setLaunchError(errText(e));
      setLaunching(null);
    }
  };

  return (
    <div class="page">
      <div class="page-head">
        <div>
          <div class="page-title">
            ADDONS <span class="page-sub">// COMMUNITY ADDON PACK</span>
          </div>
          <div class="page-lead">
            Extra games and content distributed through the HackerOS Games addon pack.
            Installs into <code class="code">{ADDONS_DIR}/</code>.
          </div>
        </div>
        <Show when={status() === 'installed'}>
          <button class="ghost-btn" onClick={refresh}><RefreshCw size={11} /> RESCAN</button>
        </Show>
      </div>

      <Switch>
        <Match when={status() === 'unsupported'}>
          <Notice icon={<AlertTriangle size={13} />} color="var(--yellow)" hex="#ffd600">
            Addon management requires the HackerOS Games desktop app — run this from the installed launcher to install or play addons.
          </Notice>
        </Match>

        <Match when={status() === 'checking'}>
          <Notice icon={<Spinner />} color="var(--text-dim)" hex="#556677">
            Checking addon installation status…
          </Notice>
        </Match>

        <Match when={status() === 'not-installed'}>
          <div class="empty-box">
            <div class="center-x mb14 accent-icon"><PackageSearch size={32} /></div>
            <div class="empty-title">ADDON PACK NOT INSTALLED</div>
            <p class="empty-text">
              No addons directory was found on this system. Installing the addon pack downloads{' '}
              <code class="code">addons.hl</code> from the HackerOS-Games repository and runs it with{' '}
              <code class="code">hl run</code>. Additional addon games (like{' '}
              <span class="accent">Parkour Runner</span>) will appear here automatically once installed.
            </p>
            <button class={`primary-btn${installing() ? ' busy' : ''}`} onClick={handleInstall} disabled={installing()}>
              {installing() ? <Spinner /> : <Download size={13} />}
              {installing() ? 'INSTALLING…' : 'INSTALL ADDONS'}
            </button>
            <Show when={installError()}>
              <div class="mt16">
                <Notice icon={<AlertTriangle size={13} />} color="var(--red)" hex="#ff1744">{installError()}</Notice>
              </div>
            </Show>
          </div>
        </Match>

        <Match when={status() === 'installed'}>
          <div class="mb20">
            <Notice icon={<CheckCircle2 size={13} />} color="var(--green)" hex="#00ff41">
              Addon pack detected. {ADDON_GAMES.length} addon {ADDON_GAMES.length === 1 ? 'title' : 'titles'} registered.
            </Notice>
          </div>

          <Show when={launchError()}>
            <div class="mb16">
              <Notice icon={<AlertTriangle size={13} />} color="var(--red)" hex="#ff1744">{launchError()}</Notice>
            </div>
          </Show>

          <div class="cards addon-cards">
            <For each={ADDON_GAMES}>
              {addon => {
                const available = () => availability()[addon.id];
                const isLaunching = () => launching() === addon.id;
                const canLaunch = () => available() === true && !isLaunching();
                return (
                  <div class="game-card addon-card">
                    <div class="row gap10 center mb12">
                      <IconBox name={addon.name} icon={addon.icon} color={addon.color} rgb={addon.rgb} box={38} img={30} />
                      <div class="tag" style={`background:rgba(${addon.rgb},0.08);border:1px solid ${addon.color}30;color:${addon.color};`}>ADDON</div>
                    </div>
                    <div class="card-title">{addon.name}</div>
                    <div class="dim s9 ls1 mb8">{addon.genre.toUpperCase()}</div>
                    <div class="card-desc mb16">{addon.description}</div>
                    <div class="row between center">
                      <span class="dim s9">{addon.version}</span>
                      <button
                        class="act-btn small"
                        disabled={!canLaunch()}
                        onClick={() => handleLaunch(addon.id)}
                        style={canLaunch() ? `background:rgba(${addon.rgb},0.1);border:1px solid ${addon.color};color:${addon.color};` : ''}
                      >
                        {isLaunching() ? <><Spinner size={9} /> LAUNCHING</>
                          : available() === false ? <><Lock size={9} /> MISSING</>
                          : <><Play size={9} /> LAUNCH</>}
                      </button>
                    </div>
                  </div>
                );
              }}
            </For>
          </div>
        </Match>
      </Switch>
    </div>
  );
};

export default AddonsSection;
