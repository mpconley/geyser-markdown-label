local adapter = dofile("package-src/lua/MarkdownAdapter.lua")

local function assert_contains(haystack, needle)
  if not haystack:find(needle, 1, true) then
    error(string.format("Expected output to contain '%s'\nActual:\n%s", needle, haystack))
  end
end

local function assert_not_contains(haystack, needle)
  if haystack:find(needle, 1, true) then
    error(string.format("Expected output not to contain '%s'\nActual:\n%s", needle, haystack))
  end
end

local function run_case(name, fn)
  local ok, err = pcall(fn)
  if not ok then
    io.stderr:write("[FAIL] " .. name .. "\n" .. tostring(err) .. "\n")
    os.exit(1)
  end
  print("[PASS] " .. name)
end

run_case("heading and emphasis", function()
  local html = adapter.render("# Hello\nThis is **bold** and _italic_.")
  assert_contains(html, "<h1>Hello</h1>")
  assert_contains(html, "<strong>bold</strong>")
  assert_contains(html, "<em>italic</em>")
end)

run_case("raw html is escaped", function()
  local html = adapter.render("<script>alert(1)</script>")
  assert_contains(html, "&lt;script&gt;alert(1)&lt;/script&gt;")
  assert_not_contains(html, "<script>")
end)

run_case("unsafe links are dropped", function()
  local html = adapter.render("[x](javascript:alert(1))")
  assert_not_contains(html, "<a href=")
  assert_contains(html, "x")
end)

run_case("safe links are preserved", function()
  local html = adapter.render("[Mudlet](https://www.mudlet.org)")
  assert_contains(html, '<a href="https://www.mudlet.org">Mudlet</a>')
end)

run_case("fenced code blocks escape html", function()
  local html = adapter.render("```\n<hello>\n```")
  assert_contains(html, "<pre><code>")
  assert_contains(html, "&lt;hello&gt;")
  assert_contains(html, "</code></pre>")
end)

run_case("task list fallback characters", function()
  local html = adapter.render("- [x] done\n- [ ] todo")
  assert_contains(html, "☑ done")
  assert_contains(html, "☐ todo")
end)

run_case("table rendering", function()
  local html = adapter.render("| A | B |\n| --- | --- |\n| 1 | 2 |")
  assert_contains(html, "<table")
  assert_contains(html, "<th>A</th>")
  assert_contains(html, "<td>1</td>")
end)

run_case("horizontal rule", function()
  local html = adapter.render("One\n---\nTwo")
  assert_contains(html, "<hr/>")
end)

run_case("nested unordered list", function()
  local html = adapter.render("- parent\n  - child\n  - child2\n- parent2")
  assert_contains(html, "<ul>")
  assert_contains(html, "<li>parent</li>")
  assert_contains(html, "<li>child</li>")
  assert_contains(html, "<li>parent2</li>")
end)

run_case("mixed list types at same indent", function()
  local html = adapter.render("1. one\n2. two\n- three\n- four")
  assert_contains(html, "<ol>")
  assert_contains(html, "<li>one</li>")
  assert_contains(html, "</ol>")
  assert_contains(html, "<ul>")
  assert_contains(html, "<li>three</li>")
end)

print("All adapter specs passed.")
