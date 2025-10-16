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
  
  // Preview server configuration (for production builds)
  preview: {
    port: 8080,
    host: '0.0.0.0',
    // Allow all hosts (needed for DigitalOcean, Vercel, Netlify, etc.)
    allowedHosts: [
      'stingray-app-iantr.ondigitalocean.app',
      '.ondigitalocean.app', // Allow all DigitalOcean apps
      'localhost'
    ]
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

