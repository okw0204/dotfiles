local version_cache = {}

local function first_line(cmd)
  local output = vim.fn.systemlist(cmd)
  if vim.v.shell_error ~= 0 or not output[1] then
    return nil
  end
  return output[1]
end

local function detect_lang_version()
  local ft = vim.bo.filetype
  if ft == "" then
    return nil
  end

  if version_cache[ft] ~= nil then
    return version_cache[ft] ~= "" and version_cache[ft] or nil
  end

  local checks = {
    python = { cmd = "python3 --version", pattern = "Python%s+([%d%.]+)", label = "" },
    lua = { cmd = "lua -v 2>&1", pattern = "Lua%s+([%d%.]+)", label = "" },
    javascript = { cmd = "node --version", pattern = "v([%d%.]+)", label = "" },
    typescript = { cmd = "node --version", pattern = "v([%d%.]+)", label = "󰛦" },
    javascriptreact = { cmd = "node --version", pattern = "v([%d%.]+)", label = "" },
    typescriptreact = { cmd = "node --version", pattern = "v([%d%.]+)", label = "󰜈" },
    go = { cmd = "go version", pattern = "go([%d%.]+)", label = "" },
    rust = { cmd = "rustc --version", pattern = "rustc%s+([%d%.]+)", label = "" },
    ruby = { cmd = "ruby --version", pattern = "ruby%s+([%d%.]+)", label = "" },
    php = { cmd = "php --version", pattern = "PHP%s+([%d%.]+)", label = "" },
    java = { cmd = "java -version 2>&1", pattern = '"([%d%._]+)"', label = "" },
  }

  local check = checks[ft]
  if not check then
    version_cache[ft] = ""
    return nil
  end

  local line = first_line(check.cmd)
  if not line then
    version_cache[ft] = ""
    return nil
  end

  local ver = line:match(check.pattern)
  if not ver then
    version_cache[ft] = ""
    return nil
  end

  version_cache[ft] = string.format("%s %s", check.label, ver)
  return version_cache[ft]
end

return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      opts.sections = opts.sections or {}
      opts.sections.lualine_x = opts.sections.lualine_x or {}

      table.insert(opts.sections.lualine_x, 1, {
        detect_lang_version,
        color = function()
          return { fg = Snacks.util.color("Special") }
        end,
      })

      return opts
    end,
  },
}
