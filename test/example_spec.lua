-- test/example_spec.lua
-- Example test file for chineselinter.nvim

local lu = require('luaunit')
local chineselinter = require('chineselinter')

TestExample = {}

function TestExample:setUp()
    -- Reset to default configuration before each test
    chineselinter.setup({})
end

function TestExample:tearDown()
    -- Reset configuration after each test
    chineselinter.setup({})
end

function TestExample:test_module_exists()
    lu.assertNotNil(chineselinter)
    lu.assertIsTable(chineselinter)
end

function TestExample:test_setup_function_exists()
    lu.assertEquals(type(chineselinter.setup), 'function')
end

function TestExample:test_check_function_exists()
    lu.assertEquals(type(chineselinter.check), 'function')
end

function TestExample:test_setup_with_ignored_errors()
    -- Should not error when setting ignored_errors
    chineselinter.setup({ ignored_errors = { 'E001', 'E002' } })
    lu.assertTrue(true)
end

function TestExample:test_setup_with_empty_table()
    chineselinter.setup({})
    lu.assertTrue(true)
end

function TestExample:test_setup_with_nil()
    chineselinter.setup(nil)
    lu.assertTrue(true)
end

function TestExample:test_setup_with_non_table()
    -- Should not error when passed a non-table value
    chineselinter.setup('invalid')
    lu.assertTrue(true)
end

return TestExample

