return {
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")

      local eslint_filetypes = {
        javascript = true,
        javascriptreact = true,
        typescript = true,
        typescriptreact = true,
        vue = true,
        svelte = true,
        astro = true,
      }

      local eslint_config_files = {
        ".eslintrc",
        ".eslintrc.js",
        ".eslintrc.cjs",
        ".eslintrc.yaml",
        ".eslintrc.yml",
        ".eslintrc.json",
        "eslint.config.js",
        "eslint.config.mjs",
        "eslint.config.cjs",
        "eslint.config.ts",
        "eslint.config.mts",
        "eslint.config.cts",
      }

      local function uses_eslint(bufnr)
        local filename = vim.api.nvim_buf_get_name(bufnr)
        if filename == "" then
          return false
        end

        return vim.fs.find(eslint_config_files, {
          path = vim.fs.dirname(filename),
          upward = true,
          type = "file",
          limit = 1,
        })[1] ~= nil
      end

      local function find_local_binary(start, binary)
        return vim.fs.find("node_modules/.bin/" .. binary, {
          upward = true,
          path = start,
          type = "file",
          limit = 1,
        })[1]
      end

      local function pick_eslint(bufnr)
        local filename = vim.api.nvim_buf_get_name(bufnr)
        local start = filename ~= "" and vim.fs.dirname(filename) or vim.loop.cwd()

        if start and start ~= "" then
          local local_eslint_d = find_local_binary(start, "eslint_d")
          if local_eslint_d then
            return { name = "eslint_d", cmd = local_eslint_d }
          end

          local local_eslint = find_local_binary(start, "eslint")
          if local_eslint then
            return { name = "eslint", cmd = local_eslint }
          end
        end

        local global_eslint_d = vim.fn.exepath("eslint_d")
        if global_eslint_d ~= "" then
          return { name = "eslint_d", cmd = global_eslint_d }
        end

        local global_eslint = vim.fn.exepath("eslint")
        if global_eslint ~= "" then
          return { name = "eslint", cmd = global_eslint }
        end

        return nil
      end

      local function lint_buffer(args)
        local bufnr = args and args.buf or vim.api.nvim_get_current_buf()
        if not eslint_filetypes[vim.bo[bufnr].filetype] then
          return
        end

        if not uses_eslint(bufnr) then
          return
        end

        local linter = pick_eslint(bufnr)
        if not linter then
          return
        end

        lint.linters[linter.name].cmd = linter.cmd
        lint.try_lint(linter.name)
      end

      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        callback = lint_buffer,
      })

      vim.keymap.set("n", "<leader>l", function()
        lint_buffer({ buf = vim.api.nvim_get_current_buf() })
      end, { desc = "Lint buffer" })
    end,
  },
}
