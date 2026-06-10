local MarkdownAdapter = {}

local function escape_html(text)
  text = text:gsub("&", "&amp;")
  text = text:gsub("<", "&lt;")
  text = text:gsub(">", "&gt;")
  return text
end

local function sanitize_url(url)
  local lower = (url or ""):lower()
  if lower:match("^https://") or lower:match("^http://") or lower:match("^mailto:") then
    return url
  end
  return nil
end

local function trim(text)
  return (text:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function starts_with(text, prefix)
  return text:sub(1, #prefix) == prefix
end

local function parse_inline(text)
  local code_spans = {}
  local index = 0

  text = text:gsub("`([^`]+)`", function(code)
    index = index + 1
    local token = "@@CODE" .. index .. "@@"
    code_spans[token] = "<code>" .. escape_html(code) .. "</code>"
    return token
  end)

  text = escape_html(text)

  text = text:gsub("%[([^%]]+)%]%(([^%)]+)%)", function(label, url)
    local safe_url = sanitize_url(trim(url))
    if not safe_url then
      return label
    end
    return string.format('<a href="%s">%s</a>', escape_html(safe_url), label)
  end)

  text = text:gsub("%*%*([^%*]+)%*%*", "<strong>%1</strong>")
  text = text:gsub("__([^_]+)__", "<strong>%1</strong>")
  text = text:gsub("~~([^~]+)~~", "<s>%1</s>")
  text = text:gsub("%*([^%*]+)%*", "<em>%1</em>")
  text = text:gsub("_([^_]+)_", "<em>%1</em>")

  for token, replacement in pairs(code_spans) do
    text = text:gsub(token, replacement)
  end

  return text
end

local function is_table_separator(line)
  if not line:find("|") then
    return false
  end

  local row = trim(line)
  row = row:gsub("^|", ""):gsub("|$", "")

  local has_column = false
  for cell in row:gmatch("([^|]+)") do
    has_column = true
    local cleaned = trim(cell)
    if cleaned == "" or not cleaned:match("^:?-+:?$") then
      return false
    end
  end

  return has_column
end

local function split_table_row(line)
  local row = trim(line)
  row = row:gsub("^|", ""):gsub("|$", "")
  local cells = {}
  for cell in row:gmatch("([^|]+)") do
    cells[#cells + 1] = trim(cell)
  end
  return cells
end

function MarkdownAdapter.render(markdown)
  markdown = markdown or ""
  markdown = markdown:gsub("\r\n", "\n")
  markdown = markdown:gsub("\r", "\n")

  local lines = {}
  for line in (markdown .. "\n"):gmatch("(.-)\n") do
    lines[#lines + 1] = line
  end

  local out = {}
  local i = 1
  local in_code_block = false
  local list_stack = {}

  local function close_lists(min_indent)
    min_indent = min_indent or -1
    while #list_stack > 0 and list_stack[#list_stack].indent >= min_indent do
      out[#out + 1] = "</" .. list_stack[#list_stack].type .. ">"
      table.remove(list_stack)
    end
  end

  local function ensure_list(list_type, indent)
    while #list_stack > 0 and list_stack[#list_stack].indent > indent do
      out[#out + 1] = "</" .. list_stack[#list_stack].type .. ">"
      table.remove(list_stack)
    end

    if #list_stack > 0 and list_stack[#list_stack].indent == indent and list_stack[#list_stack].type ~= list_type then
      out[#out + 1] = "</" .. list_stack[#list_stack].type .. ">"
      table.remove(list_stack)
    end

    if #list_stack == 0 or list_stack[#list_stack].indent < indent or list_stack[#list_stack].type ~= list_type then
      out[#out + 1] = "<" .. list_type .. ">"
      list_stack[#list_stack + 1] = { type = list_type, indent = indent }
    end
  end

  while i <= #lines do
    local line = lines[i]

    if line:match("^%s*```") then
      close_lists()
      if not in_code_block then
        in_code_block = true
        out[#out + 1] = "<pre><code>"
      else
        in_code_block = false
        out[#out + 1] = "</code></pre>"
      end
      i = i + 1
      goto continue
    end

    if in_code_block then
      out[#out + 1] = escape_html(line)
      i = i + 1
      goto continue
    end

    if line == "" then
      close_lists()
      i = i + 1
      goto continue
    end

    local trimmed = trim(line)
    if trimmed:match("^[-*_][-%*_][-%*_]+$") then
      close_lists()
      out[#out + 1] = "<hr/>"
      i = i + 1
      goto continue
    end

    if i + 1 <= #lines and line:find("|") and is_table_separator(lines[i + 1]) then
      close_lists()
      local header_cells = split_table_row(line)
      out[#out + 1] = "<table border=\"1\" cellspacing=\"0\" cellpadding=\"4\">"
      out[#out + 1] = "<thead><tr>"
      for _, cell in ipairs(header_cells) do
        out[#out + 1] = "<th>" .. parse_inline(cell) .. "</th>"
      end
      out[#out + 1] = "</tr></thead><tbody>"
      i = i + 2
      while i <= #lines and lines[i] ~= "" and lines[i]:find("|") do
        local row_cells = split_table_row(lines[i])
        out[#out + 1] = "<tr>"
        for _, cell in ipairs(row_cells) do
          out[#out + 1] = "<td>" .. parse_inline(cell) .. "</td>"
        end
        out[#out + 1] = "</tr>"
        i = i + 1
      end
      out[#out + 1] = "</tbody></table>"
      goto continue
    end

    local heading_level, heading_text = line:match("^(#+)%s+(.+)$")
    if heading_level then
      close_lists()
      local level = #heading_level
      if level > 6 then
        level = 6
      end
      out[#out + 1] = string.format("<h%d>%s</h%d>", level, parse_inline(heading_text), level)
      i = i + 1
      goto continue
    end

    local quote = line:match("^>%s?(.*)$")
    if quote then
      close_lists()
      out[#out + 1] = "<blockquote>" .. parse_inline(quote) .. "</blockquote>"
      i = i + 1
      goto continue
    end

    local ordered_indent, ordered_text = line:match("^(%s*)%d+%.%s+(.+)$")
    if ordered_text then
      ensure_list("ol", #ordered_indent)
      out[#out + 1] = "<li>" .. parse_inline(ordered_text) .. "</li>"
      i = i + 1
      goto continue
    end

    local unordered_indent, unordered_text = line:match("^(%s*)[-%*+]%s+(.+)$")
    if unordered_text then
      ensure_list("ul", #unordered_indent)
      local task_checked, task_text = unordered_text:match("^%[([ xX])%]%s+(.+)$")
      if task_checked then
        local checkbox = task_checked:lower() == "x" and "☑ " or "☐ "
        out[#out + 1] = "<li>" .. checkbox .. parse_inline(task_text) .. "</li>"
      else
        out[#out + 1] = "<li>" .. parse_inline(unordered_text) .. "</li>"
      end
      i = i + 1
      goto continue
    end

    if starts_with(trimmed, "\\") then
      line = trimmed:sub(2)
    end

    close_lists()
    out[#out + 1] = "<p>" .. parse_inline(line) .. "</p>"

    i = i + 1
    ::continue::
  end

  close_lists()

  if in_code_block then
    out[#out + 1] = "</code></pre>"
  end

  return table.concat(out, "\n")
end

_G.GeyserMarkdownAdapter = MarkdownAdapter
return MarkdownAdapter
