
if FORMAT:match "html" then
  local text = require "text"

  -- This is where you would add admonition types.
  local AdmonitionClasses = {
    note=1, warning=1, important=1, aside=1
  }

  local function rawAside(classes, attributes, contents)
    local str_attributes = {}
    attributes["class"] = table.concat(classes, " ")
    for k, v in pairs(attributes) do
      table.insert(str_attributes, k .. "=\"" .. v .. "\"")
    end
    local asideTag = "<aside " .. table.concat(str_attributes, " ") .. ">"
    local rv = {pandoc.RawBlock(FORMAT, asideTag), table.unpack(contents)}
    table.insert(rv, pandoc.RawBlock(FORMAT, "</aside>"))
    return rv
  end

  -- Converts ::: note ::: to an <aside> element in HTML if it contains one of
  -- the admonition classes.
  function Div(elem)
    for i, class in pairs(elem.attr.classes) do
      if AdmonitionClasses[text.lower(class)] then
        return rawAside(elem.attr.classes, elem.attr.attributes, elem.content)
      end
    end
  end

  -- Look for NOTE:, WARNING:, etc.. at the start of paragraphs. If so
  -- "upgrades" it to an admonition.
  function Para(elem)
    if #elem.content == 0 or elem.content[1].tag ~= "Str" then
      return
    end
    local first_inline = elem.content[1]
    local found, _, tag = string.find(first_inline.text, "^(%a+):$")
    if not found or not AdmonitionClasses[text.lower(tag)] then
      return
    end

    local content = elem.content:clone()
    content:remove(1)
    if #content and content[1].tag == "Space" then
      content:remove(1)
    end
    return rawAside({text.lower(tag)}, {}, {pandoc.Para(content)})
  end
end
