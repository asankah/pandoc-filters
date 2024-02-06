local pandoc=require("pandoc")

-- Only targets HTML for now.
if FORMAT:match "html" then

  -- Converts a link text to a pandoc Link element.
  --
  -- The link text excludes the surrounding [[]]. Treats link text like
  -- "foobar" as if it was `[foobar](foobar.html)`. Or
  -- "foobar#fragment|description" as `[description](foobar.html#fragment)`.
  local function handleLink(lt)
    local description = nil
    local link = nil
    local fragment = ""
    if lt:find("|") then
      link, description = lt:match("^(.*)%|(.*)$")
    else
      link = lt
    end
    if link:find("#") then
      link, fragment = link:match("^(.*)(#.*)$")
    end

    if not description then
      description = link
    end

    if not link:find(":") then
      link = link .. ".html"
    end

    return pandoc.Link(description, link .. fragment)
  end

  -- Filter out runs of inlines together rather than individual AST nodes. It
  -- is possible for links to contain whitespace which would be split into
  -- separate `Str` and `Space` nodes in the AST.
  function Inlines(inlines)
    local is_in_link = false
    local link_so_far = ""
    local filters = {
      Str = function (el)
        if is_in_link then
          if el.text:find("%]%]$") then
            local linkText = link_so_far .. el.text:sub(1, -3)
            link_so_far = ""
            is_in_link = false
            return handleLink(linkText)
          else
            link_so_far = link_so_far .. el.text
            return nil
          end
        else
          local linkText = el.text:match("^%[%[(.*)%]%]$")
          if linkText then
            return handleLink(linkText)
          end

          link_so_far = el.text:match("^%[%[(.*)")
          if link_so_far then
            is_in_link = true
            return nil
          end
        end
        return el
      end,
      Space = function (el)
        if is_in_link then
          link_so_far = link_so_far .. " "
          return nil
        end
        return el
      end
    }

    -- `filtered` collects the converted AST nodes. Not a simple `map` since
    -- not all AST nodes will make it across.
    local filtered = pandoc.List({})

    for _, v in ipairs(inlines) do
      if filters[v.tag] then
        local f = filters[v.tag](v)
        if f then
          filtered:insert(f)
        end
      else
        if is_in_link then
          -- bad link. Backpeddle
          filtered:insert(pandoc.Str("[[" .. link_so_far))
          filtered:insert(v)
          is_in_link = false
        else
          filtered:insert(v)
        end
      end
    end

    if is_in_link then
      filtered:extend(pandoc.Inlines("[[" .. link_so_far))
    end
    return filtered
  end
end
