import pc from 'picocolors';
import { createRequire } from 'module';
import { getConfig } from '@repo/rspack-config/config';
import { parseArgs } from '@repo/rspack-config/utils';

const moduleUrl = import.meta.url;
const require = createRequire(moduleUrl);

const { dependencies: deps } = require('./package.json');

const port = 3000;

const args = parseArgs(process.argv.slice(2));
const mode = args.mode || 'development';

// Base configuration
const baseFederationConfig = {
	name: 'hostApp',
	filename: 'remoteEntry.js',
	exposes: {
		'./Dummy': 'Dummy.tsx',
	},
	shared: {
		...deps,
		react: { singleton: true, eager: true, requiredVersion: deps.react },
		'react-dom': { singleton: true, eager: true, requiredVersion: deps['react-dom'] },
	},
};

// Environment-specific settings (overrides for each environment)
const getEnvironmentConfig = (env) => {
	switch (env) {
		case 'development':
			return {
				publicPath: `http://localhost:${port}/`,
				remotes: {
					remoteApp: 'http://localhost:3001/remoteEntry.js',
				},
				allowedOrigins: ['http://localhost:3001/'],
			};

		case 'staging':
			return {
				publicPath: `http://staging.example.com/`,
				remotes: {
					remoteApp: `http://staging.example.com/remoteEntry.js`,
				},
				allowedOrigins: ["http://staging.example.com/"],
			};

		case 'production':
			return {
				publicPath: `http://localhost:${port}/`,
				remotes: {
					remoteApp: 'http://localhost:3001/remoteEntry.js',
				},
				allowedOrigins: ["http://localhost:3001/"],
			};

		default:
			// Fallback to development as default environment
			return {
				publicPath: `http://localhost:${port}/`,
				remotes: {
					remoteApp: 'http://localhost:3001/remoteEntry.js',
				},
				allowedOrigins: ["http://localhost:3001/"],
			};
	}
};

// Get the specific environment config
const environmentConfig = getEnvironmentConfig(process.env.NODE_ENV);

// Combine base and environment-specific configs
const federationConfigs = {
	...baseFederationConfig,
	...environmentConfig,
};

console.log(pc.gray(`[${mode === 'development' ? 'Dev' : 'Build'}]: ${pc.magenta(mode)}`));

const config = getConfig({
	baseUrl: moduleUrl,
	federationConfigs,
	mode,
});

// Add devServer configuration for development mode
if (mode === 'development') {
	config.devServer = {
		port: port,
		host: 'localhost',
		hot: true,
		open: true,
		historyApiFallback: true,
		headers: {
			'Access-Control-Allow-Origin': '*',
		},
	};
}

export default config;
