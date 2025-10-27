import { defineConfig } from '@rsbuild/core';
import { pluginTypeCheck } from '@rsbuild/plugin-type-check';

export default defineConfig({
  plugins: [pluginTypeCheck()],
  source: {
    entry: {
      index: './src/index.ts',
    },
  },
  output: {
    target: 'node',
    distPath: {
      root: 'dist',
    },
    filename: {
      js: 'overpass2geojson-bundle.cjs',
    },
    minify: false,
  },
  tools: {
    rspack: {
      target: 'node20',
      node: {
        __dirname: false,
        __filename: false,
      },
      optimization: {
        minimize: false,
      },
    },
  },
});
