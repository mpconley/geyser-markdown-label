local MarkdownAdapter = _G.GeyserMarkdownAdapter
if not MarkdownAdapter then
  error("GeyserMarkdownAdapter must be loaded before GeyserMarkdownLabel")
end

if not Geyser or not Geyser.Label then
  error("Geyser must be loaded before Geyser.MarkdownLabel")
end

Geyser.MarkdownLabel = Geyser.Label:new({
  name = "MarkdownLabelClass",
  eventHandlerName = nil,
  eventName = nil,
  eventPayloadIndex = 2,
  lastMarkdown = nil,
  lastRenderedHtml = nil,
})

function Geyser.MarkdownLabel:new(cons, container)
  cons = cons or {}
  cons.name = cons.name or Geyser.nameGen("markdownlabel")

  local me = Geyser.Label:new(cons, container)
  setmetatable(me, self)
  self.__index = self

  me.lastMarkdown = nil
  me.lastRenderedHtml = nil
  me.eventHandlerName = nil
  me.eventName = nil
  me.eventPayloadIndex = cons.eventPayloadIndex or 2

  if cons.markdown then
    me:setContent(cons.markdown)
  end

  if cons.eventName then
    me:subscribeEvent(cons.eventName, cons.eventPayloadIndex)
  end

  return me
end

function Geyser.MarkdownLabel:setContent(markdown)
  return self:echo(markdown)
end

function Geyser.MarkdownLabel:echo(markdown)
  markdown = markdown or ""
  if markdown == self.lastMarkdown and self.lastRenderedHtml then
    return
  end

  local html = MarkdownAdapter.render(markdown)
  self.lastMarkdown = markdown
  self.lastRenderedHtml = html
  Geyser.Label.rawEcho(self, html)
end

function Geyser.MarkdownLabel:subscribeEvent(eventName, payloadIndex)
  self:unsubscribeEvent()

  self.eventName = eventName
  self.eventPayloadIndex = payloadIndex or self.eventPayloadIndex or 2

  local handlerName = self.name .. "_markdown_event"
  self.eventHandlerName = handlerName

  registerNamedEventHandler("geyser-markdown", handlerName, self.eventName, function(...)
    local args = { ... }
    local payload = args[self.eventPayloadIndex]
    if payload == nil then
      return
    end
    self:setContent(tostring(payload))
  end)

  return true
end

function Geyser.MarkdownLabel:unsubscribeEvent()
  if not self.eventHandlerName then
    return
  end

  deleteNamedEventHandler("geyser-markdown", self.eventHandlerName)
  self.eventHandlerName = nil
end

function Geyser.MarkdownLabel:destroy()
  self:unsubscribeEvent()
  if Geyser.Label.destroy then
    return Geyser.Label.destroy(self)
  end
end

return Geyser.MarkdownLabel
