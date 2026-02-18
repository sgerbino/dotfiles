return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false,
  build = ':TSUpdate',
  config = function()
    local parsers = { 'bash', 'c', 'cpp', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query' }

    -- The main branch stores queries under runtime/ which lazy.nvim doesn't add to rtp
    local ts_path = vim.fs.joinpath(vim.fn.stdpath('data'), 'lazy', 'nvim-treesitter', 'runtime')
    if vim.uv.fs_stat(ts_path) then
      vim.opt.rtp:prepend(ts_path)
    end

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
