return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = function()
      local util = require("conform.util")

      local function local_oxfmt(_, ctx)
        local bufname = ctx.filename or vim.api.nvim_buf_get_name(ctx.buf)
        local start = vim.fs.dirname(bufname)

        if start and start ~= "" then
          local local_bin = vim.fs.find("node_modules/.bin/oxfmt", {
            upward = true,
            path = start,
            type = "file",
          })[1]

          if local_bin then
            return local_bin
          end
        end

        local global_bin = vim.fn.exepath("oxfmt")
        if global_bin ~= "" then
          return global_bin
        end

        return "oxfmt"
      end

      return {
        notify_no_formatters = false,
        format_on_save = {
          lsp_format = "fallback",
          timeout_ms = 1000,
        },
        formatters_by_ft = {
          javascript = { "oxfmt" },
          javascriptreact = { "oxfmt" },
          typescript = { "oxfmt" },
          typescriptreact = { "oxfmt" },
          json = { "oxfmt" },
          jsonc = { "oxfmt" },
          vue = { "oxfmt" },
        },
        formatters = {
          oxfmt = {
            command = local_oxfmt,
            cwd = util.root_file({ "package.json", ".git" }),
          },
        },
      }
    end,
    config = function(_, opts)
      require("conform").setup(opts)

      vim.keymap.set("n", "<leader>f", function()
        require("conform").format({ async = true, lsp_format = "fallback" })
      end, { desc = "Format buffer" })
    end,
  },
}
