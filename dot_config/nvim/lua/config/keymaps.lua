-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- 日本語入力中でも素早くNormalへ戻れるようにする
map("i", "jj", "<Esc>", { desc = "Insert -> Normal" })

-- 削除系キーでレジスタ"(デフォルト)を汚さない
-- 明示レジスタ指定("a など)がある場合は既存動作を優先する
local function keep_register_or_blackhole(key)
  return function()
    if vim.v.register == '"' then
      return '"_' .. key
    end
    return key
  end
end

for _, key in ipairs({ "x", "X", "d", "D", "s", "S", "c", "C" }) do
  map({ "n", "x" }, key, keep_register_or_blackhole(key), {
    expr = true,
    desc = "Delete/Change without yanking",
  })
end
