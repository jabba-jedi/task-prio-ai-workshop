import { defineConfig } from 'vite'

// Minimal Vite configuration for workshop demo
export default defineConfig({
  // Use index.html as entry point (default)
  root: './',
  
  // Development server configuration
  server: {
    port: 5173,
    open: true, // Auto-open browser
    strictPort: false // Try next port if 5173 is taken
  },
  
  // Build configuration
  build: {
    outDir: 'dist',
    emptyOutDir: true,
    // Keep output simple for workshop
    minify: 'esbuild',
    sourcemap: false
  }
})

