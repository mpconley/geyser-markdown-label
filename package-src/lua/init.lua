local function load_if_needed(loader)
  local ok, err = pcall(loader)
  if not ok then
    error("Geyser Markdown package load failed: " .. tostring(err))
  end
end

load_if_needed(function()
  dofile(getMudletHomeDir() .. "/packages/geyser-markdown/lua/MarkdownAdapter.lua")
end)

load_if_needed(function()
  dofile(getMudletHomeDir() .. "/packages/geyser-markdown/lua/GeyserMarkdownLabel.lua")
end)

load_if_needed(function()
  dofile(getMudletHomeDir() .. "/packages/geyser-markdown/lua/demo.lua")
end)

cecho("<green>Geyser Markdown package loaded.\\n")
