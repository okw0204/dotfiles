return {
  {
    "zbirenbaum/copilot.lua",
    opts = {
      panel = { enabled = false },
      suggestion = { enabled = false },
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = function(_, opts)
      opts = opts or {}
      opts.file_types = opts.file_types or {}

      if not vim.tbl_contains(opts.file_types, "Avante") then
        table.insert(opts.file_types, "Avante")
      end
    end,
  },
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false,
    build = "make",
    opts = {
      provider = "opencode",
      instructions_file = "avante.md",
      input = {
        provider = "snacks",
      },
      behaviour = {
        -- Copilot は必要時だけ切り替えて使いたいので、自動提案は止めておく
        auto_suggestions = false,
      },
      providers = {
        copilot = {
          model = "gpt-4.1",
        },
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "folke/snacks.nvim",
      "nvim-tree/nvim-web-devicons",
      "zbirenbaum/copilot.lua",
      "MeanderingProgrammer/render-markdown.nvim",
    },
  },
}
