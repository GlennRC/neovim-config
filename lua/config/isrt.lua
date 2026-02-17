-- ISRT keyboard layout remaps for ZSA Voyager
-- Matches nav layer (Layer 3): N=Left, E=Up, A=Down, O=Right
--
-- Navigation (right home row):
--   n=left  e=up  a=down  o=right
--
-- Displaced commands (bidirectional swap):
--   h=next search  k=end of word  j=append  l=open line below
--
-- Text objects: use j/l instead of a/o
--   e.g., djw = "delete a word", ciw = "change inner word" (i unchanged)

local modes = { "n", "x", "o" }

-- n ↔ h : left ↔ next search
vim.keymap.set(modes, "n", "h", { desc = "Left" })
vim.keymap.set(modes, "h", "n", { desc = "Next search match" })
vim.keymap.set(modes, "N", "H", { desc = "Top of screen" })
vim.keymap.set(modes, "H", "N", { desc = "Prev search match" })

-- e ↔ k : up ↔ end of word
vim.keymap.set(modes, "e", "k", { desc = "Up" })
vim.keymap.set(modes, "k", "e", { desc = "End of word" })
vim.keymap.set(modes, "E", "K", { desc = "Keyword lookup" })
vim.keymap.set(modes, "K", "E", { desc = "End of WORD" })

-- a ↔ j : down ↔ append
vim.keymap.set(modes, "a", "j", { desc = "Down" })
vim.keymap.set(modes, "j", "a", { desc = "Append" })
vim.keymap.set(modes, "A", "J", { desc = "Join lines" })
vim.keymap.set(modes, "J", "A", { desc = "Append at EOL" })

-- o ↔ l : right ↔ open line below
vim.keymap.set(modes, "o", "l", { desc = "Right" })
vim.keymap.set(modes, "l", "o", { desc = "Open line below" })
vim.keymap.set(modes, "O", "L", { desc = "Bottom of screen" })
vim.keymap.set(modes, "L", "O", { desc = "Open line above" })

-- g-prefixed: display line movement
vim.keymap.set(modes, "ga", "gj", { desc = "Down (display line)" })
vim.keymap.set(modes, "ge", "gk", { desc = "Up (display line)" })
vim.keymap.set(modes, "gj", "ga", { desc = "Show char code" })
vim.keymap.set(modes, "gk", "ge", { desc = "Back end of word" })
vim.keymap.set(modes, "gA", "gJ", { desc = "Join lines (no space)" })
vim.keymap.set(modes, "gK", "gE", { desc = "Back end of WORD" })

-- Window navigation (Ctrl+w)
vim.keymap.set("n", "<C-w>n", "<C-w>h", { desc = "Window left" })
vim.keymap.set("n", "<C-w>e", "<C-w>k", { desc = "Window up" })
vim.keymap.set("n", "<C-w>a", "<C-w>j", { desc = "Window down" })
vim.keymap.set("n", "<C-w>o", "<C-w>l", { desc = "Window right" })
