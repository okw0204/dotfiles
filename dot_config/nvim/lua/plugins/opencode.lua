return {
  {
    "nickjvandyke/opencode.nvim",
    version = "*", -- Latest stable release
    dependencies = {
      {
        "folke/snacks.nvim",
        optional = true,
        opts = {
          input = {},
          picker = {
            actions = {
              opencode_send = function(...)
                return require("opencode").snacks_picker_send(...)
              end,
            },
            win = {
              input = {
                keys = {
                  ["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
                },
              },
            },
          },
        },
      },
    },
    config = function()
      local opencode_cmd = "opencode --port 4096"

      local function save_if_needed()
        if vim.bo.buftype == "" and vim.bo.modified then
          pcall(vim.cmd, "silent update")
        end
      end

      local function find_opencode_win()
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].buftype == "terminal" then
            local name = vim.api.nvim_buf_get_name(buf)
            if name:find("opencode", 1, true) then
              return win
            end
          end
        end
        return nil
      end

      local function mark_opencode_buf_unlisted(win)
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.api.nvim_buf_is_valid(buf) then
          vim.bo[buf].buflisted = false
        end
      end

      local function ensure_opencode_panel_focus()
        local win = find_opencode_win()
        if not win then
          require("opencode").toggle()
          win = find_opencode_win()
        end

        if win and vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_set_current_win(win)
          mark_opencode_buf_unlisted(win)
          if vim.bo.buftype == "terminal" then
            vim.cmd("startinsert")
          end
        end
      end

      local run_after_opencode_ready

      run_after_opencode_ready = function(callback, delay)
        require("opencode").start()
        vim.defer_fn(callback, delay or 900)
      end

      local function ask_with_context()
        local mode = vim.fn.mode()
        local prompt = (mode == "v" or mode == "V" or mode == "\22") and "@this: " or "@buffer: "

        save_if_needed()
        run_after_opencode_ready(function()
          ensure_opencode_panel_focus()
          require("opencode").ask(prompt, { submit = true })
        end)
      end

      local function opencode_operator(prompt)
        _G.opencode_prompt_operator = function(kind)
          local start_pos = vim.api.nvim_buf_get_mark(0, "[")
          local end_pos = vim.api.nvim_buf_get_mark(0, "]")
          if start_pos[1] > end_pos[1] or (start_pos[1] == end_pos[1] and start_pos[2] > end_pos[2]) then
            start_pos, end_pos = end_pos, start_pos
          end

          local range = {
            from = { start_pos[1], start_pos[2] },
            to = { end_pos[1], end_pos[2] },
            kind = kind,
          }

          run_after_opencode_ready(function()
            require("opencode").prompt(prompt, {
              context = require("opencode.context").new(range),
            })
          end, 1200)
        end

        vim.o.operatorfunc = "v:lua.opencode_prompt_operator"
        return "g@"
      end

      ---@type opencode.Opts
      vim.g.opencode_opts = {
        server = {
          -- lsof が無い環境でも接続先を確定させるため固定ポートを使う
          port = 4096,
          start = function()
            require("opencode.terminal").start(opencode_cmd)
          end,
          stop = function()
            require("opencode.terminal").stop()
          end,
          toggle = function()
            require("opencode.terminal").toggle(opencode_cmd)
          end,
        },
      }

      vim.o.autoread = true -- Required for `opts.events.reload`

      vim.api.nvim_create_autocmd("TermOpen", {
        group = vim.api.nvim_create_augroup("opencode_terminal", { clear = true }),
        pattern = "*opencode*",
        callback = function(args)
          vim.bo[args.buf].buflisted = false
        end,
      })

      -- README の推奨キーマップを <leader> 系に寄せて衝突を避ける
      vim.keymap.set({ "n", "x" }, "<leader>oa", function()
        ask_with_context()
      end, { desc = "Ask opencode (@buffer/@this)" })
      vim.keymap.set({ "n", "x" }, "<leader>os", function()
        save_if_needed()
        run_after_opencode_ready(function()
          require("opencode").select()
        end)
      end, { desc = "Execute opencode action" })
      vim.keymap.set({ "n", "t" }, "<leader>ot", function()
        require("opencode").toggle()
      end, { desc = "Toggle opencode" })

      vim.keymap.set({ "n", "x" }, "<leader>or", function()
        save_if_needed()
        return opencode_operator("@this ")
      end, { desc = "Add range to opencode", expr = true })
      vim.keymap.set("n", "<leader>ol", function()
        save_if_needed()
        return opencode_operator("@this ") .. "_"
      end, { desc = "Add line to opencode", expr = true })

      vim.keymap.set("n", "<S-C-u>", function()
        require("opencode").command("session.half.page.up")
      end, { desc = "Scroll opencode up" })
      vim.keymap.set("n", "<S-C-d>", function()
        require("opencode").command("session.half.page.down")
      end, { desc = "Scroll opencode down" })
    end,
  },
}
