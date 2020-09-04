module.exports = {
	"env": {
		"browser": true,
		"commonjs": true,
		"es6": true,
		"node": true,
		"jasmine": true
	},
	"plugins": [
		"react"
	],
	"extends": "eslint:recommended",
	"globals": {
		"atom": "readonly"
	},
	"parserOptions": {
		"ecmaVersion": 2018,
		"sourceType": "module",
		"ecmaFeatures": {
			"jsx": true,
		}
	},
	"rules": {
		"react/jsx-uses-vars": "error",
	},
	"settings": {
		"react": {
			"version": "16"
		}
	}
};
