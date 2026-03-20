return {
  "folke/noice.nvim",
  opts = function(_, opts)
    opts.views = opts.views or {}
    opts.views.notify = vim.tbl_deep_extend("force", opts.views.notify or {}, {
      timeout = 4000,
    })

    opts.routes = opts.routes or {}
    vim.list_extend(opts.routes, {
      {
        filter = { event = "notify", error = true },
        view = "notify",
        opts = { timeout = 16000 },
      },
      {
        filter = { event = "notify", warning = true },
        view = "notify",
        opts = { timeout = 12000 },
      },
      {
        filter = { event = "msg_show", kind = "wmsg" },
        view = "notify",
        opts = { timeout = 12000 },
      },
      {
        filter = { event = "msg_show", kind = "emsg" },
        view = "notify",
        opts = { timeout = 16000 },
      },
    })

    opts.commands = opts.commands or {}
    opts.commands.history = vim.tbl_deep_extend("force", opts.commands.history or {}, {
      view = "popup",
      opts = { enter = true, format = "details" },
    })
  end,
  keys = {
    { "<leader>nl", "<cmd>Noice last<cr>", desc = "Noice Last Message" },
    { "<leader>nh", "<cmd>Noice history<cr>", desc = "Noice History" },
  },
}
