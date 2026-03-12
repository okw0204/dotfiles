-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local ime_group = vim.api.nvim_create_augroup("user_ime_control", { clear = true })

-- fcitx5 を半角英数へ戻す（Insert以外は基本OFF運用）
local function ime_off()
  if vim.fn.executable("fcitx5-remote") ~= 1 then
    return
  end
  pcall(vim.fn.system, { "fcitx5-remote", "-c" })
end

vim.api.nvim_create_autocmd({ "VimEnter", "InsertLeave", "CmdlineEnter" }, {
  group = ime_group,
  callback = ime_off,
})

vim.api.nvim_create_autocmd("ModeChanged", {
  group = ime_group,
  callback = function()
    -- i/R/r 以外に遷移したらIMEをOFF
    local mode = vim.fn.mode(1)
    if not mode:match("^[iRr]") then
      ime_off()
    end
  end,
})
