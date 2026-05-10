local PythonRunner = {}

PythonRunner.config = {
    root_files = { "app.py", "main.py" },
    interpreter = "python",
    interpreters = { "python", "python -i", "ipython", "ipython -i" },
    interpreter_save_file = vim.fn.stdpath("data") .. "/python_runner.json",
    term_name_prefix = 'Python: ',
    close_on_exit = true, -- закрыть терминал после выполнения
    open_in_split = true, -- открывать в сплите или новом буфере
    split_direction = 'belowright', -- belowright, aboveleft, totheleft, toright
    split_size = '10', -- высота/ширина в строках/символах
}

function PythonRunner.set_config(options)
  for k, v in pairs(options or {}) do
    PythonRunner.config[k] = v
  end
end

function PythonRunner.load_interpreter_pick()
  local file = io.open(PythonRunner.config.interpreter_save_file, "r")
  if file then
    local content = file:read("*all")
    file:close()
    local data = vim.json.decode(content)
    PythonRunner.config.interpreter = data.interpreter
  end
end

function PythonRunner.save_interpreter_pick(selection)
  PythonRunner.config.interpreter = selection
  local data = { interpreter = selection }
  local json_data = vim.json.encode(data)
  local file, err = io.open(PythonRunner.config.interpreter_save_file, "w")
  if file then
    file:write(json_data)
    file:close()
  else
    vim.notify("Ошибка сохранения: " .. err, vim.log.levels.ERROR)
  end
end

function PythonRunner.pick_interpreter()
  PythonRunner.load_interpreter_pick()
  local display_interpreters = {}
  for i, item in ipairs(PythonRunner.config.interpreters) do
    local marker = (item == PythonRunner.config.interpreter) and "✓ " or "  "
    table.insert(display_interpreters, marker .. item)
  end
  vim.ui.select(
    display_interpreters,
    { prompt = "Выберите интерпретатор Python:", format_item = function(item) return item end },
    function(choice, idx)
      if choice and idx then
        local original_choice = choice:gsub("^%s*✓?%s*", "")
        PythonRunner.save_interpreter_pick(original_choice)
        -- vim.notify("Выбран: " .. original_choice, vim.log.levels.INFO)
      end
    end
  )
end

-- function PythonRunner.find_project_root()
--   local current_dir = vim.fn.getcwd()
--
--   local dir = current_dir
--   while dir and dir ~= "/" do
--     for _, marker in ipairs(PythonRunner.config.root_markers) do
--       if vim.loop.fs_stat(dir .. "/" .. marker) then
--         return dir
--       end
--     end
--     local parent = dir:match("^(.*)/[^/]*$")
--     if not parent or parent == dir then break end
--     dir = parent
--   end
--   return current_dir -- Возвращаем текущую директорию, если корень не найден
-- end

function PythonRunner.find_root_file(start_path)
    local current_path = start_path or vim.fn.getcwd()

    while current_path do
        for _, filename in ipairs(PythonRunner.config.root_files) do
            local full_path = vim.fs.joinpath(current_path, filename)

            if vim.loop.fs_stat(full_path) then
                return full_path
            end
        end

        local parent_path = vim.fs.dirname(current_path)

        if parent_path == current_path then
            break
        end

        current_path = parent_path
    end

    return nil
end

function PythonRunner.run_python(isproject)
    local current_file
    local working_dir =  vim.fn.getcwd()

    if isproject then
        current_file = PythonRunner.find_root_file(vim.fs.dirname(vim.fn.expand('%:p')))

        if not current_file then 
            vim.notify("🔎 Корневой файл из каталога " .. working_dir .. " не найден", vim.log.levels.INFO)
            return
        else
            vim.notify("🔎 Найден файл: " .. current_file, vim.log.levels.INFO)
        end
    else
        current_file = vim.fn.expand('%:p')
    end

    local filename = vim.fn.expand('%:t')

    -- if not current_file:match("%.py$") then
    --     vim.notify("❌ Не Python‑файл: " .. filename, vim.log.levels.WARN)
    --     return
    -- end

    local python_cmd = PythonRunner.config.interpreter .. " " .. current_file

    if PythonRunner.config.open_in_split then
        local term_cmd = 'cd ' .. working_dir .. ' && ' .. python_cmd
        vim.cmd('w')
        vim.cmd(PythonRunner.config.split_direction .. ' split ' .. PythonRunner.config.split_size)
        vim.cmd('term ' .. term_cmd)
        
        -- Настраиваем буфер терминала
        local bufnr = vim.api.nvim_get_current_buf()
        vim.api.nvim_buf_set_name(bufnr, PythonRunner.config.term_name_prefix .. filename)
        vim.wo.wrap = false
        vim.wo.number = false
        vim.wo.relativenumber = false

        -- Переключаемся в режим терминала
        vim.cmd('startinsert')

        -- Автоматическое закрытие при завершении
        if PythonRunner.config.close_on_exit then
            -- vim.cmd('autocmd TermClose <buffer> ++once bdelete')
            vim.api.nvim_create_autocmd('TermClose', {
                buffer = bufnr,
                callback = function()
                    vim.schedule(function()
                        vim.api.nvim_buf_delete(bufnr, { force = true })
                    end)
                end

            })
        end
    else
        vim.cmd('w')
        local command = ''
        if PythonRunner.config.close_on_exit then
            local command = 'silent !kitty --title=float sh -c "' .. python_cmd .. '"'
            vim.cmd(command)
        else
            local command = 'silent !kitty --hold --title=float sh -c "' .. python_cmd .. '"'
            vim.cmd(command)
        end
    end

    vim.notify("🚀 Запуск: " .. filename, vim.log.levels.INFO)
end


vim.api.nvim_create_user_command("PickPythonInterpreter", function() PythonRunner.pick_interpreter() end,
    { desc = "Выбрать режим запуска Python-интерпретатора" })
vim.api.nvim_create_user_command("RunPython", function() PythonRunner.run_python(false) end,
    { desc = "Запустить Python-файл" })
vim.api.nvim_create_user_command("RunPythonProject", function() PythonRunner.run_python(true) end,
    { desc = "Запустить Python-проект" })

return PythonRunner
