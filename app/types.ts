export interface GameConfig {
    id: string;
    name: string;
    description: string;
    path: string;
    color: string; // Hex code
    twColor: string; // Tailwind class equivalent for borders/text
    twBg: string; // Tailwind class for buttons
    icon?: string; // Path to icon image
}

export interface ElectronAPI {
    launchGame: (gameId: string) => Promise<{ success: true }>;
    checkGameExists: (gameId: string) => Promise<boolean>;
}

declare global {
    interface Window {
        electronAPI: ElectronAPI;
    }
}
