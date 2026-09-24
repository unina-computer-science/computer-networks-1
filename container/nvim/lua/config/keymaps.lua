local map = vim.keymap.set

-- Better window navigation.
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Resize windows.
map("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height" })
map("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height" })
map("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
map("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

-- Move lines up and down in visual mode.
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Keep cursor centered when scrolling.
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down centered" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up centered" })

-- Keep cursor centered when searching.
map("n", "n", "nzzzv", { desc = "Next search result centered" })
map("n", "N", "Nzzzv", { desc = "Previous search result centered" })

-- Better paste (don't overwrite register).
map("x", "<leader>p", '"_dP', { desc = "Paste without overwriting" })

-- Save file.
map("n", "<leader>w", ":w<CR>", { desc = "Save file" })

-- Quit.
map("n", "<leader>q", ":q<CR>", { desc = "Quit" })

-- Clear search highlight.
map("n", "<Esc>", ":noh<CR>", { desc = "Clear search highlight" })

-- CN1: build and run the current C file in a split terminal, with the
-- course's compile line. -lssl -lcrypto are added by themselves when the
-- file includes OpenSSL. <leader>r runs with no arguments, <leader>R asks
-- for them (./tick_server 6000, ./udp_ping server 7000...).
local function compile_and_run(ask_args)
    if vim.bo.filetype ~= "c" then
        vim.notify("Not a C file", vim.log.levels.WARN)
        return
    end
    local args = ""
    if ask_args then
        args = vim.fn.input("Arguments: ")
    end
    vim.cmd("write")
    local src = vim.fn.expand("%:p")
    local exe = vim.fn.expand("%:p:r")
    local libs = ""
    for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
        if line:match("^%s*#%s*include%s*<openssl/") then
            libs = " -lssl -lcrypto"
            break
        end
    end
    local cmd = string.format(
        "gcc -Wall -Wextra -pthread -g -o %s %s%s && %s %s",
        vim.fn.shellescape(exe), vim.fn.shellescape(src), libs,
        vim.fn.shellescape(exe), args
    )
    vim.cmd("botright split | resize 15 | terminal " .. cmd)
    vim.cmd("startinsert")
end
map("n", "<leader>r", function() compile_and_run(false) end, { desc = "Build and run (C)" })
map("n", "<leader>R", function() compile_and_run(true) end, { desc = "Build and run with arguments (C)" })
