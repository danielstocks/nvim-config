return {
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G" },
    init = function()
      -- Compatibility alias for older muscle memory.
      vim.api.nvim_create_user_command("Gblame", function(opts)
        local suffix = opts.args ~= "" and (" " .. opts.args) or ""
        vim.cmd("Git blame" .. suffix)
      end, { nargs = "*" })
    end,
    keys = {
      { "<leader>gb", "<cmd>Git blame<cr>", desc = "Git blame" },
    },
  },
}
