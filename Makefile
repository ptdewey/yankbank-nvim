fmt:
	echo "Formatting lua/yankbank..."
	stylua lua/ --config-path=.stylua.toml

lint:
	echo "Linting lua/yankbank..."
	luacheck lua/ --globals vim YB_YANKS YB_REG_TYPES YB_OPTS

pr-ready: fmt lint
