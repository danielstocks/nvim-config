return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        filesystem = {
          hijack_netrw_behavior = "open_default",
          filtered_items = {
            visible = true,
            never_show = {
              ".DS_Store",
            },
          },
        },
      })

      vim.keymap.set("n", "<leader><Tab>", ":Neotree toggle filesystem reveal left<CR>", {
        silent = true,
        desc = "Toggle Neo-tree",
      })
    end,
  },
}
