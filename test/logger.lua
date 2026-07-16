-- test/logger.lua
-- Mock logger module for testing
-- Provides a minimal mock of the logger module used by chineselinter

local M = {}

function M.derive(name)
    return {
        name = name,
        debug = function(msg)
            print(string.format('[DEBUG][%s] %s', name, msg))
        end,
        info = function(msg)
            print(string.format('[INFO][%s] %s', name, msg))
        end,
        warn = function(msg)
            print(string.format('[WARN][%s] %s', name, msg))
        end,
        error = function(msg)
            print(string.format('[ERROR][%s] %s', name, msg))
        end,
    }
end

return M

