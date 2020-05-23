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
		"ecmaFeatures": {
			"jsx": true,
		}
	},
	"rules": {
		indent: ["error", "tab"],
		semi: ["error", "always"],
		quotes: ["error", "double"],
		"jsx-quotes": ["error", "prefer-double"],

		"react/jsx-uses-vars": 2,
		"react/jsx-indent": ["error", "tab"],
	},
	"settings": {
		"react": {
			"version": "16"
		}
	}
};
