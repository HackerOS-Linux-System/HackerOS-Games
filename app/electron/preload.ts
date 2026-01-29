import { contextBridge, ipcRenderer } from 'electron';

contextBridge.exposeInMainWorld('electronAPI', {
    launchGame: (gameId: string) => ipcRenderer.invoke('launch-game', gameId),
                                checkGameExists: (gameId: string) => ipcRenderer.invoke('check-game-exists', gameId),
});
