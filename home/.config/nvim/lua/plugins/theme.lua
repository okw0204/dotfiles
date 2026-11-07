-- 共通の既定テーマ。環境側が lua/plugins/theme.local.lua を用意している場合はその spec に任せる。
-- Arch/Omarchy は現在のテーマへのシンボリックリンクをそこに置き、無い環境では Kanagawa を使う。
if vim.fn.filereadable(vim.fn.stdpath("config") .. "/lua/plugins/theme.local.lua") == 1 then
  return {}
end

return {
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "kanagawa",
    },
  },
}
