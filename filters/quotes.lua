local pandoc=require("pandoc")

if FORMAT:match "html" then
  function BlockQuote(content)
    -- Check whether the last block starts with two dashes.
    local els = content.content

    if #els == 0 then
      return
    end

    local last_block = els[#els]
    local last_block_text = pandoc.utils.stringify(last_block)
    if string.sub(last_block_text, 1, 3) ~= "-- " then
      return
    end

    els:insert(1, pandoc.RawBlock("html", "<figure>"))
    els:insert(#els, pandoc.RawBlock("html", "<figcaption>"))
    els:insert(pandoc.RawBlock("html", "</figcaption>"))
    els:insert(pandoc.RawBlock("html", "</figure>"))

    return pandoc.BlockQuote(els)
  end
end
