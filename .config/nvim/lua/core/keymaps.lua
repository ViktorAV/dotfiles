-- modes Normal Insert Visual Terminal Operator-pending Command-line
-- silent подавляет вывод команды в командную строку, если true
-- noremap, no recursive mapping, игнорирует ранее определенные маппинги
-- buffer привязывает клавишу только в текущем буфере, если true
-- desc определяет строку подсказки для клавиши, для which-key и прочих

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.keymap.set({'i', 'n', 'v', 'c', 't', 'x'}, ';', ':', { noremap = true, silent = false })
vim.keymap.set({'i', 'n', 'v', 'c', 't', 'x'}, ':', ';', { noremap = true, silent = false })

-- Добавить ударение
vim.api.nvim_set_keymap('n', '<A-`>', 'a<C-v>u0301<Esc>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('i', '<A-`>', '<C-v>u0301', {noremap = true, silent = true})

-- LSP
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list'})

-- Передвижение
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = "moves lines down in visual selection" })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = "moves lines up in visual selection" })
vim.keymap.set('n', '<C-space>', function()
    require('leap').leap { backward = true }
end)

vim.keymap.set('n', 'n', 'nzzzv', { desc = "next search with cursor centered" })
vim.keymap.set('n', 'N', 'Nzzzv', { desc = "prev search with cursor centered" })
vim.keymap.set('v', '<', '<gv', { desc = "move selected" })
vim.keymap.set('v', '>', '>gv', {  desc = "move selected" })
vim.keymap.set('i', '<C-Enter>', '<Esc>o', { desc = "cursor to next line" })

-- Буфер обмена
-- vim.keymap.set('x', '<leader>p', [["_dP]], { desc = "paste without replacing clipboard content" })
-- vim.keymap.set('v', 'p', '"_dP',  { desc = "prevents pasting from replacing your clipboard" })
-- vim.keymap.set({ 'n', 'v' }, '<leader>d', [["_d]], { desc = "delete without copy" })
-- vim.keymap.set('n', 'x', '"_x',  { desc = "prevents deleted characters from copying to clipboard" })

-- Буферы
vim.keymap.set('n', '<BS>', '<cmd>w<cr><cmd>bd!<cr>', { desc = 'close buffer' })
vim.keymap.set('n', '<C-r>', function()
    local confirm = vim.fn.confirm('Delete file?', '&yes\n&no', 1)
    if confirm == 1 then
        os.remove(vim.fn.expand '%')
        vim.api.nvim_buf_delete(0, { force = true })
    end
end, { desc = 'delete and close bufer' })
vim.keymap.set('n', '<C-s>', ':!save_path %<cr>', { desc = 'safe file', silent = true })
vim.keymap.set('n', '<leader>bc', '<cmd>new<cr>', { desc = 'create buffer' })
vim.keymap.set('n', '<leader>bn', '<cmd>bn<cr>', { desc = 'next buffer' })
vim.keymap.set('n', '<leader>bp', '<cmd>bp<cr>', { desc = 'prev buffer' })

-- Остальное
vim.keymap.set('n', '<C-c>', ':nohl<CR>', { desc = "clear search highlights', silent = true" })
vim.keymap.set('n', 'g=', "g+", { desc = "redo" })
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Hightlight when yanking text",
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})
vim.keymap.set('n', '<leader>x', '<cmd>!chmod +x %<CR>', { silent = true, desc = 'makes file executable' })
vim.keymap.set('n', '<leader>r', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
                                   { desc = "globally replace word under cursor" })
vim.keymap.set('n', '<leader>cp', function()
    local filepath = vim.fn.expand('%:~') -- gets the file path relative to the home directory
    vim.fn.setreg('+', filepath) -- copy the file path to the clipboard register
    print('File path copied to clipboard: ' .. filepath)
end, { desc = 'copy filepath to the clipboard'})

-- Табы
-- vim.keymap.set('n', '<leader>to', '<cmd>tabnew<CR>', { desc = 'open new tab' })
-- vim.keymap.set('n', '<leader>tx', '<cmd>tabclose<CR>', { desc = 'close current tab' })
-- vim.keymap.set('n', '<leader>tn', '<cmd>tabn<CR>', { desc = 'go to next tab' })
-- vim.keymap.set('n', '<leader>tp', '<cmd>tabp<CR>', { desc = 'go to prev tab' })
-- vim.keymap.set('n', '<leader>tf', '<cmd>tabnew %<CR>', { desc = 'open current tab in new tab' })

-- Окна
-- vim.keymap.set('n', '<leader>sv', '<C-w>v', { desc = 'split window vertically' })
-- vim.keymap.set('n', '<leader>sh', '<C-w>s', { desc = 'split window horizontally' })
-- vim.keymap.set('n', '<leader>se', '<C-w>=', { desc = 'make split windows equal size' })
-- vim.keymap.set('n', '<leader>sx', '<cmd>close<CR>', { desc = 'close current split window' })
-- vim.keymap.set('n', '<C-w>q', '<cmd>close<cr>', { desc = 'close current window' })
-- C-S-h/j/k/l (resize) 
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
vim.keymap.set('n', '<C-x>', '<C-w>c', { desc = 'Move focus to the upper window' })

local function toggle_fullscreen()
  local api = vim.api
  local current_win = api.nvim_get_current_win()

  local success, win_vars = pcall(function()
    return api.nvim_win_get_var(current_win, 'fullscreen_state')
  end)

  if not success or win_vars == nil then
    win_vars = { is_fullscreen = false }
  end

  if win_vars.is_fullscreen then
    api.nvim_cmd({ cmd = 'wincmd', args = { '=' } }, {})
    win_vars.is_fullscreen = false
  else
    api.nvim_cmd({ cmd = 'wincmd', args = { '_' } }, {}) -- макс. высота
    api.nvim_cmd({ cmd = 'wincmd', args = { '|' } }, {}) -- макс. ширина
    win_vars.is_fullscreen = true
  end

  api.nvim_win_set_var(current_win, 'fullscreen_state', win_vars)
end

vim.keymap.set('n', '<C-w><C-f>', toggle_fullscreen, { silent = true, desc = 'Toggle fullscreen window' })
-- vim.keymap.set('t', '<C-w>f', '<cmd>tab split<cr>', { desc = '"Fullscreen" window' })
-- vim.keymap.set('t', '<C-w><C-f>', function()
--   vim.api.nvim_feedkeys(
--     vim.api.nvim_replace_termcodes('<C-\\><C-n>', true, false, true),
--     'n',
--     false
--   )
--   toggle_fullscreen()
--   vim.api.nvim_feedkeys(
--     vim.api.nvim_replace_termcodes('i', true, false, true),
--     'n',
--     false
--   )
-- end, {
--   silent = true,
--   desc = 'Toggle fullscreen in terminal'
-- })

vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.keymap.set({'t', 'n'}, '<C-\\>', function()
    -- vim.cmd('RunTerminal')
    vim.cmd('ToggleProjectTerminal')
end, { noremap = true, silent = true })

-- Команды
vim.api.nvim_create_user_command('W', function()
    vim.cmd('silent w !sudo tee % > /dev/null')
    vim.cmd('edit!')
end, {
    desc = 'Сохраняет файл с правами sudo'
})

vim.api.nvim_create_user_command('Signal', function()
    vim.cmd('w')
    vim.cmd('silent !kill -SIGUSR1 `cat $mastery_pid`')
end, {
	bang = true,
    desc = 'Отправляет сигнал на перечитывание файла в mastery'
})
