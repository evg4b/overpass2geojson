const path = require('path');

/**
 * @type {import('@rspack/core').Configuration}
 */
module.exports = {
	mode: 'production',
	target: 'node',
	devtool: false, // Отключаем source maps для единственного файла
	entry: {
		cli: './source/cli.tsx',
	},
	output: {
		path: path.resolve(__dirname, 'dist'),
		filename: '[name].cjs',
		chunkFormat: 'commonjs',
		clean: true,
		asyncChunks: false,
	},
	resolve: {
		extensions: ['.tsx', '.ts', '.jsx', '.js'],
	},
	module: {
		rules: [
			{
				test: /\.(ts|tsx)$/,
				exclude: /node_modules/,
				use: {
					loader: 'builtin:swc-loader',
					options: {
						jsc: {
							parser: {
								syntax: 'typescript',
								tsx: true,
							},
							transform: {
								react: {
									runtime: 'automatic',
								},
							},
						},
					},
				},
			},
		],
	},
	optimization: {
		minimize: false,
		splitChunks: false,
		runtimeChunk: false,
		concatenateModules: true,
	},
	performance: {
		hints: false,
	},
	externalsPresets: { node: true },
	externals: [
		// Функция для обработки встроенных модулей Node.js
		function ({request}, callback) {
			// Список встроенных модулей Node.js
			const builtinModules = [
				'assert',
				'buffer',
				'child_process',
				'cluster',
				'crypto',
				'dgram',
				'dns',
				'domain',
				'events',
				'fs',
				'http',
				'https',
				'module',
				'net',
				'os',
				'path',
				'punycode',
				'querystring',
				'readline',
				'repl',
				'stream',
				'string_decoder',
				'sys',
				'timers',
				'tls',
				'tty',
				'url',
				'util',
				'vm',
				'zlib',
			];

			// Опциональные зависимости
			const optionalDeps = [
				'bufferutil',
				'utf-8-validate',
				'react-devtools-core',
			];

			// Обработка модулей с префиксом node:
			if (request.startsWith('node:')) {
				return callback(null, 'commonjs ' + request);
			}

			// Обработка встроенных модулей без префикса
			if (builtinModules.includes(request)) {
				return callback(null, 'commonjs ' + request);
			}

			// Обработка опциональных зависимостей
			if (optionalDeps.includes(request)) {
				return callback(null, 'commonjs ' + request);
			}

			// Все остальное встраиваем в бандл
			callback();
		},
	],
	node: {
		__dirname: false,
		__filename: false,
	},
	plugins: [
		new (require('@rspack/core').BannerPlugin)({
			banner: '#!/usr/bin/env node',
			raw: true,
		}),
	],
};
