import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react'; // If you have this plugin installed, otherwise you can remove this line and the plugin usage below.

// Assuming basic setup since vite config was missing.
// We set base to './' so assets work with file:// protocol in Electron production build.
export default defineConfig({
    base: './',
    server: {
        port: 5173,
        strictPort: true,
    },
    build: {
        outDir: 'dist',
        emptyOutDir: true,
    }
});
