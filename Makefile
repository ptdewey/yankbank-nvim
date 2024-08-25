fmt:
	echo "Formatting lua/yankbank..."
	stylua lua/ --config-path=.stylua.toml

lint:
	echo "Linting lua/yankbank..."
	luacheck lua/ --globals vim YANKS REG_TYPES OPTS

pr-ready: fmt lint
