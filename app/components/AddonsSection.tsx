import React from 'react';
import { AddonConfig, GameConfig } from '../types';
import { Package, Lock, Puzzle } from 'lucide-react';

interface Props { addons: AddonConfig[]; games: GameConfig[]; }

const AddonsSection: React.FC<Props> = ({ addons, games }) => {
  const getGame = (id: string) => games.find(g => g.id === id);

  return (
    <div style={{ padding: '32px', height: '100%', overflowY: 'auto' }}>
      <div style={{ marginBottom: '28px' }}>
        <div style={{
          fontFamily: 'Orbitron, monospace', fontSize: '16px', fontWeight: 700,
          color: 'var(--text)', letterSpacing: '4px', marginBottom: '6px',
        }}>
          ADDONS <span style={{ color: 'var(--text-dim)', fontSize: '11px', fontWeight: 400 }}>// GAME EXPANSIONS</span>
        </div>
        <div style={{
          display: 'flex', alignItems: 'center', gap: '8px',
          padding: '11px 16px', maxWidth: '580px',
          background: 'rgba(255,214,0,0.04)', border: '1px solid rgba(255,214,0,0.18)',
          fontSize: '11px', color: 'var(--yellow)',
        }}>
          <Puzzle size={13} />
          Addon downloads are coming in a future HackerOS Games update.
        </div>
      </div>

      <div style={{
        display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(270px,1fr))',
        gap: '14px', maxWidth: '880px',
      }}>
        {addons.map(addon => {
          const game = getGame(addon.targetGame);
          return (
            <div
              key={addon.id}
              className="game-card"
              style={{
                padding: '20px', opacity: 0.65,
                '--card-color': game?.color ?? '#555',
              } as React.CSSProperties}
            >
              {game && (
                <div style={{
                  display: 'inline-flex', alignItems: 'center', gap: '4px',
                  padding: '3px 8px', marginBottom: '12px',
                  background: `rgba(${game.rgb},0.08)`,
                  border: `1px solid ${game.color}30`,
                  fontSize: '9px', color: game.color, letterSpacing: '1px',
                }}>
                  {game.name.toUpperCase()}
                </div>
              )}
              <div style={{
                fontFamily: 'Orbitron, monospace', fontSize: '12px', fontWeight: 700,
                color: 'var(--text)', letterSpacing: '1px', marginBottom: '8px',
              }}>
                {addon.name}
              </div>
              <div style={{ fontSize: '11px', color: 'var(--text-dim)', lineHeight: '1.6', marginBottom: '16px' }}>
                {addon.description}
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <span style={{ fontSize: '9px', color: 'var(--text-dim)' }}>v{addon.version}</span>
                <button disabled style={{
                  display: 'flex', alignItems: 'center', gap: '5px',
                  padding: '5px 12px', background: 'transparent',
                  border: '1px solid #2a2a2a', color: '#3a3a3a',
                  fontSize: '9px', letterSpacing: '2px', textTransform: 'uppercase',
                  cursor: 'not-allowed', fontFamily: 'Share Tech Mono, monospace',
                }}>
                  <Lock size={9} /> SOON
                </button>
              </div>
            </div>
          );
        })}
      </div>

      <div style={{
        marginTop: '44px', padding: '28px',
        border: '1px dashed var(--border)', textAlign: 'center',
        maxWidth: '460px', color: 'var(--text-dim)',
      }}>
        <Package size={28} style={{ margin: '0 auto 10px', opacity: 0.25 }} />
        <div style={{ fontSize: '10px', letterSpacing: '2px', marginBottom: '8px' }}>MORE ADDONS IN DEVELOPMENT</div>
        <div style={{ fontSize: '10px', lineHeight: '1.7' }}>
          Community addon support and a full addon store are planned for a future update.
        </div>
      </div>
    </div>
  );
};

export default AddonsSection;
