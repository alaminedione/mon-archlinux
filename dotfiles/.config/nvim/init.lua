-- This file simply bootstraps the installation of Lazy.nvim and then calls other files for execution
-- This file doesn't necessarily need to be touched, BE CAUTIOUS editing this file and proceed at your own risk.
local lazypath = vim.env.LAZY or vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not (vim.env.LAZY or (vim.uv or vim.loop).fs_stat(lazypath)) then
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- validate that lazy is available
if not pcall(require, "lazy") then
  -- stylua: ignore
  vim.api.nvim_echo({ { ("Unable to load lazy from: %s\n"):format(lazypath), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } }, true, {})
  vim.fn.getchar()
  vim.cmd.quit()
end

require "lazy_setup"
require "polish"

-- naviguer avec tab
vim.api.nvim_set_keymap("n", "<Tab>", ":bnext<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<S-Tab>", ":bprevious<CR>", { noremap = true, silent = true })

-- Masquer les diagnostics en ligne (virtual text) par défaut
vim.diagnostic.config {
  virtual_text = false, -- Désactive l'affichage des diagnostics en ligne
}

require("telescope").setup {
  defaults = {
    vimgrep_arguments = {
      "rg",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
      "--glob",
      "!**/node_modules/*", -- Exclure node_modules
      "--glob",
      "!**/.git/*", -- Exclure .git
      "--glob",
      "!**/build/*", -- Exclure build
      "--glob",
      "!**/dist/*", -- Exclure dist
      "--glob",
      "!**/tmp/*", -- Exclure tmp
      "--glob",
      "!**/logs/*", -- Exclure logs
      "--glob",
      "!**/coverage/*", -- Exclure coverage
      "--glob",
      "!**/bin/*", -- Exclure bin
      "--glob",
      "!**/vendor/*", -- Exclure vendor
      "--glob",
      "!**/.idea/*", -- Exclure .idea
      "--glob",
      "!**/.vscode/*", -- Exclure .vscode
      "--glob",
      "!**/.cache/*", -- Exclure .cache
      "--glob",
      "!**/docs/*", -- Exclure docs
      "--glob",
      "!**/backup/*", -- Exclure backup
    },
  },
}

-- Zen mode
vim.keymap.set("n", "<leader>zz", function() require("zen-mode").toggle() end, { desc = "Toggle Zen Mode" })
-- Toggle wrap
vim.keymap.set("n", "<Leader>zw", function() vim.opt.wrap = not vim.opt.wrap:get() end, { desc = "Toggle wrap" })
-- Hide/show terminal
vim.keymap.set("n", "<Leader>zt", function() require("toggleterm").toggle() end, { desc = "Hide terminal" })

--vim.opt.termguicolors = true


-- views can only be fully collapsed with the global statusline
vim.opt.laststatus = 3
vim.cmd [[colorscheme catppuccin-latte]]
