import { useEffect, useState } from 'react';
import { getTopScores } from '../services/tauriService';
import { HighScore } from '../types';
import { Trophy, X, Loader2 } from 'lucide-react';

interface Props {
  difficulty: string;
  onClose: () => void;
}

const DIFFS = ['easy', 'normal', 'hard'] as const;

export default function LeaderboardPanel({ difficulty, onClose }: Props) {
  const [scores, setScores] = useState<HighScore[]>([]);
  const [loading, setLoading] = useState(true);
  const [active, setActive] = useState<typeof DIFFS[number]>(difficulty as typeof DIFFS[number]);

  useEffect(() => {
    setLoading(true);
    getTopScores(active, 10).then(s => { setScores(s); setLoading(false); });
  }, [active]);

  return (
    <div className="bg-slate-900 border-2 border-slate-600 rounded-2xl p-8 w-full max-w-lg shadow-2xl">
      <div className="flex justify-between items-center mb-6">
        <h2 className="text-3xl font-black flex items-center gap-3">
          <Trophy className="text-yellow-400" /> LEADERBOARD
        </h2>
        <button onClick={onClose} className="text-slate-400 hover:text-white transition-colors"><X size={24} /></button>
      </div>

      {/* Difficulty tabs */}
      <div className="flex gap-2 mb-6">
        {DIFFS.map(d => (
          <button key={d} onClick={() => setActive(d)}
            className={`flex-1 py-2 rounded-lg capitalize font-bold transition-all ${active === d ? 'bg-blue-600 text-white' : 'bg-slate-700 text-slate-400 hover:bg-slate-600'}`}>
            {d}
          </button>
        ))}
      </div>

      {loading ? (
        <div className="flex items-center justify-center py-12 text-slate-400 gap-3">
          <Loader2 size={20} className="animate-spin" /> Loading scores…
        </div>
      ) : scores.length === 0 ? (
        <div className="text-center py-12 text-slate-500">
          <Trophy size={40} className="mx-auto mb-3 opacity-30" />
          <p>No scores yet on {active}.</p>
          <p className="text-sm mt-1">Be the first to set a record!</p>
        </div>
      ) : (
        <div className="space-y-2">
          {scores.map((s, i) => (
            <div key={i} className={`flex items-center gap-4 p-3 rounded-lg border ${i === 0 ? 'bg-yellow-900/20 border-yellow-600/30' : 'bg-slate-800 border-slate-700'}`}>
              <div className={`text-2xl font-black w-8 text-center ${i === 0 ? 'text-yellow-400' : i === 1 ? 'text-slate-300' : i === 2 ? 'text-orange-400' : 'text-slate-500'}`}>
                {i + 1}
              </div>
              <div className="flex-1">
                <div className="font-mono text-xl font-bold text-white">{s.score.toLocaleString()}</div>
                <div className="text-xs text-slate-400">Wave {s.wave} · {s.kills} kills · {new Date(s.timestamp * 1000).toLocaleDateString()}</div>
              </div>
              <div className={`text-sm font-bold capitalize px-2 py-1 rounded ${i === 0 ? 'text-yellow-400' : 'text-slate-400'}`}>
                {s.difficulty}
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
