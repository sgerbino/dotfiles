return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false,
  build = ':TSUpdate',
  config = function()
    local parsers = { 'bash', 'c', 'cpp', 'diff', 'html', 'javascript', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'regex', 'rust', 'typescript', 'zig' }

    -- FreeBSD doesn't automatically resolve nested runtime/ in plugins
    vim.opt.runtimepath:append(vim.fn.stdpath('data') .. '/lazy/nvim-treesitter/runtime')

    require('nvim-treesitter').setup()
    require('nvim-treesitter').install(parsers)

    vim.api.nvim_create_autocmd('FileType', {
      pattern = '*',
      callback = function()
        pcall(vim.treesitter.start)
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
