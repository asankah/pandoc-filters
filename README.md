# Pandoc Filters

Useful [pandoc](https://pandoc.org) filters. Primarily useful for converting Markdown to HTML for blogs and other things.

All the filters are in the `filters/` subdirectory. That way you only need to add one directory to your `resource-path`.

## Admonitions / Aside

Converts [`Div`s](https://pandoc.org/MANUAL.html#divs-and-spans) that include specific classes into HTML `<aside>` elements. For example:

``` markdown
::: note :::
This is a note.

It can contain multiple paragraphs.
::::::
```

Will result in:

``` html
<aside class="note">
This is a note.
<p>
It can contain multiple paragraphs.
</aside>
```

Another single-paragraph admonition style is supported:

``` markdown
NOTE: This is a single-paragraph admonition.

This is not a part of the admonition.
```

Use as:

```sh
pandoc --resource-path /path/to/pandoc-filters/filters --lua-filter=admonitions.lua -t html my-doc.md
```

**NOTE**: This filter only works when the output format is `html5`, and not `html`.

Currently it recognizes the following admonitions: **note**, **warning**, **important**, **aside**.

