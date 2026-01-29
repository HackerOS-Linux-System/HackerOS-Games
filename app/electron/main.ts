import { app, BrowserWindow, ipcMain } from 'electron';
import path from 'path';
import { spawn } from 'child_process';
import fs from 'fs';

// Define game launch logic in the main process
const GAMES_CONFIG: Record<string, { path: string; getCommand: (p: string) => string[] }> = {
    "starblaster": {
        path: "/usr/share/HackerOS/Scripts/HackerOS-Games/starblaster",
        getCommand: (p) => [p]
    },
    "bit-jump": {
        path: "/usr/share/HackerOS/Scripts/HackerOS-Games/bit-jump.love",
        getCommand: (p) => ["love", p]
    },
    "the-racer": {
        path: "/usr/share/HackerOS/Scripts/HackerOS-Games/the-racer",
        getCommand: (p) => [p]
    },
    "bark-squadron": {
        path: "/usr/share/HackerOS/Scripts/HackerOS-Games/bark-squadron.AppImage",
        getCommand: (p) => [p]
    }
};

let mainWindow: BrowserWindow | null = null;

function createWindow() {
    const isDev = !app.isPackaged;

    // Determine icon path safely
    // Dev: ../images/ (relative to dist-electron)
    // Prod: ../dist/images/ (relative to dist-electron inside asar, because we copy images to dist/images in build script)
    const iconPath = isDev
    ? path.join(__dirname, '../images/HackerOS-Games.png')
    : path.join(__dirname, '../dist/images/HackerOS-Games.png');

    mainWindow = new BrowserWindow({
        width: 1000,
        height: 700,
        backgroundColor: '#050505',
        icon: iconPath,
        webPreferences: {
            preload: path.join(__dirname, 'preload.js'),
                                   nodeIntegration: false,
                                   contextIsolation: true,
                                   webSecurity: false
        },
        autoHideMenuBar: true,
        titleBarStyle: 'hidden',
        titleBarOverlay: {
            color: '#050505',
            symbolColor: '#00ff41',
            height: 30
        }
    });

    if (isDev) {
        mainWindow.loadURL('http://localhost:5173');
    } else {
        mainWindow.loadFile(path.join(__dirname, '../dist/index.html'));
    }
}

app.whenReady().then(() => {
    createWindow();

    app.on('activate', () => {
        if (BrowserWindow.getAllWindows().length === 0) {
            createWindow();
        }
    });
});

app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') {
        app.quit();
    }
});

// IPC Handlers
ipcMain.handle('launch-game', async (_event, gameId: string) => {
    const game = GAMES_CONFIG[gameId];
    if (!game) {
        throw new Error(`Game '${gameId}' not configured.`);
    }

    // Check file existence
    if (!fs.existsSync(game.path)) {
        throw new Error(`Executable not found at: ${game.path}`);
    }

    // Ensure AppImages are executable
    if (game.path.endsWith('.AppImage')) {
        try {
            fs.chmodSync(game.path, '755');
        } catch (err) {
            console.warn('Failed to chmod AppImage:', err);
        }
    }

    const [command, ...args] = game.getCommand(game.path);

    console.log(`Launching ${gameId} -> Command: ${command} Args: ${args.join(' ')}`);

    try {
        const subprocess = spawn(command, args, {
            detached: true,
            stdio: 'ignore'
        });
        subprocess.unref();
        return { success: true };
    } catch (error: any) {
        console.error(error);
        throw new Error(`Failed to launch: ${error.message}`);
    }
});

ipcMain.handle('check-game-exists', async (_event, gameId: string) => {
    const game = GAMES_CONFIG[gameId];
    if (!game) return false;
    return fs.existsSync(game.path);
});
