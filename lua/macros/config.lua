local M = {}

local defaults = {
  prompt_title = "Macros",
  num_registers = 12,
  theme = "dropdown",
  layout_strategy = "center",
  layout_config = { height = 0.20, width = 0.50 },
}

M.options = {}

function M.setup(options)
  M.options = vim.tbl_deep_extend("force", {}, defaults, options or {})
  M.options.num_registers = M.options.num_registers - 1
end

return M
