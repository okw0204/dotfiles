-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- 日本語入力中でも素早くNormalへ戻れるようにする
map("i", "jj", "<Esc>", { desc = "Insert -> Normal" })
map("i", "っｊ", "<Esc>", { desc = "Insert -> Normal (IME fallback)" })

-- Rust のテスト候補実行を素早く呼べるようにする
map("n", "<leader>r", "<nop>", { desc = "+rust" })
map("n", "<leader>rt", function()
  vim.cmd.RustLsp("testables")
end, { desc = "Rust Testables" })
map("n", "<leader>rT", function()
  vim.cmd.RustLsp({ "testables", bang = true })
end, { desc = "Rust Testables!" })
map("n", "<leader>ro", function()
  local bufnr = vim.api.nvim_get_current_buf()
  local file = vim.api.nvim_buf_get_name(bufnr)
  local edits = {}
  local seen = {}

  local function add_edit(start_pos, end_pos)
    local key = table.concat({ start_pos.line, start_pos.character, end_pos.line, end_pos.character }, ":")
    if seen[key] then
      return
    end
    seen[key] = true
    table.insert(edits, {
      lnum = start_pos.line,
      col = start_pos.character,
      end_lnum = end_pos.line,
      end_col = end_pos.character,
    })
  end

  for _, diagnostic in ipairs(vim.diagnostic.get(bufnr)) do
    -- rust-analyzer は未使用 use の削除候補を rustc の補助診断として返す
    if diagnostic.source == "rustc" and diagnostic.code == "unused_imports" and diagnostic.message == "remove the whole `use` item" then
      add_edit({ line = diagnostic.lnum, character = diagnostic.col }, { line = diagnostic.end_lnum, character = diagnostic.end_col })
    end

    for _, related in ipairs(vim.tbl_get(diagnostic, "user_data", "lsp", "relatedInformation") or {}) do
      if related.message == "remove the whole `use` item" and vim.uri_to_fname(related.location.uri) == file then
        add_edit(related.location.range.start, related.location.range["end"])
      end
    end
  end

  if #edits == 0 then
    vim.notify("No unused imports diagnostics available", vim.log.levels.INFO)
    return
  end

  table.sort(edits, function(a, b)
    if a.lnum == b.lnum then
      return a.col > b.col
    end
    return a.lnum > b.lnum
  end)

  for _, edit in ipairs(edits) do
    vim.api.nvim_buf_set_text(bufnr, edit.lnum, edit.col, edit.end_lnum, edit.end_col, {})
  end

  pcall(vim.lsp.buf.format, { bufnr = bufnr, async = false })
end, { desc = "Rust Remove Unused Imports" })
