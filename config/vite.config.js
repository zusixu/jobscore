import path from 'path'
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import legacy from '@vitejs/plugin-legacy'
import styleImport from 'vite-plugin-style-import'

// https://vitejs.dev/config/
export default defineConfig({
  base: process.env.VITE_APP_URL_BASE || '/',
  plugins: [
    vue(),
    legacy({
      targets: ['defaults', 'not IE 11']
    }),
    styleImport({
      libs: [
        {
          libraryName: 'element-plus',
          esModule: true,
          ensureStyleFile: true,
          resolveStyle: (name) => {
            return `element-plus/lib/theme-chalk/${name}.css`;
          },
          resolveComponent: (name) => {
            return `element-plus/lib/${name}`;
          },
        }
      ]
    })
  ],
  optimizeDeps: {
    include: ['vue', 'element-plus']
  },
  resolve: {
    alias: {
      '@': path.resolve('src')
    }
  },
  css: {
    postcss: './config/postcss.config.js'
  },
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
    sourcemap: process.env.NODE_ENV === 'development',
    minify: 'terser',
    terserOptions: {
      compress: {
        drop_console: process.env.NODE_ENV === 'production'
      }
    },
    rollupOptions: {
      output: {
        manualChunks: {
          'vue-vendor': ['vue', 'element-plus']
        }
      }
    }
  },
  server: {
    port: 5173,
    strictPort: false,
    open: true,
    cors: true
  },
  preview: {
    port: 4173,
    strictPort: false
  }
})
