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
      local function save_if_needed()
        if vim.bo.buftype == "" and vim.bo.modified then
          pcall(vim.cmd, "silent update")
        end
      end

      local function wait_for_opencode_process(callback, retries)
        retries = retries or 20
        require("opencode").start()

        local function attempt(remaining)
          local ok, processes = pcall(require("opencode.cli.process").get)
          -- 起動直後は process 検出が追いつかないことがあるので、見えるまで少し待つ
          if ok and processes and #processes > 0 then
            callback()
          elseif remaining > 0 then
            vim.defer_fn(function()
              attempt(remaining - 1)
            end, 200)
          else
            vim.notify("No `opencode` processes found", vim.log.levels.ERROR, { title = "opencode" })
          end
        end

        attempt(retries)
      end

      ---@type opencode.Opts
      vim.g.opencode_opts = {
        -- lsof 前提の upstream 寄り構成に戻す
      }

      vim.o.autoread = true

      vim.keymap.set({ "n", "t" }, "<leader>ot", function()
        require("opencode").toggle()
      end, { desc = "Toggle opencode" })

      vim.keymap.set("n", "<leader>ob", function()
        save_if_needed()
        local context = require("opencode.context").new()
        wait_for_opencode_process(function()
          require("opencode").ask("@buffer: ", { submit = true, context = context })
        end)
      end, { desc = "Ask opencode with buffer" })

      vim.keymap.set("x", "<leader>or", function()
        save_if_needed()
        local context = require("opencode.context").new()
        wait_for_opencode_process(function()
          require("opencode").ask("@this: ", { submit = true, context = context })
        end)
      end, { desc = "Ask opencode with selection" })
    end,
  },
}
