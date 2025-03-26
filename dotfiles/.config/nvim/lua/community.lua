-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.lua" },
  -- import/override with your plugins folder
  { import = "astrocommunity.pack.html-css" },
  { import = "astrocommunity.pack.php" },
  -- { import = "astrocommunity.pack.blade" },
  { import = "astrocommunity.pack.laravel" },
  { import = "astrocommunity.pack.python" },
  -- { import = "astrocommunity.pack.python-ruff" },
  { import = "astrocommunity.pack.markdown" },
  { import = "astrocommunity.pack.typescript" },
  { import = "astrocommunity.pack.sql" },
  { import = "astrocommunity.pack.dart" },
  { import = "astrocommunity.pack.go" },

  { import = "astrocommunity.pack.toml" },
  { import = "astrocommunity.pack.cpp" },
  { import = "astrocommunity.pack.bash" },
  { import = "astrocommunity.pack.json" },
  { import = "astrocommunity.pack.java" },
  { import = "astrocommunity.pack.astro" },
  { import = "astrocommunity.utility.hover-nvim" },
  { import = "astrocommunity.editing-support.neogen" },
   { import = "astrocommunity.colorscheme.catppuccin" },
  -- { import = "astrocommunity.pack.nvchad-ui" },
  --tailwind
  { import = "astrocommunity.pack.tailwindcss" },
  -- {import = "astrocommunity.programming-language-support.rest-nvim"}
}
