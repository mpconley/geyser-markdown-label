local function load_if_needed(loader)
  local ok, err = pcall(loader)
  if not ok then
    error("Geyser Markdown package load failed: " .. tostring(err))
  end
end

local root = _G.GeyserMarkdownPackageRoot
if not root or root == "" then
  local home = getMudletHomeDir()
  local candidates = {
    home .. "/geyser-markdown",
    home .. "/geyser-markdown-label",
    home .. "/packages/geyser-markdown",
  }

  for _, path in ipairs(candidates) do
    if io.exists(path .. "/lua/MarkdownAdapter.lua") then
      root = path
      break
    end
  end
end

if not root or root == "" then
  error("Geyser Markdown package loader could not resolve package root")
end

load_if_needed(function()
  dofile(root .. "/lua/MarkdownAdapter.lua")
end)

load_if_needed(function()
  dofile(root .. "/lua/GeyserMarkdownLabel.lua")
end)

load_if_needed(function()
  dofile(root .. "/lua/demo.lua")
end)

cecho("<green>Geyser Markdown package loaded.\\n")
