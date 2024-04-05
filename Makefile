fmt:
	echo "Formatting lua/yankbank..."
	stylua lua/ --config-path=.stylua.toml

lint:
	echo "Linting lua/yankbank..."
	luacheck lua/ --globals vim

pr-ready: fmt lint
