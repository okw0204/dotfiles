-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- 日本語入力中でも素早くNormalへ戻れるようにする
map("i", "jj", "<Esc>", { desc = "Insert -> Normal" })
map("i", "っｊ", "<Esc>", { desc = "Insert -> Normal (IME fallback)" })

for _, key in ipairs({ "x", "X", "d", "D", "c", "C" }) do
  map({ "n", "x" }, key, '"_' .. key, {
    desc = "Delete/Change without yanking",
  })
end

-- Rust のテスト候補実行を素早く呼べるようにする
map("n", "<leader>r", "<nop>", { desc = "+rust" })
map("n", "<leader>rt", function()
  vim.cmd.RustLsp("testables")
end, { desc = "Rust Testables" })
map("n", "<leader>rT", function()
  vim.cmd.RustLsp({ "testables", bang = true })
end, { desc = "Rust Testables!" })
