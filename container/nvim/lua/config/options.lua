-- Line numbers.
vim.opt.number = true
vim.opt.relativenumber = true

-- Default indentation (4 spaces).
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Search.
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.incsearch = true

-- Appearance.
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.scrolloff = 8

-- Behavior.
vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.backup = false

-- CN1: persistent undo goes to /workspace. stdpath("data") is in the image
-- and with --rm it would vanish at every exit, taking the edit history with
-- it.
vim.opt.undofile = true
local undodir = "/workspace/.nvim-undo"
vim.fn.mkdir(undodir, "p")
vim.opt.undodir = undodir

-- CN1: the container has neither xclip nor wl-clipboard nor a display, and
-- "unnamedplus" would raise an error on every yank. OSC 52 is used instead:
-- the copy reaches the host's clipboard through the terminal (Windows
-- Terminal, iTerm2, kitty, WezTerm, Alacritty, foot...). Terminals that do
-- not support it ignore the sequence. Paste reads the last copy made here:
-- asking the terminal for the clipboard is often blocked, and would hang.
if vim.fn.has("clipboard") == 0 then
    local osc52 = require("vim.ui.clipboard.osc52")
    local last = { {}, "v" }
    local function copy(reg)
        local send = osc52.copy(reg)
        return function(lines, regtype)
            last = { lines, regtype }
            send(lines, regtype)
        end
    end
    local function paste()
        return last
    end
    vim.g.clipboard = {
        name = "OSC 52 (CN1)",
        copy = { ["+"] = copy("+"), ["*"] = copy("*") },
        paste = { ["+"] = paste, ["*"] = paste },
    }
end
vim.opt.clipboard = "unnamedplus"

vim.opt.splitright = true
vim.opt.splitbelow = true

-- Leader key.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Treesitter parser install directory.
vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/site")
