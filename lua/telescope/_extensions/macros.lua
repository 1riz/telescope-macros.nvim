local has_telescope, telescope = pcall(require, "telescope")
local macros = require("macros")

if not has_telescope then
  error("This plugins requires nvim-telescope/telescope.nvim")
end

return telescope.register_extension({
  setup = macros.setup,
  exports = { macros = macros.picker },
})
