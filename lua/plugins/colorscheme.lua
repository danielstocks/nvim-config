return {
  {
    "folke/tokyonight.nvim",
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
        local style = is_macos_dark_mode() and "moon" or "day"

        if vim.g.tokyonight_style == style then
          return
        end

        vim.g.tokyonight_style = style

        require("tokyonight").setup({
          style = style,
        })

        vim.cmd.colorscheme("tokyonight")
      end

      apply_colorscheme()

      vim.api.nvim_create_autocmd("FocusGained", {
        callback = apply_colorscheme,
      })
    end,
  },
}
