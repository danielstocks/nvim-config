return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = function()
      local util = require("conform.util")

      local function find_local_node_bin(start, bin)
        if start and start ~= "" then
          return vim.fs.find("node_modules/.bin/" .. bin, {
            upward = true,
            path = start,
            type = "file",
            limit = 1,
          })[1]
        end
      end

      local function local_oxfmt(_, ctx)
        local bufname = ctx.filename or vim.api.nvim_buf_get_name(ctx.buf)
        local start = vim.fs.dirname(bufname)

        local local_bin = find_local_node_bin(start, "oxfmt")
        if local_bin then
          return local_bin
        end

        local global_bin = vim.fn.exepath("oxfmt")
        if global_bin ~= "" then
          return global_bin
        end

        return "oxfmt"
      end

      local function local_rescript(_, ctx)
        local bufname = ctx.filename or vim.api.nvim_buf_get_name(ctx.buf)
        local start = vim.fs.dirname(bufname)

        local local_bin = find_local_node_bin(start, "rescript")
        if local_bin then
          return local_bin
        end

        local global_bin = vim.fn.exepath("rescript")
        if global_bin ~= "" then
          return global_bin
        end

        return "rescript"
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
          rescript = { "rescript-format" },
          vue = { "oxfmt" },
        },
        formatters = {
          oxfmt = {
            command = local_oxfmt,
            cwd = util.root_file({ "package.json", ".git" }),
          },
          ["rescript-format"] = {
            command = local_rescript,
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
