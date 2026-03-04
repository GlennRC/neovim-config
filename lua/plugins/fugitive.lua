return {
  'tpope/vim-fugitive',
  cmd = { 'Git', 'G', 'Gdiffsplit', 'Gread', 'Gwrite' },
  keys = {
    { '<leader>gs', '<cmd>Git<cr>', desc = 'Git status (fugitive)' },
    { '<leader>gd', '<cmd>Gdiffsplit<cr>', desc = 'Git diff split' },
    { '<leader>gl', '<cmd>Git log --oneline -50<cr>', desc = 'Git log (last 50)' },
  },
}
