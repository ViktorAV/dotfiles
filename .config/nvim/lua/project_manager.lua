local M = {}

local cfg = {
  root_dir = vim.fn.expand("~/yadisk/code"),
  project_entry_files = { "app.py", "main.py", "src/main.py" },
  venv_dirs = { ".venv", "venv" },
  create_venv = true,
  python_cmd = "python",

  runner = {
    interpreter = "python",
    interpreters = {
      "python",
      "python -i",
      "python -m pdb",
      "ipython --no-confirm-exit",
      "ipython --no-confirm-exit -i",
    },
    save_file = vim.fn.stdpath("data") .. "/python_runner.json",
    terminal_command = vim.env.SHELL or "/usr/bin/zsh",
    close_on_exit = true,
    open_in = "split",
    split_direction = "belowright",
    split_size = 10,
  },
}

local term = { bufnr = nil, winid = nil, project_path = nil }

local function join(...)
  return vim.fs.joinpath(...)
end


local function find_venv_root(start_path)
  local dir = vim.fn.fnamemodify(start_path, ":p")
  dir = dir:gsub("/$", "")

  while dir and dir ~= "/" and dir ~= "" do
    for _, name in ipairs(cfg.venv_dirs) do
      local candidate = join(dir, name)
      local stat = vim.loop.fs_stat(candidate)
      if stat and stat.type == "directory" then
        return dir  -- нашли папку, в которой лежит .venv
      end
    end

    -- Поднимаемся на уровень выше
    local parent = dir:match("^(.*)/[^/]+$")
    if not parent or parent == dir then
      break
    end
    dir = parent
  end
  return nil
end

local function get_venv_activate_command(project_path)
  for _, d in ipairs(cfg.venv_dirs) do
    local candidate = join(project_path, d)
    if vim.loop.fs_stat(candidate) then
      local sysname = vim.loop.os_uname().sysname
      if sysname == "Windows" then
        -- Для Windows можно вернуть путь к activate.bat, но проще сразу python.exe
        return nil  -- ниже обработаем отдельно
      else
        local activate_script = join(candidate, "bin", "activate")
        if vim.loop.fs_stat(activate_script) then
          -- Команда для shell: source .../bin/activate
          return "source " .. vim.fn.shellescape(activate_script)
        end
      end
    end
  end
  return nil
end

local function get_venv_python_path(project_path)
  for _, d in ipairs(cfg.venv_dirs) do
    local candidate = join(project_path, d)
    if vim.loop.fs_stat(candidate) then
      local sysname = vim.loop.os_uname().sysname
      if sysname == "Windows" then
        local p = join(candidate, "Scripts", "python.exe")
        if vim.loop.fs_stat(p) then return p end
      else
        local p = join(candidate, "bin", "python")
        if vim.loop.fs_stat(p) then return p end
      end
    end
  end
  return nil
end

local function list_dirs(path)
  local dirs = {}
  if not path or path == "" then return dirs end
  local stat = vim.loop.fs_stat(path)
  if not stat or stat.type ~= "directory" then return dirs end

  local cmd = string.format('find "%s" -maxdepth 1 -mindepth 1 -type d ! -name ".*" -printf "%%f\\n"', path)
  local handle = io.popen(cmd)
  if handle then
    for line in handle:lines() do
      if line and line ~= "" then
        table.insert(dirs, line)
      end
    end
    handle:close()
  end
  table.sort(dirs)
  return dirs
end

local function set_project_env(current_file_dir, category_name)
  local use_venv = (category_name == "python")
  if not use_venv then return end

  local venv_root = find_venv_root(current_file_dir)
  local project_path = venv_root or current_file_dir

  local venv_python = get_venv_python_path(project_path)

  if venv_python and vim.loop.fs_stat(venv_python) then
    pcall(function()
      vim.cmd("PyrightSetPythonExecutable " .. venv_python)
    end)
    vim.notify("✅ Окружение .venv найдено и настроено для Pyright: " .. venv_python, vim.log.levels.INFO)
  else
    vim.notify("⚠️ .venv не найден — будет использоваться системный python", vim.log.levels.WARN)
  end
end

local function open_entry_file(project_path)
  local function try_open_in_dir(dir)
    for _, name in ipairs(cfg.project_entry_files) do
      local path = join(dir, name)
      if vim.loop.fs_stat(path) then
        vim.cmd("edit " .. path)
        return true
      end
    end
    return false
  end

  if try_open_in_dir(project_path) then return end

  local src_path = join(project_path, "src")
  if vim.loop.fs_stat(src_path) and vim.loop.fs_stat(src_path).type == "directory" then
    if try_open_in_dir(src_path) then return end
  end

  pcall(function()
    require("fzf-lua").files({ cwd = project_path })
  end, function()
    pcall(function()
      vim.cmd("Files " .. project_path)
    end, function()
      vim.notify("Не удалось запустить fzf. Проверьте установку.", vim.log.levels.ERROR)
    end)
  end)
end

local function create_new_project(category_name)
  vim.ui.input({ prompt = "Имя проекта: " }, function(project_name)
    if not project_name or project_name == "" then return end
    local project_path = join(cfg.root_dir, category_name, project_name)

    os.execute(string.format('mkdir -p "%s"', project_path))

    if cfg.create_venv and category_name == "python" then
      local cmd = 'cd "' .. project_path .. '" && ' .. cfg.python_cmd .. ' -m venv .venv'
      os.execute(cmd)
    end

    set_project_env(project_path, category_name)
    vim.cmd("edit " .. join(project_path, 'src/main.py'))
  end)
end

function M.open_project_menu()
  local categories = list_dirs(cfg.root_dir)
  if #categories == 0 then
    vim.notify("Нет категорий в: " .. cfg.root_dir, vim.log.levels.WARN)
    return
  end

  -- Собираем список проектов: "category/project"
  local all_items = {}
  for _, cat in ipairs(categories) do
    local cat_path = join(cfg.root_dir, cat)
    local projects = list_dirs(cat_path)
    for _, proj in ipairs(projects) do
      table.insert(all_items, cat .. "/" .. proj)
    end
  end
  table.insert(all_items, "[Create new project]")

  vim.ui.input({ prompt = "Проект (введите часть имени): " }, function(query)
    if not query then return end

    local q = query:lower()
    local filtered = {}
    for _, item in ipairs(all_items) do
      if item:lower():find(q, 1, true) then
        table.insert(filtered, item)
      end
    end

    if #filtered == 0 then
      vim.notify("Ничего не найдено по запросу: " .. query, vim.log.levels.WARN)
      return
    end

    -- Если ровно один результат и это не «Create new project» — сразу открываем
    if #filtered == 1 and filtered[1] ~= "[Create new project]" then
      local choice = filtered[1]
      local category, name = choice:match("^([^/]+)/([^/]+)$")
      if not category or not name then
        vim.notify("Ошибка разбора имени проекта: " .. choice, vim.log.levels.ERROR)
        return
      end
      local project_path = join(cfg.root_dir, category, name)
      open_entry_file(project_path)

      vim.schedule(function()
        local buf_name = vim.api.nvim_buf_get_name(0)
        if not buf_name or buf_name == "" or buf_name:match("^term://") then
          return
        end
        local file_dir = vim.fn.fnamemodify(buf_name, ":p:h")
        set_project_env(file_dir, category)
      end)
      return
    end

    -- Показываем список для выбора
    vim.ui.select(filtered, { prompt = "Выберите проект: " }, function(choice)
      if not choice then return end

      if choice == "[Create new project]" then
        vim.ui.select(categories, { prompt = "Категория для нового проекта: " }, function(cat)
          if cat then create_new_project(cat) end
        end)
        return
      end

      local category, name = choice:match("^([^/]+)/([^/]+)$")
      if not category or not name then
        vim.notify("Ошибка разбора имени проекта: " .. choice, vim.log.levels.ERROR)
        return
      end

      local project_path = join(cfg.root_dir, category, name)
      open_entry_file(project_path)

      vim.schedule(function()
        local buf_name = vim.api.nvim_buf_get_name(0)
        if not buf_name or buf_name == "" or buf_name:match("^term://") then
          return
        end
        local file_dir = vim.fn.fnamemodify(buf_name, ":p:h")
        set_project_env(file_dir, category)
      end)
    end)
  end)
end

local runner = cfg.runner

function M.runner_set_config(options)
  options = options or {}
  for k, v in pairs(options) do runner[k] = v end
end

function M.runner_load_config()
  local file = io.open(runner.save_file, "r")
  if file then
    local content = file:read("*all")
    file:close()
    local data = vim.json.decode(content)
    if data then
      runner.interpreter = data.interpreter or runner.interpreter
      runner.open_in = data.open_in or runner.open_in
    end
  end
end

function M.runner_save_config()
  local data = { interpreter = runner.interpreter, open_in = runner.open_in }
  local json_data = vim.json.encode(data)
  local file, err = io.open(runner.save_file, "w")
  if file then
    file:write(json_data)
    file:close()
  else
    vim.notify("Ошибка сохранения: " .. (err or "unknown"), vim.log.levels.ERROR)
  end
end

function M.runner_configure()
  vim.ui.select(runner.interpreters, {
    prompt = "Выберите интерпретатор Python:",
    format_item = function(item)
      local marker = (item == runner.interpreter) and "✓ " or "  "
      return marker .. item
    end,
  }, function(choice)
    if choice then
      runner.interpreter = choice
      M.runner_save_config()
    end
  end)

  vim.ui.select({ "split", "external" }, {
    prompt = "Способ запуска:",
    format_item = function(item)
      local marker = (item == runner.open_in) and "✓ " or "  "
      return marker .. item
    end,
  }, function(choice)
    if choice then
      runner.open_in = choice
      M.runner_save_config()
    end
  end)
end

local function find_project_root(current_dir)
  local dir = current_dir
  while dir and dir ~= "/" do
    for _, marker in ipairs(cfg.project_entry_files) do
      local path = join(dir, marker)
      if vim.loop.fs_stat(path) then
        return dir
      end
    end
    local parent = dir:match("^(.*)/[^/]*$")
    if not parent or parent == dir then break end
    dir = parent
  end
  return current_dir
end

local function find_root_file(root_dir)
  for _, filename in ipairs(cfg.project_entry_files) do
    local full_path = join(root_dir, filename)
    if vim.loop.fs_stat(full_path) then
      return full_path
    end
  end
  return nil
end

function M.run_python(is_project)
  local current_file
  local start_dir = vim.fn.expand("%:p:h")  -- папка текущего файла (например, src)

  if is_project then
    -- Для проекта ищем главный файл, но стартовую директорию всё равно берём от текущего буфера
    local project_root = find_project_root(start_dir)
    current_file = find_root_file(project_root)
    if not current_file then
      vim.notify("Корневой файл не найден", vim.log.levels.INFO)
      return
    end
  else
    current_file = vim.fn.expand("%:p")
  end

  local filename = vim.fn.expand("%:t")
  vim.cmd("w")

  -- External mode (kitty)
  if runner.open_in == "external" then
    -- Ищем .venv, поднимаясь вверх от папки текущего файла
    local venv_root = find_venv_root(start_dir)
    local python_cmd = get_venv_python_path(venv_root or start_dir) or runner.interpreter

    local hold_flag = runner.close_on_exit and "" or "--hold "
    local command = string.format(
      'silent !kitty --title=float %s sh -c "%s"',
      hold_flag,
      string.format('cd %s && clear && %s %s',
        vim.fn.shellescape(start_dir),
        vim.fn.shellescape(python_cmd),
        vim.fn.shellescape(current_file)
      )
    )
    vim.cmd(command)
    return
  end

  -- Internal mode
  if not term.bufnr or not vim.api.nvim_buf_is_valid(term.bufnr) then
    M.toggle_project_terminal()
    if not term.bufnr or not vim.api.nvim_buf_is_valid(term.bufnr) then
      vim.notify("Не удалось подготовить терминал", vim.log.levels.ERROR)
      return
    end
  end

  if vim.api.nvim_buf_get_option(term.bufnr, "buftype") ~= "terminal" then
    vim.notify("Буфер не является терминальным", vim.log.levels.ERROR)
    return
  end

  if not term.winid or not vim.api.nvim_win_is_valid(term.winid) then
    vim.cmd(runner.split_direction .. " split " .. runner.split_size)
    local new_win = vim.api.nvim_get_current_win()
    term.winid = new_win
    vim.api.nvim_win_set_buf(new_win, term.bufnr)
  end

  vim.api.nvim_set_current_win(term.winid)

  -- ВАЖНО: ищем .venv, начиная от папки текущего файла и поднимаясь вверх
  local venv_root = find_venv_root(start_dir)
  local python_cmd = get_venv_python_path(venv_root or start_dir) or runner.interpreter

  local full_cmd = string.format(
    'cd %s && clear && %s %s',
    vim.fn.shellescape(start_dir),
    vim.fn.shellescape(python_cmd),
    vim.fn.shellescape(current_file)
  )

  vim.fn.feedkeys(full_cmd .. "\r", "n")
  vim.cmd("startinsert")

  vim.notify("🚀 Запуск: " .. filename, vim.log.levels.INFO)
end

local function enter_insert_mode_in_term(bufnr)
  vim.schedule(function()
    if vim.api.nvim_buf_is_valid(bufnr) and
       vim.api.nvim_buf_get_option(bufnr, "buftype") == "terminal" then
      local winid = vim.fn.bufwinid(bufnr)
      if winid ~= -1 then
        vim.api.nvim_set_current_win(winid)
        vim.cmd("startinsert")
      end
    end
  end)
end

function M.toggle_project_terminal()
  if term.bufnr and vim.api.nvim_buf_is_valid(term.bufnr) then
    local windows = vim.fn.win_findbuf(term.bufnr)
    if #windows > 0 then
      for _, win in ipairs(windows) do
        vim.api.nvim_win_close(win, true)
      end
      term.winid = nil
      return
    end

    vim.cmd(runner.split_direction .. " split " .. runner.split_size)
    local new_win = vim.api.nvim_get_current_win()
    term.winid = new_win
    vim.api.nvim_win_set_buf(new_win, term.bufnr)
    enter_insert_mode_in_term(term.bufnr)
    return
  end

  -- Находим стартовую папку (где лежит текущий файл)
  local start_dir = vim.fn.expand("%:p:h")

  term.project_path = start_dir

  term.bufnr = vim.api.nvim_create_buf(false, true)
  if not term.bufnr then
    vim.notify("Не удалось создать буфер", vim.log.levels.ERROR)
    return
  end
  vim.api.nvim_buf_set_name(term.bufnr, "[Project Terminal]")

  vim.cmd(runner.split_direction .. " split " .. runner.split_size)
  local new_win = vim.api.nvim_get_current_win()
  term.winid = new_win
  vim.api.nvim_win_set_buf(new_win, term.bufnr)

  -- Ищем .venv вверх от start_dir
  local venv_root = find_venv_root(start_dir)
  local use_dir = venv_root or start_dir  -- если .venv не найден, остаёмся в start_dir

  local venv_activate = get_venv_activate_command(use_dir)
  local shell = runner.terminal_command or vim.env.SHELL or "/usr/bin/zsh"

  local term_cmd
  if venv_activate then
    term_cmd = string.format('cd %s && %s && exec %s',
      vim.fn.shellescape(use_dir),
      venv_activate,
      shell
    )
  else
    term_cmd = 'cd ' .. vim.fn.shellescape(use_dir) .. ' && exec ' .. shell
  end

  vim.fn.termopen(term_cmd, {
    bufnr = term.bufnr,
    cwd = use_dir,
  })

  enter_insert_mode_in_term(term.bufnr)

  vim.api.nvim_create_autocmd("TermClose", {
    buffer = term.bufnr,
    once = true,
    callback = function()
      if runner.close_on_exit then
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(term.bufnr) then
            vim.api.nvim_buf_delete(term.bufnr, { force = true })
            term.bufnr = nil
            term.winid = nil
            term.project_path = nil
          end
        end)
      else
        term.winid = nil
      end
    end,
  })
end

function M.select_venv()
  local current_dir = vim.fn.getcwd()
  local venv_candidates = { ".venv", "venv" }
  local found_venvs = {}

  local dir = current_dir
  while dir and dir ~= "/" do
    for _, name in ipairs(venv_candidates) do
      local path = join(dir, name)
      if vim.loop.fs_stat(path) then
        local sysname = vim.loop.os_uname().sysname
        local python_path = sysname == "Windows"
          and join(path, "Scripts", "python.exe")
          or join(path, "bin", "python")

        if vim.loop.fs_stat(python_path) then
          table.insert(found_venvs, { dir = dir, python = python_path })
        end
      end
    end

    local parent = dir:match("^(.*)/[^/]*$")
    if not parent or parent == dir then break end
    dir = parent
  end

  if #found_venvs == 0 then
    vim.notify("❌ .venv не найден ни в текущей папке, ни выше", vim.log.levels.ERROR)
    return
  end

  local items = {}
  for _, v in ipairs(found_venvs) do
    table.insert(items, v.dir .. " → " .. v.python)
  end

  vim.ui.select(items, { prompt = "Выберите .venv: " }, function(selected)
    if not selected then return end
    local dir, python = selected:match("(.-) → (.-)$")
    if dir and python then
      vim.fn.chdir(dir)
      pcall(function()
        vim.cmd("PyrightSetPythonExecutable " .. python)
      end)
      vim.notify("✅ Окружение активировано: " .. python, vim.log.levels.INFO)
    end
  end)
end

M.runner_load_config()

-- vim.api.nvim_create_autocmd("BufReadPost", {
--   callback = function()
--     local buf_name = vim.api.nvim_buf_get_name(0)
--     if not buf_name or buf_name == "" then return end
--
--     local fname = vim.fn.fnamemodify(buf_name, ":t")
--
--     local is_entry = false
--     for _, entry_name in ipairs(cfg.project_entry_files) do
--       local pure_name = entry_name:match("[^/]+$")
--       if pure_name and fname == pure_name then
--         is_entry = true
--         break
--       end
--     end
--
--     if not is_entry then return end
--
--     if buf_name:find("[/][.]git[/]") or buf_name:find("[/][.]venv[/]") then
--       return
--     end
--
--     local dir = vim.fn.fnamemodify(buf_name, ":p:h")
--     if dir and dir ~= "" then
--       local current = vim.fn.getcwd()
--       if current ~= dir then
--         vim.fn.chdir(dir)
--       end
--     end
--   end,
-- })

vim.api.nvim_create_user_command("OpenProjectMenu",
  function() M.open_project_menu() end,
  { desc = "Открыть меню выбора проекта" })

vim.keymap.set("n", "<leader>po", "<cmd>OpenProjectMenu<cr>", { desc = "Open project menu", buffer = false })
vim.keymap.set("n", "<leader>fp", "<cmd>OpenProjectMenu<cr>", { desc = "Open project menu", buffer = false })

vim.api.nvim_create_user_command("PythonRunnerConfigure",
  function() M.runner_configure() end,
  { desc = "Выбрать команду запуска проекта" })

vim.api.nvim_create_user_command("RunPythonScript",
  function() M.run_python(false) end,
  { desc = "Запустить текущий файл через Python" })

vim.api.nvim_create_user_command("RunPythonProject",
  function() M.run_python(true) end,
  { desc = "Запустить главный файл проекта" })

-- vim.keymap.set("n", "<leader>r", "<cmd>RunProject<cr>", { desc = "Run project main", buffer = false })
-- vim.keymap.set("n", "<leader>R", "<cmd>RunScript<cr>", { desc = "Run current file", buffer = false })

vim.api.nvim_create_user_command("ToggleProjectTerminal",
  function() M.toggle_project_terminal() end,
  { desc = "Переключить (показать/скрыть) терминал проекта" })

-- vim.keymap.set("n", "<leader>t", "<cmd>ToggleProjectTerminal<cr>", { desc = "Toggle project terminal", buffer = false })

vim.api.nvim_create_user_command("SelectVenv",
  function() M.select_venv() end,
  { desc = "Выбрать .venv вручную (поиск вверх по дереву)" })

vim.keymap.set("n", "<leader>pv", "<cmd>SelectVenv<cr>", { desc = "Select .venv", buffer = false })
vim.keymap.set("n", "<leader>fv", "<cmd>SelectVenv<cr>", { desc = "Select .venv", buffer = false })

return M
