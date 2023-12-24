require("theprimeagen.set")
require("theprimeagen.remap")

-- DO NOT INCLUDE THIS
vim.opt.rtp:append("~/personal/streamer-tools")
-- DO NOT INCLUDE THIS

local augroup = vim.api.nvim_create_augroup
local ThePrimeagenGroup = augroup('ThePrimeagen', {})

local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup('HighlightYank', {})

function R(name)
    require("plenary.reload").reload_module(name)
end

autocmd('TextYankPost', {
    group = yank_group,
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({
            higroup = 'IncSearch',
            timeout = 40,
        })
    end,
})

autocmd({"BufWritePre"}, {
    group = ThePrimeagenGroup,
    pattern = "*",
    command = [[%s/\s\+$//e]],
})

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25

-- Aqui começa a sua nova função on_attach
local function on_attach(client, bufnr)
    if client.supports_method("textDocument/formatting") then
        vim.api.nvim_clear_autocmds({
            group = ThePrimeagenGroup,
            buffer = bufnr,
        })
        vim.api.nvim_create_autocmd("BufWritePre", {
            group = ThePrimeagenGroup,
            buffer = bufnr,
            callback = function()
                vim.lsp.buf.format({ buffnr = bufnr })
            end,
        })
    end
end

-- Configuração do null-ls com on_attach
local null_ls = require("null-ls")
null_ls.setup({
    sources = {
        null_ls.builtins.formatting.goimports,
        null_ls.builtins.formatting.black.with({
            extra_args = { "--line-length", "79" },
        }),
        null_ls.builtins.formatting.isort,
        null_ls.builtins.diagnostics.flake8,
        null_ls.builtins.formatting.prettier.with({
            extra_args = { "--print-width", "76" },
            filetypes = { "html", "css", "json", "gohtml" },
        }),
    },
    on_attach = on_attach,  -- Adicionando aqui
})
