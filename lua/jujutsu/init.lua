-- jujutsu.nvim: A Neovim plugin for jujutsu integration
-- Inspired by lazygit.nvim

local M = {}

-- Default config
local defaults = {
  -- Command to run. Good options:
  --   "jjui"
  --   "lazyjj"
  --   { "jj", "log" }
  cmd = "jjui",

  -- Use the jj root as the cwd
  use_vcs_root = true,

  floating = {
    width = 0.8, -- fraction of editor width
    height = 0.8, -- fraction of editor height
    border = "rounded",
    title = " Jujutsu ",
    title_pos = "center",
    -- Set to a highlight group for the border, e.g. "FloatBorder"
    winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
  },

  mappings = {
    toggle = "<leader>jj",
    close = "<C-q>",
  },
}

---@type { [string]: integer|nil }
local state = {
  buf = nil,
  win = nil,
}

local config = vim.deepcopy(defaults)

--- Compute floating window dimensions and position
---@return table
local function build_win_config()
  local cols = vim.o.columns
  local lines = vim.o.lines

  local width = math.max(20, math.floor(cols * config.floating.width))
  local height = math.max(5, math.floor(lines * config.floating.height))
  local row = math.floor((lines - height) / 2)
  local col = math.floor((cols - width) / 2)

  return {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = config.floating.border,
    title = config.floating.title,
    title_pos = config.floating.title_pos,
  }
end

--- Return jj vcs root if it exists
---@return string|nil
local function find_vcs_root()
  local jj_root = vim.fn.systemlist "jj root 2>/dev/null"
  if vim.v.shell_error == 0 and jj_root[1] and jj_root[1] ~= "" then
    return jj_root[1]
  end

  return nil
end

--- Destroy buffer and window state cleanly
local function cleanup()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, true)
  end
  if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
    vim.api.nvim_buf_delete(state.buf, { force = true })
  end
  state.win = nil
  state.buf = nil
end

--- Open the floating window
function M.open()
  -- If the window is already open, just focus it
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_set_current_win(state.win)
    vim.cmd "startinsert"
    return
  end

  -- Resolve cwd
  local cwd = nil
  if config.use_vcs_root then
    cwd = find_vcs_root()
  end
  cwd = cwd or vim.fn.getcwd()

  -- Create a scratch buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].filetype = "jujutsu-nvim"

  -- Open the floating window
  local win = vim.api.nvim_open_win(buf, true, build_win_config())

  -- Apply window highlight
  if config.floating.winhighlight then
    vim.wo[win].winhighlight = config.floating.winhighlight
  end

  state.buf = buf
  state.win = win

  -- cmd config
  local cmd = config.cmd
  if type(cmd) == "table" then
    cmd = table.concat(cmd, " ")
  end

  -- Open the neovim terminal
  vim.fn.termopen(cmd, {
    cwd = cwd,
    on_exit = function(_, exit_code, _)
      -- Small defer so the cmd has a chance to fully repaint
      vim.defer_fn(function()
        cleanup()
      end, 10)
    end,
  })

  -- Set up the in-terminal close mapping
  if config.mappings.close then
    vim.keymap.set("t", config.mappings.close, function()
      cleanup()
    end, { buffer = buf, desc = "Close jujutsu.nvim float" })
  end

  vim.cmd "startinsert"
end

--- Close the jujutsu.nvim floating terminal
function M.close()
  cleanup()
end

--- Toggle the jujutsu.nvim floating terminal
function M.toggle()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    M.close()
  else
    M.open()
  end
end

function M.setup(opts)
  config = vim.tbl_deep_extend("force", defaults, opts or {})

  -- Register the default normal mode toggle mapping
  if config.mappings.toggle then
    vim.keymap.set("n", config.mappings.toggle, M.toggle, {
      desc = "Toggle jujutsu.nvim",
      silent = true,
    })
  end
end

return M
