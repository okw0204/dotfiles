-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.relativenumber = false
vim.opt.timeoutlen = 450 -- jj でEscしやすいように少し長め
vim.opt.guicursor = "n-v-c:block,i:ver25,r-cr:hor20,o:hor50,ci-ve:block"
vim.opt.virtualedit = "onemore"
vim.opt.clipboard = "unnamedplus"
-- コメント行で改行しても次の行にコメントを自動挿入しない
vim.opt.formatoptions:remove({ "c", "r", "o" })
