#!/bin/bash
set -e

# Function to log progress
log() { echo -e "\033[1;34m[INFO]\033[0m $1"; }
error() { echo -e "\033[1;31m[ERROR]\033[0m $1"; exit 1; }

# Starting setup
log "Initializing app..."

# Create Next.js application
rm -rf metaforge .next node_modules
npx create-next-app@15.3.2 metaforge --src-dir --use-pages --no-app --ts --tailwind --turbopack --eslint --import-alias "@/*" || error "Failed to create Next.js app"
cd metaforge || error "Failed to enter project directory"

# Create base directory structure following architecture requirements
log "Creating directories..."
mkdir -p src/{types,hooks,utils/{db,continentFetcher,auth},components/{ui,common,entity,team-builder,leaderboard,auth},pages/{api/{tft/{entities,player,leaderboard},cron,debug,auth},entity/\[entity\],meta-report,stats-explorer,team-builder,guides,news,profile,auth,leaderboard,login,player}} 

# Copy data files
[ -d "../public" ] && cp -r ../public/* public/

log "Writing files..."

# Create .env.local with correct client secret
RANDOM_SECRET=$(openssl rand -hex 32 2>/dev/null || head -c 32 /dev/urandom | xxd -p)
cat > .env.local << EOF
# Riot API Key for TFT data
RIOT_API_KEY=RGAPI-f36ff924-4aee-4661-b00f-5baf1bbe8328

# Riot OAuth credentials
RIOT_CLIENT_ID=f0603360-ce93-436c-8b2f-1185aedba99e
RIOT_CLIENT_SECRET=gUZXora5_twkP3RS7S4mz29VpWp9Da97WtlUPfF_mIf
RIOT_REDIRECT_URI=https://metaforge.lol/auth/callback

# Public variables for client-side
NEXT_PUBLIC_RIOT_CLIENT_ID=f0603360-ce93-436c-8b2f-1185aedba99e
NEXT_PUBLIC_BASE_URL=https://metaforge.lol
NEXT_PUBLIC_AUTH_CALLBACK=/auth/callback

# Database connection
NEON_DATABASE_URL=postgresql://metaforge_owner:npg_mSzOKh79ygeP@ep-lively-mud-a4mgzxpd-pooler.us-east-1.aws.neon.tech/metaforge?sslmode=require

# Other configuration
CRON_SECRET=${RANDOM_SECRET}
NODE_ENV=production
EOF

# Create a .gitignore file to ensure .env.local isn't committed
cat > .gitignore << 'EOL'
# dependencies
/node_modules
/.pnp
.pnp.js

# testing
/coverage

# next.js
/.next/
/out/

# production
/build

# misc
.DS_Store
*.pem

# debug
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# local env files
.env.local
.env.development.local
.env.test.local
.env.production.local

# vercel
.vercel

# typescript
*.tsbuildinfo
next-env.d.ts
EOL

# Run the cron job to rebuild the data
cat > refresh-data.sh << 'EOL'
"curl -X POST http://localhost:3000/api/cron/refresh-data -H \"Authorization: Bearer \$(grep CRON_SECRET .env.local | cut -d '=' -f2)\""
EOL

# Create next.config.js
cat > next.config.js << 'EOL'
const path = require('path');

/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  
  // Webpack configuration for path aliases
  webpack: (config, { isServer }) => {
    config.resolve.alias['@'] = path.resolve(__dirname, 'src');
    return config;
  },
  
  // ESLint configuration
  eslint: {
    dirs: ['src/pages', 'src/components', 'src/utils', 'src/hooks', 'src/types'],
    ignoreDuringBuilds: false,
  }
}

module.exports = nextConfig
EOL

cat > package.json << 'EOL'
{
  "name": "metaforge-tft",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "fix-deps": "npm audit fix"
  },
  "dependencies": {
    "@dnd-kit/core": "^6.0.8",
    "@dnd-kit/utilities": "^3.2.1",
    "@fontsource/exo-2": "^5.0.8",
    "@next/font": "^13.4.19",
    "@react-hook/window-size": "^3.1.1",
    "@tanstack/react-query": "^4.35.3",
    "@use-gesture/react": "^10.2.27",
    "autoprefixer": "^10.4.15",
    "axios": "^1.5.0",
    "cookie": "^0.5.0",
    "framer-motion": "^10.16.4",
    "gsap": "^3.12.2",
    "lodash": "^4.17.21",
    "lucide-react": "^0.263.1",
    "next": "15.3.2",
    "pg": "^8.11.3",
    "postcss": "^8.4.29",
    "postcss-flexbugs-fixes": "^5.0.2",
    "postcss-preset-env": "^9.1.3",
    "react": "18.3.1",
    "react-dnd": "^16.0.1",
    "react-dnd-html5-backend": "^16.0.1",
    "react-dnd-touch-backend": "^16.0.1",
    "react-dom": "18.3.1",
    "react-spring": "^9.7.2",
    "recharts": "^2.8.0",
    "tailwindcss": "^3.3.3",
    "typescript": "5.2.2"
  },
  "devDependencies": {
    "@types/cookie": "^0.5.1",
    "@types/jsonwebtoken": "^9.0.2",
    "@types/lodash": "^4.14.197",
    "@types/node": "^20.6.0",
    "@types/pg": "^8.10.2",
    "@types/react": "^18.2.21",
    "@types/react-dom": "^18.2.7",
    "eslint": "^8.49.0",
    "eslint-config-next": "^15.3.2"
  },
  "overrides": {
    "react": "18.3.1",
    "react-dom": "18.3.1",
    "@react-three/fiber": {
      "react": "18.3.1",
      "react-dom": "18.3.1"
    },
    "react-native": {
      "react": "18.3.1"
    },
    "use-sync-external-store": {
      "react": "18.3.1" 
    },
    "glob": "^9.3.5",
    "rimraf": "^5.0.1",
    "@humanwhocodes/config-array": "^0.11.11",
    "@humanwhocodes/object-schema": "^2.0.2",
    "inflight": "^1.0.6",
    "react-use-measure": {
      "react": "18.3.1",
      "react-dom": "18.3.1"
    },
    "suspend-react": {
      "react": "18.3.1"
    },
    "zustand": {
      "react": "18.3.1"
    },
    "@react-native/virtualized-lists": {
      "react": "18.3.1"
    },
    "its-fine": {
      "react": "18.3.1"
    },
    "react-reconciler": {
      "react": "18.3.1"
    }
  },
  "resolutions": {
    "react": "18.3.1",
    "react-dom": "18.3.1",
    "glob": "^9.3.5",
    "minimatch": "^9.0.3"
  }
}
EOL

# Create a simplified root .eslintrc.json to disable most TypeScript checks
cat > .eslintrc.json << 'EOL'
{
  "extends": "next/core-web-vitals",
  "rules": {
    "@typescript-eslint/no-unused-vars": "off",
    "@typescript-eslint/no-explicit-any": "off", 
    "@typescript-eslint/no-unnecessary-type-constraint": "off",
    "@typescript-eslint/no-namespace": "off",
    "react/no-unescaped-entities": "off",
    "react-hooks/exhaustive-deps": "warn",
    "@next/next/no-img-element": "off"
  }
}
EOL

# Create a fully optimized postcss.config.js
cat > postcss.config.js << 'EOL'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
    'postcss-flexbugs-fixes': {},
    'postcss-preset-env': {
      autoprefixer: {
        flexbox: 'no-2009',
      },
      stage: 3,
      features: {
        'custom-properties': false,
      },
    },
  },
}
EOL

# Create a more flexible tsconfig.json
cat > tsconfig.json << 'EOL'
{
  "compilerOptions": {
    "target": "es2015",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "forceConsistentCasingInFileNames": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx"],
  "exclude": ["node_modules"]
}
EOL

# Create vercel.json for deployment
cat > vercel.json << 'EOF'
{
  "crons": [{"path": "/api/cron/refresh-data", "schedule": "0 * * * *"}]
}
EOF

# =====================
# STYLES SECTION
# =====================

# Create a more optimized tailwind config
cat > tailwind.config.js << 'EOL'
const defaultTheme = require('tailwindcss/defaultTheme');

module.exports = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx}', 
    './src/components/**/*.{js,ts,jsx,tsx}',
    './src/**/*.{js,ts,jsx,tsx}'
  ],
  theme: {
    extend: {
      colors: {
        // Solar Eclipse Color System
        'void-core': '#1c1917',
        'eclipse-shadow': '#292524',
        'solar-flare': '#f59e0b',
        'corona-light': '#fef3c7',
        'stellar-white': '#fafafa',
        'cosmic-dust': '#d6d3d1',
        'verdant-success': '#84cc16',
        'burning-warning': '#fb923c',
        'crimson-alert': '#dc2626',
        
        // Legacy colors for backward compatibility
        brown: '#1c1917',
        'brown-light': '#292524',
        cream: '#fef3c7',
        'cream-dark': '#E5D9BC',
        'gold': '#f59e0b',
        'gold-light': '#fb923c',
      },
      backgroundImage: { 
        'main-bg': "url('/assets/app/bg.jpg')",
        'eclipse-gradient': 'linear-gradient(to right, #1c1917, #292524)',
        'solar-horizon': 'linear-gradient(to right, #f59e0b, #fb923c)',
        'dark-matter': 'radial-gradient(circle at center, #292524, #1c1917)',
      },
      fontFamily: {
        sans: ['Exo 2', ...defaultTheme.fontFamily.sans],
        mono: ['JetBrains Mono', ...defaultTheme.fontFamily.mono],
      },
      fontSize: {
        'massive': ['42px', '52px'],
        'xlarge': ['32px', '40px'],
        'large': ['24px', '32px'],
      },
      zIndex: { 
        '60': '60', 
        '70': '70' 
      },
      minWidth: { 
        '24': '6rem',
        '16': '4rem',
        '32': '8rem',
      },
      maxWidth: { 
        '28': '7rem', 
        '32': '8rem' 
      },
      animation: {
        'pulse-slow': 'pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite',
        'glow-pulse': 'glow 2s ease-in-out infinite alternate',
        'float': 'float 6s ease-in-out infinite',
      },
      keyframes: {
        glow: {
          '0%': { boxShadow: '0 0 5px rgba(245, 158, 11, 0.5)' },
          '100%': { boxShadow: '0 0 20px rgba(245, 158, 11, 0.8)' },
        },
        float: {
          '0%, 100%': { transform: 'translateY(0)' },
          '50%': { transform: 'translateY(-10px)' },
        },
      },
      boxShadow: {
        'solar': '0 4px 14px rgba(245, 158, 11, 0.25)',
        'inner-solar': 'inset 0 2px 4px 0 rgba(245, 158, 11, 0.05)',
        'eclipse': '0 10px 25px -5px rgba(0, 0, 0, 0.8)',
      },
    },
  },
  plugins: [],
  safelist: [
    'grid-cols-2', 'grid-cols-3', 'grid-cols-4', 'min-w-24',
    'animate-pulse', 'animate-glow-pulse', 'animate-float',
    'opacity-50', 'blur-sm',
    'touch-manipulation', 'touch-pan-y',
    'bg-void-core', 'bg-eclipse-shadow', 'text-corona-light', 'text-solar-flare',
    'border-solar-flare', 'border-solar-flare/30', 'border-solar-flare/50',
    'shadow-solar', 'shadow-inner-solar', 'shadow-eclipse'
  ]
}
EOL

# Create complete globals.css file
cat > src/styles/globals.css << 'EOL'
@import '@fontsource/exo-2/400.css';
@import '@fontsource/exo-2/500.css';
@import '@fontsource/exo-2/600.css';
@import '@fontsource/exo-2/700.css';

@tailwind base;
@tailwind components;
@tailwind utilities;

/* ===== Base Styles ===== */
html, body { 
  @apply text-corona-light bg-void-core overscroll-none;
  font-family: 'Exo 2', sans-serif;
  letter-spacing: -0.01em;
}

h1, h2, h3, h4, h5, h6 {
  @apply font-sans tracking-tight text-stellar-white;
  letter-spacing: -0.02em;
}

/* ===== UI Components ===== */
.tooltip { 
  @apply absolute bg-eclipse-shadow/95 border border-solar-flare/60 rounded-lg p-2 text-xs pointer-events-none z-50 whitespace-nowrap transition-opacity shadow-solar; 
  backdrop-filter: blur(8px);
}

/* Table styles - MAJOR FIX for row height */
.stats-table { 
  @apply w-full border-collapse;
}

.stats-table th { 
  @apply sticky top-0 z-10 bg-void-core/95 px-4 py-3 text-left text-solar-flare font-semibold tracking-wider border-b border-solar-flare/30; 
  font-family: 'Exo 2', sans-serif;
}

.stats-table td {
  @apply px-4 py-3 border-b border-solar-flare/10 align-middle;
  font-family: 'Exo 2', sans-serif;
}

.stats-table tbody tr { 
  @apply hover:bg-solar-flare/20 transition-colors duration-300;
  height: 64px; /* EXPLICIT HEIGHT FIX */
  min-height: 64px;
}

.stats-table tbody tr:nth-child(even) {
  @apply bg-eclipse-shadow/30;
}

/* Stats table container - ensure proper scrolling */
.stats-table-container {
  max-height: calc(100vh - 340px);
  overflow-y: auto;
  border: 1px solid rgba(245, 158, 11, 0.3);
  border-radius: 0.5rem;
}

/* Scrollbars */
::-webkit-scrollbar { 
  @apply w-2 h-2; 
}

::-webkit-scrollbar-track { 
  @apply bg-void-core/50 rounded-sm; 
}

::-webkit-scrollbar-thumb { 
  @apply bg-solar-flare/70 rounded-sm; 
}

/* ===== Component Classes ===== */
@layer components {
  .card { 
    @apply bg-eclipse-shadow/70 rounded-xl shadow-eclipse border border-solar-flare/30 p-4 transition-all duration-300;
    backdrop-filter: blur(8px);
  }
  
  .card:hover {
    @apply border-solar-flare/40 shadow-solar;
  }
  
  .stat-box { 
    @apply bg-void-core/60 p-3 rounded-lg text-center border border-solar-flare/10 transition-all duration-300; 
  }
  
  .stat-box:hover {
    @apply border-solar-flare/30;
  }
  
  .filter-btn { 
    @apply px-3 py-1 text-xs rounded-full transition-all duration-300; 
  }
  
  .filter-active { 
    @apply bg-solar-flare text-void-core; 
  }
  
  .filter-inactive { 
    @apply bg-eclipse-shadow/30 hover:bg-eclipse-shadow/50 border border-solar-flare/20 hover:border-solar-flare/40; 
  }
  
  .section-card {
    @apply bg-eclipse-shadow/20 rounded-xl p-4 border border-solar-flare/10 transition-all duration-300;
  }
  
  .section-title {
    @apply text-lg font-semibold text-solar-flare mb-3;
  }
  
  .panel-card {
    @apply bg-void-core/60 rounded-xl border border-solar-flare/40 backdrop-filter backdrop-blur-md transition-all duration-300;
  }
  
  .panel-title {
    @apply text-solar-flare text-lg px-3 py-2 ml-1 border-b border-solar-flare/20;
  }

  .feature-banner {
    @apply bg-eclipse-shadow/60 border border-solar-flare/40 p-3 rounded-xl backdrop-blur-md shadow-solar transition-all duration-300;
  }

  .feature-cards-container {
    @apply grid grid-cols-1 md:grid-cols-3 gap-3;
  }
  
  .feature-card {
    @apply h-full bg-void-core/20 backdrop-filter backdrop-blur-md overflow-hidden relative rounded-xl border border-solar-flare/30 shadow-md transition-all duration-300 hover:bg-eclipse-shadow/50 hover:border-solar-flare/50 hover:shadow-solar;
  }
  
  /* Solar Eclipse Button System */
  .btn {
    @apply px-4 py-2 rounded-lg font-medium transition-all duration-300 transform;
  }
  
  .btn:hover {
    @apply scale-105 shadow-solar;
  }
  
  .btn-primary {
    @apply bg-gradient-to-r from-solar-flare to-burning-warning text-void-core shadow-md;
  }
  
  .btn-secondary {
    @apply bg-eclipse-shadow text-corona-light border border-solar-flare/50;
  }
  
  .btn-ghost {
    @apply bg-transparent text-corona-light border border-solar-flare/30 hover:bg-solar-flare/10;
  }
  
  /* Loading State Classes */
  .loading-shimmer {
    @apply animate-pulse bg-eclipse-shadow/30 rounded-lg;
  }
  
  .loading-overlay {
    @apply absolute inset-0 bg-void-core/60 flex items-center justify-center z-50 backdrop-filter backdrop-blur-sm;
  }
  
  .loading-spinner {
    @apply relative;
  }
  
  .loading-spinner:before {
    content: "";
    @apply w-full h-full rounded-full absolute;
    border: 4px solid rgba(245, 158, 11, 0.1);
  }
  
  .loading-spinner:after {
    content: "";
    @apply w-full h-full rounded-full absolute animate-spin;
    border: 4px solid transparent;
    border-top-color: #f59e0b;
    border-radius: 50%;
  }
  
  .error-banner {
    @apply bg-crimson-alert/30 text-corona-light rounded-lg border border-crimson-alert/60 p-3 my-2 flex justify-between items-center backdrop-filter backdrop-blur-sm transition-all duration-300;
  }
}

/* ===== Hexagon Grid System - Solar Enhancement ===== */
.honeycomb-container {
  @apply flex flex-col justify-center items-center overflow-hidden;
  background: transparent;
  filter: drop-shadow(0px 2px 8px rgba(0, 0, 0, 0.4));
}

/* Hex rows */
.hex-row {
  @apply flex relative;
  margin-bottom: -8px;
}

.hex-row:nth-child(odd) { margin-right: 36px; }
.hex-row:nth-child(even) { margin-left: 58px; }

/* Basic hex cell */
.hex-cell {
  width: 84px;
  height: 92px;
  @apply relative mr-2.5 transition-all duration-300;
}

/* Hex container with clip path for hexagonal shape */
.hex-container {
  width: 84px;
  height: 92px;
  @apply absolute flex justify-center items-center transition-all duration-300;
  clip-path: polygon(50% 0%, 100% 25%, 100% 75%, 50% 100%, 0% 75%, 0% 25%);
  background: rgba(41, 37, 36, 0.7);
  box-shadow: inset 0 0 10px rgba(0, 0, 0, 0.6), 0 0 15px rgba(0, 0, 0, 0.2);
}

.hex-container:before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  @apply transition-opacity duration-300 opacity-0;
  background: linear-gradient(45deg, rgba(245, 158, 11, 0.1), rgba(251, 146, 60, 0.05));
}

.hex-container:hover {
  background: rgba(41, 37, 36, 0.8);
}

.hex-container:hover:before {
  @apply opacity-100;
}

.hex-drop-active { 
  background: rgba(245, 158, 11, 0.2) !important;
  box-shadow: 0 0 15px rgba(245, 158, 11, 0.3);
}

.hex-drop-active:before {
  @apply opacity-100;
}

.hex-drop-invalid { 
  background: rgba(220, 38, 38, 0.2) !important;
  box-shadow: 0 0 15px rgba(220, 38, 38, 0.3);
}

/* Star container to allow overflow outside hex */
.star-container {
    position: absolute;
    top: -5px;
    left: 50%;
    transform: translateX(-50%);  
    z-index: 30;
    filter: drop-shadow(0px 1px 4px rgba(245, 158, 11, 0.7));
}

/* ===== Units and Items ===== */
/* Units on the board */
.unit-wrapper {
  @apply relative w-full flex flex-col items-center touch-manipulation transition-transform duration-300;
}

.unit-wrapper:hover {
  @apply scale-105;
}

.board-unit {
  width: 78px;
  height: 84px;
  @apply relative z-10 flex justify-center items-center cursor-grab touch-manipulation transition-all duration-300;
  clip-path: polygon(50% 0%, 100% 25%, 100% 75%, 50% 100%, 0% 75%, 0% 25%);
}

.board-unit-border {
  @apply absolute w-full h-full transition-all duration-300;
  clip-path: polygon(50% 0%, 100% 25%, 100% 75%, 50% 100%, 0% 75%, 0% 25%);
}

.board-unit-content {
  @apply absolute flex justify-center items-center transition-all duration-300;
  width: calc(100% - 4px);
  height: calc(100% - 4px);
  top: 2px;
  left: 2px;
  clip-path: polygon(50% 0%, 100% 25%, 100% 75%, 50% 100%, 0% 75%, 0% 25%);
  background-color: #1c1917;
}

.board-unit-content:before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  @apply transition-opacity duration-300 opacity-0;
  background: linear-gradient(45deg, rgba(245, 158, 11, 0.15), rgba(251, 146, 60, 0.05));
}

.board-unit:hover .board-unit-content:before {
  @apply opacity-100;
}

.board-unit-img {
  @apply w-full h-full object-cover transition-transform duration-300;
  transform: scale(1.0);
}

.board-unit:hover .board-unit-img {
  transform: scale(1.05);
}

/* Selector units - Changed to square format */
.selector-unit-wrapper {
  @apply relative cursor-grab inline-block touch-manipulation transition-transform duration-300;
}

.selector-unit-wrapper:hover {
  @apply scale-105;
}

.selector-unit-border {
  width: 48px;
  height: 48px;
  @apply absolute transition-all duration-300;
  clip-path: polygon(50% 0%, 100% 25%, 100% 75%, 50% 100%, 0% 75%, 0% 25%);
}

.selector-unit-content {
  @apply absolute flex justify-center items-center overflow-hidden transition-all duration-300;
  width: calc(100% - 2px);
  height: calc(100% - 2px);
  top: 1px;
  left: 1px;
  clip-path: polygon(50% 0%, 100% 25%, 100% 75%, 50% 100%, 0% 75%, 0% 25%);
  background-color: #1c1917;
}

.selector-unit-content:before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  @apply transition-opacity duration-300 opacity-0;
  background: linear-gradient(45deg, rgba(245, 158, 11, 0.15), rgba(251, 146, 60, 0.05));
}

.selector-unit-wrapper:hover .selector-unit-content:before {
  @apply opacity-100;
}

.selector-unit-img {
  @apply w-full h-full object-contain transition-transform duration-300;
}

.selector-unit-wrapper:hover .selector-unit-img {
  transform: scale(1.1);
}

/* Item container */
.item-container-absolute {
  @apply absolute bottom-0.5 left-1/2 flex justify-center p-0.5 z-50 rounded-lg pointer-events-auto w-auto;
  transform: translateX(-50%);
  background: rgba(28, 25, 23, 0.85);
  border: 1px solid rgba(245, 158, 11, 0.6);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.4);
}

.item-wrapper {
  @apply relative w-5 h-5 mx-px transition-transform duration-150 touch-manipulation;
}

.item-wrapper:hover { 
  transform: scale(1.2);
  filter: drop-shadow(0 0 5px rgba(245, 158, 11, 0.5));
}

.item-img {
  @apply w-full h-full object-contain transition-all duration-300;
  filter: drop-shadow(0 0 3px rgba(245, 158, 11, 0.4));
}

.item-wrapper:hover .item-img {
  filter: drop-shadow(0 0 5px rgba(245, 158, 11, 0.7));
}

/* ===== Feature Card Styling ===== */
.feature-hex-container {
  @apply relative w-16 h-16 flex items-center justify-center transition-all duration-300;
}

.feature-hex-svg {
  @apply absolute w-14 h-14 transition-all duration-300;
  filter: drop-shadow(0 0 2px rgba(245, 158, 11, 0.2));
}

.feature-card:hover .feature-hex-svg {
  filter: drop-shadow(0 0 3px rgba(245, 158, 11, 0.3));
}

.feature-hex-content {
  @apply text-solar-flare text-3xl relative z-20 transition-all duration-300;
}

.feature-card:hover .feature-hex-content {
  @apply text-burning-warning scale-105;
}

.feature-hex-glow {
  @apply absolute inset-0 opacity-0 transition-all duration-300;
}

.feature-card:hover .feature-hex-glow {
  @apply opacity-10;
}

/* ===== Dropdown Menu Styling ===== */
.dropdown-content {
  @apply absolute z-50 w-48 mt-1 bg-eclipse-shadow/95 rounded-xl shadow-solar;
  animation: fadeIn 0.2s cubic-bezier(0.2, 0.8, 0.2, 1);
  backdrop-filter: blur(8px);
  border: 1px solid rgba(245, 158, 11, 0.3);
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(-8px); }
  to { opacity: 1; transform: translateY(0); }
}

.dropdown-content a, .dropdown-content button {
  @apply block px-4 py-2 text-sm hover:bg-solar-flare/10 text-corona-light transition-colors duration-200;
}

.dropdown-content a:first-child, .dropdown-content button:first-child {
  @apply rounded-t-xl;
}

.dropdown-content a:last-child, .dropdown-content button:last-child {
  @apply rounded-b-xl;
}

/* ===== Mobile optimizations ===== */
@media (max-width: 640px) {
  .stats-table {
    @apply text-xs;
  }
  
  .stats-table td, .stats-table th {
    @apply px-2 py-2;
  }
  
  .stats-table tbody tr {
    height: 48px; /* Smaller height for mobile */
    min-height: 48px;
  }
  
  .honeycomb-container {
    @apply p-2 scale-90 transform-gpu;
    min-width: 100%;
    margin-left: -5%;
  }
  
  .hex-cell {
    @apply mr-1.5;
  }
}

/* Custom scrollbar */
.custom-scrollbar::-webkit-scrollbar {
  width: 6px;
  height: 6px;
}

.custom-scrollbar::-webkit-scrollbar-track {
  background: rgba(30, 20, 10, 0.2);
  border-radius: 10px;
}

.custom-scrollbar::-webkit-scrollbar-thumb {
  background: rgba(245, 158, 11, 0.3);
  border-radius: 10px;
}

.custom-scrollbar::-webkit-scrollbar-thumb:hover {
  background: rgba(245, 158, 11, 0.5);
}

/* For Firefox */
.custom-scrollbar {
  scrollbar-width: thin;
  scrollbar-color: rgba(245, 158, 11, 0.3) rgba(30, 20, 10, 0.2);
}

/* ===== Enhanced Responsive Styles ===== */

/* Responsive container handling */
.responsive-container {
  width: 100%;
  padding-left: 0.5rem;
  padding-right: 0.5rem;
}

@media (min-width: 640px) {
  .responsive-container {
    padding-left: 1rem;
    padding-right: 1rem;
  }
}

@media (min-width: 768px) {
  .responsive-container {
    padding-left: 1.5rem;
    padding-right: 1.5rem;
  }
}

/* Mobile menu animation */
@keyframes slideDown {
  from { max-height: 0; opacity: 0; }
  to { max-height: 1000px; opacity: 1; }
}

@keyframes slideUp {
  from { max-height: 1000px; opacity: 1; }
  to { max-height: 0; opacity: 0; }
}

.menu-enter {
  animation: slideDown 0.3s cubic-bezier(0.2, 0.8, 0.2, 1) forwards;
}

.menu-exit {
  animation: slideUp 0.3s cubic-bezier(0.2, 0.8, 0.2, 1) forwards;
}

/* Dropdown positioning for mobile */
@media (max-width: 768px) {
  .dropdown-content {
    position: absolute;
    right: 0;
    width: 180px;
    background-color: rgba(41, 37, 36, 0.95);
    box-shadow: 0 4px 12px rgba(245, 158, 11, 0.3);
    z-index: 50;
  }
}

/* Enhanced stats table responsiveness */
@media (max-width: 640px) {
  .stats-table th,
  .stats-table td {
    padding: 0.5rem 0.25rem;
    font-size: 0.75rem;
  }
  
  .stats-table th:first-child,
  .stats-table td:first-child {
    padding-left: 0.5rem;
  }
  
  .stats-table th:last-child,
  .stats-table td:last-child {
    padding-right: 0.5rem;
  }
}

/* Fix for overlapping elements in cards on mobile */
@media (max-width: 640px) {
  .card {
    padding: 0.75rem;
  }
  
  .feature-cards-container {
    gap: 0.5rem;
  }
  
  .feature-card {
    padding: 0.5rem;
  }
}

/* Ensure horizontal scrolling works properly on mobile */
.overflow-x-auto {
  -webkit-overflow-scrolling: touch;
  scrollbar-width: none; /* Firefox */
}

.overflow-x-auto::-webkit-scrollbar {
  display: none; /* Chrome, Safari, Edge */
}

/* ===== Solar Eclipse Interactive Elements ===== */
.solar-btn {
  @apply relative overflow-hidden rounded-lg px-4 py-2 
         bg-gradient-to-r from-solar-flare to-burning-warning 
         text-void-core font-medium 
         transition-all duration-300 transform hover:scale-105;
  box-shadow: 0 4px 10px rgba(245, 158, 11, 0.3);
}

.solar-btn:after {
  content: "";
  @apply absolute inset-0 opacity-0 transition-opacity duration-300;
  background: linear-gradient(45deg, rgba(255, 255, 255, 0.1), rgba(255, 255, 255, 0));
}

.solar-btn:hover:after {
  @apply opacity-100;
}

.solar-btn:focus {
  outline: none;
  box-shadow: 0 0 0 3px rgba(245, 158, 11, 0.4);
}

/* Tier List styling */
.tier-s {
  @apply bg-gradient-to-r from-solar-flare to-burning-warning text-void-core font-semibold;
}

.tier-a {
  @apply bg-gradient-to-r from-solar-flare/80 to-burning-warning/70 text-void-core font-medium;
}

.tier-b {
  @apply bg-gradient-to-r from-solar-flare/60 to-burning-warning/50 text-void-core;
}

.tier-c {
  @apply bg-gradient-to-r from-solar-flare/40 to-burning-warning/30 text-void-core;
}

/* Custom focus states */
input:focus, select:focus, textarea:focus {
  @apply outline-none ring-2 ring-solar-flare/50;
}

/* Solar Eclipse Transition Effects */
.solar-transition {
  @apply transition-all duration-300 ease-in-out;
}

.solar-page-transition {
  animation: fadeInPage 0.4s cubic-bezier(0.2, 0.8, 0.2, 1);
}

@keyframes fadeInPage {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

/* Pulse animation with solar accent */
.solar-pulse {
  @apply relative;
}

.solar-pulse:after {
  content: '';
  @apply absolute inset-0 rounded-full;
  box-shadow: 0 0 0 0 rgba(245, 158, 11, 0.7);
  animation: solarPulse 2s infinite;
}

@keyframes solarPulse {
  0% { box-shadow: 0 0 0 0 rgba(245, 158, 11, 0.7); }
  70% { box-shadow: 0 0 0 10px rgba(245, 158, 11, 0); }
  100% { box-shadow: 0 0 0 0 rgba(245, 158, 11, 0); }
}
EOL

# Types file
cat > src/types/index.ts << 'EOL'
// Base interface for statistics
export interface BaseStats {
  id: string; 
  name: string; 
  icon: string;
  count?: number; 
  winRate?: number; 
  playRate?: number; 
  avgPlacement?: number; 
  top4Rate?: number; 
  totalGames?: number;
  region?: string;
  stats?: {
    count?: number;
    avgPlacement?: number;
    winRate?: number;
    top4Rate?: number;
  };
}

// Game data interfaces
export interface TraitData {
  name: string; 
  description: string; 
  icon: string;
  tiers: Array<{ units: number; value: string; icon: string; }>;
}

export interface UnitData {
  name: string; 
  icon: string; 
  cost: number;
  traits: { origin: string | string[]; class: string | string[]; };
  ability: { name: string; description: string; type: string; mana_cost?: number[]; };
  stats: Record<string, number>;
}

export interface ItemData {
  name: string; 
  category: string; 
  icon: string; 
  description?: string;
}

// Item Combo interface
export interface ItemCombo {
  mainItem: ProcessedItem;
  items: ProcessedItem[];
  winRate: number;
  frequency?: number;
}

// API interfaces
export interface LeagueEntry { summonerId: string; leaguePoints: number; }
export interface League { entries: LeagueEntry[]; }
export interface Summoner { puuid: string; id: string; }
export interface Match { metadata: { match_id: string }; info: { participants: any[] }; }

export interface ProcessedMatch {
  id: string;
  region?: string;
  participants: {
    placement: number;
    units: { name: string; itemNames: string[]; }[];
    traits: { name: string; tier_current: number; num_units: number; }[];
  }[];
}

// Processed data interfaces
export interface ProcessedItem extends BaseStats { 
  category?: string;
  unitsWithItem?: UnitWithItem[];
  relatedComps?: Composition[];
  combos?: ItemCombo[];
}

export interface UnitWithItem {
  id: string;
  name: string;
  icon: string;
  cost: number;
  count: number;
  winRate: number;
  avgPlacement: number;
  relatedComps?: Composition[];
  stats?: {
    count?: number;
    avgPlacement?: number;
    winRate?: number;
    top4Rate?: number;
  };
}

export interface ProcessedUnit extends BaseStats {
  cost: number;
  items?: ProcessedItem[];
  bestItems?: ProcessedItem[];
  relatedComps?: Composition[];
  // Add the traits property to match what's being used in team-builder
  traits?: {
    origin?: string | string[];
    class?: string | string[];
  };
  starLevel?: number; // Star level for unit (1-4 stars)
}

export interface ProcessedTrait extends BaseStats {
  tier: number;
  numUnits: number; 
  tierIcon: string;
  relatedComps?: Composition[];
}

export interface Composition extends BaseStats {
  traits: ProcessedTrait[]; 
  units: ProcessedUnit[];
  placementData?: { placement: number; count: number; }[];
}

export interface ProcessedData { 
  compositions: Composition[]; 
  summary: {
    totalGames: number; 
    avgPlacement: number; 
    topComps: Composition[];
  }; 
  region?: string;
}

export interface TierList {
  S: BaseStats[]; 
  A: BaseStats[]; 
  B: BaseStats[]; 
  C: BaseStats[];
}

// Team builder interfaces
export interface BoardCell {
  unit?: ProcessedUnit;
  items?: ProcessedItem[];
}

export interface SavedComposition {
  id: string;
  name: string;
  board: Record<string, BoardCell>;
  date: string;
  traits?: {id: string, count: number}[];
}

// Feature card type
export interface FeatureCardProps {
  title: string;
  icon: React.ReactNode;
  description: string;
  linkTo: string;
}

// Enhanced Region type with status and subRegions information
export interface Region {
  id: string;
  name: string;
  status?: 'active' | 'degraded' | 'down' | 'error';
  lastError?: Date;
  retryAttempts?: number;
  subRegions?: string[]; // Added subRegions property
  isGroup?: boolean;     // Flag to identify if this is a group/continent
}

// Error handling types
export interface ApiError {
  type: 'timeout' | 'rate-limit' | 'server' | 'network' | 'unknown';
  message: string;
  statusCode?: number;
  region?: string;
  timestamp: Date;
}

export interface ErrorState {
  hasError: boolean;
  error?: ApiError | null;
  retryFn?: () => void;
}

export interface ProcessedDisplayTrait {
  id: string;
  name: string;
  icon: string;
  tierIcon?: string;
}

// Module declarations
declare namespace NodeJS { interface ProcessEnv { RIOT_API_KEY: string; } }
EOL

# Create unified path utilities
cat > src/utils/paths.ts << 'EOL'
import traitsJson from 'public/mapping/traits.json';

// Define constants for asset paths
export const ASSET_PATHS = {
  trait: '/assets/traits/',
  unit: '/assets/units/',
  item: '/assets/items/',
  default: '/assets/'
};

// Default icons for fallbacks
export const DEFAULT_ICONS = {
  trait: '/assets/app/default.png',
  unit: '/assets/app/default.png',
  item: '/assets/app/default.png'
};

// Type for traits object
type TraitsRecord = Record<string, {
  name: string;
  description?: string;
  icon: string;
  tiers?: Array<{ units: number; value: string; icon?: string }>;
}>;

// Get cost color - standardized color mapping for all components
export const getCostColor = (cost: number) => {
  const colors: Record<number, string> = {
    1: '#9aa4af', 
    2: '#2ecc71', 
    3: '#3498db',
    4: '#9b59b6', 
    5: '#f1c40f', 
    6: '#e74c3c'
  };
  return colors[cost] || colors[1];
};

// Core icon path function
export const getIconPath = (icon: string | undefined, type: string): string => {
  if (!icon) return DEFAULT_ICONS[type as keyof typeof DEFAULT_ICONS] || '';
  
  // If path already has a proper prefix, return it directly
  if (icon.startsWith('/')) return icon;
  
  // Normalize type (remove plural 's' if present)
  const normalizedType = type.endsWith('s') ? type.slice(0, -1) : type;
  
  // Get the correct base path by type
  const basePath = ASSET_PATHS[normalizedType as keyof typeof ASSET_PATHS] || ASSET_PATHS.default;
  
  return `${basePath}${icon}`;
};

// Ensure path has proper prefix
export const ensureIconPath = (path: string, type: string): string => {
  if (!path) return DEFAULT_ICONS[type as keyof typeof DEFAULT_ICONS];
  if (path.startsWith('/')) return path;
  
  const basePath = type === 'trait' || type === 'traits' ? '/assets/traits/' :
                   type === 'unit' || type === 'units' ? '/assets/units/' :
                   type === 'item' || type === 'items' ? '/assets/items/' : '/assets/';
  
  return `${basePath}${path}`;
};

// Get tier name from level
export const getTierName = (tier: number) => {
  if (tier === 1) return "(Bronze)";
  if (tier === 2) return "(Silver)";
  if (tier === 3) return "(Gold)";
  if (tier === 4) return "(Diamond)";
  return "";
};

// Get trait tier icon - completely rewritten for accuracy
export const getTierIcon = (traitId: string, numUnits: number): string => {
  // Early return for invalid inputs
  if (!traitId || numUnits === undefined) return DEFAULT_ICONS.trait;
  
  // Get trait data from traits.json
  const traits: TraitsRecord = { ...traitsJson.origins, ...traitsJson.classes };
  const trait = traits[traitId];
  
  // If trait not found, return default icon
  if (!trait) return DEFAULT_ICONS.trait;
  
  // Get trait tiers
  const traitTiers = trait.tiers || [];
  if (!traitTiers.length) return getIconPath(trait.icon, 'trait');
  
  // Find the appropriate tier level based on unit count
  let tierLevel = -1;
  for (let i = 0; i < traitTiers.length; i++) {
    if (numUnits >= traitTiers[i].units) {
      tierLevel = i;
    } else {
      break;
    }
  }
  
  // If no tier matches, return the default trait icon
  if (tierLevel === -1) return getIconPath(trait.icon, 'trait');
  
  // Get the tier icon if specified in the tier data
  if (traitTiers[tierLevel].icon) {
    // Add empty string fallback to ensure we always pass a string
    return getIconPath(traitTiers[tierLevel].icon || '', 'trait');
  }
  
  // If no tier-specific icon, construct from trait ID instead of name
  const tierNames = ['bronze', 'silver', 'gold', 'diamond'];
  if (tierLevel >= tierNames.length) {
    return getIconPath(trait.icon, 'trait');
  }
  
  // CHANGE THIS LINE: Use traitId directly instead of formatting trait.name
  // Return constructed tier icon path - with fallback
  return `${ASSET_PATHS.trait}${traitId}_${tierNames[tierLevel]}.png`;
};

// Primary entity icon resolver - main function to use everywhere
export const getEntityIcon = (entity: any, type: string): string => {
  if (!entity) return DEFAULT_ICONS[type as keyof typeof DEFAULT_ICONS] || '';
  
  // Normalize type
  const normalizedType = type.endsWith('s') ? type.slice(0, -1) : type;
  
  // Special case for trait tier icons
  if (normalizedType === 'trait') {
    // First check if tierIcon is directly provided
    if (entity.tierIcon) return entity.tierIcon;
    
    // For traits with tier information
    if (entity.tier && entity.tier > 0 && entity.numUnits && entity.numUnits > 0 && entity.id) {
      const tierIcon = getTierIcon(entity.id, entity.numUnits);
      if (tierIcon) return tierIcon;
    }
  }
  
  // Default to regular icon path
  return ensureIconPath(entity.icon, normalizedType);
};

// Utility to safely get all trait data from unit - CRITICAL FIX for unit traits
export const getUnitTraits = (unit: any): { id: string, type: 'origin' | 'class' }[] => {
  if (!unit || !unit.traits) return [];
  
  const result: { id: string, type: 'origin' | 'class' }[] = [];
  
  // Extract origin traits
  if (unit.traits.origin) {
    if (Array.isArray(unit.traits.origin)) {
      unit.traits.origin.filter(Boolean).forEach((traitId: string) => {
        result.push({ id: traitId, type: 'origin' });
      });
    } else if (unit.traits.origin) {
      result.push({ id: unit.traits.origin, type: 'origin' });
    }
  }
  
  // Extract class traits
  if (unit.traits.class) {
    if (Array.isArray(unit.traits.class)) {
      unit.traits.class.filter(Boolean).forEach((traitId: string) => {
        result.push({ id: traitId, type: 'class' });
      });
    } else if (unit.traits.class) {
      result.push({ id: unit.traits.class, type: 'class' });
    }
  }
  
  return result;
};

// Get full trait info from id
export const getTraitInfo = (traitId: string): { 
  id: string;
  name: string; 
  icon: string; 
  isOrigin: boolean;
  tiers?: { units: number; value: string; icon?: string }[];
} | null => {
  if (!traitId) return null;
  
  const origins = traitsJson.origins as Record<string, any>;
  const classes = traitsJson.classes as Record<string, any>;
  
  if (origins[traitId]) {
    return { 
      id: traitId,
      ...origins[traitId], 
      isOrigin: true 
    };
  }
  
  if (classes[traitId]) {
    return { 
      id: traitId,
      ...classes[traitId], 
      isOrigin: false 
    };
  }
  
  return null;
};
EOL

cat > src/utils/dataProcessing.ts << 'EOL'
import _ from 'lodash';
import traitsJson from 'public/mapping/traits.json';
import unitsJson from 'public/mapping/units.json';
import itemsJson from 'public/mapping/items.json';
import { getIconPath, getTierIcon, ensureIconPath } from '@/utils/paths';
import { ProcessedData, ProcessedMatch, Composition, UnitWithItem, ProcessedItem, ProcessedUnit } from '@/types';
import { generateAllItemCombos } from './itemCombos';

// Extended types for internal use to avoid type errors
interface ExtendedComposition extends Composition {
  count?: number; // Make count optional to fix the type error
  placement: number; // Add placement property needed for statistics calculations
  region?: string; // Add region as it's used in groupBy
}

// Extended ProcessedData interface that includes the items property
interface EnhancedProcessedData extends ProcessedData {
  items: ProcessedItem[];
}

// Cached data for better performance
const traits: Record<string, any> = { ...traitsJson.origins, ...traitsJson.classes };
const units: Record<string, any> = unitsJson.units;
const items: Record<string, any> = itemsJson.items;

// Define allowed entity types
type EntityType = 'trait' | 'unit' | 'item';

// Get display name consistently
export const getDisplayName = (id: string, type: EntityType): string => {
  if (type === 'trait') {
    return (traits as Record<string, { name: string }>)[id]?.name || id;
  } else if (type === 'unit') {
    return (units as Record<string, { name: string }>)[id]?.name || id;
  } else if (type === 'item') {
    return (items as Record<string, { name: string }>)[id]?.name || id;
  }
  return id;
};

// Extract main traits from comp name
export const parseCompTraits = (compName: string | undefined, allTraits: any[]): any[] => {
  const mainTraits: any[] = [];
  if (!compName) return allTraits.slice(0, 3);
  
  compName.split(' & ').forEach(part => {
    const match = part.match(/^(\d+)\s+(.+)$/);
    if (match) {
      const [_, count, traitName] = match;
      const matchingTrait = allTraits.find(t => t.name === traitName.trim());
      if (matchingTrait) {
        mainTraits.push(matchingTrait);
      }
    }
  });
  
  return mainTraits.length > 0 ? mainTraits.slice(0, 3) : allTraits.slice(0, 3);
};

// Calculate entity statistics across compositions with improved caps
export const calculateEntityStats = (entities: any[], compositions: ExtendedComposition[]) => {
  // Create an accumulator map for better performance
  const statsMap: Record<string, any> = {};
  
  compositions.forEach(comp => {
    entities.forEach(entity => {
      if (!entity?.id) return;
      
      if (!statsMap[entity.id]) {
        statsMap[entity.id] = {
          ...entity,
          count: 0,
          totalGames: 0,
          winRateSum: 0,
          top4RateSum: 0,
          placementSum: 0
        };
      }
      
      statsMap[entity.id].count++;
      statsMap[entity.id].totalGames += comp.count || 0;
      statsMap[entity.id].placementSum += (comp.avgPlacement || 0) * (comp.count || 1);
      statsMap[entity.id].winRateSum += ((comp.winRate || 0) / 100) * (comp.count || 1);
      statsMap[entity.id].top4RateSum += ((comp.top4Rate || 0) / 100) * (comp.count || 1);
    });
  });
  
  // Convert to array and calculate final stats with caps for reasonable values
  return Object.values(statsMap).map(entity => {
    const totalGames = entity.totalGames || 1;
    const calculatedWinRate = (entity.winRateSum / totalGames) * 100;
    const calculatedTop4Rate = (entity.top4RateSum / totalGames) * 100;
    
    // Cap values to reasonable ranges
    const avgPlacement = Math.min(Math.max(entity.placementSum / totalGames, 1), 8);
    const winRate = Math.min(Math.max(calculatedWinRate, 0), 100);
    const top4Rate = Math.min(Math.max(calculatedTop4Rate, 0), 100);
    
    return {
      ...entity,
      avgPlacement,
      winRate,
      top4Rate,
      playRate: (entity.count / compositions.length) * 100,
      stats: {
        count: entity.count,
        avgPlacement,
        winRate,
        top4Rate
      }
    };
  });
};

// IMPROVED: Check if a composition is viable under realistic TFT gameplay rules
export const isRealisticComp = (comp: any): boolean => {
  if (!comp?.units || !Array.isArray(comp.units)) return false;
  
  // Rule 1: Check for too many tier 5 (legendary) units
  const legendaryCount = comp.units.filter((u: any) => u.cost === 5).length;
  if (legendaryCount > 3) return false; // More than 3 legendaries is unrealistic
  
  // Rule 2: Check for unrealistic trait combinations
  // Diamond tier traits (lvl 4) are very difficult to achieve
  if (comp.traits) {
    const diamondTraits = comp.traits.filter((t: any) => t.tier === 4).length;
    if (diamondTraits > 1) return false; // More than 1 diamond tier trait is unrealistic
    
    // Check if there are too many gold traits (tier 3)
    const goldTraits = comp.traits.filter((t: any) => t.tier === 3).length;
    if (goldTraits > 3) return false; // More than 3 gold traits is unrealistic
  }
  
  // Rule 3: Check unit count against game rules
  const totalUnits = comp.units.length;
  if (totalUnits < 5 || totalUnits > 10) return false; // Unrealistic unit count
  
  // Rule 4: Check for a balanced economy (can't have too many high-cost units early)
  // Calculate the total cost of the units
  const totalCost = comp.units.reduce((sum: number, u: any) => sum + (u.cost || 0), 0);
  const avgCost = totalCost / totalUnits;
  
  // If average unit cost is too high, the comp is likely unrealistic
  if (avgCost > 4) return false;
  
  // Rule 5: Check if this is a 'perfect items' comp (every unit has 3 perfect items)
  // This is unrealistic in most games
  const unitsWithFullItems = comp.units.filter((u: any) => 
    u.items && u.items.length === 3
  ).length;
  
  // If more than 70% of units have perfect items, it's suspicious
  if (unitsWithFullItems > totalUnits * 0.7) return false;
  
  return true;
};

// Process match data with optimizations - Use ProcessedData as the return type
export const processMatchData = (matches: ProcessedMatch[], region?: string): ProcessedData => {
  if (!matches?.length) {
    return { 
      compositions: [], 
      summary: { totalGames: 0, avgPlacement: 0, topComps: [] },
      region
    };
  }

  // Filter by region if specified
  const filteredMatches = region && region !== 'all' 
    ? matches.filter(m => m.region?.toUpperCase() === region.toUpperCase())
    : matches;

  if (!filteredMatches.length) {
    return { 
      compositions: [], 
      summary: { totalGames: 0, avgPlacement: 0, topComps: [] },
      region 
    };
  }

  // Extract compositions with better map usage - FIXED with required properties
  const compositions = filteredMatches.flatMap(match =>
    match.participants.map(p => {
      // Generate a composition name based on significant traits
      const significantTraits = p.traits
        .filter(t => t.tier_current > 1)
        .sort((a, b) => b.num_units - a.num_units);
      
      // Create a name from the top traits
      const name = significantTraits.length > 0
        ? significantTraits
            .slice(0, 2)
            .map(t => `${t.num_units} ${getDisplayName(t.name, 'trait')}`)
            .join(' & ')
        : 'Mixed Composition';
      
      // Get an icon from the most significant trait
      const primaryTrait = significantTraits[0];
      const icon = primaryTrait
        ? getIconPath((traits)[primaryTrait.name]?.icon || '/assets/app/default.png', 'trait')
        : '/assets/app/default.png';
      
      // Generate a unique ID
      const id = `${match.id}-${p.placement}`;
      
      return {
        id,
        name,
        icon,
        placement: p.placement,
        region: match.region || 'unknown',
        traits: p.traits
          .filter(t => t.tier_current >= 1)
          .map(t => ({
            id: t.name,
            name: getDisplayName(t.name, 'trait'),
            icon: getIconPath((traits)[t.name]?.icon || '/assets/app/default.png', 'trait'),
            tier: t.tier_current,
            numUnits: t.num_units,
            tierIcon: getTierIcon(t.name, t.num_units)
          }))
          .sort((a, b) => b.tier !== a.tier ? b.tier - a.tier : a.name.localeCompare(b.name)),
        units: p.units.map(u => {
          // Get the unit data from mapping
          const unitData = (units)[u.name];
          
          return {
            id: u.name,
            name: getDisplayName(u.name, 'unit'),
            icon: getIconPath(unitData?.icon || '/assets/app/default.png', 'unit'),
            cost: unitData?.cost || 0,
            // Include traits data directly from unit mapping - CRITICAL FIX
            traits: unitData?.traits || {},
            items: u.itemNames.map(item => ({
              id: item,
              name: getDisplayName(item, 'item'),
              icon: getIconPath((items)[item]?.icon || '/assets/app/default.png', 'item'),
              category: (items)[item]?.category
            }))
          };
        })
      };
    })
  ) as ExtendedComposition[];  // Use our extended type with explicit casting

  // Process best items per unit - IMPROVED CALCULATION
  const itemsByUnit: Record<string, Record<string, {
    item: ProcessedItem, 
    count: number, 
    winRateSum: number, 
    top4RateSum: number,
    placementSum: number,
    totalGames: number
  }>> = {};
  
  compositions.forEach((comp: ExtendedComposition) => {
    comp.units.forEach(unit => {
      if (!itemsByUnit[unit.id]) itemsByUnit[unit.id] = {};
      
      (unit.items || []).forEach(item => {
        if (!itemsByUnit[unit.id][item.id]) {
          itemsByUnit[unit.id][item.id] = { 
            item, 
            count: 0,
            winRateSum: 0,
            top4RateSum: 0,
            placementSum: 0,
            totalGames: 0
          };
        }
        itemsByUnit[unit.id][item.id].count++;
        itemsByUnit[unit.id][item.id].totalGames += comp.count || 1;
        itemsByUnit[unit.id][item.id].placementSum += (comp.avgPlacement || 0) * (comp.count || 1);
        itemsByUnit[unit.id][item.id].winRateSum += ((comp.winRate || 0) / 100) * (comp.count || 1);
        itemsByUnit[unit.id][item.id].top4RateSum += ((comp.top4Rate || 0) / 100) * (comp.count || 1);
      });
    });
  });
  
  // Add best items to units with properly capped stats
  Object.entries(itemsByUnit).forEach(([unitId, unitItems]) => {
    const bestItems = Object.values(unitItems)
      .map(entry => {
        const totalGames = entry.totalGames || 1;
        const winRate = Math.min((entry.winRateSum / totalGames) * 100, 100);
        const top4Rate = Math.min((entry.top4RateSum / totalGames) * 100, 100);
        const avgPlacement = Math.min(Math.max(entry.placementSum / totalGames, 1), 8);
        
        return {
          ...entry.item,
          stats: {
            count: entry.count,
            winRate,
            top4Rate,
            avgPlacement
          }
        };
      })
      .sort((a, b) => (b.stats?.winRate || 0) - (a.stats?.winRate || 0))
      .slice(0, 3);
      
    compositions.forEach(comp => {
      comp.units.forEach(unit => {
        if (unit.id === unitId) (unit as ProcessedUnit).bestItems = bestItems;
      });
    });
  });

  // MAJOR FIX: Significantly improved unit-item relationship calculation
  const unitsWithItems: Record<string, Record<string, {
    unit: ProcessedUnit,
    count: number,
    winRateSum: number,
    top4RateSum: number,
    placementSum: number,
    totalGames: number,
    relatedComps: Set<string>
  }>> = {};
  
  // First pass - gather data with proper structure
  compositions.forEach((comp: ExtendedComposition) => {
    comp.units.forEach(unit => {
      (unit.items || []).forEach(item => {
        if (!item.id) return;
        
        if (!unitsWithItems[item.id]) {
          unitsWithItems[item.id] = {};
        }
        
        if (!unitsWithItems[item.id][unit.id]) {
          unitsWithItems[item.id][unit.id] = {
            unit: { 
              id: unit.id,
              name: unit.name,
              icon: unit.icon,
              cost: unit.cost, 
              count: 0,
              winRate: 0,
              avgPlacement: 0,
              stats: {
                count: 0,
                winRate: 0,
                avgPlacement: 0,
                top4Rate: 0
              }
            },
            count: 0,
            winRateSum: 0,
            top4RateSum: 0,
            placementSum: 0,
            totalGames: 0,
            relatedComps: new Set<string>()
          };
        }
        
        // Update stats with proper accumulation
        unitsWithItems[item.id][unit.id].count++;
        unitsWithItems[item.id][unit.id].totalGames += comp.count || 1;
        unitsWithItems[item.id][unit.id].placementSum += (comp.avgPlacement || 0) * (comp.count || 1);
        unitsWithItems[item.id][unit.id].winRateSum += ((comp.winRate || 0) / 100) * (comp.count || 1);
        unitsWithItems[item.id][unit.id].top4RateSum += ((comp.top4Rate || 0) / 100) * (comp.count || 1);
        unitsWithItems[item.id][unit.id].relatedComps.add(comp.id);
      });
    });
  });

  // IMPROVED: Composition filtering - apply realistic TFT gameplay rules
  const filteredCompositions = compositions.filter(isRealisticComp);

  // Improved composition grouping
  const compsByKey = _.groupBy(filteredCompositions, comp => {
    // Only consider traits with tier > 1 for composition name
    const significantTraits = comp.traits
      .filter(t => t.tier > 1 && t.numUnits > 1)
      .sort((a, b) => b.numUnits - a.numUnits || a.name.localeCompare(b.name))
      .slice(0, 2);
      
    const key = significantTraits
      .map(t => `${t.numUnits} ${t.name}`)
      .join(' & ');
      
    return key || 'Other';
  });
  
  // Create composition stats
  const stats: Composition[] = Object.entries(compsByKey)
    .filter(([name]) => name !== 'Other')
    .map(([name, comps]) => {
      // Get traits for icon determination - FIXED ICON SELECTION
      // Filter traits to only include those with tier > 1
      const traits = _.uniqBy(comps.flatMap(c => c.traits), 'id')
        .sort((a, b) => b.tier - a.tier);
      
      // Find significant traits (tier > 1) for the icon
      const significantTraits = traits.filter(t => t.tier > 1);
      
      // Calculate placement data for distribution charts
      const placementData = _.chain(comps)
        .countBy('placement')
        .map((count, place) => ({ placement: Number(place), count }))
        .sortBy('placement')
        .value();
      
      const avgPlacement = _.meanBy(comps, 'placement');
      const winRate = Math.min((comps.filter(c => c.placement === 1).length / comps.length) * 100, 100);
      const top4Rate = Math.min((comps.filter(c => c.placement <= 4).length / comps.length) * 100, 100);
      
      return {
        id: name.replace(/\s+/g, '-').toLowerCase(),
        name,
        // Set icon to first significant trait with tier > 1, fallback to first trait if none
        icon: significantTraits.length > 0 
          ? (significantTraits[0].tierIcon || significantTraits[0].icon) 
          : (traits.length > 0 ? (traits[0].tierIcon || traits[0].icon) : ''),
        traits,
        units: _.chain(comps)
          .flatMap('units')
          .groupBy('id')
          .map((units) => ({
            ...units[0],
            count: units.length
          }))
          .orderBy(['count', 'cost'], ['desc', 'desc'])
          .value(),
        count: comps.length,
        avgPlacement,
        winRate,
        top4Rate,
        playRate: (comps.length / compositions.length) * 100,
        placementData,
        // Store region data
        regions: _.countBy(comps, 'region'),
        stats: {
          count: comps.length,
          avgPlacement,
          winRate,
          top4Rate
        }
      };
    })
    .filter(comp => comp.count >= 2)
    .sort((a, b) => b.count - a.count);

  // CRITICAL FIX: Calculate proper unitsWithItem statistics
  const processedItems: Record<string, ProcessedItem> = {};

  Object.entries(unitsWithItems).forEach(([itemId, unitEntries]) => {
    // Process units with this item and ensure proper stats structure
    const processedUnits = Object.entries(unitEntries).map(([unitId, entry]) => {
      // Calculate averages with proper weighting
      const totalGames = entry.totalGames || 1;
      const winRate = Math.min((entry.winRateSum / totalGames) * 100, 100);
      const top4Rate = Math.min((entry.top4RateSum / totalGames) * 100, 100);
      const avgPlacement = Math.min(Math.max(entry.placementSum / totalGames, 1), 8);
      
      // Create a clean unit with proper nested stats structure
      const processedUnit: UnitWithItem = {
        id: entry.unit.id,
        name: entry.unit.name,
        icon: entry.unit.icon,
        cost: entry.unit.cost,
        count: entry.count,
        winRate: winRate,
        avgPlacement: avgPlacement,
        stats: {
          count: entry.count,
          winRate: winRate,
          avgPlacement: avgPlacement,
          top4Rate: top4Rate
        },
        relatedComps: Array.from(entry.relatedComps)
          .map(compId => stats.find(s => s.id === compId))
          .filter((comp): comp is Composition => comp !== undefined)
      };
      
      return processedUnit;
    })
    .sort((a, b) => (b.stats?.winRate || 0) - (a.stats?.winRate || 0));
    
    // Create or update the processed item with unitsWithItem data
    if (!processedItems[itemId]) {
      // Find an item instance to copy basic info from
      let itemBase: ProcessedItem | undefined;
      for (const comp of stats) {
        for (const unit of comp.units) {
          const foundItem = (unit.items || []).find(i => i.id === itemId);
          if (foundItem) {
            itemBase = foundItem as ProcessedItem;
            break;
          }
        }
        if (itemBase) break;
      }
      
      if (itemBase) {
        // Create a new item with statistics
        processedItems[itemId] = {
          ...itemBase,
          count: Object.values(unitEntries).reduce((sum, entry) => sum + entry.count, 0),
          winRate: Object.values(unitEntries).reduce((sum, entry) => sum + entry.winRateSum, 0) / 
                  Object.values(unitEntries).reduce((sum, entry) => sum + (entry.totalGames || 1), 0) * 100,
          avgPlacement: Object.values(unitEntries).reduce((sum, entry) => sum + entry.placementSum, 0) / 
                        Object.values(unitEntries).reduce((sum, entry) => sum + (entry.totalGames || 1), 0),
          unitsWithItem: processedUnits,
          relatedComps: processedUnits.flatMap(unit => unit.relatedComps || [])
            .filter((v, i, a) => a.findIndex(t => t.id === v.id) === i) // unique comps
        };
      }
    } else {
      // Update existing item
      processedItems[itemId].unitsWithItem = processedUnits;
    }
    
    // Add unitsWithItem to all instances of this item in comps
    stats.forEach(comp => {
      comp.units.forEach(unit => {
        (unit.items || []).forEach(item => {
          if (item.id === itemId) {
            (item as ProcessedItem).unitsWithItem = processedUnits;
          }
        });
      });
    });
  });

  // Extract all items from compositions for generating item combos
  const allItems = Object.values(processedItems);
  
  // FIX: Generate item combos data and add it to items
  const itemCombos = generateAllItemCombos(allItems);
  
  // Attach combos to processed items
  Object.entries(itemCombos).forEach(([itemId, combos]) => {
    if (processedItems[itemId]) {
      processedItems[itemId].combos = combos;
    }
    
    // Also attach combos to items in compositions
    stats.forEach(comp => {
      comp.units.forEach(unit => {
        (unit.items || []).forEach(item => {
          if (item.id === itemId) {
            (item as ProcessedItem).combos = combos;
          }
        });
      });
    });
  });

  // Fix: Create an intermediate enhanced data object
  const enhancedData: EnhancedProcessedData = {
    compositions: stats,
    summary: {
      totalGames: filteredMatches.length,
      avgPlacement: _.meanBy(compositions, 'placement'),
      topComps: stats.slice(0, 5)
    },
    items: Object.values(processedItems),
    region
  };

  // Store items data in a global or module variable for access by other methods
  // This is a workaround since we can't include them in the returned data
  (global as any).__tftItemsData = Object.values(processedItems);

  // Return only the fields that are part of the ProcessedData interface
  return {
    compositions: enhancedData.compositions,
    summary: enhancedData.summary,
    region: enhancedData.region
  };
};

// NEW METHOD: Add a helper function to access the processed items
export const getProcessedItems = (): ProcessedItem[] => {
  return (global as any).__tftItemsData || [];
};
EOL

# Fix useTftData.ts
cat > src/utils/useTftData.ts << 'EOL'
import { useQuery } from '@tanstack/react-query';
import { useState, useMemo, useEffect, useCallback } from 'react';
import axios from 'axios';
import traitsJson from 'public/mapping/traits.json';
import { ensureIconPath, getEntityIcon } from '@/utils/paths';
import { 
  ProcessedData, 
  TierList,
  Region,
  ErrorState,
  BaseStats,
  Composition,
  ProcessedUnit,
  ProcessedItem,
  ProcessedTrait,
  ItemCombo
} from '@/types';
import { generateAllItemCombos } from '@/utils/itemCombos';
import { getProcessedItems } from '@/utils/dataProcessing';

// Interface for the enhanced ProcessedData that includes items
// This is for internal use only since the actual ProcessedData doesn't have items
interface EnhancedProcessedData extends ProcessedData {
  items?: ProcessedItem[];
}

// Updated region structure with proper grouping and isGroup flag
export const REGIONS: Region[] = [
  { id: 'all', name: 'All Regions' },
  { id: 'AMER', name: 'America', subRegions: ['NA', 'BR', 'LAN', 'LAS'], isGroup: true },
  { id: 'EUROPE', name: 'Europe', subRegions: ['EUW', 'EUNE'], isGroup: true },
  { id: 'APAC', name: 'Asia & Pacific', subRegions: ['JP', 'KR'], isGroup: true },
  { id: 'MEA', name: 'Middle East & Africa', subRegions: ['RU', 'TR'], isGroup: true },
  { id: 'NA', name: 'North America' },
  { id: 'BR', name: 'Brazil' },
  { id: 'LAN', name: 'Latin America North' },
  { id: 'LAS', name: 'Latin America South' },
  { id: 'EUW', name: 'Europe West' },
  { id: 'EUNE', name: 'Europe Nordic & East' },
  { id: 'KR', name: 'Korea' },
  { id: 'JP', name: 'Japan' },
  { id: 'RU', name: 'Russia' },
  { id: 'TR', name: 'Turkey' }
];

export enum HighlightType {
  TopWinner = 'top_winner',
  MostConsistent = 'most_consistent',
  MostPlayed = 'most_played',
  FlexiblePick = 'flexible_pick',
  PocketPick = 'pocket_pick'
}

export enum EntityType {
  Unit = 'unit',
  Trait = 'trait',
  Item = 'item',
  Comp = 'comp'
}

export interface HighlightEntity {
  entityType: EntityType;
  entity: any;
  title: string;
  value: string;
  detail: string;
  image: string;
  link: string;
  category?: string;
  variant?: string;
}

export interface HighlightGroup {
  type: HighlightType;
  title: string;
  unitVariants: HighlightEntity[];
  traitVariants: HighlightEntity[];
  itemVariants: HighlightEntity[];
  compVariants: HighlightEntity[];
  getPreferredVariant(entityType: string): HighlightEntity | null;
}

// Helper function to find if a region is a group/continent
export function isRegionGroup(regionId: string): boolean {
  const region = REGIONS.find(r => r.id === regionId);
  return region?.isGroup || false;
}

// Helper to get subregions for a region ID
export function getSubRegions(regionId: string): string[] {
  const region = REGIONS.find(r => r.id === regionId);
  return region?.subRegions || [];
}

export function useTftData() {
  const [currentRegion, setCurrentRegion] = useState(() => {
    return typeof window !== 'undefined' ? localStorage.getItem('tft-region') || 'all' : 'all';
  });
  
  const [matchCount, setMatchCount] = useState(0);
  const [isChangingRegion, setIsChangingRegion] = useState(false);
  const [errorState, setErrorState] = useState<ErrorState>({ hasError: false });

  // Helper to merge data from multiple regions
  const mergeRegionData = async (regions: string[]): Promise<ProcessedData | null> => {
    try {
      // Fetch data for each subregion
      const regionDataPromises = regions.map(region => 
        axios.get<ProcessedData>(`/api/tft/compositions?region=${region}`)
      );
      
      const responses = await Promise.all(regionDataPromises);
      const validResponses = responses.filter(r => r.data && r.data.compositions);
      
      if (validResponses.length === 0) {
        return null;
      }
      
      // Start with first region's data as base
      const mergedData: EnhancedProcessedData = JSON.parse(JSON.stringify(validResponses[0].data));
      
      // Set total match count for display
      let totalMatches = mergedData.summary?.totalGames || 0;
      
      // We'll need to collect items from all regions
      const mergedItems: Record<string, ProcessedItem> = {};
      
      // Add the initial items if they exist
      const firstRegionItems = getProcessedItems();
      firstRegionItems.forEach(item => {
        if (item.id) {
          mergedItems[item.id] = { ...item };
        }
      });
      
      // Add compositions from other regions
      for (let i = 1; i < validResponses.length; i++) {
        const regionData = validResponses[i].data as EnhancedProcessedData;
        
        // Track total match count
        totalMatches += regionData.summary?.totalGames || 0;
        
        // Get items for this region
        // Attempt to use the getProcessedItems helper - should extract from the API response via global
        let regionItems: ProcessedItem[] = [];
        try {
          // Request the region's items data
          const itemsResponse = await axios.get<ProcessedItem[]>(`/api/tft/items?region=${regionData.region}`);
          if (itemsResponse.data && Array.isArray(itemsResponse.data)) {
            regionItems = itemsResponse.data;
          }
        } catch (e) {
          console.warn(`Failed to fetch items for region ${regionData.region}`, e);
          // Fallback - try to extract items from compositions
          regionItems = extractItemsFromCompositions(regionData.compositions);
        }
        
        // Merge items data
        regionItems.forEach(item => {
          if (!item.id) return;
          
          if (mergedItems[item.id]) {
            // Update existing item
            const existingItem = mergedItems[item.id];
            
            // Merge unitsWithItem data
            if (item.unitsWithItem && existingItem.unitsWithItem) {
              item.unitsWithItem.forEach(unit => {
                const existingUnit = existingItem.unitsWithItem?.find(u => u.id === unit.id);
                if (existingUnit) {
                  // Update stats
                  existingUnit.count = (existingUnit.count || 0) + (unit.count || 0);
                  existingUnit.winRate = weightedAverage(
                    [existingUnit.winRate || 0, unit.winRate || 0],
                    [existingUnit.count || 0, unit.count || 0]
                  );
                  existingUnit.avgPlacement = weightedAverage(
                    [existingUnit.avgPlacement || 0, unit.avgPlacement || 0],
                    [existingUnit.count || 0, unit.count || 0]
                  );
                  
                  // Merge related comps
                  if (unit.relatedComps) {
                    existingUnit.relatedComps = [
                      ...(existingUnit.relatedComps || []),
                      ...(unit.relatedComps || [])
                    ];
                  }
                } else if (existingItem.unitsWithItem) {
                  existingItem.unitsWithItem.push(unit);
                }
              });
            } else if (item.unitsWithItem && !existingItem.unitsWithItem) {
              existingItem.unitsWithItem = item.unitsWithItem;
            }
            
            // Merge combos data if available
            if (item.combos && existingItem.combos) {
              // Keep the highest winrate combos
              const allCombos = [...existingItem.combos, ...item.combos];
              existingItem.combos = allCombos
                .sort((a, b) => b.winRate - a.winRate)
                .slice(0, 5);
            } else if (item.combos && !existingItem.combos) {
              existingItem.combos = item.combos;
            }
          } else {
            // Add new item
            mergedItems[item.id] = item;
          }
        });
        
        // For each composition in the additional region
        regionData.compositions?.forEach(comp => {
          // Check if this composition already exists in merged data
          const existingComp = mergedData.compositions.find(c => c.id === comp.id);
          
          if (existingComp) {
            // Update existing composition with combined stats
            const totalGames = (existingComp.count || 0) + (comp.count || 0);
            
            // Weight the stats by count
            existingComp.avgPlacement = weightedAverage(
              [existingComp.avgPlacement || 0, comp.avgPlacement || 0],
              [existingComp.count || 0, comp.count || 0]
            );
            
            existingComp.winRate = weightedAverage(
              [existingComp.winRate || 0, comp.winRate || 0],
              [existingComp.count || 0, comp.count || 0]
            );
            
            existingComp.top4Rate = weightedAverage(
              [existingComp.top4Rate || 0, comp.top4Rate || 0],
              [existingComp.count || 0, comp.count || 0]
            );
            
            // Update count
            existingComp.count = totalGames;
          } else {
            // Add new composition to merged data
            mergedData.compositions.push(comp);
          }
        });
      }
      
      // Update summary data
      if (mergedData.summary) {
        mergedData.summary.totalGames = totalMatches;
        
        // Recalculate average placement
        const totalPlacement = validResponses.reduce((sum, r) => 
          sum + (r.data.summary?.avgPlacement || 0) * (r.data.summary?.totalGames || 0), 0);
        
        mergedData.summary.avgPlacement = totalMatches > 0 ? 
          totalPlacement / totalMatches : 0;
        
        // Resort top comps by win rate
        mergedData.compositions.sort((a, b) => (b.winRate || 0) - (a.winRate || 0));
        mergedData.summary.topComps = mergedData.compositions.slice(0, 10);
      }
      
      // FIX: Ensure item combos are generated for merged data
      const allItemsArray = Object.values(mergedItems);
      const itemCombos = generateAllItemCombos(allItemsArray);
      
      // Attach combos to items
      allItemsArray.forEach(item => {
        if (item.id && itemCombos[item.id]) {
          item.combos = itemCombos[item.id];
        }
      });
      
      // Store the items globally for access via getProcessedItems
      (global as any).__tftItemsData = allItemsArray;
      
      return mergedData;
    } catch (error) {
      console.error('Error merging region data:', error);
      return null;
    }
  };
  
  // Helper function for extracting items from compositions
  const extractItemsFromCompositions = (compositions: Composition[]): ProcessedItem[] => {
    const extractedItems: Record<string, ProcessedItem> = {};
    
    // Extract all items from all units in all compositions
    compositions.forEach(comp => {
      comp.units.forEach(unit => {
        (unit.items || []).forEach(item => {
          if (!item || !item.id) return;
          
          // Initialize item if not exists
          if (!extractedItems[item.id]) {
            extractedItems[item.id] = {
              ...item,
              unitsWithItem: [], // Initialize as empty array
              relatedComps: [],  // Initialize as empty array
              count: 0,
              winRate: 0,
              avgPlacement: 0,
              stats: {
                count: 0,
                winRate: 0,
                avgPlacement: 0,
                top4Rate: 0
              }
            };
          }
          
          // These checks are no longer needed since we initialize properly above
          // But keeping them for extra safety
          // Keep these checks as an extra safety measure
          if (!extractedItems[item.id].unitsWithItem) {
            extractedItems[item.id].unitsWithItem = [];
          }
          
          if (!extractedItems[item.id].relatedComps) {
            extractedItems[item.id].relatedComps = [];
          }
          
          // Add unit to unitsWithItem if not already there
          const existingUnit = extractedItems[item.id].unitsWithItem?.find(u => u.id === unit.id);
          if (!existingUnit) {
            const unitWithItemData = {
              id: unit.id,
              name: unit.name,
              icon: unit.icon,
              cost: unit.cost,
              count: 1,
              winRate: comp.winRate || 0,
              avgPlacement: comp.avgPlacement || 0,
              stats: {
                count: 1,
                winRate: comp.winRate || 0,
                avgPlacement: comp.avgPlacement || 0,
                top4Rate: comp.top4Rate || 0
              },
              relatedComps: [comp]
            };
            
            // Store reference to the item to make TypeScript happy
            const currentItem = extractedItems[item.id];
            if (currentItem && currentItem.unitsWithItem) {
              currentItem.unitsWithItem.push(unitWithItemData);
            }
          } else if (existingUnit) {
            // Update existing unit
            existingUnit.count = (existingUnit.count || 0) + 1;
            if (!existingUnit.relatedComps) {
              existingUnit.relatedComps = [];
            }
            if (existingUnit.relatedComps && !existingUnit.relatedComps.some(c => c.id === comp.id)) {
              existingUnit.relatedComps.push(comp);
            }
          }
          
          // Add comp to relatedComps if not already there
          const currentItem = extractedItems[item.id];
          if (currentItem && currentItem.relatedComps) {
            if (!currentItem.relatedComps.some(c => c.id === comp.id)) {
              currentItem.relatedComps.push(comp);
            }
          }
          
          // Update item stats - FIXING THE TYPE ERROR HERE
          if (currentItem) {
            currentItem.count = (currentItem.count || 0) + 1;
          }
        });
      });
    });
    
    // Calculate item stats
    Object.values(extractedItems).forEach(item => {
      if (item.unitsWithItem && item.unitsWithItem.length > 0) {
        const totalCount = item.unitsWithItem.reduce((sum, unit) => sum + (unit.count || 0), 0);
        const winRateSum = item.unitsWithItem.reduce((sum, unit) => sum + ((unit.winRate || 0) * (unit.count || 0)), 0);
        const avgPlacementSum = item.unitsWithItem.reduce((sum, unit) => sum + ((unit.avgPlacement || 0) * (unit.count || 0)), 0);
        
        item.count = totalCount;
        item.winRate = totalCount > 0 ? winRateSum / totalCount : 0;
        item.avgPlacement = totalCount > 0 ? avgPlacementSum / totalCount : 0;
        
        item.stats = {
          count: totalCount,
          winRate: item.winRate,
          avgPlacement: item.avgPlacement,
          top4Rate: 0 // Default since we don't have this data
        };
      }
    });
    
    return Object.values(extractedItems);
  };
  
  // Helper function for weighted average calculations
  const weightedAverage = (values: number[], weights: number[]): number => {
    const sum = weights.reduce((acc, val) => acc + val, 0);
    if (sum === 0) return 0;
    
    let weightedSum = 0;
    for (let i = 0; i < values.length; i++) {
      weightedSum += values[i] * weights[i];
    }
    
    return weightedSum / sum;
  };

  // UPDATED: Fetch from compositions endpoint with region group support
  const { data, isLoading, refetch, error: fetchError } = useQuery({
    queryKey: ['tft-compositions', currentRegion],
    queryFn: async () => {
      try {
        setErrorState({ hasError: false });
        
        let responseData: ProcessedData | null = null;
        
        // Check if this is a group/continent
        if (isRegionGroup(currentRegion) && currentRegion !== 'all') {
          // Get all subregions for this group
          const subRegions = getSubRegions(currentRegion);
          
          if (subRegions.length === 0) {
            throw new Error(`No subregions found for ${currentRegion}`);
          }
          
          // Merge data from all subregions
          responseData = await mergeRegionData(subRegions);
          
          if (!responseData) {
            throw new Error(`Failed to fetch data for ${currentRegion} group`);
          }
          
          // Update match count
          setMatchCount(responseData.summary?.totalGames || 0);
        } else {
          // Regular single region fetch
          const response = await axios.get<ProcessedData>(`/api/tft/compositions?region=${currentRegion}`);
          responseData = response.data;
          
          // Update match count
          setMatchCount(responseData.summary?.totalGames || 0);
        }
        
        // Add region to the data
        if (responseData) {
          responseData.region = currentRegion;
        }
        
        // Update region statuses if available in the response
        if (responseData?.region) {
          // Find the region in our REGIONS array and update its status
          REGIONS.forEach(region => {
            // Only update the current region
            if (region.id === responseData?.region) {
              region.status = 'active';
            }
          });
        }
        
        // Also try to fetch region statuses from the API
        try {
          const statusResponse = await axios.get('/api/region-status');
          if (statusResponse.data && Array.isArray(statusResponse.data)) {
            // Update our REGIONS array with the statuses
            statusResponse.data.forEach((statusItem: any) => {
              const region = REGIONS.find(r => r.id === statusItem.region);
              if (region) {
                region.status = statusItem.status;
                region.lastError = statusItem.last_error ? new Date(statusItem.updated_at) : undefined;
                region.retryAttempts = statusItem.error_count || 0;
              }
            });
          }
        } catch (statusError) {
          // Silently handle errors fetching status - not critical
          console.error('Failed to fetch region statuses:', statusError);
        }
        
        // FIX: Check for items data - if not present, use our helper function
        const items = getProcessedItems();
        if (!items || items.length === 0) {
          // Try to extract from compositions as a fallback
          const extractedItems = extractItemsFromCompositions(responseData.compositions);
          
          // Generate and attach item combos
          if (extractedItems.length > 0) {
            const itemCombos = generateAllItemCombos(extractedItems);
            
            // Attach combos to items
            extractedItems.forEach(item => {
              if (item.id && itemCombos[item.id]) {
                item.combos = itemCombos[item.id];
              }
            });
            
            // Store items globally for access via getProcessedItems
            (global as any).__tftItemsData = extractedItems;
          }
        }
        
        return responseData;
      } catch (error) {
        setErrorState({
          hasError: true,
          error: {
            type: (error as any).response?.status >= 500 ? 'server' : 'network',
            message: (error as Error).message || 'Failed to fetch composition data',
            statusCode: (error as any).response?.status,
            timestamp: new Date()
          },
          retryFn: refetch
        });
        return null;
      }
    },
    staleTime: 300000,
    refetchOnWindowFocus: false
  });

  useEffect(() => {
    if (typeof window !== 'undefined') {
      localStorage.setItem('tft-region', currentRegion);
    }
  }, [currentRegion]);

  // Improved changeRegion function to force refetch
  const changeRegion = useCallback((region: string) => {
    if (region === currentRegion) return;
    
    setIsChangingRegion(true);
    setCurrentRegion(region);
    
    // Force a refetch after state update
    setTimeout(() => {
      refetch();
      setIsChangingRegion(false);
    }, 100);
  }, [currentRegion, refetch]);

  const getRegionStatus = useCallback((regionId: string) => {
    if (regionId === 'all') return 'active';
    
    // For group regions, check if any subregion is active
    if (isRegionGroup(regionId)) {
      const subRegions = getSubRegions(regionId);
      const anyActive = subRegions.some(r => {
        const status = REGIONS.find(region => region.id === r)?.status;
        return status === 'active' || status === undefined;
      });
      
      return anyActive ? 'active' : 'degraded';
    }
    
    return REGIONS.find(r => r.id === regionId)?.status || 'active';
  }, []);

  const handleRetry = useCallback(() => {
    if (errorState.retryFn) errorState.retryFn();
    else refetch();
  }, [errorState, refetch]);

  // Generate highlights based on data
  const highlights = useMemo(() => {
    if (!data?.compositions?.length) return [];

    // Helper function to check if a trait is origin
    const isOriginTrait = (traitId: string) => {
      return Object.keys(traitsJson.origins).includes(traitId);
    };

    // Helper function to create comp variants by type
    const createCompVariantsByType = (
      sortFn: (a: any, b: any) => number, 
      detailFn: (comp: any) => string
    ) => {
      // Generic function to categorize comps
      const categorizeComps = (comps: any[]) => {
        // Fast 9 comps (lots of high cost units)
        const fast9Comps = comps
          .filter(comp => comp.units && comp.units.filter((u: any) => u.cost >= 4).length >= 3)
          .sort(sortFn)
          .slice(0, 1);
          
        // Reroll comps (lots of low cost units)
        const rerollComps = comps
          .filter(comp => comp.units && comp.units.filter((u: any) => u.cost <= 2).length >= 4)
          .sort(sortFn)
          .slice(0, 1);
          
        // Standard comps (neither fast 9 nor reroll)
        const standardComps = comps
          .filter(comp => {
            if (!comp.units) return false;
            const highCostCount = comp.units.filter((u: any) => u.cost >= 4).length;
            const lowCostCount = comp.units.filter((u: any) => u.cost <= 2).length;
            return highCostCount < 3 && lowCostCount < 4;
          })
          .sort(sortFn)
          .slice(0, 1);
          
        return [...fast9Comps, ...rerollComps, ...standardComps];
      };

      // Create a list of all comp categories
      const categorizedComps = categorizeComps(data.compositions);
      
      // Convert to HighlightEntity format
      return categorizedComps.map(comp => {
        // Determine comp type
        let variant = 'Overall';
        if (comp.units) {
          const highCostUnits = comp.units.filter((u: any) => u.cost >= 4).length >= 3;
          const lowCostUnits = comp.units.filter((u: any) => u.cost <= 2).length >= 4;
          variant = highCostUnits ? 'Fast 9' : lowCostUnits ? 'Reroll' : 'Standard';
        }
        
        return {
          entityType: EntityType.Comp,
          entity: comp,
          title: "Best Comp",
          value: comp.name,
          detail: detailFn(comp),
          image: comp.traits?.[0]?.tierIcon || (comp.traits?.[0]?.icon ? 
            ensureIconPath(comp.traits[0].icon, 'trait') : ''),
          link: `/entity/comps/${comp.id}`,
          variant
        };
      });
    };

    // Get items using the helper function
    const allItems = getProcessedItems();

    // Group units by cost for easier filtering
    const unitsByCost: Record<number, any[]> = {
      1: [], 2: [], 3: [], 4: [], 5: []
    };
    
    data.compositions.forEach(comp => {
      comp.units.forEach(unit => {
        if (unit.cost >= 1 && unit.cost <= 5) {
          if (!unitsByCost[unit.cost].find(u => u.id === unit.id)) {
            unitsByCost[unit.cost].push(unit);
          }
        }
      });
    });
    
    // Group items by category
    const itemsByCategory: Record<string, any[]> = {};
    
    // Using the allItems array instead of trying to extract from compositions
    allItems.forEach(item => {
      if (!item.category) return;
      
      if (!itemsByCategory[item.category]) {
        itemsByCategory[item.category] = [];
      }
      
      if (!itemsByCategory[item.category].find(i => i.id === item.id)) {
        itemsByCategory[item.category].push(item);
      }
    });
    
    // Create sorted arrays of entities
    const allUnits = Object.values(unitsByCost).flat();
    const allTraits = data.compositions.flatMap(comp => comp.traits).filter((v, i, a) => a.findIndex(t => t.id === v.id) === i);
    
    // Sort entities
    const sortedUnits = [...allUnits].sort((a, b) => (b.winRate ?? 0) - (a.winRate ?? 0));
    const sortedTraits = [...allTraits].sort((a, b) => (b.winRate ?? 0) - (a.winRate ?? 0));
    const sortedItems = [...allItems].sort((a, b) => (b.winRate ?? 0) - (a.winRate ?? 0));
    const sortedComps = [...data.compositions].sort((a, b) => (b.winRate ?? 0) - (a.winRate ?? 0));

    // Create populated highlight groups
    return [
      // TOP WINNER HIGHLIGHTS
      {
        type: HighlightType.TopWinner,
        title: "Best Winrate",
        unitVariants: [
          ...sortedUnits.slice(0, 3).map(unit => ({
            entityType: EntityType.Unit,
            entity: unit,
            title: "Best Winrate",
            value: unit.name,
            detail: `${(unit.winRate ?? 0).toFixed(1)}% win rate`,
            image: ensureIconPath(unit.icon, 'unit'),
            link: `/entity/units/${unit.id}`,
            variant: 'Overall'
          })),
          ...Object.entries(unitsByCost).flatMap(([cost, units]) => {
            if (!units.length) return [];
            const topUnit = [...units].sort((a, b) => (b.winRate ?? 0) - (a.winRate ?? 0))[0];
            return [{
              entityType: EntityType.Unit,
              entity: topUnit,
              title: "Best Winrate",
              value: topUnit.name,
              detail: `${(topUnit.winRate ?? 0).toFixed(1)}% win rate`,
              image: ensureIconPath(topUnit.icon, 'unit'),
              link: `/entity/units/${topUnit.id}`,
              category: cost,
              variant: `${cost} 🪙`
            }];
          })
        ],
        traitVariants: [
          ...sortedTraits.slice(0, 3).map(trait => ({
            entityType: EntityType.Trait,
            entity: trait,
            title: "Best Winrate",
            value: trait.name,
            detail: `${(trait.winRate ?? 0).toFixed(1)}% win rate`,
            image: trait.tierIcon || ensureIconPath(trait.icon, 'trait'),
            link: `/entity/traits/${trait.id}`,
            variant: 'Overall'
          })),
          ...sortedTraits
            .filter(trait => isOriginTrait(trait.id))
            .slice(0, 2)
            .map(trait => ({
              entityType: EntityType.Trait,
              entity: trait,
              title: "Best Winrate",
              value: trait.name,
              detail: `${(trait.winRate ?? 0).toFixed(1)}% win rate`,
              image: trait.tierIcon || ensureIconPath(trait.icon, 'trait'),
              link: `/entity/traits/${trait.id}`,
              variant: 'Origin'
            })),
          ...sortedTraits
            .filter(trait => !isOriginTrait(trait.id))
            .slice(0, 2)
            .map(trait => ({
              entityType: EntityType.Trait,
              entity: trait,
              title: "Best Winrate",
              value: trait.name,
              detail: `${(trait.winRate ?? 0).toFixed(1)}% win rate`,
              image: trait.tierIcon || ensureIconPath(trait.icon, 'trait'),
              link: `/entity/traits/${trait.id}`,
              variant: 'Class'
            }))
        ],
        itemVariants: [
          ...sortedItems.slice(0, 3).map(item => ({
            entityType: EntityType.Item,
            entity: item,
            title: "Best Winrate",
            value: item.name,
            detail: `${(item.winRate ?? 0).toFixed(1)}% win rate`,
            image: ensureIconPath(item.icon, 'item'),
            link: `/entity/items/${item.id}`,
            variant: 'Overall'
          })),
          ...Object.entries(itemsByCategory).flatMap(([category, items]) => {
            if (!items.length) return [];
            const bestItem = [...items].sort((a, b) => (b.winRate ?? 0) - (a.winRate ?? 0))[0];
            if (!bestItem) return [];
            
            const displayCategory = category.replace(/-/g, ' ')
              .replace(/\b\w/g, c => c.toUpperCase());
            
            return [{
              entityType: EntityType.Item,
              entity: bestItem,
              title: "Best Winrate",
              value: bestItem.name,
              detail: `${(bestItem.winRate ?? 0).toFixed(1)}% win rate`,
              image: ensureIconPath(bestItem.icon, 'item'),
              link: `/entity/items/${bestItem.id}`,
              category: category,
              variant: displayCategory
            }];
          })
        ],
        compVariants: [
          ...sortedComps.slice(0, 3).map(comp => ({
            entityType: EntityType.Comp,
            entity: comp,
            title: "Best Winrate",
            value: comp.name,
            detail: `${(comp.winRate ?? 0).toFixed(1)}% win rate`,
            image: comp.traits?.[0]?.tierIcon || (comp.traits?.[0]?.icon ? 
              ensureIconPath(comp.traits[0].icon, 'trait') : ''),
            link: `/entity/comps/${comp.id}`,
            variant: 'Overall'
          })),
          ...createCompVariantsByType(
            (a, b) => (b.winRate ?? 0) - (a.winRate ?? 0),
            comp => `${(comp.winRate ?? 0).toFixed(1)}% win rate`
          )
        ],
        getPreferredVariant(entityType: string): HighlightEntity | null {
          if (entityType === 'units') return this.unitVariants[0] || null;
          if (entityType === 'traits') return this.traitVariants[0] || null;
          if (entityType === 'items') return this.itemVariants[0] || null;
          if (entityType === 'comps') return this.compVariants[0] || null;
          return null;
        }
      },
      
      // MOST CONSISTENT HIGHLIGHTS 
      {
        type: HighlightType.MostConsistent,
        title: "Most Consistent",
        unitVariants: [
          ...sortedUnits
            .sort((a, b) => (a.avgPlacement ?? 0) - (b.avgPlacement ?? 0))
            .slice(0, 3)
            .map(unit => ({
              entityType: EntityType.Unit,
              entity: unit,
              title: "Most Consistent",
              value: unit.name,
              detail: `${(unit.avgPlacement ?? 0).toFixed(2)} avg place`,
              image: ensureIconPath(unit.icon, 'unit'),
              link: `/entity/units/${unit.id}`,
              variant: 'Overall'
            })),
          ...Object.entries(unitsByCost).flatMap(([cost, units]) => {
            if (!units.length) return [];
            const bestUnit = [...units].sort((a, b) => (a.avgPlacement ?? 0) - (b.avgPlacement ?? 0))[0];
            return [{
              entityType: EntityType.Unit,
              entity: bestUnit,
              title: "Most Consistent",
              value: bestUnit.name,
              detail: `${(bestUnit.avgPlacement ?? 0).toFixed(2)} avg place`,
              image: ensureIconPath(bestUnit.icon, 'unit'),
              link: `/entity/units/${bestUnit.id}`,
              category: cost,
              variant: `${cost} 🪙`
            }];
          })
        ],
        traitVariants: [
          ...sortedTraits
            .sort((a, b) => (a.avgPlacement ?? 0) - (b.avgPlacement ?? 0))
            .slice(0, 3)
            .map(trait => ({
              entityType: EntityType.Trait,
              entity: trait,
              title: "Most Consistent",
              value: trait.name,
              detail: `${(trait.avgPlacement ?? 0).toFixed(2)} avg place`,
              image: trait.tierIcon || ensureIconPath(trait.icon, 'trait'),
              link: `/entity/traits/${trait.id}`,
              variant: 'Overall'
            })),
          ...sortedTraits
            .filter(trait => isOriginTrait(trait.id))
            .sort((a, b) => (a.avgPlacement ?? 0) - (b.avgPlacement ?? 0))
            .slice(0, 2)
            .map(trait => ({
              entityType: EntityType.Trait,
              entity: trait,
              title: "Most Consistent",
              value: trait.name,
              detail: `${(trait.avgPlacement ?? 0).toFixed(2)} avg place`,
              image: trait.tierIcon || ensureIconPath(trait.icon, 'trait'),
              link: `/entity/traits/${trait.id}`,
              variant: 'Origin'
            })),
          ...sortedTraits
            .filter(trait => !isOriginTrait(trait.id))
            .sort((a, b) => (a.avgPlacement ?? 0) - (b.avgPlacement ?? 0))
            .slice(0, 2)
            .map(trait => ({
              entityType: EntityType.Trait,
              entity: trait,
              title: "Most Consistent",
              value: trait.name,
              detail: `${(trait.avgPlacement ?? 0).toFixed(2)} avg place`,
              image: trait.tierIcon || ensureIconPath(trait.icon, 'trait'),
              link: `/entity/traits/${trait.id}`,
              variant: 'Class'
            }))
        ],
        itemVariants: [
          ...sortedItems
            .sort((a, b) => (a.avgPlacement ?? 0) - (b.avgPlacement ?? 0))
            .slice(0, 3)
            .map(item => ({
              entityType: EntityType.Item,
              entity: item,
              title: "Most Consistent",
              value: item.name,
              detail: `${(item.avgPlacement ?? 0).toFixed(2)} avg place`,
              image: ensureIconPath(item.icon, 'item'),
              link: `/entity/items/${item.id}`,
              variant: 'Overall'
            })),
          ...Object.entries(itemsByCategory).flatMap(([category, items]) => {
            if (!items.length) return [];
            const bestItem = [...items].sort((a, b) => (a.avgPlacement ?? 0) - (b.avgPlacement ?? 0))[0];
            if (!bestItem) return [];
            
            const displayCategory = category.replace(/-/g, ' ')
              .replace(/\b\w/g, c => c.toUpperCase());
            
            return [{
              entityType: EntityType.Item,
              entity: bestItem,
              title: "Most Consistent",
              value: bestItem.name,
              detail: `${(bestItem.avgPlacement ?? 0).toFixed(2)} avg place`,
              image: ensureIconPath(bestItem.icon, 'item'),
              link: `/entity/items/${bestItem.id}`,
              category: category,
              variant: displayCategory
            }];
          })
        ],
        compVariants: [
          ...sortedComps
            .sort((a, b) => (a.avgPlacement ?? 0) - (b.avgPlacement ?? 0))
            .slice(0, 3)
            .map(comp => ({
              entityType: EntityType.Comp,
              entity: comp,
              title: "Most Consistent",
              value: comp.name,
              detail: `${(comp.avgPlacement ?? 0).toFixed(2)} avg place`,
              image: comp.traits?.[0]?.tierIcon || (comp.traits?.[0]?.icon ? 
                ensureIconPath(comp.traits[0].icon, 'trait') : ''),
              link: `/entity/comps/${comp.id}`,
              variant: 'Overall'
            })),
          ...createCompVariantsByType(
            (a, b) => (a.avgPlacement ?? 0) - (b.avgPlacement ?? 0),
            comp => `${(comp.avgPlacement ?? 0).toFixed(2)} avg place`
          )
        ],
        getPreferredVariant(entityType: string): HighlightEntity | null {
          if (entityType === 'units') return this.unitVariants[0] || null;
          if (entityType === 'traits') return this.traitVariants[0] || null;
          if (entityType === 'items') return this.itemVariants[0] || null;
          if (entityType === 'comps') return this.compVariants[0] || null;
          return null;
        }
      },
      
      // MOST PLAYED HIGHLIGHTS
      {
        type: HighlightType.MostPlayed,
        title: "Most Played",
        unitVariants: [
          ...sortedUnits
            .sort((a, b) => (b.count ?? 0) - (a.count ?? 0))
            .slice(0, 3)
            .map(unit => ({
              entityType: EntityType.Unit,
              entity: unit,
              title: "Most Played",
              value: unit.name,
              detail: `${unit.count ?? 0} appearances`,
              image: ensureIconPath(unit.icon, 'unit'),
              link: `/entity/units/${unit.id}`,
              variant: 'Overall'
            })),
          ...Object.entries(unitsByCost).flatMap(([cost, units]) => {
            if (!units.length) return [];
            const mostPlayedUnit = [...units].sort((a, b) => (b.count ?? 0) - (a.count ?? 0))[0];
            return [{
              entityType: EntityType.Unit,
              entity: mostPlayedUnit,
              title: "Most Played",
              value: mostPlayedUnit.name,
              detail: `${mostPlayedUnit.count ?? 0} appearances`,
              image: ensureIconPath(mostPlayedUnit.icon, 'unit'),
              link: `/entity/units/${mostPlayedUnit.id}`,
              category: cost,
              variant: `${cost} 🪙`
            }];
          })
        ],
        traitVariants: [
          ...sortedTraits
            .sort((a, b) => (b.count ?? 0) - (a.count ?? 0))
            .slice(0, 3)
            .map(trait => ({
              entityType: EntityType.Trait,
              entity: trait,
              title: "Most Played",
              value: trait.name,
              detail: `${trait.count ?? 0} appearances`,
              image: trait.tierIcon || ensureIconPath(trait.icon, 'trait'),
              link: `/entity/traits/${trait.id}`,
              variant: 'Overall'
            })),
          ...sortedTraits
            .filter(trait => isOriginTrait(trait.id))
            .sort((a, b) => (b.count ?? 0) - (a.count ?? 0))
            .slice(0, 2)
            .map(trait => ({
              entityType: EntityType.Trait,
              entity: trait,
              title: "Most Played",
              value: trait.name,
              detail: `${trait.count ?? 0} appearances`,
              image: trait.tierIcon || ensureIconPath(trait.icon, 'trait'),
              link: `/entity/traits/${trait.id}`,
              variant: 'Origin'
            })),
          ...sortedTraits
            .filter(trait => !isOriginTrait(trait.id))
            .sort((a, b) => (b.count ?? 0) - (a.count ?? 0))
            .slice(0, 2)
            .map(trait => ({
              entityType: EntityType.Trait,
              entity: trait,
              title: "Most Played",
              value: trait.name,
              detail: `${trait.count ?? 0} appearances`,
              image: trait.tierIcon || ensureIconPath(trait.icon, 'trait'),
              link: `/entity/traits/${trait.id}`,
              variant: 'Origin'
            }))
        ],
        itemVariants: [
          ...sortedItems
            .sort((a, b) => (b.count ?? 0) - (a.count ?? 0))
            .slice(0, 3)
            .map(item => ({
              entityType: EntityType.Item,
              entity: item,
              title: "Most Played",
              value: item.name,
              detail: `${item.count ?? 0} appearances`,
              image: ensureIconPath(item.icon, 'item'),
              link: `/entity/items/${item.id}`,
              variant: 'Overall'
            })),
          ...Object.entries(itemsByCategory).flatMap(([category, items]) => {
            if (!items.length) return [];
            const mostPlayedItem = [...items].sort((a, b) => (b.count ?? 0) - (a.count ?? 0))[0];
            if (!mostPlayedItem) return [];
            
            const displayCategory = category.replace(/-/g, ' ')
              .replace(/\b\w/g, c => c.toUpperCase());
            
            return [{
              entityType: EntityType.Item,
              entity: mostPlayedItem,
              title: "Most Played",
              value: mostPlayedItem.name,
              detail: `${mostPlayedItem.count ?? 0} appearances`,
              image: ensureIconPath(mostPlayedItem.icon, 'item'),
              link: `/entity/items/${mostPlayedItem.id}`,
              category,
              variant: displayCategory
            }];
          })
        ],
        compVariants: [
          ...sortedComps
            .sort((a, b) => (b.count ?? 0) - (a.count ?? 0))
            .slice(0, 3)
            .map(comp => ({
              entityType: EntityType.Comp,
              entity: comp,
              title: "Most Played",
              value: comp.name,
              detail: `${comp.count ?? 0} appearances`,
              image: comp.traits?.[0]?.tierIcon || (comp.traits?.[0]?.icon ? 
                ensureIconPath(comp.traits[0].icon, 'trait') : ''),
              link: `/entity/comps/${comp.id}`,
              variant: 'Overall'
            })),
          ...createCompVariantsByType(
            (a, b) => (b.count ?? 0) - (a.count ?? 0),
            comp => `${comp.count ?? 0} appearances`
          )
        ],
        getPreferredVariant(entityType: string): HighlightEntity | null {
          if (entityType === 'units') return this.unitVariants[0] || null;
          if (entityType === 'traits') return this.traitVariants[0] || null;
          if (entityType === 'items') return this.itemVariants[0] || null;
          if (entityType === 'comps') return this.compVariants[0] || null;
          return null;
        }
      },
      
      // MOST FLEXIBLE HIGHLIGHTS
      {
        type: HighlightType.FlexiblePick,
        title: "Most Flexible",
        unitVariants: [
          ...sortedUnits
            .filter(unit => (unit.relatedComps?.length ?? 0) >= 3)
            .sort((a, b) => (b.relatedComps?.length ?? 0) - (a.relatedComps?.length ?? 0))
            .slice(0, 3)
            .map(unit => ({
              entityType: EntityType.Unit,
              entity: unit,
              title: "Most Flexible",
              value: unit.name,
              detail: `Fits in ${unit.relatedComps?.length ?? 0} comps`,
              image: ensureIconPath(unit.icon, 'unit'),
              link: `/entity/units/${unit.id}`,
              variant: 'Overall'
            })),
          ...Object.entries(unitsByCost).flatMap(([cost, units]) => {
            if (!units.length) return [];
            const flexibleUnit = [...units]
              .filter(unit => (unit.relatedComps?.length ?? 0) >= 2)
              .sort((a, b) => (b.relatedComps?.length ?? 0) - (a.relatedComps?.length ?? 0))[0];
            
            if (!flexibleUnit) return [];
            
            return [{
              entityType: EntityType.Unit,
              entity: flexibleUnit,
              title: "Most Flexible",
              value: flexibleUnit.name,
              detail: `Fits in ${flexibleUnit.relatedComps?.length ?? 0} comps`,
              image: ensureIconPath(flexibleUnit.icon, 'unit'),
              link: `/entity/units/${flexibleUnit.id}`,
              category: cost,
              variant: `${cost} 🪙`
            }];
          })
        ],
        traitVariants: [
          ...sortedTraits
            .filter(trait => (trait.relatedComps?.length ?? 0) >= 2)
            .sort((a, b) => (b.relatedComps?.length ?? 0) - (a.relatedComps?.length ?? 0))
            .slice(0, 3)
            .map(trait => ({
              entityType: EntityType.Trait,
              entity: trait,
              title: "Most Flexible",
              value: trait.name,
              detail: `Used in ${trait.relatedComps?.length ?? 0} comps`,
              image: trait.tierIcon || ensureIconPath(trait.icon, 'trait'),
              link: `/entity/traits/${trait.id}`,
              variant: 'Overall'
            })),
          ...sortedTraits
            .filter(trait => isOriginTrait(trait.id) && (trait.relatedComps?.length ?? 0) >= 2)
            .sort((a, b) => (b.relatedComps?.length ?? 0) - (a.relatedComps?.length ?? 0))
            .slice(0, 2)
            .map(trait => ({
              entityType: EntityType.Trait,
              entity: trait,
              title: "Most Flexible",
              value: trait.name,
              detail: `Used in ${trait.relatedComps?.length ?? 0} comps`,
              image: trait.tierIcon || ensureIconPath(trait.icon, 'trait'),
              link: `/entity/traits/${trait.id}`,
              variant: 'Origin'
            })),
          ...sortedTraits
            .filter(trait => !isOriginTrait(trait.id) && (trait.relatedComps?.length ?? 0) >= 2)
            .sort((a, b) => (b.relatedComps?.length ?? 0) - (a.relatedComps?.length ?? 0))
            .slice(0, 2)
            .map(trait => ({
              entityType: EntityType.Trait,
              entity: trait,
              title: "Most Flexible",
              value: trait.name,
              detail: `Used in ${trait.relatedComps?.length ?? 0} comps`,
              image: trait.tierIcon || ensureIconPath(trait.icon, 'trait'),
              link: `/entity/traits/${trait.id}`,
              variant: 'Class'
            }))
        ],
        itemVariants: [
          ...sortedItems
            .filter(item => (item.unitsWithItem?.length ?? 0) >= 2)
            .sort((a, b) => (b.unitsWithItem?.length ?? 0) - (a.unitsWithItem?.length ?? 0))
            .slice(0, 3)
            .map(item => ({
              entityType: EntityType.Item,
              entity: item,
              title: "Most Flexible",
              value: item.name,
              detail: `Used on ${item.unitsWithItem?.length ?? 0} units`,
              image: ensureIconPath(item.icon, 'item'),
              link: `/entity/items/${item.id}`,
              variant: 'Overall'
            })),
          ...Object.entries(itemsByCategory).flatMap(([category, items]) => {
            if (!items.length) return [];
            
            const flexibleItem = [...items]
              .filter(item => (item.unitsWithItem?.length ?? 0) >= 2)
              .sort((a, b) => (b.unitsWithItem?.length ?? 0) - (a.unitsWithItem?.length ?? 0))[0];
              
            if (!flexibleItem) return [];
            
            const displayCategory = category.replace(/-/g, ' ')
              .replace(/\b\w/g, c => c.toUpperCase());
            
            return [{
              entityType: EntityType.Item,
              entity: flexibleItem,
              title: "Most Flexible",
              value: flexibleItem.name,
              detail: `Used on ${flexibleItem.unitsWithItem?.length ?? 0} units`,
              image: ensureIconPath(flexibleItem.icon, 'item'),
              link: `/entity/items/${flexibleItem.id}`,
              category,
              variant: displayCategory
            }];
          })
        ],
        compVariants: [
          ...sortedComps
            .filter(comp => (comp.traits?.length ?? 0) >= 3)
            .sort((a, b) => (b.traits?.length ?? 0) - (a.traits?.length ?? 0))
            .slice(0, 3)
            .map(comp => ({
              entityType: EntityType.Comp,
              entity: comp,
              title: "Most Flexible",
              value: comp.name,
              detail: `${comp.traits?.length ?? 0} active traits`,
              image: comp.traits?.[0]?.tierIcon || (comp.traits?.[0]?.icon ? 
                ensureIconPath(comp.traits[0].icon, 'trait') : ''),
              link: `/entity/comps/${comp.id}`,
              variant: 'Overall'
            })),
          ...createCompVariantsByType(
            (a, b) => (b.traits?.length ?? 0) - (a.traits?.length ?? 0),
            comp => `${comp.traits?.length ?? 0} active traits`
          )
        ],
        getPreferredVariant(entityType: string): HighlightEntity | null {
          if (entityType === 'units') return this.unitVariants[0] || null;
          if (entityType === 'traits') return this.traitVariants[0] || null;
          if (entityType === 'items') return this.itemVariants[0] || null;
          if (entityType === 'comps') return this.compVariants[0] || null;
          return null;
        }
      },
      
      // POCKET PICK HIGHLIGHTS
      {
        type: HighlightType.PocketPick,
        title: "Pocket Pick",
        unitVariants: [
          ...sortedUnits
            .filter(unit => (unit.winRate ?? 0) > 52 && (unit.playRate ?? 0) < 15)
            .sort((a, b) => (b.winRate ?? 0) - (a.winRate ?? 0))
            .slice(0, 3)
            .map(unit => ({
              entityType: EntityType.Unit,
              entity: unit,
              title: "Pocket Pick",
              value: unit.name,
              detail: `${(unit.winRate ?? 0).toFixed(1)}% win • ${(unit.playRate ?? 0).toFixed(1)}% play`,
              image: ensureIconPath(unit.icon, 'unit'),
              link: `/entity/units/${unit.id}`,
              variant: 'Overall'
            })),
          ...Object.entries(unitsByCost).flatMap(([cost, units]) => {
            const pocketPicks = units.filter(unit => 
              (unit.winRate ?? 0) > 52 && 
              (unit.playRate ?? 0) < Math.min(25, units.length > 5 ? 15 : 30)
            );
            
            if (!pocketPicks.length) return [];
            
            const bestPocketPick = [...pocketPicks]
              .sort((a, b) => (b.winRate ?? 0) - (a.winRate ?? 0))[0];
              
            return [{
              entityType: EntityType.Unit,
              entity: bestPocketPick,
              title: "Pocket Pick",
              value: bestPocketPick.name,
              detail: `${(bestPocketPick.winRate ?? 0).toFixed(1)}% win • ${(bestPocketPick.playRate ?? 0).toFixed(1)}% play`,
              image: ensureIconPath(bestPocketPick.icon, 'unit'),
              link: `/entity/units/${bestPocketPick.id}`,
              category: cost,
              variant: `${cost} 🪙`
            }];
          })
        ],
        traitVariants: [
          ...sortedTraits
            .filter(trait => (trait.winRate ?? 0) > 52 && (trait.playRate ?? 0) < 15)
            .sort((a, b) => (b.winRate ?? 0) - (a.winRate ?? 0))
            .slice(0, 3)
            .map(trait => ({
              entityType: EntityType.Trait,
              entity: trait,
              title: "Pocket Pick",
              value: trait.name,
              detail: `${(trait.winRate ?? 0).toFixed(1)}% win • ${(trait.playRate ?? 0).toFixed(1)}% play`,
              image: trait.tierIcon || ensureIconPath(trait.icon, 'trait'),
              link: `/entity/traits/${trait.id}`,
              variant: 'Overall'
            })),
          ...sortedTraits
            .filter(trait => isOriginTrait(trait.id) && (trait.winRate ?? 0) > 52 && (trait.playRate ?? 0) < 15)
            .sort((a, b) => (b.winRate ?? 0) - (a.winRate ?? 0))
            .slice(0, 2)
            .map(trait => ({
              entityType: EntityType.Trait,
              entity: trait,
              title: "Pocket Pick",
              value: trait.name,
              detail: `${(trait.winRate ?? 0).toFixed(1)}% win • ${(trait.playRate ?? 0).toFixed(1)}% play`,
              image: trait.tierIcon || ensureIconPath(trait.icon, 'trait'),
              link: `/entity/traits/${trait.id}`,
              variant: 'Origin'
            })),
          ...sortedTraits
            .filter(trait => !isOriginTrait(trait.id) && (trait.winRate ?? 0) > 52 && (trait.playRate ?? 0) < 15)
            .sort((a, b) => (b.winRate ?? 0) - (a.winRate ?? 0))
            .slice(0, 2)
            .map(trait => ({
              entityType: EntityType.Trait,
              entity: trait,
              title: "Pocket Pick",
              value: trait.name,
              detail: `${(trait.winRate ?? 0).toFixed(1)}% win • ${(trait.playRate ?? 0).toFixed(1)}% play`,
              image: trait.tierIcon || ensureIconPath(trait.icon, 'trait'),
              link: `/entity/traits/${trait.id}`,
              variant: 'Class'
            }))
        ],
        itemVariants: [
          ...sortedItems
            .filter(item => (item.winRate ?? 0) > 52 && (item.playRate ?? 0) < 15)
            .sort((a, b) => (b.winRate ?? 0) - (a.winRate ?? 0))
            .slice(0, 3)
            .map(item => ({
              entityType: EntityType.Item,
              entity: item,
              title: "Pocket Pick",
              value: item.name,
              detail: `${(item.winRate ?? 0).toFixed(1)}% win • ${(item.playRate ?? 0).toFixed(1)}% play`,
              image: ensureIconPath(item.icon, 'item'),
              link: `/entity/items/${item.id}`,
              variant: 'Overall'
            })),
          ...Object.entries(itemsByCategory).flatMap(([category, items]) => {
            const pocketPicks = items.filter(item => 
              (item.winRate ?? 0) > 50 && 
              (item.playRate ?? 0) < Math.min(20, items.length > 5 ? 15 : 30)
            );
            
            if (!pocketPicks.length) return [];
            
            const bestPocketPick = [...pocketPicks]
              .sort((a, b) => (b.winRate ?? 0) - (a.winRate ?? 0))[0];
              
            if (!bestPocketPick) return [];
            
            const displayCategory = category.replace(/-/g, ' ')
              .replace(/\b\w/g, c => c.toUpperCase());
            
            return [{
              entityType: EntityType.Item,
              entity: bestPocketPick,
              title: "Pocket Pick",
              value: bestPocketPick.name,
              detail: `${(bestPocketPick.winRate ?? 0).toFixed(1)}% win • ${(bestPocketPick.playRate ?? 0).toFixed(1)}% play`,
              image: ensureIconPath(bestPocketPick.icon, 'item'),
              link: `/entity/items/${bestPocketPick.id}`,
              category,
              variant: displayCategory
            }];
          })
        ],
        compVariants: [
          ...sortedComps
            .filter(comp => (comp.winRate ?? 0) > 52 && (comp.playRate ?? 0) < 8)
            .sort((a, b) => (b.winRate ?? 0) - (a.winRate ?? 0))
            .slice(0, 3)
            .map(comp => ({
              entityType: EntityType.Comp,
              entity: comp,
              title: "Pocket Pick",
              value: comp.name,
              detail: `${(comp.winRate ?? 0).toFixed(1)}% win • ${(comp.playRate ?? 0).toFixed(1)}% play`,
              image: comp.traits?.[0]?.tierIcon || (comp.traits?.[0]?.icon ? 
                ensureIconPath(comp.traits[0].icon, 'trait') : ''),
              link: `/entity/comps/${comp.id}`,
              variant: 'Overall'
            })),
          ...createCompVariantsByType(
            (a, b) => {
              // For pocket picks, we want high winrate but low playrate
              // First check if one is a pocket pick and the other isn't
              const aIsPocket = (a.winRate ?? 0) > 52 && (a.playRate ?? 0) < 10;
              const bIsPocket = (b.winRate ?? 0) > 52 && (b.playRate ?? 0) < 10;
              
              if (aIsPocket && !bIsPocket) return -1;
              if (!aIsPocket && bIsPocket) return 1;
              
              // If both or neither are pocket picks, go by winrate
              return (b.winRate ?? 0) - (a.winRate ?? 0);
            },
            comp => `${(comp.winRate ?? 0).toFixed(1)}% win • ${(comp.playRate ?? 0).toFixed(1)}% play`
          )
        ],
        getPreferredVariant(entityType: string): HighlightEntity | null {
          if (entityType === 'units') return this.unitVariants[0] || null;
          if (entityType === 'traits') return this.traitVariants[0] || null;
          if (entityType === 'items') return this.itemVariants[0] || null;
          if (entityType === 'comps') return this.compVariants[0] || null;
          return null;
        }
      }
    ];
  }, [data, getProcessedItems]);

  return {
    data,
    isLoading: isLoading || isChangingRegion,
    currentRegion,
    changeRegion,
    matchCount,
    regions: REGIONS,
    refetch,
    errorState,
    getRegionStatus,
    error: fetchError,
    handleRetry,
    highlights
  };
}

export function useEntityData(type: string, id: string) {
  const { data } = useTftData();
  
  if (!data || !id) return null;
  
  if (type === 'comps') {
    return data.compositions.find(comp => comp.id === id);
  }
  
  if (type === 'items') {
    // FIX: Use the helper function to get items
    const items = getProcessedItems();
    if (items && items.length > 0) {
      const item = items.find(item => item.id === id);
      if (item) {
        return item;
      }
    }
  }
  
  // For other entity types, or as fallback for items, search through compositions
  let entity: any;
  let relatedComps: Composition[] = [];
  
  if (type === 'units') {
    // Find the unit in any composition
    data.compositions.forEach(comp => {
      const foundUnit = comp.units.find(unit => unit.id === id);
      if (foundUnit) {
        entity = foundUnit;
        // Add this comp to related comps if it contains the unit
        relatedComps.push(comp);
      }
    });
  } 
  else if (type === 'traits') {
    // Find the trait in any composition
    data.compositions.forEach(comp => {
      const foundTrait = comp.traits.find(trait => trait.id === id);
      if (foundTrait) {
        entity = foundTrait;
        // Add this comp to related comps if it contains the trait
        relatedComps.push(comp);
      }
    });
  } 
  else if (type === 'items') {
    // This section now serves as a fallback if the item wasn't found in the getProcessedItems call
    
    // Find the item in any unit in any composition
    data.compositions.forEach(comp => {
      comp.units.forEach(unit => {
        if (!unit.items) return;
        
        const foundItem = unit.items.find(item => item.id === id);
        if (foundItem) {
          entity = foundItem;
          // Add this comp to related comps if it contains the item
          relatedComps.push(comp);
        }
      });
    });
    
    // Find units that use this item
    const unitsWithItem: any[] = [];
    data.compositions.forEach(comp => {
      comp.units.forEach(unit => {
        if (!unit.items) return;
        
        const hasItem = unit.items.some(item => item.id === id);
        if (hasItem) {
          // Check if this unit is already in the list
          const existingUnit = unitsWithItem.find(u => u.id === unit.id);
          if (existingUnit) {
            existingUnit.count += comp.count || 1;
          } else {
            unitsWithItem.push({
              id: unit.id,
              name: unit.name,
              icon: unit.icon,
              cost: unit.cost,
              count: comp.count || 1,
              winRate: comp.winRate || 0,
              avgPlacement: comp.avgPlacement || 0,
              relatedComps: [comp]
            });
          }
        }
      });
    });
    
    // Calculate stats for the returned entity
    if (entity && unitsWithItem.length > 0) {
      entity.unitsWithItem = unitsWithItem
        .map(unit => ({
          ...unit,
          winRate: unit.winRate * 100,
        }))
        .sort((a, b) => b.count - a.count);
    }
  }
  
  if (!entity) return null;
  
  // Calculate stats based on related comps
  const totalGames = relatedComps.reduce((sum, comp) => sum + (comp.count || 1), 0);
  const avgPlacement = relatedComps.reduce((sum, comp) => 
    sum + ((comp.avgPlacement ?? 0) * (comp.count || 1)), 0) / (totalGames || 1);
  const winRate = relatedComps.reduce((sum, comp) => 
    sum + ((comp.winRate ?? 0) * (comp.count || 1)), 0) / (totalGames || 1);
  const top4Rate = relatedComps.reduce((sum, comp) => 
    sum + ((comp.top4Rate ?? 0) * (comp.count || 1)), 0) / (totalGames || 1);
  
  // Return the entity with calculated stats
  return {
    ...entity,
    relatedComps,
    stats: { 
      count: totalGames, 
      avgPlacement, 
      winRate, 
      top4Rate 
    }
  };
}

export function useTierLists() {
  const { data } = useTftData();
  if (!data) return null;
  
  const calculateScore = (entity: BaseStats) => {
    return ((entity.winRate ?? 0) * 0.6) + 
           ((entity.playRate ?? 0) * 0.3) - 
           ((entity.avgPlacement ?? 5) * 0.1);
  };
  
  const createTierList = <T extends BaseStats>(items: T[]): TierList => {
    const sorted = [...items].sort((a, b) => calculateScore(b) - calculateScore(a));
    
    if (items.length <= 4) {
      return {
        S: sorted.slice(0, 1),
        A: sorted.slice(1, 2),
        B: sorted.slice(2, 3),
        C: sorted.slice(3)
      };
    }
    
    const total = sorted.length;
    return {
      S: sorted.slice(0, Math.max(1, Math.floor(total * 0.15))),
      A: sorted.slice(Math.floor(total * 0.15), Math.floor(total * 0.4)),
      B: sorted.slice(Math.floor(total * 0.4), Math.floor(total * 0.7)),
      C: sorted.slice(Math.floor(total * 0.7))
    };
  };
  
  // Extract unique entities from compositions
  const extractEntities = (type: string): any[] => {
    if (!data.compositions) return [];
    
    if (type === 'units') {
      // Extract unique units from all compositions
      const units: Record<string, any> = {};
      data.compositions.forEach(comp => {
        comp.units.forEach(unit => {
          if (!units[unit.id]) {
            units[unit.id] = {...unit, count: 0, playRate: 0};
          }
          units[unit.id].count += comp.count || 1;
        });
      });
      
      // Calculate playRate for each unit
      const totalCompositions = data.compositions.reduce((sum, comp) => sum + (comp.count || 1), 0);
      Object.values(units).forEach(unit => {
        unit.playRate = (unit.count / totalCompositions) * 100;
      });
      
      return Object.values(units);
    }
    
    if (type === 'items') {
      // FIX: Use getProcessedItems if available
      const processedItems = getProcessedItems();
      if (processedItems && processedItems.length > 0) {
        return processedItems;
      }
      
      // Fallback to extraction if getProcessedItems doesn't work
      const items: Record<string, any> = {};
      data.compositions.forEach(comp => {
        comp.units.forEach(unit => {
          (unit.items || []).forEach(item => {
            if (!items[item.id]) {
              items[item.id] = {...item, count: 0, playRate: 0};
            }
            items[item.id].count += comp.count || 1;
          });
        });
      });
      
      // Calculate playRate for each item
      const totalItems = Object.values(items).reduce((sum: number, item: any) => sum + item.count, 0);
      Object.values(items).forEach(item => {
        item.playRate = (item.count / totalItems) * 100;
      });
      
      return Object.values(items);
    }
    
    if (type === 'traits') {
      // Extract unique traits from all compositions
      const traits: Record<string, any> = {};
      data.compositions.forEach(comp => {
        comp.traits.forEach(trait => {
          if (!traits[trait.id]) {
            traits[trait.id] = {...trait, count: 0, playRate: 0};
          }
          traits[trait.id].count += comp.count || 1;
        });
      });
      
      // Calculate playRate for each trait
      const totalTraits = Object.values(traits).reduce((sum: number, trait: any) => sum + trait.count, 0);
      Object.values(traits).forEach(trait => {
        trait.playRate = (trait.count / totalTraits) * 100;
      });
      
      return Object.values(traits);
    }
    
    return data.compositions;
  };
  
  return {
    units: createTierList(extractEntities('units')),
    items: createTierList(extractEntities('items')),
    traits: createTierList(extractEntities('traits')),
    comps: createTierList(data.compositions)
  };
}

export function useEntityFilter<T extends Record<string, any>>(
  entities: T[], 
  initialFilters: Record<string, Record<string, boolean>> = {}
) {
  const [search, setSearch] = useState('');
  const [filters, setFilters] = useState(initialFilters);
  
  const toggleFilter = (type: string, filterId: string): void => {
    setFilters(prevState => {
      const newState = {...prevState};
      
      if (filterId === 'all') {
        return {...newState, [type]: { all: true }};
      }
    
      // Create a new object without the 'all' property
      const filterGroup = {...(newState[type] || { all: true })};
      delete filterGroup.all;
    
      filterGroup[filterId] = !filterGroup[filterId];
    
      const hasActiveFilters = Object.entries(filterGroup)
        .some(([key, value]) => key !== 'all' && value);
    
      return {
        ...newState, 
        [type]: hasActiveFilters ? filterGroup : { all: true }
      };
    });
  };
  
  const filteredEntities = useMemo(() => {
    if (!entities) return [];
    
    return entities.filter(entity => {
      if (search && typeof entity.name === 'string' && 
          !entity.name.toLowerCase().includes(search.toLowerCase())) {
        return false;
      }
      
      for (const filterType in filters) {
        const filterGroup = filters[filterType];
        
        if (filterGroup.all) continue;
        
        const entityVal = entity[filterType];
        if (entityVal !== undefined) {
          const strVal = String(entityVal);
          if (!filterGroup[strVal]) return false;
        }
      }
      
      return true;
    });
  }, [entities, search, filters]);
  
  return {
    search,
    setSearch,
    filters,
    toggleFilter,
    filteredEntities
  };
}
EOL

# Update the rateLimiter.ts to include RU region
cat > src/utils/rateLimiter.ts << 'EOL'
/**
 * Advanced rate limiter implementation with queuing
 */
export class RateLimiter {
  private windowMs: number;
  private maxRequests: number;
  private timestamps: number[] = [];
  private pendingPromises: { resolve: () => void }[] = [];
  private intervalId: NodeJS.Timeout | null = null;

  constructor(windowMs: number, maxRequests: number) {
    this.windowMs = windowMs;
    this.maxRequests = maxRequests;
    
    // Start cleanup interval
    this.intervalId = setInterval(() => this.cleanup(), windowMs / 2);
  }

  private cleanup(): void {
    const now = Date.now();
    const windowStart = now - this.windowMs;
    
    // Remove expired timestamps
    this.timestamps = this.timestamps.filter(time => time > windowStart);
    
    // Check if we can resolve pending promises
    this.checkPending();
  }

  private checkPending(): void {
    // If we have capacity and pending requests, resolve the oldest one
    while (this.timestamps.length < this.maxRequests && this.pendingPromises.length > 0) {
      const pending = this.pendingPromises.shift();
      if (pending) {
        this.timestamps.push(Date.now());
        pending.resolve();
      }
    }
  }

  async acquire(): Promise<void> {
    // Clean up old timestamps first
    const now = Date.now();
    const windowStart = now - this.windowMs;
    this.timestamps = this.timestamps.filter(time => time > windowStart);
    
    // If we haven't reached the limit, allow the request
    if (this.timestamps.length < this.maxRequests) {
      this.timestamps.push(now);
      return Promise.resolve();
    }
    
    // Otherwise, queue it
    return new Promise<void>(resolve => {
      this.pendingPromises.push({ resolve });
    });
  }

  destroy(): void {
    if (this.intervalId) {
      clearInterval(this.intervalId);
      this.intervalId = null;
    }
  }
}

// Define regions and continents
interface ContinentInfo {
  regions: string[];
  limiters: Record<string, RateLimiter>;
}

// Map regions to their continental routing
export const REGION_TO_CONTINENT: Record<string, string> = {
  'na1': 'americas',
  'br1': 'americas',
  'la1': 'americas',
  'la2': 'americas',
  'euw1': 'europe',
  'eun1': 'europe',
  'tr1': 'europe',
  'ru': 'europe',
  'kr': 'asia',
  'jp1': 'asia',
  'ph2': 'asia',
  'sg2': 'asia',
  'th2': 'asia',
  'tw2': 'asia',
  'vn2': 'asia'
};

// Create continent-based rate limiters
export const CONTINENTS: Record<string, ContinentInfo> = {
  'americas': {
    regions: ['na1', 'br1', 'la1', 'la2'],
    limiters: {
      'match': new RateLimiter(10000, 250),
      'matches-by-puuid': new RateLimiter(10000, 600)
    }
  },
  'europe': {
    regions: ['euw1', 'eun1', 'tr1', 'ru'],
    limiters: {
      'match': new RateLimiter(10000, 250),
      'matches-by-puuid': new RateLimiter(10000, 600)
    }
  },
  'asia': {
    regions: ['kr', 'jp1', 'ph2', 'sg2', 'th2', 'tw2', 'vn2'],
    limiters: {
      'match': new RateLimiter(10000, 250),
      'matches-by-puuid': new RateLimiter(10000, 600)
    }
  }
};

// Regional rate limiters (for regional endpoints)
const regionLimiters: Record<string, Record<string, RateLimiter>> = {};

// Initialize rate limiters for each region
Object.keys(REGION_TO_CONTINENT).forEach(region => {
  regionLimiters[region] = {
    // Summoner endpoint rate limits
    'summoner': new RateLimiter(60000, 1600),  // 1600 requests every 1 minute for summoner endpoints
    
    // League endpoint rate limits
    'league-master': new RateLimiter(10000, 30),  // /tft/league/v1/master - 30 requests every 10 seconds
    'league-entries': new RateLimiter(10000, 250), // /tft/league/v1/entries/{tier}/{division} - 250 requests every 10 seconds
    'league-summoner': new RateLimiter(60000, 60), // /tft/league/v1/entries/by-summoner/{summonerId} - 60 requests every 1 minute
    
    // General fallback rate limiter
    'default': new RateLimiter(10000, 20)      // Conservative default
  };
});

// Utility function to acquire appropriate rate limit for an endpoint
export async function acquireRateLimit(region: string, endpoint: string): Promise<void> {
  const continent = REGION_TO_CONTINENT[region] || 'americas'; // Default to Americas if unknown region
  
  // For continental endpoints (match details/history)
  if (endpoint.includes('/tft/match/v1/matches/by-puuid')) {
    await CONTINENTS[continent].limiters['matches-by-puuid'].acquire();
    return;
  } 
  
  if (endpoint.includes('/tft/match/v1/matches/')) {
    await CONTINENTS[continent].limiters['match'].acquire();
    return;
  }
  
  // For regional endpoints
  const limiter = regionLimiters[region] || regionLimiters['na1']; // Default to NA if unknown
  
  // Select the appropriate limiter based on the endpoint
  if (endpoint.includes('/tft/summoner/v1/')) {
    await limiter['summoner'].acquire();
  } else if (endpoint.includes('/tft/league/v1/master')) {
    await limiter['league-master'].acquire();
  } else if (endpoint.includes('/tft/league/v1/entries/by-summoner')) {
    await limiter['league-summoner'].acquire();
  } else if (endpoint.includes('/tft/league/v1/entries')) {
    await limiter['league-entries'].acquire();
  } else {
    await limiter['default'].acquire();
  }
}
EOL

# Update the api.ts file
cat > src/utils/api.ts << 'EOL'
import { acquireRateLimit, REGION_TO_CONTINENT, CONTINENTS } from '@/utils/rateLimiter';
import { saveMatch, updateRegionStatus } from '@/utils/db';
import { logMessage, LogSeverity } from '@/utils/logger';
import { ProcessedMatch } from '@/types';

// REGIONS object with all available regions
export const REGIONS: Record<string, any> = {
  NA: { 
    master: 'https://na1.api.riotgames.com/tft/league/v1/master', 
    summoner: 'https://na1.api.riotgames.com/tft/summoner/v1/summoners',
    routing: 'na1',
    continental: 'americas',
    status: 'active'
  },
  EUW: { 
    master: 'https://euw1.api.riotgames.com/tft/league/v1/master', 
    summoner: 'https://euw1.api.riotgames.com/tft/summoner/v1/summoners',
    routing: 'euw1',
    continental: 'europe',
    status: 'active'
  },
  EUNE: { 
    master: 'https://eun1.api.riotgames.com/tft/league/v1/master', 
    summoner: 'https://eun1.api.riotgames.com/tft/summoner/v1/summoners',
    routing: 'eun1',
    continental: 'europe',
    status: 'active'
  },
  KR: { 
    master: 'https://kr.api.riotgames.com/tft/league/v1/master', 
    summoner: 'https://kr.api.riotgames.com/tft/summoner/v1/summoners',
    routing: 'kr',
    continental: 'asia',
    status: 'active'
  },
  JP: { 
    master: 'https://jp1.api.riotgames.com/tft/league/v1/master', 
    summoner: 'https://jp1.api.riotgames.com/tft/summoner/v1/summoners',
    routing: 'jp1',
    continental: 'asia',
    status: 'active'
  },
  BR: { 
    master: 'https://br1.api.riotgames.com/tft/league/v1/master', 
    summoner: 'https://br1.api.riotgames.com/tft/summoner/v1/summoners',
    routing: 'br1',
    continental: 'americas',
    status: 'active'
  },
  LAN: { 
    master: 'https://la1.api.riotgames.com/tft/league/v1/master', 
    summoner: 'https://la1.api.riotgames.com/tft/summoner/v1/summoners',
    routing: 'la1',
    continental: 'americas',
    status: 'active'
  },
  LAS: { 
    master: 'https://la2.api.riotgames.com/tft/league/v1/master', 
    summoner: 'https://la2.api.riotgames.com/tft/summoner/v1/summoners',
    routing: 'la2',
    continental: 'americas',
    status: 'active'
  },
  TR: { 
    master: 'https://tr1.api.riotgames.com/tft/league/v1/master', 
    summoner: 'https://tr1.api.riotgames.com/tft/summoner/v1/summoners',
    routing: 'tr1',
    continental: 'europe',
    status: 'active'
  },
  RU: { 
    master: 'https://ru.api.riotgames.com/tft/league/v1/master', 
    summoner: 'https://ru.api.riotgames.com/tft/summoner/v1/summoners',
    routing: 'ru',
    continental: 'europe',
    status: 'active'
  }
};

// Define RegionKey type here to match the one in api.ts
export type RegionKey = keyof typeof REGIONS;

// Continental routing for parallel processing
export const REGIONS_BY_CONTINENT: Record<string, RegionKey[]> = {
  'americas': ['NA', 'BR', 'LAN', 'LAS'],
  'europe': ['EUW', 'EUNE', 'TR', 'RU'],
  'asia': ['KR', 'JP'],
  'sea': ['OCE']
};

// Define interface for API endpoints
interface ApiEndpoints {
  master: string;
  summoner: (id: string) => string;
  matches: (puuid: string) => string;
  matchDetails: (id: string) => string;
}

// Build API endpoints for a region
export const getApiEndpoints = (regionKey: RegionKey): ApiEndpoints | null => {
  const region = REGIONS[regionKey];
  if (!region) return null;
  
  return {
    master: region.master,
    summoner: (id: string) => `${region.summoner}/${id}`,
    matches: (puuid: string) => `https://${region.continental}.api.riotgames.com/tft/match/v1/matches/by-puuid/${puuid}/ids?count=100`,
    matchDetails: (id: string) => `https://${region.continental}.api.riotgames.com/tft/match/v1/matches/${id}`
  };
};

// Define interface for fetch options
interface FetchOptions extends RequestInit {
  maxRetries?: number;
  baseDelay?: number;
  timeout?: number;
}

// Typed fetch function with API key
export const fetchWithApiKey = async (url: string, options: FetchOptions = {}): Promise<any> => {
  const maxRetries = options.maxRetries || 5;
  const baseDelay = options.baseDelay || 1000; // 1 second

  // Determine region for rate limiting
  let region = 'na1'; // Default to NA
  
  // Extract region from URL
  if (url.includes('na1.api.riotgames.com')) region = 'na1';
  else if (url.includes('euw1.api.riotgames.com')) region = 'euw1';
  else if (url.includes('ru.api.riotgames.com')) region = 'ru';
  else if (url.includes('kr.api.riotgames.com')) region = 'kr';
  else if (url.includes('br1.api.riotgames.com')) region = 'br1';
  else if (url.includes('jp1.api.riotgames.com')) region = 'jp1';
  else if (url.includes('americas.api.riotgames.com')) region = 'americas';
  else if (url.includes('europe.api.riotgames.com')) region = 'europe';
  else if (url.includes('asia.api.riotgames.com')) region = 'asia';
  
  // Apply rate limiting
  await acquireRateLimit(region, url);
  
  let retries = 0;
  
  while (retries < maxRetries) {
    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), options.timeout || 15000);
      
      // Check if API key is set
      if (!process.env.RIOT_API_KEY) {
        throw new Error('RIOT_API_KEY is not set in environment variables');
      }
      
      const response = await fetch(url, {
        headers: { 'X-Riot-Token': process.env.RIOT_API_KEY },
        signal: controller.signal,
        ...options
      });
      
      clearTimeout(timeoutId);
      
      if (response.ok) {
        return await response.json();
      }
      
      // Handle specific error cases
      if (response.status === 429) {
        // Rate limit - get retry-after header or use exponential backoff
        const retryAfter = response.headers.get('Retry-After') || Math.pow(2, retries) * baseDelay;
        logMessage(LogSeverity.WARN, `Rate limit hit for ${url}, retrying after ${retryAfter}ms`);
        await new Promise(resolve => setTimeout(resolve, Number(retryAfter)));
        retries++;
        continue;
      }
      
      if (response.status === 504) {
        // Gateway timeout - common with EUW
        logMessage(LogSeverity.WARN, `Gateway timeout for ${url}, retry ${retries + 1}/${maxRetries}`);
        await new Promise(resolve => setTimeout(resolve, Math.pow(2, retries) * baseDelay));
        retries++;
        continue;
      }
      
      if (response.status >= 500) {
        // Server error - retry with backoff
        logMessage(LogSeverity.ERROR, `Server error ${response.status} for ${url}, retry ${retries + 1}/${maxRetries}`);
        await new Promise(resolve => setTimeout(resolve, Math.pow(2, retries) * baseDelay));
        retries++;
        continue;
      }
      
      // API key error
      if (response.status === 403 || response.status === 401) {
        logMessage(LogSeverity.ERROR, `API key error (${response.status}) for ${url}`);
        throw new Error(`Invalid Riot API key (${response.status})`);
      }
      
      // Other error, log and return null
      logMessage(LogSeverity.ERROR, `Error fetching ${url}: ${response.status}`);
      return null;
    } catch (error) {
      if ((error as Error).name === 'AbortError') {
        logMessage(LogSeverity.ERROR, `Request timeout for ${url}, retry ${retries + 1}/${maxRetries}`);
      } else {
        logMessage(LogSeverity.ERROR, `Failed to fetch ${url}:`, error);
      }
      
      // Implement exponential backoff
      await new Promise(resolve => setTimeout(resolve, Math.pow(2, retries) * baseDelay));
      retries++;
    }
  }
  
  logMessage(LogSeverity.ERROR, `Max retries (${maxRetries}) exceeded for ${url}`);
  return null;
};

// Define interface for league entries and summoners
interface LeagueEntry {
  summonerId: string;
  leaguePoints: number;
}

interface League {
  entries: LeagueEntry[];
}

interface Summoner {
  puuid: string;
  id: string;
}

// Process one region with rate limiting and better error handling
export const processRegion = async (regionKey: RegionKey, matchesPerRegion: number = 100): Promise<ProcessedMatch[]> => {
  // Updated to limit matches per region to 5 for initial implementation
  const API = getApiEndpoints(regionKey);
  if (!API) return [];
  
  logMessage(LogSeverity.INFO, `Processing region ${regionKey}...`);
  
  try {
    // Update region status to processing
    await updateRegionStatus(regionKey, 'processing');
    
    // Fetch master league - can request more players now
    const league = await fetchWithApiKey(API.master, { 
      maxRetries: 3, 
      timeout: 15000 
    }) as League | null;
    
    if (!league?.entries?.length) {
      logMessage(LogSeverity.WARN, `No league data for ${regionKey}`);
      await updateRegionStatus(regionKey, 'degraded', 'No league data available');
      return [];
    }
    
    // Get top players - increased from 4 to 10 for more data sources
    const players = league.entries
      .sort((a, b) => b.leaguePoints - a.leaguePoints)
      .slice(0, 10);
    
    if (!players.length) {
      logMessage(LogSeverity.WARN, `No players found for ${regionKey}`);
      await updateRegionStatus(regionKey, 'degraded', 'No players found');
      return [];
    }
    
    // Fetch summoner data concurrently with proper rate limiting
    const summonerPromises = players.map(p => 
      fetchWithApiKey(API.summoner(p.summonerId), { 
        timeout: 8000, 
        maxRetries: 2 
      })
    );
    
    const summoners = (await Promise.all(summonerPromises)).filter(Boolean) as Summoner[];
    
    if (!summoners.length) {
      logMessage(LogSeverity.WARN, `No summoner data for ${regionKey}`);
      await updateRegionStatus(regionKey, 'degraded', 'No summoner data available');
      return [];
    }
    
    // Fetch match lists with higher batch size
    const matchListPromises: Promise<string[]>[] = [];
    
    for (const summoner of summoners) {
      // Increased from 20 to 100 matches per player
      matchListPromises.push(
        fetchWithApiKey(API.matches(summoner.puuid), {
          timeout: 15000,
          maxRetries: 2
        })
      );
    }
    
    const matchLists = (await Promise.all(matchListPromises)).filter(Boolean) as string[][];
    
    // Get unique match IDs, limited to 5 per region as requested
    const allMatchIds = matchLists.flat();
    const uniqueMatches = [...new Set(allMatchIds)].slice(0, matchesPerRegion);
    
    if (!uniqueMatches.length) {
      logMessage(LogSeverity.WARN, `No matches found for ${regionKey}`);
      await updateRegionStatus(regionKey, 'degraded', 'No matches found');
      return [];
    }
    
    logMessage(LogSeverity.INFO, `Fetching ${uniqueMatches.length} matches for ${regionKey}...`);
    
    // Fetch match details with increased batch size and parallelism
    const matches: any[] = [];
    const batchSize = 5; // Reduced from 10 to 5 since we only need 5 total matches
    
    for (let i = 0; i < uniqueMatches.length; i += batchSize) {
      const batchIds = uniqueMatches.slice(i, i + batchSize);
      const batchPromises = batchIds.map(id => 
        fetchWithApiKey(API.matchDetails(id), {
          timeout: 8000,
          maxRetries: 2
        })
      );
      
      const batchResults = await Promise.all(batchPromises);
      const validResults = batchResults.filter(Boolean);
      matches.push(...validResults);
      
      // Add a small delay between batches to avoid rate limit spikes
      if (i + batchSize < uniqueMatches.length) {
        await new Promise(resolve => setTimeout(resolve, 100));
      }
      
      // Save each match to database
      for (let j = 0; j < validResults.length; j++) {
        const match = validResults[j];
        if (match && match.metadata?.match_id) {
          await saveMatch(match.metadata.match_id, regionKey, match);
        }
      }
    }
    
    // Update region status to active
    await updateRegionStatus(regionKey, 'active');
    
    // Process match data
    return matches.map(match => ({
      id: match.metadata.match_id,
      region: regionKey,
      participants: match.info.participants.map((p: any) => ({
        placement: p.placement,
        units: p.units.map((u: any) => ({
          name: u.character_id,
          itemNames: u.itemNames || []
        })),
        traits: p.traits
          .filter((t: any) => t.style > 0)
          .map((t: any) => ({
            name: t.name,
            tier_current: t.style,
            num_units: t.num_units
          }))
      }))
    }));
  } catch (error) {
    logMessage(LogSeverity.ERROR, `Error processing region ${regionKey}:`, error);
    // Update region status to error
    await updateRegionStatus(
      regionKey, 
      'error', 
      error instanceof Error ? error.message : 'Unknown error'
    );
    return [];
  }
};
EOL

# Create logger utility for improved debugging
cat > src/utils/logger.ts << 'EOL'
export enum LogSeverity {
  INFO = 'info',
  WARN = 'warn',
  ERROR = 'error',
  DEBUG = 'debug'
}

export function logMessage(severity: LogSeverity, message: string, data?: any): void {
  const timestamp = new Date().toISOString();
  const logEntry = `[${timestamp}] [${severity.toUpperCase()}] ${message}`;
  
  switch (severity) {
    case LogSeverity.ERROR:
      if (data) {
        console.error(logEntry, data);
      } else {
        console.error(logEntry);
      }
      break;
    case LogSeverity.WARN:
      if (data) {
        console.warn(logEntry, data);
      } else {
        console.warn(logEntry);
      }
      break;
    case LogSeverity.DEBUG:
      if (process.env.NODE_ENV === 'development') {
        if (data) {
          console.log(logEntry, data);
        } else {
          console.log(logEntry);
        }
      }
      break;
    default:
      if (data) {
        console.log(logEntry, data);
      } else {
        console.log(logEntry);
      }
  }
}
EOL

# Update the refresh-data.ts file with parallel continent processing
cat > src/pages/api/cron/refresh-data.ts << 'EOL'
import type { NextApiRequest, NextApiResponse } from 'next';
import { processMatchData } from '@/utils/dataProcessing';
import { initializeDatabase, saveStats, cleanupOldData } from '@/utils/db';
import { sanitizeForDatabase } from '@/utils/db/sanitizeData';
import { logMessage, LogSeverity } from '@/utils/logger';
import { processAllContinentsInParallel } from '@/utils/continentFetcher';
import _ from 'lodash';
import { Composition, ProcessedItem, ProcessedTrait, ProcessedUnit, ProcessedMatch } from '@/types';

// Ensure API key doesn't expire during execution
export const config = {
  maxDuration: 300, // 5 minutes
};

// Extract and process units from compositions for separate storage
function extractUnits(compositions: Composition[]): ProcessedUnit[] {
  logMessage(LogSeverity.INFO, `Extracting units from ${compositions.length} compositions`);
  
  // Create a map to deduplicate units by ID
  const unitMap: Record<string, ProcessedUnit & {
    weightedPlacementSum?: number;
    weightedWinRateSum?: number;
    weightedTop4RateSum?: number;
  }> = {};
  
  compositions.forEach(composition => {
    (composition.units || []).forEach(unit => {
      if (!unit.id || !unit.name) return;
      
      // Initialize unit if not already in map
      if (!unitMap[unit.id]) {
        unitMap[unit.id] = {
          id: unit.id,
          name: unit.name,
          icon: unit.icon,
          cost: unit.cost || 0,
          count: 0,
          avgPlacement: 0,
          winRate: 0,
          top4Rate: 0,
          playRate: 0,
          totalGames: 0,
          relatedComps: [],
          traits: unit.traits,
          bestItems: unit.bestItems || [],
          // Track weighted sums for accurate statistics
          weightedPlacementSum: 0,
          weightedWinRateSum: 0,
          weightedTop4RateSum: 0,
          stats: {
            count: 0,
            avgPlacement: 0,
            winRate: 0,
            top4Rate: 0
          }
        };
      }
      
      // Get composition weight (either its count or default to 1)
      const compWeight = composition.count || 1;
      
      // Update counts - incrementing by composition weight with safe access
      const existingUnit = unitMap[unit.id];
      existingUnit.count = (existingUnit.count || 0) + compWeight;
      existingUnit.totalGames = (existingUnit.totalGames || 0) + compWeight;
      
      // Add weighted stats using composition weight with safe access
      existingUnit.weightedPlacementSum = (existingUnit.weightedPlacementSum || 0) + 
        (composition.avgPlacement || 0) * compWeight;
      existingUnit.weightedWinRateSum = (existingUnit.weightedWinRateSum || 0) + 
        (composition.winRate || 0) * compWeight;
      existingUnit.weightedTop4RateSum = (existingUnit.weightedTop4RateSum || 0) + 
        (composition.top4Rate || 0) * compWeight;
      
      // Add composition to relatedComps if not already present
      if (!existingUnit.relatedComps?.find(comp => comp.id === composition.id)) {
        // Create a trimmed composition reference to avoid circular references
        const trimmedComp = {
          id: composition.id,
          name: composition.name,
          icon: composition.icon,
          avgPlacement: composition.avgPlacement,
          winRate: composition.winRate,
          top4Rate: composition.top4Rate,
          count: composition.count,
          traits: [], // Add empty traits array to satisfy the Composition type
          units: []   // Add empty units array to satisfy the Composition type
        };
        existingUnit.relatedComps = [...(existingUnit.relatedComps || []), trimmedComp];
      }
    });
  });
  
  // Calculate play rate and update stats object
  const totalComps = compositions.reduce((sum, comp) => sum + (comp.count || 1), 0);
  const units = Object.values(unitMap).map(unit => {
    // Calculate final averages based on weight
    const totalWeight = unit.count || 1;
    unit.avgPlacement = (unit.weightedPlacementSum || 0) / totalWeight;
    unit.winRate = (unit.weightedWinRateSum || 0) / totalWeight;
    unit.top4Rate = (unit.weightedTop4RateSum || 0) / totalWeight;
    
    // Update stats object for consistency
    unit.stats = {
      count: unit.count || 0,
      avgPlacement: unit.avgPlacement,
      winRate: unit.winRate,
      top4Rate: unit.top4Rate
    };
    
    // Clean up temporary properties
    const { weightedPlacementSum, weightedWinRateSum, weightedTop4RateSum, ...cleanUnit } = unit;
    
    // Set playRate
    cleanUnit.playRate = ((cleanUnit.count || 0) / totalComps) * 100;
    
    return cleanUnit;
  });
  
  logMessage(LogSeverity.INFO, `Extracted ${units.length} units from compositions`);
  return units;
}

// Extract and process traits from compositions for separate storage
function extractTraits(compositions: Composition[]): ProcessedTrait[] {
  logMessage(LogSeverity.INFO, `Extracting traits from ${compositions.length} compositions`);
  
  // Create a map to deduplicate traits by ID
  const traitMap: Record<string, ProcessedTrait & {
    weightedPlacementSum?: number;
    weightedWinRateSum?: number;
    weightedTop4RateSum?: number;
  }> = {};
  
  compositions.forEach(composition => {
    (composition.traits || []).forEach(trait => {
      if (!trait.id || !trait.name) return;
      
      // Create key with ID and tier
      const key = `${trait.id}_${trait.tier || 0}`;
      
      // Initialize trait if not already in map
      if (!traitMap[key]) {
        traitMap[key] = {
          id: trait.id,
          name: trait.name,
          icon: trait.icon,
          tier: trait.tier || 0,
          numUnits: trait.numUnits || 0,
          tierIcon: trait.tierIcon,
          count: 0,
          avgPlacement: 0,
          winRate: 0,
          top4Rate: 0,
          playRate: 0,
          totalGames: 0,
          relatedComps: [],
          weightedPlacementSum: 0,
          weightedWinRateSum: 0,
          weightedTop4RateSum: 0,
          stats: {
            count: 0,
            avgPlacement: 0,
            winRate: 0,
            top4Rate: 0
          }
        };
      }
      
      // Get composition weight (either its count or default to 1)
      const compWeight = composition.count || 1;
      
      // Update counts with safe access
      const existingTrait = traitMap[key];
      existingTrait.count = (existingTrait.count || 0) + compWeight;
      existingTrait.totalGames = (existingTrait.totalGames || 0) + compWeight;
      
      // Add weighted stats using composition weight with safe access
      existingTrait.weightedPlacementSum = (existingTrait.weightedPlacementSum || 0) + 
        (composition.avgPlacement || 0) * compWeight;
      existingTrait.weightedWinRateSum = (existingTrait.weightedWinRateSum || 0) + 
        (composition.winRate || 0) * compWeight;
      existingTrait.weightedTop4RateSum = (existingTrait.weightedTop4RateSum || 0) + 
        (composition.top4Rate || 0) * compWeight;
      
      // Add composition to relatedComps if not already present
      if (!existingTrait.relatedComps?.find(comp => comp.id === composition.id)) {
        // Create a trimmed composition reference to avoid circular references
        const trimmedComp = {
          id: composition.id,
          name: composition.name,
          icon: composition.icon,
          avgPlacement: composition.avgPlacement,
          winRate: composition.winRate,
          top4Rate: composition.top4Rate,
          count: composition.count,
          traits: [], // Add empty traits array to satisfy the Composition type
          units: []   // Add empty units array to satisfy the Composition type
        };
        existingTrait.relatedComps = [...(existingTrait.relatedComps || []), trimmedComp];
      }
    });
  });
  
  // Calculate play rate and update stats object
  const totalTraits = Object.values(traitMap).reduce((sum: number, trait: any) => sum + (trait.count || 0), 0);
  const traits = Object.values(traitMap).map(trait => {
    // Calculate final averages based on weight
    const totalWeight = trait.count || 1;
    trait.avgPlacement = (trait.weightedPlacementSum || 0) / totalWeight;
    trait.winRate = (trait.weightedWinRateSum || 0) / totalWeight;
    trait.top4Rate = (trait.weightedTop4RateSum || 0) / totalWeight;
    
    // Update stats object for consistency
    trait.stats = {
      count: trait.count || 0,
      avgPlacement: trait.avgPlacement,
      winRate: trait.winRate,
      top4Rate: trait.top4Rate
    };
    
    // Clean up temporary properties
    const { weightedPlacementSum, weightedWinRateSum, weightedTop4RateSum, ...cleanTrait } = trait;
    
    // Set playRate
    cleanTrait.playRate = ((cleanTrait.count || 0) / totalTraits) * 100;
    
    return cleanTrait;
  });
  
  logMessage(LogSeverity.INFO, `Extracted ${traits.length} traits from compositions`);
  return traits;
}

// Extract and process items from compositions for separate storage
function extractItems(compositions: Composition[]): ProcessedItem[] {
  logMessage(LogSeverity.INFO, `Extracting items from ${compositions.length} compositions`);
  
  // First pass: collect all items and their stats
  const itemMap: Record<string, {
    basic: {
      id: string;
      name: string;
      icon: string;
      category?: string;
    };
    stats: {
      count: number;
      totalGames: number;
      placementSum: number;
      winRateSum: number;
      top4RateSum: number;
    };
    comps: Set<string>;
    units: Record<string, {
      id: string;
      name: string;
      icon: string;
      cost: number;
      count: number;
      winRateSum: number;
      placementSum: number;
      top4RateSum: number;
      totalGames: number;
      relatedComps: Set<string>;
    }>;
  }> = {};
  
  // First pass - collect basic data with proper accumulation
  compositions.forEach(comp => {
    comp.units.forEach(unit => {
      (unit.items || []).forEach(item => {
        if (!item.id || !item.name) return;
        
        // Create or get item entry
        if (!itemMap[item.id]) {
          itemMap[item.id] = {
            basic: {
              id: item.id,
              name: item.name,
              icon: item.icon,
              category: item.category
            },
            stats: {
              count: 0,
              totalGames: 0,
              placementSum: 0,
              winRateSum: 0,
              top4RateSum: 0
            },
            comps: new Set<string>(),
            units: {}
          };
        }
        
        // Get composition weight
        const compWeight = comp.count || 1;
        
        // Update stats with proper weighting
        const itemEntry = itemMap[item.id];
        itemEntry.stats.count++;
        itemEntry.stats.totalGames += compWeight;
        itemEntry.stats.placementSum += (comp.avgPlacement || 0) * compWeight;
        itemEntry.stats.winRateSum += (comp.winRate || 0) * compWeight;
        itemEntry.stats.top4RateSum += (comp.top4Rate || 0) * compWeight;
        
        // Add composition ID
        itemEntry.comps.add(comp.id);
        
        // Add or update unit with proper stats accumulation
        if (!itemEntry.units[unit.id]) {
          itemEntry.units[unit.id] = {
            id: unit.id,
            name: unit.name,
            icon: unit.icon,
            cost: unit.cost || 0,
            count: 0,
            winRateSum: 0,
            placementSum: 0,
            top4RateSum: 0,
            totalGames: 0,
            relatedComps: new Set<string>()
          };
        }
        
        // Update unit stats with proper weighted accumulation
        itemEntry.units[unit.id].count++;
        itemEntry.units[unit.id].totalGames += compWeight;
        itemEntry.units[unit.id].placementSum += (comp.avgPlacement || 0) * compWeight;
        itemEntry.units[unit.id].winRateSum += (comp.winRate || 0) * compWeight;
        itemEntry.units[unit.id].top4RateSum += (comp.top4Rate || 0) * compWeight;
        itemEntry.units[unit.id].relatedComps.add(comp.id);
      });
    });
  });
  
  // Create trimmed compositions for reference
  const trimmedComps: Record<string, any> = {};
  compositions.forEach(comp => {
    trimmedComps[comp.id] = {
      id: comp.id,
      name: comp.name,
      icon: comp.icon,
      avgPlacement: comp.avgPlacement,
      winRate: comp.winRate,
      top4Rate: comp.top4Rate,
      count: comp.count,
      stats: {
        count: comp.count || 0,
        avgPlacement: comp.avgPlacement || 0,
        winRate: comp.winRate || 0,
        top4Rate: comp.top4Rate || 0
      },
      traits: [], // Empty arrays to satisfy Composition type
      units: []
    };
  });
  
  // Second pass - build final items with proper stats structure
  const items: ProcessedItem[] = [];
  
  for (const [itemId, entry] of Object.entries(itemMap)) {
    // Calculate item averages with proper weighting
    const itemWeight = entry.stats.totalGames || 1;
    const avgPlacement = entry.stats.placementSum / itemWeight;
    const winRate = (entry.stats.winRateSum / itemWeight);
    const top4Rate = (entry.stats.top4RateSum / itemWeight);
    
    // Process units with this item - creating proper stats structure
    const unitsWithItem = Object.values(entry.units).map(unitData => {
      const unitWeight = unitData.totalGames || 1;
      
      return {
        id: unitData.id,
        name: unitData.name,
        icon: unitData.icon,
        cost: unitData.cost,
        count: unitData.count,
        winRate: (unitData.winRateSum / unitWeight),
        avgPlacement: unitData.placementSum / unitWeight,
        top4Rate: (unitData.top4RateSum / unitWeight),
        stats: {
          count: unitData.count,
          winRate: (unitData.winRateSum / unitWeight),
          avgPlacement: unitData.placementSum / unitWeight,
          top4Rate: (unitData.top4RateSum / unitWeight)
        },
        relatedComps: Array.from(unitData.relatedComps)
          .map(compId => trimmedComps[compId])
          .filter(Boolean)
      };
    }).sort((a, b) => b.winRate - a.winRate);
    
    // Build related compositions
    const relatedComps = Array.from(entry.comps)
      .map(compId => trimmedComps[compId])
      .filter(Boolean);
    
    // Build final item
    const processedItem: ProcessedItem = {
      id: itemId,
      name: entry.basic.name,
      icon: entry.basic.icon,
      category: entry.basic.category,
      count: entry.stats.count,
      avgPlacement,
      winRate,
      top4Rate,
      playRate: 0, // Will be calculated later
      totalGames: entry.stats.totalGames,
      stats: {
        count: entry.stats.count,
        avgPlacement,
        winRate,
        top4Rate
      },
      unitsWithItem,
      relatedComps
    };
    
    items.push(processedItem);
  }
  
  // Calculate play rates
  const totalCount = items.reduce((sum, item) => sum + (item.count || 0), 0) || 1;
  items.forEach(item => {
    item.playRate = ((item.count || 0) / totalCount) * 100;
  });
  
  logMessage(LogSeverity.INFO, `Extracted ${items.length} items from compositions`);
  return items;
}

// Package and save entities
async function saveEntityData(
  processedData: any, 
  region: string, 
  entityType: 'compositions' | 'units' | 'traits' | 'items'
): Promise<boolean> {
  try {
    if (!processedData) {
      logMessage(LogSeverity.ERROR, `No data to save for ${entityType}/${region}`);
      return false;
    }
    
    let entities: any[] = [];
    let summary: any = { totalGames: 0, avgPlacement: 0, topEntities: [] };
    
    // Extract the correct entities based on type
    if (entityType === 'compositions') {
      entities = processedData.compositions || [];
      summary = processedData.summary || { totalGames: 0, avgPlacement: 0, topComps: [], topEntities: [] };
      
      logMessage(LogSeverity.INFO, `Saving ${entities.length} compositions for ${region}`);
    } else if (entityType === 'units') {
      entities = extractUnits(processedData.compositions || []);
      summary = {
        totalGames: processedData.summary?.totalGames || 0,
        avgPlacement: processedData.summary?.avgPlacement || 0,
        topUnits: entities.slice(0, 5).sort((a, b) => (b.winRate || 0) - (a.winRate || 0))
      };
      
      logMessage(LogSeverity.INFO, `Saving ${entities.length} units for ${region}`);
    } else if (entityType === 'traits') {
      entities = extractTraits(processedData.compositions || []);
      summary = {
        totalGames: processedData.summary?.totalGames || 0,
        avgPlacement: processedData.summary?.avgPlacement || 0,
        topTraits: entities.slice(0, 5).sort((a, b) => (b.winRate || 0) - (a.winRate || 0))
      };
      
      logMessage(LogSeverity.INFO, `Saving ${entities.length} traits for ${region}`);
    } else if (entityType === 'items') {
      entities = extractItems(processedData.compositions || []);
      summary = {
        totalGames: processedData.summary?.totalGames || 0,
        avgPlacement: processedData.summary?.avgPlacement || 0,
        topItems: entities.slice(0, 5).sort((a, b) => (b.winRate || 0) - (a.winRate || 0))
      };
      
      logMessage(LogSeverity.INFO, `Saving ${entities.length} items for ${region}`);
    }
    
    // Skip if no entities to save
    if (!entities.length) {
      logMessage(LogSeverity.WARN, `No ${entityType} to save for ${region}`);
      return false;
    }
    
    // Sort entities by win rate
    entities = entities.sort((a, b) => (b.winRate || 0) - (a.winRate || 0));
    
    // Create data object based on entity type
    const dataObj: any = {
      region,
      summary
    };
    
    // Add entities to the appropriate field
    dataObj[entityType] = entities;
    
    // Sanitize data for database storage
    const sanitizedData = sanitizeForDatabase(dataObj);
    
    logMessage(LogSeverity.INFO, 
      `Sanitized ${entityType} data for ${region}: ${Math.round(JSON.stringify(sanitizedData).length / 1024)}KB`);
    
    // Save to database
    return await saveStats(entityType, region, sanitizedData);
  } catch (error) {
    logMessage(LogSeverity.ERROR, `Failed to save ${entityType} data for ${region}:`, error);
    return false;
  }
}

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  // Verify cron secret for security
  if (req.headers.authorization !== `Bearer ${process.env.CRON_SECRET}`) {
    return res.status(401).json({ error: 'Unauthorized' });
  }

  try {
    logMessage(LogSeverity.INFO, 'Starting data refresh job with parallel continent processing');
    
    // Initialize database if needed
    await initializeDatabase();
    
    // Process all regions in parallel by continent
    // Use the specified n matches per region
    const allMatches: ProcessedMatch[] = await processAllContinentsInParallel(100);
    
    // Skip global processing if insufficient matches
    if (allMatches.length < 20) {
      logMessage(LogSeverity.WARN, 'Insufficient total matches, skipping global stats processing');
      return res.status(200).json({ 
        success: true,
        message: 'Job completed, but insufficient matches for global stats',
        matchCount: allMatches.length
      });
    }
    
    // Process and save global data for all entity types
    logMessage(LogSeverity.INFO, `Processing ${allMatches.length} matches for global data`);
    const globalData = processMatchData(allMatches, 'all');
    
    if (!globalData || !globalData.compositions || globalData.compositions.length === 0) {
      logMessage(LogSeverity.WARN, 'No global compositions generated, skipping');
      return res.status(200).json({
        success: true,
        message: 'Job completed but no global compositions generated',
        matchCount: allMatches.length
      });
    }
    
    logMessage(LogSeverity.INFO, 
      `Processed ${globalData.compositions.length} global compositions`);
    
    // Save all entity types from the global data
    await saveEntityData(globalData, 'all', 'compositions');
    await saveEntityData(globalData, 'all', 'units');
    await saveEntityData(globalData, 'all', 'traits');
    await saveEntityData(globalData, 'all', 'items');
    
    // Now also process individual regions in parallel
    const regionProcessingPromises = _.groupBy(allMatches, 'region');
    const regionProcessingResults = [];
    
    // Process each region separately - can be done in parallel since we're only processing data
    for (const [region, matches] of Object.entries(regionProcessingPromises)) {
      if (matches.length < 1) {
        logMessage(LogSeverity.WARN, `Insufficient matches for ${region}, skipping stats processing`);
        continue;
      }
      
      // Process data for this region
      logMessage(LogSeverity.INFO, `Processing ${matches.length} matches for ${region}`);
      const regionData = processMatchData(matches, region);
      
      if (!regionData || !regionData.compositions || regionData.compositions.length === 0) {
        logMessage(LogSeverity.WARN, `No compositions generated for ${region}, skipping`);
        continue;
      }
      
      logMessage(LogSeverity.INFO, 
        `Processed ${regionData.compositions.length} compositions for ${region}`);
      
      // Save all entity types for this region
      await saveEntityData(regionData, region, 'compositions');
      await saveEntityData(regionData, region, 'units');
      await saveEntityData(regionData, region, 'traits');
      await saveEntityData(regionData, region, 'items');
      
      regionProcessingResults.push({
        region,
        compositions: regionData.compositions.length,
        matchCount: matches.length
      });
    }
    
    // Clean up old data
    await cleanupOldData(7); // Keep data for 7 days
    
    logMessage(LogSeverity.INFO, `Data refresh completed: ${allMatches.length} total matches`);
    
    return res.status(200).json({ 
      success: true,
      matchCount: allMatches.length,
      regionsProcessed: regionProcessingResults
    });
  } catch (error) {
    logMessage(LogSeverity.ERROR, 'Cron job error', error);
    return res.status(500).json({ 
      error: error instanceof Error ? error.message : 'Unknown error' 
    });
  }
}
EOL

# Create the core ContinentFetcher utility
cat > src/utils/continentFetcher/index.ts << 'EOL'
/**
 * ContinentFetcher - Parallel API fetch architecture for TFT data
 * 
 * This module enables parallel fetching across continents while maintaining
 * sequential fetching within regions of the same continent to respect
 * rate limits while maximizing throughput.
 */
import { processRegion, REGIONS_BY_CONTINENT, RegionKey } from '@/utils/api';
import { updateRegionStatus } from '@/utils/db';
import { logMessage, LogSeverity } from '@/utils/logger';
import { ProcessedMatch } from '@/types';

// Define continent processing function type
export type ContinentProcessor = (regions: RegionKey[], matchesPerRegion: number) => Promise<ProcessedMatch[]>;

/**
 * Process all regions within a continent sequentially
 * Respects rate limits by processing one region at a time
 */
export const processContinent: ContinentProcessor = async (regions, matchesPerRegion) => {
  const results: ProcessedMatch[] = [];
  
  // Process each region in the continent sequentially
  for (const region of regions) {
    try {
      logMessage(LogSeverity.INFO, `Processing ${region} in continent group`);
      
      // Process the region and add results - limited to 5 matches per region
      const regionMatches = await processRegion(region, matchesPerRegion);
      results.push(...regionMatches);
      
      // Short delay between regions to avoid potential rate limit issues
      if (regions.indexOf(region) < regions.length - 1) {
        await new Promise(resolve => setTimeout(resolve, 200));
      }
    } catch (error) {
      // Log error but continue with next region
      logMessage(LogSeverity.ERROR, `Failed to process ${region} in continent`, error);
      
      // Update region status to error
      await updateRegionStatus(
        region, 
        'error', 
        error instanceof Error ? error.message : 'Unknown error during continent processing'
      );
    }
  }
  
  return results;
};

/**
 * Process multiple continents in parallel
 * This is the main entry point for the parallel API fetch architecture
 */
export const processAllContinentsInParallel = async (matchesPerRegion: number = 5): Promise<ProcessedMatch[]> => {
  logMessage(LogSeverity.INFO, `Starting parallel continent processing with ${matchesPerRegion} matches per region`);
  
  // Create processors for each continent
  const continentProcessors = Object.entries(REGIONS_BY_CONTINENT).map(
    ([continent, regions]) => {
      logMessage(LogSeverity.INFO, `Setting up processor for ${continent} with regions: ${regions.join(', ')}`);
      return processContinent(regions, matchesPerRegion);
    }
  );
  
  try {
    // Process all continents in parallel
    const continentResults = await Promise.all(continentProcessors);
    
    // Flatten results - this ensures we return an array of ProcessedMatch objects
    const allMatches: ProcessedMatch[] = continentResults.flat();
    
    logMessage(
      LogSeverity.INFO, 
      `Parallel processing complete: ${allMatches.length} total matches across all continents`
    );
    
    return allMatches;
  } catch (error) {
    logMessage(LogSeverity.ERROR, 'Error in parallel continent processing', error);
    
    // Return empty array on failure - individual errors are already handled
    return [];
  }
};

// Export the main processor
export default processAllContinentsInParallel;
EOL

# Create the completely reworked database utility
cat > src/utils/db/index.ts << 'EOL'
import { Pool, QueryResult, QueryResultRow } from 'pg';
import { LogSeverity, logMessage } from '../logger';
import { sanitizeForDatabase } from './sanitizeData';

/**
 * Improved database connection pool with robust error handling
 */
class DbPool {
  private static instance: Pool | null = null;
  private static connectionAttempts = 0;
  private static readonly MAX_ATTEMPTS = 3;
  
  /**
   * Get the database pool instance with proper initialization
   */
  public static getPool(): Pool {
    if (!DbPool.instance) {
      // Check environment variables
      if (!process.env.NEON_DATABASE_URL) {
        logMessage(LogSeverity.ERROR, 'NEON_DATABASE_URL environment variable not set');
        throw new Error('Database connection string not found in environment');
      }
      
      try {
        DbPool.instance = new Pool({
          connectionString: process.env.NEON_DATABASE_URL,
          ssl: {
            rejectUnauthorized: false
          },
          max: 10, // Maximum connections in pool
          idleTimeoutMillis: 30000, // Close idle clients after 30 seconds
          connectionTimeoutMillis: 10000, // Connection timeout after 10 seconds
        });
        
        // Set up event listeners
        DbPool.instance.on('error', (err) => {
          logMessage(LogSeverity.ERROR, 'Unexpected database pool error', err);
          
          // Reset pool on fatal error
          if (DbPool.connectionAttempts < DbPool.MAX_ATTEMPTS) {
            DbPool.instance = null;
            DbPool.connectionAttempts++;
            logMessage(LogSeverity.WARN, 
              `Attempting to recover pool (attempt ${DbPool.connectionAttempts}/${DbPool.MAX_ATTEMPTS})`);
          }
        });
        
        // Reset connection attempts on success
        DbPool.connectionAttempts = 0;
        
        logMessage(LogSeverity.INFO, 'Database pool created successfully');
      } catch (err) {
        logMessage(LogSeverity.ERROR, 'Failed to create database pool', err);
        throw err;
      }
    }
    
    return DbPool.instance;
  }
  
  /**
   * Cleanly end the pool
   */
  public static async end(): Promise<void> {
    if (DbPool.instance) {
      await DbPool.instance.end();
      DbPool.instance = null;
      logMessage(LogSeverity.INFO, 'Database pool has been closed');
    }
  }
}

/**
 * Execute a SQL query with enhanced logging and error handling
 */
export async function query<T extends QueryResultRow = any>(
  text: string, 
  params: any[] = [],
  label?: string
): Promise<QueryResult<T>> {
  const start = Date.now();
  const queryLabel = label || text.slice(0, 40).replace(/\s+/g, ' ');
  
  try {
    const pool = DbPool.getPool();
    const result = await pool.query<T>(text, params);
    
    // Performance logging for slow queries
    const duration = Date.now() - start;
    if (duration > 1000) {
      logMessage(
        LogSeverity.WARN, 
        `Slow query (${duration}ms): ${queryLabel}`, 
        { rowCount: result.rowCount }
      );
    }
    
    return result;
  } catch (error: any) {
    logMessage(
      LogSeverity.ERROR,
      `Database query failed: ${queryLabel}`,
      { error: error.message, params: params.slice(0, 3) }
    );
    
    if (error.code === 'ECONNREFUSED' || error.code === 'ETIMEDOUT') {
      logMessage(LogSeverity.ERROR, 'Database connection failed, resetting pool');
      DbPool.getPool(); // This will reset the pool due to the error handling
    }
    
    throw error;
  }
}

/**
 * Initialize the database schema - completely rewritten
 */
export async function initializeDatabase(): Promise<boolean> {
  try {
    logMessage(LogSeverity.INFO, 'Initializing database schema');
    
    // Check if tables exist first
    const tablesExist = await query(`
      SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' AND table_name = 'stats'
      )
    `);
    
    // If tables already exist, skip recreation
    if (tablesExist.rows[0].exists) {
      logMessage(LogSeverity.INFO, 'Database schema already exists, skipping initialization');
      return true;
    }
    
    // Create matches table
    await query(`
      CREATE TABLE IF NOT EXISTS matches (
        id SERIAL PRIMARY KEY,
        match_id TEXT UNIQUE NOT NULL,
        region TEXT NOT NULL,
        data JSONB NOT NULL,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      )
    `, [], 'createMatchesTable');
    
    // Create stats table
    await query(`
      CREATE TABLE IF NOT EXISTS stats (
        id SERIAL PRIMARY KEY,
        type TEXT NOT NULL,
        region TEXT NOT NULL,
        data JSONB NOT NULL,
        version TEXT NOT NULL DEFAULT '1.0',
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      )
    `, [], 'createStatsTable');
    
    // Create region status table
    await query(`
      CREATE TABLE IF NOT EXISTS region_status (
        region TEXT PRIMARY KEY,
        status TEXT NOT NULL DEFAULT 'active',
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        error_count INTEGER DEFAULT 0,
        last_error TEXT
      )
    `, [], 'createRegionStatusTable');
    
    // Create optimal indexes
    await query(`
      CREATE INDEX IF NOT EXISTS idx_matches_region ON matches(region);
      CREATE INDEX IF NOT EXISTS idx_matches_created_at ON matches(created_at DESC);
      CREATE INDEX IF NOT EXISTS idx_stats_type_region ON stats(type, region);
      CREATE INDEX IF NOT EXISTS idx_stats_created_at ON stats(created_at DESC);
      CREATE INDEX IF NOT EXISTS idx_stats_gin ON stats USING GIN (data jsonb_path_ops);
    `, [], 'createIndexes');
    
    logMessage(LogSeverity.INFO, 'Database schema initialized successfully');
    return true;
  } catch (error) {
    logMessage(LogSeverity.ERROR, 'Failed to initialize database schema', error);
    return false;
  }
}

/**
 * Save match data to the database
 */
export async function saveMatch(matchId: string, region: string, data: any): Promise<boolean> {
  try {
    await query(
      'INSERT INTO matches (match_id, region, data) VALUES ($1, $2, $3) ON CONFLICT (match_id) DO NOTHING',
      [matchId, region, JSON.stringify(data)],
      'saveMatch'
    );
    return true;
  } catch (error) {
    logMessage(LogSeverity.ERROR, `Failed to save match: ${matchId}`, error);
    return false;
  }
}

/**
 * Get all matches from the database, optionally filtered by region
 */
export async function getMatches(region?: string): Promise<any[]> {
  try {
    let result;
    if (region && region !== 'all') {
      result = await query(
        'SELECT data FROM matches WHERE region = $1 ORDER BY created_at DESC',
        [region],
        'getMatchesByRegion'
      );
    } else {
      result = await query(
        'SELECT data FROM matches ORDER BY created_at DESC',
        [],
        'getAllMatches'
      );
    }
    return result.rows.map(row => row.data);
  } catch (error) {
    logMessage(LogSeverity.ERROR, 'Failed to get matches', error);
    return [];
  }
}

/**
 * Save processed statistics to the database
 */
export async function saveStats(type: string, region: string, data: any): Promise<boolean> {
  try {
    // Log data statistics to help with debugging
    let dataSize = 0;
    let entityCount = 0;
    
    if (data) {
      dataSize = JSON.stringify(data).length;
      
      // Count entities based on type
      if (type === 'compositions' && data.compositions) {
        entityCount = data.compositions.length;
      } else if (type === 'units' && data.units) {
        entityCount = data.units.length;
      } else if (type === 'traits' && data.traits) {
        entityCount = data.traits.length;
      } else if (type === 'items' && data.items) {
        entityCount = data.items.length;
      }
    }
    
    logMessage(LogSeverity.INFO, 
      `Saving ${type} data for ${region}: ${entityCount} entities, ${Math.round(dataSize / 1024)}KB`
    );
    
    await query(
      'INSERT INTO stats (type, region, data) VALUES ($1, $2, $3)',
      [type, region, JSON.stringify(data)],
      'saveStats'
    );
    
    logMessage(LogSeverity.INFO, `Successfully saved ${type} data for ${region}`);
    return true;
  } catch (error) {
    logMessage(LogSeverity.ERROR, `Failed to save stats: ${type}/${region}`, error);
    return false;
  }
}

/**
 * Get the latest statistics from the database
 */
export async function getStats(type: string, region: string = 'all'): Promise<any> {
  try {
    const result = await query(
      'SELECT data FROM stats WHERE type = $1 AND region = $2 ORDER BY created_at DESC LIMIT 1',
      [type, region],
      'getStats'
    );
    
    if (result.rows.length === 0) {
      logMessage(LogSeverity.INFO, `No stats found for ${type}/${region}`);
      return null;
    }
    
    return result.rows[0].data;
  } catch (error) {
    logMessage(LogSeverity.ERROR, `Failed to get stats: ${type}/${region}`, error);
    return null;
  }
}

/**
 * Update region status
 */
export async function updateRegionStatus(
  region: string, 
  status: string, 
  errorMessage?: string
): Promise<boolean> {
  try {
    if (status === 'error' && errorMessage) {
      await query(
        `INSERT INTO region_status (region, status, updated_at, error_count, last_error) 
         VALUES ($1, $2, NOW(), 1, $3) 
         ON CONFLICT (region) DO UPDATE 
         SET status = $2, 
             updated_at = NOW(), 
             error_count = region_status.error_count + 1, 
             last_error = $3`,
        [region, status, errorMessage],
        'updateRegionStatusWithError'
      );
    } else {
      await query(
        `INSERT INTO region_status (region, status, updated_at) 
         VALUES ($1, $2, NOW()) 
         ON CONFLICT (region) DO UPDATE 
         SET status = $2, 
             updated_at = NOW()`,
        [region, status],
        'updateRegionStatus'
      );
    }
    return true;
  } catch (error) {
    logMessage(LogSeverity.ERROR, `Failed to update region status: ${region}`, error);
    return false;
  }
}

/**
 * Get all region statuses
 */
export async function getRegionStatuses(): Promise<any[]> {
  try {
    const result = await query(
      'SELECT * FROM region_status',
      [],
      'getRegionStatuses'
    );
    return result.rows;
  } catch (error) {
    logMessage(LogSeverity.ERROR, 'Failed to get region statuses', error);
    return [];
  }
}

/**
 * Clean up old data
 */
export async function cleanupOldData(daysToKeep: number = 7): Promise<boolean> {
  try {
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - daysToKeep);
    
    await query(
      'DELETE FROM matches WHERE created_at < $1',
      [cutoffDate],
      'cleanupOldMatches'
    );
    
    // Keep only the latest stats for each type/region
    await query(`
      DELETE FROM stats WHERE id NOT IN (
        SELECT id FROM (
          SELECT id, 
                 ROW_NUMBER() OVER (PARTITION BY type, region ORDER BY created_at DESC) as row_num 
          FROM stats
        ) t 
        WHERE t.row_num <= 2
      )
    `, [], 'cleanupOldStats');
    
    return true;
  } catch (error) {
    logMessage(LogSeverity.ERROR, 'Failed to clean up old data', error);
    return false;
  }
}

/**
 * Insert sample data for initial setup
 */
export async function insertSampleData(): Promise<boolean> {
  try {
    logMessage(LogSeverity.INFO, 'Inserting sample data');
    
    const regions = ['all', 'NA', 'EUW', 'KR', 'BR', 'JP'];
    
    // Create minimal sample data for all entity types
    const sampleComposition = {
      id: 'sample-comp',
      name: 'Sample Composition',
      icon: '/assets/app/default.png',
      count: 1,
      avgPlacement: 4.5,
      winRate: 25,
      top4Rate: 50,
      traits: [],
      units: []
    };
    
    const sampleUnit = {
      id: 'sample-unit',
      name: 'Sample Unit',
      icon: '/assets/app/default.png',
      cost: 3,
      count: 1,
      avgPlacement: 4.5,
      winRate: 25,
      top4Rate: 50,
      stats: {
        count: 1,
        avgPlacement: 4.5,
        winRate: 25,
        top4Rate: 50
      }
    };
    
    const sampleTrait = {
      id: 'sample-trait',
      name: 'Sample Trait',
      icon: '/assets/app/default.png',
      tier: 2,
      numUnits: 4,
      count: 1,
      avgPlacement: 4.5,
      winRate: 25,
      top4Rate: 50,
      stats: {
        count: 1,
        avgPlacement: 4.5,
        winRate: 25,
        top4Rate: 50
      }
    };
    
    const sampleItem = {
      id: 'sample-item',
      name: 'Sample Item',
      icon: '/assets/app/default.png',
      category: 'completed',
      count: 1,
      avgPlacement: 4.5,
      winRate: 25,
      top4Rate: 50,
      stats: {
        count: 1,
        avgPlacement: 4.5,
        winRate: 25,
        top4Rate: 50
      }
    };
    
    // Sample data for each entity type
    const compositionsData = {
      compositions: [sampleComposition],
      summary: { 
        totalGames: 1, 
        avgPlacement: 4.5, 
        topComps: [sampleComposition]
      },
      region: 'all'
    };
    
    const unitsData = {
      units: [sampleUnit],
      summary: { 
        totalGames: 1, 
        avgPlacement: 4.5, 
        topUnits: [sampleUnit]
      },
      region: 'all'
    };
    
    const traitsData = {
      traits: [sampleTrait],
      summary: { 
        totalGames: 1, 
        avgPlacement: 4.5, 
        topTraits: [sampleTrait]
      },
      region: 'all'
    };
    
    const itemsData = {
      items: [sampleItem],
      summary: { 
        totalGames: 1, 
        avgPlacement: 4.5, 
        topItems: [sampleItem]
      },
      region: 'all'
    };
    
    // Insert data for all regions and entity types
    for (const region of regions) {
      compositionsData.region = region;
      unitsData.region = region;
      traitsData.region = region;
      itemsData.region = region;
      
      await saveStats('compositions', region, compositionsData);
      await saveStats('units', region, unitsData);
      await saveStats('traits', region, traitsData);
      await saveStats('items', region, itemsData);
      
      // Add region status
      await updateRegionStatus(region, 'active');
    }
    
    logMessage(LogSeverity.INFO, 'Sample data inserted successfully for all regions and entity types');
    return true;
  } catch (error) {
    logMessage(LogSeverity.ERROR, 'Failed to insert sample data', error);
    return false;
  }
}

// Export sanitizeForDatabase function
export { sanitizeForDatabase };
EOL

# Create sanitizeData.ts
cat > src/utils/db/sanitizeData.ts << 'EOL'
// Function to safely sanitize data for database storage
export function sanitizeForDatabase(data: any): any {
  if (!data) return { compositions: [], units: [], traits: [], items: [] };
  
  try {
    // Create completely new objects instead of trying to sanitize existing ones
    const sanitized: any = {
      region: data.region || 'unknown',
      summary: {
        totalGames: data.summary?.totalGames || 0,
        avgPlacement: data.summary?.avgPlacement || 0
      },
      compositions: [],
      units: [],
      traits: [],
      items: []
    };
    
    // Add top entities to summary if they exist
    if (data.summary?.topComps) sanitized.summary.topComps = [];
    if (data.summary?.topUnits) sanitized.summary.topUnits = [];
    if (data.summary?.topTraits) sanitized.summary.topTraits = [];
    if (data.summary?.topItems) sanitized.summary.topItems = [];
    
    // Add compositions if they exist
    if (data.compositions && Array.isArray(data.compositions)) {
      sanitized.compositions = data.compositions.map((comp: any) => {
        if (!comp) return null;
        
        return {
          id: comp.id || 'unknown',
          name: comp.name || 'Unknown Composition',
          icon: comp.icon || '',
          count: comp.count || 0,
          avgPlacement: comp.avgPlacement || 0,
          winRate: comp.winRate || 0,
          top4Rate: comp.top4Rate || 0,
          playRate: comp.playRate || 0,
          stats: {
            count: comp.count || comp.stats?.count || 0,
            avgPlacement: comp.avgPlacement || comp.stats?.avgPlacement || 0,
            winRate: comp.winRate || comp.stats?.winRate || 0,
            top4Rate: comp.top4Rate || comp.stats?.top4Rate || 0
          },
          traits: Array.isArray(comp.traits) ? comp.traits.map((trait: any) => ({
            id: trait.id || 'unknown',
            name: trait.name || 'Unknown Trait',
            icon: trait.icon || '',
            tier: trait.tier || 0,
            numUnits: trait.numUnits || 0,
            tierIcon: trait.tierIcon || '',
            stats: {
              count: trait.count || trait.stats?.count || 0,
              avgPlacement: trait.avgPlacement || trait.stats?.avgPlacement || 0,
              winRate: trait.winRate || trait.stats?.winRate || 0,
              top4Rate: trait.top4Rate || trait.stats?.top4Rate || 0
            }
          })) : [],
          units: Array.isArray(comp.units) ? comp.units.map((unit: any) => ({
            id: unit.id || 'unknown',
            name: unit.name || 'Unknown Unit',
            icon: unit.icon || '',
            cost: unit.cost || 0,
            count: unit.count || 0,
            stats: {
              count: unit.count || unit.stats?.count || 0,
              avgPlacement: unit.avgPlacement || unit.stats?.avgPlacement || 0,
              winRate: unit.winRate || unit.stats?.winRate || 0,
              top4Rate: unit.top4Rate || unit.stats?.top4Rate || 0
            },
            items: Array.isArray(unit.items) ? unit.items.map((item: any) => ({
              id: item.id || 'unknown',
              name: item.name || 'Unknown Item',
              icon: item.icon || '',
              category: item.category || 'unknown',
              stats: {
                count: item.count || item.stats?.count || 0,
                avgPlacement: item.avgPlacement || item.stats?.avgPlacement || 0,
                winRate: item.winRate || item.stats?.winRate || 0,
                top4Rate: item.top4Rate || item.stats?.top4Rate || 0
              }
            })) : []
          })) : []
        };
      }).filter(Boolean);
    }
    
    // Add units if they exist
    if (data.units && Array.isArray(data.units)) {
      sanitized.units = data.units.map((unit: any) => {
        if (!unit) return null;
        
        return {
          id: unit.id || 'unknown',
          name: unit.name || 'Unknown Unit',
          icon: unit.icon || '',
          cost: unit.cost || 0,
          count: unit.count || 0,
          avgPlacement: unit.avgPlacement || 0,
          winRate: unit.winRate || 0,
          top4Rate: unit.top4Rate || 0,
          playRate: unit.playRate || 0,
          stats: {
            count: unit.count || unit.stats?.count || 0,
            avgPlacement: unit.avgPlacement || unit.stats?.avgPlacement || 0,
            winRate: unit.winRate || unit.stats?.winRate || 0,
            top4Rate: unit.top4Rate || unit.stats?.top4Rate || 0
          },
          traits: unit.traits ? { ...unit.traits } : {},
          bestItems: Array.isArray(unit.bestItems) ? unit.bestItems.map((item: any) => ({
            id: item.id || 'unknown',
            name: item.name || 'Unknown Item',
            icon: item.icon || '',
            stats: item.stats ? { ...item.stats } : {
              count: item.count || 0,
              avgPlacement: item.avgPlacement || 0,
              winRate: item.winRate || 0,
              top4Rate: item.top4Rate || 0
            }
          })) : [],
          relatedComps: Array.isArray(unit.relatedComps) ? unit.relatedComps.map((comp: any) => ({
            id: comp.id || 'unknown',
            name: comp.name || 'Unknown Composition',
            icon: comp.icon || '',
            count: comp.count || 0,
            avgPlacement: comp.avgPlacement || 0,
            winRate: comp.winRate || 0,
            top4Rate: comp.top4Rate || 0,
            traits: [],
            units: []
          })) : []
        };
      }).filter(Boolean);
    }
    
    // Add traits if they exist
    if (data.traits && Array.isArray(data.traits)) {
      sanitized.traits = data.traits.map((trait: any) => {
        if (!trait) return null;
        
        return {
          id: trait.id || 'unknown',
          name: trait.name || 'Unknown Trait',
          icon: trait.icon || '',
          tier: trait.tier || 0,
          numUnits: trait.numUnits || 0,
          tierIcon: trait.tierIcon || '',
          count: trait.count || 0,
          avgPlacement: trait.avgPlacement || 0,
          winRate: trait.winRate || 0,
          top4Rate: trait.top4Rate || 0,
          playRate: trait.playRate || 0,
          stats: {
            count: trait.count || trait.stats?.count || 0,
            avgPlacement: trait.avgPlacement || trait.stats?.avgPlacement || 0,
            winRate: trait.winRate || trait.stats?.winRate || 0,
            top4Rate: trait.top4Rate || trait.stats?.top4Rate || 0
          },
          relatedComps: Array.isArray(trait.relatedComps) ? trait.relatedComps.map((comp: any) => ({
            id: comp.id || 'unknown',
            name: comp.name || 'Unknown Composition',
            icon: comp.icon || '',
            count: comp.count || 0,
            avgPlacement: comp.avgPlacement || 0,
            winRate: comp.winRate || 0,
            top4Rate: comp.top4Rate || 0,
            traits: [],
            units: []
          })) : []
        };
      }).filter(Boolean);
    }
    
    // Add items if they exist - CRITICAL FIX FOR UNITS WITH ITEM RELATIONSHIP
    if (data.items && Array.isArray(data.items)) {
      sanitized.items = data.items.map((item: any) => {
        if (!item) return null;
        
        // Process unitsWithItem with complete stats structure
        let safeUnitsWithItem: any[] = [];
        if (item.unitsWithItem && Array.isArray(item.unitsWithItem)) {
          safeUnitsWithItem = item.unitsWithItem.map((unit: any) => {
            // Ensure proper stats structure
            return {
              id: unit.id || 'unknown',
              name: unit.name || 'Unknown Unit',
              icon: unit.icon || '',
              cost: unit.cost || 0,
              count: unit.count || 0,
              winRate: unit.winRate || 0,
              avgPlacement: unit.avgPlacement || 0,
              stats: {
                count: unit.count || unit.stats?.count || 0,
                avgPlacement: unit.avgPlacement || unit.stats?.avgPlacement || 0,
                winRate: unit.winRate || unit.stats?.winRate || 0,
                top4Rate: unit.top4Rate || unit.stats?.top4Rate || 0
              },
              relatedComps: Array.isArray(unit.relatedComps) ? 
                unit.relatedComps.map((comp: any) => ({
                  id: comp.id || 'unknown',
                  name: comp.name || 'Unknown Composition',
                  icon: comp.icon || '',
                  traits: [],
                  units: []
                })) : []
            };
          });
        }
        
        // Create clean item object with all required properties
        return {
          id: item.id || 'unknown',
          name: item.name || 'Unknown Item',
          icon: item.icon || '',
          category: item.category || 'unknown',
          count: item.count || 0,
          avgPlacement: item.avgPlacement || 0,
          winRate: item.winRate || 0,
          top4Rate: item.top4Rate || 0,
          playRate: item.playRate || 0,
          stats: {
            count: item.count || item.stats?.count || 0,
            avgPlacement: item.avgPlacement || item.stats?.avgPlacement || 0,
            winRate: item.winRate || item.stats?.winRate || 0,
            top4Rate: item.top4Rate || item.stats?.top4Rate || 0
          },
          // Use our properly structured unitsWithItem array
          unitsWithItem: safeUnitsWithItem,
          relatedComps: Array.isArray(item.relatedComps) ? item.relatedComps.map((comp: any) => ({
            id: comp.id || 'unknown',
            name: comp.name || 'Unknown Composition',
            icon: comp.icon || '',
            count: comp.count || 0,
            avgPlacement: comp.avgPlacement || 0,
            winRate: comp.winRate || 0,
            top4Rate: comp.top4Rate || 0,
            traits: [],
            units: []
          })) : [],
          combos: Array.isArray(item.combos) ? item.combos.map((combo: any) => ({
            mainItem: {
              id: combo.mainItem?.id || item.id || 'unknown',
              name: combo.mainItem?.name || item.name || 'Unknown Item',
              icon: combo.mainItem?.icon || item.icon || ''
            },
            items: Array.isArray(combo.items) ? combo.items.map((comboItem: any) => ({
              id: comboItem.id || 'unknown',
              name: comboItem.name || 'Unknown Item',
              icon: comboItem.icon || ''
            })) : [],
            winRate: combo.winRate || 0,
            frequency: combo.frequency || 0
          })) : []
        };
      }).filter(Boolean);
    }
    
    return sanitized;
  } catch (error) {
    console.error("Error during sanitization:", error);
    return { 
      region: data.region,
      summary: { 
        totalGames: data.summary?.totalGames || 0,
        avgPlacement: data.summary?.avgPlacement || 0
      },
      compositions: [],
      units: [],
      traits: [],
      items: []
    };
  }
}
EOL

# Create the continent fetcher utility
cat > src/utils/continentFetcher.ts << 'EOL'
import { processRegion, REGIONS_BY_CONTINENT, RegionKey } from '@/utils/api';
import { logMessage, LogSeverity } from '@/utils/logger';
import { ProcessedMatch } from '@/types';

/**
 * Process all continents in parallel with proper rate limiting
 */
export async function processAllContinentsInParallel(matchesPerRegion: number = 2000): Promise<ProcessedMatch[]> {
  try {
    logMessage(LogSeverity.INFO, 'Starting parallel continent processing');
    
    // Process each continent in parallel
    const continentPromises = Object.entries(REGIONS_BY_CONTINENT).map(
      async ([continentName, regions]) => {
        logMessage(LogSeverity.INFO, `Processing continent: ${continentName} with regions: ${regions.join(', ')}`);
        
        // Process regions within each continent in parallel
        const regionPromises = regions.map(region => 
          processRegion(region as RegionKey, matchesPerRegion)
        );
        
        // Wait for all regions in this continent to complete
        const continentResults = await Promise.all(regionPromises);
        
        // Flatten the results
        const continentMatches = continentResults.flat();
        
        logMessage(LogSeverity.INFO, 
          `Continent ${continentName} completed: ${continentMatches.length} total matches`);
        
        return continentMatches;
      }
    );
    
    // Wait for all continents to complete
    const allContinentResults = await Promise.all(continentPromises);
    
    // Flatten all results
    const allMatches = allContinentResults.flat();
    
    logMessage(LogSeverity.INFO, 
      `All continents completed: ${allMatches.length} total matches from ${Object.keys(REGIONS_BY_CONTINENT).length} continents`);
    
    return allMatches;
  } catch (error) {
    logMessage(LogSeverity.ERROR, 'Error in parallel continent processing:', error);
    return [];
  }
}
EOL

# Create the item combos utility
cat > src/utils/itemCombos.ts << 'EOL'
import { ProcessedItem, ItemCombo } from '@/types';

/**
 * Generate item combinations data for all items
 */
export function generateAllItemCombos(items: ProcessedItem[]): Record<string, ItemCombo[]> {
  const combos: Record<string, ItemCombo[]> = {};
  
  if (!items || items.length === 0) {
    return combos;
  }
  
  // For each item, find its most common combinations
  items.forEach(mainItem => {
    if (!mainItem.id || !mainItem.unitsWithItem) return;
    
    const itemCombos: Record<string, {
      items: ProcessedItem[];
      appearances: number;
      winRateSum: number;
      totalGames: number;
    }> = {};
    
    // Look through units that use this item to find common combinations
    mainItem.unitsWithItem.forEach(unit => {
      if (!unit.relatedComps) return;
      
      // Look through related compositions to find item combinations
      unit.relatedComps.forEach(comp => {
        // Find the unit in this composition
        const compUnit = comp.units?.find(u => u.id === unit.id);
        if (!compUnit || !compUnit.items) return;
        
        // Get all items on this unit (should include our main item)
        const unitItems = compUnit.items.filter(item => item.id !== mainItem.id);
        
        if (unitItems.length === 0) return;
        
        // Create a key for this combination
        const comboKey = [mainItem.id, ...unitItems.map(i => i.id).sort()].join(',');
        
        if (!itemCombos[comboKey]) {
          itemCombos[comboKey] = {
            items: [mainItem, ...unitItems],
            appearances: 0,
            winRateSum: 0,
            totalGames: 0
          };
        }
        
        // Update combo stats
        const weight = comp.count || 1;
        itemCombos[comboKey].appearances++;
        itemCombos[comboKey].totalGames += weight;
        itemCombos[comboKey].winRateSum += (comp.winRate || 0) * weight;
      });
    });
    
    // Convert to final combo format and sort by win rate
    const finalCombos = Object.values(itemCombos)
      .filter(combo => combo.appearances >= 2) // Only include combos that appear multiple times
      .map(combo => ({
        mainItem,
        items: combo.items,
        winRate: combo.totalGames > 0 ? combo.winRateSum / combo.totalGames : 0,
        frequency: combo.appearances / (mainItem.unitsWithItem?.length || 1)
      }))
      .sort((a, b) => b.winRate - a.winRate)
      .slice(0, 5); // Keep top 5 combos
    
    if (finalCombos.length > 0) {
      combos[mainItem.id] = finalCombos;
    }
  });
  
  return combos;
}
EOL

# Update region-status.ts
cat > src/pages/api/region-status.ts << 'EOL'
import type { NextApiRequest, NextApiResponse } from 'next';
import { getRegionStatuses } from '@/utils/db';
import { logMessage, LogSeverity } from '@/utils/logger';

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  try {
    const statuses = await getRegionStatuses();
    
    // Set cache headers to allow short-term caching
    res.setHeader('Cache-Control', 'public, s-maxage=60, stale-while-revalidate=120');
    
    return res.status(200).json(statuses);
  } catch (error) {
    logMessage(LogSeverity.ERROR, 'Failed to get region statuses', error);
    return res.status(500).json({ 
      error: error instanceof Error ? error.message : 'Unknown error' 
    });
  }
}
EOL

# Update matches API endpoint
cat > src/pages/api/tft/matches.ts << 'EOL'
import type { NextApiRequest, NextApiResponse } from 'next';
import { 
  initializeDatabase,
  getStats, 
  getMatches, 
  getRegionStatuses,
  insertSampleData
} from '@/utils/db';
import { logMessage, LogSeverity } from '@/utils/logger';
import { ProcessedMatch } from '@/types';

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse<ProcessedMatch[] | { error: string }>
) {
  try {
    // Initialize database if needed
    await initializeDatabase();
    
    // First try to get processed data
    const cachedData = await getStats('compositions', 'all');
    
    if (cachedData && cachedData.compositions) {
      // Get region statuses for client display
      const regionStatuses = await getRegionStatuses();
      
      // Set cache headers for better performance
      res.setHeader('Cache-Control', 'public, s-maxage=3600, stale-while-revalidate=7200');
      
      // We need to return an array of processed matches for compatibility with existing code
      return res.status(200).json(
        cachedData.compositions.map((comp: any) => ({
          id: comp.id || 'unknown',
          region: comp.region || 'unknown',
          participants: [] // Empty participants as we don't need them anymore
        }))
      );
    }
    
    // If no processed data, try returning raw match data
    const matches = await getMatches();
    
    if (matches && matches.length > 0) {
      // Set cache headers
      res.setHeader('Cache-Control', 'public, s-maxage=3600, stale-while-revalidate=7200');
      return res.status(200).json(matches);
    }
    
    // No data available - insert sample data and return it
    logMessage(LogSeverity.INFO, 'No data available, inserting sample data');
    await insertSampleData();
    
    // Get the sample data we just inserted
    const sampleData = await getStats('compositions', 'all');
    
    if (sampleData && sampleData.compositions) {
      return res.status(200).json(
        sampleData.compositions.map((comp: any) => ({
          id: comp.id || 'sample-id',
          region: comp.region || 'all',
          participants: [] // Empty participants for sample data
        }))
      );
    }
    
    // If all else fails, return error
    return res.status(404).json({ error: 'No cached data available and failed to create sample data' });
  } catch (error) {
    logMessage(LogSeverity.ERROR, "API Error", error);
    
    return res.status(500).json({ 
      error: error instanceof Error ? 
        `Failed to process match data: ${error.message}` : 
        'Unknown error processing match data'
    });
  }
}
EOL

# Create compositions API endpoint
cat > src/pages/api/tft/compositions.ts << 'EOL'
import type { NextApiRequest, NextApiResponse } from 'next';
import { getStats, initializeDatabase } from '@/utils/db';
import { logMessage, LogSeverity } from '@/utils/logger';

export const config = {
  api: {
    responseLimit: '16mb',
  },
};

// Main handler for stats
export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  try {
    // Initialize database
    await initializeDatabase();
    
    // Get region from query
    const { region = 'all' } = req.query;
    
    // Validate region
    const validRegion = typeof region === 'string' ? region : 'all';
    
    // Get data for the region
    const compositions = await getStats('compositions', validRegion);
    
    if (!compositions) {
      logMessage(LogSeverity.WARN, `No compositions found for region: ${validRegion}`);
      return res.status(404).json({ error: `No data available for region: ${validRegion}` });
    }
    
    // Add region to response
    const response = {
      ...compositions,
      region: validRegion
    };
    
    return res.status(200).json(response);
  } catch (error) {
    logMessage(LogSeverity.ERROR, 'Error fetching compositions:', error);
    return res.status(500).json({ error: 'Failed to fetch composition data' });
  }
}
EOL

# Create direct entities API endpoints
cat > src/pages/api/tft/entities/\[type\].ts << 'EOL'
import type { NextApiRequest, NextApiResponse } from 'next';
import { initializeDatabase, getStats, insertSampleData } from '@/utils/db';
import { logMessage, LogSeverity } from '@/utils/logger';

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  try {
    // Initialize database if needed
    await initializeDatabase();
    
    const { type, region = 'all' } = req.query;
    
    // Validate type
    const validTypes = ['compositions', 'units', 'traits', 'items'];
    if (!type || !validTypes.includes(type as string)) {
      return res.status(400).json({ error: 'Invalid entity type' });
    }
    
    // Get the cached processed data
    logMessage(LogSeverity.INFO, `Fetching ${type} data for ${region}`);
    
    const processedData = await getStats(type as string, region as string);
    
    if (processedData) {
      // Set cache headers
      res.setHeader('Cache-Control', 'public, s-maxage=3600, stale-while-revalidate=7200');
      
      // Log some statistics about the returned data
      const dataSize = JSON.stringify(processedData).length;
      let entityCount = 0;
      
      // Check for entities
      if (type === 'compositions' && processedData.compositions) {
        entityCount = processedData.compositions.length;
      } else if (type === 'units' && processedData.units) {
        entityCount = processedData.units.length;
      } else if (type === 'traits' && processedData.traits) {
        entityCount = processedData.traits.length;
      } else if (type === 'items' && processedData.items) {
        entityCount = processedData.items.length;
      }
      
      logMessage(LogSeverity.INFO,
        `Returning ${entityCount} ${type} for ${region}, size: ${Math.round(dataSize / 1024)}KB`);
        
      return res.status(200).json(processedData);
    }
    
    // No data - insert sample data
    logMessage(LogSeverity.INFO, `No ${type} data available, inserting sample data`);
    await insertSampleData();
    
    // Get the sample data we just inserted
    const sampleData = await getStats(type as string, region as string);
    
    if (sampleData) {
      res.setHeader('Cache-Control', 'public, s-maxage=3600, stale-while-revalidate=7200');
      return res.status(200).json(sampleData);
    }
    
    return res.status(404).json({ error: `No ${type} data available and failed to create sample data` });
  } catch (error) {
    logMessage(LogSeverity.ERROR, 'API Error', error);
    return res.status(500).json({ 
      error: error instanceof Error ? error.message : 'Unknown error' 
    });
  }
}
EOL

# Update Tooltip component
cat > src/components/ui/Tooltip.tsx << 'EOL'
import React from 'react';
import Link from 'next/link';
import { getCostColor, getEntityIcon, getIconPath, DEFAULT_ICONS } from '@/utils/paths';
import { ProcessedItem, ProcessedUnit, ProcessedTrait, Composition } from '@/types';
import traitsJson from 'public/mapping/traits.json';
import unitsJson from 'public/mapping/units.json';
import itemsJson from 'public/mapping/items.json';
import { getTierName } from '@/utils/paths';

// Create context for tooltip
const TooltipContext = React.createContext({
  content: null as React.ReactNode, 
  position: { x: 0, y: 0 }, 
  show: (content: React.ReactNode, e: React.MouseEvent) => {}, 
  hide: () => {}
});

export const useTooltip = () => React.useContext(TooltipContext);

// Define types for our entities
interface UnitDetails {
  name: string;
  icon: string;
  cost: number;
  traits?: {
    origin?: string | string[];
    class?: string | string[];
  };
  ability?: {
    name: string;
    description: string;
    type: string;
    mana_cost?: number[];
  };
}

interface ItemDetails {
  name: string;
  category: string;
  icon: string;
  description?: string;
  stats?: string[];
}

interface ItemCombo {
  mainItem: ProcessedItem;
  items: ProcessedItem[];
  winRate: number;
}

// Enhanced tooltips for each entity type
export const renderUnitTooltip = (unit: ProcessedUnit) => {
  if (!unit) return null;
  
  const unitDetails = unitsJson.units[unit.id as keyof typeof unitsJson.units] as UnitDetails | undefined;
  const origin = unitDetails?.traits?.origin ? (Array.isArray(unitDetails.traits.origin) ? unitDetails.traits.origin[0] : unitDetails.traits.origin) : null;
  const unitClass = unitDetails?.traits?.class ? (Array.isArray(unitDetails.traits.class) ? unitDetails.traits.class[0] : unitDetails.traits.class) : null;
  
  const originData = origin ? traitsJson.origins[origin as keyof typeof traitsJson.origins] : null;
  const classData = unitClass ? traitsJson.classes[unitClass as keyof typeof traitsJson.classes] : null;
  
  return (
    <div className="min-w-60 max-w-64 font-sans">
      <div className="flex items-start gap-2 mb-2">
        <div className="rounded-full border-2 w-10 h-10 flex-shrink-0 overflow-hidden" 
             style={{ borderColor: getCostColor(unit.cost) }}>
          <img 
            src={getEntityIcon(unit, 'unit')} 
            alt={unit.name} 
            className="w-full h-full object-cover"
            onError={(e) => {
              const target = e.target as HTMLImageElement;
              target.src = DEFAULT_ICONS.unit;
            }}
          />
        </div>
        <div className="flex-1 min-w-0">
          <div className="font-semibold text-gold truncate">{unit.name}</div>
          <div className="text-xs flex items-center">
            <span className="text-cream/90 mr-1">Cost:</span>
            <span className="font-medium text-cream">{unit.cost}🪙</span>
          </div>
        </div>
      </div>
      
      <div className="text-xs flex flex-wrap gap-1 mb-2">
        <span className="text-cream/80">Categories:</span>
        {originData && (
          <div className="bg-brown-light/40 px-1.5 py-0.5 rounded text-xs flex items-center">
            <img 
              src={getIconPath(originData.icon, 'trait')} 
              alt={originData.name} 
              className="w-3 h-3 mr-1"
              onError={(e) => {
                const target = e.target as HTMLImageElement;
                target.src = DEFAULT_ICONS.trait;
              }}
            />
            <span>{originData.name}</span>
          </div>
        )}
        {classData && (
          <div className="bg-brown-light/40 px-1.5 py-0.5 rounded text-xs flex items-center">
            <img 
              src={getIconPath(classData.icon, 'trait')} 
              alt={classData.name} 
              className="w-3 h-3 mr-1"
              onError={(e) => {
                const target = e.target as HTMLImageElement;
                target.src = DEFAULT_ICONS.trait;
              }}
            />
            <span>{classData.name}</span>
          </div>
        )}
      </div>
      
      {/* Best items section - without names */}
      {unit.bestItems && unit.bestItems.length > 0 && (
        <div className="border-t border-gold/20 pt-1 mb-2">
          <div className="text-xs text-cream/90 font-medium mb-1">Best Items:</div>
          <div className="flex gap-1 justify-center">
            {unit.bestItems.slice(0, 3).map((item, i) => (
              <Link href={`/entity/items/${item.id}`} key={i} className="block">
                <div className="relative group">
                  <img 
                    src={getEntityIcon(item, 'item')} 
                    alt={item.name} 
                    className="w-8 h-8 object-contain border border-gold/30 rounded p-0.5 bg-brown-light/30"
                    onError={(e) => {
                      const target = e.target as HTMLImageElement;
                      target.src = DEFAULT_ICONS.item;
                    }}
                  />
                </div>
              </Link>
            ))}
          </div>
        </div>
      )}
    </div>
  );
};

export const renderItemTooltip = (item: ProcessedItem) => {
  if (!item) return null;
  
  const itemDetails = itemsJson.items[item.id as keyof typeof itemsJson.items] as ItemDetails | undefined;
  
  // Get potential combos
  const combos = item.combos || [];
  
  return (
    <div className="min-w-60 max-w-64 font-sans">
      <div className="flex items-start gap-2 mb-2">
        <div className="w-10 h-10 flex-shrink-0 border border-gold/30 rounded p-1 bg-brown-light/20">
          <img 
            src={getEntityIcon(item, 'item')} 
            alt={item.name} 
            className="w-full h-full object-contain"
            onError={(e) => {
              const target = e.target as HTMLImageElement;
              target.src = DEFAULT_ICONS.item;
            }}
          />
        </div>
        <div className="flex-1 min-w-0">
          <div className="font-semibold text-gold truncate">{item.name}</div>
          <div className="text-xs text-cream/80 truncate">
            {itemDetails?.category && 
              itemDetails.category.replace(/-/g, ' ').replace(/\b\w/g, c => c.toUpperCase())}
          </div>
        </div>
      </div>
      
      <div className="text-xs flex flex-wrap gap-1 mb-2">
        <span className="text-cream/80">Category:</span>
        <div className="bg-brown-light/40 px-1.5 py-0.5 rounded text-xs">
          {itemDetails?.category && 
            itemDetails.category.replace(/-/g, ' ').replace(/\b\w/g, c => c.toUpperCase())}
        </div>
      </div>
      
      {/* Stats section */}
      {itemDetails?.stats && itemDetails.stats.length > 0 && (
        <div className="text-xs border-b border-gold/20 pb-1 mb-2">
          <div className="text-cream/90 font-medium mb-1">Stats:</div>
          <div className="space-y-0.5">
            {itemDetails.stats.map((stat, i) => (
              <div key={i} className="text-gold-light">{stat}</div>
            ))}
          </div>
        </div>
      )}
      
      {itemDetails?.description && (
        <div className="text-xs border-t border-gold/20 pt-1 italic text-cream/90 mb-2 line-clamp-3">
          {itemDetails.description}
        </div>
      )}
      
      {/* Best units section */}
      {item.unitsWithItem && item.unitsWithItem.length > 0 && (
        <div className="border-t border-gold/20 pt-1 mb-2">
          <div className="text-xs text-cream/90 font-medium mb-1">Best Units:</div>
          <div className="flex flex-wrap gap-1 justify-center">
            {item.unitsWithItem.slice(0, 3).map((unit, i) => (
              <Link href={`/entity/units/${unit.id}`} key={i} className="block">
                <div className="relative group flex flex-col items-center">
                  <div className="w-8 h-8 rounded-full border-2 overflow-hidden"
                       style={{ borderColor: getCostColor(unit.cost) }}>
                    <img 
                      src={getEntityIcon(unit, 'unit')} 
                      alt={unit.name} 
                      className="w-full h-full object-cover"
                      onError={(e) => {
                        const target = e.target as HTMLImageElement;
                        target.src = DEFAULT_ICONS.unit;
                      }}
                    />
                  </div>
                  <div className="text-xs mt-0.5 text-center max-w-8 truncate">{unit.name}</div>
                </div>
              </Link>
            ))}
          </div>
        </div>
      )}
      
      {/* Best combos section */}
      {combos.length > 0 && (
        <div className="border-t border-gold/20 pt-1 mb-2">
          <div className="text-xs text-cream/90 font-medium mb-1">Best Combos:</div>
          <div className="space-y-1">
            {combos.slice(0, 2).map((combo, i) => (
              <div key={i} className="flex items-center justify-center gap-1 bg-brown-light/30 p-1 rounded">
                {combo.items.map((comboItem, j) => (
                  <Link href={`/entity/items/${comboItem.id}`} key={j} className="block">
                    <img 
                      src={getEntityIcon(comboItem, 'item')} 
                      alt={comboItem.name} 
                      className="w-6 h-6 object-contain border border-gold/20 rounded bg-brown-light/40"
                      onError={(e) => {
                        const target = e.target as HTMLImageElement;
                        target.src = DEFAULT_ICONS.item;
                      }}
                    />
                  </Link>
                ))}
                <div className="text-xs text-cream/90 ml-1">
                  {combo.winRate.toFixed(1)}% Win
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
};

export const renderTraitTooltip = (trait: ProcessedTrait) => {
  if (!trait) return null;
  
  const traitData = traitsJson.origins[trait.id as keyof typeof traitsJson.origins] || 
                    traitsJson.classes[trait.id as keyof typeof traitsJson.classes];
  
  const traitType = Object.keys(traitsJson.origins).includes(trait.id) ? 'Origin' : 'Class';
  
  // Get all units with this trait
  const unitsWithTrait = Object.entries(unitsJson.units)
    .filter(([_, unit]) => {
      if (!unit || !('traits' in unit) || !unit.traits) return false;
      
      // Check origins
      const origins = unit.traits.origin ? 
        (Array.isArray(unit.traits.origin) ? unit.traits.origin : [unit.traits.origin]) : [];
      
      // Check classes
      const classes = unit.traits.class ?
        (Array.isArray(unit.traits.class) ? unit.traits.class : [unit.traits.class]) : [];
      
      // Check if any origins or classes match the trait id
      return [...origins, ...classes].includes(trait.id);
    })
    .map(([id, unit]) => ({
      id,
      name: unit.name,
      icon: unit.icon, 
      cost: unit.cost
    }))
    .sort((a, b) => a.cost - b.cost);
  
  return (
    <div className="min-w-60 max-w-72 font-sans">
      <div className="flex items-start gap-2 mb-2">
        <div className="w-12 h-12 flex-shrink-0 rounded p-1 bg-brown-light/20">
          <img 
            src={getEntityIcon(trait, 'trait')} 
            alt={trait.name} 
            className="w-full h-full object-contain"
            onError={(e) => {
              const target = e.target as HTMLImageElement;
              target.src = DEFAULT_ICONS.trait;
            }}
          />
        </div>
        <div className="flex-1 min-w-0">
          <div className="font-semibold text-gold truncate">{trait.name}</div>
          <div className="text-xs flex items-center gap-1.5">
            <span className="text-cream/80">Type:</span>
            <span className="bg-brown-light/40 py-0.5 rounded text-xs">{traitType}</span>
          </div>
        </div>
      </div>
      
      {trait.tier > 0 && (
        <div className="text-xs flex flex-wrap gap-1 mb-2">
          <span className="text-cream/80">Active Level:</span>
          <span className="text-cream bg-brown-light/50 px-1.5 py-0.5 rounded-full text-xs">
            {trait.numUnits}-units {getTierName(trait.tier)}
          </span>
        </div>
      )}
      
      {traitData?.description && (
        <div className="text-xs border-t border-gold/20 pt-1 text-cream/90 mb-2 line-clamp-3">
          {traitData.description}
        </div>
      )}
      
      {/* Tier bonuses section */}
      {traitData?.tiers && traitData.tiers.length > 0 && (
        <div className="text-xs border-t border-gold/20 pt-1 mb-2">
          <div className="font-medium text-gold mb-1">Tier Bonuses:</div>
          <div className="space-y-1">
            {traitData.tiers.map((tier, i) => (
              <div 
                key={i} 
                className={`rounded p-1 flex items-center gap-1 text-xs ${
                  trait.tier > i 
                    ? 'bg-gold/20' 
                    : 'bg-brown-light/30 text-cream/60'
                }`}
              >
                <span className="font-semibold">{tier.units}:</span>
                <span className="line-clamp-1">{tier.value}</span>
              </div>
            ))}
          </div>
        </div>
      )}
      
      {/* Units with this trait section */}
      {unitsWithTrait.length > 0 && (
        <div className="text-xs border-t border-gold/20 pt-1 mb-2">
          <div className="font-medium text-gold mb-1">Units ({unitsWithTrait.length}):</div>
          <div className="flex flex-wrap gap-1 justify-center">
            {unitsWithTrait.slice(0, 8).map((unit, i) => (
              <Link href={`/entity/units/${unit.id}`} key={i} className="block">
                <div className="relative">
                  <div className="w-7 h-7 rounded-full border overflow-hidden"
                       style={{ borderColor: getCostColor(unit.cost) }}>
                    <img 
                      src={getEntityIcon(unit, 'unit')} 
                      alt={unit.name} 
                      className="w-full h-full object-cover"
                      onError={(e) => {
                        const target = e.target as HTMLImageElement;
                        target.src = DEFAULT_ICONS.unit;
                      }}
                    />
                  </div>
                </div>
              </Link>
            ))}
          </div>
        </div>
      )}
    </div>
  );
};

export const renderCompTooltip = (comp: Composition) => {
  if (!comp) return null;
  
  // Extract the core units (highest cost and most played)
  const coreUnits = comp.units
    .filter(unit => unit.count && unit.count > 0)
    .sort((a, b) => {
      // Sort by count first, then by cost
      if (a.count !== b.count) return (b.count || 0) - (a.count || 0);
      return b.cost - a.cost;
    })
    .slice(0, 6);
  
  // Extract the main traits
  const mainTraits = comp.traits
    .filter(trait => trait.tier > 1)
    .sort((a, b) => b.tier - a.tier)
    .slice(0, 4);
  
  const loadInTeamBuilder = (e: React.MouseEvent) => {
    e.preventDefault();
    // Save comp to localStorage for loading in team builder
    if (typeof window !== 'undefined') {
      localStorage.setItem('loadComp', JSON.stringify(comp));
      window.location.href = '/team-builder';
    }
  };
  
  return (
    <div className="min-w-64 max-w-80 font-sans">
      <div className="flex items-start gap-2 mb-2">
        <div className="flex -space-x-1">
          {mainTraits.slice(0, 2).map((trait, i) => (
            <img 
              key={i} 
              src={getEntityIcon(trait, 'trait')} 
              alt={trait.name} 
              className="w-8 h-8 object-contain"
              onError={(e) => {
                const target = e.target as HTMLImageElement;
                target.src = DEFAULT_ICONS.trait;
              }}
            />
          ))}
        </div>
        <div className="flex-1 min-w-0">
          <div className="font-semibold text-gold truncate max-w-full">{comp.name}</div>
          <div className="text-xs text-cream/70">
            <span className="bg-brown-light/40 px-1.5 py-0.5 rounded text-xs">
              {comp.units && comp.units.filter(u => u.cost >= 4).length >= 3 ? "Fast 9" : 
              comp.units && comp.units.filter(u => u.cost <= 2).length >= 4 ? "Reroll" : "Standard"}
            </span>
          </div>
        </div>
      </div>
      
      <div className="text-xs flex items-center gap-1 mb-2">
        <span className="text-cream/80">Performance:</span>
        <span className="text-gold/90 font-medium">{comp.winRate ? comp.winRate.toFixed(1) + '% Win' : ''}</span>
        <span className="text-cream/60">•</span>
        <span className="text-cream/90">{comp.avgPlacement ? comp.avgPlacement.toFixed(2) + ' Avg' : ''}</span>
      </div>
      
      {/* Core units section */}
      <div className="mb-2 border-t border-gold/20 pt-1">
        <div className="text-xs text-cream/90 font-medium mb-1">Core Units:</div>
        <div className="flex flex-wrap gap-1 justify-center">
          {coreUnits.map((unit, i) => (
            <Link href={`/entity/units/${unit.id}`} key={i} className="block">
              <div className="relative">
                <div className="w-8 h-8 rounded-full border-2 overflow-hidden"
                     style={{ borderColor: getCostColor(unit.cost) }}>
                  <img 
                    src={getEntityIcon(unit, 'unit')} 
                    alt={unit.name} 
                    className="w-full h-full object-cover"
                    onError={(e) => {
                      const target = e.target as HTMLImageElement;
                      target.src = DEFAULT_ICONS.unit;
                    }}
                  />
                </div>
              </div>
            </Link>
          ))}
        </div>
      </div>
      
      {/* Traits section */}
      <div className="mb-2 border-t border-gold/20 pt-1">
        <div className="text-xs text-cream/90 font-medium mb-1">Active Traits:</div>
        <div className="flex flex-wrap gap-1 justify-center">
          {mainTraits.map((trait, i) => (
            <Link href={`/entity/traits/${trait.id}`} key={i} className="block">
              <div 
                className="bg-brown-light/30 px-2 py-0.5 rounded text-xs flex items-center gap-1"
              >
                <img 
                  src={getEntityIcon(trait, 'trait')} 
                  alt={trait.name} 
                  className="w-4 h-4"
                  onError={(e) => {
                    const target = e.target as HTMLImageElement;
                    target.src = DEFAULT_ICONS.trait;
                  }}
                />
                <span>{trait.name} ({trait.numUnits})</span>
              </div>
            </Link>
          ))}
        </div>
      </div>
      
      {/* Load in Team Builder button */}
      <div className="mt-3 border-t border-gold/20 pt-2">
        <Link href="/team-builder" onClick={loadInTeamBuilder} className="block">
          <div
            className="w-full text-xs bg-gold hover:bg-gold-light text-brown py-1.5 px-3 rounded flex items-center justify-center gap-1.5"
          >
            <svg xmlns="http://www.w3.org/2000/svg" className="h-3.5 w-3.5" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <polyline points="16 18 22 12 16 6"></polyline>
              <polyline points="8 6 2 12 8 18"></polyline>
            </svg>
            <span>Load in Team Builder</span>
          </div>
        </Link>
      </div>
    </div>
  );
};

export function TooltipProvider({ children }: { children: React.ReactNode }) {
  const [content, setContent] = React.useState<React.ReactNode>(null);
  const [position, setPosition] = React.useState({ x: 0, y: 0 });

  const show = (content: React.ReactNode, e: React.MouseEvent) => {
    // Calculate position to avoid going off screen
    const rect = e.currentTarget.getBoundingClientRect();
    const x = Math.min(rect.left, window.innerWidth - 320);
    
    // Position above or below based on space
    const y = rect.top + window.scrollY;
    const spaceBelow = window.innerHeight - rect.bottom;
    const posY = spaceBelow < 250 && rect.top > 250 ? y - 10 : y + rect.height + 10;
    
    setContent(content);
    setPosition({ x, y: posY });
  };

  const hide = () => setContent(null);

  return (
    <TooltipContext.Provider value={{ content, position, show, hide }}>
      {children}
      {content && (
        <div className="tooltip z-50 max-w-sm" style={{
          left: position.x, top: position.y, opacity: content ? 1 : 0
        }}>
          {content}
        </div>
      )}
    </TooltipContext.Provider>
  );
}
EOL

# Create Card component
cat > src/components/ui/Card.tsx << 'EOL'
import React, { ReactNode } from 'react';
import { motion } from 'framer-motion';

interface CardProps {
  children: ReactNode;
  className?: string;
  animate?: boolean;
  delay?: number;
}

export default function Card({ 
  children, 
  className = '', 
  animate = false,
  delay = 0
}: CardProps) {
  if (animate) {
    return (
      <motion.div 
        className={`card w-full ${className}`}
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ 
          duration: 0.4,
          ease: [0.2, 0.8, 0.2, 1],
          delay: delay
        }}
      >
        {children}
      </motion.div>
    );
  }
  
  return <div className={`card w-full ${className}`}>{children}</div>;
}
EOL

# Update IconComponents to standardize hovering
cat > src/components/ui/IconComponents.tsx << 'EOL'
import React from 'react';
import { useTooltip, renderUnitTooltip, renderItemTooltip, renderTraitTooltip, renderCompTooltip } from './Tooltip';
import { getEntityIcon, getCostColor, DEFAULT_ICONS } from '@/utils/paths';

interface TraitIconProps {
  trait: any;
  [key: string]: any;
}

interface UnitIconProps {
  unit: any;
  [key: string]: any;
}

interface ItemIconProps {
  item: any;
  [key: string]: any;
}

interface CompIconProps {
  comp: any;
  [key: string]: any;
}

const sizes = {
  xs: 'w-4 h-4', 
  sm: 'w-6 h-6', 
  md: 'w-10 h-10', 
  lg: 'w-16 h-16'
};

type IconSize = 'xs' | 'sm' | 'md' | 'lg';

interface EntityIconProps {
  entity: any;
  type: string;
  size?: IconSize;
  onClick?: (e: React.MouseEvent) => void;
  showDetailedTooltip?: boolean;
  className?: string;
}

export function EntityIcon({ 
  entity, 
  type, 
  size = 'md', 
  onClick, 
  showDetailedTooltip = true,
  className = ''
}: EntityIconProps) {
  const { show, hide } = useTooltip();
  if (!entity) return null;
  
  // Use the unified path resolver
  const iconPath = getEntityIcon(entity, type);
  const sizeClass = sizes[size];
  
  const handleMouseEnter = (e: React.MouseEvent) => {
    if (showDetailedTooltip) {
      if (type === 'unit') {
        show(renderUnitTooltip(entity), e);
      } else if (type === 'item') {
        show(renderItemTooltip(entity), e);
      } else if (type === 'trait') {
        show(renderTraitTooltip(entity), e);
      } else if (type === 'comp') {
        show(renderCompTooltip(entity), e);
      } else {
        show(entity.name, e);
      }
    } else {
      show(entity.name, e);
    }
  };
  
  if (type === 'trait') {
    return (
      <div 
        className={`bg-brown-light/30 rounded hover:bg-brown-light/50 flex items-center justify-center ${className}`}
        onMouseEnter={handleMouseEnter}
        onMouseLeave={hide}
        onClick={onClick}
      >
        <img 
          src={iconPath} 
          alt={entity.name}
          className="w-12 h-12 object-contain"
          onError={(e) => {
            const target = e.target as HTMLImageElement;
            target.src = DEFAULT_ICONS.trait;
          }}
        />
      </div>
    );
  }
  
  if (type === 'unit') {
    const borderColor = getCostColor(entity.cost);
    
    return (
      <div 
        className={`relative ${className}`}
        onMouseEnter={handleMouseEnter}
        onMouseLeave={hide}
        onClick={onClick}
      >
        <img 
          src={iconPath} 
          alt={entity.name}
          className={`${sizeClass} rounded-full border-2 object-cover hover:shadow-md transition-shadow ${className}`}
          style={{ borderColor }}
          onError={(e) => {
            const target = e.target as HTMLImageElement;
            target.src = DEFAULT_ICONS.unit;
          }}
        />
      </div>
    );
  }
  
  if (type === 'item') {
    return (
      <div 
        className={`${sizeClass} overflow-hidden ${className}`}
        onMouseEnter={handleMouseEnter}
        onMouseLeave={hide}
        onClick={onClick}
      >
        <img 
          src={iconPath} 
          alt={entity.name}
          className="w-full h-full object-contain hover:shadow-md transition-shadow"
          onError={(e) => {
            const target = e.target as HTMLImageElement;
            target.src = DEFAULT_ICONS.item;
          }}
        />
      </div>
    );
  }
  
  if (type === 'comp') {
    const mainTrait = entity.traits && entity.traits.length > 0 
      ? entity.traits.sort((a: any, b: any) => (b.tier || 0) - (a.tier || 0))[0]
      : null;
      
    const compIconSrc = mainTrait ? getEntityIcon(mainTrait, 'trait') : DEFAULT_ICONS.trait;
    
    return (
      <div 
        className={`${sizeClass} overflow-hidden ${className}`}
        onMouseEnter={handleMouseEnter}
        onMouseLeave={hide}
        onClick={onClick}
      >
        <img 
          src={compIconSrc} 
          alt={entity.name || 'Composition'}
          className="w-full h-full object-contain hover:shadow-md transition-shadow"
          onError={(e) => {
            const target = e.target as HTMLImageElement;
            target.src = DEFAULT_ICONS.trait;
          }}
        />
      </div>
    );
  }
  
  return null;
}

export function TraitIcon({ trait, ...rest }: TraitIconProps) {
  return <EntityIcon type="trait" entity={trait} {...rest} />;
}

export function UnitIcon({ unit, ...rest }: UnitIconProps) {
  return <EntityIcon type="unit" entity={unit} {...rest} />;
}

export function ItemIcon({ item, ...rest }: ItemIconProps) {
  return <EntityIcon type="item" entity={item} {...rest} />;
}

export function CompIcon({ comp, ...rest }: CompIconProps) {
  return <EntityIcon type="comp" entity={comp} {...rest} />;
}
EOL

# Create FilterButtons component
cat > src/components/ui/FilterButtons.tsx << 'EOL'
import React from 'react';

interface FilterOption {
  id: string;
  name: string;
}

interface FilterButtonsProps {
  options: FilterOption[];
  activeFilter: {
    all: boolean;
    [key: string]: boolean;
  };
  onChange: (id: string) => void;
}

export default function FilterButtons({ options, activeFilter, onChange }: FilterButtonsProps) {
  const sortedOptions = [...options];
  if (!activeFilter.all) {
    sortedOptions.sort((a, b) => {
      if (activeFilter[a.id] && !activeFilter[b.id]) return -1;
      if (!activeFilter[a.id] && activeFilter[b.id]) return 1;
      return 0;
    });
  }

  return (
    <div className="flex flex-wrap gap-2">
      <button 
        className={`filter-btn ${activeFilter.all ? 'filter-active' : 'filter-inactive'}`}
        onClick={() => onChange('all')}
      >All</button>
      
      {sortedOptions.map(opt => (
        <button
          key={opt.id}
          className={`filter-btn ${activeFilter[opt.id] && !activeFilter.all ? 'filter-active' : 'filter-inactive'}`}
          onClick={() => onChange(opt.id)}
        >{opt.name}</button>
      ))}
    </div>
  );
}
EOL

# Create a new StatsPanel component with PlacementDistribution
cat > src/components/ui/StatsPanel.tsx << 'EOL'
import React from 'react';
import { motion } from 'framer-motion';

interface PlacementDistributionProps {
  placementData?: Array<{ placement: number; count: number; }>;
}

function PlacementDistribution({ placementData }: PlacementDistributionProps) {
  if (!placementData || placementData.length === 0) return null;
  
  // Calculate total count for percentages
  const totalGames = placementData.reduce((sum, p) => sum + p.count, 0);
  const placementPercentages = placementData.map(p => ({
    ...p,
    percentage: ((p.count / totalGames) * 100).toFixed(1)
  }));

  return (
    <div className="mt-2 pt-3 border-t border-solar-flare/20">
      <div className="flex flex-col space-y-2">
        {/* Visual chart for all 8 placements */}
        <div className="w-full bg-void-core/50 rounded-lg p-3 border border-solar-flare/10">
          <div className="flex items-end space-x-1">
            {Array.from({ length: 8 }, (_, i) => {
              const placement = i + 1;
              // Find the placement data or use a default
              const placementData = placementPercentages.find(p => p.placement === placement) || 
                { placement, count: 0, percentage: '0.0' };
              
              const percentage = parseFloat(placementData.percentage);
              const height = `${Math.max(4, (percentage / 100) * 120)}px`;
              
              // Color scheme based on placement
              let barColor;
              let textColor;
              
              switch(placement) {
                case 1: 
                  barColor = 'bg-gradient-to-t from-solar-flare to-burning-warning';
                  textColor = 'text-solar-flare';
                  break;
                case 2: 
                  barColor = 'bg-gradient-to-t from-cosmic-dust to-stellar-white/80';
                  textColor = 'text-stellar-white';
                  break;
                case 3: 
                  barColor = 'bg-gradient-to-t from-amber-700 to-amber-600';
                  textColor = 'text-amber-400';
                  break;
                default: 
                  barColor = 'bg-gradient-to-t from-corona-light/40 to-corona-light/30';
                  textColor = 'text-corona-light';
              }

              return (
                <motion.div 
                  key={placement} 
                  className="flex-1 flex flex-col items-center"
                  initial={{ height: 0, opacity: 0 }}
                  animate={{ height: "auto", opacity: 1 }}
                  transition={{ 
                    duration: 0.5, 
                    delay: placement * 0.05,
                    ease: [0.2, 0.8, 0.2, 1]
                  }}
                >
                  <div className="text-xs text-corona-light/70 mb-1">{percentage}%</div>
                  <motion.div 
                    className={`w-full rounded-t ${barColor}`} 
                    style={{ height: "4px" }}
                    animate={{ height }}
                    transition={{ 
                      duration: 0.8, 
                      delay: placement * 0.05 + 0.3,
                      ease: [0.2, 0.8, 0.2, 1] 
                    }}
                  ></motion.div>
                  <div className={`text-xs font-medium mt-1 ${textColor}`}>
                    #{placement}
                  </div>
                </motion.div>
              );
            })}
          </div>
        </div>
      </div>
    </div>
  );
}

interface StatsPanelProps {
  stats: {
    count?: number;
    avgPlacement?: number;
    winRate?: number;
    top4Rate?: number;
    placementData?: Array<{ placement: number; count: number; }>;
    totalGames?: number; // Total number of games analyzed
    [key: string]: any;
  } | null;
}

export default function StatsPanel({ stats }: StatsPanelProps) {
  if (!stats) return null;
  
  // Calculate per-lobby frequency if totalGames is available
  const totalGames = stats.totalGames || 0;
  const perLobbyFrequency = totalGames > 0 
    ? ((stats.count || 0) / totalGames * 8).toFixed(1)
    : '-';
  
  const variants = {
    hidden: { opacity: 0, y: 20 },
    visible: (i: number) => ({
      opacity: 1,
      y: 0,
      transition: {
        delay: i * 0.1,
        duration: 0.5,
        ease: [0.2, 0.8, 0.2, 1]
      }
    })
  };
  
  return (
    <div className="space-y-4">
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
        <motion.div 
          className="stat-box"
          custom={0}
          initial="hidden"
          animate="visible"
          variants={variants}
        >
          <div className="text-sm text-corona-light/80">Frequency</div>
          <div className="text-base font-medium text-solar-flare">
            {totalGames > 0 ? `${perLobbyFrequency}/8` : stats.count || 0}
          </div>
        </motion.div>
        <motion.div 
          className="stat-box"
          custom={1}
          initial="hidden"
          animate="visible"
          variants={variants}
        >
          <div className="text-sm text-corona-light/80">Avg Place</div>
          <div className="text-base font-medium text-solar-flare">{stats.avgPlacement?.toFixed(2) || '-'}</div>
        </motion.div>
        <motion.div 
          className="stat-box"
          custom={2}
          initial="hidden"
          animate="visible"
          variants={variants}
        >
          <div className="text-sm text-corona-light/80">Win Rate</div>
          <div className="text-base font-medium text-solar-flare">{stats.winRate?.toFixed(1) || '0'}%</div>
        </motion.div>
        <motion.div 
          className="stat-box"
          custom={3}
          initial="hidden"
          animate="visible"
          variants={variants}
        >
          <div className="text-sm text-corona-light/80">Top 4</div>
          <div className="text-base font-medium text-solar-flare">{stats.top4Rate?.toFixed(1) || '0'}%</div>
        </motion.div>
      </div>
      
      {stats.placementData && <PlacementDistribution placementData={stats.placementData} />}
    </div>
  );
}

// Export PlacementDistribution component
export { PlacementDistribution };
EOL

# Create Error and Loading components
cat > src/components/ui/ErrorMessage.tsx << 'EOL'
import React from 'react';
import { motion } from 'framer-motion';

interface ErrorMessageProps {
  message?: string;
  onRetry?: () => void;
  className?: string;
}

export default function ErrorMessage({ message, onRetry, className = '' }: ErrorMessageProps) {
  return (
    <motion.div 
      className={`error-banner ${className}`}
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.4, ease: [0.2, 0.8, 0.2, 1] }}
    >
      <span>{message || 'An error occurred. Please try again.'}</span>
      {onRetry && (
        <motion.button 
          onClick={onRetry} 
          className="px-3 py-1 bg-void-core/60 hover:bg-void-core border border-solar-flare/40 rounded-lg text-sm text-corona-light"
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.95 }}
        >
          Retry
        </motion.button>
      )}
    </motion.div>
  );
}
EOL

# Create LoadingState
cat > src/components/ui/LoadingState.tsx << 'EOL'
import React from 'react';
import { motion } from 'framer-motion';

interface LoadingStateProps {
  fullScreen?: boolean;
  message?: string;
  size?: 'sm' | 'md' | 'lg';
}

export default function LoadingState({ 
  fullScreen = false, 
  message, 
  size = 'md' 
}: LoadingStateProps) {
  const sizes = {
    sm: 'h-6 w-6',
    md: 'h-10 w-10',
    lg: 'h-16 w-16'
  };

  const spinnerVariants = {
    animate: {
      rotate: 360,
      transition: {
        duration: 1.5,
        ease: "linear",
        repeat: Infinity
      }
    }
  };

  const fadeInVariants = {
    hidden: { opacity: 0 },
    visible: { 
      opacity: 1, 
      transition: { 
        duration: 0.5,
        ease: [0.2, 0.8, 0.2, 1]
      }
    }
  };

  if (fullScreen) {
    return (
      <motion.div 
        className="loading-overlay"
        initial="hidden"
        animate="visible"
        variants={fadeInVariants}
      >
        <div className="flex flex-col items-center">
          <motion.div 
            className={`loading-spinner ${sizes[size]}`} 
            variants={spinnerVariants}
            animate="animate"
          />
          {message && (
            <motion.p 
              className="mt-3 text-corona-light/80"
              initial={{ opacity: 0, y: 5 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.2, duration: 0.5 }}
            >
              {message}
            </motion.p>
          )}
        </div>
      </motion.div>
    );
  }
  
  return (
    <motion.div 
      className="flex justify-center items-center py-6"
      initial="hidden"
      animate="visible"
      variants={fadeInVariants}
    >
      <div className="flex flex-col items-center">
        <motion.div 
          className={`loading-spinner ${sizes[size]}`}
          variants={spinnerVariants}
          animate="animate"
        />
        {message && (
          <motion.p 
            className="mt-3 text-corona-light/80"
            initial={{ opacity: 0, y: 5 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2, duration: 0.5 }}
          >
            {message}
          </motion.p>
        )}
      </div>
    </motion.div>
  );
}
EOL

# Create Layout component with region support
cat > src/components/ui/Layout.tsx << 'EOL'
import React, { useState, useRef, useEffect } from 'react';
import { useRouter } from 'next/router';
import Link from 'next/link';
import Head from 'next/head';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  Menu, X, Slack, Search, Layers, 
  Book, Newspaper, User, ChevronDown, Trophy, 
  Users, TrendingUp
} from 'lucide-react';
import AuthStatus from '@/components/auth/AuthStatus';
import SearchBar from '@/components/ui/SearchBar';
import { RegionDropdown } from '@/components/ui/RegionDropdown';

interface NavItem {
  name: string;
  href: string;
  icon?: React.ComponentType<{ className?: string }>;
}

interface NavDropdownProps {
  label: string;
  icon?: React.ComponentType<{ className?: string }>;
  items: NavItem[];
  isActive: boolean;
  className?: string;
}

// Dropdown Component
function NavDropdown({ label, icon, items, isActive, className = '' }: NavDropdownProps) {
  const [isOpen, setIsOpen] = useState<boolean>(false);
  const dropdownRef = useRef<HTMLDivElement | null>(null);
  
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setIsOpen(false);
      }
    };
    
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);
  
  return (
    <div className={`relative ${className}`} ref={dropdownRef}>
      <motion.button
        className={`flex items-center gap-2 px-3 py-2 rounded-md ${
          isActive ? "bg-solar-flare/20 text-solar-flare border-b-2 border-solar-flare" : "text-corona-light hover:bg-solar-flare/10"
        }`}
        onClick={() => setIsOpen(!isOpen)}
        whileHover={{ scale: 1.03 }}
        whileTap={{ scale: 0.97 }}
      >
        {icon && React.createElement(icon, { className: "h-4 w-4" })}
        <span className="hidden sm:block text-sm">{label}</span>
        <motion.div
          animate={{ rotate: isOpen ? 180 : 0 }}
          transition={{ duration: 0.3 }}
        >
          <ChevronDown className="h-3 w-3" />
        </motion.div>
      </motion.button>
      
      <AnimatePresence>
        {isOpen && (
          <motion.div 
            className="absolute z-20 mt-1 right-0 transform translate-x-3 w-56 rounded-md shadow-lg backdrop-filter backdrop-blur-lg bg-eclipse-shadow/70 border border-solar-flare/30 overflow-hidden"
            initial={{ opacity: 0, y: -10, scale: 0.95 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: -10, scale: 0.95 }}
            transition={{ duration: 0.2, ease: [0.2, 0.8, 0.2, 1] }}
          >
            <div className="py-1">
              {items.map((item, index) => (
                <Link
                  key={index}
                  href={item.href}
                  className="block px-4 py-2 text-sm hover:bg-solar-flare/10 text-corona-light hover:text-solar-flare transition-all duration-200"
                  onClick={() => setIsOpen(false)}
                >
                  <div className="flex items-center gap-2">
                    {item.icon && React.createElement(item.icon, { className: "h-4 w-4" })}
                    <span>{item.name}</span>
                  </div>
                </Link>
              ))}
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}

interface LayoutProps {
  children: React.ReactNode;
  title?: string;
}

export default function Layout({ children, title = "Tools for Tacticians" }: LayoutProps) {
  const router = useRouter();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [isPageTransitioning, setIsPageTransitioning] = useState(false);
  const pageTitle = `MetaForge | ${title}`;
  
  // Handle page transitions
  useEffect(() => {
    const handleRouteChangeStart = () => setIsPageTransitioning(true);
    const handleRouteChangeComplete = () => setIsPageTransitioning(false);
    
    router.events.on('routeChangeStart', handleRouteChangeStart);
    router.events.on('routeChangeComplete', handleRouteChangeComplete);
    
    return () => {
      router.events.off('routeChangeStart', handleRouteChangeStart);
      router.events.off('routeChangeComplete', handleRouteChangeComplete);
    };
  }, [router]);
  
  // Define navigation items
  const statsAndTools: NavItem[] = [
    { name: "Meta Report", href: "/meta-report", icon: TrendingUp },
    { name: "Stats Explorer", href: "/stats-explorer", icon: Search },
    { name: "Team Builder", href: "/team-builder", icon: Layers }
  ];
  
  const resources: NavItem[] = [
    { name: "Guides", href: "/guides", icon: Book },
    { name: "News", href: "/news", icon: Newspaper }
  ];
  
  const community: NavItem[] = [
    { name: "Profile", href: "/profile", icon: User },
    { name: "Leaderboard", href: "/leaderboard", icon: Trophy }
  ];
  
  // Check if any items in a dropdown are active
  const isStatsActive = statsAndTools.some(item => router.pathname === item.href);
  const isResourcesActive = resources.some(item => router.pathname === item.href);
  const isCommunityActive = community.some(item => router.pathname === item.href || router.pathname.startsWith(item.href));

  // Page transitions
  const pageVariants = {
    initial: { opacity: 0, y: 10 },
    animate: { opacity: 1, y: 0 },
    exit: { opacity: 0, y: -10 }
  };

  return (
    <div className="min-h-screen bg-main-bg bg-cover bg-center bg-fixed flex flex-col">
      <Head>
        <title>{pageTitle}</title>
        <meta name="description" content="Master TeamFight Tactics with MetaForge - strategies and tools for tacticians" />
        <link rel="icon" href="/assets/app/app.png" />
      </Head>
      
      <div className="flex-grow flex flex-col min-h-screen bg-void-core/60">
        {/* Desktop and Mobile Navbar with Improved Spacing */}
        <nav className="bg-void-core/95 shadow-eclipse sticky top-0 z-50 border-b border-solar-flare/40">
          <div className="max-w-7xl mx-auto px-2 sm:px-4">
            <div className="flex h-16 items-center justify-between">
              {/* Logo and title */}
              <div className="flex-shrink-0">
                <Link href="/" className="flex items-center gap-2">
                  <div className="relative h-10 w-10 overflow-hidden">
                    <motion.img 
                      src="/assets/app/app.png" 
                      alt="MetaForge" 
                      className="h-10 w-10"
                      onError={(e) => {
                        const target = e.target as HTMLImageElement;
                        target.src = '/assets/app/default.png';
                      }}
                    />
                  </div>
                  <span className="text-xl font-display tracking-tight text-solar-flare">MetaForge</span>
                </Link>
              </div>
              
              {/* Desktop navigation with improved spacing - using flex with justify-between */}
              <div className="hidden md:flex items-center flex-1 ml-2 mt-1 justify-between">
                {/* Left side dropdowns */}
                
                {/* Right side controls */}
                  <div className="flex items-center gap-3">
                    <RegionDropdown />
                    <AuthStatus />
                  </div>
                {/* Search bar with reduced width */}
                <div className="w-60 lg:w-72">
                  <SearchBar />
                </div>
              
                {/* Right side dropdown */} 
                <div className="flex items-center gap-2">
                  <div className="flex items-center gap-2">
                  <NavDropdown 
                    label="Tools" 
                    icon={Slack} 
                    items={statsAndTools} 
                    isActive={isStatsActive} 
                  />
                  
                  <NavDropdown 
                    label="Resources" 
                    icon={Book} 
                    items={resources} 
                    isActive={isResourcesActive} 
                  />
                  <NavDropdown 
                    label="Community" 
                    icon={Users} 
                    items={community} 
                    isActive={isCommunityActive} 
                  />
                </div>
                
                  
                </div>
              </div>  
              
              {/* Mobile menu button */}
              <div className="flex md:hidden">
                <motion.button
                  type="button"
                  className="inline-flex items-center justify-center p-2 rounded-md text-corona-light hover:text-solar-flare hover:bg-eclipse-shadow/30"
                  onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
                  whileHover={{ scale: 1.1 }}
                  whileTap={{ scale: 0.9 }}
                >
                  <span className="sr-only">Open menu</span>
                  {mobileMenuOpen ? (
                    <X className="block h-6 w-6" aria-hidden="true" />
                  ) : (
                    <Menu className="block h-6 w-6" aria-hidden="true" />
                  )}
                </motion.button>
              </div>
            </div>
          </div>
          
          {/* Mobile menu panel with improved animation and styling */}
          <AnimatePresence>
            {mobileMenuOpen && (
              <motion.div 
                className="md:hidden backdrop-filter backdrop-blur-md bg-eclipse-shadow/80"
                initial={{ height: 0, opacity: 0 }}
                animate={{ height: "auto", opacity: 1 }}
                exit={{ height: 0, opacity: 0 }}
                transition={{ duration: 0.3, ease: [0.2, 0.8, 0.2, 1] }}
              >
                <div className="px-2 pt-2 pb-3 space-y-1 border-t border-solar-flare/20">
                  {/* Tools Section */}
                  <div className="flex items-center justify-between">
                    <div className="px-3 py-2 font-medium text-solar-flare">Tools</div>
                  </div>
                  {statsAndTools.map((item, index) => (
                    <motion.div
                      key={item.name}
                      initial={{ opacity: 0, x: -10 }}
                      animate={{ opacity: 1, x: 0 }}
                      transition={{ delay: index * 0.05, duration: 0.3 }}
                    >
                      <Link
                        href={item.href}
                        className={`block px-3 py-2 rounded-md text-sm font-medium ${
                          router.pathname === item.href
                            ? 'text-solar-flare bg-solar-flare/10 border-l-2 border-solar-flare'
                            : 'text-corona-light hover:bg-eclipse-shadow/30'
                        }`}
                        onClick={() => setMobileMenuOpen(false)}
                      >
                        <div className="flex items-center gap-2">
                          {item.icon && React.createElement(item.icon, { className: "h-4 w-4" })}
                          <span>{item.name}</span>
                        </div>
                      </Link>
                    </motion.div>
                  ))}
                  
                  {/* Resources Section */}
                  <div className="flex items-center justify-between mt-2">
                    <div className="px-3 py-2 font-medium text-solar-flare">Resources</div>
                  </div>
                  {resources.map((item, index) => (
                    <motion.div
                      key={item.name}
                      initial={{ opacity: 0, x: -10 }}
                      animate={{ opacity: 1, x: 0 }}
                      transition={{ delay: (index + statsAndTools.length) * 0.05, duration: 0.3 }}
                    >
                      <Link
                        href={item.href}
                        className={`block px-3 py-2 rounded-md text-sm font-medium ${
                          router.pathname === item.href
                            ? 'text-solar-flare bg-solar-flare/10 border-l-2 border-solar-flare'
                            : 'text-corona-light hover:bg-eclipse-shadow/30'
                        }`}
                        onClick={() => setMobileMenuOpen(false)}
                      >
                        <div className="flex items-center gap-2">
                          {item.icon && React.createElement(item.icon, { className: "h-4 w-4" })}
                          <span>{item.name}</span>
                        </div>
                      </Link>
                    </motion.div>
                  ))}
                  
                  {/* Community Section */}
                  <div className="flex items-center justify-between mt-2">
                    <div className="px-3 py-2 font-medium text-solar-flare">Community</div>
                  </div>
                  {community.map((item, index) => (
                    <motion.div
                      key={item.name}
                      initial={{ opacity: 0, x: -10 }}
                      animate={{ opacity: 1, x: 0 }}
                      transition={{ delay: (index + statsAndTools.length + resources.length) * 0.05, duration: 0.3 }}
                    >
                      <Link
                        href={item.href}
                        className={`block px-3 py-2 rounded-md text-sm font-medium ${
                          router.pathname === item.href || router.pathname.startsWith(item.href)
                            ? 'text-solar-flare bg-solar-flare/10 border-l-2 border-solar-flare'
                            : 'text-corona-light hover:bg-eclipse-shadow/30'
                        }`}
                        onClick={() => setMobileMenuOpen(false)}
                      >
                        <div className="flex items-center gap-2">
                          {item.icon && React.createElement(item.icon, { className: "h-4 w-4" })}
                          <span>{item.name}</span>
                        </div>
                      </Link>
                    </motion.div>
                  ))}
                  
                  {/* Region & User Section */}
                  <div className="px-3 py-2 border-t border-solar-flare/20 mt-2">
                    <div className="flex items-center justify-between">
                      <span className="font-medium text-solar-flare">Region</span>
                      <RegionDropdown />
                    </div>
                  </div>
                  
                  <div className="px-3 py-2 border-t border-solar-flare/20 mt-2">
                    <AuthStatus />
                  </div>
                </div>
              </motion.div>
            )}
          </AnimatePresence>
        </nav>
        
        {/* Mobile search */}
        <div className="md:hidden px-4 py-2 bg-void-core/90 border-b border-solar-flare/30">
          <SearchBar />
        </div>
        
        <motion.main 
          className="max-w-7xl w-full mx-auto px-2 sm:px-4 py-6 sm:py-8"
          initial="initial"
          animate="animate"
          exit="exit"
          variants={pageVariants}
          transition={{ duration: 0.4, ease: [0.2, 0.8, 0.2, 1] }}
        >
          {children}
        </motion.main>
        
        <footer className="bg-void-core/95 py-4 border-t border-solar-flare/30 text-center text-sm text-corona-light/70 mt-auto">
          <div className="max-w-7xl mx-auto px-4">
            <p>MetaForge is not endorsed by Riot Games and does not reflect the views or opinions of Riot Games or anyone officially involved in producing or managing League of Legends.</p>
          </div>
        </footer>
      </div>
    </div>
  );
}
EOL

# Create RegionDropdown component
cat > src/components/ui/RegionDropdown.tsx << 'EOL'
import React, { useState, useRef, useEffect } from 'react';
import { ChevronDown, Globe } from 'lucide-react';
import { REGIONS, isRegionGroup, getSubRegions } from '@/utils/useTftData';

export function RegionDropdown() {
  const [isOpen, setIsOpen] = useState(false);
  const [currentRegion, setCurrentRegion] = useState('all');
  const [isMounted, setIsMounted] = useState(false);
  const dropdownRef = useRef<HTMLDivElement | null>(null);
  
  useEffect(() => {
    setIsMounted(true);
    const savedRegion = localStorage.getItem('tft-region');
    if (savedRegion) setCurrentRegion(savedRegion);
  }, []);
  
  useEffect(() => {
    const handleClickOutside = (e: MouseEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(e.target as Node)) {
        setIsOpen(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);
  
  const changeRegion = (regionId: string) => {
    localStorage.setItem('tft-region', regionId);
    window.location.reload();
  };
  
  // Get the regions organized in a hierarchical structure
  const getHierarchicalRegions = () => {
    const parentRegions = REGIONS.filter(r => r.isGroup || r.id === 'all');
    return parentRegions.map(parent => {
      if (parent.isGroup && parent.subRegions) {
        const children = REGIONS.filter(r => parent.subRegions?.includes(r.id));
        return { parent, children };
      }
      return { parent, children: [] };
    });
  };
  
  // Get details for current region
  const getCurrentRegionDetails = () => {
    const region = REGIONS.find(r => r.id === currentRegion);
    if (!region) return REGIONS[0]; // Default to All Regions
    return region;
  };
  
  if (!isMounted) return <div className="h-9 w-9 sm:w-16" />;
  
  const currentRegionDetails = getCurrentRegionDetails();
  const hierarchicalRegions = getHierarchicalRegions();

  return (
    <div className="relative" ref={dropdownRef}>
      <button
  className="flex items-center ml-1 gap-1 px-2 sm:px-3 py-2 rounded-md bg-void-core/30 border border-solar-flare/30 backdrop-blur-sm text-cream hover:bg-gold/10"
  onClick={() => setIsOpen(!isOpen)}
  aria-expanded={isOpen}
  aria-haspopup="true"
>
  <Globe className="h-4 w-4 text-gold" />
  <span className="hidden sm:block text-sm">{currentRegionDetails.name}</span>
  <ChevronDown className="h-3 w-3" />
</button>
      
      {isOpen && (
        <div className="absolute z-50 mt-1 right-0 w-56 rounded-md shadow-lg bg-void-core/50 backdrop-blur-lg border border-solar-flare/30">
          {hierarchicalRegions.map(({ parent, children }) => (
            <div key={parent.id}>
              {/* Parent region */}
              <button
                className={`block w-full text-left px-3 py-1.5 ${
                  parent.id === currentRegion 
                    ? "bg-gold/10 text-gold" 
                    : parent.isGroup 
                      ? "text-gold font-medium"
                      : "hover:bg-gold/5 text-cream"
                }`}
                onClick={() => {
                  setIsOpen(false);
                  changeRegion(parent.id);
                }}
              >
                {parent.name}
              </button>

              {/* Children */}
              {children.length > 0 && (
                <div>
                  {children.map(child => (
                    <button
                      key={child.id}
                      className={`block w-full text-left pl-5 pr-3 py-1 text-sm ${
                        child.id === currentRegion 
                          ? "bg-gold/10 text-gold" 
                          : "hover:bg-gold/5 text-cream/90"
                      }`}
                      onClick={() => {
                        setIsOpen(false);
                        changeRegion(child.id);
                      }}
                    >
                      {child.name}
                    </button>
                  ))}
                </div>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
EOL

# Create SearchBar for app-wide search
cat > src/components/ui/SearchBar.tsx << 'EOL'
import React, { useState, useEffect, useRef, useMemo } from 'react';
import { Search, X } from 'lucide-react';
import Link from 'next/link';
import { useTftData } from '@/utils/useTftData';
import unitsJson from 'public/mapping/units.json';
import traitsJson from 'public/mapping/traits.json';
import itemsJson from 'public/mapping/items.json';
import debounce from 'lodash/debounce';

// Define search result interface
interface SearchResult {
  type: 'units' | 'traits' | 'items' | 'comps';
  id: string;
  name: string;
  icon?: string;
  cost?: number;
  traits?: any[];
}

export default function SearchBar({ className = '' }) {
  // Fix TypeScript error by using type assertion and safe property access
  const tftData = useTftData() as any;
  const data = tftData?.data || null;
  
  const [query, setQuery] = useState('');
  const [results, setResults] = useState<SearchResult[]>([]);
  const [showResults, setShowResults] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const searchRef = useRef<HTMLDivElement>(null);
  
  const debouncedSearch = useMemo(() => debounce((q: string) => {
    if (!q || q.length < 2) {
      setResults([]);
      setIsLoading(false);
      return;
    }
    
    setIsLoading(true);
    q = q.toLowerCase();
    const foundResults: SearchResult[] = [];
    
    // Search units
    Object.entries(unitsJson.units)
      .filter(([_, unit]) => unit.name.toLowerCase().includes(q))
      .slice(0, 3)
      .forEach(([id, unit]) => foundResults.push({
        type: 'units', id, name: unit.name, 
        icon: `/assets/units/${unit.icon}`, cost: unit.cost
      }));
      
    // Search traits
    Object.entries({...traitsJson.origins, ...traitsJson.classes})
      .filter(([_, trait]) => trait.name.toLowerCase().includes(q))
      .slice(0, 3)
      .forEach(([id, trait]) => foundResults.push({
        type: 'traits', id, name: trait.name, icon: `/assets/traits/${trait.icon}`
      }));
      
    // Search items
    Object.entries(itemsJson.items)
      .filter(([_, item]) => item.name.toLowerCase().includes(q))
      .slice(0, 3)
      .forEach(([id, item]) => foundResults.push({
        type: 'items', id, name: item.name, icon: `/assets/items/${item.icon}`
      }));
      
    // Search compositions from data if available
    if (data?.compositions) {
      data.compositions
        .filter((comp: {name: string; id: string; traits?: any[]}) => comp.name.toLowerCase().includes(q))
        .slice(0, 3)
        .forEach((comp: {name: string; id: string; traits?: any[]}) => foundResults.push({
          type: 'comps', id: comp.id, name: comp.name, traits: comp.traits?.slice(0, 2)
        }));
    }
    
    setResults(foundResults);
    setShowResults(foundResults.length > 0);
    setIsLoading(false);
  }, 200), [data]);
  
  useEffect(() => {
    debouncedSearch(query);
    return () => debouncedSearch.cancel();
  }, [query, debouncedSearch]);
  
  useEffect(() => {
    const handleClickOutside = (e: MouseEvent) => {
      if (searchRef.current && !(searchRef.current as HTMLElement).contains(e.target as Node)) {
        setShowResults(false);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);
  
  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Escape') {
      setShowResults(false);
    }
  };
  
  return (
    <div className={`relative w-full ${className}`} ref={searchRef}>
      <div className="relative">
        <input
          type="text"
          placeholder="Search..."
          value={query}
          onChange={e => setQuery(e.target.value)}
          onKeyDown={handleKeyDown}
          onFocus={() => query.length >= 2 && setShowResults(true)}
          aria-label="Search TFT entities"
          className="w-full px-9 py-1.5 bg-brown-light/40 border border-gold/30 rounded-lg focus:outline-none focus:border-gold text-sm"
        />
        <Search className="absolute left-2.5 top-1/2 -translate-y-1/2 text-gold h-4 w-4" />
        {query && (
          <button 
            className="absolute right-2.5 top-1/2 -translate-y-1/2 text-cream/60 hover:text-cream"
            onClick={() => { setQuery(''); setShowResults(false); }}
            aria-label="Clear search"
          >
            <X className="h-4 w-4" />
          </button>
        )}
      </div>

      {showResults && query.length >= 2 && (
        <div className="absolute z-40 w-full mt-1 bg-brown/95 border border-gold/40 rounded-md shadow-lg">
          {isLoading ? (
            <div className="p-3 text-center text-cream/70 text-sm">Searching...</div>
          ) : results.length > 0 ? (
            <div className="max-h-64 overflow-y-auto p-1.5 divide-y divide-gold/20">
              {results.map((result, i) => (
                <Link 
                  href={`/entity/${result.type}/${result.id}`} 
                  key={i}
                  onClick={() => { setShowResults(false); setQuery(''); }}
                >
                  <div className="flex items-center gap-2.5 p-2 hover:bg-gold/10 rounded">
                    {result.type === 'units' && (
                      <div className="w-8 h-8 rounded-full border-2 overflow-hidden flex-shrink-0" 
                           style={{ borderColor: ['#9aa4af', '#2ecc71', '#3498db', '#9b59b6', '#f1c40f'][result.cost as number - 1] || '#9aa4af' }}>
                        <img src={result.icon} alt={result.name} className="w-full h-full object-cover" />
                      </div>
                    )}
                    {result.type === 'traits' && <img src={result.icon} alt={result.name} className="w-7 h-7" />}
                    {result.type === 'items' && <img src={result.icon} alt={result.name} className="w-7 h-7" />}
                    {result.type === 'comps' && (
                      <div className="flex">
                        {result.traits?.map((trait, j) => (
                          <img key={j} src={trait.tierIcon || trait.icon} alt={trait.name} className="w-6 h-6 -ml-1 first:ml-0" />
                        ))}
                      </div>
                    )}
                    <div className="min-w-0 flex-grow">
                      <div className="font-medium text-sm truncate">{result.name}</div>
                      <div className="text-xs text-cream/70 capitalize">{result.type.replace(/s$/, '')}</div>
                    </div>
                  </div>
                </Link>
              ))}
            </div>
          ) : (
            <div className="p-3 text-center text-cream/70 text-sm">No results found</div>
          )}
        </div>
      )}
    </div>
  );
}
EOL

# Export UI components
cat > src/components/ui/index.ts << 'EOL'
export { default as Card } from './Card';
export { default as FilterButtons } from './FilterButtons';
export { default as StatsPanel, PlacementDistribution } from './StatsPanel';
export { default as Layout } from './Layout';
export { default as ErrorMessage } from './ErrorMessage';
export { default as LoadingState } from './LoadingState';
export { default as SearchBar } from './SearchBar';
export { TooltipProvider, useTooltip, renderUnitTooltip, renderItemTooltip, renderTraitTooltip, renderCompTooltip } from './Tooltip';
export { UnitIcon, TraitIcon, ItemIcon, CompIcon, EntityIcon } from './IconComponents';
export { RegionDropdown } from './RegionDropdown';
EOL

# Update common/index.ts to export the new SelectDropdown component
cat > src/components/common/index.ts << 'EOL'
export { HeaderBanner } from './HeaderBanner';
export { FeatureBanner, FeatureCard, FeatureCardsContainer } from './FeatureBanner';
export { ErrorBanner } from './ErrorBanner';
export { LoadingSpinner, LoadingOverlay } from './LoadingSpinner';
export { StatsCarousel } from './StatsCarousel';
export { EntityTabs, SelectDropdown, ContextualFilterSidebar } from './EntityTabs';
export { MetaHighlightCard } from './MetaHighlightCard';
export { MetaInsightsDashboard } from './MetaInsightsDashboard';
export type { EntityType, FilterOption, FilterState } from './EntityTabs';
EOL

# Update MetaHighlightCard component
cat > src/components/common/MetaHighlightCard.tsx << 'EOL'
import React from 'react';
import Link from 'next/link';
import { motion } from 'framer-motion';
import { getEntityIcon, DEFAULT_ICONS } from '@/utils/paths';
import { HighlightEntity, EntityType } from '@/utils/useTftData';
import { parseCompTraits } from '@/utils/dataProcessing';

interface MetaHighlightCardProps {
  highlight: HighlightEntity | null;
  title: string;
  icon: React.ReactNode;
}

export function MetaHighlightCard({
  highlight,
  title,
  icon
}: MetaHighlightCardProps) {
  if (!highlight) {
    return (
      <motion.div 
        className="h-full border border-solar-flare/30 rounded-xl bg-eclipse-shadow/5 backdrop-filter backdrop-blur-md transition-all min-h-[120px]"
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.4, ease: [0.2, 0.8, 0.2, 1] }}
      >
        <div className="flex items-center justify-center py-2 px-3 bg-eclipse-shadow/60 border-b border-solar-flare/30 rounded-t-xl">
          <div className="flex items-center justify-center gap-2">
            {icon}
            <h3 className="text-solar-flare text-base font-display tracking-tight">{title}</h3>
          </div>
        </div>
        <div className="relative h-20">
          <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2">
            <p className="text-sm text-corona-light/70">No data available</p>
          </div>
        </div>
      </motion.div>
    );
  }

  const displayTitle = highlight.variant && highlight.variant !== 'Overall' ? 
    `${title}: ${highlight.variant}` : 
    title;

  const renderEntityImage = () => {
    if (highlight.entityType === EntityType.Unit) {
      return (
        <motion.div 
          className="w-12 h-12 rounded-full border-2 border-solar-flare/30 overflow-hidden flex-shrink-0"
          whileHover={{ scale: 1.1 }}
          transition={{ duration: 0.3 }}
        >
          <img 
            src={getEntityIcon(highlight.entity, 'unit')} 
            alt={highlight.value} 
            className="w-full h-full object-cover" 
            onError={(e) => {
              const target = e.target as HTMLImageElement;
              target.src = DEFAULT_ICONS.unit;
            }}
          />
        </motion.div>
      );
    }
    
    if (highlight.entityType === EntityType.Item) {
      return (
        <motion.img 
          src={getEntityIcon(highlight.entity, 'item')} 
          alt={highlight.value} 
          className="w-12 h-12 object-contain" 
          whileHover={{ scale: 1.1 }}
          transition={{ duration: 0.3 }}
          onError={(e) => {
            const target = e.target as HTMLImageElement;
            target.src = DEFAULT_ICONS.item;
          }}
        />
      );
    }
    
    if (highlight.entityType === EntityType.Trait) {
      return (
        <motion.img 
          src={getEntityIcon(highlight.entity, 'trait')} 
          alt={highlight.value} 
          className="w-12 h-12 object-contain" 
          whileHover={{ scale: 1.1 }}
          transition={{ duration: 0.3 }}
          onError={(e) => {
            const target = e.target as HTMLImageElement;
            target.src = DEFAULT_ICONS.trait;
          }}
        />
      );
    }
    
    if (highlight.entityType === EntityType.Comp) {
      return (
        <div className="flex gap-1 flex-wrap justify-center ml-2">
          {parseCompTraits(highlight.entity.name, highlight.entity.traits || []).map((trait: any, i: number) => (
            <motion.img 
              key={i} 
              src={getEntityIcon(trait, 'trait')} 
              alt={trait.name} 
              className="w-8 h-8" 
              whileHover={{ scale: 1.1, rotate: 5 }}
              transition={{ duration: 0.3 }}
              onError={(e) => {
                const target = e.target as HTMLImageElement;
                target.src = DEFAULT_ICONS.trait;
              }}
            />
          ))}
        </div>
      );
    }
    
    return (
      <div className="w-12 h-12 bg-eclipse-shadow/50 rounded-full flex items-center justify-center">
        {icon}
      </div>
    );
  };

  return (
    <motion.div 
      className="h-full flex flex-col border border-solar-flare/30 rounded-xl bg-eclipse-shadow/5 backdrop-filter backdrop-blur-md transition-all min-h-[120px]"
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.4, ease: [0.2, 0.8, 0.2, 1] }}
      whileHover={{ 
        boxShadow: "0 10px 25px -5px rgba(245, 158, 11, 0.2)",
        borderColor: "rgba(245, 158, 11, 0.5)"
      }}
    >
      <div className="flex items-center justify-center py-2 px-3 rounded-t-xl bg-eclipse-shadow/60 border-b border-solar-flare/30">
        <div className="flex items-center justify-center gap-2">
          {icon}
          <h3 className="text-solar-flare text-base text-xl font-display tracking-tight">{displayTitle}</h3>
        </div>
      </div>
      <Link href={highlight.link} className="flex-1 relative">
        <motion.div 
          className="absolute inset-0 hover:bg-eclipse-shadow/50 hover:border-solar-flare/50 transition-all ease-in-out rounded-b-xl"
          whileHover={{ scale: 1.02 }}
        >
          <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 flex items-center gap-3">
            <div className="flex-shrink-0">
              {renderEntityImage()}
            </div>
            <div className="min-w-0">
              <div className="font-medium truncate text-corona-light">{highlight.value}</div>
              <div className="text-xs text-corona-light/70 truncate">{highlight.detail}</div>
            </div>
          </div>
        </motion.div>
      </Link>
    </motion.div>
  );
}
EOL

# Fix 1: Update MetaInsightsDashboard with proper theming and engaging TFT wording
cat > src/components/common/MetaInsightsDashboard.tsx << 'EOL'
import React, { useState, useMemo } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import Link from 'next/link';
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, Cell, PieChart, Pie, LineChart, Line, RadialBarChart, RadialBar } from 'recharts';
import { 
  ChevronUp, 
  ChevronDown, 
  TrendingUp, 
  Activity, 
  Medal, 
  Sparkles, 
  Crown,
  Target,
  Zap,
  BarChart3,
  PieChart as PieChartIcon,
  LineChart as LineChartIcon,
  Eye,
  Star,
  DollarSign,
  Shield
} from 'lucide-react';
import { UnitIcon, TraitIcon, ItemIcon } from '@/components/ui';
import { useTftData } from '@/utils/useTftData';
import { parseCompTraits } from '@/utils/dataProcessing';
import { getEntityIcon, DEFAULT_ICONS, getCostColor } from '@/utils/paths';

interface InsightCard {
  title: string;
  icon: React.ReactNode;
  data: any[];
  metric: string;
  formatter: (value: number) => string;
}

export function MetaInsightsDashboard() {
  const [activeInsight, setActiveInsight] = useState<string>('meta-overview');
  const tftData = useTftData() as any;
  const data = tftData?.data || null;
  
  if (!data?.compositions) return null;
  
  // Process comprehensive meta data with TFT-focused insights
  const metaAnalysis = useMemo(() => {
    const units: Record<string, any> = {};
    const traits: Record<string, any> = {};
    const items: Record<string, any> = {};
    const placements = Array(8).fill(0).map((_, i) => ({ 
      placement: i + 1, 
      count: 0,
      name: i === 0 ? '1st' : i === 1 ? '2nd' : i === 2 ? '3rd' : `${i + 1}th`,
      percentage: 0
    }));
    
    let totalGames = 0;
    let highRollGames = 0; // Games with top 3 finish
    let topDecileGames = 0; // Games in top 10% of compositions by winrate
    
    // Enhanced data processing with meta insights
    data.compositions.forEach((comp: any) => {
      const compGames = comp.count || 1;
      totalGames += compGames;
      
      // Track placement distribution properly
      if (comp.placementData && Array.isArray(comp.placementData)) {
        comp.placementData.forEach((p: any) => {
          const placementIndex = p.placement - 1;
          if (placementIndex >= 0 && placementIndex < 8) {
            placements[placementIndex].count += p.count || 0;
          }
        });
      } else {
        // Fallback: estimate placement distribution from average placement
        const avgPlace = comp.avgPlacement || 4.5;
        const placementIndex = Math.round(avgPlace - 1);
        if (placementIndex >= 0 && placementIndex < 8) {
          placements[placementIndex].count += compGames;
        }
      }
      
      // Identify high-roll and meta compositions
      if ((comp.winRate || 0) > 15) highRollGames += compGames;
      if ((comp.winRate || 0) > 20) topDecileGames += compGames;
      
      // Process units with enhanced metrics
      comp.units.forEach((unit: any) => {
        if (!units[unit.id]) {
          units[unit.id] = { 
            ...unit, 
            count: 0, 
            games: 0,
            winRateSum: 0, 
            top4RateSum: 0, 
            placementSum: 0,
            flexibility: new Set(), // Different comps this unit appears in
            itemSynergy: {}, // Items that pair well with this unit
            costEfficiency: 0 // Performance relative to cost
          };
        }
        
        const unitEntity = units[unit.id];
        unitEntity.count += compGames;
        unitEntity.games += compGames;
        unitEntity.placementSum += (comp.avgPlacement || 0) * compGames;
        unitEntity.winRateSum += ((comp.winRate || 0) / 100) * compGames;
        unitEntity.top4RateSum += ((comp.top4Rate || 0) / 100) * compGames;
        unitEntity.flexibility.add(comp.id);
        
        // Track item synergies
        if (unit.items) {
          unit.items.forEach((item: any) => {
            if (!unitEntity.itemSynergy[item.id]) {
              unitEntity.itemSynergy[item.id] = { count: 0, winRateSum: 0 };
            }
            unitEntity.itemSynergy[item.id].count += compGames;
            unitEntity.itemSynergy[item.id].winRateSum += ((comp.winRate || 0) / 100) * compGames;
          });
        }
      });
      
      // Process traits with tier analysis
      comp.traits.forEach((trait: any) => {
        const traitKey = `${trait.id}-${trait.tier}`;
        
        if (!traits[traitKey]) {
          traits[traitKey] = { 
            ...trait,
            traitId: trait.id,
            count: 0, 
            games: 0,
            winRateSum: 0, 
            top4RateSum: 0, 
            placementSum: 0,
            tierDistribution: Array(5).fill(0), // Track tier distribution
            unitSynergy: {}, // Units that work well with this trait
            difficulty: 0 // How hard is it to achieve this trait
          };
        }
        
        const traitEntity = traits[traitKey];
        traitEntity.count += compGames;
        traitEntity.games += compGames;
        traitEntity.placementSum += (comp.avgPlacement || 0) * compGames;
        traitEntity.winRateSum += ((comp.winRate || 0) / 100) * compGames;
        traitEntity.top4RateSum += ((comp.top4Rate || 0) / 100) * compGames;
        traitEntity.tierDistribution[trait.tier - 1] += compGames;
        
        // Track unit synergies
        comp.units.forEach((unit: any) => {
          if (!traitEntity.unitSynergy[unit.id]) {
            traitEntity.unitSynergy[unit.id] = { count: 0, winRateSum: 0 };
          }
          traitEntity.unitSynergy[unit.id].count += compGames;
          traitEntity.unitSynergy[unit.id].winRateSum += ((comp.winRate || 0) / 100) * compGames;
        });
      });
      
      // Process items with enhanced analysis
      comp.units.forEach((unit: any) => {
        if (!unit.items) return;
        
        unit.items.forEach((item: any) => {
          if (!items[item.id]) {
            items[item.id] = { 
              ...item, 
              count: 0, 
              games: 0,
              winRateSum: 0, 
              top4RateSum: 0, 
              placementSum: 0,
              versatility: new Set(), // Different units this item appears on
              carrySynergy: 0, // How well it works on carry units
              supportSynergy: 0, // How well it works on support units
              contestation: 0 // How contested this item is
            };
          }
          
          const itemEntity = items[item.id];
          itemEntity.count += compGames;
          itemEntity.games += compGames;
          itemEntity.placementSum += (comp.avgPlacement || 0) * compGames;
          itemEntity.winRateSum += ((comp.winRate || 0) / 100) * compGames;
          itemEntity.top4RateSum += ((comp.top4Rate || 0) / 100) * compGames;
          itemEntity.versatility.add(unit.id);
          
          // Determine if this is on a carry or support unit (based on cost)
          if (unit.cost >= 4) {
            itemEntity.carrySynergy += ((comp.winRate || 0) / 100) * compGames;
          } else {
            itemEntity.supportSynergy += ((comp.winRate || 0) / 100) * compGames;
          }
        });
      });
    });
    
    // Calculate final metrics for units
    Object.values(units).forEach((unit: any) => {
      unit.avgPlacement = unit.placementSum / unit.games;
      unit.winRate = (unit.winRateSum / unit.games) * 100;
      unit.top4Rate = (unit.top4RateSum / unit.games) * 100;
      unit.playRate = (unit.games / totalGames) * 100;
      unit.flexibilityScore = unit.flexibility.size;
      unit.costEfficiency = (unit.winRate || 0) / Math.max(unit.cost || 1, 1);
      
      // Calculate best items for this unit
      unit.bestItems = Object.entries(unit.itemSynergy)
        .map(([itemId, synergy]: [string, any]) => ({
          itemId,
          winRate: (synergy.winRateSum / synergy.count) * 100,
          count: synergy.count
        }))
        .sort((a, b) => b.winRate - a.winRate)
        .slice(0, 3);
    });
    
    // Calculate final metrics for traits
    Object.values(traits).forEach((trait: any) => {
      trait.avgPlacement = trait.placementSum / trait.games;
      trait.winRate = (trait.winRateSum / trait.games) * 100;
      trait.top4Rate = (trait.top4RateSum / trait.games) * 100;
      trait.playRate = (trait.games / totalGames) * 100;
      trait.difficulty = trait.tierDistribution[3] + trait.tierDistribution[4]; // Higher tiers = more difficult
      
      // Calculate best units for this trait
      trait.bestUnits = Object.entries(trait.unitSynergy)
        .map(([unitId, synergy]: [string, any]) => ({
          unitId,
          winRate: (synergy.winRateSum / synergy.count) * 100,
          count: synergy.count
        }))
        .sort((a, b) => b.winRate - a.winRate)
        .slice(0, 3);
    });
    
    // Calculate final metrics for items
    Object.values(items).forEach((item: any) => {
      item.avgPlacement = item.placementSum / item.games;
      item.winRate = (item.winRateSum / item.games) * 100;
      item.top4Rate = (item.top4RateSum / item.games) * 100;
      item.playRate = (item.games / totalGames) * 100;
      item.versatilityScore = item.versatility.size;
      item.carryEfficiency = item.carrySynergy / Math.max(item.games * 0.01, 1);
      item.supportEfficiency = item.supportSynergy / Math.max(item.games * 0.01, 1);
    });
    
    // Calculate percentage for placement distribution
    const totalPlacementGames = placements.reduce((sum, p) => sum + p.count, 0);
    placements.forEach(p => {
      p.percentage = totalPlacementGames > 0 ? (p.count / totalPlacementGames) * 100 : 0;
    });
    
    // Meta game health metrics - TFT focused
    const metaHealth = {
      diversity: Object.values(units).filter((u: any) => u.playRate > 5).length,
      balance: Math.max(0, 1 - (Math.max(...Object.values(units).map((u: any) => u.playRate)) / 100)),
      competitiveness: Math.min(1, topDecileGames / totalGames),
      consistency: Math.max(0, 1 - (placements[0].count + placements[1].count + placements[2].count) / totalGames),
      skillExpression: Math.min(1, highRollGames / totalGames)
    };
    
    return {
      units: Object.values(units),
      traits: Object.values(traits),
      items: Object.values(items),
      placements,
      metaHealth,
      totalGames,
      compositions: data.compositions.length,
      totalPlacementGames // Add this to the return so it's available
    };
  }, [data]);
  
  // Define insight cards with TFT-focused wording and theme colors
  const insightCards: Record<string, InsightCard> = {
    'meta-overview': {
      title: 'Meta Pulse',
      icon: <Activity className="h-6 w-6" />,
      data: [
        { name: 'Champion Diversity', value: metaAnalysis.metaHealth.diversity, max: 50 },
        { name: 'Balance Score', value: metaAnalysis.metaHealth.balance * 100, max: 100 },
        { name: 'High-Roll Factor', value: metaAnalysis.metaHealth.competitiveness * 100, max: 100 },
        { name: 'Consistency Index', value: metaAnalysis.metaHealth.consistency * 100, max: 100 },
        { name: 'Skill Expression', value: metaAnalysis.metaHealth.skillExpression * 100, max: 100 }
      ],
      metric: 'score',
      formatter: (value: number) => `${value.toFixed(1)}%`
    },
    'top-carries': {
      title: 'Elite Carries',
      icon: <Crown className="h-6 w-6" />,
      data: metaAnalysis.units
        .filter(unit => unit.cost >= 3) // 3+ cost units can be true carries
        .sort((a, b) => (b.winRate * b.playRate) - (a.winRate * a.playRate)) // Sort by impact (winrate * playrate)
        .slice(0, 6)
        .map(unit => ({
          name: unit.name,
          value: unit.winRate * unit.playRate / 100, // Impact score
          cost: unit.cost,
          winRate: unit.winRate,
          playRate: unit.playRate,
          entity: unit
        })),
      metric: 'impact',
      formatter: (value: number) => `${value.toFixed(1)} impact`
    },
    'flex-picks': {
      title: 'Flex Champions',
      icon: <Target className="h-6 w-6" />,
      data: metaAnalysis.units
        .filter(unit => unit.flexibilityScore >= 3)
        .sort((a, b) => b.flexibilityScore - a.flexibilityScore)
        .slice(0, 6)
        .map(unit => ({
          name: unit.name,
          value: unit.flexibilityScore,
          winRate: unit.winRate,
          playRate: unit.playRate,
          entity: unit
        })),
      metric: 'comps',
      formatter: (value: number) => `${value} comps`
    },
    'trait-dominance': {
      title: 'Trait Dominance',
      icon: <Crown className="h-6 w-6" />,
      data: metaAnalysis.traits
        .sort((a, b) => (b.winRate * b.playRate) - (a.winRate * a.playRate))
        .slice(0, 6)
        .map(trait => ({
          name: trait.name,
          value: trait.winRate * trait.playRate / 100,
          tier: trait.tier,
          winRate: trait.winRate,
          playRate: trait.playRate,
          entity: trait
        })),
      metric: 'impact',
      formatter: (value: number) => `${value.toFixed(1)}`
    },
    'item-priority': {
      title: 'Item Priority',
      icon: <Star className="h-6 w-6" />,
      data: metaAnalysis.items
        .sort((a, b) => (b.winRate + b.versatilityScore * 2) - (a.winRate + a.versatilityScore * 2))
        .slice(0, 6)
        .map(item => ({
          name: item.name,
          value: item.winRate + item.versatilityScore * 2,
          winRate: item.winRate,
          versatility: item.versatilityScore,
          entity: item
        })),
      metric: 'priority',
      formatter: (value: number) => `${value.toFixed(1)}`
    },
    'comp-distribution': {
      title: 'Comp Distribution',
      icon: <PieChartIcon className="h-6 w-6" />,
      data: metaAnalysis.placements.map(p => ({
        name: p.name,
        value: p.count,
        percentage: metaAnalysis.totalPlacementGames > 0 ? (p.count / metaAnalysis.totalPlacementGames) * 100 : 0,
        placement: p.placement
      })),
      metric: 'games',
      formatter: (value: number) => `${value.toLocaleString()} games`
    }
  };
  
  const activeCard = insightCards[activeInsight];
  
  // Custom tooltip components using theme colors
  const CustomTooltip = ({ active, payload, label }: any) => {
    if (active && payload && payload.length) {
      const data = payload[0].payload;
      return (
        <div className="bg-brown-dark/95 border border-gold/30 rounded-lg p-3 text-sm backdrop-blur-sm shadow-xl">
          <p className="text-gold font-medium">{label}</p>
          {payload.map((entry: any, index: number) => (
            <p key={index} className="text-cream">
              {`${entry.name}: ${activeCard.formatter(entry.value)}`}
            </p>
          ))}
          {data.winRate && (
            <p className="text-cream/70 text-xs mt-1">
              Win Rate: {data.winRate.toFixed(1)}%
            </p>
          )}
        </div>
      );
    }
    return null;
  };
  
  // Generate chart component based on insight type
  const renderChart = () => {
    if (!activeCard.data.length) {
      return (
        <div className="flex items-center justify-center h-full">
          <div className="text-center text-cream/60">
            <Activity className="h-12 w-12 mx-auto mb-2 opacity-50" />
            <p>No data available</p>
          </div>
        </div>
      );
    }
    
    switch (activeInsight) {
      case 'meta-overview':
        return (
          <RadialBarChart width={300} height={300} cx={150} cy={150} innerRadius="20%" outerRadius="80%" data={activeCard.data}>
            <RadialBar dataKey="value" cornerRadius={10} fill="#f59e0b" />
            <Tooltip content={<CustomTooltip />} />
          </RadialBarChart>
        );
        
      case 'comp-distribution':
        return (
          <BarChart width={400} height={300} data={activeCard.data} margin={{ top: 20, right: 30, left: 20, bottom: 5 }}>
            <XAxis 
              dataKey="name" 
              tick={{ fontSize: 12, fill: '#f3f4f6' }} 
            />
            <YAxis tick={{ fontSize: 12, fill: '#f3f4f6' }} />
            <Tooltip content={<CustomTooltip />} />
            <Bar dataKey="value" radius={[4, 4, 0, 0]}>
              {activeCard.data.map((entry, index) => {
                // Use theme colors for placement bars - better for placement analysis
                const getPlacementColor = (placement: number) => {
                  if (placement <= 1) return '#f59e0b'; // Gold for 1st
                  if (placement <= 4) return '#d97706'; // Amber for top 4
                  if (placement <= 6) return '#92400e'; // Brown-600 for mid
                  return '#78716c'; // Stone-500 for bot
                };
                return (
                  <Cell key={`cell-${index}`} fill={getPlacementColor(entry.placement)} />
                );
              })}
            </Bar>
          </BarChart>
        );
        
      default:
        return (
          <BarChart width={400} height={300} data={activeCard.data} margin={{ top: 20, right: 30, left: 20, bottom: 5 }}>
            <XAxis 
              dataKey="name" 
              tick={{ fontSize: 12, fill: '#f3f4f6' }} 
              angle={-45} 
              textAnchor="end" 
              height={80}
            />
            <YAxis tick={{ fontSize: 12, fill: '#f3f4f6' }} />
            <Tooltip content={<CustomTooltip />} />
            <Bar dataKey="value" radius={[4, 4, 0, 0]}>
              {activeCard.data.map((entry, index) => (
                <Cell 
                  key={`cell-${index}`} 
                  fill={`rgba(245, 158, 11, ${0.9 - index * 0.1})`} // Gold theme with opacity
                />
              ))}
            </Bar>
          </BarChart>
        );
    }
  };
  
  return (
    <div className="bg-brown/5 border border-gold/20 rounded-lg backdrop-blur-md overflow-hidden mt-6">
      <div className="bg-brown/60 border-b border-gold/30 p-4">
        <h2 className="text-2xl text-gold mb-4 font-display flex items-center gap-3">
          <BarChart3 className="h-6 w-6" />
          Meta Dashboard
        </h2>
        
        {/* Insight Navigation - themed properly */}
        <div className="flex flex-wrap gap-2">
          {Object.entries(insightCards).map(([key, card]) => (
            <motion.button
              key={key}
              onClick={() => setActiveInsight(key)}
              className={`px-4 py-2 rounded-lg flex items-center gap-2 transition-all duration-200 ${
                activeInsight === key
                  ? 'bg-gold text-brown-dark shadow-lg font-medium'
                  : 'bg-brown-light/30 text-cream/70 hover:bg-brown-light/50 hover:text-cream'
              }`}
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
            >
              {card.icon}
              <span className="text-sm font-medium">{card.title}</span>
            </motion.button>
          ))}
        </div>
      </div>
      
      <AnimatePresence mode="wait">
        <motion.div
          key={activeInsight}
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          exit={{ opacity: 0, y: -20 }}
          transition={{ duration: 0.3 }}
          className="p-6"
        >
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            {/* Chart Section */}
            <div className="bg-brown-light/20 rounded-lg p-4 border border-gold/10">
              <h3 className="text-lg text-gold mb-4 flex items-center gap-2">
                {activeCard.icon}
                {activeCard.title}
              </h3>
              <div className="flex justify-center">
                <ResponsiveContainer width="100%" height={300}>
                  {renderChart()}
                </ResponsiveContainer>
              </div>
            </div>
            
            {/* Detailed Breakdown */}
            <div className="bg-brown-light/20 rounded-lg p-4 border border-gold/10">
              <h3 className="text-lg text-gold mb-4">Ranked Champions</h3>
              <div className="space-y-3 max-h-80 overflow-y-auto custom-scrollbar">
                {activeCard.data.slice(0, 8).map((item, index) => (
                  <motion.div
                    key={index}
                    className="bg-brown-light/30 rounded-lg p-3 hover:bg-brown-light/40 transition-colors border border-gold/5"
                    initial={{ opacity: 0, x: -20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: index * 0.1 }}
                  >
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-3">
                        {item.entity && (
                          <div className="flex-shrink-0">
                            {activeInsight.includes('unit') || activeInsight === 'top-carries' || activeInsight === 'flex-picks' ? (
                              <img 
                                src={getEntityIcon(item.entity, 'unit')} 
                                alt={item.name}
                                className={`w-8 h-8 rounded-full border-2`}
                                style={{ borderColor: getCostColor(item.entity.cost) }}
                                onError={(e) => {
                                  const target = e.target as HTMLImageElement;
                                  target.src = DEFAULT_ICONS.unit;
                                }}
                              />
                            ) : activeInsight === 'trait-dominance' ? (
                              <img 
                                src={getEntityIcon(item.entity, 'trait')} 
                                alt={item.name}
                                className="w-8 h-8 object-contain"
                                onError={(e) => {
                                  const target = e.target as HTMLImageElement;
                                  target.src = DEFAULT_ICONS.trait;
                                }}
                              />
                            ) : activeInsight === 'item-priority' ? (
                              <img 
                                src={getEntityIcon(item.entity, 'item')} 
                                alt={item.name}
                                className="w-8 h-8 object-contain"
                                onError={(e) => {
                                  const target = e.target as HTMLImageElement;
                                  target.src = DEFAULT_ICONS.item;
                                }}
                              />
                            ) : null}
                          </div>
                        )}
                        <div>
                          <div className="text-cream font-medium text-sm">{item.name}</div>
                          <div className="text-cream/60 text-xs">
                            {activeCard.formatter(item.value)}
                            {item.winRate && ` • ${item.winRate.toFixed(1)}% WR`}
                            {item.playRate && ` • ${item.playRate.toFixed(1)}% PR`}
                          </div>
                        </div>
                      </div>
                      
                      <div className="text-right">
                        <div className="text-lg font-bold text-gold">
                          #{index + 1}
                        </div>
                        {activeInsight === 'top-carries' && (
                          <div className="text-xs text-cream/60">
                            {item.cost}🪙
                          </div>
                        )}
                        {activeInsight === 'trait-dominance' && (
                          <div className="text-xs text-cream/60">
                            Tier {item.tier}
                          </div>
                        )}
                      </div>
                    </div>
                  </motion.div>
                ))}
              </div>
            </div>
          </div>
          
          {/* Additional insights based on active card */}
          {activeInsight === 'meta-overview' && (
            <div className="mt-6 bg-brown-light/20 rounded-lg p-4 border border-gold/10">
              <h3 className="text-lg text-gold mb-4">Current Meta Snapshot</h3>
              <div className="grid grid-cols-2 md:grid-cols-5 gap-4 text-center">
                <div>
                  <div className="text-2xl font-bold text-cream">{metaAnalysis.compositions}</div>
                  <div className="text-sm text-cream/60">Meta Comps</div>
                </div>
                <div>
                  <div className="text-2xl font-bold text-cream">{metaAnalysis.totalGames.toLocaleString()}</div>
                  <div className="text-sm text-cream/60">Games Analyzed</div>
                </div>
                <div>
                  <div className="text-2xl font-bold text-cream">{(metaAnalysis.metaHealth.diversity)}</div>
                  <div className="text-sm text-cream/60">Playable Units</div>
                </div>
                <div>
                  <div className="text-2xl font-bold text-cream">{(metaAnalysis.metaHealth.balance * 100).toFixed(1)}%</div>
                  <div className="text-sm text-cream/60">Balance Health</div>
                </div>
                <div>
                  <div className="text-2xl font-bold text-cream">{(metaAnalysis.metaHealth.skillExpression * 100).toFixed(1)}%</div>
                  <div className="text-sm text-cream/60">Skill Factor</div>
                </div>
              </div>
            </div>
          )}

          {/* Elite Carries Explanation */}
          {activeInsight === 'top-carries' && (
            <div className="mt-6 bg-brown-light/20 rounded-lg p-4 border border-gold/10">
              <h3 className="text-lg text-gold mb-4">What Makes an Elite Carry?</h3>
              <p className="text-cream/80 text-sm leading-relaxed">
                Elite carries are high-cost units that consistently win games. We look at both win rate and play rate 
                to find champions that actually carry when used. These units deserve your best items and should be 
                prioritized in your item allocation strategy.
              </p>
            </div>
          )}

          {/* Comp Distribution Explanation */}
          {activeInsight === 'comp-distribution' && (
            <div className="mt-6 bg-brown-light/20 rounded-lg p-4 border border-gold/10">
              <h3 className="text-lg text-gold mb-4">Composition Placement Analysis</h3>
              <div className="grid grid-cols-2 md:grid-cols-4 gap-4 text-center">
                <div>
                  <div className="text-xl font-bold text-gold">
                    {((metaAnalysis.placements[0]?.count || 0) / metaAnalysis.totalGames * 100).toFixed(1)}%
                  </div>
                  <div className="text-xs text-cream/60">1st Place Rate</div>
                </div>
                <div>
                  <div className="text-xl font-bold text-cream">
                    {(metaAnalysis.placements.slice(0, 4).reduce((sum, p) => sum + (p.count || 0), 0) / metaAnalysis.totalGames * 100).toFixed(1)}%
                  </div>
                  <div className="text-xs text-cream/60">Top 4 Rate</div>
                </div>
                <div>
                  <div className="text-xl font-bold text-cream">
                    {(metaAnalysis.placements.slice(0, 4).reduce((sum, p) => sum + (p.count || 0), 0) / metaAnalysis.placements.reduce((sum, p) => sum + (p.count || 0), 0) * 100).toFixed(1)}%
                  </div>
                  <div className="text-xs text-cream/60">Top 4 of Total</div>
                </div>
                <div>
                  <div className="text-xl font-bold text-cream">
                    {(metaAnalysis.placements.reduce((sum, p, i) => sum + (p.count || 0) * (i + 1), 0) / metaAnalysis.placements.reduce((sum, p) => sum + (p.count || 0), 0)).toFixed(2)}
                  </div>
                  <div className="text-xs text-cream/60">Average Place</div>
                </div>
              </div>
            </div>
          )}
        </motion.div>
      </AnimatePresence>
    </div>
  );
}
EOL

# Fix 2: Update meta-report page to use proper color scheme throughout
cat > src/pages/meta-report/index.tsx << 'EOL'
import { useState, useMemo, useEffect, useCallback } from 'react';
import { Layout, Card, UnitIcon, ItemIcon } from '@/components/ui';
import { FeatureBanner, HeaderBanner, StatsCarousel, EntityTabs, MetaHighlightCard, MetaInsightsDashboard } from '@/components/common';
import type { EntityType, FilterState } from '@/components/common';
import { useTftData, useTierLists, HighlightType, EntityType as HighlightEntityType } from '@/utils/useTftData';
import Link from 'next/link';
import { Trophy, Star, Medal, Users, Shield, ChevronDown, ChevronUp, Sparkles, Crown } from 'lucide-react';
import { parseCompTraits } from '@/utils/dataProcessing';
import { getEntityIcon, DEFAULT_ICONS, getTraitInfo } from '@/utils/paths';
import { BaseStats } from '@/types';
import itemsJson from 'public/mapping/items.json';
import traitsJson from 'public/mapping/traits.json';
import { motion, AnimatePresence } from 'framer-motion';

export default function MetaReport() {
  const tftDataResult = useTftData() as unknown as Record<string, any>;
  
  const data = tftDataResult?.data ?? null;
  const isLoading = tftDataResult?.isLoading ?? false;
  const error = tftDataResult?.error ?? null;
  const handleRetry = tftDataResult?.handleRetry ?? (() => {});
  const highlights = tftDataResult?.highlights ?? [];
  
  const tierLists = useTierLists();
  const [activeTab, setActiveTab] = useState<EntityType>('units');
  const [filter, setFilter] = useState<FilterState>({ all: true });
  const [expandedTiers, setExpandedTiers] = useState<Record<string, boolean>>({
    S: true, A: true, B: true, C: false
  });

  // Reset filter when changing tabs
  useEffect(() => {
    setFilter({ all: true });
  }, [activeTab]);

  // Get category options based on active tab
  const categoryOptions = useMemo(() => {
    switch(activeTab) {
      case 'units':
        return [1, 2, 3, 4, 5].map(cost => ({ id: String(cost), name: `${cost} 🪙` }));
      case 'items':
        const categories = new Set<string>();
        Object.values(itemsJson.items).forEach(item => {
          if (item.category && !['component', 'tactician'].includes(item.category)) {
            categories.add(item.category);
          }
        });
        return Array.from(categories).map(category => ({
          id: category,
          name: category.replace(/-/g, ' ').replace(/\b\w/g, c => c.toUpperCase())
        }));
      case 'traits':
        return [{ id: 'origin', name: 'Origins' }, { id: 'class', name: 'Classes' }];
      case 'comps':
        return [
          { id: 'fast9', name: 'Fast 9' },
          { id: 'reroll', name: 'Reroll' },
          { id: 'standard', name: 'Standard' }
        ];
      default:
        return [];
    }
  }, [activeTab]);

  // Filter entities based on current filter
  const filterEntity = useCallback((entity: any): boolean => {
    if (filter.all) return true;
    
    const isOriginTrait = (traitId: string): boolean => (
      Object.keys(traitsJson.origins).includes(traitId)
    );
  
    const getCompType = (comp: any): string => {
      if (!comp.units) return 'standard';
      const highCostUnits = comp.units.filter((u: any) => u.cost >= 4).length >= 3;
      const lowCostUnits = comp.units.filter((u: any) => u.cost <= 2).length >= 4;
      return highCostUnits ? 'fast9' : lowCostUnits ? 'reroll' : 'standard';
    };
    
    switch(activeTab) {
      case 'units':
        return entity.cost && filter[String(entity.cost)];
      case 'items':
        return entity.category && filter[entity.category];
      case 'traits':
        const isOrigin = isOriginTrait(entity.id);
        return (isOrigin && filter.origin) || (!isOrigin && filter.class);
      case 'comps':
        return filter[getCompType(entity)];
      default:
        return true;
    }
  }, [filter, activeTab]);

  // Apply filters to tier list
  const filteredTierList = useMemo(() => {
    if (!tierLists || filter.all) return tierLists;
    
    const result = {...tierLists};
    const list = result[activeTab as keyof typeof result];
    
    Object.keys(list).forEach(tier => {
      list[tier as keyof typeof list] = list[tier as keyof typeof list].filter(filterEntity);
    });
    
    return result;
  }, [tierLists, filter, activeTab, filterEntity]);

  // Filter highlights
  const filteredHighlights = useMemo(() => {
    if (!highlights || filter.all) return highlights;
    
    return highlights.map((group: any) => {
      const filtered = {...group};
      const variantKey = `${activeTab}Variants` as keyof typeof filtered;
      
      if (Array.isArray(filtered[variantKey])) {
        const filteredArray = (filtered[variantKey] as any[])
          .filter((variant: any) => filterEntity(variant.entity));
        filtered[variantKey] = filteredArray as any;
      }
      
      return filtered;
    });
  }, [highlights, filter, activeTab, filterEntity]);

  // Toggle filter with proper typing
  const toggleFilter = (id: string) => {
    if (id === 'all') {
      setFilter({ all: true });
    } else {
      setFilter(prevFilter => {
        // Create new filter state with proper typing
        const newFilter: FilterState = { ...prevFilter, all: false };
        
        // Toggle the specific filter
        newFilter[id] = !newFilter[id];
        
        // If no filters are active, reset to all
        const hasActiveFilters = Object.entries(newFilter)
          .some(([key, value]) => key !== 'all' && value === true);
        
        if (!hasActiveFilters) {
          return { all: true };
        }
        
        return newFilter;
      });
    }
  };

  // Toggle tier expansion
  const toggleTierExpansion = (tier: string) => {
    setExpandedTiers(prev => ({
      ...prev,
      [tier]: !prev[tier]
    }));
  };

  // Render entity icon WITHOUT TEXT
  const renderEntityIcon = (item: BaseStats): JSX.Element => {
    switch(activeTab) {
      case 'units':
        return <UnitIcon unit={item} size="lg" />;
      case 'items':
        return <ItemIcon item={item} size="lg" />;
      case 'traits':
        return (
          <img 
            src={getEntityIcon(item, 'trait')} 
            alt={item.name} 
            className="w-12 h-12 object-contain" 
            onError={(e) => {
              const target = e.target as HTMLImageElement;
              target.src = DEFAULT_ICONS.trait;
            }}
          />
        );
      default:
        const displayTraits = parseCompTraits(item.name, (item as any).traits || []);
        return (
          <div className="flex gap-1 flex-wrap justify-center w-full">
            {displayTraits.map((trait: any, i: number) => (
              <img 
                key={i} 
                src={getEntityIcon(trait, 'trait')} 
                alt={trait.name} 
                className="w-8 h-8" 
                onError={(e) => {
                  const target = e.target as HTMLImageElement;
                  target.src = DEFAULT_ICONS.trait;
                }}
              />
            ))}
          </div>
        );
    }
  };

  // Loading and error states
  if (isLoading) {
    return (
      <Layout title="Meta Report">
        <div className="flex items-center justify-center h-64">
          <div className="text-center">
            <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-gold mx-auto"></div>
            <p className="mt-4 text-cream/80">Loading meta data...</p>
          </div>
        </div>
      </Layout>
    );
  }

  if (error) {
    return (
      <Layout>
        <div className="mt-6">
          <Card>
            <div className="text-center py-8">
              <div className="text-red-400 mb-2">Error loading data</div>
              <p className="text-cream/80 mb-4">
                {error && typeof error === 'object' && 'message' in error ? String(error.message) : 'An error occurred'}
              </p>
              <button onClick={handleRetry} className="px-4 py-2 bg-brown-light/50 hover:bg-brown-light/70 text-cream rounded-md">
                Retry
              </button>
            </div>
          </Card>
        </div>
      </Layout>
    );
  }

  if (!filteredTierList) {
    return (
      <Layout>
        <div className="flex items-center justify-center h-64">
          <div className="text-center">
            <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-gold mx-auto"></div>
            <p className="mt-4 text-cream/80">Analyzing meta data...</p>
          </div>
        </div>
      </Layout>
    );
  }

  // Enhanced tier styles with subtle shadows and better spread
  const tierStyles = [
    { 
      tier: 'S', 
      bgColor: 'bg-gradient-to-r from-gold via-yellow-500 to-gold', 
      textColor: 'text-brown-dark', 
      shadow: 'shadow-inner shadow-gold/20',
      glow: 'shadow-lg shadow-gold/15 shadow-spread',
      icon: <Crown className="h-6 w-6" />
    },
    { 
      tier: 'A', 
      bgColor: 'bg-gradient-to-r from-amber-600 via-amber-500 to-amber-600', 
      textColor: 'text-white', 
      shadow: 'shadow-inner shadow-amber-500/20',
      glow: 'shadow-md shadow-amber-500/15',
      icon: <Trophy className="h-5 w-5" />
    },
    { 
      tier: 'B', 
      bgColor: 'bg-gradient-to-r from-amber-700 via-amber-800 to-amber-700', 
      textColor: 'text-cream', 
      shadow: 'shadow-inner shadow-amber-700/20',
      glow: 'shadow-sm shadow-amber-700/10',
      icon: <Medal className="h-5 w-5" />
    },
    { 
      tier: 'C', 
      bgColor: 'bg-gradient-to-r from-amber-900 via-brown-dark to-amber-900', 
      textColor: 'text-cream/90', 
      shadow: 'shadow-inner shadow-amber-900/15',
      glow: 'shadow-sm shadow-amber-900/8',
      icon: <Shield className="h-5 w-5" />
    }
  ];

  // Highlight types
  const standardHighlights = [
    { type: HighlightType.TopWinner, title: "Best Winrate", icon: <Trophy className="text-gold h-5 w-5" /> },
    { type: HighlightType.MostConsistent, title: "Most Consistent", icon: <Medal className="text-gold h-5 w-5" /> },
    { type: HighlightType.MostPlayed, title: "Most Played", icon: <Users className="text-gold h-5 w-5" /> },
    { type: HighlightType.FlexiblePick, title: "Most Flexible", icon: <Shield className="text-gold h-5 w-5" /> },
    { type: HighlightType.PocketPick, title: "Pocket Pick", icon: <Star className="text-gold h-5 w-5" /> }
  ];

  return (
    <Layout title="Meta Report">
      <HeaderBanner />
      <StatsCarousel />
      
      <div className="mt-8">
        <FeatureBanner title="Meta Report - Highlights & Strategies" />
        <EntityTabs
          activeTab={activeTab}
          onTabChange={setActiveTab}
          filterOptions={categoryOptions}
          filterState={filter}
          onFilterChange={toggleFilter}
          allowSearch={false}
          className="mt-1"
        />
      </div>
      
      <div className="mb-10 mt-6 flex flex-col lg:flex-row gap-6">
        {/* Tier List with themed colors only */}
        <div className="lg:w-4/6">
          <Card className="p-0 overflow-hidden h-full backdrop-filter backdrop-blur-md bg-brown/5 border border-gold/30">
            <div className="flex items-center justify-center py-4 bg-brown/60 border-b border-gold/30">
              <h2 className="text-xl font-display tracking-tight text-gold">Power Rankings</h2>
            </div>
            
            <div className="mt-4 w-full">
              {tierStyles.map(({ tier, bgColor, textColor, shadow, glow, icon }) => (
                <div key={tier} className={`border-t border-b border-gold/20 mb-2 ${glow}`}>
                  <div 
                    className="flex w-full items-center cursor-pointer group"
                    onClick={() => toggleTierExpansion(tier)}
                  >
                    <div className={`${bgColor} ${shadow} w-28 min-w-[7rem] h-14 flex items-center justify-center font-bold text-2xl ${textColor} border-r border-brown/20 relative overflow-hidden group-hover:scale-105 transition-transform duration-200`}>
                      <div className="absolute inset-0 bg-white/10 opacity-0 group-hover:opacity-100 transition-opacity duration-200"></div>
                      <div className="flex items-center gap-2 relative z-10">
                        {icon}
                        <span>{tier}</span>
                      </div>
                    </div>
                    <div className="flex justify-between items-center w-full px-4 py-3 bg-brown-light/20 group-hover:bg-brown-light/30 transition-colors">
                      <span className="text-gold text-sm font-medium">
                        {filteredTierList[activeTab as keyof typeof filteredTierList][tier as keyof typeof filteredTierList.units]?.length || 0} entities
                      </span>
                      <motion.div
                        animate={{ rotate: expandedTiers[tier] ? 180 : 0 }}
                        transition={{ duration: 0.2 }}
                      >
                        <ChevronDown size={18} className="text-gold" />
                      </motion.div>
                    </div>
                  </div>
                  
                  <AnimatePresence>
                    {expandedTiers[tier] && (
                      <motion.div 
                        initial={{ height: 0, opacity: 0 }}
                        animate={{ height: 'auto', opacity: 1 }}
                        exit={{ height: 0, opacity: 0 }}
                        transition={{ duration: 0.3, ease: [0.25, 0.46, 0.45, 0.94] }}
                        className="overflow-hidden bg-brown-light/20"
                      >
                        <div className="flex flex-wrap p-4 gap-2">
                          {filteredTierList[activeTab as keyof typeof filteredTierList][tier as keyof typeof filteredTierList.units]?.map((item, i) => (
                            <Link href={`/entity/${activeTab}/${item.id}`} key={i}>
                              <motion.div 
                                className="w-16 h-16 flex items-center justify-center hover:bg-brown-light/30 transition-all p-1 text-cream rounded-lg relative group"
                                initial={{ scale: 0.9, opacity: 0 }}
                                animate={{ scale: 1, opacity: 1 }}
                                transition={{ duration: 0.2, delay: i * 0.03 }}
                                whileHover={{ 
                                  scale: 1.1, 
                                  backgroundColor: 'rgba(245, 158, 11, 0.15)',
                                  boxShadow: '0 4px 20px rgba(245, 158, 11, 0.3)'
                                }}
                              >
                                {renderEntityIcon(item)}
                              </motion.div>
                            </Link>
                          ))}
                          {filteredTierList[activeTab as keyof typeof filteredTierList][tier as keyof typeof filteredTierList.units]?.length === 0 && (
                            <div className="h-16 w-full flex items-center justify-center text-cream/50 text-sm">
                              No {activeTab} in this tier
                            </div>
                          )}
                        </div>
                      </motion.div>
                    )}
                  </AnimatePresence>
                </div>
              ))}
            </div>
          </Card>
        </div>

        {/* Meta Highlights */}
        <div className="lg:w-2/6 flex flex-col gap-2">
          {standardHighlights.map((highlight, i) => {
            const highlightData = filteredHighlights?.find((h: any) => h.type === highlight.type);
            const highlightEntity = highlightData?.getPreferredVariant(activeTab);
            
            return (
              <motion.div 
                key={i} 
                className="h-full"
                initial={{ x: 20, opacity: 0 }}
                animate={{ x: 0, opacity: 1 }}
                transition={{ duration: 0.3, delay: i * 0.1 }}
              >
                <MetaHighlightCard 
                  highlight={highlightEntity || null}
                  title={highlight.title}
                  icon={highlight.icon}
                />
              </motion.div>
            );
          })}
        </div>
      </div>
      
      {/* Meta Insights Dashboard */}
      <MetaInsightsDashboard />
    </Layout>
  );
}
EOL

# Error Banner component
cat > src/components/common/ErrorBanner.tsx << 'EOL'
import React from 'react';
import { AlertTriangle, RefreshCw } from 'lucide-react';
import { ErrorState } from '@/types';

export function ErrorBanner({ error, onRetry }: { error: ErrorState, onRetry?: () => void }) {
  if (!error.hasError) return null;
  
  const errorMessage = error.error?.message || 'An error occurred';
  const errorType = error.error?.type || 'unknown';
  const timeAgo = error.error?.timestamp 
    ? getTimeAgo(error.error.timestamp) 
    : '';
  
  return (
    <div className="error-banner">
      <div className="flex items-center gap-2">
        <AlertTriangle className="text-red-300" size={18} />
        <div>
          <p className="text-sm font-medium">
            {errorType === 'timeout' ? 'Request timed out' : 
             errorType === 'rate-limit' ? 'Rate limit exceeded' : 
             errorType === 'server' ? 'Server error' : 
             'Connection error'}
          </p>
          <p className="text-xs text-red-300/90">
            {errorMessage} {timeAgo && `(${timeAgo})`}
          </p>
        </div>
      </div>
      
      {onRetry && (
        <button 
          onClick={onRetry}
          className="bg-red-700/50 hover:bg-red-700/70 px-3 py-1 rounded flex items-center gap-1 text-sm"
        >
          <RefreshCw size={14} />
          <span>Retry</span>
        </button>
      )}
    </div>
  );
}

// Helper function to format timestamp to readable time ago
function getTimeAgo(date: Date | string | number): string {
  const seconds = Math.floor((new Date().getTime() - new Date(date).getTime()) / 1000);
  
  let interval = seconds / 31536000;
  if (interval > 1) return Math.floor(interval) + " years ago";
  
  interval = seconds / 2592000;
  if (interval > 1) return Math.floor(interval) + " months ago";
  
  interval = seconds / 86400;
  if (interval > 1) return Math.floor(interval) + " days ago";
  
  interval = seconds / 3600;
  if (interval > 1) return Math.floor(interval) + " hours ago";
  
  interval = seconds / 60;
  if (interval > 1) return Math.floor(interval) + " minutes ago";
  
  return Math.floor(seconds) + " seconds ago";
}
EOL

# Loading Spinner and Overlay
cat > src/components/common/LoadingSpinner.tsx << 'EOL'
import React from 'react';

type SpinnerSize = 'small' | 'medium' | 'large';

interface LoadingSpinnerProps {
  size?: SpinnerSize;
  message?: string;
}

export function LoadingSpinner({ size = 'medium', message = '' }: LoadingSpinnerProps) {
  const sizes = {
    small: 'h-4 w-4',
    medium: 'h-10 w-10',
    large: 'h-16 w-16'
  };
  
  const spinnerSize = sizes[size] || sizes.medium;
  
  return (
    <div className="flex flex-col items-center justify-center p-4">
      <div className={`animate-spin rounded-full border-t-2 border-b-2 border-gold ${spinnerSize}`}></div>
      {message && <p className="mt-2 text-sm text-cream/70">{message}</p>}
    </div>
  );
}

interface LoadingOverlayProps {
  message?: string;
}

export function LoadingOverlay({ message = 'Loading...' }: LoadingOverlayProps) {
  return (
    <div className="loading-overlay">
      <div className="flex flex-col items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-gold"></div>
        <p className="mt-3 text-cream/80">{message}</p>
      </div>
    </div>
  );
}
EOL

# HeaderBanner component
cat > src/components/common/HeaderBanner.tsx << 'EOL'
import React from 'react';
import { Card } from '@/components/ui';
import { Tag, Award, FileBarChart } from 'lucide-react';
import { useTftData } from '@/utils/useTftData';

export function HeaderBanner() {
  // Use a type assertion to tell TypeScript what the expected structure is
  const tftData = useTftData() as any;
  // Now we can safely access properties
  const matchCount = tftData?.matchCount || 0;
  const currentRegion = tftData?.currentRegion || 'all';
  
  return (
    <Card className="h-auto py-2 px-3 sm:px-4 sm:p-3 mt-4 -mb-2 border border-gold/40 shadow-none">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-2">
        <div className="text-md text-cream/90">
          TeamFight Tactics {currentRegion ? `${currentRegion} ` : ''}matches
        </div>
        
        <div className="flex flex-wrap justify-start sm:justify-end gap-1.5 overflow-x-auto">
          <div className="inline-flex items-center bg-brown-light/30 px-2 py-1 rounded-lg border border-gold/20">
            <Tag size={14} className="text-gold mr-1.5" />
            <span className="text-xs whitespace-nowrap">Patch 14.4</span>
          </div>
          
          <div className="inline-flex items-center bg-brown-light/30 px-2 py-1 rounded-lg border border-gold/20">
            <Award size={14} className="text-gold mr-1.5" />
            <p className="text-xs whitespace-nowrap">Last update: 1min</p>
          </div>
          
          <div className="inline-flex items-center bg-brown-light/30 px-2 py-1 rounded-lg border border-gold/20">
            <FileBarChart size={14} className="text-gold mr-1.5" />
            <p className="text-xs whitespace-nowrap">
              {matchCount > 0 ? `${matchCount}+ ` : '10000+ '}matches
              {currentRegion !== 'all' && ` (${currentRegion})`}
            </p>
          </div>
        </div>
      </div>
    </Card>
  );
}
EOL

# FeatureBanner component
cat > src/components/common/FeatureBanner.tsx << 'EOL'
import React, { ReactNode } from 'react';
import Link from 'next/link';
import { motion } from 'framer-motion';
import { FeatureCardProps } from '@/types';

interface FeatureBannerProps {
  title: string;
  children?: ReactNode;
}

export function FeatureBanner({ title, children }: FeatureBannerProps) {
  return (
    <motion.div 
      className="feature-banner"
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.4, ease: [0.2, 0.8, 0.2, 1] }}
    >
      <div className="flex justify-center items-center">
        <div className="flex items-center">
          <span className="text-lg text-corona-light ml-4 mt-1 font-display tracking-tight">{title}</span>
        </div>
      </div>
      {children}
    </motion.div>
  );
}

export function FeatureCard({ title, icon, description, linkTo }: FeatureCardProps) {
  return (
    <Link href={linkTo}>
      <motion.div 
        className="feature-card group"
        whileHover={{ 
          scale: 1.02,
          boxShadow: "0 5px 15px -5px rgba(245, 158, 11, 0.15)"
        }}
        transition={{ duration: 0.3, ease: [0.2, 0.8, 0.2, 1] }}
      >
        <div className="relative p-3 flex flex-col h-full items-center text-center">
          <div className="flex justify-center">
            <div className="feature-hex-container">
              <svg 
                className="feature-hex-svg" 
                viewBox="0 0 100 100"
                xmlns="http://www.w3.org/2000/svg"
              >
                <polygon 
                  points="50,0 100,25 100,75 50,100 0,75 0,25"
                  fill="hsla(27, 69.90%, 14.30%, 0.94)"
                  stroke="rgba(245, 158, 11, 0.5)" 
                  strokeWidth="2" 
                  className="transition-all group-hover:stroke-solar-flare"
                />
              </svg>
              
              <div className="feature-hex-content">
                {icon}
              </div>
            </div>
          </div>
          <h3 className="text-lg text-solar-flare mb-1 font-display tracking-tight">{title}</h3>
          <div className="text-xs text-corona-light/70 mt-auto group-hover:text-corona-light">{description}</div>
        </div>
      </motion.div>
    </Link>
  );
}

interface FeatureCardsContainerProps {
  children: ReactNode;
}

export function FeatureCardsContainer({ children }: FeatureCardsContainerProps) {
  return (
    <div className="feature-cards-container">
      {children}
    </div>
  );
}
EOL

# StatsCarousel component
cat > src/components/common/StatsCarousel.tsx << 'EOL'
import React, { useState, useEffect, useRef } from 'react';
import Link from 'next/link';
import { motion } from 'framer-motion';
import { useTftData, HighlightType, EntityType, HighlightEntity, HighlightGroup } from '@/utils/useTftData';
import { parseCompTraits } from '@/utils/dataProcessing';
import { getEntityIcon, ensureIconPath, DEFAULT_ICONS } from '@/utils/paths';

// Define a type for the variant keys
type VariantKeys = 'unitVariants' | 'itemVariants' | 'traitVariants' | 'compVariants';

// Extend HighlightEntity to include displayTitle for carousel items
interface CarouselHighlightEntity extends HighlightEntity {
  displayTitle: string;
}

export function StatsCarousel() {
  // Fixed TypeScript error by using type assertion and providing a default value
  const tftData = useTftData() as any;
  const highlights = tftData?.highlights || [];
  
  const [displayItems, setDisplayItems] = useState<CarouselHighlightEntity[]>([]);
  const scrollerRef = useRef<HTMLDivElement>(null);
  const animationRef = useRef<number | null>(null);
  const scrollXRef = useRef(0);
  const lastTimeRef = useRef(0);
  const [isHovered, setIsHovered] = useState(false);
  const [containerWidth, setContainerWidth] = useState(0);
  const [contentWidth, setContentWidth] = useState(0);
  
  // Process highlights to get diverse display items
  useEffect(() => {
    if (!highlights?.length) return;
    
    // Function to select diverse variants from each highlight type
    const getRandomHighlights = () => {
      const items: CarouselHighlightEntity[] = [];
      
      // Process each highlight type
      highlights.forEach((highlightGroup: HighlightGroup) => {
        // For each entity type, get a random variant that's not "Overall"
        const variantTypes: VariantKeys[] = ['unitVariants', 'itemVariants', 'traitVariants', 'compVariants'];
        
        variantTypes.forEach(variantType => {
          // Use type assertion to ensure TypeScript knows this is an array of HighlightEntity
          const variants = (highlightGroup[variantType] as HighlightEntity[]) || [];
          
          // Prefer variant items over overall items when available
          const specialVariants = variants.filter(v => v.variant && v.variant !== 'Overall');
          
          if (specialVariants.length > 0) {
            // Get a random special variant
            const randomVariant = specialVariants[Math.floor(Math.random() * specialVariants.length)];
            items.push({
              ...randomVariant,
              // Add highlight type title with variant
              displayTitle: `${highlightGroup.title}: ${randomVariant.variant}`
            });
          } else if (variants.length > 0) {
            // Fallback to any variant if no special variants exist
            const randomVariant = variants[Math.floor(Math.random() * variants.length)];
            items.push({
              ...randomVariant,
              displayTitle: highlightGroup.title
            });
          }
        });
      });
      
      // Shuffle the items
      return items.sort(() => Math.random() - 0.5);
    };
    
    // Get diverse highlights
    const randomHighlights = getRandomHighlights();
    setDisplayItems(randomHighlights);
  }, [highlights]);

  // Animation logic with improved speed control
  useEffect(() => {
    if (!displayItems.length || !scrollerRef.current) return;
    
    // Function to get current dimensions
    const updateDimensions = () => {
      if (scrollerRef.current) {
        setContainerWidth(scrollerRef.current.parentElement?.clientWidth || 0);
        setContentWidth(scrollerRef.current.scrollWidth / 3); // Divide by 3 because we have 3 copies
      }
    };
    
    // Initial dimensions update
    updateDimensions();
    
    // Add resize listener
    window.addEventListener('resize', updateDimensions);
    
    const animate = (timestamp: number) => {
      if (!lastTimeRef.current) {
        lastTimeRef.current = timestamp;
      }
      
      const elapsed = timestamp - lastTimeRef.current;
      
      // SPEED ADJUSTMENTS:
      // Base speed: 0.01
      // Default speed: 3
      // Hover speed: 1.5
      const baseSpeed = 0.01;
      const speed = isHovered ? baseSpeed * 1.5 : baseSpeed * 3;
      
      scrollXRef.current += speed * elapsed;
      
      if (scrollerRef.current) {
        // Reset position for seamless loop when reaching the first duplicate set
        if (scrollXRef.current >= contentWidth) {
          scrollXRef.current = 0;
        }
        
        scrollerRef.current.style.transform = `translateX(-${scrollXRef.current}px)`;
      }
      
      lastTimeRef.current = timestamp;
      animationRef.current = requestAnimationFrame(animate);
    };
    
    animationRef.current = requestAnimationFrame(animate);
    
    return () => {
      if (animationRef.current) {
        cancelAnimationFrame(animationRef.current);
      }
      window.removeEventListener('resize', updateDimensions);
    };
  }, [displayItems, isHovered, containerWidth, contentWidth]);
  
  // Helper function to render entity image
  const renderEntityImage = (item: CarouselHighlightEntity) => {
    if (item.entityType === EntityType.Unit) {
      return (
        <div className="min-w-10 h-10 rounded-full border-2 border-solar-flare/30 overflow-hidden flex-shrink-0">
          <img 
            src={getEntityIcon(item.entity, 'unit')} 
            alt={item.value} 
            className="w-full h-full object-cover" 
            onError={(e) => {
              // Fallback if image fails to load
              const target = e.target as HTMLImageElement;
              target.src = DEFAULT_ICONS.unit;
            }}
          />
        </div>
      );
    }
    
    if (item.entityType === EntityType.Item) {
      return (
        <img 
          src={getEntityIcon(item.entity, 'item')} 
          alt={item.value} 
          className="min-w-10 h-10 object-contain"
          onError={(e) => {
            // Fallback if image fails to load
            const target = e.target as HTMLImageElement;
            target.src = DEFAULT_ICONS.item;
          }}
        />
      );
    }
    
    if (item.entityType === EntityType.Trait) {
      return (
        <div className="min-w-10 h-10 flex items-center justify-center flex-shrink-0">
          <img 
          src={getEntityIcon(item.entity, 'trait')} 
          alt={item.value} 
          className="min-w-12 h-12 object-contain"
          onError={(e) => {
            // Fallback if image fails to load
            const target = e.target as HTMLImageElement;
            target.src = DEFAULT_ICONS.trait;
          }}
        />
        </div>
      );
    }
    
    if (item.entityType === EntityType.Comp) {
      // Fix: Use fixed container height and width to match other entity types
      return (
        <div className="min-w-10 h-10 flex items-center justify-center flex-shrink-0">
          {parseCompTraits(item.entity.name, item.entity.traits || []).slice(0, 2).map((trait: any, i: number) => {
            return (
              <img 
                key={i} 
                src={getEntityIcon(trait, 'trait')}
                alt={trait.name} 
                className="h-12 w-12 -ml-1 first:ml-0" 
                onError={(e) => {
                  // Fallback if image fails to load
                  const target = e.target as HTMLImageElement;
                  target.src = DEFAULT_ICONS.trait;
                }}
              />
            );
          })}
        </div>
      );
    }
    
    return null;
  };
  
  if (!displayItems.length) return null;
  
  return (
    <div className="w-full overflow-hidden relative my-1 py-2">
      <div 
        className="flex" 
        ref={scrollerRef}
        onMouseEnter={() => setIsHovered(true)}
        onMouseLeave={() => setIsHovered(false)}
        style={{ height: '75px', width: 'fit-content', willChange: 'transform' }}
      >
        {/* Triple the items for seamless looping */}
        {[...displayItems, ...displayItems, ...displayItems].map((highlight, idx) => (
          <Link href={highlight.link || '#'} key={idx}>
            <motion.div 
              className="flex-shrink-0 w-64 mx-1 relative z-10 border border-solar-flare/30 rounded-lg p-2 shadow-md 
                          transition-all hover:bg-eclipse-shadow/50 hover:border-solar-flare/50 
                          bg-eclipse-shadow/5 backdrop-filter backdrop-blur-md"
              whileHover={{ 
                scale: 1.05,
                boxShadow: "0 10px 25px -5px rgba(245, 158, 11, 0.2)"
              }}
            >
              {/* Consistent layout matching feature buttons */}
              <div className="flex flex-col h-full">
                {/* Title in cream */}
                <div className="text-xs font-semibold text-corona-light mb-2 text-center">
                  {highlight.displayTitle}
                </div>
                
                {/* Horizontally centered content with icon on left */}
                <div className="flex items-center justify-center flex-1">
                  <div className="flex-shrink-0 mr-3">
                    {renderEntityImage(highlight)}
                  </div>
                  <div className="min-w-0">
                    {/* Entity name in gold with truncation */}
                    <div className="text-solar-flare font-semibold text-sm truncate max-w-full">
                      {highlight.value}
                    </div>
                    <div className="text-xs text-corona-light/70 truncate max-w-full">
                      {highlight.detail}
                    </div>
                  </div>
                </div>
              </div>
            </motion.div>
          </Link>
        ))}
      </div>
    </div>
  );
}
EOL

# Fix 1: Update EntityTabs.tsx to ensure dropdowns close consistently and improve item combinations UI
cat > src/components/common/EntityTabs.tsx << 'EOL'
import React, { useState, useRef, useEffect, useMemo } from 'react';
import { Search, X, Filter, ChevronDown, ChevronUp } from 'lucide-react';
import { FilterButtons } from '@/components/ui';
import { motion, AnimatePresence } from 'framer-motion';
import { getEntityIcon, DEFAULT_ICONS, getTierIcon } from '@/utils/paths';
import { createPortal } from 'react-dom';
import traitsJson from 'public/mapping/traits.json';

export type EntityType = 'units' | 'items' | 'traits' | 'comps';

export interface FilterOption {
  id: string;
  name: string;
  icon?: string;
  cost?: number;
  category?: string;
  tierIcon?: string;
}

export interface FilterState {
  all: boolean;
  [key: string]: boolean;
}

interface EntityTabsProps {
  activeTab: EntityType;
  onTabChange: (tab: EntityType) => void;
  filterOptions: FilterOption[];
  filterState: FilterState;
  onFilterChange: (id: string) => void;
  searchValue?: string;
  onSearchChange?: (value: string) => void;
  showConditionsButton?: boolean;
  showConditions?: boolean;
  onToggleConditions?: () => void;
  allowSearch?: boolean;
  className?: string;
}

export function EntityTabs({
  activeTab,
  onTabChange,
  filterOptions,
  filterState,
  onFilterChange,
  searchValue = '',
  onSearchChange,
  showConditionsButton = false,
  showConditions = false,
  onToggleConditions,
  allowSearch = true,
  className = ''
}: EntityTabsProps) {
  const entityTypes: { id: EntityType; name: string }[] = [
    { id: 'units', name: 'Units' },
    { id: 'items', name: 'Items' },
    { id: 'traits', name: 'Traits' },
    { id: 'comps', name: 'Comps' }
  ];

  // Clear search when tab changes
  useEffect(() => {
    if (onSearchChange) {
      onSearchChange('');
    }
  }, [activeTab, onSearchChange]);

  return (
    <div className={`bg-brown/10 border border-gold/30 rounded-lg backdrop-blur-md p-0 shadow-inner shadow-gold/5 ${className}`}>
      <div className="flex flex-col gap-0">
        <div className="flex flex-col md:flex-row md:items-center justify-between p-2 border-b border-gold/20">
          <div className="flex overflow-x-auto custom-scrollbar">
            {entityTypes.map(type => (
              <button 
                key={type.id} 
                onClick={() => onTabChange(type.id)}
                className={`px-4 py-2.5 font-medium transition-all duration-200 ${
                  activeTab === type.id 
                    ? 'text-gold border-b-2 border-gold bg-brown-light/20' 
                    : 'text-cream hover:text-gold hover:bg-brown-light/10 rounded-t-md'
                }`}
              >
                {type.name}
              </button>
            ))}
          </div>
          
          <div className="flex items-center gap-3 overflow-x-auto custom-scrollbar mt-2 md:mt-0">
            {showConditionsButton && onToggleConditions && (
              <button 
                onClick={onToggleConditions}
                className={`px-3 py-1.5 rounded-full flex items-center gap-1 ${
                  showConditions 
                    ? 'bg-gold text-brown font-medium' 
                    : 'bg-brown-light/30 hover:bg-brown-light/50 text-cream'
                } transition-all duration-200`}
              >
                <Filter size={14} />
                {showConditions ? 'Hide Filters' : 'Advanced Filters'}
              </button>
            )}
            
            <FilterButtons 
              options={filterOptions}
              activeFilter={filterState}
              onChange={onFilterChange}
            />
          </div>
        </div>
        
        {allowSearch && onSearchChange && (
          <div className="relative group">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gold h-5 w-5" />
            <input
              type="text" 
              placeholder={`Search ${activeTab}...`}
              value={searchValue}
              className="w-full pl-10 pr-12 py-2.5 bg-brown/60 focus:outline-none focus:ring-1 focus:ring-gold/50 rounded-lg text-cream transition-all duration-200"
              onChange={e => onSearchChange(e.target.value)}
            />
            {searchValue && (
              <button 
                className="absolute right-3 top-1/2 -translate-y-1/2 text-cream/50 hover:text-cream/80"
                onClick={() => onSearchChange('')}
                aria-label="Clear search"
              >
                <X size={16} />
              </button>
            )}
          </div>
        )}
      </div>
    </div>
  );
}

interface SelectDropdownProps {
  options: FilterOption[];
  value: string | string[];
  onChange: (value: string | string[]) => void;
  placeholder: string;
  className?: string;
  multiple?: boolean;
  entityType?: 'unit' | 'item' | 'trait' | string;
  maxHeight?: string;
  showIcons?: boolean;
  limit?: number;
  closeAfterSelect?: boolean;
}

export function SelectDropdown({ 
  options, 
  value, 
  onChange, 
  placeholder, 
  className = '',
  multiple = false,
  entityType = '',
  maxHeight = '200px',
  showIcons = true,
  limit = 0,
  closeAfterSelect = true
}: SelectDropdownProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const dropdownRef = useRef<HTMLDivElement>(null);
  const [dropdownPosition, setDropdownPosition] = useState({ top: 0, left: 0, width: 0 });
  const [portalContainer, setPortalContainer] = useState<HTMLElement | null>(null);
  
  useEffect(() => {
    setPortalContainer(document.body);
  }, []);
  
  useEffect(() => {
    if (isOpen && dropdownRef.current) {
      const rect = dropdownRef.current.getBoundingClientRect();
      setDropdownPosition({
        top: rect.bottom + window.scrollY,
        left: rect.left + window.scrollX,
        width: rect.width
      });
    }
  }, [isOpen]);
  
  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Escape') {
      setIsOpen(false);
    } else if (e.key === 'ArrowDown' && isOpen) {
      const firstOption = document.querySelector('button[role="option"]') as HTMLElement;
      if (firstOption) firstOption.focus();
      e.preventDefault();
    }
  };
  
  const handleOptionKeyDown = (e: React.KeyboardEvent, optionId: string, index: number) => {
    const options = document.querySelectorAll('button[role="option"]');
    
    if (e.key === 'ArrowDown' && options && index < options.length - 1) {
      (options[index + 1] as HTMLElement).focus();
      e.preventDefault();
    } else if (e.key === 'ArrowUp' && options && index > 0) {
      (options[index - 1] as HTMLElement).focus();
      e.preventDefault();
    } else if (e.key === 'Enter' || e.key === ' ') {
      handleSelect(optionId);
      e.preventDefault();
    }
  };
  
  useEffect(() => {
    const handleOutsideClick = (e: MouseEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(e.target as Node)) {
        const dropdownContent = document.getElementById('dropdown-content');
        if (!dropdownContent || !dropdownContent.contains(e.target as Node)) {
          setIsOpen(false);
        }
      }
    };
    
    document.addEventListener('mousedown', handleOutsideClick);
    return () => document.removeEventListener('mousedown', handleOutsideClick);
  }, []);
  
  const getSelectedInfo = () => {
    if (multiple && Array.isArray(value)) {
      if (value.length === 0) return { text: placeholder, icon: null };
      if (value.length === 1) {
        const selected = options.find(opt => opt.id === value[0]);
        return { 
          text: selected ? selected.name : placeholder,
          icon: selected && showIcons ? selected.icon : null,
          cost: selected ? selected.cost : null
        };
      }
      return { text: `${value.length} selected`, icon: null };
    } else {
      const selected = options.find(opt => opt.id === value);
      return { 
        text: selected ? selected.name : placeholder,
        icon: selected && showIcons ? selected.icon : null,
        cost: selected ? selected.cost : null
      };
    }
  };
  
  const filteredOptions = searchQuery 
    ? options.filter(option => option.name.toLowerCase().includes(searchQuery.toLowerCase()))
    : options;
  
  interface GroupedOptions {
    label: string;
    items: FilterOption[];
    color?: string;
  }
  
  const groupedOptions = useMemo(() => {
    if (entityType === 'unit' && options.some(opt => opt.cost !== undefined)) {
      const groups: Record<string, FilterOption[]> = {};
      
      filteredOptions.forEach(option => {
        const cost = option.cost?.toString() || 'Other';
        if (!groups[cost]) groups[cost] = [];
        groups[cost].push(option);
      });
      
      return Object.entries(groups)
        .sort(([costA], [costB]) => {
          if (costA === 'Other') return 1;
          if (costB === 'Other') return -1;
          return parseInt(costA) - parseInt(costB);
        })
        .map(([cost, items]) => ({
          label: `${cost} Cost`,
          color: ['#9aa4af', '#2ecc71', '#3498db', '#9b59b6', '#f1c40f'][parseInt(cost) - 1] || '#9aa4af',
          items: items.sort((a, b) => a.name.localeCompare(b.name))
        })) as GroupedOptions[];
    }
    
    if (entityType === 'item' && options.some(opt => opt.category !== undefined)) {
      const groups: Record<string, FilterOption[]> = {};
      
      filteredOptions.forEach(option => {
        const category = option.category || 'Other';
        if (!groups[category]) groups[category] = [];
        groups[category].push(option);
      });
      
      return Object.entries(groups)
        .sort(([catA], [catB]) => {
          if (catA === 'Other') return 1;
          if (catB === 'Other') return -1;
          return catA.localeCompare(catB);
        })
        .map(([category, items]) => ({
          label: category.replace(/-/g, ' ').replace(/\b\w/g, c => c.toUpperCase()),
          items: items.sort((a, b) => a.name.localeCompare(b.name))
        })) as GroupedOptions[];
    }
    
    return [{
      label: '',
      items: filteredOptions.sort((a, b) => a.name.localeCompare(b.name))
    }] as GroupedOptions[];
  }, [filteredOptions, entityType]);
    
  const handleSelect = (optionId: string) => {
    if (multiple && Array.isArray(value)) {
      if (value.includes(optionId)) {
        const newValue = value.filter(v => v !== optionId);
        onChange(newValue);
      } else {
        if (limit > 0 && value.length >= limit) {
          const newValue = [...value];
          newValue.pop();
          newValue.push(optionId);
          onChange(newValue);
        } else {
          onChange([...value, optionId]);
        }
      }
      
      if (closeAfterSelect) {
        setIsOpen(false);
      }
    } else {
      onChange(optionId);
      setIsOpen(false);
    }
  };
  
  const isSelected = (optionId: string) => {
    if (multiple && Array.isArray(value)) {
      return value.includes(optionId);
    } else {
      return value === optionId;
    }
  };
  
  const getIcon = (option: FilterOption) => {
    if (!showIcons || !option.icon) return null;
    
    if (entityType === 'unit') {
      return (
        <div 
          className="w-5 h-5 rounded-full flex-shrink-0 overflow-hidden border"
          style={{ 
            borderColor: option.cost ? 
              ['#9aa4af', '#2ecc71', '#3498db', '#9b59b6', '#f1c40f'][option.cost - 1] || '#9aa4af'
              : '#9aa4af'
          }}
        >
          <img 
            src={getEntityIcon(option, 'unit')} 
            alt={option.name} 
            className="w-full h-full object-cover"
            onError={(e) => {
              const target = e.target as HTMLImageElement;
              target.src = DEFAULT_ICONS.unit;
            }}
          />
        </div>
      );
    } else if (entityType === 'item') {
      return (
        <img 
          src={getEntityIcon(option, 'item')} 
          alt={option.name} 
          className="w-5 h-5 object-contain flex-shrink-0"
          onError={(e) => {
            const target = e.target as HTMLImageElement;
            target.src = DEFAULT_ICONS.item;
          }}
        />
      );
    } else if (entityType === 'trait') {
      if (option.tierIcon) {
        return (
          <img 
            src={option.tierIcon} 
            alt={option.name} 
            className="w-5 h-5 object-contain flex-shrink-0"
            onError={(e) => {
              const target = e.target as HTMLImageElement;
              target.src = DEFAULT_ICONS.trait;
            }}
          />
        );
      } else if (option.icon) {
        return (
          <img 
            src={getEntityIcon(option, 'trait')} 
            alt={option.name} 
            className="w-5 h-5 object-contain flex-shrink-0"
            onError={(e) => {
              const target = e.target as HTMLImageElement;
              target.src = DEFAULT_ICONS.trait;
            }}
          />
        );
      }
    }
    
    return null;
  };
  
  const selectedInfo = getSelectedInfo();
  
  const renderDropdownContent = () => {
    if (!isOpen) return null;
    
    return (
      <div 
        id="dropdown-content"
        className="absolute z-50 mt-1 py-1 bg-brown/95 border border-gold/30 rounded-lg shadow-xl backdrop-blur-md overflow-hidden custom-scrollbar"
        style={{ 
          top: dropdownPosition.top, 
          left: dropdownPosition.left,
          width: dropdownPosition.width,
          maxHeight: '300px'
        }}
        onClick={e => e.stopPropagation()}
      >
        <div className="px-2 py-1 border-b border-gold/10 sticky top-0 bg-brown/95 backdrop-blur-md z-10">
          <div className="relative">
            <Search className="absolute left-2 top-1/2 -translate-y-1/2 text-gold/60 h-3.5 w-3.5" />
            <input
              type="text"
              value={searchQuery}
              onChange={e => setSearchQuery(e.target.value)}
              placeholder="Search..."
              className="w-full pl-7 pr-2 py-1.5 bg-brown-light/30 border border-gold/10 rounded text-xs text-cream focus:outline-none focus:border-gold/30"
              onClick={e => e.stopPropagation()}
              onKeyDown={e => e.stopPropagation()}
            />
          </div>
        </div>
        
        <div className="overflow-y-auto max-h-[250px] custom-scrollbar">
          {groupedOptions.length > 0 ? (
            groupedOptions.map((group, groupIndex) => (
              <div key={groupIndex} className="py-1">
                {group.label && (
                  <div 
                    className="px-3 py-1 text-xs font-medium border-b border-gold/10 mb-1"
                    style={group.color ? { color: group.color } : {}}
                  >
                    {group.label}
                  </div>
                )}
                {group.items.map((option, optionIndex) => (
                  <button
                    key={option.id}
                    onClick={() => handleSelect(option.id)}
                    onKeyDown={(e) => handleOptionKeyDown(e, option.id, optionIndex)}
                    className={`w-full flex items-center gap-2 px-3 py-2 hover:bg-gold/10 transition-colors ${
                      isSelected(option.id) ? 'bg-gold/20 text-gold' : 'text-cream'
                    }`}
                    role="option"
                    aria-selected={isSelected(option.id)}
                    tabIndex={0}
                  >
                    {multiple && (
                      <div className={`w-4 h-4 border rounded flex-shrink-0 flex items-center justify-center ${
                        isSelected(option.id) ? 'bg-gold border-gold' : 'border-cream/50'
                      }`}>
                        {isSelected(option.id) && <span className="text-brown text-xs">✓</span>}
                      </div>
                    )}
                    {getIcon(option)}
                    <span className="truncate">{option.name}</span>
                  </button>
                ))}
              </div>
            ))
          ) : (
            <div className="px-3 py-2 text-cream/50 text-sm">No matches found</div>
          )}
        </div>
      </div>
    );
  };
  
  return (
    <div ref={dropdownRef} className={`relative ${className}`}>
      <button
        onClick={() => setIsOpen(!isOpen)}
        onKeyDown={handleKeyDown}
        className="w-full flex items-center justify-between px-3 py-2 bg-brown-light/30 border border-gold/20 rounded-lg text-sm text-cream hover:bg-brown-light/40 transition-colors"
        aria-haspopup="listbox"
        aria-expanded={isOpen}
      >
        <div className="flex items-center gap-2 truncate">
          {selectedInfo.icon && (
            <div className="flex-shrink-0">
              {entityType === 'unit' ? (
                <div 
                  className="w-5 h-5 rounded-full overflow-hidden border"
                  style={{ 
                    borderColor: selectedInfo.cost ? 
                      ['#9aa4af', '#2ecc71', '#3498db', '#9b59b6', '#f1c40f'][selectedInfo.cost - 1] || '#9aa4af'
                      : '#9aa4af'
                  }}
                >
                  <img 
                    src={getEntityIcon({icon: selectedInfo.icon}, entityType as 'unit' | 'item' | 'trait')} 
                    alt=""
                    className="w-full h-full object-cover"
                    onError={(e) => {
                      const target = e.target as HTMLImageElement;
                      target.src = DEFAULT_ICONS[entityType as keyof typeof DEFAULT_ICONS] || DEFAULT_ICONS.unit;
                    }}
                  />
                </div>
              ) : (
                <img 
                  src={getEntityIcon({icon: selectedInfo.icon}, entityType as 'unit' | 'item' | 'trait')} 
                  alt=""
                  className="w-5 h-5 object-contain"
                  onError={(e) => {
                    const target = e.target as HTMLImageElement;
                    target.src = DEFAULT_ICONS[entityType as keyof typeof DEFAULT_ICONS] || DEFAULT_ICONS.unit;
                  }}
                />
              )}
            </div>
          )}
          <span className={`truncate ${selectedInfo.text !== placeholder ? 'text-cream' : 'text-cream/60'}`}>
            {selectedInfo.text}
          </span>
        </div>
        <div className="ml-1">
          {isOpen ? <ChevronUp size={16} className="text-gold" /> : <ChevronDown size={16} className="text-gold" />}
        </div>
      </button>
      
      {isOpen && portalContainer && createPortal(renderDropdownContent(), portalContainer)}
    </div>
  );
}

interface ContextualFilter {
  entity: string;
  entityType: 'unit' | 'trait' | 'item';
  starLevel?: string[];
  itemsHeld?: string[];
  item1?: string;
  item2?: string;
  item3?: string;
  traitTier?: string;
  unitHolders?: string[];
  itemCombos?: string[];
}

interface ContextualFilterSidebarProps {
  visible: boolean;
  entityOptions: {
    units: FilterOption[];
    items: FilterOption[];
    traits: FilterOption[];
  };
  unitItemRelations: Record<string, string[]>;
  itemUnitRelations: Record<string, string[]>;
  itemComboRelations: Record<string, string[]>;
  filters: ContextualFilter[];
  onAddFilter: (filter: ContextualFilter) => void;
  onRemoveFilter: (index: number) => void;
  onClearAll: () => void;
  className?: string;
}

export function ContextualFilterSidebar({
  visible,
  entityOptions,
  unitItemRelations,
  itemUnitRelations,
  itemComboRelations,
  filters,
  onAddFilter,
  onRemoveFilter,
  onClearAll,
  className = ''
}: ContextualFilterSidebarProps) {
  const [currentFilterType, setCurrentFilterType] = useState<'unit' | 'trait' | 'item'>('unit');
  const [selectedEntity, setSelectedEntity] = useState<string>('');
  const [starLevel, setStarLevel] = useState<string[]>([]);
  const [item1, setItem1] = useState<string>('');
  const [item2, setItem2] = useState<string>('');
  const [item3, setItem3] = useState<string>('');
  const [traitTier, setTraitTier] = useState<string>('');
  const [unitHolders, setUnitHolders] = useState<string[]>([]);
  const [itemCombo1, setItemCombo1] = useState<string>('');
  const [itemCombo2, setItemCombo2] = useState<string>('');
  
  const starLevelOptions = [
    { id: '1', name: '1★', icon: '/assets/ui/star_1.png' },
    { id: '2', name: '2★', icon: '/assets/ui/star_2.png' },
    { id: '3', name: '3★', icon: '/assets/ui/star_3.png' }
  ];
  
  const getTraitTierOptions = (traitId: string) => {
    if (!traitId) return [];
    
    const traitData = traitsJson.origins[traitId as keyof typeof traitsJson.origins] || 
                     traitsJson.classes[traitId as keyof typeof traitsJson.classes];
    
    if (!traitData || !traitData.tiers) return [];
    
    return traitData.tiers.map((tier, index) => {
      const tierLevel = index + 1;
      const tierIcon = tier.icon ? `/assets/traits/${tier.icon}` : getTierIcon(traitId, tier.units);
      
      return {
        id: tierLevel.toString(),
        name: `${tier.units} units`,
        icon: traitData.icon,
        tierIcon: tierIcon
      };
    });
  };
  
  useEffect(() => {
    setSelectedEntity('');
    resetSecondaryFilters();
  }, [currentFilterType]);
  
  useEffect(() => {
    resetSecondaryFilters();
    
    if (selectedEntity) {
      applyCurrentFilter();
    }
  }, [selectedEntity]);
  
  const resetSecondaryFilters = () => {
    setStarLevel([]);
    setItem1('');
    setItem2('');
    setItem3('');
    setTraitTier('');
    setUnitHolders([]);
    setItemCombo1('');
    setItemCombo2('');
  };
  
  const applyCurrentFilter = () => {
    if (!selectedEntity) return;
    
    const existingFilterIndex = filters.findIndex(
      f => f.entity === selectedEntity && f.entityType === currentFilterType
    );
    
    const newFilter: ContextualFilter = {
      entity: selectedEntity,
      entityType: currentFilterType
    };
    
    if (currentFilterType === 'unit') {
      if (starLevel.length > 0) newFilter.starLevel = starLevel;
      if (item1) newFilter.item1 = item1;
      if (item2) newFilter.item2 = item2;
      if (item3) newFilter.item3 = item3;
    } else if (currentFilterType === 'trait') {
      if (traitTier) newFilter.traitTier = traitTier;
    } else if (currentFilterType === 'item') {
      if (unitHolders.length > 0) newFilter.unitHolders = unitHolders;
      
      const combos: string[] = [];
      if (itemCombo1) combos.push(itemCombo1);
      if (itemCombo2) combos.push(itemCombo2);
      
      if (combos.length > 0) newFilter.itemCombos = combos;
    }
    
    if (existingFilterIndex >= 0) {
      if (!hasContextualFilters(newFilter)) {
        onRemoveFilter(existingFilterIndex);
      } else {
        const updatedFilters = [...filters];
        updatedFilters[existingFilterIndex] = newFilter;
        onClearAll();
        updatedFilters.forEach(filter => onAddFilter(filter));
      }
    } else {
      onAddFilter(newFilter);
    }
  };
  
  const hasContextualFilters = (filter: ContextualFilter): boolean => {
    return !!(
      (filter.starLevel && filter.starLevel.length > 0) ||
      filter.item1 || filter.item2 || filter.item3 ||
      filter.traitTier ||
      (filter.unitHolders && filter.unitHolders.length > 0) ||
      (filter.itemCombos && filter.itemCombos.length > 0)
    );
  };
  
  useEffect(() => {
    if (selectedEntity) {
      applyCurrentFilter();
    }
  }, [starLevel, item1, item2, item3, traitTier, unitHolders, itemCombo1, itemCombo2]);
  
  const getContextSpecificOptions = (type: string) => {
    if (!selectedEntity) return [];
    
    if (type === 'unit-items' && currentFilterType === 'unit' && unitItemRelations[selectedEntity]) {
      return entityOptions.items.filter(item => 
        unitItemRelations[selectedEntity]?.includes(item.id)
      );
    }
    
    if (type === 'item-units' && currentFilterType === 'item' && itemUnitRelations[selectedEntity]) {
      return entityOptions.units.filter(unit => 
        itemUnitRelations[selectedEntity]?.includes(unit.id)
      );
    }
    
    if (type === 'item-combos' && currentFilterType === 'item' && itemComboRelations[selectedEntity]) {
      return entityOptions.items.filter(item => 
        item.id !== selectedEntity && itemComboRelations[selectedEntity]?.includes(item.id)
      );
    }
    
    return [];
  };
  
  const getEntityName = (id: string, type: 'unit' | 'trait' | 'item'): string => {
    const options = type === 'unit' ? entityOptions.units :
                    type === 'trait' ? entityOptions.traits :
                    entityOptions.items;
                    
    return options.find(opt => opt.id === id)?.name || id;
  };
  
  const getEntityOptionByID = (id: string, type: 'unit' | 'trait' | 'item'): FilterOption | undefined => {
    const options = type === 'unit' ? entityOptions.units :
                    type === 'trait' ? entityOptions.traits :
                    entityOptions.items;
                    
    return options.find(opt => opt.id === id);
  };
  
  const formatFilterDisplay = (filter: ContextualFilter): React.ReactNode => {
    const entityName = getEntityName(filter.entity, filter.entityType);
    const entityOption = getEntityOptionByID(filter.entity, filter.entityType);
    const contextParts = [];
    
    if (filter.starLevel?.length) {
      contextParts.push(`${filter.starLevel.map(lvl => `${lvl}★`).join('/')} stars`);
    }
    
    const itemNames = [];
    if (filter.item1) itemNames.push(getEntityName(filter.item1, 'item'));
    if (filter.item2) itemNames.push(getEntityName(filter.item2, 'item'));
    if (filter.item3) itemNames.push(getEntityName(filter.item3, 'item'));
    
    if (itemNames.length > 0) {
      contextParts.push(`with ${itemNames.join(', ')}`);
    }
    
    if (filter.traitTier) {
      const traitData = traitsJson.origins[filter.entity as keyof typeof traitsJson.origins] || 
                       traitsJson.classes[filter.entity as keyof typeof traitsJson.classes];
      
      if (traitData && traitData.tiers) {
        const tierIndex = parseInt(filter.traitTier) - 1;
        if (tierIndex >= 0 && tierIndex < traitData.tiers.length) {
          const unitCount = traitData.tiers[tierIndex].units;
          contextParts.push(`${unitCount} units`);
        }
      }
    }
    
    if (filter.unitHolders?.length) {
      if (filter.unitHolders.length === 1) {
        contextParts.push(`on ${getEntityName(filter.unitHolders[0], 'unit')}`);
      } else {
        contextParts.push(`on ${filter.unitHolders.length} units`);
      }
    }
    
    if (filter.itemCombos?.length) {
      if (filter.itemCombos.length === 1) {
        contextParts.push(`with ${getEntityName(filter.itemCombos[0], 'item')}`);
      } else {
        contextParts.push(`with ${filter.itemCombos.length} items`);
      }
    }

    // Get the appropriate icon based on filter type and tier
    let iconSrc = '';
    if (entityOption) {
      if (filter.entityType === 'trait' && filter.traitTier) {
        // Use tier-specific icon for traits when tier is selected
        const traitData = traitsJson.origins[filter.entity as keyof typeof traitsJson.origins] || 
                         traitsJson.classes[filter.entity as keyof typeof traitsJson.classes];
        
        if (traitData && traitData.tiers) {
          const tierIndex = parseInt(filter.traitTier) - 1;
          if (tierIndex >= 0 && tierIndex < traitData.tiers.length) {
            const tier = traitData.tiers[tierIndex];
            iconSrc = tier.icon ? `/assets/traits/${tier.icon}` : getTierIcon(filter.entity, tier.units);
          }
        }
      } else {
        iconSrc = getEntityIcon(entityOption, filter.entityType);
      }
    }
    
    return (
      <div className="flex items-center gap-3">
        {iconSrc && (
          <div className="flex-shrink-0">
            {filter.entityType === 'unit' ? (
              <div 
                className="w-8 h-8 rounded-full overflow-hidden border-2"
                style={{ 
                  borderColor: entityOption?.cost ? 
                    ['#9aa4af', '#2ecc71', '#3498db', '#9b59b6', '#f1c40f'][entityOption.cost - 1] || '#9aa4af'
                    : '#9aa4af'
                }}
              >
                <img 
                  src={iconSrc} 
                  alt={entityName} 
                  className="w-full h-full object-cover"
                  onError={(e) => {
                    const target = e.target as HTMLImageElement;
                    target.src = DEFAULT_ICONS.unit;
                  }}
                />
              </div>
            ) : (
              <img 
                src={iconSrc} 
                alt={entityName} 
                className="w-8 h-8 object-contain"
                onError={(e) => {
                  const target = e.target as HTMLImageElement;
                  target.src = DEFAULT_ICONS[filter.entityType];
                }}
              />
            )}
          </div>
        )}
        <div className="overflow-hidden">
          <div className="font-medium truncate">{entityName}</div>
          {contextParts.length > 0 && (
            <div className="text-xs text-cream/70 truncate">{contextParts.join(', ')}</div>
          )}
        </div>
      </div>
    );
  };
  
  return (
    <AnimatePresence>
      {visible && (
        <motion.div
          initial={{ width: 0, opacity: 0 }}
          animate={{ width: '30%', opacity: 1 }}
          exit={{ width: 0, opacity: 0 }}
          transition={{ duration: 0.3 }}
          className={`overflow-visible border-l border-gold/30 bg-brown-light/20 backdrop-blur-md ${className}`}
        >
          <div className="p-4 h-full overflow-y-auto custom-scrollbar">
            <div className="flex items-center justify-between mb-4 pb-2 border-b border-gold/20">
              <h3 className="text-gold font-display text-lg">Advanced Filters</h3>
              <button 
                onClick={onClearAll}
                className="text-xs px-2.5 py-1.5 bg-brown-light/30 hover:bg-brown-light/50 text-cream/80 rounded transition-all hover:text-cream"
              >
                Clear All
              </button>
            </div>
            
            {filters.length > 0 && (
              <div className="mb-6">
                <div className="bg-brown/40 border border-gold/20 rounded-lg overflow-hidden shadow-md">
                  <div className="bg-brown/60 px-4 py-2.5 border-b border-gold/20">
                    <h4 className="text-sm text-gold font-medium">Active Filters ({filters.length})</h4>
                  </div>
                  <div className="p-3 space-y-2.5 max-h-64 overflow-y-auto custom-scrollbar">
                    {filters.map((filter, index) => (
                      <motion.div 
                        key={`${filter.entityType}-${filter.entity}-${index}`}
                        className="bg-brown-light/40 border border-gold/20 shadow-sm rounded-lg p-3 flex items-center justify-between hover:bg-brown-light/50 transition-colors"
                        initial={{ opacity: 0, y: -5 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ duration: 0.2 }}
                        whileHover={{ scale: 1.02 }}
                      >
                        {formatFilterDisplay(filter)}
                        <button 
                          onClick={() => onRemoveFilter(index)}
                          className="ml-2 p-1.5 text-cream/60 hover:text-cream/90 rounded-full hover:bg-brown-light/50 transition-colors"
                          aria-label="Remove filter"
                        >
                          <X size={14} />
                        </button>
                      </motion.div>
                    ))}
                  </div>
                </div>
              </div>
            )}
            
            <div className="mb-5">
              <div className="bg-brown/40 border border-gold/20 rounded-lg overflow-hidden shadow-md mb-5">
                <div className="bg-brown/60 px-4 py-2.5 border-b border-gold/20">
                  <h4 className="text-sm text-gold font-medium">Filter By Entity Type</h4>
                </div>
                <div className="p-3">
                  <div className="flex space-x-2">
                    <button
                      onClick={() => setCurrentFilterType('unit')}
                      className={`flex-1 py-2.5 px-3 text-sm rounded font-medium transition-all ${
                        currentFilterType === 'unit' 
                          ? 'bg-gold/20 text-gold border border-gold/40 shadow-inner shadow-gold/10' 
                          : 'bg-brown-light/30 text-cream/70 hover:bg-brown-light/40 border border-gold/10'
                      }`}
                    >
                      Units
                    </button>
                    <button
                      onClick={() => setCurrentFilterType('trait')}
                      className={`flex-1 py-2.5 px-3 text-sm rounded font-medium transition-all ${
                        currentFilterType === 'trait' 
                          ? 'bg-gold/20 text-gold border border-gold/40 shadow-inner shadow-gold/10' 
                          : 'bg-brown-light/30 text-cream/70 hover:bg-brown-light/40 border border-gold/10'
                      }`}
                    >
                      Traits
                    </button>
                    <button
                      onClick={() => setCurrentFilterType('item')}
                      className={`flex-1 py-2.5 px-3 text-sm rounded font-medium transition-all ${
                        currentFilterType === 'item' 
                          ? 'bg-gold/20 text-gold border border-gold/40 shadow-inner shadow-gold/10' 
                          : 'bg-brown-light/30 text-cream/70 hover:bg-brown-light/40 border border-gold/10'
                      }`}
                    >
                      Items
                    </button>
                  </div>
                </div>
              </div>
              
              <div className="bg-brown/40 border border-gold/20 rounded-lg overflow-hidden shadow-md">
                <div className="bg-brown/60 px-4 py-2.5 border-b border-gold/20">
                  <h4 className="text-sm text-gold font-medium">
                    Select {currentFilterType === 'unit' ? 'Unit' : currentFilterType === 'trait' ? 'Trait' : 'Item'}
                  </h4>
                </div>
                <div className="p-3">
                  <SelectDropdown
                    options={
                      currentFilterType === 'unit' ? entityOptions.units :
                      currentFilterType === 'trait' ? entityOptions.traits :
                      entityOptions.items
                    }
                    value={selectedEntity}
                    onChange={(value) => setSelectedEntity(value as string)}
                    placeholder={`Select ${currentFilterType}...`}
                    entityType={currentFilterType}
                    maxHeight="200px"
                    closeAfterSelect={true}
                  />
                </div>
              </div>
            </div>
            
            {selectedEntity && (
              <div className="space-y-4 mt-5">
                <div className="bg-brown/40 border border-gold/20 rounded-lg overflow-hidden shadow-md">
                  <div className="bg-brown/60 px-4 py-2.5 border-b border-gold/20">
                    <h4 className="text-sm text-gold font-medium">Filter Options</h4>
                  </div>
                  <div className="p-3 space-y-4">
                    {currentFilterType === 'unit' && (
                      <>
                        <div>
                          <label className="text-xs text-cream/80 block mb-1.5 font-medium">Star Level</label>
                          <SelectDropdown
                            options={starLevelOptions}
                            value={starLevel}
                            onChange={(value) => setStarLevel(value as string[])}
                            placeholder="Any star level"
                            multiple={true}
                            entityType="star"
                            showIcons={false}
                            closeAfterSelect={true}
                          />
                        </div>
                        
                        {unitItemRelations[selectedEntity]?.length > 0 && (
                          <>
                            <div>
                              <label className="text-xs text-cream/80 block mb-1.5 font-medium">Item 1</label>
                              <SelectDropdown
                                options={getContextSpecificOptions('unit-items')}
                                value={item1}
                                onChange={(value) => {
                                  setItem1(value as string);
                                  if (!value) {
                                    setItem2('');
                                    setItem3('');
                                  }
                                }}
                                placeholder="Select first item"
                                multiple={false}
                                entityType="item"
                                closeAfterSelect={true}
                              />
                            </div>
                            
                            {item1 && (
                              <div>
                                <label className="text-xs text-cream/80 block mb-1.5 font-medium">Item 2</label>
                                <SelectDropdown
                                  options={getContextSpecificOptions('unit-items')}
                                  value={item2}
                                  onChange={(value) => {
                                    setItem2(value as string);
                                    if (!value) {
                                      setItem3('');
                                    }
                                  }}
                                  placeholder="Select second item"
                                  multiple={false}
                                  entityType="item"
                                  closeAfterSelect={true}
                                />
                              </div>
                            )}
                            
                            {item2 && (
                              <div>
                                <label className="text-xs text-cream/80 block mb-1.5 font-medium">Item 3</label>
                                <SelectDropdown
                                  options={getContextSpecificOptions('unit-items')}
                                  value={item3}
                                  onChange={(value) => setItem3(value as string)}
                                  placeholder="Select third item"
                                  multiple={false}
                                  entityType="item"
                                  closeAfterSelect={true}
                                />
                              </div>
                            )}
                          </>
                        )}
                      </>
                    )}
                    
                    {currentFilterType === 'trait' && (
                      <div>
                        <label className="text-xs text-cream/80 block mb-1.5 font-medium">Trait Tier</label>
                        <SelectDropdown
                          options={getTraitTierOptions(selectedEntity)}
                          value={traitTier}
                          onChange={(value) => setTraitTier(value as string)}
                          placeholder="Any tier"
                          entityType="trait"
                          showIcons={true}
                          closeAfterSelect={true}
                        />
                      </div>
                    )}
                    
                    {currentFilterType === 'item' && (
                      <>
                        {itemUnitRelations[selectedEntity]?.length > 0 && (
                          <div>
                            <label className="text-xs text-cream/80 block mb-1.5 font-medium">Held By Units</label>
                            <SelectDropdown
                              options={getContextSpecificOptions('item-units')}
                              value={unitHolders}
                              onChange={(value) => setUnitHolders(value as string[])}
                              placeholder="Select units"
                              multiple={true}
                              entityType="unit"
                              closeAfterSelect={true}
                            />
                          </div>
                        )}
                        
                        {itemComboRelations[selectedEntity]?.length > 0 && (
                          <>
                            <div>
                              <label className="text-xs text-cream/80 block mb-1.5 font-medium">Item Combo 1</label>
                              <SelectDropdown
                                options={getContextSpecificOptions('item-combos')}
                                value={itemCombo1}
                                onChange={(value) => setItemCombo1(value as string)}
                                placeholder="Select combo item 1"
                                multiple={false}
                                entityType="item"
                                closeAfterSelect={true}
                              />
                            </div>
                            <div>
                              <label className="text-xs text-cream/80 block mb-1.5 font-medium">Item Combo 2</label>
                              <SelectDropdown
                                options={getContextSpecificOptions('item-combos')}
                                value={itemCombo2}
                                onChange={(value) => setItemCombo2(value as string)}
                                placeholder="Select combo item 2"
                                multiple={false}
                                entityType="item"
                                closeAfterSelect={true}
                              />
                            </div>
                          </>
                        )}
                      </>
                    )}
                  </div>
                </div>
              </div>
            )}
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
EOL

# Fix 2: Update stats explorer with working category filters and persistent filters
cat > src/pages/stats-explorer/index.tsx << 'EOL'
import { useState, useMemo, useCallback, useEffect } from 'react';
import { useRouter } from 'next/router';
import Link from 'next/link';
import { useTftData } from '@/utils/useTftData';
import { ArrowUp, ArrowDown } from 'lucide-react';
import { UnitIcon, Card, Layout, LoadingState, ErrorMessage } from '@/components/ui';
import { FeatureBanner, HeaderBanner, StatsCarousel, EntityTabs, ContextualFilterSidebar } from '@/components/common';
import type { EntityType, FilterOption, FilterState } from '@/components/common';
import unitsJson from 'public/mapping/units.json';
import itemsJson from 'public/mapping/items.json';
import traitsJson from 'public/mapping/traits.json';
import { parseCompTraits } from '@/utils/dataProcessing';
import { getEntityIcon, DEFAULT_ICONS, getTierIcon } from '@/utils/paths';
import { BaseStats, ProcessedDisplayTrait } from '@/types';
import { motion } from 'framer-motion';

interface NamedEntity {
  name: string;
  [key: string]: any;
}

interface ProcessedEntity extends BaseStats {
  avgPlacement: number;
  winRate: number;
  top4Rate: number;
  displayIcon?: string;
  tierIcon?: string;
  placementSum?: number;
  winRateSum?: number;
  top4RateSum?: number;
  cost?: number;
  category?: string;
  tier?: number;
  traits?: any[];
  originalUnits?: any[];
  units?: any[];
  numUnits?: number;
}

type SortField = 'count' | 'avgPlacement' | 'winRate' | 'top4Rate';
type SortDirection = 'asc' | 'desc';

interface ContextualFilter {
  entity: string;
  entityType: 'unit' | 'trait' | 'item';
  starLevel?: string[];
  itemsHeld?: string[];
  item1?: string;
  item2?: string;
  item3?: string;
  traitTier?: string;
  unitHolders?: string[];
  itemCombos?: string[];
}

export default function StatsExplorer() {
  const router = useRouter();
  
  const tftDataResult = useTftData() as unknown as Record<string, any>;
  const data = tftDataResult?.data || null;
  const isLoading = tftDataResult?.isLoading || false;
  const error = tftDataResult?.error || null;
  const handleRetry = tftDataResult?.handleRetry || (() => {});
  
  const [search, setSearch] = useState<string>('');
  const [activeTab, setActiveTab] = useState<EntityType>('units');
  const [sort, setSort] = useState<SortField>('count');
  const [dir, setDir] = useState<SortDirection>('desc');
  const [showConditions, setShowConditions] = useState<boolean>(false);
  
  // Category filters state
  const [categoryFilters, setCategoryFilters] = useState<FilterState>({ all: true });
  
  // Active contextual filters - these should NOT reset when tab changes
  const [activeFilters, setActiveFilters] = useState<ContextualFilter[]>([]);
  
  // Generate relation maps for contextual filters
  const relationships = useMemo(() => {
    const unitItemMap: Record<string, string[]> = {};
    const itemUnitMap: Record<string, string[]> = {};
    const itemComboMap: Record<string, string[]> = {};
    
    if (data?.compositions) {
      data.compositions.forEach((comp: any) => {
        comp.units.forEach((unit: any) => {
          if (!unit.id || !unit.items) return;
          
          if (!unitItemMap[unit.id]) {
            unitItemMap[unit.id] = [];
          }
          
          unit.items.forEach((item: any) => {
            if (!item.id) return;
            
            if (!unitItemMap[unit.id].includes(item.id)) {
              unitItemMap[unit.id].push(item.id);
            }
            
            if (!itemUnitMap[item.id]) {
              itemUnitMap[item.id] = [];
            }
            
            if (!itemUnitMap[item.id].includes(unit.id)) {
              itemUnitMap[item.id].push(unit.id);
            }
            
            (unit.items || []).forEach((otherItem: any) => {
              if (!otherItem.id || otherItem.id === item.id) return;
              
              if (!itemComboMap[item.id]) {
                itemComboMap[item.id] = [];
              }
              
              if (!itemComboMap[item.id].includes(otherItem.id)) {
                itemComboMap[item.id].push(otherItem.id);
              }
            });
          });
        });
      });
    }
    
    return { unitItemMap, itemUnitMap, itemComboMap };
  }, [data]);
  
  // Prepare entity options for filtering
  const allEntityOptions = useMemo(() => {
    return {
      units: Object.entries(unitsJson.units)
        .map(([id, u]: [string, any]) => ({ 
          id, 
          name: u.name, 
          icon: u.icon, 
          cost: u.cost 
        }))
        .sort((a, b) => a.cost - b.cost || a.name.localeCompare(b.name)),
      items: Object.entries(itemsJson.items)
        .filter(([_, i]: [string, any]) => i.category !== 'component')
        .map(([id, i]: [string, any]) => ({ 
          id, 
          name: i.name, 
          icon: i.icon, 
          category: i.category 
        }))
        .sort((a, b) => a.name.localeCompare(b.name)),
      traits: [...Object.entries(traitsJson.origins), ...Object.entries(traitsJson.classes)]
        .map(([id, t]: [string, any]) => ({ 
          id, 
          name: t.name, 
          icon: t.icon
        }))
        .sort((a, b) => a.name.localeCompare(b.name))
    };
  }, []);

  // Clear search and RESET category filters when tab changes, but keep contextual filters
  useEffect(() => {
    setSearch('');
    setCategoryFilters({ all: true });
    // Note: We do NOT reset activeFilters here
  }, [activeTab]);

  // Clear all filters (both category and contextual)
  const clearAllFilters = () => {
    setActiveFilters([]);
    setCategoryFilters({ all: true });
  };
  
  // Add a new contextual filter
  const addFilter = (filter: ContextualFilter) => {
    setActiveFilters(prev => {
      const existing = prev.findIndex(f => 
        f.entity === filter.entity && f.entityType === filter.entityType
      );
      
      if (existing >= 0) {
        const newFilters = [...prev];
        newFilters[existing] = filter;
        return newFilters;
      } else {
        return [...prev, filter];
      }
    });
  };
  
  // Remove a contextual filter
  const removeFilter = (index: number) => {
    setActiveFilters(prev => prev.filter((_, i) => i !== index));
  };

  // Handle category filter changes
  const handleCategoryFilterChange = (filterId: string) => {
    setCategoryFilters(prev => {
      if (filterId === 'all') {
        return { all: true };
      }
      
      const { all, ...rest } = prev;
      const newState = { ...rest, [filterId]: !rest[filterId] };
      
      const hasActiveFilters = Object.entries(newState)
        .some(([key, value]) => key !== 'all' && value);
      
      return hasActiveFilters ? { all: false, ...newState } : { all: true };
    });
  };

  // IMPROVED data processing with proper trait grouping and category filtering
  const data_processed = useMemo(() => {
    if (!data?.compositions?.length) {
      return { units: [], items: [], traits: [], comps: [] };
    }
    
    const process = (type: EntityType): ProcessedEntity[] => {
      const entities: Record<string, any> = {};
      
      // Filter compositions based on contextual filters
      const filteredCompositions = data.compositions.filter((comp: any) => {
        if (activeFilters.length === 0) return true;
        
        for (const filter of activeFilters) {
          let matchesFilter = false;
          
          if (filter.entityType === 'unit') {
            const unitInComp = comp.units.find((u: any) => u.id === filter.entity);
            if (!unitInComp) continue;
            
            if (filter.starLevel?.length) {
              matchesFilter = true;
            }
            
            let hasAllSpecifiedItems = true;
            if (filter.item1) {
              const hasItem1 = (unitInComp.items || []).some((item: any) => item.id === filter.item1);
              if (!hasItem1) hasAllSpecifiedItems = false;
            }
            if (filter.item2) {
              const hasItem2 = (unitInComp.items || []).some((item: any) => item.id === filter.item2);
              if (!hasItem2) hasAllSpecifiedItems = false;
            }
            if (filter.item3) {
              const hasItem3 = (unitInComp.items || []).some((item: any) => item.id === filter.item3);
              if (!hasItem3) hasAllSpecifiedItems = false;
            }
            
            if ((filter.item1 || filter.item2 || filter.item3) && !hasAllSpecifiedItems) {
              continue;
            }
            
            if (!filter.starLevel?.length && !filter.item1 && !filter.item2 && !filter.item3) {
              matchesFilter = true;
            } else {
              matchesFilter = true;
            }
          }
          else if (filter.entityType === 'trait') {
            const traitInComp = comp.traits.find((t: any) => t.id === filter.entity);
            if (!traitInComp) continue;
            
            if (filter.traitTier) {
              if (traitInComp.tier < parseInt(filter.traitTier)) continue;
              matchesFilter = true;
            } else {
              matchesFilter = true;
            }
          }
          else if (filter.entityType === 'item') {
            let hasItem = false;
            let matchesHolders = true;
            
            for (const unit of comp.units) {
              if ((unit.items || []).some((i: any) => i.id === filter.entity)) {
                hasItem = true;
                
                if (filter.unitHolders?.length) {
                  if (!filter.unitHolders.includes(unit.id)) {
                    matchesHolders = false;
                  }
                }
                
                if (filter.itemCombos?.length) {
                  const hasAnyCombo = filter.itemCombos.some(comboId => 
                    (unit.items || []).some((i: any) => i.id === comboId)
                  );
                  
                  if (!hasAnyCombo) {
                    matchesHolders = false;
                  }
                }
                
                if (matchesHolders) break;
              }
            }
            
            if (!hasItem || !matchesHolders) continue;
            matchesFilter = true;
          }
          
          if (matchesFilter) return true;
        }
        
        return false;
      });
      
      // Handle different entity types
      if (type === 'units') {
        filteredCompositions.forEach((comp: any) => {
          comp.units.forEach((unit: any) => {
            if (!unit?.id) return;
            
            if (!entities[unit.id]) {
              entities[unit.id] = { 
                ...unit, 
                count: 0, 
                winRateSum: 0, 
                top4RateSum: 0, 
                placementSum: 0
              };
            }
            
            entities[unit.id].count += comp.count ?? 0;
            entities[unit.id].placementSum += (comp.avgPlacement ?? 0) * (comp.count ?? 0);
            entities[unit.id].winRateSum += ((comp.winRate ?? 0) / 100) * (comp.count ?? 0);
            entities[unit.id].top4RateSum += ((comp.top4Rate ?? 0) / 100) * (comp.count ?? 0);
          });
        });
      } 
      else if (type === 'items') {
        filteredCompositions.forEach((comp: any) => {
          comp.units.forEach((unit: any) => {
            (unit.items || []).forEach((item: any) => {
              if (!item?.id) return;
              
              if (!entities[item.id]) {
                entities[item.id] = { 
                  ...item, 
                  count: 0, 
                  winRateSum: 0, 
                  top4RateSum: 0, 
                  placementSum: 0
                };
              }
              
              entities[item.id].count += comp.count ?? 0;
              entities[item.id].placementSum += (comp.avgPlacement ?? 0) * (comp.count ?? 0);
              entities[item.id].winRateSum += ((comp.winRate ?? 0) / 100) * (comp.count ?? 0);
              entities[item.id].top4RateSum += ((comp.top4Rate ?? 0) / 100) * (comp.count ?? 0);
            });
          });
        });
      }
      else if (type === 'traits') {
        // MAJOR FIX: Group traits by trait ID, accumulating across all tiers
        filteredCompositions.forEach((comp: any) => {
          comp.traits.forEach((trait: any) => {
            if (!trait?.id) return;
            
            const entityKey = trait.id; // Group by trait ID, not tier
            
            if (!entities[entityKey]) {
              // Initialize with the highest tier version we've seen
              entities[entityKey] = { 
                ...trait, 
                count: 0, 
                winRateSum: 0, 
                top4RateSum: 0, 
                placementSum: 0,
                maxTier: trait.tier,
                maxNumUnits: trait.numUnits,
                tierFrequency: {}
              };
            }
            
            // Track tier frequency for display
            if (!entities[entityKey].tierFrequency[trait.tier]) {
              entities[entityKey].tierFrequency[trait.tier] = 0;
            }
            entities[entityKey].tierFrequency[trait.tier] += comp.count || 1;
            
            // Keep track of the highest tier and unit count seen
            if (trait.tier > entities[entityKey].maxTier) {
              entities[entityKey].maxTier = trait.tier;
              entities[entityKey].maxNumUnits = trait.numUnits;
              entities[entityKey].tierIcon = trait.tierIcon;
            }
            
            entities[entityKey].count += comp.count ?? 0;
            entities[entityKey].placementSum += (comp.avgPlacement ?? 0) * (comp.count ?? 0);
            entities[entityKey].winRateSum += ((comp.winRate ?? 0) / 100) * (comp.count ?? 0);
            entities[entityKey].top4RateSum += ((comp.top4Rate ?? 0) / 100) * (comp.count ?? 0);
          });
        });
      }
      else if (type === 'comps') {
        filteredCompositions.forEach((comp: any) => {
          if (!comp?.id) return;
          
          if (!entities[comp.id]) {
            entities[comp.id] = { 
              ...comp, 
              count: 0, 
              winRateSum: 0, 
              top4RateSum: 0, 
              placementSum: 0,
              // Preserve original composition properties for categorization
              units: comp.units,
              traits: comp.traits
            };
          }
          
          entities[comp.id].count += comp.count ?? 0;
          entities[comp.id].placementSum += (comp.avgPlacement ?? 0) * (comp.count ?? 0);
          entities[comp.id].winRateSum += ((comp.winRate ?? 0) / 100) * (comp.count ?? 0);
          entities[comp.id].top4RateSum += ((comp.top4Rate ?? 0) / 100) * (comp.count ?? 0);
        });
      }
      
      // Process entities and calculate final stats
      const processedEntities = Object.values(entities)
        .filter(e => e.count > 0)
        .map(e => {
          const avgPlacement = (e.placementSum || 0) / (e.count || 1);
          const winRate = ((e.winRateSum || 0) / (e.count || 1)) * 100;
          const top4Rate = ((e.top4RateSum || 0) / (e.count || 1)) * 100;
          
          const processedEntity = {
            id: e.id,
            name: e.name,
            icon: e.icon,
            count: e.count,
            avgPlacement,
            winRate,
            top4Rate,
            cost: e.cost,
            category: e.category,
            tier: e.maxTier || e.tier,
            numUnits: e.maxNumUnits || e.numUnits,
            displayIcon: e.displayIcon,
            tierIcon: e.tierIcon,
            // Preserve units and traits for compositions
            units: e.units,
            traits: e.traits
          };
          
          // For traits, determine the best display icon
          if (type === 'traits' && e.maxTier) {
            const traitData = traitsJson.origins[e.id as keyof typeof traitsJson.origins] || 
                             traitsJson.classes[e.id as keyof typeof traitsJson.classes];
            
            if (traitData) {
              processedEntity.displayIcon = getTierIcon(e.id, e.maxNumUnits || 1);
              processedEntity.tierIcon = processedEntity.displayIcon;
            }
          }
          
          return processedEntity;
        });

      // Apply category filtering AFTER processing
      let categoryFilteredEntities = processedEntities;
      
      if (!categoryFilters.all) {
        categoryFilteredEntities = processedEntities.filter(entity => {
          if (type === 'units' && entity.cost !== undefined) {
            return categoryFilters[entity.cost.toString()];
          } else if (type === 'items' && entity.category) {
            return categoryFilters[entity.category];
          } else if (type === 'traits') {
            // For traits, check if it's an origin or class
            const isOrigin = Object.keys(traitsJson.origins).includes(entity.id);
            return categoryFilters[isOrigin ? 'origin' : 'class'];
          } else if (type === 'comps') {
            // For comps, implement some basic categorization
            // This is simplified - you might want more sophisticated logic
            const hasHighCostUnits = entity.units?.some((u: any) => u.cost >= 4);
            const category = hasHighCostUnits ? 'fast9' : 'reroll';
            return categoryFilters[category];
          }
          return true;
        });
      }
      
      return categoryFilteredEntities;
    };
    
    // Filter by search term
    const matchSearch = (e: NamedEntity): boolean => 
      !search || e.name.toLowerCase().includes(search.toLowerCase());
    
    // Sort function
    const sortFn = (a: ProcessedEntity, b: ProcessedEntity): number => {
      const av = a[sort] || 0, bv = b[sort] || 0;
      return dir === 'asc' ? av - bv : bv - av;
    };
    
    // Process and filter each entity type
    return {
      units: process('units').filter(matchSearch).sort(sortFn),
      items: process('items').filter(matchSearch).sort(sortFn),
      traits: process('traits').filter(matchSearch).sort(sortFn),
      comps: process('comps').filter(matchSearch).sort(sortFn)
    };
  }, [data, activeFilters, categoryFilters, search, sort, dir, activeTab]);

  // Column definitions
  const columns = [
    { id: 'count', name: 'Frequency' },
    { id: 'avgPlacement', name: 'Avg Place' },
    { id: 'winRate', name: 'Win %' },
    { id: 'top4Rate', name: 'Top 4 %' }
  ];

  // Category options for filter buttons - FIXED to work with category filters
  const getCategoryOptions = () => {
    switch(activeTab) {
      case 'units':
        return Array.from(new Set(allEntityOptions.units.map(u => u.cost?.toString() || '')))
          .filter(Boolean)
          .map(cost => ({ id: cost, name: `${cost} Cost` }))
          .sort((a, b) => parseInt(a.id) - parseInt(b.id));
      case 'items':
        return Array.from(
          new Set(allEntityOptions.items.map(i => i.category).filter(Boolean))
        ).map(c => ({ 
          id: c || '', 
          name: c ? c.replace(/-/g, ' ').replace(/\b\w/g, (char: string) => char.toUpperCase()) : ''
        }));
      case 'traits':
        return [
          { id: 'origin', name: 'Origins' },
          { id: 'class', name: 'Classes' }
        ];
      case 'comps':
        return [
          { id: 'fast9', name: 'Fast 9' },
          { id: 'reroll', name: 'Reroll' },
          { id: 'standard', name: 'Standard' }
        ];
      default:
        return [];
    }
  };

  // Toggle conditions panel
  const toggleConditions = () => {
    setShowConditions(!showConditions);
  };
  
  // Get class for conditional styling with updated thresholds
  const getStatColor = (item: ProcessedEntity, stat: string): string => {
    if (stat === 'avgPlacement') {
      if (item.avgPlacement < 4.1) return 'text-gold font-medium';
      if (item.avgPlacement < 4.4) return 'text-amber-300 font-medium';
      if (item.avgPlacement > 4.8) return 'text-red-400';
      return 'text-cream';
    }
    if (stat === 'winRate') {
      if (item.winRate > 15) return 'text-gold font-medium';
      if (item.winRate > 12.5) return 'text-amber-300 font-medium';
      if (item.winRate < 8) return 'text-red-400';
      return 'text-cream';
    }
    if (stat === 'top4Rate') {
      if (item.top4Rate > 55) return 'text-gold font-medium';
      if (item.top4Rate > 50) return 'text-amber-300 font-medium';
      if (item.top4Rate < 45) return 'text-red-400';
      return 'text-cream';
    }
    return 'text-cream';
  };

  // Loading and error states
  if (isLoading) return (
    <Layout>
      <LoadingState message="Loading stats data..." />
    </Layout>
  );

  if (error) return (
    <Layout>
      <div className="mt-6">
        <ErrorMessage 
          message={error && typeof error === 'object' && 'message' in error ? String(error.message) : 'An error occurred'} 
          onRetry={handleRetry} 
        />
      </div>
    </Layout>
  );

  return (
    <Layout title="Stats Explorer">
      <HeaderBanner />
      <StatsCarousel />
      
      <div className="mt-8">
        <FeatureBanner title="Stats Explorer - Performance Metrics" />
        
        <EntityTabs
          activeTab={activeTab}
          onTabChange={setActiveTab}
          filterOptions={getCategoryOptions()}
          filterState={categoryFilters}
          onFilterChange={handleCategoryFilterChange} // FIXED: Now properly connected
          searchValue={search}
          onSearchChange={setSearch}
          showConditionsButton={true}
          showConditions={showConditions}
          onToggleConditions={toggleConditions}
          className="mt-1"
        />

        <div className="flex mt-4">
          <Card className={`p-0 overflow-hidden backdrop-filter backdrop-blur-md bg-brown/10 border border-gold/30 shadow-inner shadow-gold/5 flex-1 flex ${showConditions ? 'rounded-r-none' : ''}`}>
            <div className="stats-table-container w-full">
              <table className="w-full border-collapse stats-table">
                <thead>
                  <tr className="bg-brown-light/30 text-gold text-sm border-b border-gold/30">
                    <th className="px-4 py-3 text-left sticky top-0 bg-brown z-10 backdrop-blur-sm" style={{width:'40%'}}>
                      {activeTab === 'comps' ? 'Comp' : activeTab.slice(0, -1).charAt(0).toUpperCase() + activeTab.slice(0, -1).slice(1)}
                    </th>
                    {columns.map(col => (
                      <th 
                        key={col.id} 
                        className="px-4 py-3 text-center cursor-pointer sticky top-0 bg-brown z-10 backdrop-blur-sm"
                        style={{width: '15%'}}
                        onClick={() => {
                          setDir(sort === col.id ? (dir === 'asc' ? 'desc' : 'asc') : 'desc');
                          setSort(col.id as SortField);
                        }}
                      >
                        <div className="flex items-center justify-center gap-1">
                          <span>{col.name}</span>
                          <span className="w-4 ml-1 flex justify-center">
                            {sort === col.id ? 
                              (dir === 'asc' ? <ArrowUp className="h-3 w-3 text-gold" /> : <ArrowDown className="h-3 w-3 text-gold" />) : 
                              null
                            }
                          </span>
                        </div>
                      </th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {data_processed[activeTab].map((item, idx) => (
                    <motion.tr 
                      key={`${item.id}-${idx}`} 
                      className="border-t border-gold/10 cursor-pointer hover:bg-gold/10 h-16" // FIXED: Add explicit height
                      onClick={() => router.push(`/entity/${activeTab}/${item.id}`)}
                      initial={{ opacity: 0 }}
                      animate={{ opacity: 1 }}
                      transition={{ duration: 0.2, delay: idx * 0.03 }}
                      whileHover={{ backgroundColor: 'rgba(245, 158, 11, 0.15)' }}
                    >
                      <td className="px-4 py-3">
                        <div className="flex items-center gap-3">
                          {activeTab === 'units' && <UnitIcon unit={item} size="md" />}
                          {activeTab === 'items' && (
                            <img 
                              src={getEntityIcon(item, 'item')} 
                              alt={item.name} 
                              className="w-10 h-10 object-contain"
                              onError={(e) => {
                                const target = e.target as HTMLImageElement;
                                target.src = DEFAULT_ICONS.item;
                              }}
                            />
                          )}
                          {activeTab === 'traits' && (
                            <img 
                              src={item.tierIcon || item.displayIcon || getEntityIcon(item, 'trait')} 
                              alt={item.name} 
                              className="w-8 h-8 object-contain"
                              onError={(e) => {
                                const target = e.target as HTMLImageElement;
                                target.src = DEFAULT_ICONS.trait;
                              }}
                            />
                          )}
                          {activeTab === 'comps' && item.traits && (
                            <div className="flex gap-1">
                              {parseCompTraits(item.name, item.traits).map((trait: ProcessedDisplayTrait, j: number) => (
                                <img 
                                  key={j} 
                                  src={trait.tierIcon || getEntityIcon(trait, 'trait')} 
                                  alt={trait.name} 
                                  className="w-6 h-6 object-contain"
                                  onError={(e) => {
                                    const target = e.target as HTMLImageElement;
                                    target.src = DEFAULT_ICONS.trait;
                                  }}
                                />
                              ))}
                            </div>
                          )}
                          <div className="font-medium">
                            {item.name}
                            {activeTab === 'traits' && item.numUnits && (
                              <span className="ml-2 text-sm text-cream/80">({item.numUnits} units)</span>
                            )}
                          </div>
                        </div>
                      </td>
                      <td className="px-4 py-3 text-center">
                        <span className="text-corona-light">{item.count}</span>
                      </td>
                      <td className="px-4 py-3 text-center">
                        <span className={getStatColor(item, 'avgPlacement')}>
                          {item.avgPlacement?.toFixed(2)}
                        </span>
                      </td>
                      <td className="px-4 py-3 text-center">
                        <span className={getStatColor(item, 'winRate')}>
                          {item.winRate?.toFixed(1)}%
                        </span>
                      </td>
                      <td className="px-4 py-3 text-center">
                        <span className={getStatColor(item, 'top4Rate')}>
                          {item.top4Rate?.toFixed(1)}%
                        </span>
                      </td>
                    </motion.tr>
                  ))}
                  {data_processed[activeTab].length === 0 && (
                    <tr>
                      <td colSpan={5} className="px-4 py-8 text-center text-cream/60">
                        {(activeFilters.length > 0 || !categoryFilters.all) ? (
                          <div className="flex flex-col items-center">
                            <div className="text-gold mb-2">No matches found</div>
                            <div className="text-cream/60 mb-3">Try removing some filters to see more results</div>
                            <button 
                              onClick={clearAllFilters}
                              className="px-3 py-1.5 rounded-md bg-solar-flare/20 border border-solar-flare/40 text-solar-flare hover:bg-solar-flare/30 transition-colors"
                            >
                              Clear All Filters
                            </button>
                          </div>
                        ) : (
                          "No data available"
                        )}
                      </td>
                    </tr>
                  )}
                </tbody>
              </table>
            </div>
            
            <ContextualFilterSidebar
              visible={showConditions}
              entityOptions={allEntityOptions}
              unitItemRelations={relationships.unitItemMap}
              itemUnitRelations={relationships.itemUnitMap}
              itemComboRelations={relationships.itemComboMap}
              filters={activeFilters}
              onAddFilter={addFilter}
              onRemoveFilter={removeFilter}
              onClearAll={() => setActiveFilters([])} // Only clear contextual filters
            />
          </Card>
        </div>
      </div>
    </Layout>
  );
}
EOL

# =====================
# ENTITY COMPONENTS SECTION
# =====================

# Fix UnitDetail.tsx component
cat > src/components/entity/UnitDetail.tsx << 'EOL'
import React, { useState } from 'react';
import Link from 'next/link';
import { UnitIcon, ItemIcon, StatsPanel, TraitIcon, PlacementDistribution } from '@/components/ui';
import traitsJson from 'public/mapping/traits.json';
import { Heart, Droplet, Shield, Sword, Zap, Gauge, FastForward, ArrowLeftRight } from 'lucide-react';
import { ProcessedUnit } from '@/types';
import { getIconPath, getEntityIcon, DEFAULT_ICONS, getUnitTraits, getTraitInfo } from '@/utils/paths';

export default function UnitDetail({ 
  entityData, 
  unitDetails 
}: { 
  entityData: ProcessedUnit | null, 
  unitDetails: any 
}) {
  const [starLevel, setStarLevel] = useState<number>(1);
  
  const statIconComponents = {
    health: Heart,
    mana: Droplet,
    armor: Shield,
    mr: Shield,
    damage: Sword, 
    attack_speed: FastForward,
    crit_rate: Gauge,
    range: ArrowLeftRight,
    dps: Zap
  };

  if (!entityData) return null;

  // Calculate scaled stats based on star level
  const getScaledStat = (statKey: string, baseStat: number): number => {
    if (!baseStat) return 0;
    
    const scalingFactors = {
      health: [1, 1.8, 3.24, 5.832],
      armor: [1, 1.5, 2.25, 3.375],
      mr: [1, 1.5, 2.25, 3.375],
      damage: [1, 1.5, 2.25, 3.375],
      dps: [1, 1.5, 2.25, 3.375]
    };
    
    const factor = scalingFactors[statKey as keyof typeof scalingFactors]?.[starLevel - 1] || 1;
    const scaledValue = Math.round(baseStat * factor * 10) / 10;
    
    // Cap extremely high values that could be calculation errors
    const cap = statKey === 'health' ? 10000 : 
              (statKey === 'attack_speed' ? 5.0 : 
              (statKey.includes('rate') ? 100 : 1000));
              
    return Math.min(scaledValue, cap);
  };

  // Star button component
  const StarButton = ({ level, isActive, onClick }: { level: number, isActive: boolean, onClick: () => void }) => {
    const starColors = {
      1: "text-amber-700",
      2: "text-gray-400",
      3: "text-amber-400",
      4: "text-emerald-400"
    };
    
    const starText = {
      1: "★",
      2: "★★",
      3: "★★★",
      4: "★★★★"
    };
    
    return (
      <button
        onClick={onClick}
        className={`px-1.5 py-0.5 rounded transition-all ${
          isActive 
            ? `${starColors[level as keyof typeof starColors]} bg-brown-light/50` 
            : 'text-cream/40 hover:text-cream/60'
        }`}
        style={{ letterSpacing: "-1px" }}
      >
        {starText[level as keyof typeof starText]}
      </button>
    );
  };

  // Get unit traits
  const unitTraitsList = getUnitTraits(unitDetails);
  
  // Prepare placement data for distribution chart
  const placementData = entityData.relatedComps ? 
    entityData.relatedComps.reduce((acc, comp) => {
      if (!comp.placementData) return acc;
      
      // Aggregate placement data from all related compositions
      comp.placementData.forEach(pd => {
        const existing = acc.find(a => a.placement === pd.placement);
        if (existing) {
          existing.count += pd.count;
        } else {
          acc.push({ ...pd });
        }
      });
      return acc;
    }, [] as Array<{ placement: number; count: number }>) : 
    undefined;

  // IMPROVED: Check if bestItems is available
  const hasBestItems = entityData.bestItems && entityData.bestItems.length > 0;
  // IMPROVED: Check if relatedComps is available
  const hasRelatedComps = entityData.relatedComps && entityData.relatedComps.length > 0;

  return (
    <>
      <div className="flex items-center gap-4 border-b border-gold/30 pb-4 mb-4">
        <UnitIcon unit={entityData} size="lg" />
        <div>
          <h1 className="text-xl font-bold text-gold">{entityData.name}</h1>
          <p className="text-sm text-cream/80">{entityData.cost} 🪙</p>
        </div>
      </div>
      
      <div className="grid md:grid-cols-2 gap-6">
        <div className="space-y-6">
          <div className="bg-brown-dark/20 rounded-lg p-4 shadow-md border border-gold/5">
            <h2 className="text-lg font-semibold text-gold mb-4">Traits</h2>
            <div className="flex flex-wrap gap-2">
              {unitTraitsList.map((traitEntry, i) => {
                // Get full trait info
                const traitInfo = getTraitInfo(traitEntry.id);
                if (!traitInfo) return null;
                
                return (
                  <Link href={`/entity/traits/${traitEntry.id}`} key={i}>
                    <div className="flex items-center gap-2 bg-brown-light/40 rounded p-2 hover:bg-gold/15 transition-all shadow-sm">
                      <TraitIcon 
                        trait={{
                          id: traitEntry.id,
                          name: traitInfo.name,
                          icon: traitInfo.icon
                        }}
                        size="sm"
                      />
                      <span>{traitInfo.name}</span>
                    </div>
                  </Link>
                );
              })}
            </div>
          </div>
          
          <div className="bg-brown-dark/20 rounded-lg p-4 shadow-md border border-gold/5">
            <h2 className="text-lg font-semibold text-gold mb-4">Performance Stats</h2>
            <StatsPanel stats={{
              ...entityData.stats,
              placementData
            }} />
          </div>
        </div>
        
        <div className="space-y-6">
          <div className="bg-brown-dark/20 rounded-lg p-4 shadow-md border border-gold/5">
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-lg font-semibold text-gold">Stats & Ability</h2>
              <div className="flex space-x-1">
                {[1, 2, 3, 4].map(level => (
                  <StarButton 
                    key={level}
                    level={level}
                    isActive={starLevel === level}
                    onClick={() => setStarLevel(level)}
                  />
                ))}
              </div>
            </div>
            
            <div className="grid grid-cols-3 gap-3 mb-4">
              {unitDetails?.stats && Object.entries(unitDetails.stats).map(([key, value], i) => {
                // Skip mana fields, we'll handle them specially
                if (key === 'start_mana' || key === 'max_mana') {
                  // Only show combined mana on start_mana to avoid duplication
                  if (key === 'start_mana' && unitDetails.stats.max_mana !== undefined) {
                    return (
                      <div key={i} className="flex items-center gap-2 bg-brown-light/40 px-3 py-2 rounded shadow-sm">
                        <Droplet size={16} className="text-gold" strokeWidth={2} />
                        <div className="text-xs flex-grow">Mana</div>
                        <div className="font-semibold text-gold-light">
                          {unitDetails.stats.start_mana}/{unitDetails.stats.max_mana}
                        </div>
                      </div>
                    );
                  }
                  return null;
                }
                
                // Regular stat handling
                const statName = key.replace(/_/g, ' ').replace(/\b\w/g, c => c.toUpperCase());
                const scaledValue = getScaledStat(key, value as number);
                
                return (
                  <div key={i} className="flex items-center gap-2 bg-brown-light/40 px-3 py-2 rounded shadow-sm">
                    {statIconComponents[key as keyof typeof statIconComponents] && React.createElement(statIconComponents[key as keyof typeof statIconComponents], {
                      size: 16,
                      className: "text-gold",
                      strokeWidth: 2
                    })}
                    <div className="text-xs flex-grow">{statName}</div>
                    <div className="font-semibold text-gold-light">{scaledValue}</div>
                  </div>
                );
              })}
            </div>
            
            {/* Ability description below stats */}
            {unitDetails?.ability && (
              <div className="bg-brown-light/40 p-3 rounded mt-4 shadow-sm border border-gold/5">
                <h3 className="text-md font-semibold text-gold border-b border-gold/30 pb-2 mb-2">
                  {unitDetails.ability.name}
                </h3>
                <p className="text-sm whitespace-pre-line">{unitDetails.ability.description}</p>
              </div>
            )}
          </div>

          {/* Using non-null assertion for TypeScript */}
          {hasBestItems && (
            <div className="bg-brown-dark/20 rounded-lg p-4 shadow-md border border-gold/5">
              <h2 className="text-lg font-semibold text-gold mb-4">Best Items</h2>
              <div className="grid grid-cols-3 gap-3">
                {entityData.bestItems!.map((item, i) => (
                  <Link href={`/entity/items/${item.id}`} key={i}>
                    <div className="flex flex-col items-center gap-2 bg-brown-light/40 p-3 rounded hover:bg-gold/15 transition-all shadow-sm">
                      <ItemIcon item={item} size="md" />
                      <div className="text-center">
                        <div className="text-sm font-medium truncate max-w-28">{item.name}</div>
                        <div className="flex flex-col text-xs">
                          <span className="text-gold-light">
                            Win: {Math.min(item.stats?.winRate || 0, 100).toFixed(1)}%
                          </span>
                          <span className="text-cream/70">
                            Avg: {item.stats?.avgPlacement?.toFixed(2) || '?'}
                          </span>
                        </div>
                      </div>
                    </div>
                  </Link>
                ))}
              </div>
            </div>
          )}
          
          {/* Using non-null assertion for TypeScript */}
          {hasRelatedComps && (
            <div className="bg-brown-dark/20 rounded-lg p-4 shadow-md border border-gold/5">
              <h2 className="text-lg font-semibold text-gold mb-4">Top Compositions</h2>
              <div className="grid grid-cols-2 gap-3">
                {entityData.relatedComps!.slice(0, 4).map((comp, i) => (
                  <Link href={`/entity/comps/${comp.id}`} key={i}>
                    <div className="bg-brown-light/40 p-3 rounded hover:bg-gold/15 transition-all shadow-sm">
                      <div className="flex justify-center gap-1 mb-2">
                        {(comp.traits || []).slice(0, 3).map((trait, j) => (
                          <TraitIcon
                            key={j}
                            trait={trait}
                            size="sm"
                          />
                        ))}
                      </div>
                      <div className="text-sm font-medium text-center truncate">{comp.name?.split('&')[0] || 'Comp'}</div>
                      <div className="text-xs text-center mt-2 flex justify-between px-2">
                        <span>Win: {Math.min(comp.winRate || 0, 100).toFixed(1)}%</span>
                        <span>Avg: {comp.avgPlacement?.toFixed(2)}</span>
                      </div>
                    </div>
                  </Link>
                ))}
              </div>
            </div>
          )}

          {/* FALLBACK: If no relationship data is available */}
          {!hasBestItems && !hasRelatedComps && (
            <div className="bg-brown-dark/20 rounded-lg p-4 shadow-md border border-gold/5">
              <h2 className="text-lg font-semibold text-gold mb-3">Usage Info</h2>
              <p className="text-cream/70 text-center p-4">
                No detailed usage information available for this unit yet. 
                Check back later for data about which items work best with this unit.
              </p>
            </div>
          )}
        </div>
      </div>
    </>
  );
}
EOL

# Update TraitDetail.tsx
cat > src/components/entity/TraitDetail.tsx << 'EOL'
import React from 'react';
import Link from 'next/link';
import { StatsPanel, UnitIcon, TraitIcon, PlacementDistribution } from '@/components/ui';
import unitsJson from 'public/mapping/units.json';
import { ProcessedTrait } from '@/types';
import { getTierName, getEntityIcon, getTraitInfo } from '@/utils/paths';

export default function TraitDetail({ 
  entityData, 
  traitDetails, 
  traitType, 
  entityId 
}: { 
  entityData: ProcessedTrait | null, 
  traitDetails: any, 
  traitType: string, 
  entityId: string 
}) {
  if (!entityData) return null;

  // Prepare placement data for distribution chart
  const placementData = entityData.relatedComps ? 
    entityData.relatedComps.reduce((acc, comp) => {
      if (!comp.placementData) return acc;
      
      // Aggregate placement data from all related compositions
      comp.placementData.forEach(pd => {
        const existing = acc.find(a => a.placement === pd.placement);
        if (existing) {
          existing.count += pd.count;
        } else {
          acc.push({ ...pd });
        }
      });
      return acc;
    }, [] as Array<{ placement: number; count: number }>) : 
    undefined;

  // Get the base trait information to ensure we're using the base icon
  const baseTraitInfo = getTraitInfo ? getTraitInfo(entityId) : null;
  const baseIcon = baseTraitInfo?.icon || entityData.icon;

  return (
    <>
      {/* UPDATED: Custom handling for trait icon */}
      <div className="flex items-center gap-4 border-b border-gold/30 pb-4 mb-6">
        <div className="w-16 h-16 flex items-center justify-center">
          {baseIcon ? (
            <img 
              src={`/assets/traits/${baseIcon}`} 
              alt={entityData.name} 
              className="w-full h-full object-contain"
              onError={(e) => {
                (e.target as HTMLImageElement).src = '/assets/app/default.png';
              }}
            />
          ) : (
            // Fallback to using a simplified trait object with TraitIcon
            <TraitIcon 
              trait={{
                id: entityId,
                name: entityData.name,
                icon: entityData.icon
              }} 
              size="lg" 
            />
          )}
        </div>
        <div>
          <h1 className="text-xl font-bold text-gold">{entityData.name}</h1>
          <p className="text-sm text-cream/80">{traitType === 'origins' ? 'Origin' : 'Class'}</p>
        </div>
      </div>
      
      <div className="grid md:grid-cols-2 gap-6">
        <div className="space-y-6">
          {traitDetails?.description && (
            <div className="bg-brown-dark/20 rounded-lg p-4 shadow-md border border-gold/5">
              <h2 className="text-lg font-semibold text-gold mb-3">Description</h2>
              <p className="text-sm whitespace-pre-line">{traitDetails.description}</p>
            </div>
          )}
          
          {traitDetails?.tiers && traitDetails.tiers.length > 0 && (
            <div className="bg-brown-dark/20 rounded-lg p-4 shadow-md border border-gold/5">
              <h2 className="text-lg font-semibold text-gold mb-3">Trait Tiers</h2>
              <div className="space-y-2">
                {traitDetails.tiers.map((tier: { icon: string, units: number, value: string }, i: number) => (
                  <div key={i} className="flex items-center gap-3 p-3 rounded shadow-sm bg-brown-light/40 hover:bg-gold/15 transition-all">
                    <div className="flex items-center gap-2">
                      <img 
                        src={`/assets/traits/${tier.icon || baseIcon || entityData.icon}`} 
                        alt={`Tier ${i+1}`} 
                        className="w-8 h-8"
                        onError={(e) => {
                          (e.target as HTMLImageElement).src = '/assets/app/default.png';
                        }}
                      />
                      <span className="font-semibold">{tier.units}-units</span>
                    </div>
                    <p className="text-sm">{tier.value}</p>
                  </div>
                ))}
              </div>
            </div>
          )}
          
          <div className="bg-brown-dark/20 rounded-lg p-4 shadow-md border border-gold/5">
            <h2 className="text-lg font-semibold text-gold mb-3">Performance Stats</h2>
            <StatsPanel stats={{...entityData.stats, placementData}} />
          </div>
        </div>
        
        <div className="space-y-6">
          <div className="bg-brown-dark/20 rounded-lg p-4 shadow-md border border-gold/5">
            <h2 className="text-lg font-semibold text-gold mb-3">Units with this Trait</h2>
            <div className="grid grid-cols-2 sm:grid-cols-3 gap-3">
              {Object.entries(unitsJson.units)
                .filter(([_, unit]) => {
                  // Type guard: Check if unit has traits
                  if (!unit || typeof unit !== 'object' || !('traits' in unit) || !unit.traits) return false;
                  
                  // Safely extract origins array
                  const origins = unit.traits.origin ? 
                    (Array.isArray(unit.traits.origin) ? unit.traits.origin : [unit.traits.origin]) 
                    : [];
                  
                  // Safely extract classes array
                  const classes = unit.traits.class ?
                    (Array.isArray(unit.traits.class) ? unit.traits.class : [unit.traits.class])
                    : [];
                  
                  return [...origins, ...classes].filter(Boolean).includes(entityId);
                })
                .map(([unitId, unit]) => ({
                  id: unitId,
                  name: unit.name,
                  icon: unit.icon,
                  cost: unit.cost
                }))
                // Sort by cost (descending) and then name
                .sort((a, b) => b.cost - a.cost || a.name.localeCompare(b.name))
                .map((unit, i) => (
                  <Link href={`/entity/units/${unit.id}`} key={i}>
                    <div className="flex items-center gap-2 bg-brown-light/40 p-3 rounded hover:bg-gold/15 transition-all shadow-sm">
                      <UnitIcon unit={unit} size="sm" />
                      <span className="text-base truncate">{unit.name}</span>
                    </div>
                  </Link>
                ))}
            </div>
          </div>
          
          {entityData.relatedComps && entityData.relatedComps.length > 0 && (
            <div className="bg-brown-dark/20 rounded-lg p-4 shadow-md border border-gold/5">
              <h2 className="text-lg font-semibold text-gold mb-3">Top Compositions</h2>
              <div className="grid grid-cols-2 gap-3">
                {entityData.relatedComps.slice(0, 6).map((comp, i) => (
                  <Link href={`/entity/comps/${comp.id}`} key={i}>
                    <div className="bg-brown-light/40 p-3 rounded hover:bg-gold/15 transition-all shadow-sm">
                      <div className="flex justify-center gap-1 mb-2">
                        {(comp.traits || []).slice(0, 3).map((trait, j) => (
                          <TraitIcon 
                            key={j} 
                            trait={trait} 
                            size="sm"
                          />
                        ))}
                      </div>
                      <div className="text-sm font-medium text-center truncate">{comp.name?.split('&')[0] || 'Comp'}</div>
                      <div className="text-xs text-center mt-2 flex justify-between px-2">
                        <span>Win: {Math.min(comp.winRate || 0, 100).toFixed(1)}%</span>
                        <span>Avg: {comp.avgPlacement?.toFixed(2)}</span>
                      </div>
                    </div>
                  </Link>
                ))}
              </div>
            </div>
          )}
        </div>
      </div>
    </>
  );
}
EOL

# Fix ItemDetail.tsx component
cat > src/components/entity/ItemDetail.tsx << 'EOL'
import React from 'react';
import Link from 'next/link';
import { ItemIcon, UnitIcon, StatsPanel, TraitIcon } from '@/components/ui';
import itemsJson from 'public/mapping/items.json';
import { ProcessedItem } from '@/types';
import { getCostColor, getEntityIcon, DEFAULT_ICONS } from '@/utils/paths';

interface ItemDetails {
  name: string;
  category: string;
  icon: string;
  description?: string;
  stats?: string[];
  recipe?: string[];
}

export default function ItemDetail({ 
  entityData,
  itemDetails: propItemDetails
}: { 
  entityData: ProcessedItem | null;
  itemDetails?: ItemDetails;
}) {
  if (!entityData) return null;
  
  // Get detailed item information from the JSON or use provided itemDetails
  const itemDetails = propItemDetails || 
    (itemsJson.items[entityData.id as keyof typeof itemsJson.items] as ItemDetails | undefined);
  
  // Prepare placement data for distribution chart if available
  const placementData = entityData.relatedComps ? 
    entityData.relatedComps.reduce((acc, comp) => {
      if (!comp.placementData) return acc;
      
      comp.placementData.forEach(pd => {
        const existing = acc.find(a => a.placement === pd.placement);
        if (existing) {
          existing.count += pd.count;
        } else {
          acc.push({ ...pd });
        }
      });
      return acc;
    }, [] as Array<{ placement: number; count: number }>) : 
    undefined;

  // IMPROVED: Check for empty unitsWithItem and combos arrays to prevent issues
  const hasUnitsWithItem = entityData.unitsWithItem && entityData.unitsWithItem.length > 0;
  const hasItemCombos = entityData.combos && entityData.combos.length > 0;
  const hasRelatedComps = entityData.relatedComps && entityData.relatedComps.length > 0;

  return (
    <>
      {/* Header Section with Recipe moved here */}
      <div className="flex items-center border-b border-gold/30 pb-4 mb-4">
        {/* Left side with item icon */}
        <div className="flex items-center gap-4">
          <ItemIcon item={entityData} size="lg" />
          <div>
            <h1 className="text-xl font-bold text-gold">{entityData.name}</h1>
            {(itemDetails?.category || entityData.category) && (
              <p className="text-sm text-cream/80">
                {(itemDetails?.category || entityData.category || '').replace(/-/g, ' ').replace(/\b\w/g, c => c.toUpperCase())}
              </p>
            )}
          </div>
        </div>
        
        {/* Right side with recipe - larger icons, no names */}
        {itemDetails?.recipe && itemDetails.recipe.length > 0 && (
          <div className="ml-auto flex items-center gap-4">
            {itemDetails.recipe.map((componentId, i) => {
              const componentItem = itemsJson.items[componentId as keyof typeof itemsJson.items];
              if (!componentItem) return null;
              
              return (
                <React.Fragment key={i}>
                  <Link href={`/entity/items/${componentId}`} className="group">
                    <div className="relative">
                      <div className="w-14 h-14">
                        <img 
                          src={getEntityIcon({id: componentId, icon: componentItem.icon}, 'item')} 
                          alt={componentItem.name} 
                          className="w-full h-full object-contain"
                        />
                      </div>
                      <div className="absolute -bottom-6 left-1/2 transform -translate-x-1/2 bg-brown-dark text-xs text-cream py-1 px-2 rounded opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap z-10">
                        {componentItem.name}
                      </div>
                    </div>
                  </Link>
                  {i < (itemDetails.recipe?.length || 0) - 1 && (
                    <span className="text-gold text-3xl font-light">+</span>
                  )}
                </React.Fragment>
              );
            })}
          </div>
        )}
      </div>
      
      <div className="grid md:grid-cols-2 gap-6">
        <div className="space-y-6">
          {/* Unified Item Details Section */}
          <div className="bg-brown-dark/20 rounded-lg p-4 shadow-md border border-gold/5">
            <h2 className="text-lg font-semibold text-gold mb-4">Item Details</h2>
            
            {/* Stats Section - Displayed with centered layout */}
            {itemDetails?.stats && itemDetails.stats.length > 0 && (
              <div className="mb-4 flex justify-center">
                <div className="flex flex-wrap justify-center gap-2">
                  {itemDetails.stats.map((stat, i) => (
                    <div key={i} className="bg-brown-light/40 px-3 py-2 rounded shadow-sm border border-gold/5">
                      <span className="text-gold-light font-medium">{stat}</span>
                    </div>
                  ))}
                </div>
              </div>
            )}
            
            {/* Description Section - Centered text */}
            {itemDetails?.description && (
              <div className="text-center">
                <p className="text-cream/90 bg-brown-light/30 p-4 rounded shadow-sm border border-gold/5 whitespace-pre-line">{itemDetails.description}</p>
              </div>
            )}
            
            {/* If no data available */}
            {!itemDetails?.description && !itemDetails?.stats?.length && (
              <p className="text-cream/60 text-center py-2">No detailed information available for this item.</p>
            )}
          </div>
          
          {/* Performance Stats */}
          <div className="bg-brown-dark/20 rounded-lg p-4 shadow-md border border-gold/5">
            <h2 className="text-lg font-semibold text-gold mb-3">Performance Stats</h2>
            <StatsPanel stats={{
              ...entityData.stats,
              placementData
            }} />
          </div>

          {/* Item Combos - MOVED HERE and showing only 3 */}
          {hasItemCombos && (
            <div className="bg-brown-dark/20 rounded-lg p-4 shadow-md border border-gold/5">
              <h2 className="text-lg font-semibold text-gold mb-3">Popular Combos</h2>
              <div className="space-y-3">
                {entityData.combos!.slice(0, 3).map((combo, i) => (
                  <div key={i} className="bg-brown-light/40 p-3 rounded hover:bg-gold/15 transition-all shadow-sm">
                    <div className="flex items-center gap-2 mb-2">
                      {combo.items.map((item, j) => (
                        <Link href={`/entity/items/${item.id}`} key={j}>
                          <div className="relative group">
                            <ItemIcon item={item} size="md" />
                            <div className="absolute -bottom-7 left-1/2 transform -translate-x-1/2 bg-brown-dark text-xs text-cream p-1 rounded opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap z-10">
                              {item.name}
                            </div>
                          </div>
                        </Link>
                      ))}
                      <div className="ml-auto flex items-center">
                        <span className="text-sm text-gold-light">
                          Win: {Math.min(combo.winRate || 0, 100).toFixed(1)}%
                        </span>
                        {combo.frequency !== undefined && (
                          <span className="text-sm text-cream/60 ml-2">
                            ({Math.round(combo.frequency * 100)}%)
                          </span>
                        )}
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
        
        <div className="space-y-6">
          {/* Best Units */}
          {hasUnitsWithItem && (
            <div className="bg-brown-dark/20 rounded-lg p-4 shadow-md border border-gold/5">
              <h2 className="text-lg font-semibold text-gold mb-3">Best Units</h2>
              <div className="grid grid-cols-3 gap-3">
                {entityData.unitsWithItem!.slice(0, 6).map((unit, i) => (
                  <Link href={`/entity/units/${unit.id}`} key={i}>
                    <div className="flex flex-col items-center gap-2 bg-brown-light/40 p-3 rounded hover:bg-gold/15 transition-all shadow-sm">
                      <UnitIcon unit={unit} size="md" />
                      <div className="text-center">
                        <div className="text-sm font-medium truncate max-w-28">{unit.name}</div>
                        <div className="flex flex-col text-xs">
                          <span className="text-gold-light">
                            Win: {Math.min(unit.winRate || 0, 100).toFixed(1)}%
                          </span>
                          <span className="text-cream/70">
                            Avg: {unit.avgPlacement?.toFixed(2) || '?'}
                          </span>
                        </div>
                      </div>
                    </div>
                  </Link>
                ))}
              </div>
            </div>
          )}
          
          {/* Related Compositions */}
          {hasRelatedComps && (
            <div className="bg-brown-dark/20 rounded-lg p-4 shadow-md border border-gold/5">
              <h2 className="text-lg font-semibold text-gold mb-3">Top Compositions</h2>
              <div className="grid grid-cols-2 gap-3">
                {entityData.relatedComps!.slice(0, 4).map((comp, i) => (
                  <Link href={`/entity/comps/${comp.id}`} key={i}>
                    <div className="bg-brown-light/40 p-3 rounded hover:bg-gold/15 transition-all shadow-sm">
                      <div className="flex justify-center gap-1 mb-2">
                        {(comp.traits || []).slice(0, 3).map((trait, j) => (
                          <TraitIcon 
                            key={j} 
                            trait={trait} 
                            size="sm"
                          />
                        ))}
                      </div>
                      <div className="text-sm font-medium text-center truncate mb-2">
                        {comp.name?.split('&')[0] || 'Comp'}
                      </div>
                      <div className="text-xs text-center flex justify-between px-2">
                        <span>Win: {Math.min(comp.winRate || 0, 100).toFixed(1)}%</span>
                        <span>Avg: {comp.avgPlacement?.toFixed(2)}</span>
                      </div>
                    </div>
                  </Link>
                ))}
              </div>
            </div>
          )}
          
          {/* FALLBACK: If no relationship data is available */}
          {!hasUnitsWithItem && !hasItemCombos && !hasRelatedComps && (
            <div className="bg-brown-dark/20 rounded-lg p-4 shadow-md border border-gold/5">
              <h2 className="text-lg font-semibold text-gold mb-3">Usage Info</h2>
              <p className="text-cream/70 text-center p-4">
                No detailed usage information available for this item yet. 
                Check back later for data about which units work best with this item.
              </p>
            </div>
          )}
        </div>
      </div>
    </>
  );
}
EOL

# Update CompDetail.tsx
cat > src/components/entity/CompDetail.tsx << 'EOL'
import React, { useState } from 'react';
import Link from 'next/link';
import { StatsPanel, UnitIcon, TraitIcon, ItemIcon } from '@/components/ui';
import { parseCompTraits } from '@/utils/dataProcessing';
import traitsJson from 'public/mapping/traits.json';
import { Composition } from '@/types';
import { getEntityIcon } from '@/utils/paths';

interface CompDetailProps {
  entityData: Composition | null;
}

export default function CompDetail({ entityData }: CompDetailProps) {
  const [viewMode, setViewMode] = useState<'core' | 'extended'>('core');
  
  if (!entityData) return null;

  const mainTraits: Record<string, number> = {};
  if (entityData.name) {
    entityData.name.split(' & ').forEach(part => {
      const match = part.match(/^(\d+)\s+(.+)$/);
      if (match) {
        const [_, count, name] = match;
        mainTraits[name.trim()] = parseInt(count);
      }
    });
  }

  // Group units by cost for better organization
  const unitsByCost: Record<number, typeof entityData.units> = {};
  entityData.units?.forEach(unit => {
    if (!unitsByCost[unit.cost]) {
      unitsByCost[unit.cost] = [];
    }
    unitsByCost[unit.cost].push(unit);
  });

  // Calculate best carries based on cost and item effectiveness
  const getBestCarries = () => {
    if (!entityData.units) return [];
    
    // Sort units by carrying potential (usually higher cost units with items)
    return entityData.units
      .filter(unit => unit.cost >= 3)
      .sort((a, b) => {
        // Higher cost units are better carriers
        if (a.cost !== b.cost) return b.cost - a.cost;
        
        // Units with more items are better carriers
        const aItemCount = a.bestItems?.length || 0;
        const bItemCount = b.bestItems?.length || 0;
        if (aItemCount !== bItemCount) return bItemCount - aItemCount;
        
        return 0;
      })
      .slice(0, 3);
  };

  const bestCarries = getBestCarries();
  
  // Get core units - FIXED: exactly 6 units
  const getCoreUnits = () => {
    if (!entityData.units) return [];
    
    // Sort units by cost (descending) and then by count/importance
    return entityData.units
      .sort((a, b) => {
        // Higher cost units first
        if (a.cost !== b.cost) return b.cost - a.cost;
        // Then by count/frequency
        return (b.count || 0) - (a.count || 0);
      })
      .slice(0, 6); // Limit to exactly 6 core units
  };
  
  // Get extended units - FIXED: exactly 12 units 
  const getExtendedUnits = () => {
    if (!entityData.units) return [];
    
    // Sort units with most important first
    return entityData.units
      .sort((a, b) => {
        // Higher cost units first
        if (a.cost !== b.cost) return b.cost - a.cost;
        // Then by count/frequency
        return (b.count || 0) - (a.count || 0);
      })
      .slice(0, 12); // Limit to exactly 12 units for extended view
  };
  
  // Choose units to display based on view mode - will always be 6 or 12
  const unitsToDisplay = viewMode === 'core' ? getCoreUnits() : getExtendedUnits();

  // Calculate team power and playstyle
  const getTeamPlaystyle = () => {
    if (!entityData.units) return "Standard";
    
    const highCostUnits = entityData.units.filter(u => u.cost >= 4).length;
    const lowCostUnits = entityData.units.filter(u => u.cost <= 2).length;
    
    if (highCostUnits >= 3) return "Fast 9";
    if (lowCostUnits >= 4) return "Reroll";
    return "Standard";
  };

  return (
    <>
      {/* UPDATED: Larger trait icons with container fill */}
      <div className="flex items-center gap-4 border-b border-gold/30 pb-4 mb-6">
        <div className="flex items-center">
          {(() => {
            const displayTraits = parseCompTraits(entityData.name, entityData.traits || []);
            return displayTraits.map((trait: any, i: number) => (
              <div key={i} className="w-16 h-16 flex items-center justify-center first:ml-0">
                <img 
                  src={getEntityIcon(trait, 'trait')} 
                  alt={trait.name} 
                  className="w-full h-full object-contain"
                  onError={(e) => {
                    (e.target as HTMLImageElement).src = '/assets/app/default.png';
                  }}
                />
              </div>
            ));
          })()}
        </div>
        <div>
          <h1 className="text-xl font-bold text-gold">{entityData.name}</h1>
          <p className="text-sm text-cream/80">
            {getTeamPlaystyle()}
          </p>
        </div>
      </div>
      
      <div className="grid md:grid-cols-2 gap-6">
        <div className="space-y-6">
          {entityData.traits && entityData.traits.length > 0 && (
            <div className="bg-brown-dark/20 rounded-lg p-4 shadow-md border border-gold/5">
              <h2 className="text-lg font-semibold text-gold mb-3">Active Traits</h2>
              <div className="space-y-3">
                {(() => {
                  // Filter traits to only include those mentioned in the comp name
                  // If no main traits were found in the name, show all traits
                  const traitsToShow = Object.keys(mainTraits).length > 0 
                    ? entityData.traits.filter(trait => mainTraits.hasOwnProperty(trait.name))
                    : entityData.traits;
                  
                  return traitsToShow
                    .sort((a, b) => (b.numUnits || 0) - (a.numUnits || 0))
                    .map((trait, i) => {
                      const isMainTrait = mainTraits.hasOwnProperty(trait.name);
                      const mainTraitCount = mainTraits[trait.name];
                      
                      // Get trait tier description
                      const traitData = traitsJson.origins[trait.id as keyof typeof traitsJson.origins] || 
                                        traitsJson.classes[trait.id as keyof typeof traitsJson.classes];
                      
                      // Find the active tier
                      const tierLevel = trait.tier || 0;
                      const activeTierInfo = traitData?.tiers?.[tierLevel - 1];
                      
                      return (
                        <Link href={`/entity/traits/${trait.id}`} key={i}>
                          <div className="bg-brown-light/40 p-3 rounded hover:bg-gold/15 transition-all shadow-sm">
                            <div className="flex items-center gap-3">
                              <TraitIcon 
                                trait={{
                                  ...trait,
                                  // Ensure proper icon resolution
                                  icon: traitData?.icon || trait.icon
                                }} 
                                size="sm" 
                              />
                              <div>
                                <div className="font-medium">
                                  {trait.name} ({isMainTrait ? mainTraitCount : trait.numUnits})
                                </div>
                                {/* ADDED: Display active tier buff */}
                                {activeTierInfo && (
                                  <div className="text-xs text-gold-light mt-1">{activeTierInfo.value}</div>
                                )}
                              </div>
                            </div>
                          </div>
                        </Link>
                      );
                    });
                })()}
              </div>
            </div>
          )}
          
          <div className="bg-brown-dark/20 rounded-lg p-4 shadow-md border border-gold/5">
            <h2 className="text-lg font-semibold text-gold mb-3">Performance Stats</h2>
            <StatsPanel stats={{
              ...entityData,
              placementData: entityData.placementData
            }} />
          </div>
        </div>
        <div className="space-y-6">
          <div className="bg-brown-dark/20 rounded-lg p-4 shadow-md border border-gold/5">
            <h2 className="text-lg font-semibold text-gold mb-3">Team Composition</h2>
            <div className="flex justify-between items-center mb-3">
              <div className="flex rounded overflow-hidden border border-gold/30">
                <button 
                  className={`px-3 py-1 text-xs font-medium ${viewMode === 'core' ? 'bg-gold text-brown' : 'bg-brown-light/30 text-cream'}`}
                  onClick={() => setViewMode('core')}
                >
                  Core
                </button>
                <button 
                  className={`px-3 py-1 text-xs font-medium ${viewMode === 'extended' ? 'bg-gold text-brown' : 'bg-brown-light/30 text-cream'}`}
                  onClick={() => setViewMode('extended')}
                >
                  Extended
                </button>
              </div>
            </div>
              
            {/* Team display grid - IMPROVED HORIZONTAL STYLE */}
            <div className="grid grid-cols-3 gap-2 mb-4">
              {unitsToDisplay.map((unit, i) => (
                <Link href={`/entity/units/${unit.id}`} key={i}>
                  <div className="flex flex-row items-center bg-brown-light/40 p-2 rounded hover:bg-gold/15 transition-all shadow-sm">
                    <UnitIcon unit={unit} size="sm" className="mr-2" />
                    <div className="flex-1 min-w-0">
                      <div className="text-xs truncate max-w-full">{unit.name}</div>
                      <div className="flex items-center">
                        <div className="text-xs text-cream/70 mr-1">{unit.cost} 🪙</div>
                        {unit.winRate && (
                          <div className="text-xs text-gold-light">{Math.min(unit.winRate, 100).toFixed(1)}%</div>
                        )}
                      </div>
                    </div>
                  </div>
                </Link>
              ))}
            </div>
            
            {/* Best Carries Section - IMPROVED WITH CLEARER ITEM DISPLAY */}
            {bestCarries.length > 0 && (
              <div className="mt-4 pt-4 border-t border-gold/20">
                <h3 className="font-semibold text-gold mb-3">Best Carries</h3>
                <div className="flex justify-between gap-2">
                  {bestCarries.map((unit, i) => (
                    <Link href={`/entity/units/${unit.id}`} key={i} className="flex-1">
                      <div className="flex flex-col items-center bg-brown-light/40 p-2 rounded-lg hover:bg-gold/15 transition-all shadow-sm">
                        <UnitIcon unit={unit} size="md" className="mb-1" />
                        <div className="text-xs font-medium text-center mb-1 truncate w-full">{unit.name}</div>
                        
                        {(unit.bestItems || []).length > 0 ? (
                          <div className="flex justify-center gap-1 mt-1">
                            {(unit.bestItems || []).slice(0, 3).map((item, j) => (
                              <Link href={`/entity/items/${item.id}`} key={j} className="block">
                                <div className="relative group">
                                  <ItemIcon item={item} size="sm" />
                                  <div className="absolute -bottom-6 left-1/2 transform -translate-x-1/2 bg-brown-dark text-xs text-cream p-1 rounded opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap z-10">
                                    {item.name}
                                  </div>
                                </div>
                              </Link>
                            ))}
                          </div>
                        ) : (
                          <div className="text-xs text-cream/50 text-center mt-1">No preferred items</div>
                        )}
                      </div>
                    </Link>
                  ))}
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </>
  );
}
EOL

# Create Enhanced CompCard component
cat > src/components/entity/CompCard.tsx << 'EOL'
import React from 'react';
import Link from 'next/link';
import { parseCompTraits } from '@/utils/dataProcessing';
import { Composition, ProcessedDisplayTrait } from '@/types';
import { getEntityIcon } from '@/utils/paths';

interface CompCardProps {
  comp: Composition | null;
  highlight?: boolean;
}

export default function CompCard({ comp, highlight = false }: CompCardProps) {
  if (!comp) return null;
  
  const displayTraits = parseCompTraits(comp.name, comp.traits || []);
  
  // Calculate if this is a high-performing comp
  const isTopTier = (comp.winRate || 0) > 52 && (comp.avgPlacement || 8) < 4;
  
  return (
    <Link href={`/entity/comps/${comp.id}`}>
      <div 
        className={`p-3 rounded-lg transition-all shadow-md ${
          highlight 
            ? 'bg-gold/15 hover:bg-gold/25 border border-gold/20' 
            : isTopTier
              ? 'bg-brown-light/40 hover:bg-gold/15 border border-gold/10'
              : 'bg-brown-dark/30 hover:bg-gold/15 border border-transparent'
        } relative`}
      >
        {/* Top tier indicator - subtle gold corner accent */}
        {isTopTier && !highlight && (
          <div className="absolute top-0 right-0 w-5 h-5 overflow-hidden">
            <div className="absolute -right-0 -top-0 transform rotate-45 bg-gold shadow-sm w-7 h-1"></div>
          </div>
        )}
        
        <div className="flex justify-center gap-2 mb-3">
          {displayTraits.map((trait: ProcessedDisplayTrait, i: number) => (
            <div key={i} className="flex-shrink-0 w-7 h-7 bg-brown-light/30 rounded-full p-1">
              <img
                src={getEntityIcon(trait, 'trait')}
                alt={trait.name}
                className="w-full h-full object-contain"
                onError={(e) => {
                  (e.target as HTMLImageElement).src = '/assets/app/default.png';
                }}
              />
            </div>
          ))}
        </div>
        
        {/* Improved truncation for long comp names with ellipsis */}
        <div className="text-sm font-medium text-center truncate mb-3 px-1">
          {comp.name?.split('&')[0]?.trim() || 'Comp'}
        </div>
        
        <div className="flex justify-between items-center bg-brown-dark/40 rounded-md px-3 py-2 text-xs">
          <div className="flex flex-col items-center">
            <span className={`font-medium ${(comp.winRate || 0) >= 52 ? 'text-gold-light' : 'text-cream'}`}>
              {Math.min(comp.winRate || 0, 100).toFixed(1)}%
            </span>
            <span className="text-cream/70 text-xs">Win</span>
          </div>
          <div className="h-8 w-px bg-cream/10"></div>
          <div className="flex flex-col items-center">
            <span className={`font-medium ${(comp.avgPlacement || 8) <= 4 ? 'text-gold-light' : 'text-cream'}`}>
              {comp.avgPlacement?.toFixed(2) || '-'}
            </span>
            <span className="text-cream/70 text-xs">Avg Place</span>
          </div>
        </div>
      </div>
    </Link>
  );
}
EOL

cat > src/components/entity/MatchDetail.tsx << 'EOL'
import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { Clock, Users, Trophy, Target, Calendar, Award, Star, Zap } from 'lucide-react';

interface MatchDetailProps {
  match: {
    matchId: string;
    queueId: number;
    gameType: string;
    gameCreation: number;
    gameDuration: number;
    gameVersion: string;
    mapId: number;
    placement: number;
    level: number;
    augments: string[];
    traits: Array<{
      name: string;
      numUnits: number;
      style: number;
      tierCurrent: number;
      tierTotal: number;
    }>;
    units: Array<{
      characterId: string;
      itemNames: string[];
      rarity: number;
      tier: number;
    }>;
    companions?: {
      contentId: string;
      skinId: number;
      species: string;
    };
  };
}

export default function MatchDetail({ match }: MatchDetailProps) {
  const [activeTab, setActiveTab] = useState<'overview' | 'composition' | 'timeline'>('overview');
  
  const gameDate = new Date(match.gameCreation);
  const gameDuration = Math.floor(match.gameDuration / 60);
  const gameType = match.gameType === 'ranked' ? 'Ranked' : 'Normal';
  
  const getPlacementStyling = (placement: number) => {
    if (placement === 1) return {
      bg: 'bg-gradient-to-r from-solar-flare/30 to-burning-warning/30',
      border: 'border-solar-flare',
      text: 'text-solar-flare',
      icon: <Trophy className="h-8 w-8" />
    };
    if (placement <= 4) return {
      bg: 'bg-gradient-to-r from-verdant-success/20 to-verdant-success/10',
      border: 'border-verdant-success',
      text: 'text-verdant-success',
      icon: <Award className="h-8 w-8" />
    };
    return {
      bg: 'bg-gradient-to-r from-burning-warning/20 to-burning-warning/10',
      border: 'border-burning-warning',
      text: 'text-burning-warning',
      icon: <Target className="h-8 w-8" />
    };
  };
  
  const placementStyle = getPlacementStyling(match.placement);
  
  const getRarityColor = (rarity: number) => {
    const colors = ['#6b7280', '#10b981', '#3b82f6', '#8b5cf6', '#f59e0b', '#ef4444'];
    return colors[rarity] || colors[0];
  };

  return (
    <div className="space-y-8">
      <motion.div 
        className={`${placementStyle.bg} backdrop-blur-md border ${placementStyle.border} rounded-xl p-8`}
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6 }}
      >
        <div className="flex flex-col lg:flex-row items-center lg:items-start gap-8">
          <motion.div 
            className="text-center"
            whileHover={{ scale: 1.05 }}
            transition={{ duration: 0.2 }}
          >
            <div className={`text-6xl font-bold ${placementStyle.text} mb-2`}>
              #{match.placement}
            </div>
            <div className="flex justify-center mb-2">
              {placementStyle.icon}
            </div>
            <div className="text-sm text-corona-light/70">Placement</div>
          </motion.div>
          
          <div className="flex-1 text-center lg:text-left">
            <h1 className="text-3xl font-display text-stellar-white mb-4">
              {gameType} Match
            </h1>
            
            <div className="flex flex-wrap gap-4 justify-center lg:justify-start mb-4">
              <div className="flex items-center gap-2 bg-void-core/40 backdrop-blur-sm px-4 py-2 rounded-lg border border-solar-flare/20">
                <Calendar className="h-4 w-4 text-corona-light/70" />
                <span className="text-corona-light text-sm">
                  {gameDate.toLocaleDateString()} at {gameDate.toLocaleTimeString()}
                </span>
              </div>
              <div className="flex items-center gap-2 bg-void-core/40 backdrop-blur-sm px-4 py-2 rounded-lg border border-solar-flare/20">
                <Clock className="h-4 w-4 text-corona-light/70" />
                <span className="text-corona-light text-sm">{gameDuration} minutes</span>
              </div>
              <div className="flex items-center gap-2 bg-void-core/40 backdrop-blur-sm px-4 py-2 rounded-lg border border-solar-flare/20">
                <Users className="h-4 w-4 text-corona-light/70" />
                <span className="text-corona-light text-sm">Level {match.level}</span>
              </div>
            </div>
            
            <div className="text-sm text-corona-light/60">
              Game Version: {match.gameVersion} • TFT Set: {match.mapId}
            </div>
          </div>
        </div>
      </motion.div>
      
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        {[
          { 
            icon: Trophy, 
            label: "Placement", 
            value: `#${match.placement}`,
            color: placementStyle.text
          },
          { 
            icon: Target, 
            label: "Level Reached", 
            value: match.level.toString(),
            color: "text-corona-light"
          },
          { 
            icon: Zap, 
            label: "Active Traits", 
            value: match.traits.filter(t => t.style >= 1).length.toString(),
            color: "text-solar-flare"
          },
          { 
            icon: Star, 
            label: "Champion Units", 
            value: match.units.length.toString(),
            color: "text-corona-light"
          }
        ].map((stat, i) => (
          <motion.div 
            key={i}
            className="backdrop-filter backdrop-blur-md bg-eclipse-shadow/30 border border-solar-flare/20 rounded-lg p-4 text-center"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: i * 0.1, duration: 0.5 }}
            whileHover={{ scale: 1.02, boxShadow: "0 10px 25px -5px rgba(245, 158, 11, 0.15)" }}
          >
            <stat.icon className="h-6 w-6 text-solar-flare mx-auto mb-2" />
            <div className="text-sm text-corona-light/70 mb-1">{stat.label}</div>
            <div className={`text-xl font-bold ${stat.color}`}>{stat.value}</div>
          </motion.div>
        ))}
      </div>
      
      <div className="backdrop-filter backdrop-blur-md bg-eclipse-shadow/30 border border-solar-flare/30 rounded-xl overflow-hidden">
        <div className="border-b border-solar-flare/30">
          <div className="flex">
            {[
              { id: 'overview', label: 'Overview', icon: Trophy },
              { id: 'composition', label: 'Team Composition', icon: Users },
              { id: 'timeline', label: 'Match Timeline', icon: Clock }
            ].map((tab) => (
              <button
                key={tab.id}
                className={`flex items-center gap-2 px-6 py-4 transition-all text-sm font-medium ${
                  activeTab === tab.id
                    ? 'text-solar-flare border-b-2 border-solar-flare bg-solar-flare/10'
                    : 'text-corona-light hover:text-solar-flare/70 hover:bg-void-core/30'
                }`}
                onClick={() => setActiveTab(tab.id as any)}
              >
                <tab.icon className="h-4 w-4" />
                <span>{tab.label}</span>
              </button>
            ))}
          </div>
        </div>
        
        <div className="p-8">
          {activeTab === 'overview' && (
            <motion.div 
              className="space-y-8"
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.3 }}
            >
              <div>
                <h3 className="text-xl font-display text-stellar-white mb-6 flex items-center gap-2">
                  <Zap className="h-5 w-5 text-solar-flare" />
                  Hextech Augments
                </h3>
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  {match.augments.map((augment, index) => (
                    <motion.div 
                      key={index}
                      className="backdrop-filter backdrop-blur-sm bg-void-core/40 border border-solar-flare/20 rounded-lg p-4 text-center hover:border-solar-flare/40 transition-all"
                      whileHover={{ scale: 1.02 }}
                    >
                      <div className="text-sm font-medium text-corona-light">
                        {augment.replace(/^TFT\d+_Augment_/, '').replace(/_/g, ' ')}
                      </div>
                    </motion.div>
                  ))}
                </div>
              </div>
              
              <div>
                <h3 className="text-xl font-display text-stellar-white mb-6 flex items-center gap-2">
                  <Star className="h-5 w-5 text-solar-flare" />
                  Active Traits
                </h3>
                <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                  {match.traits
                    .filter(trait => trait.style >= 1)
                    .sort((a, b) => b.style - a.style)
                    .map((trait, index) => (
                      <motion.div 
                        key={index}
                        className="backdrop-filter backdrop-blur-sm bg-void-core/40 border border-solar-flare/20 rounded-lg p-4 hover:border-solar-flare/40 transition-all"
                        whileHover={{ scale: 1.02 }}
                      >
                        <div className="flex items-center gap-3">
                          <div className="relative w-10 h-10 bg-solar-flare/10 rounded-lg flex items-center justify-center">
                            <div className="absolute -top-1 -right-1 bg-solar-flare text-void-core text-xs rounded-full w-5 h-5 flex items-center justify-center font-bold">
                              {trait.numUnits}
                            </div>
                          </div>
                          <div>
                            <div className="text-sm font-medium text-corona-light">{trait.name}</div>
                            <div className="text-xs text-solar-flare">
                              {['Bronze', 'Silver', 'Gold', 'Diamond'][trait.style - 1] || 'Active'}
                            </div>
                          </div>
                        </div>
                      </motion.div>
                    ))
                  }
                </div>
              </div>
            </motion.div>
          )}
          
          {activeTab === 'composition' && (
            <motion.div 
              className="space-y-8"
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.3 }}
            >
              <div>
                <h3 className="text-xl font-display text-stellar-white mb-6 flex items-center gap-2">
                  <Users className="h-5 w-5 text-solar-flare" />
                  Team Composition
                </h3>
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                  {match.units
                    .sort((a, b) => (b.tier - a.tier) || (b.rarity - a.rarity))
                    .map((unit, index) => (
                      <motion.div 
                        key={index}
                        className="backdrop-filter backdrop-blur-sm bg-void-core/40 border border-solar-flare/20 rounded-lg p-4 hover:border-solar-flare/40 transition-all"
                        whileHover={{ scale: 1.02 }}
                      >
                        <div className="flex items-center gap-4 mb-3">
                          <div 
                            className="w-14 h-14 rounded-lg border-2 overflow-hidden bg-void-core/60 flex items-center justify-center relative"
                            style={{ borderColor: getRarityColor(unit.rarity) }}
                          >
                            <div className="text-xs text-corona-light">
                              {unit.characterId.slice(0, 3)}
                            </div>
                            {unit.tier > 1 && (
                              <div className="absolute bottom-0 right-0 bg-solar-flare text-void-core rounded-full w-5 h-5 flex items-center justify-center text-xs font-bold">
                                {unit.tier}★
                              </div>
                            )}
                          </div>
                          <div>
                            <div className="font-medium text-corona-light">{unit.characterId}</div>
                            <div className="text-sm text-corona-light/70">
                              {unit.tier}★ • {['Common', 'Uncommon', 'Rare', 'Epic', 'Legendary'][unit.rarity] || 'Unknown'}
                            </div>
                          </div>
                        </div>
                        
                        {unit.itemNames && unit.itemNames.length > 0 && (
                          <div>
                            <div className="text-sm text-corona-light/70 mb-2">Items:</div>
                            <div className="flex gap-2">
                              {unit.itemNames.map((item, itemIndex) => (
                                <div 
                                  key={itemIndex} 
                                  className="w-8 h-8 bg-void-core/60 rounded border border-solar-flare/20 flex items-center justify-center"
                                >
                                  <div className="text-xs text-corona-light/70">
                                    {item.slice(0, 2)}
                                  </div>
                                </div>
                              ))}
                            </div>
                          </div>
                        )}
                      </motion.div>
                    ))
                  }
                </div>
              </div>
            </motion.div>
          )}
          
          {activeTab === 'timeline' && (
            <motion.div 
              className="text-center py-16"
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.3 }}
            >
              <Clock className="h-16 w-16 mx-auto text-solar-flare/50 mb-4" />
              <h3 className="text-xl font-display text-stellar-white mb-2">
                Match Timeline
              </h3>
              <p className="text-corona-light/70 max-w-md mx-auto">
                Round-by-round progression and key events will be available soon.
              </p>
            </motion.div>
          )}
        </div>
      </div>
    </div>
  );
}
EOL

# Update index.ts to export all components including CompCard
cat > src/components/entity/index.ts << 'EOL'
export { default as UnitDetail } from './UnitDetail';
export { default as TraitDetail } from './TraitDetail';
export { default as ItemDetail } from './ItemDetail';
export { default as CompDetail } from './CompDetail';
export { default as CompCard } from './CompCard';
export { default as PlayerDetail } from './PlayerDetail';
export { default as MatchDetail } from './MatchDetail';
EOL

# =====================
# BUILDER COMPONENTS SECTION
# =====================

# Update BuilderControls.tsx
cat > src/components/team-builder/BuilderControls.tsx << 'EOL'
import React from 'react';
import { Save, Trash2, MousePointer, Mouse, MousePointerClick } from 'lucide-react';
import { BoardCell } from '@/types';

export default function BuilderControls({ 
  board, 
  saveComposition, 
  clearBoard, 
  compositionName, 
  setCompositionName 
}: { 
  board: Record<string, BoardCell>, 
  saveComposition: () => void, 
  clearBoard: () => void, 
  compositionName: string, 
  setCompositionName: (name: string) => void 
}) {
  return (
    <div className="mt-1 mb-4 bg-brown/5 border border-gold/20 p-3 rounded-lg backdrop-blur-md">
      <div className="flex flex-col md:flex-row md:justify-between gap-2">
        {/* Instructions section - first column */}
        <div className="flex-1 bg-brown-light/10 p-2 rounded border border-gold/10">
          <div className="flex flex-col gap-1 text-center">
            <div className="text-sm font-medium text-gold-light mb-1">Builder Instructions:</div>
            <div className="flex items-center text-xs text-cream/80 gap-1">
              <Mouse size={14} className="text-gold" /> 
              <span>Drag and drop units and items</span>
            </div>
            <div className="flex items-center text-xs text-cream/80 gap-1">
              <MousePointerClick size={14} className="text-gold" /> 
              <span>Double click units on and off the board</span>
            </div>
            <div className="flex items-center text-xs text-cream/80 gap-1">
              <MousePointer size={14} className="text-gold" /> 
              <span>Right click units to change star level (2★, 3★, 4★)</span>
            </div>
          </div>
        </div>
        
        {/* Team Building - second column */}
        <div className="flex-1 bg-brown-light/10 p-2 rounded border border-gold/10">
          <div className="flex flex-col gap-1 text-center">
            <div className="text-sm font-medium text-gold-light mb-1">Team Building:</div>
            <div className="text-xs text-cream/80">Create and save your comps</div>
            <div className="text-xs text-cream/80">Explore and load the suggestions</div>
          </div>
        </div>
        
        {/* Controls - third column */}
        <div className="flex-1 bg-brown-light/10 p-2 rounded border border-gold/10">
          <div className="flex flex-col gap-2">
            <input
              type="text"
              placeholder="Comp name"
              value={compositionName}
              onChange={(e) => setCompositionName(e.target.value)}
              className="w-full py-1.5 px-3 bg-brown-light/40 border border-gold/30 rounded-md text-sm focus:outline-none focus:border-gold focus:ring-1 focus:ring-gold/50"
            />
            
            <div className="flex gap-2 w-full justify-between">
              <button 
                className="flex-1 bg-gold hover:bg-gold-light text-brown px-3 py-1.5 rounded-md flex items-center justify-center gap-2 text-sm"
                onClick={saveComposition}
                disabled={Object.keys(board).length === 0}
              >
                <Save size={16} />
                <span>Save</span>
              </button>
              
              <button 
                className="flex-1 bg-brown-light/40 hover:bg-brown-light/60 text-cream px-3 py-1.5 rounded-md flex items-center justify-center gap-2 text-sm border border-gold/30"
                onClick={clearBoard}
              >
                <Trash2 size={16} />
                <span>Clear</span>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
EOL

# Enhance Traits Panel
cat > src/components/team-builder/TraitsPanel.tsx << 'EOL'
import React from 'react';
import traitsJson from 'public/mapping/traits.json';
import { getEntityIcon, getTierIcon } from '@/utils/paths';
import { useTooltip, renderTraitTooltip } from '@/components/ui/Tooltip';

interface TraitDisplay {
  id: string;
  name: string;
  count: number;
  breakpoints: number[];
  icon: string;
  tierLevel: number;
  description?: string;
}

interface TraitsPanelProps {
  traitCounts: Record<string, number>;
  traitTiers: Record<string, number>;
}

export default function TraitsPanel({ traitCounts = {}, traitTiers = {} }: TraitsPanelProps) {
  const { show, hide } = useTooltip(); // Get the tooltip functions
  const traitsData = { ...traitsJson.origins, ...traitsJson.classes } as Record<string, any>;
  
  // Process traits for display
  const activeTraits: TraitDisplay[] = Object.entries(traitCounts)
    .filter(([traitId]) => traitsData[traitId])
    .map(([traitId, count]) => {
      const traitData = traitsData[traitId];
      if (!traitData) return null;
      
      // Get tier and breakpoints
      const tierLevel = traitTiers[traitId] || 0;
      const breakpoints = traitData.tiers 
        ? traitData.tiers.map((t: { units: number }) => t.units).sort((a: number, b: number) => a - b)
        : [];
      
      // Create trait entity for proper icon resolution
      const traitEntity = {
        id: traitId,
        name: traitData.name,
        icon: traitData.icon,
        tier: tierLevel,
        numUnits: Number(count)
      };
      
      return {
        id: traitId,
        name: traitData.name,
        count: Number(count),
        breakpoints,
        icon: getEntityIcon(traitEntity, 'trait'), // Use our icon resolver for consistent handling
        tierLevel,
        description: traitData.description,
      };
    })
    .filter(Boolean) as TraitDisplay[];
  
  // Sort traits by tier level, count, and name
  const sortedActiveTraits = [...activeTraits].sort((a, b) => {
    if (a.tierLevel !== b.tierLevel) return b.tierLevel - a.tierLevel;
    if (a.count !== b.count) return b.count - a.count;
    return a.name.localeCompare(b.name);
  });
  
  // Group traits by activation status
  const activatedTraits = sortedActiveTraits.filter(t => t.tierLevel > 0);
  const inactiveTraits = sortedActiveTraits.filter(t => t.tierLevel === 0);
  
  return (
    <div className="h-full panel-card rounded-none border-0 border-r border-gold/20">
      <h3 className="panel-title border-b border-gold/30">Traits</h3>
      
      <div className="h-[calc(100vh-280px)] overflow-y-auto">
        {activatedTraits.length > 0 && (
          <div>
            {activatedTraits.map((trait) => (
              <div 
                key={trait.id}
                className="flex items-center px-1.5 py-1.5 border-b border-gold/10 group hover:bg-brown-light/30"
                onMouseEnter={(e) => {
                  // Create a trait object with the format expected by renderTraitTooltip
                  const traitForTooltip = {
                    id: trait.id,
                    name: trait.name,
                    icon: trait.icon,
                    tier: trait.tierLevel,
                    numUnits: trait.count,
                    tierIcon: getTierIcon(trait.id, trait.count) // Fix: pass both required arguments
                  };
                  show(renderTraitTooltip(traitForTooltip), e);
                }}
                onMouseLeave={hide}
              >
                <div className="flex-shrink-0 w-8 h-8 flex items-center justify-center">
                  <img 
                    src={trait.icon} 
                    alt={trait.name}
                    className="w-8 h-8 object-contain"
                    onError={(e) => {
                      (e.target as HTMLImageElement).src = '/assets/app/default.png';
                    }}
                  />
                </div>
                
                <div className="flex-shrink-0 w-6 h-6 flex items-center justify-center bg-brown-light/60 border border-gold/40 rounded-md ml-0.5 mr-1.5">
                  <span className="text-xs font-medium text-cream">{trait.count}</span>
                </div>
                
                <div className="flex-grow">
                  <div className="text-sm font-medium">{trait.name}</div>
                  <div className="flex items-center text-xs space-x-1.5 mt-0.5 text-cream/50">
                    {trait.breakpoints.map((bp, i) => (
                      <React.Fragment key={i}>
                        <span 
                          className={`${trait.count >= bp ? 'text-cream' : 'text-cream/50'}`}
                        >
                          {bp}
                        </span>
                        {i < trait.breakpoints.length - 1 && (
                          <span className="text-cream/40 mx-0.5">›</span>
                        )}
                      </React.Fragment>
                    ))}
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
        
        {inactiveTraits.length > 0 && (
          <div>
            {inactiveTraits.map((trait) => (
              <div 
                key={trait.id}
                className="flex items-center px-1.5 py-1.5 border-b border-gold/10 opacity-70 hover:opacity-100 group hover:bg-brown-light/30"
                onMouseEnter={(e) => {
                  const traitForTooltip = {
                    id: trait.id,
                    name: trait.name,
                    icon: `/assets/traits/${traitsData[trait.id]?.icon}`,
                    tier: trait.tierLevel,
                    numUnits: trait.count,
                    tierIcon: getTierIcon(trait.id, trait.count) // Fix: pass both required arguments
                  };
                  show(renderTraitTooltip(traitForTooltip), e);
                }}
                onMouseLeave={hide}
              >
                <div className="flex-shrink-0 w-7 h-7 flex items-center justify-center grayscale">
                  <img 
                    src={`/assets/traits/${traitsData[trait.id]?.icon}`} 
                    alt={trait.name}
                    className="w-7 h-7 object-contain"
                    onError={(e) => {
                      (e.target as HTMLImageElement).src = '/assets/app/default.png';
                    }}
                  />
                </div>
                
                <div className="flex-shrink-0 w-6 h-6 flex items-center justify-center bg-brown-light/60 border border-gold/20 rounded-md mx-1">
                  <span className="text-xs text-cream">{trait.count}</span>
                </div>
                
                <div className="flex-grow">
                  <div className="text-xs font-medium">{trait.name}</div>
                  <div className="flex items-center text-xs space-x-2 mt-0.5">
                    {trait.breakpoints.map((bp, i) => (
                      <React.Fragment key={i}>
                        <span className="text-cream/50">{bp}</span>
                        {i < trait.breakpoints.length - 1 && (
                          <span className="text-cream/40 mx-0.5">›</span>
                        )}
                      </React.Fragment>
                    ))}
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
        
        {activeTraits.length === 0 && (
          <div className="text-center py-4 text-cream/60 text-sm">
            Place units on the board to see active traits
          </div>
        )}
      </div>
    </div>
  );
}
EOL

# Update BoardComponents.tsx with improved star system
cat > src/components/team-builder/BoardComponents.tsx << 'EOL'
import React, { useRef, useEffect, useState } from 'react';
import { useDrop } from 'react-dnd';
import { UnitInHex } from './DraggableComponents';
import { BoardCell, ProcessedUnit } from '@/types';
import { Star } from 'lucide-react';

// Define item types for drag and drop
interface DragItem {
  type: string;
  id: string;
}

interface UnitDragItem extends DragItem {
  type: 'UNIT';
  unit: any;
}

interface BoardUnitDragItem extends DragItem {
  type: 'UNIT_ON_BOARD';
  unit: any;
  items: any[];
  sourceHexId: string;
}

interface ItemDragItem extends DragItem {
  type: 'ITEM';
  item: any;
}

type TFTDragItem = UnitDragItem | BoardUnitDragItem | ItemDragItem;

// Star Menu Component with enhanced positioning
function StarMenu({ 
  starLevel, 
  handleStarSelection,
  position
}: { 
  starLevel: number, 
  handleStarSelection: (level: number) => void,
  position: { top: boolean, left: boolean }
}) {
  const menuRef = useRef<HTMLDivElement>(null);
  
  // Get star color based on level
  const getStarColor = (level: number) => {
    switch(level) {
      case 1: return '#CD7F32'; // Bronze
      case 2: return '#C0C0C0'; // Silver
      case 3: return '#FFD700'; // Gold
      case 4: return '#4CAF50'; // Green
      default: return '#FFFFFF'; // Default white
    }
  };
  
  return (
    <div 
      ref={menuRef} 
      className={`absolute ${position.top ? 'bottom-full mb-1' : 'top-1'} 
                 ${position.left ? 'left-1' : 'right-1'} 
                 z-50 bg-brown-light/95 border border-gold/40 rounded-md shadow-lg p-1 min-w-[120px]`}
      style={{maxHeight: '160px'}}
    >
      <div className="text-xs text-cream/80 text-center mb-1">Star Level</div>
      <div className="flex flex-col gap-1">
        <button 
          onClick={() => handleStarSelection(0)}
          className="flex items-center justify-between hover:bg-brown-light/60 px-2 py-1 rounded"
        >
          <span className="text-xs text-cream">None</span>
        </button>
        {[1, 2, 3, 4].map(level => (
          <button 
            key={level}
            onClick={() => handleStarSelection(level)}
            className={`flex items-center justify-between hover:bg-brown-light/60 px-2 py-1 rounded ${
              starLevel === level ? 'bg-brown-light/40' : ''
            }`}
          >
            <div className="flex items-center gap-1">
              {Array.from({ length: level }, (_, i) => (
                <Star 
                  key={i}
                  size={10} 
                  fill={getStarColor(level)}
                  color={getStarColor(level)}
                />
              ))}
            </div>
            <span 
              className="text-xs" 
              style={{ color: getStarColor(level) }}
            >
              {level}★
            </span>
          </button>
        ))}
      </div>
    </div>
  );
}

// Helper function to ensure a unit meets ProcessedUnit requirements
const ensureValidUnit = (unit: any): ProcessedUnit => {
  return {
    ...unit,
    // Ensure required properties have valid values
    id: unit.id || `unit-${Date.now()}`, // Provide a fallback ID if missing
    cost: typeof unit.cost === 'number' ? unit.cost : 1, // Ensure cost is a number
    starLevel: typeof unit.starLevel === 'number' ? unit.starLevel : 0, // Ensure starLevel is a number
    // Add any other required properties with defaults here
  } as ProcessedUnit;
};

export function BoardHex({ 
  hexId, 
  cell, 
  board, 
  setBoard, 
  onRemove 
}: { 
  hexId: string, 
  cell: BoardCell, 
  board: Record<string, BoardCell>, 
  setBoard: React.Dispatch<React.SetStateAction<Record<string, BoardCell>>>, 
  onRemove: (hexId: string) => void 
}) {
  const ref = useRef<HTMLDivElement>(null);
  const [starLevel, setStarLevel] = useState<number>(0); // Default to 0 stars (no stars)
  const [showStarMenu, setShowStarMenu] = useState<boolean>(false);
  const [menuPosition, setMenuPosition] = useState<{ top: boolean, left: boolean }>({ top: false, left: false });
  
  const [{ isOver, canDrop }, dropRef] = useDrop<TFTDragItem, void, { isOver: boolean; canDrop: boolean }>({
    accept: ['UNIT', 'UNIT_ON_BOARD', 'ITEM'],
    canDrop: (item: TFTDragItem) => {
      if (item.type === 'ITEM') {
        return !!cell.unit;  // Convert to explicit boolean
      }
      return true;
    },
    drop: (item) => {
      if (item.type === 'UNIT' || item.type === 'UNIT_ON_BOARD') {
        setBoard(prev => {
          const newBoard = {...prev};
          
          // Check if this hex already has a unit
          if (prev[hexId]?.unit && item.type === 'UNIT') {
            // If unit being dragged from selector to an occupied hex, swap is not needed
            newBoard[hexId] = { 
              unit: ensureValidUnit({
                ...item.unit,
                starLevel: 0  // Initialize star level for new unit
              }),
              items: prev[hexId].items || [] // Preserve existing items
            };
          } 
          else if (item.type === 'UNIT_ON_BOARD' && item.sourceHexId) {
            if (item.sourceHexId === hexId) return prev;
            
            // Handle unit swapping when dragging from board to occupied hex
            if (prev[hexId]?.unit) {
              // Swap units between source and target
              newBoard[item.sourceHexId] = { 
                unit: prev[hexId].unit,
                items: prev[hexId].items || []
              };
            } else {
              // Delete the source hex if target is empty
              delete newBoard[item.sourceHexId];
            }
            
            // Place dragged unit on target hex
            newBoard[hexId] = { 
              unit: ensureValidUnit(item.unit),
              items: item.items || []
            };
          } else {
            // Simple placement of new unit
            newBoard[hexId] = { 
              unit: ensureValidUnit({
                ...item.unit,
                starLevel: 0  // Initialize star level for new unit
              })
            };
          }
          return newBoard;
        });
      } else if (item.type === 'ITEM') {
        setBoard(prev => {
          if (!prev[hexId]?.unit) return prev;
          const newBoard = {...prev};
          
          // Create a clean reference to the current cell and ensure items exist
          const currentCell = newBoard[hexId];
          const currentItems = currentCell.items || [];
          
          // Only add item if less than 3 items already
          if (currentItems.length < 3) {
            newBoard[hexId] = {
              ...currentCell,
              items: [...currentItems, item.item]
            };
          }
          
          return newBoard;
        });
      }
    },
    collect: (monitor) => ({
      isOver: !!monitor.isOver(),
      canDrop: !!monitor.canDrop(),
    }),
  });
  
  // Connect the drop ref to our div element
  useEffect(() => {
    if (ref.current) {
      dropRef(ref);
    }
  }, [dropRef]);
  
  const handleItemDoubleClick = (e: React.MouseEvent, index: number) => {
    e.stopPropagation();
    setBoard(prev => {
      const newBoard = {...prev};
      newBoard[hexId] = {
        ...newBoard[hexId],
        items: (newBoard[hexId].items || []).filter((_, i) => i !== index)
      };
      return newBoard;
    });
  };
  
  // Handle right click for star menu with position detection
  const handleRightClick = (e: React.MouseEvent) => {
    e.preventDefault();
    if (!cell.unit) return;
    
    // Get the position from hexId (format is "col-row")
    const [colStr, rowStr] = hexId.split('-');
    const col = parseInt(colStr);
    const row = parseInt(rowStr);
    
    // For bottom rows (2-3), position menu above
    // For empty/invalid rows, default to bottom row
    const isBottomRow = row >= 2 || isNaN(row);
    
    // For left columns (0-1), position menu to the right
    // For empty/invalid columns, default to right side
    const isLeftColumn = col <= 1 || isNaN(col);
    
    setMenuPosition({ top: isBottomRow, left: isLeftColumn });
    setShowStarMenu(!showStarMenu);
  };
  
  // Handle star selection
  const handleStarSelection = (level: number) => {
    if (!cell.unit) return;
    
    setStarLevel(level);
    
    // Update the board to include star level in unit data
    setBoard(prevBoard => {
      const newBoard = {...prevBoard};
      if (newBoard[hexId]?.unit) {
        newBoard[hexId] = {
          ...newBoard[hexId],
          unit: ensureValidUnit({
            ...newBoard[hexId].unit,
            starLevel: level
          })
        };
      }
      return newBoard;
    });
    
    setShowStarMenu(false);
  };

  // Close menu when clicking outside
  useEffect(() => {
    const handleClickOutside = (e: MouseEvent) => {
      if (showStarMenu && ref.current && !ref.current.contains(e.target as Node)) {
        setShowStarMenu(false);
      }
    };
    
    window.addEventListener('mousedown', handleClickOutside);
    return () => window.removeEventListener('mousedown', handleClickOutside);
  }, [showStarMenu]);
  
  // Set initial star level from board data
  useEffect(() => {
    if (cell.unit?.starLevel !== undefined) {
      setStarLevel(cell.unit.starLevel);
    } else {
      setStarLevel(0);
    }
  }, [cell.unit?.starLevel]);
  
  // Get star color based on level
  const getStarColor = (level: number) => {
    switch(level) {
      case 1: return '#CD7F32'; // Bronze
      case 2: return '#C0C0C0'; // Silver
      case 3: return '#FFD700'; // Gold
      case 4: return '#4CAF50'; // Green
      default: return '#FFFFFF'; // Default white
    }
  };
  
  // Render stars based on level
  const renderStars = () => {
    if (starLevel === 0) return null;
    
    return (
      <div className="absolute -top-2 left-1/2 transform -translate-x-1/2 star-container">
        <div className="flex gap-1">
          {Array.from({ length: starLevel }, (_, i) => (
            <Star 
              key={i}
              size={13} 
              fill={getStarColor(starLevel)}
              color={getStarColor(starLevel)}
              className="drop-shadow-md"
            />
          ))}
        </div>
      </div>
    );
  };
  
  return (
    <div className="hex-cell" ref={ref}>
      <div 
        className={`hex-container ${isOver ? (canDrop ? 'hex-drop-active' : 'hex-drop-invalid') : ''}`}
        onDoubleClick={() => onRemove(hexId)}
        onContextMenu={handleRightClick}
      >
        {cell.unit && <UnitInHex hexId={hexId} cell={cell} setBoard={setBoard} starLevel={starLevel} />}
      </div>
      
      {/* Star indicator - rendered outside of hex to allow overflow */}
      {cell.unit && renderStars()}
      
      {/* Star selection dropdown with improved positioning */}
      {showStarMenu && cell.unit && (
        <StarMenu 
          starLevel={starLevel}
          handleStarSelection={handleStarSelection}
          position={menuPosition}
        />
      )}
      
      {cell.unit && cell.items && cell.items.length > 0 && (
        <div className="item-container-absolute">
          {cell.items.map((item, idx) => (
            <div key={idx} className="item-wrapper" onDoubleClick={(e) => handleItemDoubleClick(e, idx)}>
              <img src={`/assets/items/${item.icon}`} alt={item.name} className="item-img" />
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

export function Board({ 
  board, 
  setBoard 
}: { 
  board: Record<string, BoardCell>, 
  setBoard: React.Dispatch<React.SetStateAction<Record<string, BoardCell>>> 
}) {
  const rows = 4;
  const cols = 7;
  
  // Double-click to remove unit
  const handleDoubleClick = (hexId: string) => {
    setBoard(prev => {
      const newBoard = {...prev};
      delete newBoard[hexId];
      return newBoard;
    });
  };
  
  return (
    <div className="p-4 honeycomb-container overflow-x-auto">
      {Array.from({ length: rows }, (_, row) => (
        <div key={row} className="hex-row">
          {Array.from({ length: cols }, (_, col) => {
            const hexId = `${col}-${row}`;
            const cell = board[hexId] || {};
            
            return (
              <BoardHex 
                key={hexId} 
                hexId={hexId} 
                cell={cell} 
                board={board} 
                setBoard={setBoard}
                onRemove={handleDoubleClick}
              />
            );
          })}
        </div>
      ))}
    </div>
  );
}
EOL

# Update DraggableComponents.tsx to match the changes
cat > src/components/team-builder/DraggableComponents.tsx << 'EOL'
import React, { useRef, useEffect } from 'react';
import { useDrag } from 'react-dnd';
import { getCostColor } from '@/utils/paths';
import { ProcessedUnit, ProcessedItem, BoardCell } from '@/types';
import { Star } from 'lucide-react';

interface DraggableUnitProps {
  unit: ProcessedUnit;
}

export function DraggableUnit({ unit }: DraggableUnitProps) {
  const ref = useRef<HTMLDivElement>(null);
  const [{ isDragging }, dragRef] = useDrag({
    type: 'UNIT',
    item: { type: 'UNIT', unit, id: unit.id },
    collect: (monitor) => ({ isDragging: !!monitor.isDragging() }),
  });
  
  // Connect the drag ref to our div element
  useEffect(() => {
    if (ref.current) {
      dragRef(ref);
    }
  }, [dragRef]);
  
  return (
    <div ref={ref} className="selector-unit-wrapper" style={{ opacity: isDragging ? 0.5 : 1 }}>
      <div className="w-12 h-12 rounded overflow-hidden border-2" 
           style={{ borderColor: getCostColor(unit.cost) }}>
        <img src={`/assets/units/${unit.icon}`} alt={unit.name} className="w-full h-full object-cover" />
      </div>
    </div>
  );
}

interface DraggableItemProps {
  item: ProcessedItem;
}

export function DraggableItem({ item }: DraggableItemProps) {
  const ref = useRef<HTMLDivElement>(null);
  const [{ isDragging }, dragRef] = useDrag({
    type: 'ITEM',
    item: { type: 'ITEM', item, id: item.id },
    collect: (monitor) => ({ isDragging: !!monitor.isDragging() }),
  });
  
  // Connect the drag ref to our div element
  useEffect(() => {
    if (ref.current) {
      dragRef(ref);
    }
  }, [dragRef]);
  
  return (
    <div 
      ref={ref} 
      className={`relative cursor-grab ${isDragging ? 'opacity-50' : 'hover:z-20'}`}
      title={item.name}
    >
      <img 
        src={`/assets/items/${item.icon}`} 
        alt={item.name}
        className={`w-10 h-10 object-contain transition-transform ${isDragging ? '' : 'hover:scale-110'}`}
      />
    </div>
  );
}

interface UnitInHexProps {
  hexId: string;
  cell: BoardCell;
  setBoard: React.Dispatch<React.SetStateAction<Record<string, BoardCell>>>;
  starLevel?: number;
}

export function UnitInHex({ hexId, cell, setBoard, starLevel = 1 }: UnitInHexProps) {
  const ref = useRef<HTMLDivElement>(null);
  const [{ isDragging }, dragRef] = useDrag({
    type: 'UNIT_ON_BOARD',
    item: { 
      type: 'UNIT_ON_BOARD',
      unit: cell.unit,
      items: cell.items || [],
      sourceHexId: hexId,
      id: cell.unit?.id || 'unknown'
    },
    collect: (monitor) => ({ isDragging: !!monitor.isDragging() }),
  });
  
  // Connect the drag ref to our div element
  useEffect(() => {
    if (ref.current) {
      dragRef(ref);
    }
  }, [dragRef]);
  
  // Star color based on level
  const getStarColor = (level: number) => {
    switch(level) {
      case 2: return '#C0C0C0'; // Silver
      case 3: return '#FFD700'; // Gold
      case 4: return '#B9F2FF'; // Diamond
      default: return '#FFFFFF'; // Default
    }
  };
  
  return (
    <div className="unit-wrapper">
      <div ref={ref} className="board-unit" style={{ opacity: isDragging ? 0.5 : 1 }}>
        <div className="board-unit-border" style={{ backgroundColor: getCostColor(cell.unit?.cost || 1) }}>
          <div className="board-unit-content">
            <img 
              src={`/assets/units/${cell.unit?.icon || 'default'}`} 
              alt={cell.unit?.name || 'Unit'} 
              className="board-unit-img" 
            />
          </div>
        </div>
      </div>
    </div>
  );
}
EOL

# Improve Selector Panel
cat > src/components/team-builder/SelectorPanel.tsx << 'EOL'
import React, { useState, useEffect, useMemo } from 'react';
import { Search, UserIcon, PackageIcon, Layers } from 'lucide-react';
import { DraggableUnit, DraggableItem } from './DraggableComponents';
import { ProcessedUnit, ProcessedItem } from '@/types';
import traitsJson from 'public/mapping/traits.json';
import itemsJson from 'public/mapping/items.json';
import { getUnitTraits, getTraitInfo } from '@/utils/paths';

interface SelectorPanelProps {
  filteredUnits: ProcessedUnit[];
  filteredItems: ProcessedItem[];
  search: string;
  setSearch: (value: string) => void;
  board: Record<string, any>;
  setBoard: React.Dispatch<React.SetStateAction<Record<string, any>>>;
}

// Interface for trait display
interface TraitDisplay {
  id: string;
  name: string;
  icon: string;
  units: ProcessedUnit[];
}

// Interface for item category
interface ItemCategory {
  id: string;
  name: string;
  items: ProcessedItem[];
}

export default function SelectorPanel({ 
  filteredUnits, 
  filteredItems,
  search, 
  setSearch,
  board,
  setBoard
}: SelectorPanelProps) {
  const [activeTab, setActiveTab] = useState('units');
  const [expandedTraits, setExpandedTraits] = useState<string[]>([]);
  
  // Process traits for display with proper trait data
  const traitGroups = useMemo(() => {
    const traitMap = new Map<string, TraitDisplay>();
    
    // First pass - create trait objects with proper data
    Object.entries({ ...traitsJson.origins, ...traitsJson.classes }).forEach(([id, trait]) => {
      traitMap.set(id, {
        id,
        name: trait.name,
        icon: trait.icon,
        units: []
      });
    });
    
    // Second pass - assign units to traits using the improved getUnitTraits function
    filteredUnits.forEach(unit => {
      // Get all unit traits using our helper function
      const unitTraitsList = getUnitTraits(unit);
      
      // Add unit to each of its traits
      unitTraitsList.forEach(traitEntry => {
        const trait = traitMap.get(traitEntry.id);
        if (trait) {
          trait.units.push(unit);
        }
      });
    });
    
    // Convert to array and sort
    return Array.from(traitMap.values())
      .filter(trait => trait.units.length > 0)
      .sort((a, b) => a.name.localeCompare(b.name));
  }, [filteredUnits]);
  
  // Process items by category, with crafted items first
  const itemCategories = useMemo(() => {
    const categoryMap = new Map<string, ItemCategory>();
    
    // Get all categories
    filteredItems.forEach(item => {
      const category = item.category || 'other';
      if (!categoryMap.has(category)) {
        categoryMap.set(category, {
          id: category,
          name: category.replace(/-/g, ' ').replace(/\b\w/g, c => c.toUpperCase()),
          items: []
        });
      }
      categoryMap.get(category)?.items.push(item);
    });
    
    // Convert to array and sort (crafted first, then alphabetically)
    const sortedCategories = Array.from(categoryMap.values());
    
    // Special ordering for categories
    return sortedCategories.sort((a, b) => {
      // Crafted items first
      if (a.id === 'completed') return -1;
      if (b.id === 'completed') return 1;
      
      // Basic items next
      if (a.id === 'basic') return -1;
      if (b.id === 'basic') return 1;
      
      // Alphabetical for the rest
      return a.name.localeCompare(b.name);
    });
  }, [filteredItems]);
  
  // Toggle trait expansion
  const toggleTrait = (traitId: string) => {
    setExpandedTraits(prev => 
      prev.includes(traitId) 
        ? prev.filter(id => id !== traitId)
        : [...prev, traitId]
    );
  };
  
  // Helper to get unit range
  const getUnitRange = (unit: ProcessedUnit): number => {
    // Try to get range from unit stats using type assertion for extended stats
    const unitStats = unit.stats as Record<string, any> | undefined;
    if (unitStats && 'range' in unitStats) {
      return Number(unitStats.range);
    }
    
    // Default range based on unit class
    if (unit.traits) {
      // Get unit traits using our helper
      const unitTraitsList = getUnitTraits(unit);
      const unitTraitIds = unitTraitsList.map(t => t.id);
      
      // Long range units (row 3)
      const longRangeClasses = ['sniper', 'cannoneer', 'mage', 'artillery'];
      if (unitTraitIds.some(trait => longRangeClasses.includes(trait))) {
        return 4;
      }
      
      // Melee units (row1)
      const meleeClasses = ['assassin', 'brawler', 'warrior', 'duelist'];
      if (unitTraitIds.some(trait => meleeClasses.includes(trait))) {
        return 1;
      }
    }
    
    // Default to middle range
    return 2;
  };
  
  // Handle double click on unit for auto-placement
  const handleUnitDoubleClick = (unit: ProcessedUnit) => {
    // Get the unit's range from its stats
    const range = getUnitRange(unit);
    
    // Determine which row to place the unit based on range (0-indexed)
    const targetRow = Math.min(range - 1, 3);
    
    // Find first available position in the target row
    let placed = false;
    for (let col = 0; col < 7; col++) {
      const hexId = `${col}-${targetRow}`;
      if (!board[hexId]) {
        setBoard(prev => ({
          ...prev,
          [hexId]: { 
            unit: {
              ...unit,
              starLevel: 0 // Default to no stars
            } 
          }
        }));
        placed = true;
        break;
      }
    }
    
    // If row is full, try other rows
    if (!placed) {
      for (let row = 0; row < 4; row++) {
        for (let col = 0; col < 7; col++) {
          const hexId = `${col}-${row}`;
          if (!board[hexId]) {
            setBoard(prev => ({
              ...prev,
              [hexId]: { 
                unit: {
                  ...unit,
                  starLevel: 0 // Default to no stars
                } 
              }
            }));
            placed = true;
            break;
          }
        }
        if (placed) break;
      }
    }
  };
  
  return (
    <div className="panel-card h-full rounded-none border-0 border-l border-gold/20">
      <div className="p-2 border-b border-gold/20">
        <div className="relative mb-2">
          <input
            type="text"
            placeholder="Search..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full pl-8 pr-3 py-1.5 bg-brown-light/30 border border-gold/30 rounded-md text-sm focus:outline-none focus:border-gold focus:ring-1 focus:ring-gold/50"
          />
          <Search className="absolute left-2.5 top-1/2 -translate-y-1/2 text-gold/70 h-4 w-4" />
        </div>
        
        <div className="flex border-b border-gold/20">
          <button
            onClick={() => setActiveTab('units')}
            className={`px-3 py-1.5 text-sm flex items-center gap-1 ${
              activeTab === 'units' 
                ? 'text-gold border-b-2 border-gold' 
                : 'text-cream/70 hover:text-cream'
            }`}
          >
            <UserIcon size={14} />
            <span>Units</span>
          </button>
          <button
            onClick={() => setActiveTab('items')}
            className={`px-3 py-1.5 text-sm flex items-center gap-1 ${
              activeTab === 'items' 
                ? 'text-gold border-b-2 border-gold' 
                : 'text-cream/70 hover:text-cream'
            }`}
          >
            <PackageIcon size={14} />
            <span>Items</span>
          </button>
          <button
            onClick={() => setActiveTab('traits')}
            className={`px-3 py-1.5 text-sm flex items-center gap-1 ${
              activeTab === 'traits' 
                ? 'text-gold border-b-2 border-gold' 
                : 'text-cream/70 hover:text-cream'
            }`}
          >
            <Layers size={14} />
            <span>Traits</span>
          </button>
        </div>
      </div>
      
      <div className="h-[calc(100vh-320px)] overflow-y-auto p-2">
        {activeTab === 'units' && (
          <div className="grid grid-cols-5 gap-2">
            {filteredUnits.map((unit) => (
              <div 
                key={unit.id} 
                className="flex flex-col items-center"
                onDoubleClick={() => handleUnitDoubleClick(unit)}
              >
                <DraggableUnit unit={unit} />
                {/* Unit names removed as requested */}
              </div>
            ))}
          </div>
        )}
        
        {activeTab === 'items' && (
          <div className="space-y-4">
            {itemCategories.map((category) => (
              <div key={category.id} className="mb-4">
                <div className="text-xs font-medium text-gold-light mb-2 border-b border-gold/20 pb-1">
                  {category.name}
                </div>
                <div className="grid grid-cols-4 sm:grid-cols-5 gap-3">
                  {category.items.map((item) => (
                    <div key={item.id} className="flex flex-col items-center">
                      <DraggableItem item={item} />
                      {/* Item names removed as requested */}
                    </div>
                  ))}
                </div>
              </div>
            ))}
          </div>
        )}
        
        {activeTab === 'traits' && (
          <div className="space-y-2">
            {traitGroups.map((trait) => (
              <div key={trait.id} className="border border-gold/10 rounded bg-brown-light/20">
                <div 
                  className="flex items-center p-2 cursor-pointer"
                  onClick={() => toggleTrait(trait.id)}
                >
                  <img 
                    src={`/assets/traits/${trait.icon}`} 
                    alt={trait.name} 
                    className="w-6 h-6 mr-2" 
                    onError={(e) => {
                      (e.target as HTMLImageElement).src = '/assets/app/default.png';
                    }}
                  />
                  <span className="text-sm">{trait.name}</span>
                  <span className="ml-auto text-xs text-cream/60">{trait.units.length} units</span>
                </div>
                
                {expandedTraits.includes(trait.id) && (
                  <div className="p-2 pt-0">
                    <div className="grid grid-cols-5 gap-2 mt-2 border-t border-gold/10 pt-2">
                      {trait.units.map((unit) => (
                        <div 
                          key={unit.id} 
                          className="flex flex-col items-center"
                          onDoubleClick={() => handleUnitDoubleClick(unit)}
                        >
                          <DraggableUnit unit={unit} />
                          {/* Unit names removed */}
                        </div>
                      ))}
                    </div>
                  </div>
                )}
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
EOL


# Rework SavedCompositions
cat > src/components/team-builder/SavedCompositions.tsx << 'EOL'
import React from 'react';
import CompList from './CompList';
import { SavedComposition } from '@/types';

interface SavedCompositionsProps {
  compositions: SavedComposition[];
  onLoad: (comp: SavedComposition) => void;
  onDelete: (id: string) => void;
}

export default function SavedCompositions({ 
  compositions, 
  onLoad, 
  onDelete 
}: SavedCompositionsProps) {
  return (
    <CompList
      compositions={compositions}
      title="Saved Compositions"
      onLoad={onLoad}
      onDelete={onDelete}
      maxHeight="max-h-60"
    />
  );
}
EOL

# Create SuggestedCompositions.tsx
cat > src/components/team-builder/SuggestedCompositions.tsx << 'EOL'
import React from 'react';
import CompList from './CompList';
import unitsJson from 'public/mapping/units.json';
import { SavedComposition, BoardCell } from '@/types';

interface SuggestedCompositionsProps {
  onLoad: (comp: SavedComposition) => void;
}

export default function SuggestedCompositions({ onLoad }: SuggestedCompositionsProps) {
  // Create basic placeholder compositions without mock data
  const processedComps: SavedComposition[] = React.useMemo(() => {
    const units = unitsJson.units as Record<string, any>;
    
    // Generate an empty composition with placeholder name
    const createEmptyComposition = (id: string, name: string): SavedComposition => {
      return {
        id,
        name,
        board: {},
        date: new Date().toISOString(),
        traits: []
      };
    };
    
    return [
      createEmptyComposition('suggested-1', 'Challenger Composition'),
      createEmptyComposition('suggested-2', 'Invoker Composition'),
      createEmptyComposition('suggested-3', 'Redeemed Composition')
    ];
  }, []);
  
  return (
    <CompList
      compositions={processedComps}
      title="Suggested Compositions"
      onLoad={onLoad}
      maxHeight="max-h-96"
    />
  );
}
EOL

# Create CompList.tsx
cat > src/components/team-builder/CompList.tsx << 'EOL'
import React from 'react';
import Link from 'next/link';
import { FileInput, Trash2 } from 'lucide-react';
import traitsJson from 'public/mapping/traits.json';
import { SavedComposition, BoardCell } from '@/types';

interface CompListProps {
  compositions: SavedComposition[];
  title: string;
  onLoad?: (comp: SavedComposition) => void;
  onDelete?: (id: string) => void;
  className?: string;
  maxHeight?: string;
}

export default function CompList({ 
  compositions, 
  title, 
  onLoad, 
  onDelete, 
  className = '',
  maxHeight = 'max-h-60'
}: CompListProps) {
  if (compositions.length === 0) {
    return (
      <div className={`mt-4 bg-brown-light/10 rounded-lg border border-gold/20 p-3 ${className}`}>
        <div className="text-center text-cream/60 text-sm">
          No {title.toLowerCase()} compositions available
        </div>
      </div>
    );
  }
  
  return (
    <div className={`mt-4 panel-card ${className}`}>
      <h3 className="panel-title">{title}</h3>
      
      <div className={`grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-3 p-3 overflow-y-auto ${maxHeight}`}>
        {compositions.map((comp) => (
          <div 
            key={comp.id}
            className="bg-brown-light/30 border border-gold/20 rounded-lg overflow-hidden group hover:border-gold/40"
          >
            <div className="p-2 border-b border-gold/10 flex justify-between items-center">
              <div className="text-sm font-medium truncate w-[7rem]">{comp.name}</div>
              {(onLoad || onDelete) && (
                <div className="flex gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                  {onLoad && (
                    <button 
                      className="bg-gold/20 hover:bg-gold/40 text-cream p-1 rounded"
                      onClick={() => onLoad(comp)}
                      title="Load"
                    >
                      <FileInput size={12} />
                    </button>
                  )}
                  {onDelete && (
                    <button 
                      className="bg-brown-light/40 hover:bg-brown-light/60 text-cream p-1 rounded"
                      onClick={() => onDelete(comp.id)}
                      title="Delete"
                    >
                      <Trash2 size={12} />
                    </button>
                  )}
                </div>
              )}
            </div>
            
            <div className="p-2 flex flex-wrap gap-1 justify-center">
              {comp.traits && Array.isArray(comp.traits) && comp.traits.slice(0, 6).map((trait, i) => {
                const traitData = 
                  (traitsJson.origins as Record<string, any>)[trait.id] || 
                  (traitsJson.classes as Record<string, any>)[trait.id];
                return traitData ? (
                  <img 
                    key={i} 
                    src={`/assets/traits/${traitData.icon}`}
                    alt={traitData.name}
                    className="w-5 h-5"
                    title={`${traitData.name} (${trait.count})`}
                  />
                ) : null;
              })}
              
              {(!comp.traits || !Array.isArray(comp.traits) || comp.traits.length === 0) && 
                Object.values(comp.board as Record<string, BoardCell>)
                  .filter((cell: BoardCell) => cell && cell.unit)
                  .slice(0, 6)
                  .map((cell: BoardCell, i) => {
                    // Since we've filtered for cell.unit, we can safely use non-null assertion
                    const unit = cell.unit!;
                    return (
                      <img 
                        key={i}
                        src={`/assets/units/${unit.icon}`}
                        alt={unit.name}
                        className="w-6 h-6 rounded-full border"
                        style={{ borderColor: ['#9aa4af', '#2ecc71', '#3498db', '#9b59b6', '#f1c40f', '#e74c3c'][unit.cost - 1] || '#9aa4af' }}
                      />
                    );
                  })
              }
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
EOL

# Update team-builder/index.ts
cat > src/components/team-builder/index.ts << 'EOL'
import TraitsPanel from './TraitsPanel';
import { Board } from './BoardComponents';
import SavedCompositions from './SavedCompositions';
import SuggestedCompositions from './SuggestedCompositions';
import SelectorPanel from './SelectorPanel';
import BuilderControls from './BuilderControls';
import { DraggableUnit, DraggableItem, UnitInHex } from './DraggableComponents';
import { BoardHex } from './BoardComponents';
import CompList from './CompList';

export {
  TraitsPanel,
  Board,
  SavedCompositions,
  SuggestedCompositions,
  SelectorPanel,
  BuilderControls,
  DraggableUnit,
  DraggableItem,
  BoardHex,
  UnitInHex,
  CompList
};
EOL

# Create app setup with error handling
cat > src/pages/_app.tsx << 'EOL'
import React, { useState, useEffect } from 'react';
import { QueryClient, QueryClientProvider, QueryCache } from '@tanstack/react-query';
import { TooltipProvider } from '@/components/ui/Tooltip';
import { ErrorBanner } from '@/components/common';
import type { AppProps } from 'next/app';
import { ErrorState } from '@/types';
import { AuthProvider } from '@/utils/auth/AuthContext'; // Add AuthProvider import
import '../styles/globals.css';

export default function App({ Component, pageProps }: AppProps) {
  const [queryClient] = useState(() => new QueryClient({
    queryCache: new QueryCache({
      onError: (error) => {
        console.error('Query error:', error);
      }
    }),
    defaultOptions: {
      queries: {
        refetchOnWindowFocus: false,
        retry: 2,
        staleTime: 300000,
      }
    }
  }));
  
  const [globalError, setGlobalError] = useState<ErrorState | null>(null);
  
  // Global error handling
  useEffect(() => {
    const handleGlobalError = (event: ErrorEvent) => {
      console.error('Global error:', event.error);
      setGlobalError({
        hasError: true,
        error: {
          type: 'unknown',
          message: event.error?.message || 'An unexpected error occurred',
          timestamp: new Date()
        }
      });
      
      // Clear error after 5 seconds
      setTimeout(() => setGlobalError(null), 5000);
    };
    
    window.addEventListener('error', handleGlobalError);
    return () => window.removeEventListener('error', handleGlobalError);
  }, []);

  return (
    <QueryClientProvider client={queryClient}>
      <AuthProvider>
        <TooltipProvider>
          {globalError && (
            <div className="fixed top-16 left-0 right-0 z-50 mx-auto max-w-3xl px-4">
              <ErrorBanner error={globalError} />
            </div>
          )}
          <Component {...pageProps} />
        </TooltipProvider>
      </AuthProvider>
    </QueryClientProvider>
  );
}
EOL

# Update the hex icon in the home page
cat > src/pages/index.tsx << 'EOL'
import React, { useState, useMemo } from 'react';
import Link from 'next/link';
import { motion } from 'framer-motion';
import { Layout, Card, FilterButtons, LoadingState, ErrorMessage } from '@/components/ui';
import { useTftData } from '@/utils/useTftData';
import { TrendingUp, Search, Layers, Trophy, Grid, ChevronDown, ChevronUp, Book, Newspaper, User, Download, Tv } from 'lucide-react';
import traitsJson from 'public/mapping/traits.json';
import unitsJson from 'public/mapping/units.json';
import itemsJson from 'public/mapping/items.json';
import { StatsCarousel } from '@/components/common/StatsCarousel';
import { HeaderBanner } from '@/components/common/HeaderBanner';
import { getEntityIcon, DEFAULT_ICONS } from '@/utils/paths';
import { useAuth } from '@/utils/auth/AuthContext';
import LoginButton from '@/components/auth/LoginButton';

// Define types with required 'all' property
type FilterType = 'units' | 'items' | 'traits';
interface FilterValue {
  all: boolean;
  [key: string]: boolean;
}

interface EntityGridProps {
  entities: Array<{
    id: string;
    name: string;
    icon: string;
    cost?: number;
    category?: string;
  }>;
  type: 'units' | 'items' | 'traits';
}

// Modernized App Banner Component with improved wording focused on experimentation
const AppBanner = () => {
  return (
    <motion.div 
      className="my-8"
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ duration: 0.4 }}
    >
      <div className="relative rounded-xl overflow-hidden">
        {/* Gradient background layer */}
        <div className="absolute inset-0 bg-gradient-to-r from-eclipse-shadow to-void-core opacity-90 z-0"></div>
        
        {/* Image background layer */}
        <div className="absolute inset-0 bg-[url('/assets/app/bg.jpg')] bg-cover bg-center opacity-20 z-0"></div>
        
        {/* Subtle border glow */}
        <div className="absolute inset-0 rounded-xl border border-solar-flare/30 z-10"></div>
        
        {/* Content container - centered approach with improved hierarchy */}
        <div className="relative z-20 px-6 py-10 flex flex-col items-center text-center">
          <h2 className="text-4xl font-display tracking-tight text-solar-flare mb-3">
            <span className="text-gold">Master</span> <span className="text-corona-light/90">TeamFight Tactics</span>
          </h2>
          
          <p className="text-corona-light/90 mb-6 max-w-2xl mx-auto text-base md:text-lg">
            Make the most of data-driven analysis & community predictions to forge new comps & strats. Get ready to climb!
          </p>
          
          <div className="flex flex-col sm:flex-row gap-4 mt-2">
            <motion.a 
              href="#" 
              className="btn btn-primary flex items-center justify-center gap-2 px-6 py-3"
              whileHover={{ scale: 1.03, boxShadow: "0 0 15px rgba(245, 158, 11, 0.3)" }}
              whileTap={{ scale: 0.97 }}
            >
              <Download size={20} />
              <span>Mobile App</span>
            </motion.a>
            <motion.a 
              href="#" 
              className="btn btn-secondary flex items-center justify-center gap-2 px-6 py-3"
              whileHover={{ scale: 1.03, boxShadow: "0 0 15px rgba(245, 158, 11, 0.2)" }}
              whileTap={{ scale: 0.97 }}
            >
              <Tv size={20} />
              <span>Desktop Overlay</span>
            </motion.a>
          </div>
          
          {/* Clean icon showcase using a clean horizontal display */}
          <div className="mt-8 flex items-center justify-center gap-6">
            <div className="relative">
              <img 
                src="/assets/items/TFT14_CypherItem_Golem_NullificationField.png" 
                alt="Unit" 
                className="w-12 h-12 object-cover rounded-full border-2 border-solar-flare"
                onError={(e) => {
                  const target = e.target as HTMLImageElement;
                  target.src = DEFAULT_ICONS.unit;
                }}
              />
            </div>
            <div className="relative">
              <img 
                src="/assets/items/TFT14_CypherItem_Golem_TitansteelPlating.png" 
                alt="Unit" 
                className="w-12 h-12 object-cover rounded-full border-2 border-solar-flare"
                onError={(e) => {
                  const target = e.target as HTMLImageElement;
                  target.src = DEFAULT_ICONS.unit;
                }}
              />
            </div>
            <div className="relative">
              <img 
                src="/assets/items/TFT14_CypherItem_Golem_KineticLauncherRockets.png" 
                alt="Unit" 
                className="w-12 h-12 object-cover rounded-full border-2 border-solar-flare"
                onError={(e) => {
                  const target = e.target as HTMLImageElement;
                  target.src = DEFAULT_ICONS.unit;
                }}
              />
            </div>
          </div>
        </div>
      </div>
    </motion.div>
  );
};

interface FeatureCardProps {
  title: string;
  icon: React.ReactNode;
  description: string;
  linkTo: string;
}

// Reimagined Feature Card with more visual impact, sleeker design and improved glass effect
const FeatureCard = ({ title, icon, description, linkTo }: FeatureCardProps) => {
  return (
    <Link href={linkTo}>
      <motion.div 
        className="backdrop-filter backdrop-blur-md bg-eclipse-shadow/30 to-void-core/40 rounded-xl overflow-hidden relative group border border-solar-flare/20"
        whileHover={{ 
          scale: 1.03, 
          boxShadow: "0 10px 25px -5px rgba(245, 158, 11, 0.25)",
        }}
        transition={{ duration: 0.2 }}
      >
        {/* Animated background glow effect */}
        <motion.div 
          className="absolute inset-0 bg-gradient-to-tr from-solar-flare/0 to-solar-flare/10 opacity-0 group-hover:opacity-100 transition-opacity duration-300"
          initial={false}
          animate={{ opacity: 0 }}
          whileHover={{ opacity: 1 }}
        />
        
        {/* Border glow */}
        <div className="absolute inset-0 border border-solar-flare/30 group-hover:border-solar-flare/60 rounded-xl transition-colors duration-300" />
        
        <div className="p-6 h-full flex flex-col items-center text-center">
          {/* Icon with glow effect on hover */}
          <motion.div 
            className="w-16 h-16 rounded-full flex items-center justify-center bg-eclipse-shadow/60 backdrop-blur-md border border-solar-flare/40 mb-4 relative overflow-hidden"
            whileHover={{ scale: 1.05 }}
          >
            <motion.div 
              className="absolute inset-0 bg-solar-flare/10 opacity-0 group-hover:opacity-100 transition-opacity duration-300"
            />
            <div className="text-solar-flare z-10">
              {icon}
            </div>
          </motion.div>
          
          <h3 className="text-xl font-display text-solar-flare mb-2 group-hover:text-solar-flare/90 transition-colors duration-300">
            {title}
          </h3>
          
          <p className="text-sm text-corona-light/80 group-hover:text-corona-light/90 transition-colors duration-300">
            {description}
          </p>
          
          {/* Animated arrow that appears on hover */}
          <motion.div 
            className="mt-4 text-solar-flare/0 group-hover:text-solar-flare transition-colors duration-300 flex items-center justify-center"
            initial={{ y: 10, opacity: 0 }}
            whileHover={{ y: 0, opacity: 1 }}
          >
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M5 12H19M19 12L12 5M19 12L12 19" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
            </svg>
          </motion.div>
        </div>
      </motion.div>
    </Link>
  );
};

interface FeatureCardsContainerProps {
  children: React.ReactNode;
}

// Improved Feature Cards Container with better spacing and animation
const FeatureCardsContainer = ({ children }: FeatureCardsContainerProps) => {
  return (
    <motion.div
      className="grid grid-cols-1 md:grid-cols-3 gap-6"
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ 
        duration: 0.5,
        staggerChildren: 0.1
      }}
    >
      {children}
    </motion.div>
  );
};

// Define an interface for the FeatureBanner props
interface FeatureBannerProps {
  title: string;
}

// Enhanced Feature Banner with centered alignment
const FeatureBanner = ({ title }: FeatureBannerProps) => {
  return (
    <div className="mb-4">
      <div className="flex items-center justify-center">
        <div className="h-1 flex-grow bg-gradient-to-r from-transparent via-solar-flare/20 to-solar-flare/50 mr-3"></div>
        <div className="bg-eclipse-shadow/70 backdrop-blur-md border-b-2 border-solar-flare rounded-md px-8 py-3 inline-block shadow-sm shadow-solar-flare/20">
          <h2 className="text-2xl font-display text-solar-flare text-center">{title}</h2>
        </div>
        <div className="h-1 flex-grow bg-gradient-to-l from-transparent via-solar-flare/20 to-solar-flare/50 ml-3"></div>
      </div>
    </div>
  );
};

const EntityGrid = ({ entities, type }: EntityGridProps) => {
  // Animation variants for staggered grid items
  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.03,
        delayChildren: 0.1
      }
    }
  };
  
  const itemVariants = {
    hidden: { opacity: 0, y: 20 },
    visible: { 
      opacity: 1, 
      y: 0,
      transition: {
        duration: 0.5,
        ease: [0.2, 0.8, 0.2, 1]
      }
    }
  };
  
  return (
    <motion.div 
      className="grid grid-cols-2 sm:grid-cols-4 md:grid-cols-6 lg:grid-cols-12 gap-2"
      variants={containerVariants}
      initial="hidden"
      animate="visible"
    >
      {entities.map((entity, i) => (
        <motion.div key={i} variants={itemVariants}>
          <Link href={`/entity/${type}/${entity.id}`}>
            <motion.div 
              className="flex flex-col items-center p-2 bg-eclipse-shadow/40 backdrop-blur-sm rounded-xl hover:bg-eclipse-shadow/60 transition-all duration-300 border border-solar-flare/10 hover:border-solar-flare/30"
              whileHover={{ 
                scale: 1.05,
                boxShadow: "0 10px 25px -5px rgba(245, 158, 11, 0.2)" 
              }}
            >
              {type === 'units' && (
                <div className="relative">
                  <img 
                    src={`/assets/units/${entity.icon}`} 
                    alt={entity.name} 
                    className="w-12 h-12 rounded-full border-2 object-cover transition-transform duration-300 hover:scale-110" 
                    style={{ 
                      borderColor: ['#9aa4af', '#2ecc71', '#3498db', '#9b59b6', '#f1c40f', '#e74c3c'][(entity.cost || 1) - 1] 
                    }}
                    onError={(e) => {
                      const target = e.target as HTMLImageElement;
                      target.src = DEFAULT_ICONS.unit;
                    }}
                  />
                </div>
              )}
              {type === 'items' && (
                <img 
                  src={`/assets/items/${entity.icon}`} 
                  alt={entity.name} 
                  className="w-11 h-11 object-contain transition-transform duration-300 hover:scale-110" 
                  onError={(e) => {
                    const target = e.target as HTMLImageElement;
                    target.src = DEFAULT_ICONS.item;
                  }}
                />
              )}
              {type === 'traits' && (
                <img 
                  src={getEntityIcon(entity, 'trait')} 
                  alt={entity.name} 
                  className="w-12 h-12 object-contain transition-transform duration-300 hover:scale-110" 
                  onError={(e) => {
                    const target = e.target as HTMLImageElement;
                    target.src = DEFAULT_ICONS.trait;
                  }}
                />
              )}
              <span className="text-xs mt-1 truncate w-full text-center text-corona-light">{entity.name}</span>
            </motion.div>
          </Link>
        </motion.div>
      ))}
    </motion.div>
  );
}

export default function Home() {
  // Fixed TypeScript error by using type assertion and accessing properties safely
  const tftData = useTftData() as any;
  const isLoading = tftData?.isLoading || false;
  const data = tftData?.data || null;
  const error = tftData?.error || null;
  const handleRetry = tftData?.handleRetry || (() => {});
  
  const [activeTab, setActiveTab] = useState<FilterType>('units');
  const [filters, setFilters] = useState<Record<FilterType, FilterValue>>({ 
    units: { all: true }, 
    items: { all: true }, 
    traits: { all: true, origin: false, class: false } 
  });
  const [isCollectionsExpanded, setIsCollectionsExpanded] = useState(false);
  const { auth } = useAuth();

  // Process data before conditional returns
  const allUnits = useMemo(() => 
    Object.entries(unitsJson.units as Record<string, any>)
      .map(([id, unit]) => ({ id, name: unit.name, icon: unit.icon, cost: unit.cost }))
      .sort((a, b) => a.cost - b.cost || a.name.localeCompare(b.name))
  , []);
  
  // Use useMemo to memoize allTraitsData
  const allTraits = useMemo(() => {
    const allTraitsData = { ...traitsJson.origins, ...traitsJson.classes };
    
    return Object.entries(allTraitsData as Record<string, any>)
      .map(([id, trait]) => ({
        id, 
        name: trait.name, 
        icon: trait.icon,
        type: id in traitsJson.origins ? 'Origin' : 'Class'
      }))
      .sort((a, b) => a.name.localeCompare(b.name));
  }, []);
  
  const allItems = useMemo(() => 
    Object.entries(itemsJson.items as Record<string, any>)
      .filter(([_, item]) => item.category !== 'component' && item.category !== 'tactician')
      .map(([id, item]) => ({ id, name: item.name, icon: item.icon, category: item.category }))
      .sort((a, b) => a.name.localeCompare(b.name))
  , []);

  // Filter options
  const costFilters = useMemo(() => 
    Array.from(new Set(allUnits.map(unit => unit.cost)))
      .sort()
      .map(cost => ({ id: cost.toString(), name: `${cost} 🪙` }))
  , [allUnits]);
  
  const categoryFilters = useMemo(() => 
    Array.from(new Set(allItems.map(item => item.category)))
      .filter(Boolean)
      .map(category => ({ id: category, name: category.replace(/-/g, ' ') }))
  , [allItems]);
  
  const traitTypeFilters = [
    { id: 'origin', name: 'Origins' },
    { id: 'class', name: 'Classes' }
  ];
  
  // Filtered entities
  const filteredUnits = useMemo(() => 
    allUnits.filter(unit => {
      const costKey = unit.cost?.toString();
      return filters.units.all || (costKey && costKey in filters.units && filters.units[costKey]);
    })
  , [allUnits, filters.units]);
  
  const filteredItems = useMemo(() => 
    allItems.filter(item => 
      filters.items.all || 
      (item.category && item.category in filters.items && filters.items[item.category])
    )
  , [allItems, filters.items]);
  
  const filteredTraits = useMemo(() => 
    allTraits.filter(trait => 
      filters.traits.all || 
      ('origin' in filters.traits && filters.traits.origin && trait.type === 'Origin') ||
      ('class' in filters.traits && filters.traits.class && trait.type === 'Class')
    )
  , [allTraits, filters.traits]);
  
  if (isLoading) return (
    <Layout>
      <LoadingState message="Loading TFT data..." />
    </Layout>
  );

  if (error) return (
    <Layout>
      <div className="mt-6">
        <ErrorMessage 
          message={error && typeof error === 'object' && 'message' in error ? String(error.message) : 'An error occurred'} 
          onRetry={handleRetry} 
        />
      </div>
    </Layout>
  );

  // Toggle filter handler
  const toggleFilter = (type: FilterType, filterId: string): void => {
    if (filterId === 'all') {
      setFilters({...filters, [type]: { all: true }});
    } else {
      const newTypeFilters: FilterValue = {...filters[type], all: false};
      
      if (newTypeFilters[filterId]) {
        newTypeFilters[filterId] = false;
        // Check if any filter is still active
        const hasActiveFilters = Object.entries(newTypeFilters)
          .some(([key, value]) => key !== 'all' && value);
          
        if (!hasActiveFilters) {
          newTypeFilters.all = true;
        }
      } else {
        newTypeFilters[filterId] = true;
      }
      
      setFilters({...filters, [type]: newTypeFilters});
    }
  };
  
  // Animation variants
  const featureSectionVariants = {
    hidden: { opacity: 0, y: 20 },
    visible: { 
      opacity: 1, 
      y: 0, 
      transition: {
        duration: 0.2,
        ease: [0.2, 0.2, 0.2, 1]
      }
    }
  };
  
  return (
    <Layout>
      {/* Header Banner */}
      <HeaderBanner />
      
      {/* Stats Carousel */}
      <StatsCarousel />
      
      {/* Sleek Modern App Banner with updated wording */}
      <AppBanner />
    
      {/* First Feature Section - Updated titles and descriptions */}
      <motion.div 
        className="mt-10"
        variants={featureSectionVariants}
        initial="hidden"
        animate="visible"
      >
        <FeatureBanner title="Tools for Tacticians" />
        <div className="mt-2">
          <FeatureCardsContainer>
            <FeatureCard 
              title="Meta Report"
              icon={<TrendingUp size={30} />}
              description="Discover current best strategies" 
              linkTo="/meta-report"
            />
            <FeatureCard 
              title="Stats Explorer"
              icon={<Search size={30} />}
              description="Analyze performance with detailed stats"
              linkTo="/stats-explorer"
            />
            <FeatureCard 
              title="Team Builder"
              icon={<Layers size={30} />}
              description="Plan & craft winning compositions"
              linkTo="/team-builder"
            />
          </FeatureCardsContainer>
        </div>
      </motion.div>
      
      {/* Second Feature Section - Updated titles and descriptions */}
      <motion.div 
        className="mt-10"
        variants={featureSectionVariants}
        initial="hidden"
        animate="visible"
        transition={{ delay: 0.1 }}
      >
        <FeatureBanner title="Community & Resources" />
        <div className="mt-2">
          <FeatureCardsContainer>
            <FeatureCard 
              title="Strategy Guides"
              icon={<Book size={30} />}
              description="Learn from top players and climb the ladder" 
              linkTo="/guides"
            />
            <FeatureCard 
              title="Latest News"
              icon={<Newspaper size={30} />}
              description="Stay updated with patches and game changes"
              linkTo="/news"
            />
            <FeatureCard 
              title="Player Profile"
              icon={<User size={30} />}
              description="Track your stats and match history"
              linkTo="/profile"
            />
          </FeatureCardsContainer>
        </div>
      </motion.div>
        
      {/* Collections Section - Updated with improved glass effect */}
      <motion.div 
        className="mt-10"
        variants={featureSectionVariants}
        initial="hidden"
        animate="visible"
        transition={{ delay: 0.2 }}
      >
        <FeatureBanner title="TFT Collection & Community" />
        <div className="mt-2 backdrop-filter backdrop-blur-md bg-eclipse-shadow/30 rounded-xl p-4 shadow-md border border-solar-flare/30 hover:border-solar-flare/40 transition-all">
          <motion.div 
            className="flex flex-col items-center cursor-pointer mb-2"
            onClick={() => setIsCollectionsExpanded(!isCollectionsExpanded)}
            whileHover={{ scale: 1.02 }}
          >
            {/* Modernized collections toggle button */}
            <motion.div 
              className="w-16 h-16 rounded-full flex items-center justify-center bg-eclipse-shadow/60 backdrop-blur-sm border border-solar-flare/40 mb-4 relative overflow-hidden"
              whileHover={{ 
                scale: 1.05,
                borderColor: "rgba(245, 158, 11, 0.6)" 
              }}
              whileTap={{ scale: 0.95 }}
            >
              <Grid
                size={30}
                className="text-solar-flare"
              />
            </motion.div>
            
            <h3 className="text-xl font-display text-solar-flare mb-2">Collections</h3>
            <div className="text-sm text-corona-light/80 mb-3 text-center max-w-lg">
              Discover all available units, items, and traits
            </div>
            
            <motion.div className="mt-1 flex justify-center text-solar-flare">
              {isCollectionsExpanded ? <ChevronUp size={24} /> : <ChevronDown size={24} />}
            </motion.div>
          </motion.div>
          
          {/* Collections content with animation */}
          <motion.div 
            className="transition-all duration-200 ease-in-out overflow-hidden"
            initial={{ height: 0, opacity: 0 }}
            animate={{ 
              height: isCollectionsExpanded ? 'auto' : 0,
              opacity: isCollectionsExpanded ? 1 : 0
            }}
            transition={{ duration: 0.5, ease: [0.2, 0.8, 0.2, 1] }}
          >
            <div className="border-b border-solar-flare/30 pb-3 mb-4 mt-2">
              <div className="border-b border-solar-flare/30 flex flex-col sm:flex-row justify-between items-center">
                <div className="flex">
                  {(['units', 'items', 'traits'] as const).map((tab) => (
                    <motion.button
                      key={tab}
                      className={`px-4 py-2 transition-all duration-200 ${activeTab === tab ? 'text-solar-flare border-b-2 border-solar-flare' : 'text-corona-light/70 hover:text-corona-light'}`}
                      onClick={() => setActiveTab(tab)}
                      whileHover={{ y: -2 }}
                      whileTap={{ y: 0 }}
                    >
                      {tab.charAt(0).toUpperCase() + tab.slice(1)}
                    </motion.button>
                  ))}
                </div>
                <div className="py-2 px-4 overflow-x-auto w-full sm:w-auto">
                  {activeTab === 'units' && (
                    <FilterButtons 
                      options={costFilters} 
                      activeFilter={filters.units}
                      onChange={(id) => toggleFilter('units', id)}
                    />
                  )}
                  {activeTab === 'items' && (
                    <FilterButtons 
                      options={categoryFilters} 
                      activeFilter={filters.items}
                      onChange={(id) => toggleFilter('items', id)}
                    />
                  )}
                  {activeTab === 'traits' && (
                    <FilterButtons 
                      options={traitTypeFilters} 
                      activeFilter={filters.traits}
                      onChange={(id) => toggleFilter('traits', id)}
                    />
                  )}
                </div>
              </div>
            </div>
            
            <div className="transition-opacity duration-500 ease-in-out overflow-x-auto">
              {activeTab === 'units' && <EntityGrid entities={filteredUnits} type="units" />}
              {activeTab === 'items' && <EntityGrid entities={filteredItems} type="items" />}
              {activeTab === 'traits' && <EntityGrid entities={filteredTraits} type="traits" />}
            </div>
          </motion.div>
        </div>
      </motion.div>
      {/* Collections Section */}
      <motion.div 
        className="mt-10"
        variants={featureSectionVariants}
        initial="hidden"
        animate="visible"
        transition={{ delay: 0.2 }}
      >
        <div className="mt-2">
          {/* Community/Profile buttons in a equal-sized row */}
          <div className="flex flex-col md:flex-row gap-4 mb-4">
            <motion.div 
              className="backdrop-filter backdrop-blur-md bg-eclipse-shadow/30 rounded-xl p-4 border border-solar-flare/30 flex-1"
              whileHover={{ 
                scale: 1.02,
                boxShadow: "0 10px 25px -5px rgba(245, 158, 11, 0.15)" 
              }}
              transition={{ duration: 0.2 }}
            >
              <Link href="/profile" className="flex flex-col items-center">
                <div className="w-16 h-16 rounded-full flex items-center justify-center bg-eclipse-shadow/60 backdrop-blur-sm border border-solar-flare/40 mb-4">
                  <User size={28} className="text-solar-flare" />
                </div>
                <h3 className="text-xl font-display text-solar-flare mb-2">My Profile</h3>
                <p className="text-sm text-corona-light/80 text-center">
                  View your stats, match history, and track your TFT journey
                </p>
              </Link>
            </motion.div>
            
            <motion.div 
              className="backdrop-filter backdrop-blur-md bg-eclipse-shadow/30 rounded-xl p-4 border border-solar-flare/30 flex-1"
              whileHover={{ 
                scale: 1.02,
                boxShadow: "0 10px 25px -5px rgba(245, 158, 11, 0.15)" 
              }}
              transition={{ duration: 0.2 }}
            >
              <Link href="/leaderboard" className="flex flex-col items-center">
                <div className="w-16 h-16 rounded-full flex items-center justify-center bg-eclipse-shadow/60 backdrop-blur-sm border border-solar-flare/40 mb-4">
                  <Trophy size={28} className="text-solar-flare" />
                </div>
                <h3 className="text-xl font-display text-solar-flare mb-2">Leaderboard</h3>
                <p className="text-sm text-corona-light/80 text-center">
                  Discover top players and see where you rank globally
                </p>
              </Link>
            </motion.div>
          </div>
        </div>
      </motion.div>

      {/* CTA Banner - Login/Get Started with proper button */}
      <motion.div 
        className="mt-12 mb-6"
        variants={featureSectionVariants}
        initial="hidden"
        animate="visible"
        transition={{ delay: 0.3 }}
      >
        <div className="relative rounded-xl overflow-hidden">
          {/* Background layers */}
          <div className="absolute inset-0 bg-gradient-to-r from-eclipse-shadow to-void-core opacity-90 z-0"></div>
          <div className="absolute inset-0 bg-[url('/assets/app/fight_banner.jpg')] bg-cover bg-center opacity-20 z-0 rounded-xl"></div>
          <div className="absolute inset-0 rounded-xl border border-solar-flare/30 z-10"></div>
          
          {/* Content */}
          <div className="relative z-20 px-6 py-10 flex flex-col items-center text-center">
            <h2 className="text-2xl md:text-3xl font-display mb-3">
              <span className="text-solar-flare">Ready</span> <span className="text-white">to dominate the arena?</span>
            </h2>
            
            <p className="text-corona-light/90 mb-6 max-w-2xl mx-auto text-base">
              Join thousands of players using MetaForge to analyze their games, discover winning strategies, and climb the ranks.
            </p>
            
            {/* Centered Login Button */}
            <div className="flex justify-center">
              {auth.isAuthenticated ? (
                <Link href="/profile">
                  <motion.button
                    className="px-8 py-3 bg-solar-flare text-void-core font-medium rounded-md flex items-center gap-2"
                    whileHover={{ scale: 1.05, boxShadow: "0 0 15px rgba(245, 158, 11, 0.3)" }}
                    whileTap={{ scale: 0.95 }}
                  >
                    <User size={20} />
                    <span>Go to My Profile</span>
                  </motion.button>
                </Link>
              ) : (
                <LoginButton 
                  label="Sign in with Riot" 
                  size="lg" 
                  variant="primary" 
                />
              )}
            </div>
          </div>
        </div>
      </motion.div>
    </Layout>
  );
}
EOL

# Create dynamic entity detail page
cat > src/pages/entity/\[entity\]/\[id\].tsx << 'EOL'
import { useRouter } from 'next/router';
import { Layout, Card, LoadingState, ErrorMessage } from '@/components/ui';
import { useEntityData, useTftData } from '@/utils/useTftData';
import unitsJson from 'public/mapping/units.json';
import traitsJson from 'public/mapping/traits.json';
import itemsJson from 'public/mapping/items.json';
import { UnitDetail, TraitDetail, ItemDetail, CompDetail } from '@/components/entity';
import { ProcessedUnit, ProcessedTrait, ProcessedItem, Composition } from '@/types';

export default function EntityDetailPage() {
  const router = useRouter();
  const { id, entity } = router.query;
  const entityType = entity as string;
  const entityId = id as string;
  
  // Fixed TypeScript error by using type assertion and accessing properties safely
  const tftData = useTftData() as any;
  const isLoading = tftData?.isLoading || false;
  const error = tftData?.error || null;
  const handleRetry = tftData?.handleRetry || (() => {});
  
  // Get entity data from the hook with explicit type
  const entityData = useEntityData(entityType, entityId);
  
  // Get specific details from json files
  const unitDetails = entityType === 'units' && entityId 
    ? (unitsJson.units as Record<string, any>)[entityId] 
    : null;
  
  const traitType = entityId && Object.keys(traitsJson.origins).includes(entityId) 
    ? 'origins' 
    : 'classes';
  
  const traitDetails = entityType === 'traits' && entityId 
    ? (traitsJson[traitType] as Record<string, any>)[entityId] 
    : null;
  
  const itemDetails = entityType === 'items' && entityId 
    ? (itemsJson.items as Record<string, any>)[entityId] 
    : null;
  
  // Loading state
  if (isLoading || !entityId) {
    return (
      <Layout>
        <LoadingState message="Loading entity data..." />
      </Layout>
    );
  }

  // Error state
  if (error) {
    return (
      <Layout>
        <div className="mt-6">
          <ErrorMessage 
            message={error && typeof error === 'object' && 'message' in error ? String(error.message) : 'An error occurred'} 
            onRetry={handleRetry} 
          />
        </div>
      </Layout>
    );
  }

  // Entity not found
  if (!entityData && entityId) {
    return (
      <Layout>
        <Card className="mt-10">
          <div className="text-center py-8">
            <h1 className="text-xl text-gold mb-4">Entity Not Found</h1>
            <p className="text-center py-8">
              The {entityType?.slice(0, -1) || 'entity'} you're looking for doesn't exist or isn't available.
            </p>
            <button 
              onClick={() => router.back()}
              className="mt-6 bg-brown-light/50 hover:bg-brown-light/70 text-cream px-4 py-2 rounded-md"
            >
              Go Back
            </button>
          </div>
        </Card>
      </Layout>
    );
  }

  return (
    <Layout>
      <Card className="mt-10">
        {entityType === 'units' && entityData && (
          <UnitDetail 
            entityData={entityData as ProcessedUnit} 
            unitDetails={unitDetails} 
          />
        )}
        {entityType === 'traits' && entityData && (
          <TraitDetail 
            entityData={entityData as ProcessedTrait} 
            traitDetails={traitDetails} 
            traitType={traitType} 
            entityId={entityId} 
          />
        )}
        {entityType === 'items' && entityData && (
          <ItemDetail 
            entityData={entityData as ProcessedItem} 
            itemDetails={itemDetails} 
          />
        )}
        {entityType === 'comps' && entityData && (
          <CompDetail entityData={entityData as Composition} />
        )}
      </Card>
    </Layout>
  );
}
EOL

# Update the TeamBuilder page to use the new components
cat > src/pages/team-builder/index.tsx << 'EOL'
import React, { useState, useEffect, useRef, useMemo } from 'react';
import { DndProvider } from 'react-dnd';
import { HTML5Backend } from 'react-dnd-html5-backend';
import { Layout, Card } from '@/components/ui';
import unitsJson from 'public/mapping/units.json';
import itemsJson from 'public/mapping/items.json';
import traitsJson from 'public/mapping/traits.json';
import { SavedComposition, Composition, BoardCell } from '@/types';
import { FeatureBanner, HeaderBanner, StatsCarousel } from '@/components/common';
import {
  TraitsPanel,
  Board,
  SavedCompositions,
  SuggestedCompositions,
  SelectorPanel,
  BuilderControls
} from '@/components/team-builder';

export default function TeamBuilder() {
  const [traitCounts, setTraitCounts] = useState({});
  const [traitTiers, setTraitTiers] = useState({});
  const [board, setBoard] = useState({});
  const [compositions, setCompositions] = useState<SavedComposition[]>([]);
  const [compositionName, setCompositionName] = useState('');
  const [search, setSearch] = useState('');
  const boardRef = useRef(null);
  
  // Filter units and items based on search
  const filteredUnits = useMemo(() => 
    Object.entries(unitsJson.units)
      .map(([id, unit]) => {
        // Use type assertion to define the expected shape
        return {
          id,
          name: unit.name,
          icon: unit.icon,
          cost: unit.cost,
          // Type assertion to avoid property access errors
          traits: (unit as any).traits || {},
          // Add empty stats object to match ProcessedUnit interface
          stats: {} as {
            count?: number;
            avgPlacement?: number;
            winRate?: number;
            top4Rate?: number;
          }
        };
      })
      .filter(unit => !search || unit.name.toLowerCase().includes(search.toLowerCase()))
      .sort((a, b) => a.cost - b.cost || a.name.localeCompare(b.name)),
    [search]
  );
  
  const filteredItems = useMemo(() => 
    Object.entries(itemsJson.items)
      .filter(([_, item]) => item.category && item.category !== 'tactician')
      .map(([id, item]) => ({
        id,
        name: item.name,
        icon: item.icon,
        category: item.category,
        // Add empty stats object to match ProcessedItem interface
        stats: {} as {
          count?: number;
          avgPlacement?: number;
          winRate?: number;
          top4Rate?: number;
        }
      }))
      .filter(item => !search || item.name.toLowerCase().includes(search.toLowerCase()))
      .sort((a, b) => a.name.localeCompare(b.name)),
    [search]
  );
  
  // Load saved compositions on mount
  useEffect(() => {
    try {
      const savedComps = localStorage.getItem('tft-compositions');
      if (savedComps) {
        setCompositions(JSON.parse(savedComps));
      }
      
      // Check if there's a comp to load from a tooltip
      const loadComp = localStorage.getItem('loadComp');
      if (loadComp) {
        const comp = JSON.parse(loadComp) as Composition;
        
        // Convert the composition to board cells
        const newBoard: Record<string, BoardCell> = {};
        let row = 0, col = 0;
        
        // Place units on the board
        comp.units.forEach(unit => {
          if (col >= 7) {
            col = 0;
            row++;
          }
          
          if (row < 4) {
            const hexId = `${col}-${row}`;
            
            // Here's the fixed code to safely access unit traits:
            // Create a proper type assertion to access unit traits
            const unitsData = unitsJson.units as Record<string, any>;
            const unitTraits = unitsData[unit.id]?.traits || {};
            
            newBoard[hexId] = { 
              unit: {
                ...unit,
                // Add traits from units.json
                traits: unitTraits
              }
            };
            col++;
          }
        });
        
        setBoard(newBoard);
        setCompositionName(comp.name || 'Imported Comp');
        
        // Clear the localStorage item to prevent reloading on refresh
        localStorage.removeItem('loadComp');
      }
    } catch (e) {
      console.error('Failed to load compositions', e);
    }
  }, []);
  
  // Save composition
  const saveComposition = () => {
    if (Object.keys(board).length === 0) return;
    
    const name = compositionName.trim() || `Comp #${compositions.length + 1}`;
    const newComp: SavedComposition = { 
      id: Date.now().toString(),
      name, 
      board, 
      date: new Date().toISOString(),
      traits: Object.entries(traitCounts)
        .filter(([_, count]) => (count as number) > 0)
        .map(([id, count]) => ({ id, count: count as number }))
    };
    
    const updatedComps = [...compositions, newComp];
    
    setCompositions(updatedComps);
    localStorage.setItem('tft-compositions', JSON.stringify(updatedComps));
    setCompositionName('');
  };
  
  // Load composition
  const loadComposition = (comp: SavedComposition) => {
    setBoard(comp.board);
  };
  
  // Delete composition
  const deleteComposition = (id: string) => {
    const updatedComps = compositions.filter(comp => comp.id !== id);
    setCompositions(updatedComps);
    localStorage.setItem('tft-compositions', JSON.stringify(updatedComps));
  };
  
  // Clear the board
  const clearBoard = () => {
    setBoard({});
  };

  // Calculate traits for unique units
  useEffect(() => {
    // Create a map of unique units
    const uniqueUnits = new Map<string, { traits: string[] }>();
    
    Object.values(board as Record<string, BoardCell>).forEach(cell => {
      if (!cell?.unit) return;
      
      const unitId = cell.unit.id;
      if (!uniqueUnits.has(unitId)) {
        // Fix: Create a safe reference to traits and handle null/undefined cases
        const traits = cell.unit.traits || {};
        
        // Handle both array and single value cases with proper null checks
        const originTraits = Array.isArray(traits.origin) 
          ? traits.origin 
          : (traits.origin ? [traits.origin] : []);
        
        const classTraits = Array.isArray(traits.class) 
          ? traits.class 
          : (traits.class ? [traits.class] : []);
        
        // Filter out undefined values and ensure TypeScript knows we have strings
        const allTraits = [...originTraits, ...classTraits].filter((trait): trait is string => Boolean(trait));
        
        uniqueUnits.set(unitId, { traits: allTraits });
      }
    });
    
    // Count traits and calculate tiers 
    const counts: Record<string, number> = {};
    const tiers: Record<string, number> = {};
    const allTraits: Record<string, any> = { ...traitsJson.origins, ...traitsJson.classes };
    
    uniqueUnits.forEach(unit => {
      unit.traits.forEach(trait => {
        counts[trait] = (counts[trait] || 0) + 1;
      });
    });
    
    Object.entries(counts).forEach(([traitId, count]) => {
      const traitData = allTraits[traitId];
      if (!traitData || !traitData.tiers) {
        tiers[traitId] = 0;
        return;
      }
      
      let tierLevel = 0;
      for (let i = 0; i < traitData.tiers.length; i++) {
        if (count >= traitData.tiers[i].units) {
          tierLevel = i + 1;
        } else {
          break;
        }
      }
      
      tiers[traitId] = tierLevel;
    });
    
    setTraitCounts(counts);
    setTraitTiers(tiers);
  }, [board]);
  
  return (
    <Layout title="Team Builder">
      {/* Header Banner */}
      <HeaderBanner />
      
      {/* Stats Carousel */}
      <StatsCarousel />
      
      <div className="mt-8">
        <FeatureBanner title="Team Builder - Plan & craft" />
        
        {/* Builder Controls with instructions */}
        <BuilderControls
          board={board}
          saveComposition={saveComposition}
          clearBoard={clearBoard}
          compositionName={compositionName}
          setCompositionName={setCompositionName}
        />
        
        <Card className="mt-2 bg-brown/5 border border-gold/20 p-0 rounded-lg backdrop-blur-md">
          <DndProvider backend={HTML5Backend}>
            <div className="flex flex-col lg:flex-row team-builder-container" ref={boardRef}>
              {/* Left column - Traits */}
              <div className="lg:w-2/12 border-r border-gold/20 team-builder-panel">
                <TraitsPanel 
                  traitCounts={traitCounts} 
                  traitTiers={traitTiers} 
                />
              </div>
              
              {/* Middle column - Board */}
              <div className="lg:w-7/12 p-4 overflow-auto team-builder-content">
                {/* Board section */}
                <div className="mt-2">
                  <Board 
                    board={board} 
                    setBoard={setBoard} 
                  />
                </div>
                
                {/* Saved compositions BELOW the board */}
                <SavedCompositions 
                  compositions={compositions} 
                  onLoad={loadComposition}
                  onDelete={deleteComposition}
                />
                
                {/* Suggested compositions */}
                <SuggestedCompositions
                  onLoad={loadComposition}
                />
              </div>
              
              {/* Right column - Units/Items Selector */}
              <div className="lg:w-3/12 border-l border-gold/20 team-builder-panel">
                <SelectorPanel 
                  filteredUnits={filteredUnits} 
                  filteredItems={filteredItems}
                  search={search}
                  setSearch={setSearch}
                  board={board}
                  setBoard={setBoard}
                />
              </div>
            </div>
          </DndProvider>
        </Card>
      </div>
    </Layout>
  );
}
EOL

# =====================
# RESOURCES PAGES SECTION
# =====================

# Create news page
cat > src/pages/news/index.tsx << 'EOL'
import React, { useState } from 'react';
import { Layout, Card } from '@/components/ui';
import { HeaderBanner } from '@/components/common';
import { StatsCarousel } from '@/components/common';
import { 
  Calendar, 
  Tag, 
  Clock, 
  FileBarChart, 
  Trophy, 
  Star, 
  Puzzle, 
  Zap, 
  Slack,
  Eye,
  Cpu,
  Info
} from 'lucide-react';

// Define types for the TFT data
interface TFTCurrentData {
  currentSet: string;
  currentSetName: string;
  currentPatch: string;
  releaseDate: string;
  nextSetDate: string;
  nextSetName: string;
  nextPatchDate: string;
  nextPatchName: string;
}

interface TimelineEvent {
  date: string;
  name: string;
  type: string;
  description: string;
  highlights: string[];
}

interface Tournament {
  name: string;
  date: string;
  region: string;
  importance: string;
  prizePool: string;
  description: string;
}

interface SetData {
  name: string;
  startDate: string;
  endDate: string;
  theme: string;
  mechanic: string;
  description: string;
}

interface RevivalData {
  name: string;
  startDate: string;
  endDate: string;
  description: string;
}

interface TimelineData {
  patches: TimelineEvent[];
  tournaments: Tournament[];
  sets: SetData[];
  revivals: RevivalData[];
}

interface KeyChange {
  title: string;
  description: string;
}

interface OpeningEncounter {
  character?: string;
  type?: string;
  effect: string;
  chance: string;
}

interface HackEncounter {
  type: string;
  effect: string;
  chance: string;
}

interface EmblemChange {
  name: string;
  effect: string;
}

interface Cosmetic {
  name: string;
  description: string;
}

interface BugFix {
  bug: string;
  fix: string;
}

interface AugmentChange {
  name: string;
  change: string;
}

interface ChampionChange {
  name: string;
  change: string;
}

interface Sections {
  opening_encounters?: {
    title: string;
    content: OpeningEncounter[];
  };
  hacked_encounters?: {
    title: string;
    content: HackEncounter[];
  };
  augment_changes?: {
    title: string;
    removed_augments?: string[];
    returning_augments?: string[];
    adjusted_silver?: Record<string, string>;
    adjusted_gold?: Record<string, string>;
    adjusted_prismatic?: Record<string, string>;
    other_changes?: Record<string, string>;
    content?: AugmentChange[];
  };
  emblem_changes?: {
    title: string;
    content: EmblemChange[];
  };
  cosmetics?: {
    title: string;
    content: Cosmetic[];
  };
  ranked?: {
    title: string;
    content: string;
  };
  champion_changes?: {
    title: string;
    content: ChampionChange[];
  };
  new_hacked_encounters?: {
    title: string;
    content: HackEncounter[];
  };
  hack_adjustments?: {
    title: string;
    description: string;
  };
  bug_fixes?: {
    title: string;
    content: BugFix[];
  };
  revival_info?: {
    title: string;
    content: string;
  };
  [key: string]: any;
}

interface PatchNoteData {
  title: string;
  date: string;
  overview: string;
  keyChanges: KeyChange[];
  sections: Sections;
}

interface PatchNotesData {
  [key: string]: PatchNoteData;
}

interface HackCategory {
  category: string;
  description: string;
  examples: {
    name: string;
    description: string;
  }[];
}

interface HacksData {
  description: string;
  types: HackCategory[];
}

interface Trait {
  name: string;
  description: string;
  champions?: string;
}

// Interface for props
interface PatchNoteSectionProps {
  section: string;
  data: PatchNoteData;
}

interface NavTabProps {
  title: string;
  isActive: boolean;
  onClick: () => void;
  icon?: React.ReactNode;
}

interface TimelineTabProps {
  title: string;
  isActive: boolean;
  onClick: () => void;
}

interface HackDetailsModalProps {
  show: boolean;
  onClose: () => void;
}

const TFTPatchNotes = () => {
  const [activeSection, setActiveSection] = useState<string>('overview');
  const [activePatch, setActivePatch] = useState<string>('14.4');
  const [activeTimeline, setActiveTimeline] = useState<string>('patches');
  const [showInfoModal, setShowInfoModal] = useState<boolean>(false);
  
  // Current TFT state based on official data - UPDATED FOR 14.4
  const currentTFTData: TFTCurrentData = {
    currentSet: "Set 14",
    currentSetName: "Cyber City",
    currentPatch: "14.4",
    releaseDate: "April 2, 2025",
    nextSetDate: "July 30, 2025",
    nextSetName: "Set 15",
    nextPatchDate: "May 29, 2025",
    nextPatchName: "14.5"
  };
  
  // Timeline Data - Official 2025 TFT Schedule
  const timelineData: TimelineData = {
    patches: [
      { 
        date: "April 2, 2025", 
        name: "14.1", 
        type: "Major", 
        description: "Set 14: Cyber City release", 
        highlights: ["New Cyber City theme", "Introduction of Hacks mechanic", "New traits and champions"]
      },
      { 
        date: "April 16, 2025", 
        name: "14.2", 
        type: "Balance", 
        description: "First balance patch for Cyber City", 
        highlights: ["Resource adjustment for Hacks", "Champion balance adjustments", "Double Up updates"]
      },
      { 
        date: "May 1, 2025", 
        name: "14.3", 
        type: "Balance", 
        description: "Further Cyber City balance updates", 
        highlights: ["New hacked encounters", "PVE adjustments", "Kobuko rework"]
      },
      { 
        date: "May 14, 2025", 
        name: "14.4", 
        type: "Content", 
        description: "Revival: Remix Rumble + Balance", 
        highlights: ["Set 10 Revival - Remix Rumble", "Balance adjustments", "Loot reductions"]
      },
      { 
        date: "May 29, 2025", 
        name: "14.5", 
        type: "Balance", 
        description: "Mid-set balance update", 
        highlights: ["Cosmetics simplification", "UX improvements", "Item reworks"]
      },
      { 
        date: "June 12, 2025", 
        name: "14.6", 
        type: "Balance", 
        description: "Final major balance patch", 
        highlights: ["Final trait adjustments", "Champion rebalancing"]
      },
      { 
        date: "June 26, 2025", 
        name: "14.7", 
        type: "Balance", 
        description: "Pre-Set 15 adjustment patch", 
        highlights: ["Final balance tweaks", "Preparation for Set 15"]
      },
      { 
        date: "July 16, 2025", 
        name: "14.8", 
        type: "Fun", 
        description: "Cyber City finale patch", 
        highlights: ["Fun adjustments", "PBE release of Set 15"]
      },
      { 
        date: "July 30, 2025", 
        name: "15.1", 
        type: "Major", 
        description: "Set 15 release", 
        highlights: ["New set theme", "New mechanics and champions", "Ranked reset"]
      },
      { 
        date: "November 19, 2025", 
        name: "16.1", 
        type: "Major", 
        description: "Set 16 release", 
        highlights: ["New set theme", "New mechanics", "Ranked reset"]
      }
    ],
    tournaments: [
      {
        name: "TFT Open Championship 11: Cyber League - Week 1",
        date: "May 12-14, 2025",
        region: "Global",
        importance: "Major",
        prizePool: "$50,000",
        description: "First week of the Cyber League championship series"
      },
      {
        name: "TFT Open Championship 11: Cyber League - Week 2",
        date: "May 20-22, 2025",
        region: "Global",
        importance: "Major",
        prizePool: "$50,000",
        description: "Second week of competitive Cyber League matches"
      },
      {
        name: "Cyber City: EMEA Tactician's Cup #2",
        date: "May 24-26, 2025",
        region: "EMEA",
        importance: "Regional",
        prizePool: "$30,000",
        description: "Second Tactician's Cup for the EMEA region"
      },
      {
        name: "Cyber City: APAC Tactician's Cup #2",
        date: "May 24-26, 2025",
        region: "APAC",
        importance: "Regional",
        prizePool: "$30,000",
        description: "Second Tactician's Cup for the APAC region"
      },
      {
        name: "Cyber City: Americas Tactician's Cup #2",
        date: "May 24-26, 2025",
        region: "Americas",
        importance: "Regional",
        prizePool: "$30,000",
        description: "Second Tactician's Cup for the Americas region"
      },
      {
        name: "TFT Open Championship 11: Cyber League - Week 3",
        date: "May 26-28, 2025",
        region: "Global",
        importance: "Major",
        prizePool: "$50,000",
        description: "Third week of the Cyber League championship"
      },
      {
        name: "TFT Open Championship 11: Cyber League - Main Stage",
        date: "May 30-31, 2025",
        region: "Global",
        importance: "Major",
        prizePool: "$100,000",
        description: "Final stage of the Cyber League championship"
      },
      {
        name: "Cyber City: EMEA Tactician's Cup #3",
        date: "June 20-22, 2025",
        region: "EMEA",
        importance: "Regional",
        prizePool: "$30,000",
        description: "Third Tactician's Cup for the EMEA region"
      },
      {
        name: "Cyber City: APAC Tactician's Cup #3",
        date: "June 20-22, 2025",
        region: "APAC",
        importance: "Regional",
        prizePool: "$30,000",
        description: "Third Tactician's Cup for the APAC region"
      },
      {
        name: "Esports World Cup 2025 - TFT",
        date: "August 11-15, 2025",
        region: "Global",
        importance: "Major",
        prizePool: "$500,000",
        description: "TFT's debut at the Esports World Cup"
      },
      {
        name: "TFT Paris Open 2025",
        date: "December 2025",
        region: "Global",
        importance: "Championship",
        prizePool: "$308,500",
        description: "TFT's largest global open tournament of the year"
      }
    ],
    sets: [
      {
        name: "Set 14: Cyber City",
        startDate: "April 2, 2025",
        endDate: "July 29, 2025",
        theme: "Cyberpunk/street factions",
        mechanic: "Hacks",
        description: "Neon-lit cyberpunk aesthetic with warring factions"
      },
      {
        name: "Set 15",
        startDate: "July 30, 2025",
        endDate: "November 18, 2025",
        theme: "TBA",
        mechanic: "TBA",
        description: "Next major set, theme is anime-style fighting tournament"
      },
      {
        name: "Set 16",
        startDate: "November 19, 2025",
        endDate: "March 2026",
        theme: "TBA",
        mechanic: "TBA",
        description: "Final set of 2025, theme to be announced"
      }
    ],
    revivals: [
      {
        name: "Remix Rumble (Set 10)",
        startDate: "May 14, 2025",
        endDate: "July 29, 2025",
        description: "Revival of the music-themed Set 10 with updated bag sizes, new augments, and Cyber City crossover elements"
      }
    ]
  };
  
  // Patch Notes Data - UPDATED with accurate 14.4 info
  const patchNotesData: PatchNotesData = {
    "14.1": {
      title: "Set 14: Cyber City Launch",
      date: "April 2, 2025",
      overview: "Welcome to our next set: Cyber City, where the streets are up for grabs as you roll, explode, and hack your way to control! This update introduces the new Hacks mechanic, Cyber City champions and traits, and system-wide changes.",
      keyChanges: [
        {
          title: "New Set Mechanic: Hacks",
          description: "Benevolent Hackers have infiltrated TFT's core systems to your benefit! Hacks will alter each game in a variety of ways, affecting how core systems such as Augments, the Shop, or Items function. These Hacks will always be beneficial and will impact all players at the same power level, just in slightly different ways. You'll see two to five Hacks each game."
        },
        {
          title: "PvE Rounds Changes",
          description: "PvE (non-player combat) rounds have been taken over by Mechas! So long, Krug, hello, Robo-dude."
        },
        {
          title: "Emblem Improvements",
          description: "For the first time in TFT history, Emblems now provide bonuses on top of making a champion a specific trait. For example, Bastion Emblem grants 10% of Armor and Magic Resistance as Ability Power."
        },
        {
          title: "Augment Overhaul",
          description: "With a new roster and hacks mixing things up, we're removing some Augments that are either roster dependent, interfere too much with hacks, or just need to be vaulted. We're also welcoming back some old favorites as Black Market Augments."
        }
      ],
      sections: {
        opening_encounters: {
          title: "Opening Encounters",
          content: [
            {
              character: "Annie",
              effect: "Annie changes all Augments to Gold tier this game.",
              chance: "10.0%"
            },
            {
              character: "Zac",
              effect: "Zac's virus turns all the Augments Prismatic.",
              chance: "5.0%"
            },
            {
              character: "Aurora",
              effect: "Aurora swaps the last Augment to Prismatic this game.",
              chance: "5.0%"
            },
            {
              character: "Aurora",
              effect: "Aurora swaps the first Augment to Prismatic this game.",
              chance: "6.0%"
            },
            {
              character: "Neeko",
              effect: "Neeko transforms all the monsters into crabs that drop bonus loot, but crabs on Stage 5+ are SUPER DEADLY.",
              chance: "2.5%"
            },
            {
              character: "Urgot",
              effect: "Urgot scrounges up some loot from a highly varied pool each stage.",
              chance: "4.0%"
            },
            {
              character: "Garen",
              effect: "Garen summons a trainer golem with 3 Emblems attached.",
              chance: "4.0%"
            }
          ]
        },
        ranked: {
          title: "Ranked Changes",
          content: "When Cyber City goes live in your region, you can start climbing. Depending on your rank in the previous set, you will start anywhere from Iron II to Silver IV. This is true for both Double Up and Standard ranked. You will get 5 provisional matches after the reset."
        }
      }
    },
    "14.2": {
      title: "First Cyber City Balance Patch",
      date: "April 16, 2025",
      overview: "Welcome to our first patch of Cyber City! Balance issues experienced are part of the Cyber City hacker aesthetic! If only it were that easy… Patch 14.2 is our first big balance patch of the set. We're focused on stabilizing the meta with number adjustments, saving reworks or major adjustments for 14.3.",
      keyChanges: [
        {
          title: "Resource Adjustments",
          description: "Cyber City is a resource-rich techno metropolis thanks to the benevolent hackers injecting the streets with econ from orbs and hacked Augments. We're cutting down on the overall gold from Hacks to make sure games don't feel too resource-inflated."
        },
        {
          title: "Champion Augment Adjustments",
          description: "Our Silver Champion Augments have released a bit on the weak side, so we're making adjustments to improve their performance."
        },
        {
          title: "Double Up Changes",
          description: "More options for Gift Armories were added. Slightly reduced the amount of gold earned from PVE rounds."
        },
        {
          title: "Mobile Updates",
          description: "You can now add friends with the tap of a button (a new button) while in lobby on Mobile!"
        }
      ],
      sections: {
        hack_adjustments: {
          title: "Hack Adjustments",
          description: "Reduced the overall gold provided by various Hack mechanics to prevent resource inflation that was favoring fast level 9 strategies."
        },
        augment_changes: {
          title: "Augment Changes",
          content: [
            {
              name: "Adaptive Strikes (Jax)",
              change: "Base 3rd Strike Damage: 110/165/250 ⇒ 120/180/270"
            },
            {
              name: "Chemtech Overdrive (Black Market)",
              change: "no longer appears on 2-1"
            },
            {
              name: "Double Trouble (Black Market)",
              change: "Bugfix: Starring up the unit to 3* while on the bench, properly grants the 2* copy of the unit."
            },
            {
              name: "Life Long Learning (Black Market)",
              change: "HP Gained each turn: 1.5% ⇒ 2%"
            },
            {
              name: "Scoped Weapons (Black Market)",
              change: "AS Gained: 18% ⇒ 25%"
            }
          ]
        }
      }
    },
    "14.3": {
      title: "Cyber City Balance Updates",
      date: "May 1, 2025",
      overview: "Patch 14.3 brings new Hacks, Opening Encounters, balance changes, and a rework for Kobuko. This update continues to refine the Cyber City experience based on player feedback and data analysis.",
      keyChanges: [
        {
          title: "New Hacked Encounters",
          description: "We've added several new Hacked encounters to increase variety and strategic options."
        },
        {
          title: "Kobuko Rework",
          description: "Kobuko has been reworked to better balance his performance across different team compositions."
        },
        {
          title: "Balance Adjustments",
          description: "Various champion and trait balance adjustments to improve overall game health."
        }
      ],
      sections: {
        champion_changes: {
          title: "Champion Changes",
          content: [
            {
              name: "Aphelios",
              change: "With Golden Ox (6) in check, we're able to distribute power into the still-sad moon lad. Maybe we'll even catch a smile from an Aphelios carry who wants nothing more than to hold three items."
            },
            {
              name: "Cho'Gath",
              change: "Our Cho'Gath changes last patch had him land weaker than intended. With a mana buff and a better AP ratio on his HP stacking, expect to see this Boom Bot making a sizable impact."
            },
            {
              name: "Aurora",
              change: "With safe damage and the ability to throw in tanks throughout the fight, Aurora's been our best 5-cost for a while, especially at two stars. We're reducing some of her damage."
            },
            {
              name: "Viego",
              change: "A fully itemized Viego empowered by Golden Ox could wipe entire boards. We're making adjustments to his power level."
            },
            {
              name: "Kobuko",
              change: "Complete rework to better balance his performance."
            }
          ]
        },
        new_hacked_encounters: {
          title: "New Hacked Encounters",
          content: [
            {
              type: "Lucky Shop",
              effect: "First shop of select rounds will contain units tailored to your team.",
              chance: "Once per stage"
            },
            {
              type: "Tome Carousel",
              effect: "Carousels can appear with Tome of Traits. Use the Tome of Traits to select an Emblem partially tailored to your comp.",
              chance: "Variable"
            },
            {
              type: "Double PVE",
              effect: "After a PvE round, you'll immediately face an exact copy of it, rewarding the exact same loot.",
              chance: "Variable"
            },
            {
              type: "Group Investing",
              effect: "After every Carousel, players choose to split a pot of gold or increase the total amount for future rounds.",
              chance: "Variable"
            },
            {
              type: "Reroll Subscription",
              effect: "At the start of every stage, gain free Shop rerolls, increasing over the game.",
              chance: "Variable"
            },
            {
              type: "Three Champions",
              effect: "Start the game with a two-star 2-cost champion. Every player gets a unique one.",
              chance: "Variable"
            }
          ]
        }
      }
    },
    "14.4": {
      title: "Revival: Remix Rumble + Balance",
      date: "May 14, 2025",
      overview: "Balance and RNGolem, 14.4 is Cyber City's return to the natural order of things. At the start of Cyber City, Hacks provided enough loot to typically fully itemize two carries and a primary tank. We've since lowered the amount of total loot you get, but we're still seeing games have ever-so-slightly too much on average. This patch also brings the return of Remix Rumble!",
      keyChanges: [
        {
          title: "Set Revival: Remix Rumble",
          description: "From patch 14.4 (May 14th) to July 29th, Remix Rumble returns with a couple of updates to mix things up for longtime fans and new DJs alike! The Revival brings back your favorite music festival lineup with K/DA, True Damage, Pentakill, Heartsteel, DJ Sona, Maestro Jhin, and Jazz Bard alongside the Headliner mechanic."
        },
        {
          title: "Loot Reductions",
          description: "With our loot changes in 14.4 you can expect to see about 1 less Item Component and in a few cases 1 less Silver/Blue Loot Orb. The most extreme example of the above is Scuttle Puddle and Crab Rave."
        },
        {
          title: "Revival Features",
          description: "Updated bag sizes for easier rerolling, new Opening Encounters (Ahri, Akali, Zac), and Cyber City Hacks integrated into the revival experience."
        },
        {
          title: "Cosmetics Changes Coming",
          description: "Starting in patch TFT14.5 (patch after this), we'll simplify TFT's cosmetic rarity tiers to ensure they're straightforward and consistent."
        }
      ],
      sections: {
        revival_info: {
          title: "Remix Rumble Revival Details",
          content: "Updated bag (unit pool) sizes: 1-costs: 50 copies, 2-costs: 40 copies, 3-costs: 30 copies, 4-costs: 12 copies, 5-costs: 10 copies. Unlike the Festival of Beasts Revival (which had personal bags), Revival: Remix Rumble returns to a shared pool, but with larger bag sizes for easier rerolling."
        },
        opening_encounters: {
          title: "New Opening Encounters (Revival)",
          content: [
            {
              character: "Ahri",
              effect: "Headliners appear in your shop as if you are 1 level higher.",
              chance: "Revival only"
            },
            {
              character: "Akali",
              effect: "Headliner champions grant plus-one to another one of their traits.",
              chance: "Revival only"
            },
            {
              character: "Zac",
              effect: "Cyber City is invading the Remix Rumble Revival. Watch out for Hacks!",
              chance: "Revival only"
            }
          ]
        },
        hack_adjustments: {
          title: "Loot Adjustments",
          description: "Reduced total component drops by approximately 1 item component per game. Scuttle Puddle and Crab Rave encounters reduced their total component drops by two."
        }
      }
    },
    "14.5": {
      title: "Cosmetics Simplification & Item Reworks",
      date: "May 29, 2025",
      overview: "With Patch 14.5, we're updating, replacing, and reworking several items to better fit their fantasy. We're also simplifying TFT's cosmetic rarity tiers to ensure they're straightforward and consistent.",
      keyChanges: [
        {
          title: "Item Reworks",
          description: "Several items are being updated, replaced, and reworked to better fit their intended fantasy and improve gameplay balance."
        },
        {
          title: "Cosmetics Tier Simplification",
          description: "Little Legends released prior to patch 14.5 in the Rare and Epic tiers will be combined into the new Standard tier. Non-upgradable Little Legends and Booms are designated as three-star content."
        },
        {
          title: "Mid-Set Balance",
          description: "Mid-set balance adjustments to keep the competitive meta healthy and diverse."
        }
      ],
      sections: {}
    }
  };
  
  // Set 14 Mechanics - Hack System Details
  const hacksData: HacksData = {
    description: "In Cyber City, Hacks will alter each game in a variety of ways, affecting how core systems such as Augments, the Shop, or Items function. These Hacks will always be beneficial and will impact all players at the same power level, just in slightly different ways. You'll typically see about three Hacks each game.",
    types: [
      {
        category: "Augment Hacks",
        description: "Hacks that affect the Augment system, including timing, quality, and options.",
        examples: [
          {
            name: "Fourth Augment",
            description: "You will be able to select a fourth Augment later on in the game, bringing you to four Augments in total."
          },
          {
            name: "Augment Timing",
            description: "Augments appear at random rounds earlier than normal (never later)."
          },
          {
            name: "Black Market Augments",
            description: "Special pool of powerful Augments from previous sets, only available from a Hacked Augment slot."
          },
          {
            name: "1v2 Augment Choice",
            description: "Choose between one powerful Gold Augment or TWO Silver Augments."
          }
        ]
      },
      {
        category: "Shop Hacks",
        description: "Hacks that modify how the shop functions and what appears in it.",
        examples: [
          {
            name: "Lucky Shops",
            description: "Shops are more lucky, containing units tailored to your team. Affects all players at an equal rate, once per stage."
          },
          {
            name: "Two-Star Shops",
            description: "Occasionally, a hacked unit will appear at two stars in your shop instead of the usual one-star."
          }
        ]
      },
      {
        category: "Carousel & Item Hacks",
        description: "Hacks that affect carousel offerings and item systems.",
        examples: [
          {
            name: "Tailored Items",
            description: "Each unit on the carousel will have two completed items attached, both from the unit's recommended items list."
          },
          {
            name: "Anvil Carousel",
            description: "A carousel with anvils in place of champs and items."
          },
          {
            name: "Treasure Dragon",
            description: "At Stage 4-7 choose from a rollable package of loot. Augments can appear during the Treasure Armory."
          }
        ]
      },
      {
        category: "Loot Hacks",
        description: "Hacks that provide special loot or modify existing loot systems.",
        examples: [
          {
            name: "Hacked Eggs",
            description: "Loot Eggs with power based on how long they take to hatch. Can choose from short, medium, and long variations."
          },
          {
            name: "Tactician Health",
            description: "A small amount of Tactician Health has a chance to appear in some Hacked Loot Orbs."
          },
          {
            name: "Unstable Item Components",
            description: "Available in Hacked Loot Orbs, these components transform into a different item component each round."
          }
        ]
      },
      {
        category: "Game Mechanic Hacks",
        description: "Hacks that change broader game mechanics or introduce unique decision points.",
        examples: [
          {
            name: "Take it or Split it?",
            description: "Opens an Armory presenting two choices: take 10 gold or split 30 gold from whoever chooses the latter."
          },
          {
            name: "Group Investing",
            description: "After every Carousel, players choose to split a pot of gold or increase the total amount for future rounds."
          },
          {
            name: "Sentinel Armory",
            description: "Pick one of three Sentinels with three items each: Tank, Frontline Attacker, or Backline Sentinel."
          }
        ]
      }
    ]
  };
  
  // Key Traits from Set 14
  const traitData: Trait[] = [
    {
      name: "Anima Squad",
      description: "Anima Squad champions gain Armor, Magic Resist, and their weapons gain bonus effects."
    },
    {
      name: "Cyberboss",
      description: "Your strongest Cyberboss upgrades to its final form and gains Health, Ability Power, and its ability hits more enemies.",
      champions: "Vi (1g), LeBlanc (2g), Draven (3g), Galio (3g), Zed (4g)"
    },
    {
      name: "Cypher",
      description: "Gain Intel by losing combat, increased for loss streaks. You may trade Intel for loot once, after which Cypher champions gain Attack Damage and Ability Power."
    },
    {
      name: "Divinicorp",
      description: "Divinicorp champions grant unique stats to your team, increased for each Divinicorp in play."
    },
    {
      name: "Exotech",
      description: "Gain unique Exotech items that can only be equipped by Exotech champions, granting Health and Attack Speed."
    },
    {
      name: "Street Demon",
      description: "Street Demon tags areas on the board and buffs units who stand inside of them."
    }
  ];
  
  // Component to display patch note sections
  const PatchNoteSection = ({ section, data }: PatchNoteSectionProps) => {
    if (!data || !data.sections || !data.sections[section]) return null;
    
    const sectionData = data.sections[section];
    
    // Different renders based on section type
    if (section === 'opening_encounters' || section === 'hacked_encounters') {
      return (
        <div className="mb-6 animate-fadeIn">
          <h3 className="text-xl font-bold text-gold mb-4">{sectionData.title}</h3>
          <div className="bg-void-core/25 backdrop-blur-sm rounded-lg p-4">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {sectionData.content.map((encounter: OpeningEncounter, index: number) => (
                <div key={index} className="bg-void-core/15 rounded p-3 flex items-start border border-gold/20">
                  <div className="mr-3 font-medium text-gold-light min-w-20">
                    {encounter.character || encounter.type}
                  </div>
                  <div className="flex-1">
                    <div className="text-sm mb-1 text-cream">{encounter.effect}</div>
                    <div className="text-xs text-cream/70">Chance: {encounter.chance}</div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      );
    }
    
    if (section === 'augment_changes') {
      return (
        <div className="mb-6 animate-fadeIn">
          <h3 className="text-xl font-bold text-gold mb-4">{sectionData.title}</h3>
          
          {/* Removed Augments */}
          {sectionData.removed_augments && sectionData.removed_augments.length > 0 && (
            <div className="mb-4">
              <h4 className="text-lg font-medium text-gold mb-2">Removed Augments</h4>
              <div className="bg-void-core/25 backdrop-blur-sm rounded-lg p-4">
                <div className="flex flex-wrap gap-2">
                  {sectionData.removed_augments.map((augment: string, index: number) => (
                    <span key={index} className="bg-void-core/15 px-2 py-1 rounded text-xs border border-gold/30 text-cream">
                      {augment}
                    </span>
                  ))}
                </div>
              </div>
            </div>
          )}
          
          {/* Returning Augments */}
          {sectionData.returning_augments && sectionData.returning_augments.length > 0 && (
            <div className="mb-4">
              <h4 className="text-lg font-medium text-gold mb-2">Returning Augments</h4>
              <div className="bg-void-core/25 backdrop-blur-sm rounded-lg p-4">
                <div className="flex flex-wrap gap-2">
                  {sectionData.returning_augments.map((augment: string, index: number) => (
                    <span key={index} className="bg-void-core/15 px-2 py-1 rounded text-xs border border-gold/30 text-cream">
                      {augment}
                    </span>
                  ))}
                </div>
              </div>
            </div>
          )}
          
          {/* Other Changes */}
          {sectionData.other_changes && Object.keys(sectionData.other_changes).length > 0 && (
            <div className="mb-4">
              <h4 className="text-lg font-medium text-gold mb-2">Other Augment Changes</h4>
              <div className="bg-void-core/25 backdrop-blur-sm rounded-lg p-4">
                <div className="space-y-2">
                  {Object.entries(sectionData.other_changes as Record<string, string>).map(([name, change], index) => (
                    <div key={index} className="bg-void-core/15 rounded p-3 border border-gold/20">
                      <div className="font-medium text-gold-light mb-1">{name}</div>
                      <div className="text-sm text-cream">{change}</div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          )}
          
          {/* Content (for 14.2+) */}
          {sectionData.content && sectionData.content.length > 0 && (
            <div className="mb-4">
              <h4 className="text-lg font-medium text-gold mb-2">Augment Adjustments</h4>
              <div className="bg-void-core/25 backdrop-blur-sm rounded-lg p-4">
                <div className="space-y-2">
                  {sectionData.content.map((augment: AugmentChange, index: number) => (
                    <div key={index} className="bg-void-core/15 rounded p-3 border border-gold/20">
                      <div className="font-medium text-gold-light mb-1">{augment.name}</div>
                      <div className="text-sm text-cream">{augment.change}</div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          )}
        </div>
      );
    }
    
    if (section === 'emblem_changes') {
      return (
        <div className="mb-6 animate-fadeIn">
          <h3 className="text-xl font-bold text-gold mb-4">{sectionData.title}</h3>
          <div className="bg-void-core/25 backdrop-blur-sm rounded-lg p-4">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {sectionData.content.map((emblem: EmblemChange, index: number) => (
                <div key={index} className="bg-void-core/15 rounded p-3 border border-gold/20">
                  <div className="font-medium text-gold-light mb-1">{emblem.name}</div>
                  <div className="text-sm text-cream">{emblem.effect}</div>
                </div>
              ))}
            </div>
          </div>
        </div>
      );
    }
    
    if (section === 'cosmetics') {
      return (
        <div className="mb-6 animate-fadeIn">
          <h3 className="text-xl font-bold text-gold mb-4">{sectionData.title}</h3>
          <div className="bg-void-core/25 backdrop-blur-sm rounded-lg p-4">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {sectionData.content.map((cosmetic: Cosmetic, index: number) => (
                <div key={index} className="bg-void-core/15 rounded p-3 border border-gold/20">
                  <div className="font-medium text-gold-light mb-1">{cosmetic.name}</div>
                  <div className="text-sm text-cream">{cosmetic.description}</div>
                </div>
              ))}
            </div>
          </div>
        </div>
      );
    }
    
    if (section === 'ranked') {
      return (
        <div className="mb-6 animate-fadeIn">
          <h3 className="text-xl font-bold text-gold mb-4">{sectionData.title}</h3>
          <div className="bg-void-core/25 backdrop-blur-sm rounded-lg p-4">
            <div className="text-sm text-cream">{sectionData.content}</div>
          </div>
        </div>
      );
    }
    
    if (section === 'champion_changes') {
      return (
        <div className="mb-6 animate-fadeIn">
          <h3 className="text-xl font-bold text-gold mb-4">{sectionData.title}</h3>
          <div className="bg-void-core/25 backdrop-blur-sm rounded-lg p-4">
            <div className="space-y-3">
              {sectionData.content.map((champion: ChampionChange, index: number) => (
                <div key={index} className="bg-void-core/15 rounded p-3 border border-gold/20">
                  <div className="font-medium text-gold-light mb-1">{champion.name}</div>
                  <div className="text-sm text-cream">{champion.change}</div>
                </div>
              ))}
            </div>
          </div>
        </div>
      );
    }
    
    if (section === 'new_hacked_encounters') {
      return (
        <div className="mb-6 animate-fadeIn">
          <h3 className="text-xl font-bold text-gold mb-4">{sectionData.title}</h3>
          <div className="bg-void-core/25 backdrop-blur-sm rounded-lg p-4">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {sectionData.content.map((encounter: HackEncounter, index: number) => (
                <div key={index} className="bg-void-core/15 rounded p-3 flex items-start border border-gold/20">
                  <div className="mr-3 font-medium text-gold-light min-w-24">{encounter.type}</div>
                  <div className="flex-1">
                    <div className="text-sm mb-1 text-cream">{encounter.effect}</div>
                    <div className="text-xs text-cream/70">Frequency: {encounter.chance}</div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      );
    }
    
    if (section === 'hack_adjustments') {
      return (
        <div className="mb-6 animate-fadeIn">
          <h3 className="text-xl font-bold text-gold mb-4">{sectionData.title}</h3>
          <div className="bg-void-core/25 backdrop-blur-sm rounded-lg p-4">
            <div className="text-sm text-cream">{sectionData.description}</div>
          </div>
        </div>
      );
    }
    
    if (section === 'bug_fixes') {
      return (
        <div className="mb-6 animate-fadeIn">
          <h3 className="text-xl font-bold text-gold mb-4">{sectionData.title}</h3>
          <div className="bg-void-core/25 backdrop-blur-sm rounded-lg p-4">
            <ul className="space-y-2">
              {sectionData.content.map((bugfix: BugFix, index: number) => (
                <li key={index} className="flex items-start">
                  <div className="w-2 h-2 rounded-full bg-gold mt-1.5 mr-2"></div>
                  <div className="text-cream">
                    <span className="font-medium">{bugfix.bug}</span>: {bugfix.fix}
                  </div>
                </li>
              ))}
            </ul>
          </div>
        </div>
      );
    }
    
    if (section === 'revival_info') {
      return (
        <div className="mb-6 animate-fadeIn">
          <h3 className="text-xl font-bold text-gold mb-4">{sectionData.title}</h3>
          <div className="bg-void-core/25 backdrop-blur-sm rounded-lg p-4">
            <div className="text-sm text-cream">{sectionData.content}</div>
          </div>
        </div>
      );
    }
    
    return null;
  };
  
  // Navigation tabs for different sections
  const NavTab = ({ title, isActive, onClick, icon }: NavTabProps) => {
    return (
      <button
        className={`px-4 py-2 rounded-lg text-sm font-medium transition-all flex items-center ${
          isActive 
            ? 'bg-void-core/40 text-gold shadow-md border border-gold/30' 
            : 'bg-void-core/20 text-cream/80 hover:bg-void-core/30 border border-gold/10 hover:border-gold/20'
        }`}
        onClick={onClick}
      >
        {icon && <div className={`mr-2 ${isActive ? 'text-gold' : 'text-cream/70'}`}>{icon}</div>}
        {title}
      </button>
    );
  };
  
  // Timeline section tabs
  const TimelineTab = ({ title, isActive, onClick }: TimelineTabProps) => {
    return (
      <button
        className={`px-6 py-3 text-sm font-medium transition-all border-b-2 ${
          isActive 
            ? 'border-gold text-gold' 
            : 'border-transparent text-cream/70 hover:text-cream hover:border-gold/30'
        }`}
        onClick={onClick}
      >
        {title}
      </button>
    );
  };
  
  // Current Set Overview section
  const CurrentSetOverview = () => (
    <div className="animate-fadeIn">
      {/* Section Title - centered with gold lines */}
      <div className="mb-6">
        <div className="flex items-center justify-center">
          <div className="h-1 flex-grow bg-gradient-to-r from-transparent via-gold/20 to-gold/50 mr-3"></div>
          <div className="bg-void-core/40 backdrop-blur-md border-b-2 border-gold rounded-md px-8 py-3 inline-block shadow-sm shadow-gold/20">
            <h2 className="text-2xl font-bold text-gold text-center">Overview</h2>
          </div>
          <div className="h-1 flex-grow bg-gradient-to-l from-transparent via-gold/20 to-gold/50 ml-3"></div>
        </div>
      </div>
      
      {/* Content boxes */}
      <div className="flex flex-col md:flex-row gap-4 mb-4">
        <div className="flex-1 bg-void-core/15 backdrop-filter backdrop-blur-md rounded-lg p-4 border border-gold/20">
          <h3 className="text-lg font-semibold text-gold mb-3 flex items-center">
            <Tag size={18} className="mr-2" />
            Current Patch
          </h3>
          <div className="text-xl font-bold mb-1 text-cream">{currentTFTData.currentPatch}</div>
          <div className="text-sm text-cream/70">Released on May 14, 2025</div>
        </div>
        <div className="flex-1 bg-void-core/15 backdrop-blur-md rounded-lg p-4 border border-gold/20">
          <h3 className="text-lg font-semibold text-gold mb-3 flex items-center">
            <Calendar size={18} className="mr-2" />
            Next Patch
          </h3>
          <div className="text-xl font-bold mb-1 text-cream">{currentTFTData.nextPatchName}</div>
          <div className="text-sm text-cream/70">Coming on {currentTFTData.nextPatchDate}</div>
        </div>
        <div className="flex-1 bg-void-core/15 backdrop-blur-md rounded-lg p-4 border border-gold/20">
          <h3 className="text-lg font-semibold text-gold mb-3 flex items-center">
            <Slack size={18} className="mr-2" />
            Current Revival
          </h3>
          <div className="text-xl font-bold mb-1 text-cream">Remix Rumble</div>
          <div className="text-sm text-cream/70">May 14 - July 29, 2025</div>
        </div>
      </div>
        
      <div className="bg-void-core/15 backdrop-filter backdrop-blur-md rounded-lg p-4 border border-gold/20 mb-4">
        <h3 className="text-lg font-semibold text-gold mb-3 flex items-center">
          <Zap size={18} className="mr-2" />
          Set Mechanic: Hacks
        </h3>
        <p className="text-cream">{hacksData.description}</p>
        <div className="mt-4">
          <button 
            className="px-4 py-2 bg-void-core/30 text-gold rounded-lg text-md font-medium hover:bg-void-core/40 transition-all border border-gold/30 flex items-center"
            onClick={() => setShowInfoModal(true)}
          >
            <Info size={16} className="mr-2" />
            View Hack Details
          </button>
        </div>
      </div>
      
      <div className="bg-void-core/15 backdrop-blur-md rounded-lg p-4 border border-gold/20">
        <h3 className="text-lg font-semibold text-gold mb-3 flex items-center">
          <Puzzle size={18} className="mr-2" />
          Key Traits
        </h3>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 mt-2">
          {traitData.map((trait, index) => (
            <div key={index} className="bg-void-core/25 p-3 rounded-lg border border-gold/20">
              <div className="font-medium text-gold-light mb-1">{trait.name}</div>
              <div className="text-sm text-cream mb-1">{trait.description}</div>
              {trait.champions && (
                <div className="text-xs text-cream/70 mt-1">
                  <span className="font-medium">Champions:</span> {trait.champions}
                </div>
              )}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
  
  // Patch Notes section
  const PatchNotesSection = () => (
    <div className="animate-fadeIn">
      {/* Section Title - centered with gold lines */}
      <div className="mb-6">
        <div className="flex items-center justify-center">
          <div className="h-1 flex-grow bg-gradient-to-r from-transparent via-gold/20 to-gold/50 mr-3"></div>
          <div className="bg-void-core/40 backdrop-blur-md border-b-2 border-gold rounded-md px-8 py-3 inline-block shadow-sm shadow-gold/20">
            <h2 className="text-2xl font-bold text-gold text-center">Patch Notes</h2>
          </div>
          <div className="h-1 flex-grow bg-gradient-to-l from-transparent via-gold/20 to-gold/50 ml-3"></div>
        </div>
      </div>
      
      <div className="bg-void-core/25 backdrop-filter backdrop-blur-md rounded-lg overflow-hidden shadow-lg border border-gold/20 mb-8">
        
        <div className="px-6 py-4">
          {/* Patch selector for mobile */}
          <div className="md:hidden mb-4">
            <select 
              className="w-full p-2 bg-void-core/15 text-cream rounded-lg border border-gold/20"
              value={activePatch}
              onChange={(e) => setActivePatch(e.target.value)}
            >
              {Object.keys(patchNotesData).map(patch => (
                <option key={patch} value={patch}>Patch {patch}: {patchNotesData[patch].title}</option>
              ))}
            </select>
          </div>
          
          {/* Patch selector for desktop */}
          <div className="hidden md:flex md:flex-wrap gap-2 mb-6">
            {Object.keys(patchNotesData).map(patch => (
              <NavTab 
                key={patch}
                title={`Patch ${patch}`}
                isActive={activePatch === patch}
                onClick={() => setActivePatch(patch)}
              />
            ))}
          </div>
          
          {patchNotesData[activePatch] && (
            <>
              <div className="bg-void-core/15 backdrop-filter backdrop-blur-md rounded-lg p-6 border border-gold/20 mb-6">
                <h1 className="text-2xl font-bold text-gold mb-2">{patchNotesData[activePatch].title}</h1>
                <div className="text-sm text-cream/70 mb-4">Released on {patchNotesData[activePatch].date}</div>
                <p className="text-cream">{patchNotesData[activePatch].overview}</p>
              </div>
              
              <div className="bg-void-core/15 backdrop-blur-sm rounded-lg p-6 border border-gold/20 mb-6">
                <h2 className="text-xl font-bold text-gold mb-4">Key Changes</h2>
                <div className="space-y-4">
                  {patchNotesData[activePatch].keyChanges.map((change, index) => (
                    <div key={index} className="bg-void-core/25 rounded-lg p-4 border border-gold/20">
                      <h3 className="text-lg font-semibold text-gold-light mb-2">{change.title}</h3>
                      <p className="text-cream text-sm">{change.description}</p>
                    </div>
                  ))}
                </div>
              </div>
              
              {/* Dynamic patch note sections */}
              {patchNotesData[activePatch].sections && Object.keys(patchNotesData[activePatch].sections).map(section => (
                <PatchNoteSection 
                  key={section} 
                  section={section} 
                  data={patchNotesData[activePatch]} 
                />
              ))}
            </>
          )}
        </div>
      </div>
    </div>
  );
  
  // TFT Timeline section
const TimelineSection = () => (
  <div className="animate-fadeIn">
    {/* Section Title - centered with gold lines */}
    <div className="mb-6">
      <div className="flex items-center justify-center">
        <div className="h-1 flex-grow bg-gradient-to-r from-transparent via-gold/20 to-gold/50 mr-3"></div>
        <div className="bg-void-core/40 backdrop-blur-md border-b-2 border-gold rounded-md px-8 py-3 inline-block shadow-sm shadow-gold/20">
          <h2 className="text-2xl font-bold text-gold text-center">2025 Timeline</h2>
        </div>
        <div className="h-1 flex-grow bg-gradient-to-l from-transparent via-gold/20 to-gold/50 ml-3"></div>
      </div>
    </div>
    
    <div className="bg-void-core/25 backdrop-blur-sm rounded-lg overflow-hidden shadow-lg border border-gold/20 mb-8">
      
      {/* Replace TimelineTab with NavTab for consistent styling */}
      <div className="px-6 py-4">
        <div className="flex flex-wrap gap-2 mb-6">
          <NavTab 
            title="Patch Schedule" 
            isActive={activeTimeline === 'patches'} 
            onClick={() => setActiveTimeline('patches')}
            icon={<Calendar size={18} />}
          />
          <NavTab 
            title="Tournaments" 
            isActive={activeTimeline === 'tournaments'} 
            onClick={() => setActiveTimeline('tournaments')}
            icon={<Trophy size={18} />}
          />
          <NavTab 
            title="Sets & Revivals" 
            isActive={activeTimeline === 'sets'} 
            onClick={() => setActiveTimeline('sets')}
            icon={<Slack size={18} />}
          />
        </div>
        </div>
        
        <div className="px-6 py-4">
          {activeTimeline === 'patches' && (
            <div className="space-y-6">
              <div className="overflow-x-auto">
                <table className="min-w-full bg-void-core/15 rounded-lg overflow-hidden">
                  <thead className="bg-void-core/30">
                    <tr>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gold uppercase tracking-wider">Date</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gold uppercase tracking-wider">Patch</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gold uppercase tracking-wider">Type</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gold uppercase tracking-wider">Description</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gold uppercase tracking-wider">Highlights</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gold/10">
                    {timelineData.patches.map((patch, index) => (
                      <tr key={index} className={index % 2 === 0 ? 'bg-void-core/10' : 'bg-void-core/20'}>
                        <td className="px-4 py-3 text-sm font-medium text-cream">{patch.date}</td>
                        <td className="px-4 py-3">
                          <span className={`inline-flex items-center px-3 py-1 rounded-full text-sm font-medium ${
                            patch.type === 'Major' ? 'bg-void-core/40 text-gold' : 
                            patch.type === 'Balance' ? 'bg-void-core/30 text-gold-light' : 
                            patch.type === 'Fun' ? 'bg-void-core/30 text-gold-light' : 
                            'bg-void-core/30 text-gold-light'
                          }`}>
                            {patch.name}
                          </span>
                        </td>
                        <td className="px-4 py-3 text-sm text-cream">{patch.type}</td>
                        <td className="px-4 py-3 text-sm text-cream">{patch.description}</td>
                        <td className="px-4 py-3 text-sm">
                          <ul className="list-disc list-inside text-cream">
                            {patch.highlights.map((highlight, i) => (
                              <li key={i}>{highlight}</li>
                            ))}
                          </ul>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}
          
          {activeTimeline === 'tournaments' && (
            <div className="space-y-6">
              <div className="overflow-x-auto">
                <table className="min-w-full bg-void-core/15 rounded-lg overflow-hidden">
                  <thead className="bg-void-core/30">
                    <tr>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gold uppercase tracking-wider">Date</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gold uppercase tracking-wider">Tournament</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gold uppercase tracking-wider">Region</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gold uppercase tracking-wider">Prize Pool</th>
                      <th className="px-4 py-3 text-left text-xs font-medium text-gold uppercase tracking-wider">Description</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gold/10">
                    {timelineData.tournaments.map((tournament, index) => (
                      <tr key={index} className={index % 2 === 0 ? 'bg-void-core/10' : 'bg-void-core/20'}>
                        <td className="px-4 py-3 text-sm font-medium text-cream">{tournament.date}</td>
                        <td className="px-4 py-3">
                          <span className={`text-sm font-medium ${
                            tournament.importance === 'Championship' ? 'text-gold' : 
                            tournament.importance === 'Major' ? 'text-gold-light' : 
                            'text-gold-light'
                          }`}>
                            {tournament.name}
                          </span>
                        </td>
                        <td className="px-4 py-3">
                          <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                            tournament.region === 'Global' ? 'bg-void-core/40 text-gold' : 
                            tournament.region === 'EMEA' ? 'bg-void-core/30 text-gold-light' : 
                            tournament.region === 'APAC' ? 'bg-void-core/30 text-gold-light' : 
                            'bg-void-core/30 text-gold-light'
                          }`}>
                            {tournament.region}
                          </span>
                        </td>
                        <td className="px-4 py-3 text-sm text-gold font-medium">{tournament.prizePool}</td>
                        <td className="px-4 py-3 text-sm text-cream">{tournament.description}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}
          
          {activeTimeline === 'sets' && (
            <div className="space-y-8">
              <div>
                <h3 className="text-xl font-bold text-gold mb-4">Coming in 2025</h3>
                <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                  {timelineData.sets.map((set, index) => (
                    <div key={index} className="bg-void-core/15 rounded-lg overflow-hidden border border-gold/20">
                      <div className={`p-4 ${
                        index === 0 ? 'bg-gradient-to-r from-void-core/30 to-void-core/20' : 
                        index === 1 ? 'bg-gradient-to-r from-void-core/30 to-void-core/20' : 
                        'bg-gradient-to-r from-void-core/30 to-void-core/20'
                      }`}>
                        <h4 className="text-lg font-bold text-gold">{set.name}</h4>
                      </div>
                      <div className="p-4">
                        <div className="mb-3">
                          <span className="text-cream/70 text-sm">Dates:</span>
                          <div className="text-cream font-medium">{set.startDate} - {set.endDate}</div>
                        </div>
                        <div className="mb-3">
                          <span className="text-cream/70 text-sm">Theme:</span>
                          <div className="text-cream font-medium">{set.theme}</div>
                        </div>
                        <div className="mb-3">
                          <span className="text-cream/70 text-sm">Set Mechanic:</span>
                          <div className={`text-cream font-medium ${set.mechanic === 'TBA' ? 'text-cream/50' : ''}`}>
                            {set.mechanic}
                          </div>
                        </div>
                        <div>
                          <span className="text-cream/70 text-sm">Description:</span>
                          <div className="text-cream text-sm mt-1">{set.description}</div>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
              
              <div>
                <h3 className="text-xl font-bold text-gold mb-4">Set Revivals</h3>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  {timelineData.revivals.map((revival, index) => (
                    <div key={index} className="bg-void-core/15 rounded-lg overflow-hidden border border-gold/20">
                      <div className="bg-gradient-to-r from-void-core/30 to-void-core/20 p-4">
                        <h4 className="text-lg font-bold text-gold">{revival.name}</h4>
                      </div>
                      <div className="p-4">
                        <div className="mb-3">
                          <span className="text-cream/70 text-sm">Dates:</span>
                          <div className="text-cream font-medium">{revival.startDate} - {revival.endDate}</div>
                        </div>
                        <div>
                          <span className="text-cream/70 text-sm">Description:</span>
                          <div className="text-cream text-sm mt-1">{revival.description}</div>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
  
  // Modal for Hack System Details
  const HackDetailsModal = ({ show, onClose }: HackDetailsModalProps) => {
    if (!show) return null;
    
    return (
      <div className="fixed inset-0 bg-void-core bg-opacity-50 z-50 flex items-center justify-center p-4 animate-fadeIn backdrop-filter">
        <div className="bg-void-core/30 backdrop-blur-md rounded-lg max-w-4xl w-full max-h-[90vh] overflow-y-auto border border-gold/20 shadow-xl">
          <div className="sticky top-0 bg-gradient-to-r from-void-core/30 to-void-core/20 px-6 py-4 flex justify-between items-center border-b border-gold/20 backdrop-filter backdrop-blur-sm">
            <h2 className="text-2xl font-bold text-gold flex items-center">
              <Cpu className="mr-2" />
              Set 14 Mechanic: Hacks System
            </h2>
            <button 
              className="p-2 rounded-full bg-void-core/40 text-cream hover:bg-void-core/60 hover:text-white transition-all"
              onClick={onClose}
            >
              <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>
          
          <div className="px-6 py-4">
            <p className="text-cream mb-6">{hacksData.description}</p>
            
            <div className="space-y-6">
              {hacksData.types.map((type, index) => (
                <div key={index} className="bg-void-core/20 rounded-lg p-5 border border-gold/20">
                  <h3 className="text-xl font-bold text-gold mb-3">{type.category}</h3>
                  <p className="text-cream mb-4">{type.description}</p>
                  
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    {type.examples.map((example, i) => (
                      <div key={i} className="bg-void-core/30 rounded-lg p-4 border border-gold/20">
                        <div className="font-medium text-gold-light mb-2">{example.name}</div>
                        <div className="text-sm text-cream">{example.description}</div>
                      </div>
                    ))}
                  </div>
                </div>
              ))}
            </div>
          </div>
          
          <div className="bg-void-core/20 px-6 py-4 flex justify-end border-t border-gold/20">
            <button
              className="px-4 py-2 bg-void-core/30 text-gold rounded-lg text-sm font-medium hover:bg-void-core/40 transition-all border border-gold/30"
              onClick={onClose}
            >
              Close
            </button>
          </div>
        </div>
      </div>
    );
  };
  
  return (
    <Layout title="News">

      <div className="container mx-auto py-8">
        {/* Main Banner with Navigation - Using homepage style background */}
        <div className="relative mb-8 overflow-hidden rounded-lg border border-gold/20 shadow-lg">
          {/* Gradient background layer */}
          <div className="absolute inset-0 bg-gradient-to-r from-eclipse-shadow to-void-core opacity-90 z-0"></div>
          
          {/* Image background layer */}
          <div className="absolute inset-0 bg-[url('/assets/app/learn_banner.jpg')] bg-cover bg-center opacity-20 z-0 rounded-xl"></div>
          
          {/* Subtle border glow - optional, from homepage */}
          <div className="absolute inset-0 rounded-xl border border-solar-flare/30 z-10"></div>
          
          {/* Content container */}
          <div className="relative z-20 p-5">
            <div className="flex flex-col md:flex-row justify-between items-start md:items-center mb-4">
              <div>
                <h1 className="text-3xl font-bold text-gold mb-1">
                  Set 14: <span className="text-gold-light">Cyber City</span> News
                </h1>
                <p className="text-cream">Stay updated with the latest patches and the events to come</p>
              </div>
              <div className="flex mt-3 md:mt-0 space-x-4">
                <div className="bg-void-core/50 backdrop-filter backdrop-blur-sm px-4 py-2 rounded-lg border border-gold/30 flex items-center shadow-md">
                  <Clock size={16} className="text-gold mr-2" />
                  <span className="text-sm text-cream">Current Patch: {currentTFTData.currentPatch}</span>
                </div>
                <div className="bg-void-core/50 backdrop-blur-sm px-4 py-2 rounded-lg border border-gold/30 flex items-center shadow-md">
                  <Calendar size={16} className="text-gold mr-2" />
                  <span className="text-sm text-cream">Next Patch: {currentTFTData.nextPatchDate}</span>
                </div>
              </div>
            </div>
            
            {/* Navigation inside the banner */}
            <div className="overflow-x-auto">
              <div className="flex justify-center space-x-3 min-w-max">
                <NavTab 
                  title="Overview" 
                  isActive={activeSection === 'overview'} 
                  onClick={() => setActiveSection('overview')}
                  icon={<Eye size={18} />}
                />
                <NavTab 
                  title="Patch Notes" 
                  isActive={activeSection === 'patchnotes'} 
                  onClick={() => setActiveSection('patchnotes')}
                  icon={<FileBarChart size={18} />}
                />
                <NavTab 
                  title="Timeline" 
                  isActive={activeSection === 'timeline'} 
                  onClick={() => setActiveSection('timeline')}
                  icon={<Calendar size={18} />}
                />
              </div>
            </div>
          </div>
        </div>
          
        {/* Main Content Area */}
        <div>
          {activeSection === 'overview' && <CurrentSetOverview />}
          {activeSection === 'patchnotes' && <PatchNotesSection />}
          {activeSection === 'timeline' && <TimelineSection />}
        </div>
        
        {/* Hacks System Modal */}
        <HackDetailsModal show={showInfoModal} onClose={() => setShowInfoModal(false)} />
      </div>
    </Layout>
  );
};

export default TFTPatchNotes;
EOL

# Create guides.js in src/pages/guides
cat > src/pages/guides/index.tsx << 'EOL'
import React, { useState } from 'react';
import { Layout, Card } from '@/components/ui';
import { FeatureBanner, HeaderBanner } from '@/components/common';
import { 
  BookOpen, 
  Info, 
  Star, 
  ShoppingBag, 
  Layers, 
  Users, 
  Activity, 
  Shield,
  Swords,
  Calendar,
  Clock,
  Puzzle
} from 'lucide-react';

// Updated guides data for Set 14: Cyber City
const guidesData = {
  set_info: {
    name: "Cyber City",
    number: 14,
    current_patch: "14.4",
    patch_date: "May 14, 2025",
    next_patch: "14.5",
    next_patch_date: "May 28, 2025"
  },
  champion_tiers: {
    description: "Champions in TFT are divided into cost tiers from 1 to 5, with higher cost units being more powerful but rarer to find. The champion pool is shared among all players, making champion availability a strategic consideration.",
    tiers: [1, 2, 3, 4, 5],
    pool_size_per_champion: {
      "1": 29,
      "2": 22,
      "3": 18,
      "4": 12,
      "5": 10
    },
    drop_rates: {
      level_1: { "1": "100%", "2": "0%", "3": "0%", "4": "0%", "5": "0%" },
      level_2: { "1": "100%", "2": "0%", "3": "0%", "4": "0%", "5": "0%" },
      level_3: { "1": "75%", "2": "25%", "3": "0%", "4": "0%", "5": "0%" },
      level_4: { "1": "55%", "2": "30%", "3": "15%", "4": "0%", "5": "0%" },
      level_5: { "1": "45%", "2": "33%", "3": "20%", "4": "2%", "5": "0%" },
      level_6: { "1": "30%", "2": "40%", "3": "25%", "4": "5%", "5": "0%" },
      level_7: { "1": "19%", "2": "35%", "3": "35%", "4": "10%", "5": "1%" },
      level_8: { "1": "15%", "2": "25%", "3": "35%", "4": "20%", "5": "5%" },
      level_9: { "1": "10%", "2": "15%", "3": "30%", "4": "30%", "5": "15%" },
      level_10: { "1": "5%", "2": "10%", "3": "20%", "4": "40%", "5": "25%" },
      level_11: { "1": "1%", "2": "2%", "3": "12%", "4": "50%", "5": "35%" }
    }
  },
  champion_star_levels: {
    description: "Combining three copies of the same champion creates a stronger 2-star version. Combining three 2-star champions creates an even more powerful 3-star version, which is the maximum level a unit can reach.",
    combination_rules: "To upgrade a champion to 2-star, you need three 1-star copies. To upgrade to 3-star, you need three 2-star copies (a total of nine 1-star copies). Upgrading combines the champions automatically.",
    stat_scaling: {
      attack_damage: {
        "two_star": "180% of 1-star",
        "three_star": "324% of 1-star (180% of 2-star)"
      },
      health: {
        "two_star": "180% of 1-star",
        "three_star": "324% of 1-star (180% of 2-star)"
      },
      ability: "Ability power effects typically scale by approximately 180% at 2-star and 324% at 3-star, but can vary by champion."
    },
    costs: {
      "tier_1": {
        "1_star": 1,
        "2_star": 3,
        "3_star": 9,
        "4_star": "N/A"
      },
      "tier_2": {
        "1_star": 2,
        "2_star": 6,
        "3_star": 18,
        "4_star": "N/A"
      },
      "tier_3": {
        "1_star": 3,
        "2_star": 9,
        "3_star": 27,
        "4_star": "N/A"
      },
      "tier_4": {
        "1_star": 4,
        "2_star": 12,
        "3_star": 36,
        "4_star": "N/A"
      },
      "tier_5": {
        "1_star": 5,
        "2_star": 15,
        "3_star": 45,
        "4_star": "N/A"
      }
    },
    selling: "Selling a champion returns its full gold value. Selling a 2-star returns the equivalent of three 1-stars, and selling a 3-star returns the equivalent of nine 1-stars."
  },
  champion_store: {
    description: "The champion store refreshes automatically at the start of each round and can be manually refreshed for 2 gold. Each shop offers 5 champions based on your level and the current odds.",
    mechanics: [
      "Each shop refresh costs 2 gold",
      "Champions in the shop are drawn from the shared pool",
      "Higher level increases chances for higher-cost units",
      "The game tracks all champions offered to you in shop",
      "If you see a 3-cost champion at level 4, it has slightly increased odds to appear again",
      "This 'bad luck protection' helps you find specific champions",
      "There is also 'streak protection' for extremely unlucky streaks"
    ],
    special_mechanics: "In Set 14, shop odds can be altered by the Hacks mechanic. Some Hacks may allow two-star units to appear directly in your shop, significantly increasing your chances of upgrading key units."
  },
  champion_items: {
    inventory: "Champions can hold up to 3 items. Extra items can be stored on your bench or applied directly to champions on the board.",
    combination: "Basic items can be combined to create powerful completed items. Drag one item onto another to combine them, either in your item inventory or on a champion.",
    selling: "When you sell a champion, all items return to your item inventory. If your inventory is full, items will appear on the closest bench space.",
    source: "In Set 14, items can be obtained from PvE rounds, carousels, Hacked augments, and special encounters. Some Hacks may also provide additional item choices during component armories."
  },
  champion_traits: {
    description: "Champions have traits that provide bonuses when you field multiple champions with the same trait. The traits in Cyber City include class traits that define combat roles (Bruiser, Executioner) and origin traits that define faction affiliation (Anima Squad, Street Demon). Each trait has multiple activation thresholds with increasing power.",
    key_traits: {
      "anima_squad": "Champions gain weapons that fire periodically during combat. The more Anima Squad units you field, the more weapons they receive.",
      "street_demon": "Units gain damage amplification and omnivamp, allowing them to sustain through combat with lifesteal.",
      "golden_ox": "Champions gain attack damage, ability power, and omnivamp, making them powerful hybrids.",
      "cypher": "Collect intel through combat that can be cashed out for powerful combat stats.",
      "executioner": "Champions deal bonus damage with critical strikes and gain critical strike chance.",
      "bruiser": "Champions gain additional maximum health, making them tankier."
    }
  },
  champion_roles: {
    description: "Champions in TFT have specific roles based on their abilities and stats. Understanding these roles helps with positioning and team composition.",
    purpose: "While not explicitly labeled in-game, these roles help understand how champions function in combat and how to build teams around them.",
    types: {
      tank: "Champions with high health and resistances that can absorb damage for the team. They often have crowd control abilities. Example: Kobuko, Dr. Mundo.",
      carry: "Champions that deal high damage and are the primary damage source for your team. They need to be protected and itemized. Examples: Zeri, Kayle, Akali.",
      support: "Champions that provide utility, buffs, or debuffs rather than dealing damage directly. Examples: Aurora, Sona.",
      assassin: "Champions that target the backline and eliminate high-priority targets. They often have mobility or stealth. Examples: Rengar, Akali.",
      bruiser: "Champions that can both deal and take significant damage. They're versatile frontliners with offensive capabilities. Examples: Jax, Viego."
    },
    info: "In Cyber City, some champions can take on different roles depending on items and team composition. For instance, Morgana can be built as a tank or as a secondary carry with the right items."
  },
  game_mechanics: {
    true_damage: "True damage ignores armor and magic resistance, dealing its full value directly to health. Several champions in Cyber City deal true damage, including Zeri and Fiora.",
    dodge: "Dodge chance allows champions to completely avoid basic attacks. Most sources of dodge have been removed from the game, but a few specific augments and abilities still provide it.",
    stealth: "Stealth makes a unit untargetable and often grants other effects like movement or damage bonuses when coming out of stealth. Akali and Rengar use stealth mechanics.",
    burn: "Burn effects deal damage over time, typically as magic damage. Multiple sources of burn damage stack.",
    wound: "Wound effects reduce healing received by the target. In Cyber City, this effect is primarily found on Executioner champions.",
    chill: "Chill effects slow attack speed. Most sources of chill in Cyber City come from Nitro champions and their items.",
    item_disable: "Some effects can disable enemy items temporarily. This is a rare mechanic found on specific augments.",
    shred: "Armor shred reduces enemy armor. Multiple sources stack additively.",
    sunder: "Magic resist shred reduces enemy magic resistance. Multiple sources stack additively.",
    crowd_control: {
      stun: "Prevents the target from moving, attacking, or using abilities for the duration.",
      knockup: "Similar to stun, but explicitly cannot be reduced by tenacity.",
      silence: "Prevents casting abilities but allows movement and basic attacks.",
      disarm: "Prevents basic attacks but allows movement and ability casting.",
      root: "Prevents movement but allows attacking and ability casting."
    },
    bench: "Your bench can hold up to 9 units at a time. If your bench is full, you cannot buy new champions from the shop or receive champions from Hack rewards."
  },
  hacks_mechanic: {
    description: "Hacks are Set 14's core mechanic, transforming how systems like Augments, Shop, and Items function throughout the game.",
    frequency: "You'll see 2-5 Hacks per game, impacting various systems.",
    common_hacks: [
      {
        name: "Shop Hack",
        effect: "Two-star units can appear directly in your shop"
      },
      {
        name: "Augment Hack",
        effect: "Extra Augment round in stage 2 or 3"
      },
      {
        name: "Component Hack",
        effect: "Choose from multiple component options during armories"
      },
      {
        name: "Carousel Hack",
        effect: "Tome of Traits can appear in carousels"
      },
      {
        name: "Split-or-Take",
        effect: "After carousels, players choose to split a pot of gold or take a guaranteed amount"
      },
      {
        name: "Double PVE",
        effect: "After a PvE round, face an exact copy of it for duplicate rewards"
      }
    ]
  },
  emblem_mechanics: {
    description: "In Set 14, Emblems not only grant a trait but also provide bonus stats for the first time in TFT history.",
    types: [
      {
        trait: "Anima Squad",
        bonus: "+10% Attack Speed"
      },
      {
        trait: "Bruiser",
        bonus: "+150 Health"
      },
      {
        trait: "Executioner",
        bonus: "+10% Crit Chance"
      },
      {
        trait: "Cypher",
        bonus: "+10 Ability Power"
      },
      {
        trait: "Nitro",
        bonus: "+10% Attack Damage"
      },
      {
        trait: "Street Demon",
        bonus: "+8% Omnivamp"
      }
    ],
    source: "Emblems can be crafted through Spatula combinations, obtained from Tome of Traits, or received from certain augments and encounters."
  },
  meta_compositions: {
    golden_ox: {
      description: "A flexible composition centered around Golden Ox's powerful stat boosts. Can incorporate various carries depending on what you find.",
      core_champions: ["Viego", "Jax", "Sett", "Kayle"],
      key_traits: ["Golden Ox (4)", "Bruiser (2)"],
      carry_items: "Bloodthirster, Hand of Justice, and Titan's Resolve on Viego"
    },
    anima_executioners: {
      description: "Focuses on Anima Squad's weapon systems combined with Executioner's critical damage to create devastating backline carries.",
      core_champions: ["Zeri", "Vayne", "Jinx", "Kobuko"],
      key_traits: ["Anima Squad (3)", "Executioner (4)"],
      carry_items: "Guinsoo's Rageblade, Infinity Edge, and Giant Slayer on Zeri"
    },
    exotech_reroll: {
      description: "A reroll composition that focuses on three-starring key Exotech units to maximize their weapon effects.",
      core_champions: ["Varus", "Naafiri", "Morgana", "Aphelios"],
      key_traits: ["Exotech (3)", "Nitro (4)"],
      carry_items: "Spear of Shojin, Jeweled Gauntlet, and Holobow on Varus"
    }
  }
};

export default function GuidesPage() {
  const [activeSection, setActiveSection] = useState<string | null>('champion_tiers');

  const toggleSection = (section: string) => {
    setActiveSection(activeSection === section ? null : section);
  };

  return (
    <Layout title="Guides">
      
      <div className="container mx-auto py-8">
        {/* Updated Patch Indicator Banner with Navigation - using homepage style background */}
        <div className="relative mb-8 overflow-hidden rounded-lg border border-gold/20 shadow-lg">
          {/* Gradient background layer */}
          <div className="absolute inset-0 bg-gradient-to-r from-eclipse-shadow to-void-core opacity-90 z-0"></div>
          
          {/* Image background layer */}
          <div className="absolute inset-0 bg-[url('/assets/app/learn_banner.jpg')] bg-cover bg-center opacity-20 z-0 rounded-xl"></div>
          
          {/* Subtle border glow - optional, from homepage */}
          <div className="absolute inset-0 rounded-xl border border-solar-flare/30 z-10"></div>
          
          {/* Content container */}
          <div className="relative z-20 p-5">
            <div className="flex flex-col md:flex-row justify-between items-start md:items-center mb-4">
              <div>
                <h1 className="text-3xl font-bold text-gold mb-1">
                  Set 14 <span className="text-gold-light">Cyber City</span> Guides
                </h1>
                <p className="text-cream">Master the core systems of Teamfight Tactics</p>
              </div>
              <div className="flex mt-3 md:mt-0 space-x-4">
                <div className="bg-void-core/50 backdrop-blur-sm px-4 py-2 rounded-lg border border-gold/30 flex items-center shadow-md">
                  <Clock size={16} className="text-gold mr-2" />
                  <span className="text-sm text-cream">Patch {guidesData.set_info.current_patch}</span>
                </div>
                <div className="bg-void-core/50 backdrop-blur-sm px-4 py-2 rounded-lg border border-gold/30 flex items-center shadow-md">
                  <Calendar size={16} className="text-gold mr-2" />
                  <span className="text-sm text-cream">{guidesData.set_info.patch_date}</span>
                </div>
              </div>
            </div>
            
            {/* Navigation inside the banner - centered */}
            <div className="overflow-x-auto">
              <div className="flex justify-center space-x-3 min-w-max">
                <NavCard 
                  title="Champion Tiers" 
                  icon={<Users />}
                  isActive={activeSection === 'champion_tiers'}
                  onClick={() => toggleSection('champion_tiers')}
                />
                <NavCard 
                  title="Star Levels" 
                  icon={<Star />}
                  isActive={activeSection === 'champion_star_levels'}
                  onClick={() => toggleSection('champion_star_levels')}
                />
                <NavCard 
                  title="Store" 
                  icon={<ShoppingBag />}
                  isActive={activeSection === 'champion_store'}
                  onClick={() => toggleSection('champion_store')}
                />
                <NavCard 
                  title="Items" 
                  icon={<Swords />}
                  isActive={activeSection === 'champion_items'}
                  onClick={() => toggleSection('champion_items')}
                />
                <NavCard 
                  title="Traits" 
                  icon={<Puzzle />}
                  isActive={activeSection === 'champion_traits'}
                  onClick={() => toggleSection('champion_traits')}
                />
                <NavCard 
                  title="Game Mechanics" 
                  icon={<BookOpen />}
                  isActive={activeSection === 'game_mechanics'}
                  onClick={() => toggleSection('game_mechanics')}
                />
                <NavCard 
                  title="Set Mechanics" 
                  icon={<Info />}
                  isActive={activeSection === 'set_mechanics'}
                  onClick={() => toggleSection('set_mechanics')}
                />
              </div>
            </div>
          </div>
        </div>
        
        {/* Navigation Cards - REMOVED - now in banner */}

                  {/* Content Sections */}
        <div className="space-y-8">
          {/* Champion Tiers Section */}
          {activeSection === 'champion_tiers' && (
            <section>
              <SectionHeader 
                title="Champion Tiers" 
                subtitle="Understanding champion costs and pool distribution"
                icon={<Info size={24} />}
              />
              
              <Card className="p-6 border border-gold/20 shadow-lg bg-void-core/35 backdrop-filter backdrop-blur-md">
                <div className="space-y-6">
                  <div className="bg-void-core/25 p-4 rounded-lg text-cream backdrop-filter backdrop-blur-sm shadow-inner">
                    <p className="text-cream">{guidesData.champion_tiers.description}</p>
                  </div>
                  
                  <div>
                    <h3 className="text-xl font-medium text-gold mb-4">Pool Size per Champion</h3>
                    <div className="overflow-x-auto bg-void-core/15 rounded-lg p-4 shadow-inner border border-gold/10 backdrop-filter backdrop-blur-sm">
                      <table className="min-w-full border-collapse">
                        <thead>
                          <tr className="bg-void-core/30 border-b border-gold/30">
                            <th className="px-6 py-3 text-left text-sm font-medium text-gold-light">Champion Tier</th>
                            <th className="px-6 py-3 text-left text-sm font-medium text-gold-light">Pool Size</th>
                          </tr>
                        </thead>
                        <tbody>
                          {Object.entries(guidesData.champion_tiers.pool_size_per_champion).map(([tier, size], index) => (
                            <tr key={tier} className={index % 2 === 0 ? 'bg-void-core/10' : 'bg-void-core/20'}>
                              <td className="px-6 py-3 whitespace-nowrap text-sm text-cream">{tier}★ Cost</td>
                              <td className="px-6 py-3 whitespace-nowrap text-sm font-mono bg-void-core/25 rounded-lg inline-block ml-4 text-cream">{size}</td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    </div>
                  </div>

                  <div>
                    <h3 className="text-xl font-medium text-gold mb-4">Champion Drop Rates</h3>
                    <div className="overflow-x-auto bg-void-core/15 rounded-lg p-4 shadow-inner border border-gold/10 backdrop-filter backdrop-blur-sm">
                      <table className="min-w-full border-collapse">
                        <thead>
                          <tr className="bg-void-core/30 border-b border-gold/30">
                            <th className="px-4 py-3 text-left text-sm font-medium text-gold-light">Level</th>
                            {guidesData.champion_tiers.tiers.map(tier => (
                              <th key={tier} className="px-4 py-3 text-center text-sm font-medium text-gold-light">Tier {tier}</th>
                            ))}
                          </tr>
                        </thead>
                        <tbody>
                          {Object.entries(guidesData.champion_tiers.drop_rates).map(([level, rates], index) => (
                            <tr key={level} className={index % 2 === 0 ? 'bg-void-core/10' : 'bg-void-core/20'}>
                              <td className="px-4 py-3 whitespace-nowrap text-sm font-medium text-cream">{level.replace('level_', '')}</td>
                              {guidesData.champion_tiers.tiers.map(tier => (
                                <td key={tier} className="px-4 py-3 text-center text-sm text-cream">
                                  {rates[tier.toString() as keyof typeof rates]}
                                </td>
                              ))}
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    </div>
                  </div>
                </div>
              </Card>
            </section>
          )}

          {/* Champion Star Levels Section */}
          {activeSection === 'champion_star_levels' && (
            <section>
              <SectionHeader 
                title="Champion Star Levels" 
                subtitle="Champion upgrades and stat scaling"
                icon={<Star size={24} />}
              />
              
              <Card className="p-6 border border-gold/20 shadow-lg bg-void-core/35 backdrop-blur-md">
                <div className="space-y-6">
                  <p className="bg-void-core/25 p-4 rounded-lg text-cream">{guidesData.champion_star_levels.description}</p>
                  <p className="bg-void-core/25 p-4 rounded-lg text-cream">{guidesData.champion_star_levels.combination_rules}</p>
                  
                  <div>
                    <h3 className="text-xl font-medium text-gold mb-4">Stat Scaling</h3>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                      <div className="bg-void-core/15 rounded-lg p-5 shadow-md border border-gold/10">
                        <h4 className="font-medium text-gold-light mb-3 pb-2 border-b border-gold/20">Attack Damage</h4>
                        <div className="space-y-3">
                          {Object.entries(guidesData.champion_star_levels.stat_scaling.attack_damage).map(([level, scaling]) => (
                            <div key={level} className="flex justify-between items-center p-3 bg-void-core/25 rounded-lg">
                              <span className="text-cream">{level.replace('_', ' ')}</span>
                              <span className="text-gold text-sm font-mono bg-void-core/35 px-3 py-1 rounded">{scaling}</span>
                            </div>
                          ))}
                        </div>
                      </div>
                      
                      <div className="bg-void-core/15 rounded-lg p-5 shadow-md border border-gold/10">
                        <h4 className="font-medium text-gold-light mb-3 pb-2 border-b border-gold/20">Health</h4>
                        <div className="space-y-3">
                          {Object.entries(guidesData.champion_star_levels.stat_scaling.health).map(([level, scaling]) => (
                            <div key={level} className="flex justify-between items-center p-3 bg-void-core/25 rounded-lg">
                              <span className="text-cream">{level.replace('_', ' ')}</span>
                              <span className="text-gold text-sm font-mono bg-void-core/35 px-3 py-1 rounded">{scaling}</span>
                            </div>
                          ))}
                        </div>
                      </div>
                    </div>
                    <div className="mt-3 text-sm italic bg-void-core/25 p-4 rounded-lg text-cream">
                      {guidesData.champion_star_levels.stat_scaling.ability}
                    </div>
                  </div>

                  <div>
                    <h3 className="text-xl font-medium text-gold mb-4">Champion Upgrade Costs</h3>
                    <div className="overflow-x-auto bg-void-core/15 rounded-lg p-4 shadow-inner border border-gold/10">
                      <table className="min-w-full border-collapse">
                        <thead>
                          <tr className="bg-void-core/30 border-b border-gold/30">
                            <th className="px-4 py-3 text-left text-sm font-medium text-gold-light">Tier</th>
                            <th className="px-4 py-3 text-center text-sm font-medium text-gold-light">1★ Cost</th>
                            <th className="px-4 py-3 text-center text-sm font-medium text-gold-light">2★ Cost</th>
                            <th className="px-4 py-3 text-center text-sm font-medium text-gold-light">3★ Cost</th>
                            <th className="px-4 py-3 text-center text-sm font-medium text-gold-light">4★ Cost</th>
                          </tr>
                        </thead>
                        <tbody>
                          {Object.entries(guidesData.champion_star_levels.costs).map(([tier, costs], index) => (
                            <tr key={tier} className={index % 2 === 0 ? 'bg-void-core/10' : 'bg-void-core/20'}>
                              <td className="px-4 py-3 whitespace-nowrap text-sm font-medium text-cream">{tier.replace('tier_', '')}</td>
                              <td className="px-4 py-3 text-center text-sm text-cream">{costs['1_star']} 🪙</td>
                              <td className="px-4 py-3 text-center text-sm text-cream">{costs['2_star']} 🪙</td>
                              <td className="px-4 py-3 text-center text-sm text-cream">{costs['3_star']} 🪙</td>
                              <td className="px-4 py-3 text-center text-sm text-cream">{costs['4_star']}</td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    </div>
                  </div>
                  
                  <div className="bg-void-core/15 rounded-lg p-5 shadow-md border border-gold/10">
                    <h4 className="font-medium text-gold-light mb-3 pb-2 border-b border-gold/20">Selling Champions</h4>
                    <p className="text-cream">{guidesData.champion_star_levels.selling}</p>
                  </div>
                </div>
              </Card>
            </section>
          )}

          {/* Champion Store Section */}
          {activeSection === 'champion_store' && (
            <section>
              <SectionHeader 
                title="Champion Store" 
                subtitle="Shop mechanics and refresh strategies"
                icon={<ShoppingBag size={24} />}
              />
              
              <Card className="p-6 border border-gold/20 shadow-lg bg-void-core/40">
                <div className="space-y-6">
                  <p className="bg-void-core/30 p-4 rounded-lg text-cream">{guidesData.champion_store.description}</p>
                  
                  <div>
                    <h3 className="text-xl font-medium text-gold mb-4">Store Mechanics</h3>
                    <div className="bg-void-core/20 rounded-lg p-5 shadow-md border border-gold/10">
                      <ul className="space-y-3">
                        {guidesData.champion_store.mechanics.map((mechanic, index) => (
                          <li key={index} className="flex items-start bg-void-core/30 p-4 rounded-lg group hover:bg-void-core/40 transition-colors">
                            <div className="w-6 h-6 flex-shrink-0 rounded-full bg-void-core/40 flex items-center justify-center mr-3 border border-gold/20 group-hover:border-gold/50 transition-colors">
                              <span className="text-sm font-bold text-gold">{index + 1}</span>
                            </div>
                            <div className="text-cream">{mechanic}</div>
                          </li>
                        ))}
                      </ul>
                    </div>
                  </div>
                  
                  <div className="bg-void-core/20 rounded-lg p-5 shadow-md border border-gold/10">
                    <h4 className="font-medium text-gold-light mb-3 pb-2 border-b border-gold/20">Cyber City Special Mechanics</h4>
                    <p className="text-cream">{guidesData.champion_store.special_mechanics}</p>
                  </div>
                </div>
              </Card>
            </section>
          )}

          {/* Champion Items Section */}
          {activeSection === 'champion_items' && (
            <section>
              <SectionHeader 
                title="Champion Items" 
                subtitle="Item mechanics and combinations"
                icon={<Layers size={24} />}
              />
              
              <Card className="p-6 border border-gold/20 shadow-lg bg-void-core/40">
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
                  <div className="bg-void-core/20 rounded-lg p-5 shadow-md border border-gold/10 hover:shadow-lg hover:border-gold/30 transition-all">
                    <h4 className="font-medium text-gold-light mb-3 pb-2 border-b border-gold/20">Inventory</h4>
                    <p className="text-cream">{guidesData.champion_items.inventory}</p>
                  </div>
                  
                  <div className="bg-void-core/20 rounded-lg p-5 shadow-md border border-gold/10 hover:shadow-lg hover:border-gold/30 transition-all">
                    <h4 className="font-medium text-gold-light mb-3 pb-2 border-b border-gold/20">Combination</h4>
                    <p className="text-cream">{guidesData.champion_items.combination}</p>
                  </div>
                  
                  <div className="bg-void-core/20 rounded-lg p-5 shadow-md border border-gold/10 hover:shadow-lg hover:border-gold/30 transition-all">
                    <h4 className="font-medium text-gold-light mb-3 pb-2 border-b border-gold/20">Selling</h4>
                    <p className="text-cream">{guidesData.champion_items.selling}</p>
                  </div>
                  
                  <div className="bg-void-core/20 rounded-lg p-5 shadow-md border border-gold/10 hover:shadow-lg hover:border-gold/30 transition-all">
                    <h4 className="font-medium text-gold-light mb-3 pb-2 border-b border-gold/20">Source</h4>
                    <p className="text-cream">{guidesData.champion_items.source}</p>
                  </div>
                </div>
              </Card>
            </section>
          )}

          {/* Champion Traits Section */}
          {activeSection === 'champion_traits' && (
            <section>
              <SectionHeader 
                title="Champion Traits" 
                subtitle="Trait synergies and bonuses"
                icon={<Users size={24} />}
              />
              
              <Card className="p-5 border border-gold/20 shadow-lg">
                <div className="bg-void-core/20 rounded-lg p-4 shadow-md border border-gold/10 mb-4">
                  <p className="text-sm">{guidesData.champion_traits.description}</p>
                </div>
                
                <h3 className="text-lg font-medium text-gold mb-3">Key Cyber City Traits</h3>
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
                  {Object.entries(guidesData.champion_traits.key_traits).map(([trait, description]) => (
                    <div key={trait} className="bg-void-core/20 rounded-lg p-4 shadow-md border border-gold/10 hover:shadow-lg hover:border-gold/30 transition-all">
                      <h4 className="font-medium text-gold-light text-sm mb-2 pb-1 border-b border-gold/20">{formatTraitName(trait)}</h4>
                      <p className="text-xs">{description}</p>
                    </div>
                  ))}
                </div>
                
                <div className="bg-void-core/10 rounded-lg p-4 mt-4 shadow-md border border-gold/20">
                  <h4 className="font-medium text-gold-light text-sm mb-2 pb-1 border-b border-gold/20">Emblem Bonuses (Set 14 Feature)</h4>
                  <p className="mb-3 text-xs">{guidesData.emblem_mechanics.description}</p>
                  <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-2">
                    {guidesData.emblem_mechanics.types.map((emblem, index) => (
                      <div key={index} className="flex items-center justify-between bg-void-core/30 p-2 rounded-md">
                        <span className="font-medium text-xs">{emblem.trait}</span>
                        <span className="text-gold-light bg-void-core/50 px-2 py-0.5 rounded text-xs">{emblem.bonus}</span>
                      </div>
                    ))}
                  </div>
                </div>
              </Card>
            </section>
          )}

          {/* Game Mechanics Section */}
          {activeSection === 'game_mechanics' && (
            <section>
              <SectionHeader 
                title="Game Mechanics" 
                subtitle="Core systems and combat mechanics"
                icon={<Activity size={24} />}
              />
              
              <Card className="p-5 border border-gold/20 shadow-lg">
                <div className="space-y-4">
                  <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
                    <div className="bg-void-core/20 rounded-lg p-4 shadow-md border border-gold/10 hover:shadow-lg hover:border-gold/30 transition-all">
                      <h4 className="font-medium text-gold-light text-sm mb-2 pb-1 border-b border-gold/20">True Damage</h4>
                      <p className="text-xs">{guidesData.game_mechanics.true_damage}</p>
                    </div>
                    
                    <div className="bg-void-core/20 rounded-lg p-4 shadow-md border border-gold/10 hover:shadow-lg hover:border-gold/30 transition-all">
                      <h4 className="font-medium text-gold-light text-sm mb-2 pb-1 border-b border-gold/20">Dodge</h4>
                      <p className="text-xs">{guidesData.game_mechanics.dodge}</p>
                    </div>
                    
                    <div className="bg-void-core/20 rounded-lg p-4 shadow-md border border-gold/10 hover:shadow-lg hover:border-gold/30 transition-all">
                      <h4 className="font-medium text-gold-light text-sm mb-2 pb-1 border-b border-gold/20">Stealth</h4>
                      <p className="text-xs">{guidesData.game_mechanics.stealth}</p>
                    </div>
                    
                    <div className="bg-void-core/20 rounded-lg p-4 shadow-md border border-gold/10 hover:shadow-lg hover:border-gold/30 transition-all">
                      <h4 className="font-medium text-gold-light text-sm mb-2 pb-1 border-b border-gold/20">Burn</h4>
                      <p className="text-xs">{guidesData.game_mechanics.burn}</p>
                    </div>
                    
                    <div className="bg-void-core/20 rounded-lg p-4 shadow-md border border-gold/10 hover:shadow-lg hover:border-gold/30 transition-all">
                      <h4 className="font-medium text-gold-light text-sm mb-2 pb-1 border-b border-gold/20">Wound</h4>
                      <p className="text-xs">{guidesData.game_mechanics.wound}</p>
                    </div>
                    
                    <div className="bg-void-core/20 rounded-lg p-4 shadow-md border border-gold/10 hover:shadow-lg hover:border-gold/30 transition-all">
                      <h4 className="font-medium text-gold-light text-sm mb-2 pb-1 border-b border-gold/20">Chill</h4>
                      <p className="text-xs">{guidesData.game_mechanics.chill}</p>
                    </div>
                  </div>
                  
                  <h3 className="text-lg font-medium text-gold mb-3">Crowd Control Effects</h3>
                  <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-3">
                    {Object.entries(guidesData.game_mechanics.crowd_control).map(([cc, description]) => (
                      <div key={cc} className="bg-void-core/20 rounded-lg p-3 shadow-md border border-gold/10">
                        <h4 className="font-medium text-gold-light text-xs mb-1 pb-1 border-b border-gold/20">{formatCCName(cc)}</h4>
                        <p className="text-xs">{description}</p>
                      </div>
                    ))}
                  </div>
                  
                  <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                    <div className="bg-void-core/20 rounded-lg p-4 shadow-md border border-gold/10 hover:shadow-lg hover:border-gold/30 transition-all">
                      <h4 className="font-medium text-gold-light text-sm mb-2 pb-1 border-b border-gold/20">Item Disable</h4>
                      <p className="text-xs">{guidesData.game_mechanics.item_disable}</p>
                    </div>
                    
                    <div className="bg-void-core/20 rounded-lg p-4 shadow-md border border-gold/10 hover:shadow-lg hover:border-gold/30 transition-all">
                      <h4 className="font-medium text-gold-light text-sm mb-2 pb-1 border-b border-gold/20">Shred</h4>
                      <p className="text-xs">{guidesData.game_mechanics.shred}</p>
                    </div>
                    
                    <div className="bg-void-core/20 rounded-lg p-4 shadow-md border border-gold/10 hover:shadow-lg hover:border-gold/30 transition-all">
                      <h4 className="font-medium text-gold-light text-sm mb-2 pb-1 border-b border-gold/20">Sunder</h4>
                      <p className="text-xs">{guidesData.game_mechanics.sunder}</p>
                    </div>
                  </div>
                  
                  <div className="bg-void-core/20 rounded-lg p-4 shadow-md border border-gold/10">
                    <h4 className="font-medium text-gold-light text-sm mb-2 pb-1 border-b border-gold/20">Bench</h4>
                    <p className="text-xs">{guidesData.game_mechanics.bench}</p>
                  </div>
                </div>
              </Card>
            </section>
          )}
          
          {/* Set Mechanics Section */}
          {activeSection === 'set_mechanics' && (
            <section>
              <SectionHeader 
                title="Set Mechanics" 
                subtitle="Special features unique to Cyber City"
                icon={<Shield size={24} />}
              />
              
              <Card className="p-5 border border-gold/20 shadow-lg">
                <div className="space-y-4">
                  <div className="bg-void-core/20 rounded-lg p-4 shadow-md border border-gold/10">
                    <h3 className="text-lg font-medium text-gold mb-2">Hacks: The Core Mechanic</h3>
                    <p className="mb-3 text-sm">{guidesData.hacks_mechanic.description}</p>
                    <p className="mb-3 text-sm">
                      Hacks provide a dynamic element to each match, forcing players to adapt their strategies based on the specific 
                      changes to core systems. This creates a unique gameplay experience in every game.
                    </p>
                    <div className="bg-void-core/40 p-3 rounded-lg border border-gold/20 text-sm">
                      <div className="font-medium text-gold-light mb-1">Frequency</div>
                      <p className="text-xs">{guidesData.hacks_mechanic.frequency}</p>
                    </div>
                  </div>
                  
                  <h3 className="text-lg font-medium text-gold mb-3">Common Hack Types</h3>
                  <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
                    {guidesData.hacks_mechanic.common_hacks.map((hack, index) => (
                      <div key={index} className="bg-void-core/20 rounded-lg p-3 shadow-md border border-gold/10 hover:shadow-lg hover:border-gold/30 transition-all">
                        <h4 className="font-medium text-gold-light text-sm mb-2 pb-1 border-b border-gold/20">{hack.name}</h4>
                        <p className="text-xs">{hack.effect}</p>
                      </div>
                    ))}
                  </div>
                  
                  <h3 className="text-lg font-medium text-gold mb-3">Meta Compositions</h3>
                  <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                    {Object.entries(guidesData.meta_compositions).map(([comp, details], index) => (
                      <div key={comp} className="bg-void-core/20 rounded-lg p-3 shadow-md border border-gold/10 hover:shadow-lg hover:border-gold/30 transition-all">
                        <h4 className="font-medium text-gold-light text-sm mb-2 pb-1 border-b border-gold/20">{formatCompName(comp)}</h4>
                        <p className="text-xs mb-2">{details.description}</p>
                        
                        <div className="bg-void-core/40 p-2 rounded-lg mb-2">
                          <div className="text-xs font-medium text-gold-light mb-1">Core Champions</div>
                          <div className="flex flex-wrap gap-1">
                            {details.core_champions.map((champ, i) => (
                              <span key={i} className="bg-void-core/60 px-1.5 py-0.5 rounded-md text-xs border border-gold/10">
                                {champ}
                              </span>
                            ))}
                          </div>
                        </div>
                        
                        <div className="bg-void-core/40 p-2 rounded-lg mb-2">
                          <div className="text-xs font-medium text-gold-light mb-1">Key Traits</div>
                          <div className="flex flex-wrap gap-1">
                            {details.key_traits.map((trait, i) => (
                              <span key={i} className="bg-void-core/60 px-1.5 py-0.5 rounded-md text-xs border border-gold/10">
                                {trait}
                              </span>
                            ))}
                          </div>
                        </div>
                        
                        <div className="bg-void-core/40 p-2 rounded-lg">
                          <div className="text-xs font-medium text-gold-light mb-1">Carry Items</div>
                          <p className="text-xs">{details.carry_items}</p>
                        </div>
                      </div>
                    ))}
                  </div>

                  <div className="bg-gold/10 rounded-lg p-4 shadow-md border border-gold/20">
                    <h3 className="text-lg font-medium text-gold mb-2">Emblems with Stat Bonuses</h3>
                    <p className="mb-3 text-sm">
                      For the first time in TFT history, emblems not only grant a trait but also provide stat bonuses. 
                      This makes trait splashing more powerful and versatile than in previous sets.
                    </p>
                    <div className="grid grid-cols-2 sm:grid-cols-3 gap-2">
                      {guidesData.emblem_mechanics.types.map((emblem, index) => (
                        <div key={index} className="flex items-center justify-between bg-void-core/30 p-2 rounded-md">
                          <span className="font-medium text-xs">{emblem.trait}</span>
                          <span className="text-gold-light bg-void-core/50 px-1.5 py-0.5 rounded text-xs">{emblem.bonus}</span>
                        </div>
                      ))}
                    </div>
                  </div>
                </div>
              </Card>
            </section>
          )}
        </div>
      </div>
    </Layout>
  );
}

// Helper Components
interface NavCardProps {
  title: string;
  icon: React.ReactNode;
  isActive: boolean;
  onClick: () => void;
}

function NavCard({ title, icon, isActive, onClick }: NavCardProps) {
  return (
    <div 
      className={`flex items-center px-4 py-2 rounded-lg cursor-pointer transition-all ${
        isActive 
          ? 'bg-gradient-to-br from-void-core/40 to-void-core/20 shadow-md border border-gold/50 backdrop-blur-sm' 
          : 'bg-void-core/40 hover:bg-void-core/40 shadow border border-gold/10 hover:border-gold/30 backdrop-blur-sm'
      }`}
      onClick={onClick}
    >
      <div className={`p-1.5 rounded-full mr-2 ${isActive ? 'bg-gold/20' : 'bg-void-core/50'}`}>
        {React.cloneElement(icon as React.ReactElement, { 
          size: 18, 
          className: isActive ? 'text-gold' : 'text-gold/60' 
        })}
      </div>
      <span className={`text-sm font-semibold ${isActive ? 'text-gold' : 'text-cream/90'}`}>{title}</span>
    </div>
  );
}

interface SectionHeaderProps {
  title: string;
  subtitle: string;
  icon: React.ReactNode;
}

function SectionHeader({ title, subtitle, icon }: SectionHeaderProps) {
  return (
    <div className="mb-6">
      <div className="flex items-center justify-center">
        <div className="h-1 flex-grow bg-gradient-to-r from-transparent via-gold/20 to-gold/50 mr-3"></div>
        <div className="bg-void-core/70 backdrop-blur-md border-b-2 border-gold rounded-md px-8 py-3 inline-block shadow-sm shadow-gold/20">
          <h2 className="text-2xl font-bold text-gold text-center">{title}</h2>
        </div>
        <div className="h-1 flex-grow bg-gradient-to-l from-transparent via-gold/20 to-gold/50 ml-3"></div>
      </div>
      <p className="text-sm text-cream/90 mt-2 text-center">{subtitle}</p>
    </div>
  );
}

// Formatting Helpers
function formatStatName(name: string): string {
  return name
    .replace(/_/g, ' ')
    .replace(/^\w/, c => c.toUpperCase());
}

function formatRoleName(role: string): string {
  return role
    .replace(/_/g, ' ')
    .replace(/^\w/, c => c.toUpperCase())
    .replace(/\b\w/g, c => c.toUpperCase());
}

function formatTraitName(trait: string): string {
  return trait
    .replace(/_/g, ' ')
    .replace(/^\w/, c => c.toUpperCase())
    .replace(/\b\w/g, c => c.toUpperCase());
}

function formatCCName(cc: string): string {
  return cc
    .replace(/_/g, ' ')
    .replace(/^\w/, c => c.toUpperCase());
}

function formatCompName(comp: string): string {
  return comp
    .replace(/_/g, ' ')
    .replace(/^\w/, c => c.toUpperCase())
    .replace(/\b\w/g, c => c.toUpperCase());
}
EOL

# Create Login Page with improved styling
cat > src/pages/login/index.tsx << 'EOL'
import React, { useEffect } from 'react';
import { useRouter } from 'next/router';
import { motion } from 'framer-motion';
import { LogIn } from 'lucide-react';
import Layout from '@/components/ui/Layout';
import { getRSOAuthUrl, setAuthRedirect } from '@/utils/auth';
import { useAuth } from '@/utils/auth/AuthContext';

export default function LoginPage() {
  const { auth } = useAuth();
  const router = useRouter();
  const { error: queryError } = router.query;
  
  useEffect(() => {
    // Redirect to home page if already authenticated
    if (auth.isAuthenticated && !auth.isLoading) {
      router.push('/profile');
    }
    
    // Store the return path if it exists
    const returnPath = router.query.returnTo as string;
    if (returnPath && returnPath !== '/login') {
      setAuthRedirect(returnPath);
    }
  }, [auth.isAuthenticated, auth.isLoading, router]);
  
  // If loading auth state, show a loading state
  if (auth.isLoading) {
    return (
      <Layout>
        <div className="flex items-center justify-center py-16">
          <div className="text-center">
            <div className="inline-block h-12 w-12 border-4 border-t-gold border-r-gold/30 border-b-gold/10 border-l-gold/60 rounded-full animate-spin"></div>
            <p className="mt-4 text-corona-light">Checking authentication status...</p>
          </div>
        </div>
      </Layout>
    );
  }
  
  const handleLogin = () => {
    window.location.href = getRSOAuthUrl();
  };
  
  return (
    <Layout title="Login">
      <div className="mt-10">
        {/* Banner with background image like homepage */}
        <div className="relative mb-8">
          <div className="absolute inset-0 bg-gradient-to-r from-eclipse-shadow to-void-core opacity-90 z-0 rounded-xl"></div>
          <div className="absolute inset-0 bg-[url('/assets/app/learn_banner.jpg')] bg-cover bg-center opacity-20 z-0 rounded-xl"></div>
          <div className="absolute inset-0 rounded-xl border border-solar-flare/30 z-10"></div>
          
          <div className="relative z-20 px-6 py-8 flex flex-col items-center text-center">
            <h1 className="text-3xl md:text-4xl font-display mb-2">
              <span className="text-solar-flare">Join</span> <span className="text-white">The Tacticians</span>
            </h1>
            <p className="text-corona-light/90 max-w-lg mx-auto">
              Sign in with your Riot account to access personalized content, track your progress, and climb the leaderboard.
            </p>
          </div>
        </div>
        
        {/* Login Card with Glass Effect */}
        <div className="max-w-md mx-auto backdrop-filter backdrop-blur-md bg-eclipse-shadow/30 rounded-xl overflow-hidden border border-solar-flare/30 p-6">
          <div className="flex flex-col items-center">
            {/* Logo without circle */}
            <img 
              src="/assets/app/app.png" 
              alt="MetaForge" 
              className="w-24 h-24 mb-6" 
              onError={(e) => {
                const target = e.target as HTMLImageElement;
                target.src = '/assets/app/default.png';
              }}
            />
            
            <h2 className="text-xl text-gold mb-4">Connect Your Riot Account</h2>
            
            <p className="text-corona-light mb-6 text-center">
              Track your TFT performance, save your favorite comps, and unlock premium features customized to your playstyle.
            </p>
            
            {(auth.error || queryError) && (
              <div className="bg-red-950/80 border border-red-500/50 text-red-200 p-3 rounded-md mb-6 w-full">
                {auth.error || queryError}
              </div>
            )}
            
            <motion.button
              onClick={handleLogin}
              className="relative flex items-center justify-center gap-2 px-8 py-3 w-full bg-solar-flare text-brown-dark rounded-md font-medium overflow-hidden"
              whileHover={{ 
                scale: 1.03, 
                transition: { duration: 0.2 }
              }}
              whileTap={{ scale: 0.98 }}
            >
              {/* Background glow effect */}
              <motion.div 
                className="absolute inset-0 bg-white opacity-0 rounded-md"
                initial={{ opacity: 0 }}
                whileHover={{ opacity: 0.2 }}
                transition={{ duration: 0.3 }}
              />
              
              <LogIn size={20} />
              <span>Sign in with Riot</span>
            </motion.button>
            
            <div className="mt-6 text-xs text-corona-light/60 text-center">
              By signing in, you agree to our <a href="/terms" className="text-solar-flare hover:underline">Terms of Service</a> and <a href="/privacy" className="text-solar-flare hover:underline">Privacy Policy</a>.
            </div>
          </div>
        </div>
      </div>
    </Layout>
  );
}
EOL

# Create Profile page that redirects to login when not authenticated
cat > src/pages/profile/index.tsx << 'EOL'
import React, { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { motion, AnimatePresence } from 'framer-motion';
import Layout from '@/components/ui/Layout';
import { 
  Trophy, TrendingUp, Target, Award, Calendar, Clock, Loader2, RefreshCw, ChevronRight, Star, Zap, Shield
} from 'lucide-react';
import { useAuth } from '@/utils/auth/AuthContext';
import { PlayerStats as PlayerStatsType, MatchHistoryEntry } from '@/types/auth';
import LoginButton from '@/components/auth/LoginButton';
import { MatchDetail } from '@/components/entity';

const FeatureBanner = ({ title }: { title: string }) => {
  return (
    <div className="mb-8">
      <div className="flex items-center justify-center">
        <div className="h-1 flex-grow bg-gradient-to-r from-transparent via-solar-flare/20 to-solar-flare/50 mr-3"></div>
        <div className="bg-eclipse-shadow/70 backdrop-blur-md border-b-2 border-solar-flare rounded-lg px-8 py-3 shadow-solar">
          <h2 className="text-2xl font-display text-solar-flare text-center">{title}</h2>
        </div>
        <div className="h-1 flex-grow bg-gradient-to-l from-transparent via-solar-flare/20 to-solar-flare/50 ml-3"></div>
      </div>
    </div>
  );
};

const LoginCTA = () => {
  return (
    <div className="space-y-8">
      <motion.div 
        className="relative overflow-hidden rounded-xl"
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6 }}
      >
        <div className="absolute inset-0 bg-gradient-to-r from-eclipse-shadow to-void-core opacity-90"></div>
        <div className="absolute inset-0 bg-[url('/assets/app/learn_banner.jpg')] bg-cover bg-center opacity-30"></div>
        <div className="absolute inset-0 border border-solar-flare/30 rounded-xl"></div>
        
        <div className="relative z-10 px-8 py-16 text-center">
          <motion.h1 
            className="text-4xl font-display text-stellar-white mb-4"
            initial={{ y: 20, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            transition={{ delay: 0.3, duration: 0.5 }}
          >
            <span className="text-gold font-display tracking-tight">Begin your</span>{' '}
            <span className="text-corona-light/90">Journey</span>
          </motion.h1>
          
          <motion.p 
            className="text-corona-light/80 max-w-2xl mx-auto mb-8 text-lg"
            initial={{ y: 20, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            transition={{ delay: 0.4, duration: 0.5 }}
          >
            Connect your Riot account to access detailed match analysis, personal statistics, and climb tracking.
          </motion.p>
          
          <motion.div
            className="flex justify-center"
            initial={{ y: 20, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            transition={{ delay: 0.5, duration: 0.5 }}
          >
            <LoginButton 
              label="Connect Riot Account" 
              size="lg" 
              variant="primary"
              className="px-10 py-4 text-lg"
            />
          </motion.div>
        </div>
      </motion.div>
      
      <motion.div 
        className="backdrop-filter backdrop-blur-md bg-eclipse-shadow/30 border border-solar-flare/30 rounded-xl overflow-hidden"
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.6, duration: 0.5 }}
      >
        <div className="p-8">
          <div className="text-center mb-8">
            <h3 className="text-xl font-display text-stellar-white">What You'll Access</h3>
            <p className="text-corona-light/70 text-sm mt-2">Unlock powerful insights with your Riot account</p>
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            {[
              { icon: Trophy, title: "Rank Tracking", desc: "Monitor your climb and LP gains through every season" },
              { icon: Clock, title: "Match History", desc: "Analyze every game with detailed post-match insights" },
              { icon: TrendingUp, title: "Performance", desc: "Discover patterns and improvement opportunities" }
            ].map((feature, i) => (
              <motion.div
                key={i}
                className="text-center group"
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.7 + i * 0.1, duration: 0.5 }}
                whileHover={{ y: -5 }}
              >
                <div className="w-20 h-20 mx-auto mb-6 bg-gradient-to-br from-solar-flare/20 to-burning-warning/10 rounded-full border border-solar-flare/30 flex items-center justify-center group-hover:border-solar-flare/60 transition-all duration-300 group-hover:scale-110">
                  <feature.icon className="h-8 w-8 text-solar-flare" />
                </div>
                
                <h3 className="text-xl font-display text-stellar-white mb-3 group-hover:text-solar-flare transition-colors">
                  {feature.title}
                </h3>
                <p className="text-corona-light/70 text-sm leading-relaxed max-w-xs mx-auto">
                  {feature.desc}
                </p>
              </motion.div>
            ))}
          </div>
        </div>
      </motion.div>
    </div>
  );
};

const PlayerProfileHeader = ({ user, isLoading }: { user: any; isLoading: boolean }) => {
  if (isLoading) {
    return (
      <div className="relative overflow-hidden rounded-xl bg-eclipse-shadow/30 backdrop-blur-md border border-solar-flare/30 p-8">
        <div className="flex items-center gap-6">
          <div className="w-20 h-20 bg-void-core/40 rounded-xl animate-pulse"></div>
          <div className="flex-1 space-y-3">
            <div className="h-8 bg-void-core/40 rounded w-64 animate-pulse"></div>
            <div className="h-5 bg-void-core/40 rounded w-40 animate-pulse"></div>
          </div>
        </div>
      </div>
    );
  }

  if (!user) return null;

  return (
    <motion.div 
      className="relative overflow-hidden rounded-xl"
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.6 }}
    >
      <div className="absolute inset-0 bg-gradient-to-r from-eclipse-shadow to-void-core opacity-95"></div>
      <div className="absolute inset-0 bg-[url('/assets/app/fight_banner.jpg')] bg-cover bg-center opacity-20"></div>
      <div className="absolute inset-0 border border-solar-flare/30 rounded-xl"></div>
      
      <div className="relative z-10 p-8">
        <div className="flex flex-col lg:flex-row items-center lg:items-start gap-6">
          <motion.div
            className="relative"
            whileHover={{ scale: 1.05 }}
            transition={{ duration: 0.2 }}
          >
            <div className="w-24 h-24 rounded-xl border-2 border-solar-flare/60 overflow-hidden bg-void-core/60 backdrop-blur-sm">
              <img 
                src={user.profileIconId 
                  ? `https://ddragon.leagueoflegends.com/cdn/14.1.1/img/profileicon/${user.profileIconId}.png` 
                  : '/assets/app/default-avatar.png'
                } 
                alt="Profile Icon" 
                className="w-full h-full object-cover"
                onError={(e) => {
                  const target = e.target as HTMLImageElement;
                  target.src = '/assets/app/default-avatar.png';
                }}
              />
            </div>
            <div className="absolute -bottom-2 -right-2 bg-solar-flare text-void-core text-sm font-bold px-3 py-1 rounded-full">
              Lv. {user.summonerLevel || '?'}
            </div>
          </motion.div>
          
          <div className="flex-1 text-center lg:text-left">
            <h1 className="text-3xl lg:text-4xl font-display text-stellar-white mb-3">
              {user.gameName || user.summonerName || 'Tactician'}
              {user.tagLine && (
                <span className="text-corona-light/70 font-normal text-xl ml-2">#{user.tagLine}</span>
              )}
            </h1>
            
            <div className="flex flex-wrap gap-4 justify-center lg:justify-start">
              {user.region && (
                <div className="bg-void-core/40 backdrop-blur-sm px-4 py-2 rounded-lg border border-solar-flare/20">
                  <span className="text-corona-light/70">Region: </span>
                  <span className="text-solar-flare font-medium">{user.region.toUpperCase()}</span>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </motion.div>
  );
};

const PlayerStatsCards = ({ stats, isLoading }: { stats: PlayerStatsType | null; isLoading: boolean }) => {
  if (isLoading) {
    return (
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-6 max-w-5xl mx-auto">
        {[...Array(4)].map((_, i) => (
          <div key={i} className="text-center animate-pulse">
            <div className="w-16 h-16 bg-void-core/40 rounded-full mx-auto mb-4"></div>
            <div className="h-4 bg-void-core/40 rounded mb-2 w-20 mx-auto"></div>
            <div className="h-6 bg-void-core/40 rounded w-16 mx-auto"></div>
          </div>
        ))}
      </div>
    );
  }

  if (!stats) {
    return (
      <motion.div 
        className="text-center py-16"
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ duration: 0.5 }}
      >
        <div className="w-20 h-20 mx-auto mb-6 bg-gradient-to-br from-solar-flare/20 to-burning-warning/10 rounded-full border border-solar-flare/30 flex items-center justify-center">
          <Trophy className="h-8 w-8 text-solar-flare/50" />
        </div>
        <h3 className="text-xl font-display text-stellar-white mb-2">No Ranked Stats Yet</h3>
        <p className="text-corona-light/70">
          Play some ranked TFT games to see your statistics here!
        </p>
      </motion.div>
    );
  }

  const winRate = ((stats.wins / (stats.wins + stats.losses)) * 100).toFixed(1);
  
  const statCards = [
    { 
      icon: Trophy, 
      label: "Current Rank", 
      value: `${stats.tier} ${stats.rank}`,
      subValue: `${stats.leaguePoints} LP`,
      color: "text-solar-flare"
    },
    { 
      icon: Target, 
      label: "Win Rate", 
      value: `${winRate}%`,
      subValue: `${stats.wins}W ${stats.losses}L`,
      color: parseFloat(winRate) >= 60 ? "text-verdant-success" : parseFloat(winRate) >= 50 ? "text-solar-flare" : "text-burning-warning"
    },
    { 
      icon: Award, 
      label: "Total Games", 
      value: (stats.wins + stats.losses).toString(),
      subValue: `${stats.wins} wins`,
      color: "text-corona-light"
    },
    { 
      icon: Star, 
      label: "Hot Streak", 
      value: stats.hotStreak ? "Active" : "Inactive",
      subValue: stats.veteran ? "Veteran" : "Climbing",
      color: stats.hotStreak ? "text-burning-warning" : "text-corona-light/70"
    }
  ];

  return (
    <div className="grid grid-cols-2 lg:grid-cols-4 gap-6 max-w-5xl mx-auto">
      {statCards.map((stat, i) => (
        <motion.div
          key={i}
          className="text-center group"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: i * 0.1, duration: 0.5 }}
          whileHover={{ y: -5 }}
        >
          <div className="w-16 h-16 mx-auto mb-4 bg-gradient-to-br from-solar-flare/20 to-burning-warning/10 rounded-full border border-solar-flare/30 flex items-center justify-center group-hover:border-solar-flare/60 transition-all duration-300 group-hover:scale-110">
            <stat.icon className="h-6 w-6 text-solar-flare" />
          </div>
          
          <div className="text-sm text-corona-light/70 mb-2">{stat.label}</div>
          <div className={`text-2xl font-bold ${stat.color} mb-1`}>{stat.value}</div>
          {stat.subValue && (
            <div className="text-xs text-corona-light/60">{stat.subValue}</div>
          )}
        </motion.div>
      ))}
    </div>
  );
};

const MatchHistory = ({ matches, isLoading }: { matches: MatchHistoryEntry[]; isLoading: boolean }) => {
  const [selectedMatch, setSelectedMatch] = useState<MatchHistoryEntry | null>(null);

  if (isLoading) {
    return (
      <div className="space-y-3">
        {[...Array(5)].map((_, i) => (
          <div key={i} className="bg-eclipse-shadow/30 rounded-xl p-4 border border-solar-flare/20 animate-pulse">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-4">
                <div className="w-12 h-12 bg-void-core/40 rounded"></div>
                <div className="space-y-2">
                  <div className="h-4 bg-void-core/40 rounded w-32"></div>
                  <div className="h-3 bg-void-core/40 rounded w-24"></div>
                </div>
              </div>
              <div className="h-8 bg-void-core/40 rounded w-16"></div>
            </div>
          </div>
        ))}
      </div>
    );
  }

  if (!matches?.length) {
    return (
      <motion.div 
        className="text-center py-16"
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ duration: 0.5 }}
      >
        <div className="w-20 h-20 mx-auto mb-6 bg-gradient-to-br from-solar-flare/20 to-burning-warning/10 rounded-full border border-solar-flare/30 flex items-center justify-center">
          <Clock className="h-8 w-8 text-solar-flare/50" />
        </div>
        <h3 className="text-xl font-display text-stellar-white mb-2">No Recent Matches</h3>
        <p className="text-corona-light/70">
          Play some TFT games to see your match history here!
        </p>
      </motion.div>
    );
  }

  const getPlacementColor = (placement: number) => {
    if (placement === 1) return 'text-solar-flare bg-solar-flare/20';
    if (placement <= 4) return 'text-verdant-success bg-verdant-success/20';
    return 'text-burning-warning bg-burning-warning/20';
  };

  return (
    <>
      <div className="space-y-3">
        {matches.map((match, index) => {
          const placementColor = getPlacementColor(match.placement || 8);
          const gameDuration = Math.floor((match.gameDuration || 0) / 60);
          const gameDate = new Date(match.gameCreation || Date.now()).toLocaleDateString();
          
          return (
            <motion.div 
              key={match.matchId}
              className="backdrop-filter backdrop-blur-md bg-eclipse-shadow/30 rounded-xl p-4 border border-solar-flare/20 hover:border-solar-flare/40 transition-all cursor-pointer group"
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: index * 0.05, duration: 0.3 }}
              onClick={() => setSelectedMatch(match)}
              whileHover={{ scale: 1.01, boxShadow: "0 10px 25px -5px rgba(245, 158, 11, 0.1)" }}
            >
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-4">
                  <div className={`w-12 h-12 rounded-lg ${placementColor} border border-current/30 flex items-center justify-center font-bold text-lg`}>
                    #{match.placement || 8}
                  </div>
                  
                  <div>
                    <div className="flex items-center gap-2 text-sm text-corona-light">
                      <span className="font-medium">{gameDate}</span>
                      <span className="text-corona-light/50">•</span>
                      <span className="text-corona-light/70">{gameDuration} min</span>
                      <span className="text-corona-light/50">•</span>
                      <span className="text-corona-light/70">Level {match.level || 1}</span>
                    </div>
                    <div className="text-xs text-corona-light/60 mt-1">
                      {match.gameType || 'Standard'} • {match.traits?.filter(t => t.style >= 1).length || 0} active traits
                    </div>
                  </div>
                </div>
                
                <div className="flex items-center gap-2">
                  <div className="text-xs text-corona-light/70">View Details</div>
                  <ChevronRight className="h-4 w-4 text-corona-light/40 group-hover:text-solar-flare transition-colors" />
                </div>
              </div>
            </motion.div>
          );
        })}
      </div>

      <AnimatePresence>
        {selectedMatch && (
          <motion.div 
            className="fixed inset-0 bg-void-core/80 backdrop-blur-sm z-50 flex items-center justify-center p-4"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={() => setSelectedMatch(null)}
          >
            <motion.div 
              className="bg-eclipse-shadow/95 backdrop-blur-md rounded-xl border border-solar-flare/40 max-w-6xl w-full max-h-[90vh] overflow-y-auto"
              initial={{ scale: 0.8, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              exit={{ scale: 0.8, opacity: 0 }}
              onClick={(e) => e.stopPropagation()}
            >
              <div className="p-6">
                <div className="flex justify-between items-center mb-6">
                  <h2 className="text-2xl font-display text-stellar-white">Match Analysis</h2>
                  <button 
                    onClick={() => setSelectedMatch(null)}
                    className="bg-void-core/60 hover:bg-void-core/80 text-corona-light px-4 py-2 rounded-lg transition-colors"
                  >
                    Close
                  </button>
                </div>
                <MatchDetail match={selectedMatch} />
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </>
  );
};

const UserDashboard = () => {
  const { auth } = useAuth();
  const [activeTab, setActiveTab] = useState<'overview' | 'matches'>('overview');
  
  const {
    data: playerStats,
    isLoading: isLoadingStats,
    refetch: refetchStats
  } = useQuery<PlayerStatsType>({
    queryKey: ['playerStats', auth.user?.summonerId, auth.user?.region],
    queryFn: async () => {
      if (!auth.user?.summonerId) throw new Error('Summoner ID not found');
      
      const response = await fetch(
        `/api/tft/player/stats?summonerId=${auth.user.summonerId}&region=${auth.user.region || 'na1'}`
      );
      
      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.error || `Failed to fetch stats (${response.status})`);
      }
      
      return response.json();
    },
    enabled: !!auth.user?.summonerId && auth.isAuthenticated,
    staleTime: 300000,
    retry: 2
  });
  
  const {
    data: matchHistory,
    isLoading: isLoadingMatches,
    refetch: refetchMatches
  } = useQuery<MatchHistoryEntry[]>({
    queryKey: ['matchHistory', auth.user?.puuid, auth.user?.region],
    queryFn: async () => {
      if (!auth.user?.puuid) throw new Error('PUUID not found');
      
      const routingRegion = auth.user.region === 'kr' || auth.user.region === 'jp1' ? 'asia' : 
                           auth.user.region === 'euw1' || auth.user.region === 'eun1' ? 'europe' :
                           auth.user.region === 'oc1' ? 'sea' : 'americas';
      
      const response = await fetch(
        `/api/tft/player/matches?puuid=${auth.user.puuid}&region=${routingRegion}&count=10`
      );
      
      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.error || `Failed to fetch matches (${response.status})`);
      }
      
      return response.json();
    },
    enabled: !!auth.user?.puuid && auth.isAuthenticated,
    staleTime: 300000,
    retry: 2
  });
  
  return (
    <div className="space-y-8">
      <PlayerProfileHeader user={auth.user} isLoading={auth.isLoading} />
      
      <div>
        <FeatureBanner title="Performance Overview" />
        <PlayerStatsCards stats={playerStats || null} isLoading={isLoadingStats} />
      </div>
      
      <div className="backdrop-filter backdrop-blur-md bg-eclipse-shadow/30 rounded-xl border border-solar-flare/30 overflow-hidden">
        <div className="border-b border-solar-flare/30">
          <div className="flex">
            {[
              { id: 'overview', label: 'Analytics', icon: TrendingUp },
              { id: 'matches', label: 'Match History', icon: Clock }
            ].map((tab) => (
              <button
                key={tab.id}
                className={`flex items-center gap-2 px-6 py-4 transition-all ${
                  activeTab === tab.id
                    ? 'text-solar-flare border-b-2 border-solar-flare bg-solar-flare/10'
                    : 'text-corona-light hover:text-solar-flare/70 hover:bg-void-core/30'
                }`}
                onClick={() => setActiveTab(tab.id as any)}
              >
                <tab.icon className="h-4 w-4" />
                <span>{tab.label}</span>
              </button>
            ))}
          </div>
        </div>
        
        <div className="p-6">
          <AnimatePresence mode="wait">
            {activeTab === 'overview' && (
              <motion.div
                key="overview"
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -20 }}
                transition={{ duration: 0.3 }}
                className="text-center py-12"
              >
                <div className="w-20 h-20 mx-auto mb-6 bg-gradient-to-br from-solar-flare/20 to-burning-warning/10 rounded-full border border-solar-flare/30 flex items-center justify-center">
                  <TrendingUp className="h-8 w-8 text-solar-flare/50" />
                </div>
                <h3 className="text-xl font-display text-stellar-white mb-2">
                  Advanced Analytics Coming Soon
                </h3>
                <p className="text-corona-light/70">
                  Detailed performance insights, trends, and recommendations will be available here.
                </p>
              </motion.div>
            )}
            
            {activeTab === 'matches' && (
              <motion.div
                key="matches"
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -20 }}
                transition={{ duration: 0.3 }}
              >
                <div className="flex justify-between items-center mb-6">
                  <h3 className="text-xl font-display text-stellar-white">Recent Matches</h3>
                  <button 
                    className="flex items-center gap-2 text-corona-light hover:text-solar-flare transition-colors"
                    onClick={() => refetchMatches()}
                    disabled={isLoadingMatches}
                  >
                    <RefreshCw className={`h-4 w-4 ${isLoadingMatches ? 'animate-spin' : ''}`} />
                    Refresh
                  </button>
                </div>
                
                <MatchHistory matches={matchHistory || []} isLoading={isLoadingMatches} />
              </motion.div>
            )}
          </AnimatePresence>
        </div>
      </div>
    </div>
  );
};

export default function ProfilePage() {
  const { auth } = useAuth();
  
  return (
    <Layout title="Profile">
      <div className="max-w-6xl mx-auto py-8">
        {!auth.isAuthenticated && !auth.isLoading ? (
          <LoginCTA />
        ) : (
          auth.isAuthenticated && <UserDashboard />
        )}
      </div>
    </Layout>
  );
}
EOL

# Player stats API endpoint
cat > src/pages/api/tft/player/stats.ts << 'EOL'
import type { NextApiRequest, NextApiResponse } from 'next';
import { PlayerStats } from '@/types/auth';

const RIOT_API_KEY = process.env.RIOT_API_KEY || '';

let lastRequestTime = 0;
const RATE_LIMIT_DELAY = 100;

const delay = (ms: number) => new Promise(resolve => setTimeout(resolve, ms));

async function rateLimit() {
  const now = Date.now();
  const timeSince = now - lastRequestTime;
  if (timeSince < RATE_LIMIT_DELAY) {
    await delay(RATE_LIMIT_DELAY - timeSince);
  }
  lastRequestTime = Date.now();
}

const logError = (message: string, error?: any) => {
  console.error(`[TFT/PLAYER/STATS] ${message}`, error);
};

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { summonerId, region = 'na1' } = req.query;
    
    if (!summonerId) {
      return res.status(400).json({ error: 'Summoner ID is required' });
    }
    
    if (!RIOT_API_KEY) {
      return res.status(500).json({ error: 'RIOT_API_KEY is not set' });
    }
    
    const regionMapping: Record<string, string> = {
      'na': 'na1', 'na1': 'na1',
      'euw': 'euw1', 'euw1': 'euw1',
      'kr': 'kr', 'jp': 'jp1', 'jp1': 'jp1',
      'br': 'br1', 'br1': 'br1',
      'las': 'la2', 'la2': 'la2',
      'lan': 'la1', 'la1': 'la1',
      'eune': 'eun1', 'eun1': 'eun1',
      'tr': 'tr1', 'tr1': 'tr1',
      'oc': 'oc1', 'oc1': 'oc1', 'oce': 'oc1',
      'ru': 'ru'
    };
    
    const validRegion = regionMapping[region as string] || 'na1';
    
    try {
      await rateLimit();
      
      const response = await fetch(
        `https://${validRegion}.api.riotgames.com/tft/league/v1/entries/by-summoner/${summonerId}`,
        {
          headers: { 'X-Riot-Token': RIOT_API_KEY },
          signal: AbortSignal.timeout(10000)
        }
      );
      
      if (!response.ok) {
        if (response.status === 404) {
          return res.status(404).json({ error: 'Player not found or not ranked in TFT' });
        }
        logError(`Failed to fetch player stats: ${response.status} ${response.statusText}`);
        return res.status(response.status).json({ error: 'Failed to fetch player stats' });
      }
      
      const data = await response.json();
      
      const rankedEntry = data.find((entry: any) => 
        entry.queueType === 'RANKED_TFT' || entry.queueType === 'RANKED_TFT_TURBO'
      );
      
      if (!rankedEntry) {
        return res.status(404).json({ error: 'No ranked TFT stats found for this player' });
      }
      
      const wins = rankedEntry.wins || 0;
      const losses = rankedEntry.losses || 0;
      const totalGames = wins + losses;
      const winRate = totalGames > 0 ? Number(((wins / totalGames) * 100).toFixed(1)) : 0;
      
      const playerStats: PlayerStats = {
        summonerId: rankedEntry.summonerId || '',
        summonerName: rankedEntry.summonerName || '',
        tagLine: '',
        tier: rankedEntry.tier || '',
        rank: rankedEntry.rank || '',
        leaguePoints: rankedEntry.leaguePoints || 0,
        wins,
        losses,
        winRate,
        hotStreak: rankedEntry.hotStreak || false,
        veteran: rankedEntry.veteran || false,
        freshBlood: rankedEntry.freshBlood || false,
        inactive: rankedEntry.inactive || false,
        miniSeries: rankedEntry.miniSeries || undefined
      };
      
      res.setHeader('Cache-Control', 'public, s-maxage=300, stale-while-revalidate=600');
      
      return res.status(200).json(playerStats);
    } catch (error) {
      if (error instanceof Error && error.name === 'TimeoutError') {
        logError("Request timeout for player stats");
        return res.status(408).json({ error: 'Request timeout - please try again' });
      }
      
      logError("Riot API Error", error);
      return res.status(500).json({ error: 'Failed to fetch player stats' });
    }
  } catch (error) {
    logError("Player Stats API Error", error);
    return res.status(500).json({ error: 'Internal server error' });
  }
}
EOL

# Match history API endpoint
cat > src/pages/api/tft/player/matches.ts << 'EOL'
import type { NextApiRequest, NextApiResponse } from 'next';
import { MatchHistoryEntry } from '@/types/auth';

const RIOT_API_KEY = process.env.RIOT_API_KEY || '';

let lastRequestTime = 0;
const RATE_LIMIT_DELAY = 100;

const delay = (ms: number) => new Promise(resolve => setTimeout(resolve, ms));

async function rateLimit() {
  const now = Date.now();
  const timeSince = now - lastRequestTime;
  if (timeSince < RATE_LIMIT_DELAY) {
    await delay(RATE_LIMIT_DELAY - timeSince);
  }
  lastRequestTime = Date.now();
}

const logError = (message: string, error?: any) => {
  console.error(`[TFT/PLAYER/MATCHES] ${message}`, error);
};

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { puuid, region = 'americas', count = '10' } = req.query;
    
    if (!puuid) {
      return res.status(400).json({ error: 'PUUID is required' });
    }
    
    if (!RIOT_API_KEY) {
      return res.status(500).json({ error: 'RIOT_API_KEY is not set' });
    }
    
    const regionRouting: Record<string, string> = {
      'na1': 'americas', 'na': 'americas',
      'br1': 'americas', 'br': 'americas',
      'la1': 'americas', 'lan': 'americas',
      'la2': 'americas', 'las': 'americas',
      'euw1': 'europe', 'euw': 'europe',
      'eun1': 'europe', 'eune': 'europe',
      'tr1': 'europe', 'tr': 'europe',
      'ru': 'europe',
      'kr': 'asia',
      'jp1': 'asia', 'jp': 'asia',
      'oc1': 'sea', 'oc': 'sea', 'oce': 'sea'
    };
    
    const routingRegion = regionRouting[region as string] || 'americas';
    
    try {
      await rateLimit();
      
      const matchIdsResponse = await fetch(
        `https://${routingRegion}.api.riotgames.com/tft/match/v1/matches/by-puuid/${puuid}/ids?count=${count}`,
        {
          headers: { 'X-Riot-Token': RIOT_API_KEY },
          signal: AbortSignal.timeout(15000)
        }
      );
      
      if (!matchIdsResponse.ok) {
        if (matchIdsResponse.status === 404) {
          return res.status(404).json({ error: 'No matches found for this player' });
        }
        logError(`Failed to fetch match IDs: ${matchIdsResponse.status} ${matchIdsResponse.statusText}`);
        return res.status(matchIdsResponse.status).json({ error: 'Failed to fetch match history' });
      }
      
      const matchIds = await matchIdsResponse.json();
      
      if (!matchIds.length) {
        return res.status(200).json([]);
      }
      
      const matchDetails = [];
      
      for (const matchId of matchIds) {
        try {
          await rateLimit();
          
          const matchResponse = await fetch(
            `https://${routingRegion}.api.riotgames.com/tft/match/v1/matches/${matchId}`,
            {
              headers: { 'X-Riot-Token': RIOT_API_KEY },
              signal: AbortSignal.timeout(10000)
            }
          );
          
          if (matchResponse.ok) {
            const matchData = await matchResponse.json();
            matchDetails.push(matchData);
          } else {
            logError(`Failed to fetch match ${matchId}: ${matchResponse.status}`);
          }
        } catch (error) {
          logError(`Error fetching match ${matchId}`, error);
          continue;
        }
      }
      
      const processedMatches: MatchHistoryEntry[] = matchDetails
        .map(match => {
          const participant = match.info.participants.find((p: any) => p.puuid === puuid);
          
          if (!participant) return null;
          
          return {
            matchId: match.metadata.match_id,
            queueId: match.info.queue_id || 0,
            gameType: match.info.tft_game_type || 'standard',
            gameCreation: match.info.game_datetime || Date.now(),
            gameDuration: match.info.game_length || 0,
            gameVersion: match.info.game_version || '',
            mapId: match.info.tft_set_number || 0,
            placement: participant.placement || 8,
            level: participant.level || 1,
            augments: participant.augments || [],
            traits: (participant.traits || []).map((trait: any) => ({
              name: trait.name || '',
              numUnits: trait.num_units || 0,
              style: trait.style || 0,
              tierCurrent: trait.tier_current || 0,
              tierTotal: trait.tier_total || 0
            })),
            units: (participant.units || []).map((unit: any) => ({
              characterId: unit.character_id || '',
              itemNames: unit.itemNames || [],
              rarity: unit.rarity || 0,
              tier: unit.tier || 1
            })),
            companions: participant.companion
          };
        })
        .filter(Boolean) as MatchHistoryEntry[];
      
      res.setHeader('Cache-Control', 'public, s-maxage=300, stale-while-revalidate=600');
      
      return res.status(200).json(processedMatches);
    } catch (error) {
      if (error instanceof Error && error.name === 'TimeoutError') {
        logError("Request timeout for match history");
        return res.status(408).json({ error: 'Request timeout - please try again' });
      }
      
      logError("Riot API Error", error);
      return res.status(500).json({ error: 'Failed to fetch match history' });
    }
  } catch (error) {
    logError("Match History API Error", error);
    return res.status(500).json({ error: 'Internal server error' });
  }
}
EOL

# Global Leaderboard API
cat > src/pages/api/tft/leaderboard/global.ts << 'EOL'
import type { NextApiRequest, NextApiResponse } from 'next';

const RIOT_API_KEY = process.env.RIOT_API_KEY || '';

const regions = ['kr', 'euw1', 'na1', 'br1', 'jp1', 'eun1', 'la1', 'la2', 'tr1', 'ru'];

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  if (!RIOT_API_KEY) {
    return res.status(500).json({ error: 'RIOT_API_KEY is not set' });
  }

  try {
    let topPlayer: any = null;
    let topLP = 0;

    for (const region of regions) {
      try {
        const response = await fetch(
          `https://${region}.api.riotgames.com/tft/league/v1/challenger`,
          {
            headers: { 'X-Riot-Token': RIOT_API_KEY },
            signal: AbortSignal.timeout(5000)
          }
        );

        if (response.ok) {
          const data = await response.json();
          const regionTop = data.entries
            .sort((a: any, b: any) => b.leaguePoints - a.leaguePoints)[0];

          if (regionTop && regionTop.leaguePoints > topLP) {
            topLP = regionTop.leaguePoints;
            topPlayer = { ...regionTop, region };
          }
        }
      } catch (error) {
        console.error(`Failed to fetch challenger for ${region}:`, error);
        continue;
      }
    }

    if (!topPlayer) {
      return res.status(404).json({ error: 'No global data found' });
    }

    try {
      const summonerResponse = await fetch(
        `https://${topPlayer.region}.api.riotgames.com/tft/summoner/v1/summoners/${topPlayer.summonerId}`,
        {
          headers: { 'X-Riot-Token': RIOT_API_KEY },
          signal: AbortSignal.timeout(3000)
        }
      );

      if (summonerResponse.ok) {
        const summoner = await summonerResponse.json();
        topPlayer.summonerName = summoner.name || topPlayer.summonerName || 'Unknown';
      }
    } catch (error) {
      // Keep existing name if fetch fails
    }

    res.setHeader('Cache-Control', 's-maxage=300, stale-while-revalidate=600');
    
    return res.status(200).json({
      summonerId: topPlayer.summonerId,
      summonerName: topPlayer.summonerName || 'Global #1',
      leaguePoints: topPlayer.leaguePoints,
      region: topPlayer.region.toUpperCase(),
      tier: 'CHALLENGER'
    });
  } catch (error) {
    console.error('Global leaderboard error:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
}
EOL

# Player page
cat > src/pages/player/[summonerId].tsx << 'EOL'
import React from 'react';
import { useRouter } from 'next/router';
import { useQuery } from '@tanstack/react-query';
import Layout from '@/components/ui/Layout';
import { PlayerDetail } from '@/components/entity';
import { ArrowLeft, Loader2, Trophy } from 'lucide-react';
import Link from 'next/link';
import { motion } from 'framer-motion';

export default function PlayerPage() {
  const router = useRouter();
  const { summonerId, region = 'na1' } = router.query;
  
  const { data: player, isLoading, isError, error } = useQuery({
    queryKey: ['player', summonerId, region],
    queryFn: async () => {
      const response = await fetch(`/api/tft/player/stats?summonerId=${summonerId}&region=${region}`);
      
      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.error || 'Failed to fetch player data');
      }
      
      const stats = await response.json();
      
      return {
        ...stats,
        rank: 1,
        region: region as string
      };
    },
    enabled: !!summonerId,
    staleTime: 300000
  });
  
  if (isLoading) {
    return (
      <Layout>
        <div className="max-w-6xl mx-auto">
          <div className="flex items-center justify-center min-h-[50vh]">
            <motion.div 
              className="text-center"
              initial={{ opacity: 0, scale: 0.9 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ duration: 0.5 }}
            >
              <Loader2 className="h-16 w-16 text-solar-flare animate-spin mx-auto mb-6" />
              <h2 className="text-xl font-display text-stellar-white mb-2">Loading Player Data</h2>
              <p className="text-corona-light/70">Fetching the latest statistics...</p>
            </motion.div>
          </div>
        </div>
      </Layout>
    );
  }
  
  if (isError || !player) {
    return (
      <Layout>
        <div className="max-w-6xl mx-auto py-16">
          <motion.div 
            className="text-center"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5 }}
          >
            <div className="backdrop-filter backdrop-blur-md bg-eclipse-shadow/30 border border-crimson-alert/60 rounded-xl p-8 inline-block">
              <Trophy className="h-16 w-16 mx-auto text-crimson-alert/70 mb-4" />
              <h1 className="text-2xl font-display text-crimson-alert mb-4">Player Not Found</h1>
              <p className="text-corona-light/70 mb-6 max-w-md">
                {(error as Error)?.message || 'Unable to load player data'}
              </p>
              <Link 
                href="/leaderboard" 
                className="inline-flex items-center gap-2 bg-solar-flare hover:bg-solar-flare/90 text-void-core px-6 py-3 rounded-lg transition-colors"
              >
                <ArrowLeft className="h-4 w-4" />
                Back to Leaderboard
              </Link>
            </div>
          </motion.div>
        </div>
      </Layout>
    );
  }
  
  return (
    <Layout>
      <div className="max-w-6xl mx-auto py-8">
        <motion.div 
          className="mb-6"
          initial={{ opacity: 0, x: -20 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ duration: 0.3 }}
        >
          <Link 
            href="/leaderboard" 
            className="inline-flex items-center gap-2 text-corona-light hover:text-solar-flare transition-colors group"
          >
            <ArrowLeft className="h-4 w-4 group-hover:-translate-x-1 transition-transform" />
            <span>Back to Leaderboard</span>
          </Link>
        </motion.div>
        
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.1 }}
        >
          <PlayerDetail player={player} />
        </motion.div>
      </div>
    </Layout>
  );
}
EOL

# IMPROVED PLAYER DETAIL COMPONENT - BETTER CONTRAST
cat > src/components/entity/PlayerDetail.tsx << 'EOL'
import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { Trophy, Target, Award, TrendingUp, Users, Calendar, Clock, Star, Flame, Shield } from 'lucide-react';

interface PlayerDetailProps {
  player: {
    summonerId: string;
    summonerName: string;
    tagLine: string;
    rank: number;
    leaguePoints: number;
    wins: number;
    losses: number;
    tier: string;
    division: string;
    profileIconId?: number;
    region: string;
    hotStreak?: boolean;
    veteran?: boolean;
    freshBlood?: boolean;
    inactive?: boolean;
  };
}

export default function PlayerDetail({ player }: PlayerDetailProps) {
  const [activeTab, setActiveTab] = useState<'overview' | 'analytics' | 'achievements'>('overview');
  
  const totalGames = player.wins + player.losses;
  const winRate = totalGames > 0 ? ((player.wins / totalGames) * 100).toFixed(1) : '0.0';
  
  const getTierColor = (tier: string) => {
    const colors = {
      IRON: "text-cosmic-dust",
      BRONZE: "text-burning-warning",
      SILVER: "text-cosmic-dust",
      GOLD: "text-solar-flare",
      PLATINUM: "text-corona-light",
      DIAMOND: "text-corona-light",
      MASTER: "text-solar-flare",
      GRANDMASTER: "text-burning-warning",
      CHALLENGER: "text-solar-flare"
    };
    
    return colors[tier as keyof typeof colors] || "text-solar-flare";
  };
  
  const tierColor = getTierColor(player.tier);

  return (
    <div className="space-y-8">
      {/* Main Header */}
      <motion.div 
        className="bg-eclipse-shadow/90 backdrop-blur-sm border border-solar-flare/40 rounded-xl p-8 shadow-eclipse"
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
      >
        <div className="flex flex-col lg:flex-row items-center lg:items-start gap-8">
          <div className="relative">
            <div className="w-28 h-28 rounded-full overflow-hidden bg-void-core/60 border-3 border-solar-flare/60 shadow-solar">
              <img 
                src={player.profileIconId 
                  ? `https://ddragon.leagueoflegends.com/cdn/14.1.1/img/profileicon/${player.profileIconId}.png` 
                  : '/assets/app/default-avatar.png'
                } 
                alt="Profile Icon" 
                className="w-full h-full object-cover"
                onError={(e) => {
                  const target = e.target as HTMLImageElement;
                  target.src = '/assets/app/default-avatar.png';
                }}
              />
            </div>
            <div className="absolute -bottom-2 left-1/2 transform -translate-x-1/2 bg-solar-flare text-void-core text-sm font-bold px-4 py-2 rounded-full shadow-solar">
              #{player.rank}
            </div>
          </div>
          
          <div className="flex-1 text-center lg:text-left">
            <h1 className="text-4xl font-display text-stellar-white mb-4 drop-shadow-md">
              {player.summonerName}
              {player.tagLine && (
                <span className="text-xl text-corona-light/80 ml-3">#{player.tagLine}</span>
              )}
            </h1>
            
            <div className={`text-2xl font-bold ${tierColor} mb-6 drop-shadow-sm`}>
              {player.tier} {player.division} • {player.leaguePoints.toLocaleString()} LP
            </div>
            
            <div className="flex flex-wrap gap-4 justify-center lg:justify-start text-sm">
              <div className="bg-void-core/80 backdrop-blur-sm px-4 py-2 rounded-lg border border-solar-flare/20">
                <span className="text-corona-light/70">Region: </span>
                <span className="text-solar-flare font-medium">{player.region.toUpperCase()}</span>
              </div>
              <div className="bg-void-core/80 backdrop-blur-sm px-4 py-2 rounded-lg border border-solar-flare/20">
                <span className="text-corona-light/70">Win Rate: </span>
                <span className="text-solar-flare font-medium">{winRate}%</span>
              </div>
              <div className="bg-void-core/80 backdrop-blur-sm px-4 py-2 rounded-lg border border-solar-flare/20">
                <span className="text-corona-light/70">Games: </span>
                <span className="text-stellar-white font-medium">{totalGames}</span>
              </div>
            </div>
            
            {(player.hotStreak || player.veteran || player.freshBlood) && (
              <div className="flex gap-3 justify-center lg:justify-start mt-6">
                {player.hotStreak && (
                  <span className="text-sm bg-burning-warning/30 text-burning-warning border border-burning-warning/40 px-3 py-1 rounded-full font-medium">
                    🔥 Hot Streak
                  </span>
                )}
                {player.veteran && (
                  <span className="text-sm bg-cosmic-dust/20 text-cosmic-dust border border-cosmic-dust/40 px-3 py-1 rounded-full font-medium">
                    ⭐ Veteran
                  </span>
                )}
                {player.freshBlood && (
                  <span className="text-sm bg-corona-light/20 text-corona-light border border-corona-light/40 px-3 py-1 rounded-full font-medium">
                    ⚡ Fresh Blood
                  </span>
                )}
              </div>
            )}
          </div>
        </div>
      </motion.div>
      
      {/* Stats Grid */}
      <motion.div 
        className="grid grid-cols-2 lg:grid-cols-4 gap-6"
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.2, duration: 0.5 }}
      >
        {[
          { 
            icon: Target, 
            label: "Win Rate", 
            value: `${winRate}%`,
            subValue: `${player.wins}W / ${player.losses}L`,
            color: parseFloat(winRate) >= 60 ? "text-solar-flare" : parseFloat(winRate) >= 50 ? "text-corona-light" : "text-burning-warning"
          },
          { 
            icon: Award, 
            label: "Victories", 
            value: player.wins.toString(),
            subValue: "Total wins",
            color: "text-solar-flare"
          },
          { 
            icon: TrendingUp, 
            label: "League Points", 
            value: player.leaguePoints.toLocaleString(),
            subValue: player.tier,
            color: "text-solar-flare"
          },
          { 
            icon: Trophy, 
            label: "Ranking", 
            value: `#${player.rank}`,
            subValue: `In ${player.region.toUpperCase()}`,
            color: "text-stellar-white"
          }
        ].map((stat, i) => (
          <motion.div
            key={i}
            className="bg-eclipse-shadow/90 backdrop-blur-sm border border-solar-flare/30 rounded-xl p-6 text-center hover:border-solar-flare/50 transition-all shadow-solar hover:shadow-eclipse"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.3 + i * 0.1, duration: 0.5 }}
            whileHover={{ scale: 1.02 }}
          >
            <stat.icon className="h-8 w-8 text-solar-flare mx-auto mb-4" />
            <div className="text-sm text-corona-light/80 mb-2 font-medium">{stat.label}</div>
            <div className={`text-3xl font-bold ${stat.color} mb-2`}>{stat.value}</div>
            <div className="text-xs text-cosmic-dust">{stat.subValue}</div>
          </motion.div>
        ))}
      </motion.div>
      
      {/* Tabs Section */}
      <motion.div 
        className="bg-eclipse-shadow/90 backdrop-blur-sm border border-solar-flare/40 rounded-xl overflow-hidden shadow-eclipse"
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.4, duration: 0.5 }}
      >
        <div className="border-b border-solar-flare/30">
          <div className="flex">
            {[
              { id: 'overview', label: 'Overview', icon: Users },
              { id: 'analytics', label: 'Analytics', icon: TrendingUp },
              { id: 'achievements', label: 'Achievements', icon: Award }
            ].map((tab) => (
              <button
                key={tab.id}
                className={`flex items-center gap-3 px-8 py-5 transition-all text-sm font-medium ${
                  activeTab === tab.id
                    ? 'text-solar-flare border-b-3 border-solar-flare bg-solar-flare/10'
                    : 'text-corona-light/70 hover:text-solar-flare hover:bg-void-core/30'
                }`}
                onClick={() => setActiveTab(tab.id as any)}
              >
                <tab.icon className="h-5 w-5" />
                <span>{tab.label}</span>
              </button>
            ))}
          </div>
        </div>
        
        <div className="p-10">
          {activeTab === 'overview' && (
            <div className="text-center">
              <div className="w-24 h-24 mx-auto mb-6 bg-solar-flare/20 rounded-full border-2 border-solar-flare/40 flex items-center justify-center">
                <Users className="h-12 w-12 text-solar-flare" />
              </div>
              <h3 className="text-2xl font-display text-stellar-white mb-4">
                Player Overview
              </h3>
              <p className="text-corona-light/70 max-w-md mx-auto">
                Comprehensive player statistics, match patterns, and performance insights coming soon.
              </p>
            </div>
          )}
          
          {activeTab === 'analytics' && (
            <div className="text-center">
              <div className="w-24 h-24 mx-auto mb-6 bg-solar-flare/20 rounded-full border-2 border-solar-flare/40 flex items-center justify-center">
                <TrendingUp className="h-12 w-12 text-solar-flare" />
              </div>
              <h3 className="text-2xl font-display text-stellar-white mb-4">
                Advanced Analytics
              </h3>
              <p className="text-corona-light/70 max-w-md mx-auto">
                Detailed performance metrics, trends over time, and personalized recommendations coming soon.
              </p>
            </div>
          )}
          
          {activeTab === 'achievements' && (
            <div className="text-center">
              <div className="w-24 h-24 mx-auto mb-6 bg-solar-flare/20 rounded-full border-2 border-solar-flare/40 flex items-center justify-center">
                <Award className="h-12 w-12 text-solar-flare" />
              </div>
              <h3 className="text-2xl font-display text-stellar-white mb-4">
                Achievements & Milestones
              </h3>
              <p className="text-corona-light/70 max-w-md mx-auto">
                Unlock badges, track milestones, and celebrate your TFT journey coming soon.
              </p>
            </div>
          )}
        </div>
      </motion.div>
    </div>
  );
}
EOL

cat > src/pages/api/tft/leaderboard.ts << 'EOL'
import type { NextApiRequest, NextApiResponse } from 'next';
import { LeaderboardEntry } from '@/types/auth';

const RIOT_API_KEY = process.env.RIOT_API_KEY || '';

// Aggressive rate limiting for speed - optimized for parallel requests
const requestQueue: number[] = [];
const RATE_LIMIT_WINDOW = 1000; // 1 second window
const MAX_REQUESTS_PER_WINDOW = 100; // Riot allows 100 requests per 2 minutes, we'll be conservative

async function rateLimit() {
  const now = Date.now();
  // Remove old requests outside the window
  while (requestQueue.length > 0 && requestQueue[0] < now - RATE_LIMIT_WINDOW) {
    requestQueue.shift();
  }
  
  // If we're at the limit, wait until the oldest request expires
  if (requestQueue.length >= MAX_REQUESTS_PER_WINDOW) {
    const waitTime = requestQueue[0] + RATE_LIMIT_WINDOW - now + 10; // Add 10ms buffer
    if (waitTime > 0) {
      await new Promise(resolve => setTimeout(resolve, waitTime));
    }
  }
  
  requestQueue.push(Date.now());
}

const logError = (message: string, error?: any) => {
  console.error(`[TFT/LEADERBOARD] ${message}`, error);
};

// Simple cache to avoid repeated summoner name lookups
const nameCache = new Map<string, { name: string; tagLine: string; timestamp: number }>();
const CACHE_TTL = 300000; // 5 minutes

async function fetchSummonerNameByPuuid(puuid: string, region: string): Promise<{ name: string; tagLine: string } | null> {
  const cacheKey = `${puuid}-${region}`;
  const cached = nameCache.get(cacheKey);
  
  if (cached && Date.now() - cached.timestamp < CACHE_TTL) {
    return { name: cached.name, tagLine: cached.tagLine };
  }
  
  try {
    await rateLimit();
    
    // Get the game name and tag line from Account API using routing region
    const routingRegion = getRoutingRegion(region);
    
    const accountResponse = await fetch(
      `https://${routingRegion}.api.riotgames.com/riot/account/v1/accounts/by-puuid/${puuid}`,
      {
        headers: { 'X-Riot-Token': RIOT_API_KEY },
        signal: AbortSignal.timeout(2000) // Further reduced timeout for speed
      }
    );
    
    if (accountResponse.ok) {
      const account = await accountResponse.json();
      const result = {
        name: account.gameName || "Unknown Player",
        tagLine: account.tagLine || ""
      };
      
      // Cache the result
      nameCache.set(cacheKey, { ...result, timestamp: Date.now() });
      
      return result;
    }
    
    logError(`Failed to fetch account for PUUID ${puuid}: ${accountResponse.status}`);
    return null;
  } catch (error) {
    logError(`Error fetching summoner name for PUUID ${puuid}:`, error);
    return null;
  }
}

async function fetchSummonerName(summonerId: string, region: string): Promise<{ name: string; tagLine: string } | null> {
  const cacheKey = `${summonerId}-${region}`;
  const cached = nameCache.get(cacheKey);
  
  if (cached && Date.now() - cached.timestamp < CACHE_TTL) {
    return { name: cached.name, tagLine: cached.tagLine };
  }
  
  try {
    await rateLimit();
    
    // First get the PUUID from summoner ID
    const summonerResponse = await fetch(
      `https://${region}.api.riotgames.com/tft/summoner/v1/summoners/${summonerId}`,
      {
        headers: { 'X-Riot-Token': RIOT_API_KEY },
        signal: AbortSignal.timeout(2000) // Further reduced timeout for speed
      }
    );
    
    if (!summonerResponse.ok) {
      logError(`Failed to fetch summoner ${summonerId}: ${summonerResponse.status}`);
      return null;
    }
    
    const summoner = await summonerResponse.json();
    
    // Then get the game name and tag line from Account API using routing region
    const routingRegion = getRoutingRegion(region);
    await rateLimit(); // Additional rate limit for second API call
    
    const accountResponse = await fetch(
      `https://${routingRegion}.api.riotgames.com/riot/account/v1/accounts/by-puuid/${summoner.puuid}`,
      {
        headers: { 'X-Riot-Token': RIOT_API_KEY },
        signal: AbortSignal.timeout(2000) // Further reduced timeout for speed
      }
    );
    
    if (accountResponse.ok) {
      const account = await accountResponse.json();
      const result = {
        name: account.gameName || summoner.name || "Unknown Player",
        tagLine: account.tagLine || ""
      };
      
      // Cache the result
      nameCache.set(cacheKey, { ...result, timestamp: Date.now() });
      
      return result;
    }
    
    // Fallback to summoner name if account API fails
    logError(`Failed to fetch account for PUUID ${summoner.puuid}: ${accountResponse.status}`);
    const result = {
      name: summoner.name || "Unknown Player",
      tagLine: ""
    };
    
    // Cache the result
    nameCache.set(cacheKey, { ...result, timestamp: Date.now() });
    
    return result;
  } catch (error) {
    logError(`Error fetching summoner name for ${summonerId}:`, error);
    return null;
  }
}

function getRoutingRegion(region: string): string {
  const regionRouting: Record<string, string> = {
    'na1': 'americas', 'br1': 'americas', 'la1': 'americas', 'la2': 'americas',
    'euw1': 'europe', 'eun1': 'europe', 'tr1': 'europe', 'ru': 'europe',
    'kr': 'asia', 'jp1': 'asia',
    'oc1': 'sea'
  };
  
  return regionRouting[region] || 'americas';
}

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { region = 'na1', limit = '50', offset = '0' } = req.query;
    
    if (!RIOT_API_KEY) {
      return res.status(500).json({ error: 'RIOT_API_KEY is not set' });
    }
    
    const regionMapping: Record<string, string> = {
      'na': 'na1', 'na1': 'na1',
      'euw': 'euw1', 'euw1': 'euw1',
      'kr': 'kr', 'jp': 'jp1', 'jp1': 'jp1',
      'br': 'br1', 'br1': 'br1',
      'las': 'la2', 'la2': 'la2',
      'lan': 'la1', 'la1': 'la1',
      'eune': 'eun1', 'eun1': 'eun1',
      'tr': 'tr1', 'tr1': 'tr1',
      'oc': 'oc1', 'oc1': 'oc1', 'oce': 'oc1',
      'ru': 'ru'
    };
    
    const validRegion = regionMapping[region as string] || 'na1';
    const limitNumber = Math.min(parseInt(limit as string) || 50, 300); // Allow up to 300 entries
    const offsetNumber = parseInt(offset as string) || 0;
    
    let leaderboardData: any = null;
    let tier = '';
    
    const tiers = [
      { name: 'CHALLENGER', endpoint: 'challenger' },
      { name: 'GRANDMASTER', endpoint: 'grandmaster' },
      { name: 'MASTER', endpoint: 'master' }
    ];
    
    // Try to get leaderboard data with aggressive timeout
    for (const tierInfo of tiers) {
      try {
        await rateLimit();
        
        const response = await fetch(
          `https://${validRegion}.api.riotgames.com/tft/league/v1/${tierInfo.endpoint}`,
          {
            headers: { 'X-Riot-Token': RIOT_API_KEY },
            signal: AbortSignal.timeout(5000) // Reduced timeout
          }
        );
        
        if (response.ok) {
          leaderboardData = await response.json();
          tier = tierInfo.name;
          break;
        }
      } catch (error) {
        logError(`Failed to fetch ${tierInfo.name} for ${validRegion}`, error);
        continue;
      }
    }
    
    if (!leaderboardData?.entries?.length) {
      return res.status(404).json({ error: `No leaderboard data found for ${validRegion}` });
    }
    
    const allEntries = leaderboardData.entries
      .sort((a: any, b: any) => b.leaguePoints - a.leaguePoints);
    
    const topEntries = allEntries.slice(offsetNumber, offsetNumber + limitNumber);
    
    // Fetch names in parallel with larger batch size for speed
    const batchSize = 20; // Increased batch size for faster processing
    const summonerResults: Array<{ name: string; tagLine: string } | null> = [];
    
    for (let i = 0; i < topEntries.length; i += batchSize) {
      const batch = topEntries.slice(i, i + batchSize);
      const batchPromises = batch.map((entry: any) => {
        // Check if entry has puuid or summonerId
        if (entry.puuid) {
          return fetchSummonerNameByPuuid(entry.puuid, validRegion)
            .catch(() => null);
        } else if (entry.summonerId) {
          return fetchSummonerName(entry.summonerId, validRegion)
            .catch(() => null);
        } else {
          logError("Entry has neither puuid nor summonerId:", entry);
          return Promise.resolve(null);
        }
      });
      
      const batchResults = await Promise.all(batchPromises);
      summonerResults.push(...batchResults);
    }
    
    
    const processedEntries: LeaderboardEntry[] = topEntries.map((entry: any, index: number) => {
      const summonerInfo = summonerResults[index];
      
      return {
        summonerId: entry.summonerId || "",
        summonerName: summonerInfo?.name || entry.summonerName || `Player ${index + 1}`,
        tagLine: summonerInfo?.tagLine || "",
        rank: offsetNumber + index + 1, // Fix: Use offset to calculate correct global rank
        leaguePoints: entry.leaguePoints || 0,
        wins: entry.wins || 0,
        losses: entry.losses || 0,
        tier,
        division: "",
        region: validRegion
      };
    });
    
    // Aggressive caching
    res.setHeader('Cache-Control', 's-maxage=120, stale-while-revalidate=240');
    
    // Return with pagination metadata
    return res.status(200).json({
      entries: processedEntries,
      total: allEntries.length,
      offset: offsetNumber,
      limit: limitNumber,
      hasMore: offsetNumber + limitNumber < allEntries.length
    });
  } catch (error) {
    logError("Leaderboard API Error", error);
    return res.status(500).json({ error: 'Internal server error' });
  }
}
EOL

# Fix token api endpoint with correct client secret
cat > src/pages/api/auth/token.ts << 'EOL'
import type { NextApiRequest, NextApiResponse } from 'next';
import { serialize } from 'cookie';

// RSO Client credentials - Use environment variables
const RSO_CLIENT_ID = process.env.RIOT_CLIENT_ID || '';
const RSO_CLIENT_SECRET = process.env.RIOT_CLIENT_SECRET || '';
const RSO_TOKEN_URL = 'https://auth.riotgames.com/token';
const REDIRECT_URI = 'https://metaforge.lol/auth/callback';

// Cookie options
const COOKIE_OPTIONS = {
  httpOnly: true,
  secure: process.env.NODE_ENV === 'production',
  sameSite: 'lax' as const,
  path: '/',
  maxAge: 60 * 60 * 24 * 30 // 30 days
};

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  // Handle token exchange with auth code
  if (req.method === 'POST') {
    try {
      const { code } = req.body;
      
      if (!code) {
        return res.status(400).json({ error: 'Authorization code is required' });
      }
      
      if (!RSO_CLIENT_ID || !RSO_CLIENT_SECRET) {
        return res.status(500).json({ error: 'RSO client credentials are not configured' });
      }
      
      // Prepare the form data for token exchange
      const formData = new URLSearchParams();
      formData.append('grant_type', 'authorization_code');
      formData.append('code', code);
      formData.append('redirect_uri', REDIRECT_URI);
      
      // Exchange code for tokens using Basic auth with client ID and secret
      const authHeader = `Basic ${Buffer.from(`${RSO_CLIENT_ID}:${RSO_CLIENT_SECRET}`).toString('base64')}`;
      
      const tokenResponse = await fetch(RSO_TOKEN_URL, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': authHeader
        },
        body: formData
      });
      
      if (!tokenResponse.ok) {
        const errorText = await tokenResponse.text();
        return res.status(tokenResponse.status).json({ error: `Failed to exchange code for tokens: ${errorText}` });
      }
      
      const tokenData = await tokenResponse.json();
      
      // Calculate token expiration
      const expiresAt = Date.now() + (tokenData.expires_in * 1000);
      
      // Set cookies
      res.setHeader('Set-Cookie', [
        serialize('access_token', tokenData.access_token, COOKIE_OPTIONS),
        serialize('refresh_token', tokenData.refresh_token, COOKIE_OPTIONS),
        serialize('id_token', tokenData.id_token, COOKIE_OPTIONS),
        serialize('expires_at', expiresAt.toString(), COOKIE_OPTIONS)
      ]);
      
      return res.status(200).json({
        accessToken: tokenData.access_token,
        refreshToken: tokenData.refresh_token,
        idToken: tokenData.id_token,
        expiresAt
      });
    } catch (error) {
      return res.status(500).json({ error: 'Internal server error' });
    }
  } 
  // Handle token refresh
  else if (req.method === 'GET' && req.url?.includes('/refresh')) {
    try {
      const refreshToken = req.cookies.refresh_token;
      
      if (!refreshToken) {
        return res.status(401).json({ error: 'No refresh token found' });
      }
      
      if (!RSO_CLIENT_ID || !RSO_CLIENT_SECRET) {
        return res.status(500).json({ error: 'RSO client credentials are not configured' });
      }
      
      // Prepare form data for refresh
      const formData = new URLSearchParams();
      formData.append('grant_type', 'refresh_token');
      formData.append('refresh_token', refreshToken);
      
      // Refresh tokens using Basic auth with client ID and secret
      const authHeader = `Basic ${Buffer.from(`${RSO_CLIENT_ID}:${RSO_CLIENT_SECRET}`).toString('base64')}`;
      
      const tokenResponse = await fetch(RSO_TOKEN_URL, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': authHeader
        },
        body: formData
      });
      
      if (!tokenResponse.ok) {
        // Clear cookies on refresh failure
        res.setHeader('Set-Cookie', [
          serialize('access_token', '', { ...COOKIE_OPTIONS, maxAge: 0 }),
          serialize('refresh_token', '', { ...COOKIE_OPTIONS, maxAge: 0 }),
          serialize('id_token', '', { ...COOKIE_OPTIONS, maxAge: 0 }),
          serialize('expires_at', '', { ...COOKIE_OPTIONS, maxAge: 0 })
        ]);
        
        return res.status(401).json({ error: 'Failed to refresh token' });
      }
      
      const tokenData = await tokenResponse.json();
      
      // Calculate token expiration
      const expiresAt = Date.now() + (tokenData.expires_in * 1000);
      
      // Set cookies
      res.setHeader('Set-Cookie', [
        serialize('access_token', tokenData.access_token, COOKIE_OPTIONS),
        serialize('refresh_token', tokenData.refresh_token, COOKIE_OPTIONS),
        serialize('id_token', tokenData.id_token, COOKIE_OPTIONS),
        serialize('expires_at', expiresAt.toString(), COOKIE_OPTIONS)
      ]);
      
      return res.status(200).json({
        accessToken: tokenData.access_token,
        refreshToken: tokenData.refresh_token,
        idToken: tokenData.id_token,
        expiresAt
      });
    } catch (error) {
      return res.status(500).json({ error: 'Internal server error during token refresh' });
    }
  } else {
    return res.status(405).json({ error: 'Method not allowed' });
  }
}
EOL

cat > src/types/auth.ts << 'EOL'
// Authentication Types
export interface RiotUser {
  puuid: string;
  gameName: string;
  tagLine: string;
  accountId?: string;
  summonerId?: string;
  region?: string;
  profileIconId?: number;
  summonerLevel?: number;
}

export interface AuthState {
  isAuthenticated: boolean;
  isLoading: boolean;
  user: RiotUser | null;
  error: string | null;
}

export interface TokenData {
  accessToken: string;
  refreshToken: string;
  idToken: string;
  expiresAt: number;
}

export interface LeaderboardEntry {
  summonerId: string;
  summonerName: string;
  tagLine: string;
  rank: number;
  leaguePoints: number;
  wins: number;
  losses: number;
  tier: string;
  division: string;
  profileIconId?: number;
  region: string;
}

export interface MatchHistoryEntry {
  matchId: string;
  queueId: number;
  gameType: string;
  gameCreation: number;
  gameDuration: number;
  gameVersion: string;
  mapId: number;
  placement: number;
  level: number;
  augments: string[];
  traits: {
    name: string;
    numUnits: number;
    style: number;
    tierCurrent: number;
    tierTotal: number;
  }[];
  units: {
    characterId: string;
    itemNames: string[];
    rarity: number;
    tier: number;
  }[];
  companions?: {
    contentId: string;
    skinId: number;
    species: string;
  };
}

export interface PlayerStats {
  summonerId: string;
  summonerName: string;
  tagLine: string;
  tier: string;
  rank: string;
  leaguePoints: number;
  wins: number;
  losses: number;
  winRate: number;
  hotStreak: boolean;
  veteran: boolean;
  freshBlood: boolean;
  inactive: boolean;
  miniSeries?: {
    target: number;
    wins: number;
    losses: number;
    progress: string;
  };
}

export interface ErrorState {
  hasError: boolean;
  error: {
    type: string;
    message: string;
    timestamp: Date;
  };
}
EOL

# Create authentication utilities
cat > src/utils/auth/index.ts << 'EOL'
import { TokenData, RiotUser } from '@/types/auth';

// RSO Client credentials
const RSO_CLIENT_ID = process.env.NEXT_PUBLIC_RIOT_CLIENT_ID;
const REDIRECT_URI = 'https://metaforge.lol/auth/callback';

// API endpoints
const TOKEN_ENDPOINT = '/api/auth/token';
const LOGOUT_ENDPOINT = '/api/auth/logout';
const USER_ENDPOINT = '/api/auth/user';

/**
 * Generate the Riot Sign-On authorization URL
 */
export function getRSOAuthUrl(): string {
  // Required scopes for Riot authentication
  const scope = 'openid offline_access';
  
  if (!RSO_CLIENT_ID) {
    console.error('Missing NEXT_PUBLIC_RIOT_CLIENT_ID environment variable');
    return '#error-missing-client-id';
  }
  
  const params = new URLSearchParams({
    client_id: RSO_CLIENT_ID,
    redirect_uri: REDIRECT_URI,
    response_type: 'code',
    scope: scope
  });
  
  return `https://auth.riotgames.com/authorize?${params.toString()}`;
}

/**
 * Exchange authorization code for tokens
 */
export async function exchangeCodeForTokens(code: string): Promise<TokenData> {
  try {
    const response = await fetch(TOKEN_ENDPOINT, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ code })
    });
    
    if (!response.ok) {
      const responseText = await response.text();
      let errorMsg = 'Failed to exchange code for tokens';
      try {
        const errorData = JSON.parse(responseText);
        if (errorData.error) {
          errorMsg = errorData.error;
        }
      } catch (e) {
        // If JSON parsing fails, use the raw text
        errorMsg = responseText || errorMsg;
      }
      
      throw new Error(errorMsg);
    }
    
    const tokenData = await response.json();
    
    // Store token expiration in localStorage for client-side checks
    if (typeof window !== 'undefined' && tokenData.expiresAt) {
      localStorage.setItem('expires_at', tokenData.expiresAt.toString());
    }
    
    return tokenData;
  } catch (error) {
    console.error('Token exchange error:', error);
    throw error;
  }
}

/**
 * Get user data using tokens
 */
export async function getUserData(): Promise<RiotUser> {
  try {
    const response = await fetch(USER_ENDPOINT);
    
    if (!response.ok) {
      const responseText = await response.text();
      let errorMsg = 'Failed to fetch user data';
      try {
        const errorData = JSON.parse(responseText);
        if (errorData.error) {
          errorMsg = errorData.error;
        }
      } catch (e) {
        // If JSON parsing fails, use the raw text
        errorMsg = responseText || errorMsg;
      }
      
      throw new Error(errorMsg);
    }
    
    const userData = await response.json();
    return userData;
  } catch (error) {
    console.error('Get user data error:', error);
    throw error;
  }
}

/**
 * Refresh tokens when they expire
 */
export async function refreshTokens(): Promise<TokenData> {
  try {
    const response = await fetch(`${TOKEN_ENDPOINT}/refresh`, {
      method: 'GET'
    });
    
    if (!response.ok) {
      const responseText = await response.text();
      let errorMsg = 'Failed to refresh tokens';
      try {
        const errorData = JSON.parse(responseText);
        if (errorData.error) {
          errorMsg = errorData.error;
        }
      } catch (e) {
        // If JSON parsing fails, use the raw text
        errorMsg = responseText || errorMsg;
      }
      
      throw new Error(errorMsg);
    }
    
    const tokenData = await response.json();
    
    // Update token expiration in localStorage
    if (typeof window !== 'undefined' && tokenData.expiresAt) {
      localStorage.setItem('expires_at', tokenData.expiresAt.toString());
    }
    
    return tokenData;
  } catch (error) {
    console.error('Token refresh error:', error);
    throw error;
  }
}

/**
 * Logout and clear tokens
 */
export async function logout(): Promise<void> {
  try {
    await fetch(LOGOUT_ENDPOINT, {
      method: 'POST'
    });
    
    // Clear any local storage related to auth
    if (typeof window !== 'undefined') {
      localStorage.removeItem('auth_redirect');
      localStorage.removeItem('expires_at');
    }
  } catch (error) {
    console.error('Logout error:', error);
    throw error;
  }
}

/**
 * Check if the current session is authenticated
 */
export async function checkAuthStatus(): Promise<RiotUser | null> {
  try {
    const response = await fetch(USER_ENDPOINT);
    
    if (!response.ok) {
      return null;
    }
    
    const userData = await response.json();
    return userData;
  } catch (error) {
    console.error('Auth status check error:', error);
    return null;
  }
}

/**
 * Handle initial page load redirect after authentication
 */
export function handleAuthRedirect(): string | null {
  if (typeof window === 'undefined') return null;
  
  const redirectPath = localStorage.getItem('auth_redirect');
  if (redirectPath) {
    localStorage.removeItem('auth_redirect');
    return redirectPath;
  }
  
  return null;
}

/**
 * Save redirect path for after authentication
 */
export function setAuthRedirect(path: string): void {
  if (typeof window === 'undefined') return;
  localStorage.setItem('auth_redirect', path);
}

/**
 * Get token expiration status
 */
export function isTokenExpired(): boolean {
  if (typeof window === 'undefined') return true;
  
  const expiresAt = localStorage.getItem('expires_at');
  if (!expiresAt) return true;
  
  return parseInt(expiresAt) < Date.now();
}
EOL

# Create a custom hook for authentication
cat > src/hooks/useRSOAuth.ts << 'EOL'
import { useEffect, useState } from 'react';
import { useRouter } from 'next/router';
import { useAuth } from '@/utils/auth/AuthContext';
import { getRSOAuthUrl, handleAuthRedirect } from '@/utils/auth';

export function useRSOAuth() {
  const { auth, login, logout } = useAuth();
  const router = useRouter();
  const [redirectUrl, setRedirectUrl] = useState<string | null>(null);
  
  // Set up Riot Sign-On URL
  useEffect(() => {
    setRedirectUrl(getRSOAuthUrl());
  }, []);
  
  // Handle redirect after login if needed
  useEffect(() => {
    if (auth.isAuthenticated && !auth.isLoading) {
      const redirectPath = handleAuthRedirect();
      if (redirectPath) {
        router.push(redirectPath);
      }
    }
  }, [auth.isAuthenticated, auth.isLoading, router]);
  
  // Initiate login flow
  const initiateLogin = () => {
    if (redirectUrl) {
      window.location.href = redirectUrl;
    } else {
      login();
    }
  };
  
  return {
    isAuthenticated: auth.isAuthenticated,
    isLoading: auth.isLoading,
    user: auth.user,
    error: auth.error,
    login: initiateLogin,
    logout,
    redirectUrl
  };
}
EOL

# Login Button Component
cat > src/components/auth/LoginButton.tsx << 'EOL'
import React from 'react';
import { motion } from 'framer-motion';
import { LogIn } from 'lucide-react';
import { getRSOAuthUrl } from '@/utils/auth';

interface LoginButtonProps {
  className?: string;
  label?: string;
  size?: 'sm' | 'md' | 'lg';
  variant?: 'primary' | 'secondary' | 'outlined';
}

export default function LoginButton({ 
  className = '', 
  label = 'Sign in with Riot', 
  size = 'md',
  variant = 'primary'
}: LoginButtonProps) {
  const redirectUrl = getRSOAuthUrl();
  
  const sizeClasses = {
    sm: 'px-2 py-1 text-xs',
    md: 'px-4 py-2 text-sm',
    lg: 'px-6 py-3 text-base'
  };
  
  const variantClasses = {
    primary: 'bg-solar-flare/90 hover:bg-solar-flare text-void-core border-solar-flare',
    secondary: 'bg-eclipse-shadow/30 hover:bg-eclipse-shadow/50 text-corona-light border-solar-flare/40',
    outlined: 'bg-transparent hover:bg-solar-flare/10 text-solar-flare border-solar-flare/40'
  };
  
  const buttonClasses = `
    flex items-center justify-center gap-2 
    rounded-md border transition-all
    ${sizeClasses[size]} 
    ${variantClasses[variant]}
    ${className}
  `;
  
  const handleLogin = () => {
    window.location.href = redirectUrl;
  };
  
  return (
    <motion.button
      onClick={handleLogin}
      className={buttonClasses}
      whileHover={{ scale: 1.05 }}
      whileTap={{ scale: 0.95 }}
    >
      <LogIn size={size === 'sm' ? 14 : size === 'md' ? 16 : 20} />
      <span>{label}</span>
    </motion.button>
  );
}
EOL

# Auth Status Component
cat > src/components/auth/AuthStatus.tsx << 'EOL'
import React from 'react';
import { motion } from 'framer-motion';
import { LogOut, User } from 'lucide-react';
import Link from 'next/link';
import { useAuth } from '@/utils/auth/AuthContext';
import LoginButton from './LoginButton';

interface AuthStatusProps {
  showProfileButton?: boolean;
}

export default function AuthStatus({ showProfileButton = true }: AuthStatusProps) {
  const { auth, logout } = useAuth();
  const { isAuthenticated, isLoading, user } = auth;
  
  if (isLoading) {
    return (
      <div className="h-8 w-20 bg-eclipse-shadow/30 animate-pulse rounded-md"></div>
    );
  }
  
  if (isAuthenticated && user) {
    return (
      <div className="flex items-center gap-2">
        {showProfileButton && (
          <Link href="/profile">
            <motion.button
              className="flex items-center justify-center p-2 rounded-md text-corona-light hover:bg-eclipse-shadow/30 border border-solar-flare/20 hover:border-solar-flare/40 transition-all"
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
            >
              <User size={16} />
            </motion.button>
          </Link>
        )}
        
        <motion.button
          onClick={() => logout()}
          className="flex items-center justify-center p-2 rounded-md text-corona-light hover:bg-eclipse-shadow/30 border border-solar-flare/20 hover:border-solar-flare/40 transition-all hover:text-solar-flare"
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.95 }}
        >
          <LogOut size={16} />
        </motion.button>
      </div>
    );
  }
  
  return (
    <LoginButton 
      size="sm" 
      variant="outlined"
      label="Sign In"
    />
  );
}
EOL

# Protected Route Component
cat > src/components/auth/ProtectedRoute.tsx << 'EOL'
import React, { useEffect } from 'react';
import { useRouter } from 'next/router';
import { useAuth } from '@/utils/auth/AuthContext';
import { setAuthRedirect } from '@/utils/auth';

interface ProtectedRouteProps {
  children: React.ReactNode;
}

export default function ProtectedRoute({ children }: ProtectedRouteProps) {
  const { auth } = useAuth();
  const router = useRouter();
  
  useEffect(() => {
    // If not loading and not authenticated, redirect to login
    if (!auth.isLoading && !auth.isAuthenticated) {
      // Store current path for redirect after login
      setAuthRedirect(router.asPath);
      router.push('/login');
    }
  }, [auth.isLoading, auth.isAuthenticated, router]);
  
  // If still loading, show a loading state
  if (auth.isLoading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="text-center">
          <div className="inline-block h-12 w-12 border-4 border-t-gold border-r-gold/30 border-b-gold/10 border-l-gold/60 rounded-full animate-spin"></div>
          <p className="mt-4 text-corona-light">Loading...</p>
        </div>
      </div>
    );
  }
  
  // If authenticated, render children
  if (auth.isAuthenticated) {
    return <>{children}</>;
  }
  
  // Return null if not authenticated (will redirect in useEffect)
  return null;
}
EOL

# Create client-side callback handler
cat > src/pages/auth/callback.tsx << 'EOL'
import React, { useEffect, useState } from 'react';
import { useRouter } from 'next/router';
import Layout from '@/components/ui/Layout';
import { exchangeCodeForTokens, handleAuthRedirect } from '@/utils/auth';
import { useAuth } from '@/utils/auth/AuthContext';

export default function AuthCallback() {
  const router = useRouter();
  const { refreshUserData } = useAuth();
  const [error, setError] = useState<string | null>(null);
  const [isProcessing, setIsProcessing] = useState(true);
  const [debugLogs, setDebugLogs] = useState<string[]>([]);
  
  // Add debug log function
  const addLog = (message: string) => {
    setDebugLogs(prev => [...prev, `${new Date().toISOString().substring(11, 19)}: ${message}`]);
  };
  
  useEffect(() => {
    // Only run when router is ready
    if (!router.isReady) return;
    
    addLog("Router is ready, starting callback processing");
    
    async function processCallback() {
      try {
        // Get code from query
        const { code, error: queryError } = router.query;
        
        addLog(`Query params - code: ${code ? 'present' : 'missing'}, error: ${queryError || 'none'}`);
        
        if (queryError) {
          setError(queryError as string);
          setIsProcessing(false);
          setTimeout(() => router.push('/login'), 3000);
          return;
        }
        
        if (!code || typeof code !== 'string') {
          addLog('Missing authorization code');
          setError('Missing authorization code');
          setIsProcessing(false);
          setTimeout(() => router.push('/login'), 3000);
          return;
        }
        
        // Exchange code for tokens
        addLog('Exchanging code for tokens...');
        try {
          await exchangeCodeForTokens(code);
          addLog('Code exchange successful!');
        } catch (exchangeError) {
          const errorMessage = exchangeError instanceof Error ? exchangeError.message : 'Unknown error';
          addLog(`Code exchange failed: ${errorMessage}`);
          throw exchangeError;
        }
        
        // Update user data in context
        addLog('Refreshing user data...');
        try {
          await refreshUserData();
          addLog('User data refreshed successfully!');
        } catch (refreshError) {
          const errorMessage = refreshError instanceof Error ? refreshError.message : 'Unknown error';
          addLog(`User data refresh failed: ${errorMessage}`);
          throw refreshError;
        }
        
        // Check for redirect after auth
        const redirectPath = handleAuthRedirect();
        addLog(`Redirect path: ${redirectPath || 'none, defaulting to /profile'}`);
        
        // Redirect to profile or redirect path
        addLog(`Redirecting to ${redirectPath || '/profile'}`);
        router.push(redirectPath || '/profile');
      } catch (err) {
        const errorMessage = err instanceof Error ? err.message : 'Authentication failed';
        addLog(`Fatal error: ${errorMessage}`);
        setError(errorMessage);
        setIsProcessing(false);
        setTimeout(() => router.push('/login'), 5000);
      }
    }

    processCallback();
  }, [router.isReady, router.query, router, refreshUserData]);

  return (
    <Layout>
      <div className="flex flex-col items-center justify-center py-16">
        {error ? (
          <div className="text-center max-w-lg p-6 bg-red-900/20 border border-red-700/50 rounded-lg">
            <div className="text-xl text-red-400 mb-2">Authentication Error</div>
            <p className="text-corona-light mb-4">{error}</p>
            <p className="text-corona-light/60 text-sm">Redirecting to login page...</p>
            <div className="mt-4 w-16 h-1 bg-red-700/50 rounded-full mx-auto overflow-hidden">
              <div className="h-full bg-red-500 rounded-full shrink-animation"></div>
            </div>
            
            <style jsx>{`
              .shrink-animation {
                width: 100%;
                animation: shrink 5s linear forwards;
              }
              @keyframes shrink {
                from { width: 100%; }
                to { width: 0%; }
              }
            `}</style>
            
            {/* Debug information */}
            <div className="mt-6 text-left bg-brown-dark/50 p-3 rounded-md text-xs overflow-auto max-h-64">
              <div className="text-red-300 mb-1 font-semibold">Debug information:</div>
              {debugLogs.map((log, i) => (
                <div key={i} className="text-corona-light/80">{log}</div>
              ))}
            </div>
          </div>
        ) : (
          <div className="text-center max-w-lg p-8 bg-brown/10 backdrop-filter backdrop-blur-sm border border-solar-flare/30 rounded-lg">
            <div className="inline-block h-12 w-12 border-4 border-t-gold border-r-gold/30 border-b-gold/10 border-l-gold/60 rounded-full animate-spin mb-4"></div>
            <p className="text-lg text-corona-light mb-2">Completing authentication...</p>
            <p className="text-corona-light/60 text-sm">Please wait while we authenticate you with Riot Games.</p>
            
            {/* Debug information */}
            <div className="mt-6 text-left bg-brown-dark/50 p-3 rounded-md text-xs overflow-auto max-h-64">
              <div className="text-corona-light mb-1 font-semibold">Auth Progress:</div>
              {debugLogs.map((log, i) => (
                <div key={i} className="text-corona-light/80">{log}</div>
              ))}
            </div>
          </div>
        )}
      </div>
    </Layout>
  );
}
EOL

cat > src/utils/auth/AuthContext.tsx << 'EOL'
import React, { createContext, useContext, useEffect, useState, useCallback } from 'react';
import { useRouter } from 'next/router';
import { 
  checkAuthStatus, 
  logout as logoutUser, 
  getUserData, 
  refreshTokens, 
  isTokenExpired 
} from '@/utils/auth';
import { AuthState, RiotUser } from '@/types/auth';

// Initial auth state
const initialState: AuthState = {
  isAuthenticated: false,
  isLoading: true,
  user: null,
  error: null
};

// Create a dummy user for the default context
const dummyUser: RiotUser = {
  puuid: "",
  gameName: "",
  tagLine: ""
};

// Create context
const AuthContext = createContext<{
  auth: AuthState;
  login: () => void;
  logout: () => Promise<void>;
  refreshUserData: () => Promise<RiotUser>;
}>({
  auth: initialState,
  login: () => {},
  logout: async () => {},
  refreshUserData: async () => {
    throw new Error('Not implemented');
    return dummyUser;
  }
});

// Auth Provider component
export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [auth, setAuth] = useState<AuthState>(initialState);
  const router = useRouter();

  // Check auth status on component mount
  useEffect(() => {
    const checkAuth = async () => {
      try {
        const user = await checkAuthStatus();
        
        if (user) {
          setAuth({
            isAuthenticated: true,
            isLoading: false,
            user,
            error: null
          });
          
          // Check if token needs refreshing
          if (isTokenExpired()) {
            try {
              await refreshTokens();
            } catch (refreshError) {
              // Continue with session as we still have a valid user
            }
          }
        } else {
          setAuth({
            isAuthenticated: false,
            isLoading: false,
            user: null,
            error: null
          });
        }
      } catch (error) {
        setAuth({
          isAuthenticated: false,
          isLoading: false,
          user: null,
          error: error instanceof Error ? error.message : 'Authentication check failed'
        });
      }
    };

    checkAuth();
    
    // Check authentication status every 5 minutes to handle token refresh
    const intervalId = setInterval(checkAuth, 5 * 60 * 1000);
    
    // Clear interval on unmount
    return () => clearInterval(intervalId);
  }, []);

  // Redirect to login
  const login = useCallback(() => {
    // Store the current path for redirect after login
    const currentPath = router.asPath;
    if (currentPath !== '/login' && currentPath !== '/auth/callback' && !currentPath.startsWith('/api/')) {
      localStorage.setItem('auth_redirect', currentPath);
    }
    
    router.push('/login');
  }, [router]);

  // Logout function
  const logout = useCallback(async () => {
    try {
      await logoutUser();
      setAuth({
        isAuthenticated: false,
        isLoading: false,
        user: null,
        error: null
      });
      router.push('/');
    } catch (error) {
      setAuth(prev => ({
        ...prev,
        error: error instanceof Error ? error.message : 'Logout failed'
      }));
    }
  }, [router]);

  // Refresh user data
  const refreshUserData = useCallback(async (): Promise<RiotUser> => {
    try {
      const user = await getUserData();
      
      setAuth(prev => ({
        ...prev,
        isAuthenticated: true,
        user,
        error: null
      }));
      
      return user;
    } catch (error) {
      // If unauthorized, reset auth state
      if (error instanceof Error && error.message.includes('401')) {
        setAuth({
          isAuthenticated: false,
          isLoading: false,
          user: null,
          error: error.message
        });
      } else {
        setAuth(prev => ({
          ...prev,
          error: error instanceof Error ? error.message : 'Failed to refresh user data'
        }));
      }
      
      throw error;
    }
  }, []);

  return (
    <AuthContext.Provider value={{ auth, login, logout, refreshUserData }}>
      {children}
    </AuthContext.Provider>
  );
};

// Custom hook to use auth context
export const useAuth = () => useContext(AuthContext);
EOL

# Leaderboard page with glass styling
cat > src/pages/leaderboard/index.tsx << 'EOL'
import React, { useState, useMemo, useCallback } from 'react';
import { useQuery, useQueryClient } from '@tanstack/react-query';
import { motion, AnimatePresence } from 'framer-motion';
import Layout from '@/components/ui/Layout';
import { Search, RefreshCw, Trophy, Loader2, ChevronDown, Globe } from 'lucide-react';
import RegionFilter from '@/components/leaderboard/RegionFilter';
import TopPlayers from '@/components/leaderboard/TopPlayers';
import { LeaderboardEntry } from '@/types/auth';
import { Card } from '@/components/ui';

export default function LeaderboardPage() {
  const queryClient = useQueryClient();
  const [activeRegion, setActiveRegion] = useState('ALL');
  const [search, setSearch] = useState('');
  const [allEntries, setAllEntries] = useState<LeaderboardEntry[]>([]);
  const [hasMore, setHasMore] = useState(true);
  const [offset, setOffset] = useState(0);
  const [isLoadingMore, setIsLoadingMore] = useState(false);
  
  const regions = [
    { id: 'ALL', name: 'ALL' },
    { id: 'na1', name: 'NA' },
    { id: 'euw1', name: 'EUW' },
    { id: 'kr', name: 'KR' },
    { id: 'eun1', name: 'EUNE' },
    { id: 'br1', name: 'BR' },
    { id: 'jp1', name: 'JP' },
    { id: 'la1', name: 'LAN' },
    { id: 'la2', name: 'LAS' },
    { id: 'tr1', name: 'TR' },
    { id: 'ru', name: 'RU' }
  ];
  
  // Global leader query - cached for longer
  const {
    data: globalLeader,
    isLoading: isLoadingGlobal
  } = useQuery({
    queryKey: ['globalLeaderboard'],
    queryFn: async () => {
      const response = await fetch('/api/tft/leaderboard/global');
      if (!response.ok) throw new Error('Failed to fetch global leader');
      return response.json();
    },
    staleTime: 600000, // 10 minutes
    retry: 1
  });
  
  // Fetch initial data - force fresh fetch every time
  const {
    data: initialData,
    isLoading: isInitialLoading,
    isError,
    error,
    refetch
  } = useQuery<{
    entries: LeaderboardEntry[];
    total: number;
    offset: number;
    limit: number;
    hasMore: boolean;
  }>({
    queryKey: ['leaderboard', activeRegion], // Keep simple key
    queryFn: async () => {
      const endpoint = activeRegion === 'ALL' 
        ? '/api/tft/leaderboard/global' 
        : `/api/tft/leaderboard?region=${activeRegion}&limit=50&offset=0&_t=${Date.now()}`;
      
      const response = await fetch(endpoint);
      if (!response.ok) {
        throw new Error('Failed to fetch leaderboard data');
      }
      
      const data = await response.json();
      
      // If it's global data, format it to match the expected structure
      if (activeRegion === 'ALL' && data && !Array.isArray(data)) {
        return {
          entries: [data],
          total: 1,
          offset: 0,
          limit: 1,
          hasMore: false
        };
      }
      
      return data;
    },
    staleTime: 0, // Never consider data stale - always fetch fresh
    cacheTime: 0, // Don't cache at all
    retry: 1,
    refetchOnWindowFocus: false,
    enabled: !!activeRegion // Only run query when we have a region
  });
  
  // Load more function
  const loadMore = useCallback(async () => {
    if (!hasMore || isLoadingMore || activeRegion === 'ALL') return; // Don't load more for ALL
    
    setIsLoadingMore(true);
    try {
      const response = await fetch(
        `/api/tft/leaderboard?region=${activeRegion}&limit=50&offset=${allEntries.length}&_t=${Date.now()}`
      );
      
      if (!response.ok) throw new Error('Failed to load more');
      
      const data = await response.json();
      
      // Only append if we got new entries
      if (data.entries && data.entries.length > 0) {
        setAllEntries(prev => [...prev, ...data.entries]);
        setHasMore(data.hasMore);
      } else {
        // No more entries available
        setHasMore(false);
      }
    } catch (error) {
      // Handle error silently but stop trying to load more
      setHasMore(false);
    } finally {
      setIsLoadingMore(false);
    }
  }, [activeRegion, allEntries.length, hasMore, isLoadingMore]);
  
  // Handle region change with proper cleanup
  const handleRegionChange = useCallback((newRegion: string) => {
    if (newRegion !== activeRegion) {
      setActiveRegion(newRegion);
    }
  }, [activeRegion]);
  
  // Update state when initial data loads
  React.useEffect(() => {
    if (initialData && initialData.entries) {
      setAllEntries(initialData.entries);
      setHasMore(initialData.hasMore);
    }
  }, [initialData]);
  
  // Reset when region changes and force refetch
  React.useEffect(() => {
    setAllEntries([]);
    setOffset(0);
    setHasMore(true);
    setSearch('');
    setIsLoadingMore(false);
    
    // Remove all cached data for leaderboard
    queryClient.removeQueries({ queryKey: ['leaderboard'] });
    
    // Manually trigger refetch after a small delay to ensure state is reset
    setTimeout(() => {
      refetch();
    }, 100);
  }, [activeRegion, queryClient, refetch]);
  
  const filteredPlayers = useMemo(() => {
    if (!allEntries || !search.trim()) return allEntries || [];
    
    const searchLower = search.toLowerCase().trim();
    return allEntries.filter(player => 
      player.summonerName.toLowerCase().includes(searchLower) ||
      (player.tagLine && player.tagLine.toLowerCase().includes(searchLower))
    );
  }, [allEntries, search]);
  
  const stats = useMemo(() => {
    if (!allEntries?.length) return null;
    
    const topLocal = allEntries[0];
    const totalGames = allEntries.reduce((sum, player) => sum + player.wins + player.losses, 0);
    const avgLP = Math.round(allEntries.reduce((sum, player) => sum + player.leaguePoints, 0) / allEntries.length);
    const avgWinRate = allEntries.reduce((sum, player) => {
      const total = player.wins + player.losses;
      return sum + (total > 0 ? (player.wins / total) * 100 : 0);
    }, 0) / allEntries.length;
    
    return { 
      globalLeader, 
      topLocal, 
      totalGames, 
      avgLP,
      avgWinRate: avgWinRate.toFixed(1),
      playerCount: initialData?.total || allEntries.length 
    };
  }, [allEntries, globalLeader, initialData]);

  return (
    <Layout title="TFT Leaderboard - Top Ranked Players">
      <div className="container mx-auto px-4 py-8 max-w-7xl">
        {/* Hero Section with Fight Banner */}
        <motion.div 
          className="relative overflow-hidden rounded-xl mb-8"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6 }}
        >
          <div className="absolute inset-0 bg-gradient-to-r from-void-core via-eclipse-shadow to-void-core opacity-65"></div>
          <div className="absolute inset-0 bg-[url('/assets/app/fight_banner.jpg')] bg-cover bg-center opacity-30"></div>
          <div className="absolute inset-0 border border-solar-flare/40 rounded-xl"></div>
          
          <div className="relative z-10 px-8 py-16 text-center">
            <motion.h1 
              className="text-3xl md:text-4xl font-display mb-4"
              initial={{ y: 20, opacity: 0 }}
              animate={{ y: 0, opacity: 1 }}
              transition={{ delay: 0.3, duration: 0.5 }}
            >
              <span className="text-solar-flare">Global</span>{' '}
              <span className="text-stellar-white">Leaderboard</span>
            </motion.h1>
            
            <motion.p 
              className="text-corona-light/80 max-w-2xl mx-auto text-lg mb-8"
              initial={{ y: 20, opacity: 0 }}
              animate={{ y: 0, opacity: 1 }}
              transition={{ delay: 0.4, duration: 0.5 }}
            >
              Track the highest ranked TFT players across all regions and see where you stand in the competitive arena.
            </motion.p>
            
            {/* Stats Cards */}
            {stats && !isInitialLoading && (
              <motion.div 
                className="grid grid-cols-2 md:grid-cols-5 gap-4 max-w-5xl mx-auto"
                initial={{ y: 20, opacity: 0 }}
                animate={{ y: 0, opacity: 1 }}
                transition={{ delay: 0.5, duration: 0.5 }}
              >
                <motion.div 
                  className="bg-void-core/80 backdrop-blur-sm border border-solar-flare/40 rounded-lg p-4 text-center hover:border-solar-flare/60 transition-all"
                  whileHover={{ scale: 1.05 }}
                  transition={{ duration: 0.2 }}
                >
                  <div className="text-xl font-bold text-stellar-white">
                    {isLoadingGlobal ? (
                      <Loader2 className="h-5 w-5 animate-spin mx-auto" />
                    ) : (
                      globalLeader ? `${globalLeader.leaguePoints.toLocaleString()}` : 'N/A'
                    )}
                  </div>
                  <div className="text-xs text-corona-light/70">
                    {isLoadingGlobal ? 'Loading...' : 'Global #1 LP'}
                  </div>
                </motion.div>
                
                <motion.div 
                  className="bg-void-core/80 backdrop-blur-sm border border-solar-flare/40 rounded-lg p-4 text-center hover:border-solar-flare/60 transition-all"
                  whileHover={{ scale: 1.05 }}
                  transition={{ duration: 0.2 }}
                >
                  <div className="text-xl font-bold text-stellar-white">
                    {stats.topLocal.leaguePoints.toLocaleString()}
                  </div>
                  <div className="text-xs text-corona-light/70">
                    {activeRegion.toUpperCase()} #1 LP
                  </div>
                </motion.div>
                
                <motion.div 
                  className="bg-void-core/80 backdrop-blur-sm border border-solar-flare/40 rounded-lg p-4 text-center hover:border-solar-flare/60 transition-all"
                  whileHover={{ scale: 1.05 }}
                  transition={{ duration: 0.2 }}
                >
                  <div className="text-xl font-bold text-stellar-white">
                    {stats.avgLP.toLocaleString()}
                  </div>
                  <div className="text-xs text-corona-light/70">Average LP</div>
                </motion.div>
                
                <motion.div 
                  className="bg-void-core/80 backdrop-blur-sm border border-solar-flare/40 rounded-lg p-4 text-center hover:border-solar-flare/60 transition-all"
                  whileHover={{ scale: 1.05 }}
                  transition={{ duration: 0.2 }}
                >
                  <div className="text-xl font-bold text-stellar-white">
                    {stats.avgWinRate}%
                  </div>
                  <div className="text-xs text-corona-light/70">Avg Win Rate</div>
                </motion.div>
                
                <motion.div 
                  className="bg-void-core/80 backdrop-blur-sm border border-solar-flare/40 rounded-lg p-4 text-center hover:border-solar-flare/60 transition-all"
                  whileHover={{ scale: 1.05 }}
                  transition={{ duration: 0.2 }}
                >
                  <div className="text-xl font-bold text-stellar-white">
                    {stats.playerCount}
                  </div>
                  <div className="text-xs text-corona-light/70">Total Players</div>
                </motion.div>
              </motion.div>
            )}
          </div>
        </motion.div>
        
        {/* Main Content */}
        <Card className="bg-brown-light/10 border-gold/10 overflow-hidden">
          {/* Filters Section */}
          <div className="p-6 border-b border-gold/10">
            <div className="space-y-6">
              {/* Region Selector */}
              <div>
                <div className="flex items-center gap-2 mb-4">
                  <Globe className="h-5 w-5 text-gold" />
                  <h3 className="text-lg font-semibold text-cream">Select Region</h3>
                </div>
                <div className="flex flex-wrap gap-2">
                  {regions.map(region => (
                    <button
                      key={region.id}
                      onClick={() => handleRegionChange(region.id)}
                      disabled={isInitialLoading}
                      className={`px-4 py-2 rounded-lg font-medium transition-all ${
                        activeRegion === region.id
                          ? 'bg-gold text-brown'
                          : 'bg-brown/40 text-cream hover:bg-brown/60'
                      } ${isInitialLoading ? 'opacity-50 cursor-not-allowed' : ''}`}
                    >
                      {region.name}
                    </button>
                  ))}
                </div>
              </div>
              
              {/* Search and Refresh */}
              <div className="flex flex-col md:flex-row gap-4">
                <div className="flex-1 relative">
                  <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-cream/50" />
                  <input
                    type="text"
                    value={search}
                    onChange={(e) => setSearch(e.target.value)}
                    placeholder="Search players..."
                    className="w-full pl-10 pr-4 py-3 bg-brown/30 border border-gold/20 rounded-lg text-cream placeholder-cream/50 focus:outline-none focus:border-gold/40 transition-colors"
                  />
                </div>
                <button
                  onClick={() => refetch()}
                  disabled={isInitialLoading}
                  className="px-6 py-3 bg-brown/40 hover:bg-brown/60 text-cream rounded-lg font-medium transition-colors flex items-center gap-2 disabled:opacity-50"
                >
                  <RefreshCw className={`h-5 w-5 ${isInitialLoading ? 'animate-spin' : ''}`} />
                  Refresh
                </button>
              </div>
            </div>
          </div>
          
          {/* Players List */}
          <div className="relative">
            {isInitialLoading ? (
              <div className="p-8">
                <div className="flex flex-col items-center justify-center space-y-4">
                  <Loader2 className="h-12 w-12 animate-spin text-gold" />
                  <p className="text-cream/70">Loading leaderboard...</p>
                </div>
              </div>
            ) : isError ? (
              <div className="p-8">
                <div className="bg-red-900/20 border border-red-600/30 rounded-lg p-6 text-center">
                  <Trophy className="h-12 w-12 mx-auto text-red-500 mb-4" />
                  <h3 className="text-xl font-semibold text-cream mb-2">Failed to Load Leaderboard</h3>
                  <p className="text-cream/70 mb-4">{(error as Error)?.message || 'Something went wrong'}</p>
                  <button
                    onClick={() => refetch()}
                    className="px-6 py-2 bg-red-600 hover:bg-red-700 text-white rounded-lg font-medium transition-colors"
                  >
                    Try Again
                  </button>
                </div>
              </div>
            ) : allEntries.length > 0 ? (
              <>
                <TopPlayers 
                  players={filteredPlayers} 
                  isLoading={false}
                  region={activeRegion}
                />
                
                {/* Load More */}
                {hasMore && !search && allEntries.length > 0 && (
                  <div className="p-6 border-t border-gold/10">
                    <div className="text-center">
                      <button
                        onClick={loadMore}
                        disabled={isLoadingMore}
                        className={`px-8 py-3 rounded-lg font-medium transition-all flex items-center gap-3 mx-auto ${
                          isLoadingMore
                            ? 'bg-brown/30 text-cream/50 cursor-not-allowed'
                            : 'bg-gold text-brown hover:bg-gold-light'
                        }`}
                      >
                        {isLoadingMore ? (
                          <>
                            <Loader2 className="h-5 w-5 animate-spin" />
                            Loading more...
                          </>
                        ) : (
                          <>
                            <ChevronDown className="h-5 w-5" />
                            Load More Players
                            <span className="text-sm opacity-80">
                              ({allEntries.length} of {initialData?.total || '?'})
                            </span>
                          </>
                        )}
                      </button>
                    </div>
                  </div>
                )}
              </>
            ) : (
              <div className="p-8 text-center">
                <Trophy className="h-16 w-16 mx-auto text-gold/50 mb-4" />
                <h3 className="text-xl font-display text-cream mb-2">No Players Found</h3>
                <p className="text-cream/70">
                  This region might not have ranked players yet, or there might be an issue loading the data.
                </p>
              </div>
            )}
          </div>
        </Card>
      </div>
    </Layout>
  );
}
EOL

# User endpoint for getting user data
cat > src/pages/api/auth/user.ts << 'EOL'
import type { NextApiRequest, NextApiResponse } from 'next';
import { RiotUser } from '@/types/auth';

// Riot API key for additional data (optional)
const RIOT_API_KEY = process.env.RIOT_API_KEY || '';

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  // Only allow GET requests
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    // Check for access token
    const accessToken = req.cookies.access_token;
    const expiresAt = req.cookies.expires_at;
    
    if (!accessToken) {
      return res.status(401).json({ error: 'Not authenticated' });
    }
    
    // Check if token is expired
    if (expiresAt && parseInt(expiresAt) < Date.now()) {
      return res.status(401).json({ error: 'Token expired' });
    }
    
    // Fetch account info from Riot using their Account API
    const accountResponse = await fetch('https://americas.api.riotgames.com/riot/account/v1/accounts/me', {
      headers: {
        'Authorization': `Bearer ${accessToken}`
      }
    });
    
    if (!accountResponse.ok) {
      return res.status(accountResponse.status).json({ error: 'Failed to fetch account data' });
    }
    
    const accountData = await accountResponse.json();
    
    // Create user object with basic data
    const user: RiotUser = {
      puuid: accountData.puuid,
      gameName: accountData.gameName,
      tagLine: accountData.tagLine
    };
    
    // If we have an API key, try to fetch additional summoner data
    if (RIOT_API_KEY) {
      try {
        // Try regions one by one to find the player's main region
        const regions = ['na1', 'euw1', 'kr', 'br1', 'jp1', 'eun1', 'la1', 'la2', 'tr1', 'ru', 'oc1'];
        
        for (const region of regions) {
          const summonerResponse = await fetch(
            `https://${region}.api.riotgames.com/tft/summoner/v1/summoners/by-puuid/${user.puuid}`,
            {
              headers: {
                'X-Riot-Token': RIOT_API_KEY
              }
            }
          );
          
          if (summonerResponse.ok) {
            const summonerData = await summonerResponse.json();
            
            // Add summoner data to user object
            user.summonerId = summonerData.id;
            user.profileIconId = summonerData.profileIconId;
            user.summonerLevel = summonerData.summonerLevel;
            user.region = region;
            break;
          }
        }
      } catch (error) {
        // Don't fail if we can't get summoner data, just continue
      }
    }
    
    // Return the user data
    return res.status(200).json(user);
  } catch (error) {
    return res.status(500).json({ error: 'Internal server error' });
  }
}
EOL

# Logout endpoint
cat > src/pages/api/auth/logout.ts << 'EOL'
import type { NextApiRequest, NextApiResponse } from 'next';
import { serialize } from 'cookie';

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  // Only allow POST requests
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  // Clear all auth cookies
  res.setHeader('Set-Cookie', [
    serialize('access_token', '', { 
      httpOnly: true, 
      secure: process.env.NODE_ENV === 'production', 
      sameSite: 'lax', 
      path: '/', 
      maxAge: 0 
    }),
    serialize('refresh_token', '', { 
      httpOnly: true, 
      secure: process.env.NODE_ENV === 'production', 
      sameSite: 'lax', 
      path: '/', 
      maxAge: 0 
    }),
    serialize('id_token', '', { 
      httpOnly: true, 
      secure: process.env.NODE_ENV === 'production', 
      sameSite: 'lax', 
      path: '/', 
      maxAge: 0 
    }),
    serialize('expires_at', '', { 
      httpOnly: true, 
      secure: process.env.NODE_ENV === 'production', 
      sameSite: 'lax', 
      path: '/', 
      maxAge: 0 
    })
  ]);

  return res.status(200).json({ success: true });
}
EOL

# Create Leaderboard components
cat > src/components/leaderboard/RegionFilter.tsx << 'EOL'
import React from 'react';
import { motion } from 'framer-motion';
import { Globe, Loader2 } from 'lucide-react';

interface Region {
  id: string;
  name: string;
}

interface RegionFilterProps {
  regions: Region[];
  activeRegion: string;
  onChange: (region: string) => void;
  isLoading?: boolean;
}

export default function RegionFilter({ regions, activeRegion, onChange, isLoading = false }: RegionFilterProps) {
  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <Globe className="h-5 w-5 text-solar-flare" />
        <h3 className="text-lg font-display text-stellar-white">Navigate Regions</h3>
        {isLoading && (
          <Loader2 className="h-4 w-4 text-solar-flare animate-spin" />
        )}
      </div>
      
      <div className="flex flex-wrap gap-3 max-w-full">
        {regions.map(region => (
          <motion.button
            key={region.id}
            className={`px-5 py-3 rounded-lg backdrop-filter backdrop-blur-sm border transition-all text-sm font-medium ${
              activeRegion === region.id 
                ? 'bg-solar-flare text-void-core border-solar-flare shadow-solar' 
                : 'bg-void-core/60 text-corona-light hover:bg-void-core/80 border-solar-flare/30 hover:border-solar-flare/50'
            } ${isLoading ? 'opacity-50 cursor-not-allowed' : ''}`}
            onClick={() => !isLoading && onChange(region.id)}
            disabled={isLoading}
            whileHover={!isLoading ? { scale: 1.05 } : {}}
            whileTap={!isLoading ? { scale: 0.98 } : {}}
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.2 }}
          >
            {region.name}
          </motion.button>
        ))}
      </div>
    </div>
  );
}
EOL

cat > src/components/leaderboard/TopPlayers.tsx << 'EOL'
import React, { useState, useMemo } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { ArrowUp, ArrowDown, ExternalLink, Trophy, Crown, Medal, Star } from 'lucide-react';
import { useRouter } from 'next/router';
import { LeaderboardEntry } from '@/types/auth';

interface TopPlayersProps {
  players: LeaderboardEntry[];
  isLoading: boolean;
  region: string;
}

type SortField = 'rank' | 'leaguePoints' | 'wins' | 'losses' | 'winRate';
type SortDirection = 'asc' | 'desc';

export default function TopPlayers({ players, isLoading, region }: TopPlayersProps) {
  const router = useRouter();
  const [sort, setSort] = useState<SortField>('rank');
  const [direction, setDirection] = useState<SortDirection>('asc');
  
  const sortedPlayers = useMemo(() => {
    if (!players?.length) return [];
    
    return [...players].sort((a, b) => {
      let aVal: number, bVal: number;
      
      switch (sort) {
        case 'winRate':
          aVal = a.wins + a.losses > 0 ? (a.wins / (a.wins + a.losses)) * 100 : 0;
          bVal = b.wins + b.losses > 0 ? (b.wins / (b.wins + b.losses)) * 100 : 0;
          break;
        default:
          aVal = a[sort] as number;
          bVal = b[sort] as number;
      }
      
      return direction === 'asc' ? aVal - bVal : bVal - aVal;
    });
  }, [players, sort, direction]);
  
  const handleSort = (field: SortField) => {
    if (field === sort) {
      setDirection(direction === 'asc' ? 'desc' : 'asc');
    } else {
      setSort(field);
      setDirection(field === 'rank' ? 'asc' : 'desc');
    }
  };

  const handlePlayerClick = (player: LeaderboardEntry) => {
    router.push(`/player/${player.summonerId}?region=${region}`);
  };
  
  const getRankIcon = (rank: number) => {
    if (rank === 1) return <Crown className="h-5 w-5 text-gold" />;
    if (rank === 2) return <Medal className="h-5 w-5 text-gray-400" />;
    if (rank === 3) return <Trophy className="h-5 w-5 text-orange-600" />;
    if (rank <= 10) return <Star className="h-4 w-4 text-gold" />;
    return null;
  };
  
  const getTierColor = (tier: string) => {
    const colors = {
      IRON: 'text-gray-500',
      BRONZE: 'text-orange-700',
      SILVER: 'text-gray-400',
      GOLD: 'text-yellow-500',
      PLATINUM: 'text-cyan-400',
      DIAMOND: 'text-purple-400',
      MASTER: 'text-purple-600',
      GRANDMASTER: 'text-red-500',
      CHALLENGER: 'text-gold'
    };
    return colors[tier as keyof typeof colors] || 'text-cream';
  };
  
  if (isLoading && !players?.length) {
    return (
      <div className="p-6">
        <div className="space-y-3">
          {[...Array(10)].map((_, i) => (
            <div key={i} className="bg-brown/20 rounded-lg p-4 animate-pulse">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-4">
                  <div className="h-6 w-12 bg-brown/40 rounded"></div>
                  <div className="h-6 w-48 bg-brown/40 rounded"></div>
                </div>
                <div className="flex gap-6">
                  <div className="h-6 w-16 bg-brown/40 rounded"></div>
                  <div className="h-6 w-16 bg-brown/40 rounded"></div>
                  <div className="h-6 w-16 bg-brown/40 rounded"></div>
                  <div className="h-6 w-16 bg-brown/40 rounded"></div>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    );
  }
  
  if (!players?.length) {
    return (
      <div className="p-8 text-center">
        <Trophy className="h-16 w-16 mx-auto text-solar-flare/50 mb-4" />
        <h3 className="text-xl font-display text-stellar-white mb-2">No Players Found</h3>
        <p className="text-corona-light/70">
          This region might not have ranked players yet, or there might be an issue loading the data.
        </p>
      </div>
    );
  }
  
  const columns = [
    { id: 'leaguePoints', name: 'LP', sortable: true },
    { id: 'wins', name: 'Wins', sortable: true },
    { id: 'losses', name: 'Losses', sortable: true },
    { id: 'winRate', name: 'WR%', sortable: true }
  ];
  
  return (
    <div>
      {/* Header */}
      <div className="px-6 py-4 border-b border-gold/10 bg-brown/20">
        <div className="flex items-center">
          <div className="flex-1 grid grid-cols-12 gap-4 text-sm font-medium text-cream/70">
            <div className="col-span-1 text-center">Rank</div>
            <div className="col-span-5">Player</div>
            <div className="col-span-6 grid grid-cols-4 gap-4">
              {columns.map(column => (
                <button 
                  key={column.id} 
                  className={`flex items-center justify-center transition-colors ${
                    sort === column.id ? 'text-gold' : 'hover:text-cream'
                  } ${column.sortable ? 'cursor-pointer' : ''}`}
                  onClick={() => column.sortable && handleSort(column.id as SortField)}
                  disabled={!column.sortable}
                >
                  {column.name}
                  {column.sortable && sort === column.id && (
                    <motion.div
                      initial={{ scale: 0.8, opacity: 0 }}
                      animate={{ scale: 1, opacity: 1 }}
                      transition={{ duration: 0.2 }}
                    >
                      {direction === 'asc' ? 
                        <ArrowUp className="ml-1 h-3 w-3" /> : 
                        <ArrowDown className="ml-1 h-3 w-3" />
                      }
                    </motion.div>
                  )}
                </button>
              ))}
            </div>
          </div>
        </div>
      </div>
      
      {/* Player List */}
      <div className="divide-y divide-gold/10">
        <AnimatePresence mode="popLayout">
          {sortedPlayers.map((player, index) => {
            const winRate = player.wins + player.losses > 0 
              ? ((player.wins / (player.wins + player.losses)) * 100).toFixed(1)
              : '0.0';
            
            return (
              <motion.div 
                key={`${player.summonerId}-${player.rank}`}
                className="px-6 py-4 hover:bg-brown/20 transition-colors cursor-pointer group"
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                exit={{ opacity: 0 }}
                transition={{ duration: 0.2, delay: index * 0.01 }}
                onClick={() => handlePlayerClick(player)}
                layout
              >
                <div className="grid grid-cols-12 gap-4 items-center">
                  {/* Rank */}
                  <div className="col-span-1 flex items-center justify-center">
                    <div className="flex items-center gap-1">
                      {getRankIcon(player.rank)}
                      <span className="font-bold text-lg text-cream">
                        {player.rank}
                      </span>
                    </div>
                  </div>
                  
                  {/* Player Info */}
                  <div className="col-span-5 flex items-center gap-3">
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2">
                        <span className="font-medium text-cream truncate">
                          {player.summonerName || "Unknown"}
                        </span>
                        {player.tagLine && (
                          <span className="text-sm text-cream/60">
                            #{player.tagLine}
                          </span>
                        )}
                        <ExternalLink className="h-4 w-4 text-cream/40 opacity-0 group-hover:opacity-100 transition-opacity flex-shrink-0" />
                      </div>
                      <div className={`text-sm font-medium ${getTierColor(player.tier)}`}>
                        {player.tier} {player.division}
                      </div>
                    </div>
                  </div>
                  
                  {/* Stats */}
                  <div className="col-span-6 grid grid-cols-4 gap-4 text-sm">
                    <div className="text-center">
                      <div className="font-bold text-gold text-lg">
                        {player.leaguePoints.toLocaleString()}
                      </div>
                    </div>
                    <div className="text-center">
                      <div className="font-medium text-green-500">
                        {player.wins}
                      </div>
                    </div>
                    <div className="text-center">
                      <div className="font-medium text-red-500">
                        {player.losses}
                      </div>
                    </div>
                    <div className="text-center">
                      <div className={`font-medium ${
                        parseFloat(winRate) > 65 ? 'text-gold font-medium' : 
                        parseFloat(winRate) > 55 ? 'text-amber-300 font-medium' : 
                        parseFloat(winRate) < 45 ? 'text-red-400' : 
                        'text-cream'
                      }`}>
                        {winRate}%
                      </div>
                    </div>
                  </div>
                </div>
              </motion.div>
            );
          })}
        </AnimatePresence>
      </div>
    </div>
  );
}
EOL


# Create the completely reworked database utility
cat > readme.md << 'EOL'
<div align="center">
 
# ⚔️ MetaForge

### *TeamFight Tactics Platform*
 
[![Next.js](https://img.shields.io/badge/Next.js-000000?style=for-the-badge&logo=next.js&logoColor=white)](https://nextjs.org)
[![TypeScript](https://img.shields.io/badge/TypeScript-3178C6?style=for-the-badge&logo=typescript&logoColor=white)](https://typescript.org)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)](https://postgresql.org)

*Where data-driven analytics meets community predictions*

---

## 🎮 How it works

Players compete through two ranking systems:

<table>
<tr>
<td align="center" width="50%">

### 🏆 LP (League Points)
Traditional performance ranking  
*Earn through gameplay*

</td>
<td align="center" width="50%">

### 🔮 PP (Prediction Points)
Meta forecasting accuracy  
*Earn through correct predictions*

</td>
</tr>
</table>

---

## 🔮 Core Features

<table>
<tr>
<td align="center">

### 🔍 Stats Explorer
Deep dive into units & traits  
Performance analytics

</td>
<td align="center">

### 🛠️ Team Builder
Interactive comp builder  
Drag & drop interface

</td>
<td align="center">

### 🗳️ Meta Predictions
Submit and vote on changes  
Vote checks every patch (2-weeks)

</td>
</tr>
</table>

**🏆 Dual Leaderboards** • **👤 Player Profiles** • **📊 Meta Reports**

---

## 💻 Tech Stack

```javascript
const tech = {
  frontend: ["Next.js", "TypeScript", "Tailwind CSS", "React Query"],
  backend: ["Next.js API Routes", "PostgreSQL", "Riot Games API"],
  infrastructure: ["Neon Database", "Vercel", "Rate Limiting"]
};
```

---

## 🚀 Development

```bash
# Setup
git clone https://github.com/gaba-dev/metaforge.git
cd metaforge
npm install

# Configure
cp .env.example .env.local

# Run
npm run dev
```

---

[![Live Demo](https://img.shields.io/badge/Live_Demo-f59e0b?style=for-the-badge&logo=rocket&logoColor=white)](https://metaforge.lol)

</div>
EOL

log "Starting MetaForge..."
npm install && npm run build && npm start