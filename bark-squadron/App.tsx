import { useState, useEffect, useCallback } from 'react';
import { GameState, GameStats, GameSettings, HighScore } from './types';
import GameCanvas from './components/GameCanvas';
import LeaderboardPanel from './components/LeaderboardPanel';
import { generateBriefing, submitScore, getPrefs, savePrefs } from './services/tauriService';
import {
  Plane, Trophy, Skull, Rocket, Activity, Settings, X,
  Volume2, Gamepad2, Play, Gauge, Shield, BarChart2,
} from 'lucide-react';

const DEFAULT_SETTINGS: GameSettings = {
  difficulty: 'normal',
  showHitboxes: false,
  particles: true,
  highQuality: true,
  sensitivity: 1.0,
  volume: 80,
};

export default function App() {
  const [gameState, setGameState] = useState<GameState>(GameState.MENU);
  const [stats, setStats] = useState<GameStats>({ score: 0, wave: 1, kills: 0 });
  const [playerHp, setPlayerHp] = useState(100);
  const [briefing, setBriefing] = useState('');
  const [loadingBriefing, setLoadingBriefing] = useState(false);
  const [showSettings, setShowSettings] = useState(false);
  const [settings, setSettings] = useState<GameSettings>(DEFAULT_SETTINGS);
  const [lastScore, setLastScore] = useState<HighScore | null>(null);

  // Load saved prefs on mount
  useEffect(() => {
    getPrefs().then(p => { if (p) setSettings(p); });
  }, []);

  const handleSettingChange = <K extends keyof GameSettings>(k: K, v: GameSettings[K]) => {
    setSettings(prev => {
      const next = { ...prev, [k]: v };
      savePrefs(next);
      return next;
    });
  };

  const handleStartGame = useCallback(async () => {
    setLoadingBriefing(true);
    setGameState(GameState.BRIEFING);
    setStats({ score: 0, wave: 1, kills: 0 });
    setPlayerHp(100);
    const text = await generateBriefing(1, 0);
    setBriefing(text);
    setLoadingBriefing(false);
  }, []);

  const handleGameOver = useCallback(async (finalStats: GameStats) => {
    setGameState(GameState.GAME_OVER);
    const hs: HighScore = {
      score: finalStats.score,
      wave: finalStats.wave,
      kills: finalStats.kills,
      difficulty: settings.difficulty,
      timestamp: Math.floor(Date.now() / 1000),
    };
    setLastScore(hs);
    await submitScore(hs);
  }, [settings.difficulty]);

  return (
    <div className="relative w-screen h-screen overflow-hidden bg-slate-900 font-sans text-white selection:bg-transparent">

      {/* Game canvas layer */}
      <div className="absolute inset-0 z-0">
        <GameCanvas
          gameState={gameState}
          settings={settings}
          setGameState={setGameState}
          setStats={setStats}
          setPlayerHp={setPlayerHp}
          onGameOver={handleGameOver}
        />
      </div>

      {/* HUD */}
      <div className="absolute inset-0 z-10 pointer-events-none flex flex-col justify-between p-6">
        {gameState === GameState.PLAYING && (
          <div className="flex justify-between items-start w-full">
            <div className="flex flex-col gap-2">
              <div className="flex items-center gap-2 bg-black/50 p-2 rounded-lg border border-white/20 backdrop-blur-sm">
                <Activity className="text-green-400" size={24} />
                <div className="w-48 h-4 bg-gray-700 rounded-full overflow-hidden">
                  <div
                    className={`h-full transition-all duration-300 ${playerHp > 30 ? 'bg-green-500' : 'bg-red-500 animate-pulse'}`}
                    style={{ width: `${Math.max(0, playerHp)}%` }}
                  />
                </div>
                <span className="font-bold font-mono">{Math.floor(playerHp)}%</span>
              </div>
            </div>
            <div className="flex gap-4">
              {[
                { icon: <Trophy className="text-yellow-400" size={20} />, val: stats.score },
                { icon: <Skull className="text-red-400" size={20} />, val: stats.kills },
              ].map(({ icon, val }, i) => (
                <div key={i} className="flex items-center gap-2 bg-black/50 p-2 rounded-lg border border-white/20 backdrop-blur-sm">
                  {icon}
                  <span className="font-mono text-xl">{val}</span>
                </div>
              ))}
              <div className="flex items-center gap-2 bg-black/50 p-2 rounded-lg border border-white/20 backdrop-blur-sm">
                <span className="text-sm uppercase text-gray-400">Wave</span>
                <span className="font-mono text-xl text-blue-400">{stats.wave}</span>
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Settings Modal */}
      {showSettings && (
        <div className="absolute inset-0 z-[60] flex items-center justify-center bg-black/70 backdrop-blur-sm pointer-events-auto">
          <div className="bg-slate-800 p-6 rounded-xl border border-slate-600 w-[420px] shadow-2xl">
            <div className="flex justify-between items-center mb-6">
              <h2 className="text-2xl font-bold flex items-center gap-2"><Settings /> Settings</h2>
              <button onClick={() => setShowSettings(false)} className="hover:text-red-400"><X /></button>
            </div>
            <div className="space-y-5">
              {/* Difficulty */}
              <div>
                <label className="block text-slate-400 text-sm mb-2">Difficulty</label>
                <div className="grid grid-cols-3 gap-2">
                  {(['easy', 'normal', 'hard'] as const).map(d => (
                    <button key={d} onClick={() => handleSettingChange('difficulty', d)}
                      className={`py-2 rounded capitalize ${settings.difficulty === d ? 'bg-blue-600 text-white' : 'bg-slate-700 text-slate-400 hover:bg-slate-600'}`}>
                      {d}
                    </button>
                  ))}
                </div>
              </div>
              {/* Sensitivity */}
              <div>
                <label className="block text-slate-400 text-sm mb-2 flex items-center gap-2">
                  <Gauge size={14} /> Flight Sensitivity: {settings.sensitivity.toFixed(1)}
                </label>
                <input type="range" min="0.5" max="2.0" step="0.1" value={settings.sensitivity}
                  onChange={e => handleSettingChange('sensitivity', parseFloat(e.target.value))}
                  className="w-full h-2 bg-slate-600 rounded-lg appearance-none cursor-pointer accent-blue-500" />
              </div>
              {/* Volume */}
              <div>
                <label className="block text-slate-400 text-sm mb-2 flex items-center gap-2">
                  <Volume2 size={14} /> Volume: {settings.volume}%
                </label>
                <input type="range" min="0" max="100" step="5" value={settings.volume}
                  onChange={e => handleSettingChange('volume', parseInt(e.target.value))}
                  className="w-full h-2 bg-slate-600 rounded-lg appearance-none cursor-pointer accent-blue-500" />
              </div>
              {/* Toggles */}
              <div className="space-y-3">
                {([
                  ['highQuality', 'High Quality Graphics'],
                  ['particles', 'Particle Effects'],
                  ['showHitboxes', 'Show Hitboxes (Debug)'],
                ] as [keyof GameSettings, string][]).map(([k, label]) => (
                  <label key={k} className="flex items-center justify-between cursor-pointer p-2 rounded hover:bg-slate-700/50">
                    <span>{label}</span>
                    <input type="checkbox" checked={settings[k] as boolean}
                      onChange={e => handleSettingChange(k, e.target.checked)}
                      className="accent-blue-500 w-5 h-5" />
                  </label>
                ))}
              </div>
            </div>
            <div className="mt-4 text-center text-xs text-slate-500">Settings are saved automatically</div>
          </div>
        </div>
      )}

      {/* Leaderboard */}
      {gameState === GameState.LEADERBOARD && (
        <div className="absolute inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-md pointer-events-auto">
          <LeaderboardPanel difficulty={settings.difficulty} onClose={() => setGameState(GameState.MENU)} />
        </div>
      )}

      {/* Pause Menu */}
      {gameState === GameState.PAUSED && !showSettings && (
        <div className="absolute inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm pointer-events-auto">
          <div className="flex flex-col gap-4 items-center">
            <h1 className="text-6xl font-black text-white text-center mb-4 tracking-wider">PAUSED</h1>
            {[
              { label: 'RESUME', icon: <Play fill="currentColor" />, cls: 'bg-green-500 hover:bg-green-600', action: () => setGameState(GameState.PLAYING) },
              { label: 'SETTINGS', icon: <Settings />, cls: 'bg-slate-700 hover:bg-slate-600', action: () => setShowSettings(true) },
              { label: 'QUIT', icon: null, cls: 'bg-red-600 hover:bg-red-700', action: () => setGameState(GameState.MENU) },
            ].map(b => (
              <button key={b.label} onClick={b.action}
                className={`${b.cls} text-white font-bold py-3 px-8 rounded-full shadow-lg flex items-center justify-center gap-2 transform hover:scale-105 transition-all`}>
                {b.icon}{b.label}
              </button>
            ))}
          </div>
        </div>
      )}

      {/* Main Menu */}
      {gameState === GameState.MENU && !showSettings && (
        <div className="absolute inset-0 z-50 flex items-center justify-center bg-slate-900/80 backdrop-blur-md pointer-events-auto">
          <div className="bg-slate-800 p-8 rounded-2xl shadow-2xl border-2 border-slate-600 max-w-md w-full text-center relative overflow-hidden">
            <div className="absolute top-0 left-0 w-full h-2 bg-gradient-to-r from-blue-500 via-purple-500 to-red-500" />
            <div className="mb-6 flex justify-center">
              <Rocket size={64} className="text-blue-400 drop-shadow-[0_0_15px_rgba(59,130,246,0.5)]" />
            </div>
            <h1 className="text-5xl font-black italic tracking-tighter mb-2 bg-gradient-to-r from-blue-400 via-white to-blue-400 bg-clip-text text-transparent">
              BARK SQUADRON
            </h1>
            <p className="text-slate-400 mb-8 font-mono text-sm">v0.7 // MODERN AIR COMBAT</p>
            <div className="space-y-3">
              <button onClick={handleStartGame}
                className="w-full bg-blue-600 hover:bg-blue-500 text-white font-bold py-4 px-6 rounded-xl transition-all transform hover:scale-105 shadow-lg flex items-center justify-center gap-2 border-b-4 border-blue-800">
                <Plane /> SCRAMBLE JETS
              </button>
              <button onClick={() => setShowSettings(true)}
                className="w-full bg-slate-700 hover:bg-slate-600 text-slate-200 font-bold py-3 px-6 rounded-xl transition-all flex items-center justify-center gap-2">
                <Settings size={18} /> SETTINGS
              </button>
              <button onClick={() => setGameState(GameState.LEADERBOARD)}
                className="w-full bg-slate-700/60 hover:bg-slate-600/60 text-slate-300 font-bold py-3 px-6 rounded-xl transition-all flex items-center justify-center gap-2">
                <BarChart2 size={18} /> LEADERBOARD
              </button>
              <div className="text-sm text-slate-500 mt-4 border-t border-slate-700 pt-4 text-left">
                <p className="flex items-center gap-2 mb-1"><Gamepad2 size={14} /> <strong>Controls:</strong></p>
                <ul className="list-disc list-inside space-y-1 ml-1 text-xs">
                  <li>Arrow Keys / WASD — Fly</li>
                  <li>SPACE — Fire Cannons</li>
                  <li>ESC — Pause</li>
                </ul>
              </div>
              <div className="text-xs text-slate-600 flex items-center justify-center gap-1 pt-1">
                <Shield size={11} /> Sandbox isolated
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Briefing */}
      {gameState === GameState.BRIEFING && (
        <div className="absolute inset-0 z-50 flex items-center justify-center bg-black pointer-events-auto">
          <div className="max-w-2xl w-full p-8 border-l-4 border-green-500 bg-slate-900/90 text-left font-mono shadow-[0_0_50px_rgba(34,197,94,0.2)]">
            <h2 className="text-green-500 text-xl mb-4 uppercase tracking-widest animate-pulse flex items-center gap-2">
              <Volume2 size={20} /> Encrypted Channel...
            </h2>
            {loadingBriefing ? (
              <div className="text-white text-lg animate-pulse">Downloading mission profile...</div>
            ) : (
              <>
                <p className="text-white text-2xl leading-relaxed mb-8 border-b border-dashed border-green-900 pb-8">
                  "{briefing}"
                </p>
                <button onClick={() => setGameState(GameState.PLAYING)}
                  className="bg-green-600 hover:bg-green-500 text-black font-bold py-3 px-8 rounded-none uppercase tracking-widest transition-all w-full hover:tracking-[0.2em] duration-300">
                  ENGAGE
                </button>
              </>
            )}
          </div>
        </div>
      )}

      {/* Game Over */}
      {gameState === GameState.GAME_OVER && (
        <div className="absolute inset-0 z-50 flex items-center justify-center bg-red-900/80 backdrop-blur-md pointer-events-auto">
          <div className="bg-slate-900 p-8 rounded-2xl shadow-2xl border-2 border-red-600 max-w-md w-full text-center">
            <h2 className="text-6xl font-black text-red-600 mb-2 drop-shadow-lg">KIA</h2>
            <p className="text-red-300 mb-6 uppercase tracking-widest">Killed In Action</p>
            <div className="grid grid-cols-3 gap-3 mb-8">
              {[
                { label: 'Score', val: lastScore?.score ?? stats.score, color: 'text-yellow-400' },
                { label: 'Wave',  val: lastScore?.wave ?? stats.wave,   color: 'text-blue-400' },
                { label: 'Kills', val: lastScore?.kills ?? stats.kills, color: 'text-white' },
              ].map(({ label, val, color }) => (
                <div key={label} className="bg-slate-800 p-4 rounded-lg border border-slate-700">
                  <div className="text-slate-400 text-xs uppercase mb-1">{label}</div>
                  <div className={`text-3xl font-mono ${color}`}>{val}</div>
                </div>
              ))}
            </div>
            <div className="space-y-3">
              <button onClick={handleStartGame}
                className="w-full bg-blue-600 hover:bg-blue-500 text-white font-bold py-3 px-6 rounded-xl transition-all">
                TRY AGAIN
              </button>
              <button onClick={() => setGameState(GameState.LEADERBOARD)}
                className="w-full bg-slate-700 hover:bg-slate-600 text-white font-bold py-3 px-6 rounded-xl transition-all flex items-center justify-center gap-2">
                <BarChart2 size={16} /> LEADERBOARD
              </button>
              <button onClick={() => setGameState(GameState.MENU)}
                className="w-full bg-slate-800 hover:bg-slate-700 text-slate-400 font-bold py-2 px-6 rounded-xl transition-all">
                MAIN MENU
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
