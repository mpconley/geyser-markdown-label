# Geyser MarkdownLabel

Write Markdown. See it beautifully rendered in Mudlet.

**Geyser MarkdownLabel** is a Mudlet package that adds a new kind of window to your game: one that understands Markdown. Headings, lists, tables, checkboxes, links, code blocks — write plain text, get rich formatting.

## Why you'll like it

- **No HTML wrangling.** Stop hand-crafting `<div>` tags to make a nice panel. Just write Markdown like you would anywhere else.
- **Perfect for game content.** Help screens, quest journals, bulletin boards, character sheets — anything your game or scripts want to show with style.
- **Live updates.** Point a label at an event and it re-renders whenever new content arrives. Great for GMCP-driven panels.
- **Safe by default.** Raw HTML is stripped and unsafe links are ignored, so server-sent content can't mess with your UI.
- **Zero dependencies.** Pure Lua, works with the Geyser framework you already know.

## Quick start

1. Download `geyser-markdown.mpackage` from the [latest release](https://github.com/mpconley/geyser-markdown-label/releases/latest).
2. Drag and drop it onto your Mudlet window (or use the Package Manager).
3. Try the demo:

```lua
lua GeyserMarkdownDemo.show()
```

## Use it in your scripts

```lua
local notes = Geyser.MarkdownLabel:new({
  name = "questNotes",
  x = "70%", y = "10%",
  width = "28%", height = "50%",
})

notes:echo([[
# Quest Journal

- [x] Find the hidden key
- [ ] Unlock the tower door

| Reward | Amount |
| --- | --- |
| Gold | 500 |
| XP | 1200 |
]])
```

Want it to update itself? Subscribe it to an event:

```lua
notes:subscribeEvent("quest.update")
-- elsewhere: raiseEvent("quest.update", "## New objective\n\nSpeak to the innkeeper.")
```

## What's supported

Headings, bold/italic/strikethrough, ordered and unordered lists (nested too), task lists, tables, fenced code blocks, blockquotes, links, and horizontal rules.

## Feedback welcome

Found a bug or have an idea? [Open an issue](https://github.com/mpconley/geyser-markdown-label/issues) — feedback shapes where this goes next.
