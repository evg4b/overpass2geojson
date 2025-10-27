# Build Instructions

## Quick Start

This project uses **rspack** for bundling and **Node.js SEA** (Single Executable Application) for creating standalone executables.

## Prerequisites

- Node.js >= 16
- yarn (v4.10.3 or later)

## Standard Build

Build the application as a CommonJS bundle:

```bash
yarn build
```

This creates `dist/cli.cjs` (530 KB) - a single JavaScript bundle with all dependencies included.

**Run the bundle:**
```bash
node dist/cli.cjs
```

> **Note:** The application will keep running until you press `q` or `Ctrl+C` to exit.

## SEA Build (Single Executable Application)

Create a completely standalone executable that doesn't require Node.js or node_modules.

### macOS / Linux

```bash
yarn build:sea:macos   # or yarn build:sea:linux
```

**Output:** `overpass2geojson-macos-arm64` or `overpass2geojson-linux-x64` (~106 MB)

**Run:**
```bash
./overpass2geojson-macos-arm64
```

The application will display a greeting and wait for user input. Press `q` or `Ctrl+C` to exit.

### Windows

```bash
yarn build:sea:windows
```

**Output:** `overpass2geojson-windows-x64.exe` (~106 MB)

**Run:**
```cmd
overpass2geojson-windows-x64.exe
```

The application will display a greeting and wait for user input. Press `q` or `Ctrl+C` to exit.

## Available Scripts

| Command | Description |
|---------|-------------|
| `yarn build` | Build rspack bundle (dist/cli.cjs) |
| `yarn build:sea:macos` | Build SEA for macOS |
| `yarn build:sea:linux` | Build SEA for Linux |
| `yarn build:sea:windows` | Build SEA for Windows |
| `yarn dev` | Watch mode for development |
| `yarn test` | Run tests |

## Build Output

### Rspack Bundle
- **File:** `dist/cli.cjs`
- **Size:** ~530 KB
- **Requires:** Node.js runtime
- **Dependencies:** All NPM packages bundled (React, Ink, etc.)

### SEA Executable
- **Files:** Platform-specific executables
- **Size:** ~106 MB (includes Node.js runtime)
- **Requires:** Nothing - completely standalone
- **Dependencies:** Everything embedded (Node.js + all packages)

## Cross-Platform Building

SEA executables must be built on their target platform:
- **macOS binary** → build on macOS
- **Linux binary** → build on Linux
- **Windows binary** → build on Windows

This is because SEA embeds the native Node.js binary for that platform.

## Technical Details

### Rspack Configuration
- **Entry:** `source/cli.tsx`
- **Target:** Node.js (CommonJS)
- **Mode:** Production
- **Bundling:** All NPM dependencies included
- **Externals:** Node.js built-in modules (fs, path, crypto, etc.)
- **Source maps:** Disabled

### SEA Configuration
- **Tool:** Node.js built-in SEA support (v22+)
- **Injection:** postject
- **Format:** Node.js executable with embedded blob
- **Code cache:** Enabled for faster startup

## Troubleshooting

**Problem:** "Error: Executable must be a supported format"
- **Solution:** The script automatically detects and uses the real Node.js binary via `process.execPath`

**Problem:** SEA is too large
- **Solution:** This is normal - SEA includes entire Node.js runtime (~100 MB). The advantage is zero dependencies.

**Problem:** Permission denied on Linux/macOS
- **Solution:** Run `chmod +x overpass2geojson-*`

## File Structure

```
overpass2geojson/
├── scripts/
│   ├── build-sea.sh     # Unix build script
│   └── build-sea.bat    # Windows build script
├── source/              # TypeScript source
├── dist/                # Rspack output
│   └── cli.cjs         # Main bundle
├── rspack.config.js     # Rspack configuration
├── sea-config.json      # SEA configuration
└── package.json         # NPM scripts
```

## Distribution

**For end users:** Distribute the SEA executable
- ✅ No installation required
- ✅ No Node.js required
- ✅ No dependencies required
- ✅ Single file distribution

**For developers:** Distribute the rspack bundle
- ✅ Smaller size (~530 KB)
- ✅ Requires Node.js
- ✅ Fast execution
- ✅ Easy debugging
