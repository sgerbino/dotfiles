return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false,
  build = ':TSUpdate',
  config = function()
    local parsers = { 'bash', 'c', 'cpp', 'diff', 'html', 'javascript', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'regex', 'rust', 'typescript', 'zig' }

    require('nvim-treesitter').setup()
    require('nvim-treesitter').install(parsers)

    -- Deferred so it persists after Lazy.nvim finalizes runtimepath
    vim.schedule(function()
      vim.opt.runtimepath:append(vim.fn.stdpath('data') .. '/lazy/nvim-treesitter/runtime')
    end)

    vim.api.nvim_create_autocmd('FileType', {
      pattern = '*',
      callback = function()
        pcall(vim.treesitter.start)
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
