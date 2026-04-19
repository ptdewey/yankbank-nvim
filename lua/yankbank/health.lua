local M = {}

local start = vim.health.start or vim.health.report_start
local ok = vim.health.ok or vim.health.report_ok
local warn = vim.health.warn or vim.health.report_warn
local err = vim.health.error or vim.health.report_error
local info = vim.health.info or vim.health.report_info

function M.check()
    start("yankbank")

    if vim.fn.has("nvim-0.10") == 1 then
        ok("nvim 0.10+ detected")
    else
        err("yankbank requires nvim 0.10 or newer")
    end

    local state = require("yankbank.state")
    local opts = state.get_opts()
    if opts and next(opts) ~= nil then
        ok("setup() has been called")
        info("max_entries = " .. tostring(opts.max_entries))
        info(
            "yank_register = "
                .. tostring(opts.registers and opts.registers.yank_register)
        )
        info("persist_type = " .. tostring(opts.persist_type))
    else
        warn(
            "setup() has not been called — defaults will apply on first yank"
        )
    end

    local clipboard = vim.fn.has("clipboard") == 1
    if clipboard then
        ok("clipboard provider available")
    else
        warn(
            "no clipboard provider detected — `+` register yanks will not be captured"
        )
    end

    if opts and opts.persist_type == "sqlite" then
        local has_sqlite = pcall(require, "sqlite")
        if has_sqlite then
            ok("sqlite.lua is installed")
        else
            err("persist_type = 'sqlite' but sqlite.lua is not installed")
        end
    end

    if opts and opts.pickers and opts.pickers.snacks then
        local has_snacks = pcall(require, "snacks")
        if has_snacks then
            ok("snacks.nvim is installed")
        else
            err("pickers.snacks is enabled but snacks.nvim is not installed")
        end
    end
end

return M
