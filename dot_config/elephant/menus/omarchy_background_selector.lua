Name = "omarchyBackgroundSelector"
NamePretty = "Wallpaper Selector"
Cache = false
HideFromProviderlist = true
SearchName = true

local function ShellEscape(s)
  return "'" .. s:gsub("'", "'\\''") .. "'"
end

local function FormatName(filename)
  local name = filename:gsub("%.[^%.]+$", "")
  name = name:gsub("[_-]", " ")
  name = name:gsub("%S+", function(word)
    return word:sub(1, 1):upper() .. word:sub(2):lower()
  end)
  return name
end

function GetEntries()
  local entries = {}
  local home = os.getenv("HOME")
  local wallpaper_dir = os.getenv("WALLPAPER_DIR") or home .. "/ghq/github.com/okw0204/wallpaper"
  local wallpaper_set = os.getenv("WALLPAPER_SET") or home .. "/.local/bin/wallpaper-set"

  local handle = io.popen(
    "find " .. ShellEscape(wallpaper_dir)
      .. " -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) 2>/dev/null | sort"
  )
  if not handle then
    return entries
  end

  for background in handle:lines() do
    local filename = background:match("([^/]+)$")
    if filename then
      table.insert(entries, {
        Text = FormatName(filename),
        Value = background,
        Actions = {
          activate = ShellEscape(wallpaper_set) .. " " .. ShellEscape(background),
        },
        Preview = background,
        PreviewType = "file",
      })
    end
  end
  handle:close()

  return entries
end
