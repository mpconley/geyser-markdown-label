local Demo = {}

function Demo.show()
  if not Geyser or not Geyser.MarkdownLabel then
    cecho("<red>Geyser.MarkdownLabel is not available.\n")
    return
  end

  if Demo.label then
    Demo.label:unsubscribeEvent()
    Demo.label:hide()
  end

  Demo.label = Geyser.MarkdownLabel:new({
    name = "MarkdownDemoLabel",
    x = "2%",
    y = "2%",
    width = "46%",
    height = "35%",
    eventName = "gm.markdown.demo",
    eventPayloadIndex = 2,
  })

  Demo.label:setStyleSheet([[background-color: #111; color: #ddd; border: 1px solid #444; padding: 8px;]])
  Demo.label:echo([[# Markdown Demo

- [x] Task complete
- [ ] Task pending

| Feature | Status |
| --- | --- |
| Headings | **Yes** |
| Links | [Mudlet](https://www.mudlet.org) |

```lua
print("hello from fenced code")
```

Trigger live updates via:
`raiseEvent("gm.markdown.demo", "## Updated\n\nThis came from an event.")`
]])

  cecho("<green>Markdown demo label created.\n")
end

function Demo.hide()
  if not Demo.label then
    return
  end
  Demo.label:unsubscribeEvent()
  Demo.label:hide()
  Demo.label = nil
  cecho("<yellow>Markdown demo label hidden.\n")
end

_G.GeyserMarkdownDemo = Demo
return Demo
