require("config.lazy")

vim.opt.clipboard = "unnamedplus"
vim.opt.mouse = "a"

vim.keymap.set("n", "<leader>cp", function()
  vim.fn.setreg("+", vim.fn.expand("%:."))
end, { desc = "Copy relative file path" })
