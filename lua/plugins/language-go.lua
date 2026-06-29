local enabled = true
if not enabled then
  return {}
end

return {
  -- Install go with mason
  {
    "mason-org/mason-lspconfig.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      if not vim.tbl_contains(opts.ensure_installed, "gopls") then
        table.insert(opts.ensure_installed, "gopls")
      end
      return opts
    end,
  },

  -- Go debugger
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "leoluz/nvim-dap-go",
    },
    config = function()
      local dap = require("dap")
      local ui = require("dapui")

      require("dap-go").setup()
      ui.setup()

      dap.listeners.before.attach.dapui_config = function()
        ui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        ui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        ui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        ui.close()
      end

      vim.keymap.set("n", "<leader>dd", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
      vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Continue / Start" })
      vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Step Into" })
      vim.keymap.set("n", "<leader>dn", dap.step_over, { desc = "Step Over" })
      vim.keymap.set("n", "<leader>do", dap.step_out, { desc = "Step Out" })
      vim.keymap.set("n", "<leader>dus", ui.toggle, { desc = "Toggle UI" })
      vim.keymap.set("n", "<leader>dt", function()
        require("dap-go").debug_test()
      end, { desc = "Debug Test" })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, {
          "go",
          "gomod",
          "gowork",
          "gosum",
          "gotmpl",
        })
      end
      return opts
    end,
    init = function()
      -- Jump sequencally between code in same scope (<Ctrl>j && <Ctrl>k)
      local function jump_statement(direction)
        local node = vim.treesitter.get_node()
        if not node then
          return
        end

        local function is_comment(n)
          local t = n:type()
          return t == "comment" or t == "line_comment" or t == "block_comment"
        end

        local function is_valid_target(t)
          return t:find("statement")
            or t:find("declaration")
            or t == "keyed_field"
            or t == "parameter_declaration"
            or t == "short_var_declaration"
            or t == "field_declaration"
        end

        local boundary_containers = {
          ["literal_value"] = true,
          ["field_declaration_list"] = true,
          ["parameter_list"] = true,
          ["argument_list"] = true,
          ["block"] = true,
        }

        local initial_cursor = vim.api.nvim_win_get_cursor(0)

        local statement_node = node
        while statement_node do
          local parent = statement_node:parent()
          if not parent then
            break
          end

          local t = statement_node:type()

          if is_comment(statement_node) then
            statement_node = parent
          elseif is_valid_target(t) then
            if boundary_containers[parent:type()] then
              break
            end
            break
          else
            if boundary_containers[statement_node:type()] then
              break
            end
            statement_node = parent
          end
        end

        if not statement_node then
          return
        end

        local target = (direction == "next") and statement_node:next_named_sibling()
          or statement_node:prev_named_sibling()

        while target and is_comment(target) do
          target = (direction == "next") and target:next_named_sibling() or target:prev_named_sibling()
        end

        if not target then
          vim.api.nvim_win_set_cursor(0, initial_cursor)
          return
        end

        local start_row, start_col = target:start()
        vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "go",
        callback = function()
          vim.keymap.set("n", "<C-j>", function()
            jump_statement("next")
          end, { buffer = true, desc = "Go: Next Statement" })
          vim.keymap.set("n", "<C-k>", function()
            jump_statement("prev")
          end, { buffer = true, desc = "Go: Prev Statement" })
        end,
      })
    end,
  },

  {
    "ray-x/go.nvim",
    dependencies = {
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    event = { "CmdlineEnter" },
    ft = { "go", "gomod" },
    config = function()
      require("go").setup({
        lsp_cfg = false,
        lsp_fmt = false,
        gofmt = "",
        lsp_codelens = false,
      })

      -- Error Handling Boilerplate
      vim.keymap.set("n", "<leader>goe", "<cmd>GoIfErr<CR>", { desc = "Go: Generate if err != nil" })
      vim.keymap.set("n", "<leader>gof", "<cmd>GoFixPlurals<CR>", { desc = "Go: Fix return statement plurals" })

      -- Struct & Interface Injection
      vim.keymap.set("n", "<leader>gos", "<cmd>GoFillStruct<CR>", { desc = "Go: Auto-fill empty struct fields" })
      vim.keymap.set("n", "<leader>gow", "<cmd>GoFillSwitch<CR>", { desc = "Go: Populate all cases for switch" })

      -- Tag Tooling
      vim.keymap.set("n", "<leader>goj", "<cmd>GoAddTag json<CR>", { desc = "Go: Add JSON tags to struct" })
      vim.keymap.set("n", "<leader>goy", "<cmd>GoAddTag yaml<CR>", { desc = "Go: Add YAML tags to struct" })
      vim.keymap.set("n", "<leader>goc", "<cmd>GoClearTag<CR>", { desc = "Go: Wipe clean all struct tags" })

      vim.keymap.set("n", "<leader>gon", function()
        vim.cmd("GoAddTest")

        vim.defer_fn(function()
          vim.cmd("GoAlt!")
        end, 100)
      end, { buffer = true, desc = "Go: Generate/Append Table Test & open in Split" })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local ok, lsp = pcall(require, "lang_support.lsp_util")
      if not ok then
        return opts
      end

      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.go",
        callback = function()
          local params = vim.lsp.util.make_range_params()
          params.context = { Only = { "source.organizeImports" } }
          local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 1000)
          for cid, res in pairs(result or {}) do
            for _, r in pairs(res.result or {}) do
              if r.edit then
                vim.lsp.util.apply_workspace_edit(r.edit, "utf-8")
              else
                vim.lsp.buf.execute_command(r.command)
              end
            end
          end
          vim.lsp.buf.format({ async = false })
        end,
      })

      local root_pattern = lsp.root_pattern({ "go.work", "go.mod", ".git" })

      lsp.register("gopls", "go", {
        cmd = { "gopls" },
        root_dir = root_pattern,

        on_new_config = function(new_config, new_root_dir)
          if vim.fn.filereadable(new_root_dir .. "/.tinygo") == 1 then
            new_config.settings.gopls.buildFlags = { "-tags=tinygo" }
          end
        end,

        settings = {
          gopls = {
            staticcheck = true,
            gofumpt = true,
            completeUnimported = true,
            usePlaceholders = true,
            experimentalPostfixCompletions = true,
            analyses = {
              unusedparams = true,
              nilness = true,
              unusedwrite = false,
            },
            directoryFilters = { "-**/vendor", "-**/node_modules" },
            hoverKind = "FullDocumentation",
            matcher = "Fuzzy",
          },
        },
      })

      return opts
    end,
  },
}
