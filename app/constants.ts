import { GameConfig } from './types';

export const GAMES: GameConfig[] = [
    {
        id: 'starblaster',
        name: 'Starblaster',
        description: 'Blast through stars in this exciting space shooter!',
        path: '/usr/share/HackerOS/Scripts/HackerOS-Games/starblaster',
        color: '#00ff41', // Neon Green
        twColor: 'text-neonGreen',
        twBg: 'bg-neonGreen hover:bg-green-400',
        // Use relative paths for Electron file:// protocol compatibility
        icon: './images/starblaster.png'
    },
{
    id: 'bit-jump',
    name: 'Bit Jump',
    description: 'Jump through bits in this platformer adventure!',
    path: '/usr/share/HackerOS/Scripts/HackerOS-Games/bit-jump.love',
    color: '#d600ff', // Neon Pink
    twColor: 'text-neonPink',
    twBg: 'bg-neonPink hover:bg-fuchsia-400',
    icon: './images/bit-jump.png'
},
{
    id: 'the-racer',
    name: 'The Racer',
    description: 'Race through circuits in this high-speed thriller!',
    path: '/usr/share/HackerOS/Scripts/HackerOS-Games/the-racer',
    color: '#ff0033', // Neon Red
    twColor: 'text-neonRed',
    twBg: 'bg-neonRed hover:bg-red-500',
    icon: './images/the-racer.png'
},
{
    id: 'bark-squadron',
    name: 'Bark Squadron',
    description: 'Dogfight your way to victory in the skies!',
    path: '/usr/share/HackerOS/Scripts/HackerOS-Games/bark-squadron.AppImage',
    color: '#00d0ff', // Neon Blue
    twColor: 'text-neonBlue',
    twBg: 'bg-neonBlue hover:bg-cyan-400',
    // No icon specified, will fall back to default behavior
}
];
