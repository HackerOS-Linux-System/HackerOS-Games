import React from 'react';
import { GAMES } from './constants';
import GameCard from './components/GameCard';
import ParticlesBackground from './components/ParticlesBackground';

const App: React.FC = () => {
    return (
        <div className="min-h-screen flex flex-col bg-background relative overflow-hidden text-white">

        {/* Background Layers */}
        <div className="absolute inset-0 bg-[size:40px_40px] bg-grid-pattern opacity-30 pointer-events-none z-0"></div>
        <ParticlesBackground />
        <div className="absolute inset-0 bg-gradient-to-b from-transparent via-transparent to-background pointer-events-none z-0"></div>

        {/* Header */}
        <header className="pt-10 pb-6 text-center z-10 relative">
        <div className="inline-block border border-neonGreen bg-black/50 backdrop-blur-sm px-8 py-4 rounded-sm shadow-[0_0_15px_rgba(0,255,65,0.2)]">
        <h1 className="text-5xl font-bold text-neonGreen tracking-widest uppercase glow-text mb-2">
        HackerOS
        </h1>
        <div className="flex items-center justify-center gap-2 text-neutral-400 text-sm tracking-[0.2em]">
        <span className="w-2 h-2 bg-neonGreen rounded-full animate-pulse"></span>
        GAMES LAUNCHER SYSTEM v0.6
        <span className="w-2 h-2 bg-neonGreen rounded-full animate-pulse"></span>
        </div>
        </div>
        </header>

        {/* Main Content Grid */}
        <main className="flex-grow p-8 flex items-center justify-center z-10">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8 max-w-7xl w-full">
        {GAMES.map((game) => (
            <GameCard key={game.id} game={game} />
        ))}
        </div>
        </main>

        {/* Footer */}
        <footer className="py-6 text-center text-neutral-600 text-xs border-t border-neutral-900 z-10 bg-black/80 backdrop-blur-md">
        <p className="tracking-wider">SECURE CONNECTION ESTABLISHED // UNAUTHORIZED ACCESS PROHIBITED</p>
        <p className="mt-1 font-bold text-neutral-700">HACKEROS CORP © 2077</p>
        </footer>

        </div>
    );
};

export default App;
