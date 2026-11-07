-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.relativenumber = false
vim.opt.timeoutlen = 450 -- jj でEscしやすいように少し長め
vim.opt.guicursor = "n-v-c:block,i:ver25,r-cr:hor20,o:hor50,ci-ve:block"
vim.opt.virtualedit = "onemore"
vim.opt.clipboard = "unnamedplus"
-- jsonc は json parser に寄せて treesitter 更新エラーを避ける
vim.treesitter.language.register("json", "jsonc")
-- コメント行で改行しても次の行にコメントを自動挿入しない
vim.opt.formatoptions:remove({ "c", "r", "o" })

-- 環境固有の設定は options.local.lua に置く（存在する場合だけ重ねて読み込む）。
-- 例: Arch/Omarchy は OSC 52 の設定をここから読み込む。
local local_options = vim.fn.stdpath("config") .. "/lua/config/options.local.lua"
if vim.fn.filereadable(local_options) == 1 then
  dofile(local_options)
end
