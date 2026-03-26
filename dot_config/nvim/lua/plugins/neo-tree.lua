return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      window = {
        mappings = {
          -- y は Neo-tree 内部コピーではなく OS クリップボードへ絶対パスを入れる
          ["y"] = function(state)
            local node = state.tree:get_node()
            if not node then
              return
            end
            vim.fn.setreg("+", node:get_id(), "c")
          end,
          ["gy"] = "copy_to_clipboard",
        },
      },
      filesystem = {
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
        },
      },
    },
  },
}
