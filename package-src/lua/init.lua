local function load_if_needed(loader)
  local ok, err = pcall(loader)
  return ok, err
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

local state = _G.GeyserMarkdownState or {
  loaded = false,
  loadError = nil,
}
_G.GeyserMarkdownState = state

local function try_initialize()
  if state.loaded then
    return true
  end

  if not Geyser or not Geyser.Label then
    return false
  end

  local ok, err = load_if_needed(function()
    dofile(root .. "/lua/MarkdownAdapter.lua")
  end)
  if not ok then
    state.loadError = tostring(err)
    return false
  end

  ok, err = load_if_needed(function()
    dofile(root .. "/lua/GeyserMarkdownLabel.lua")
  end)
  if not ok then
    state.loadError = tostring(err)
    return false
  end

  ok, err = load_if_needed(function()
    dofile(root .. "/lua/demo.lua")
  end)
  if not ok then
    state.loadError = tostring(err)
    return false
  end

  state.loaded = true
  state.loadError = nil

  deleteNamedEventHandler("geyser-markdown", "bootstrap-sysload")
  cecho("<green>Geyser Markdown package loaded.\\n")
  return true
end

if not try_initialize() then
  registerNamedEventHandler("geyser-markdown", "bootstrap-sysload", "sysLoadEvent", function()
    try_initialize()
  end)

  tempTimer(0, function()
    if not try_initialize() and state.loadError then
      cecho(string.format("<red>Geyser Markdown failed to initialize: %s\\n", state.loadError))
    end
  end)
end
