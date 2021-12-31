# Admonitions example

The example can be invoked as:

```sh
pandoc --lua-filter=../../filters/admonitions.lua note.md -o note.html
```

::: note :::
This is a note.

It can contain multiple paragraphs.
::::::

NOTE: This is a single-paragraph admonition.

This is not a part of the admonition.

::: {.note .with .additional .classes and="attributes"}
This is another note.
:::

::: Warning :::
Note class is case-insensitive. However the resulting `<aside>` element will have a `class=""` attribute with the case preserved.
:::

IMPORTANT: When using a single-paragraph admonition, the resulting `<aside>` element will have a class with a **lower case** name corresponding to the tag.

THIS: IS NOT AN ADMONITION. It's just a paragraph starting with some upper case words.

ASIDE: Aside also works.

