import React, { useState } from 'react';
import { GameState, GameStats, GameSettings } from './types';
import GameCanvas from './components/GameCanvas';
import { generateBriefing } from './services/geminiService';
import { Plane, Trophy, Skull, Rocket, Activity, Settings, X, Volume2, Gamepad2, Play } from 'lucide-react';

export default function App() {
  const [gameState, setGameState] = useState<GameState>(GameState.MENU);
  const [stats, setStats] = useState<GameStats>({ score: 0, wave: 1, kills: 0 });
  const [playerHp, setPlayerHp] = useState(100);
  const [briefing, setBriefing] = useState<string>("");
  const [loadingBriefing, setLoadingBriefing] = useState(false);
  
  // Settings State
  const [showSettings, setShowSettings] = useState(false);
  const [settings, setSettings] = useState<GameSettings>({
      difficulty: 'normal',
      showHitboxes: false,
      particles: true
  });

  // Handle Game Start with Briefing
  const handleStartGame = async () => {
    setLoadingBriefing(true);
    setGameState(GameState.BRIEFING);
    // Reset Stats
    setStats({ score: 0, wave: 1, kills: 0 });
    setPlayerHp(100);
    
    // Fetch AI Briefing
    const text = await generateBriefing(1, 0);
    setBriefing(text);
    setLoadingBriefing(false);
  };

  const confirmLaunch = () => {
    setGameState(GameState.PLAYING);
  };

  const handleGameOver = () => {
    setGameState(GameState.GAME_OVER);
  };

  return (
    <div className="relative w-screen h-screen overflow-hidden bg-slate-900 font-sans text-white selection:bg-transparent">
      
      {/* Game Layer */}
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

      {/* UI Overlay */}
      <div className="absolute inset-0 z-10 pointer-events-none flex flex-col justify-between p-6">
        
        {/* HUD - Only visible when playing */}
        {gameState === GameState.PLAYING && (
          <div className="flex justify-between items-start w-full">
             {/* Left: Health */}
             <div className="flex flex-col gap-2">
                <div className="flex items-center gap-2 bg-black/50 p-2 rounded-lg border border-white/20 backdrop-blur-sm">
                   <Activity className="text-green-400" size={24} />
                   <div className="w-48 h-4 bg-gray-700 rounded-full overflow-hidden">
                      <div 
                        className={`h-full transition-all duration-300 ${playerHp > 30 ? 'bg-green-500' : 'bg-red-500 animate-pulse'}`} 
                        style={{ width: `${Math.max(0, playerHp)}%` }}
                      ></div>
                   </div>
                   <span className="font-bold font-mono">{Math.floor(playerHp)}%</span>
                </div>
             </div>

             {/* Right: Stats */}
             <div className="flex gap-4">
                <div className="flex items-center gap-2 bg-black/50 p-2 rounded-lg border border-white/20 backdrop-blur-sm">
                   <Trophy className="text-yellow-400" size={20} />
                   <span className="font-mono text-xl">{stats.score}</span>
                </div>
                <div className="flex items-center gap-2 bg-black/50 p-2 rounded-lg border border-white/20 backdrop-blur-sm">
                   <Skull className="text-red-400" size={20} />
                   <span className="font-mono text-xl">{stats.kills}</span>
                </div>
                <div className="flex items-center gap-2 bg-black/50 p-2 rounded-lg border border-white/20 backdrop-blur-sm">
                   <span className="text-sm uppercase text-gray-400">Wave</span>
                   <span className="font-mono text-xl text-blue-400">{stats.wave}</span>
                </div>
             </div>
          </div>
        )}
      </div>

      {/* SETTINGS MODAL */}
      {showSettings && (
          <div className="absolute inset-0 z-[60] flex items-center justify-center bg-black/70 backdrop-blur-sm">
              <div className="bg-slate-800 p-6 rounded-xl border border-slate-600 w-96 shadow-2xl pointer-events-auto">
                  <div className="flex justify-between items-center mb-6">
                      <h2 className="text-2xl font-bold flex items-center gap-2"><Settings /> Settings</h2>
                      <button onClick={() => setShowSettings(false)} className="hover:text-red-400"><X /></button>
                  </div>

                  <div className="space-y-6">
                      <div>
                          <label className="block text-slate-400 text-sm mb-2">Difficulty</label>
                          <div className="grid grid-cols-3 gap-2">
                              {['easy', 'normal', 'hard'].map((d) => (
                                  <button
                                    key={d}
                                    onClick={() => setSettings(s => ({...s, difficulty: d as any}))}
                                    className={`py-2 rounded capitalize ${settings.difficulty === d ? 'bg-blue-600 text-white' : 'bg-slate-700 text-slate-400 hover:bg-slate-600'}`}
                                  >
                                      {d}
                                  </button>
                              ))}
                          </div>
                      </div>

                      <div>
                           <label className="flex items-center justify-between cursor-pointer p-2 rounded hover:bg-slate-700/50">
                              <span>Enable Particles (Explosions)</span>
                              <input 
                                type="checkbox" 
                                checked={settings.particles} 
                                onChange={(e) => setSettings(s => ({...s, particles: e.target.checked}))}
                                className="accent-blue-500 w-5 h-5"
                              />
                           </label>
                           <label className="flex items-center justify-between cursor-pointer p-2 rounded hover:bg-slate-700/50">
                              <span>Show Hitboxes (Debug)</span>
                              <input 
                                type="checkbox" 
                                checked={settings.showHitboxes} 
                                onChange={(e) => setSettings(s => ({...s, showHitboxes: e.target.checked}))}
                                className="accent-blue-500 w-5 h-5"
                              />
                           </label>
                      </div>
                  </div>
                  
                  <div className="mt-6 text-center text-xs text-slate-500">
                      Settings apply immediately
                  </div>
              </div>
          </div>
      )}

      {/* PAUSE MENU */}
      {gameState === GameState.PAUSED && !showSettings && (
        <div className="absolute inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm">
             <div className="flex flex-col gap-4">
                 <h1 className="text-6xl font-black text-white text-center mb-4 tracking-wider">PAUSED</h1>
                 <button 
                     onClick={() => setGameState(GameState.PLAYING)}
                     className="pointer-events-auto bg-green-500 hover:bg-green-600 text-white font-bold py-3 px-8 rounded-full shadow-lg flex items-center justify-center gap-2 transform hover:scale-105 transition-all"
                 >
                    <Play fill="currentColor" /> RESUME
                 </button>
                 <button 
                     onClick={() => setShowSettings(true)}
                     className="pointer-events-auto bg-slate-700 hover:bg-slate-600 text-white font-bold py-3 px-8 rounded-full shadow-lg flex items-center justify-center gap-2"
                 >
                    <Settings /> SETTINGS
                 </button>
                 <button 
                     onClick={() => setGameState(GameState.MENU)}
                     className="pointer-events-auto bg-red-600 hover:bg-red-700 text-white font-bold py-3 px-8 rounded-full shadow-lg"
                 >
                    QUIT TO MENU
                 </button>
             </div>
        </div>
      )}

      {/* MAIN MENU */}
      {gameState === GameState.MENU && !showSettings && (
        <div className="absolute inset-0 z-50 flex items-center justify-center bg-slate-900/80 backdrop-blur-md">
           <div className="bg-slate-800 p-8 rounded-2xl shadow-2xl border-2 border-slate-600 max-w-md w-full text-center relative overflow-hidden">
              <div className="absolute top-0 left-0 w-full h-2 bg-gradient-to-r from-blue-500 via-purple-500 to-red-500"></div>
              
              <div className="mb-6 flex justify-center">
                 <Rocket size={64} className="text-blue-400 drop-shadow-[0_0_15px_rgba(59,130,246,0.5)]" />
              </div>
              <h1 className="text-5xl font-black italic tracking-tighter mb-2 bg-gradient-to-r from-blue-400 via-white to-blue-400 bg-clip-text text-transparent bg-[length:200%_auto] animate-gradient">
                BARK SQUADRON
              </h1>
              <p className="text-slate-400 mb-8 font-mono text-sm">v2.0 // TACTICAL DOGFIGHT</p>
              
              <div className="space-y-3">
                 <button 
                   onClick={handleStartGame}
                   className="w-full pointer-events-auto bg-blue-600 hover:bg-blue-500 text-white font-bold py-4 px-6 rounded-xl transition-all transform hover:scale-105 shadow-lg flex items-center justify-center gap-2 border-b-4 border-blue-800"
                 >
                   <Plane /> SCRAMBLE JETS
                 </button>
                 
                 <button 
                   onClick={() => setShowSettings(true)}
                   className="w-full pointer-events-auto bg-slate-700 hover:bg-slate-600 text-slate-200 font-bold py-3 px-6 rounded-xl transition-all flex items-center justify-center gap-2"
                 >
                   <Settings size={18} /> SETTINGS
                 </button>

                 <div className="text-sm text-slate-500 mt-4 border-t border-slate-700 pt-4 text-left">
                    <p className="flex items-center gap-2 mb-1"><Gamepad2 size={14}/> <strong>Controls:</strong></p>
                    <ul className="list-disc list-inside space-y-1 ml-1">
                        <li>Arrow Keys / WASD to Fly</li>
                        <li>SPACE to Shoot</li>
                        <li>ESC to Pause</li>
                    </ul>
                 </div>
              </div>
           </div>
        </div>
      )}

      {/* BRIEFING SCREEN */}
      {gameState === GameState.BRIEFING && (
        <div className="absolute inset-0 z-50 flex items-center justify-center bg-black">
           <div className="max-w-2xl w-full p-8 border-l-4 border-green-500 bg-slate-900/90 text-left font-mono shadow-[0_0_50px_rgba(34,197,94,0.2)]">
              <h2 className="text-green-500 text-xl mb-4 uppercase tracking-widest animate-pulse flex items-center gap-2">
                <Volume2 size={20}/> Incoming Transmission...
              </h2>
              
              {loadingBriefing ? (
                 <div className="text-white text-lg animate-pulse">Deciphering orders from HQ...</div>
              ) : (
                 <>
                   <p className="text-white text-2xl leading-relaxed mb-8 typing-effect border-b border-dashed border-green-900 pb-8">
                     "{briefing}"
                   </p>
                   <button 
                     onClick={confirmLaunch}
                     className="pointer-events-auto bg-green-600 hover:bg-green-500 text-black font-bold py-3 px-8 rounded-none uppercase tracking-widest transition-all w-full hover:tracking-[0.2em] duration-300"
                   >
                     Acknowledged. Launch!
                   </button>
                 </>
              )}
           </div>
        </div>
      )}

      {/* GAME OVER */}
      {gameState === GameState.GAME_OVER && (
        <div className="absolute inset-0 z-50 flex items-center justify-center bg-red-900/80 backdrop-blur-md">
           <div className="bg-slate-900 p-8 rounded-2xl shadow-2xl border-2 border-red-600 max-w-md w-full text-center transform scale-100 animate-in fade-in zoom-in duration-300">
              <h2 className="text-6xl font-black text-red-600 mb-2 drop-shadow-lg">MIA</h2>
              <p className="text-red-300 mb-6 uppercase tracking-widest">Missing In Action</p>
              
              <div className="grid grid-cols-2 gap-4 mb-8">
                 <div className="bg-slate-800 p-4 rounded-lg border border-slate-700">
                    <div className="text-slate-400 text-xs uppercase mb-1">Score</div>
                    <div className="text-3xl font-mono text-yellow-400">{stats.score}</div>
                 </div>
                 <div className="bg-slate-800 p-4 rounded-lg border border-slate-700">
                    <div className="text-slate-400 text-xs uppercase mb-1">Kills</div>
                    <div className="text-3xl font-mono text-white">{stats.kills}</div>
                 </div>
              </div>
              <button 
                   onClick={() => setGameState(GameState.MENU)}
                   className="w-full pointer-events-auto bg-slate-700 hover:bg-slate-600 text-white font-bold py-4 px-6 rounded-xl transition-all border-b-4 border-slate-900 active:border-b-0 active:translate-y-1"
                 >
                   Return to Hangar
              </button>
           </div>
        </div>
      )}
    </div>
  );
}
