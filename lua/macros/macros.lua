local action_state = require("telescope.actions.state")
local actions = require("telescope.actions")
local finders = require("telescope.finders")
local make_entry = require("telescope.make_entry")
local pickers = require("telescope.pickers")

local telescope_config = require("telescope.config").values
local config = require("macros.config")

local M = {}

local function execute_macro(prompt_bufnr)
  local selection = action_state.get_selected_entry()
  actions.close(prompt_bufnr)

  vim.cmd("normal! @" .. selection.value)
end

local function edit_macro(prompt_bufnr)
  local selection = action_state.get_selected_entry()

  vim.fn.inputsave()
  local updated_value = vim.fn.input("Edit macro [" .. selection.value .. "] ❯ ", selection.content)
  vim.fn.inputrestore()
  vim.fn.setreg(selection.value, updated_value)
  selection.content = updated_value

  M.reload_picker(prompt_bufnr)
end

local function append_comment(prompt_bufnr)
  local selection = action_state.get_selected_entry()

  vim.fn.inputsave()
  local comment_value = vim.fn.input("Add comment to macro [" .. selection.value .. "] ❯ ")
  vim.fn.inputrestore()
  local updated_value = ' " ' .. comment_value
  vim.fn.setreg(string.upper(selection.value), updated_value)
  selection.content = updated_value

  M.reload_picker(prompt_bufnr)
end

local function clear_macro(prompt_bufnr)
  local selection = action_state.get_selected_entry()
  vim.fn.setreg(selection.value, '"')

  M.reload_picker(prompt_bufnr)
end

local function clear_all_macros(prompt_bufnr)
  for i = 122 - config.options.num_registers, 122 do
    vim.fn.setreg(string.char(i), '"')
  end

  M.reload_picker(prompt_bufnr)
end

local function delete_macro(prompt_bufnr)
  local selection = action_state.get_selected_entry()
  vim.fn.setreg(selection.value, {})

  M.reload_picker(prompt_bufnr)
end

local function delete_all_macros(prompt_bufnr)
  for i = 122 - config.options.num_registers, 122 do
    vim.fn.setreg(string.char(i), {})
  end

  M.reload_picker(prompt_bufnr)
end

function M.reload_picker(prompt_bufnr)
  actions.close(prompt_bufnr)
  M.picker()
end

M.setup = function(options) config.setup(options) end

function M.picker()
  local registers_table = {}
  for i = 122 - config.options.num_registers, 122 do
    table.insert(registers_table, string.char(i))
  end

  pickers
    .new(config.options, {
      prompt_title = config.options.prompt_title,
      finder = finders.new_table({
        results = registers_table,
        entry_maker = config.options.entry_maker or make_entry.gen_from_registers(config.options),
      }),
      sorter = telescope_config.generic_sorter(config.options),

      attach_mappings = function(_, map)
        actions.select_default:replace(execute_macro)
        map({ "i", "n" }, "<C-e>", edit_macro)
        map({ "i", "n" }, "<C-t>", append_comment)
        map({ "i", "n" }, "<C-k>", clear_macro)
        map({ "i", "n" }, "<C-a>", clear_all_macros)
        map({ "i", "n" }, "<C-d>", delete_macro)
        map({ "i", "n" }, "<C-r>", delete_all_macros)
        return true
      end,
    })
    :find()
end

return M
