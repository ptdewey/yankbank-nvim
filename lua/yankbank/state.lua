local M = {}

local state = {
    yanks = {},
    reg_types = {},
    pins = {},
    opts = {},
}

function M.get_yanks()
    return state.yanks
end

function M.set_yanks(yanks)
    state.yanks = yanks
end

function M.get_reg_types()
    return state.reg_types
end

function M.set_reg_types(reg_types)
    state.reg_types = reg_types
end

function M.get_pins()
    return state.pins
end

function M.set_pins(pins)
    state.pins = pins
end

function M.get_opts()
    return state.opts
end

function M.set_opts(opts)
    state.opts = opts
end

function M.init(yanks, reg_types, pins, opts)
    state.yanks = yanks or {}
    state.reg_types = reg_types or {}
    state.pins = pins or {}
    state.opts = opts or {}
end

return M
