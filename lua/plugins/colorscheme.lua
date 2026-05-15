return {
  {
    "ellisonleao/gruvbox.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      local function is_macos_dark_mode()
        if vim.fn.has("mac") == 0 then
          return true
        end

        local result = vim.system({ "defaults", "read", "-g", "AppleInterfaceStyle" }, { text = true }):wait()
        return result.code == 0 and result.stdout:match("Dark") ~= nil
      end

      local function apply_colorscheme()
        local background = is_macos_dark_mode() and "dark" or "light"

        if vim.o.background == background and vim.g.colors_name == "gruvbox" then
          return
        end

        vim.o.background = background

        require("gruvbox").setup({
          contrast = "hard",
        })

        vim.cmd.colorscheme("gruvbox")
      end

      apply_colorscheme()

      vim.api.nvim_create_autocmd("FocusGained", {
        callback = apply_colorscheme,
      })
    end,
  },
}
