import React, { useState, useCallback, useEffect } from 'react';
import { GameConfig } from '../types';

interface GameCardProps {
    game: GameConfig;
}

const GameCard: React.FC<GameCardProps> = ({ game }) => {
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState<string | null>(null);
    const [installed, setInstalled] = useState<boolean | null>(null);

    // Check if installed on mount
    useEffect(() => {
        if (window.electronAPI) {
            window.electronAPI.checkGameExists(game.id)
            .then(setInstalled)
            .catch(() => setInstalled(false));
        } else {
            console.warn("Electron API not found - running in browser mode?");
            setInstalled(false);
        }
    }, [game.id]);

    const handleLaunch = useCallback(async () => {
        if (installed === false) return;
        if (!window.electronAPI) {
            setError('ELECTRON_API_MISSING');
            return;
        }

        setLoading(true);
        setError(null);
        try {
            await window.electronAPI.launchGame(game.id);
            setTimeout(() => setLoading(false), 3000); // Simulate init sequence
        } catch (err: any) {
            setError(err.message || 'EXECUTION FAILED');
            setLoading(false);
        }
    }, [game.id, installed]);

    return (
        <div className="group relative bg-surface/80 backdrop-blur border border-neutral-800 p-1 flex flex-col h-[300px] transition-all duration-300 hover:-translate-y-1">

        {/* Dynamic Colored Border Glow on Hover */}
        <div
        className="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity duration-300 pointer-events-none"
        style={{ boxShadow: `0 0 20px ${game.color}40`, border: `1px solid ${game.color}` }}
        ></div>

        {/* Top Bar with decorative tech bits */}
        <div className="flex justify-between items-center px-2 py-1 bg-black/40 text-[10px] text-neutral-500 font-mono mb-4 border-b border-neutral-800">
        <span>ID: {game.id.toUpperCase().substring(0, 4)}</span>
        <div className="flex gap-1">
        <div className={`w-2 h-2 rounded-full ${installed ? 'bg-green-500' : 'bg-red-900'}`}></div>
        <div className="w-2 h-2 rounded-full bg-neutral-800"></div>
        <div className="w-2 h-2 rounded-full bg-neutral-800"></div>
        </div>
        </div>

        <div className="flex-grow flex flex-col items-center justify-center px-4 text-center z-10">
        {/* Game Icon */}
        <div
        className="w-20 h-20 mb-4 flex items-center justify-center transition-all duration-300 group-hover:scale-110"
        >
        {game.icon ? (
            <img
            src={game.icon}
            alt={game.name}
            className="w-full h-full object-contain drop-shadow-[0_0_5px_rgba(255,255,255,0.3)]"
            onError={(e) => {
                // Fallback to text if image fails to load
                e.currentTarget.style.display = 'none';
                const parent = e.currentTarget.parentElement;
                if (parent) {
                    const span = document.createElement('span');
                    span.innerText = game.name.charAt(0);
                    span.className = "text-3xl font-bold";
                    span.style.color = game.color;
                    parent.classList.add('rounded-full', 'border-2', 'border-dashed');
                    parent.style.borderColor = game.color;
                    parent.appendChild(span);
                }
            }}
            />
        ) : (
            <div
            className="w-full h-full rounded-full flex items-center justify-center border-2 border-dashed opacity-80 group-hover:opacity-100"
            style={{ borderColor: game.color, color: game.color }}
            >
            <span className="text-3xl font-bold">{game.name.charAt(0)}</span>
            </div>
        )}
        </div>

        <h2
        className={`text-2xl font-bold mb-2 uppercase tracking-wider glow-text transition-colors duration-300`}
        style={{ color: game.color }}
        >
        {game.name}
        </h2>

        <p className="text-neutral-400 text-xs leading-relaxed font-sans mb-4 border-t border-b border-neutral-800 py-2 w-full line-clamp-2">
        {game.description}
        </p>
        </div>

        {/* Action Area */}
        <div className="p-4 z-10">
        {error && (
            <div className="text-red-500 text-[10px] text-center mb-2 font-bold bg-black/50 border border-red-900 p-1 animate-pulse">
            ERR: {error}
            </div>
        )}

        <button
        onClick={handleLaunch}
        disabled={loading || installed === false}
        className={`
            w-full py-3 px-4 font-bold text-black uppercase tracking-widest text-sm
            transition-all duration-200 clip-path-button relative overflow-hidden
            ${game.twBg}
            ${loading ? 'opacity-70 cursor-wait' : 'opacity-90 hover:opacity-100'}
            ${installed === false ? 'grayscale cursor-not-allowed opacity-30' : ''}
            `}
            style={{
                boxShadow: loading ? `0 0 15px ${game.color}` : 'none',
            }}
            >
            <span className="relative z-10">
            {loading ? 'INITIALIZING...' : installed === false ? 'MISSING_FILE' : 'LAUNCH_EXE'}
            </span>

            {/* Scanline overlay on button */}
            <div className="absolute inset-0 bg-[url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAQAAAAECAYAAACp8Z5+AAAAIklEQVQIW2NkQAKrVq36zwjjgzhhZWGMYAEYB8RmROaABADeOQ8CXl/xfgAAAABJRU5ErkJggg==')] opacity-20"></div>
            </button>
            </div>
            </div>
    );
};

export default GameCard;
