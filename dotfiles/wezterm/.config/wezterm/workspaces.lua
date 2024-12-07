-- Provides code to create and select wezterm workspaces
-- https://alexplescan.com/posts/2024/08/10/wezterm/

local wezterm = require 'wezterm'
local module = {}

local code_dir = wezterm.home_dir .. "/code"

local function workspace_dirs()
  -- Start with your home directory as a project, 'cause you might want
  -- to jump straight to it sometimes.
  local workspaces = {
    wezterm.home_dir,
    '~/sysconf',
  }

  -- WezTerm comes with a glob function! Let's use it to get a lua table
  -- containing all subdirectories of your code folder.
  for _, dir in ipairs(wezterm.glob(code_dir .. '/*')) do
    -- ... and add them to the workspaces table.
    table.insert(workspaces, dir)
  end

  return workspaces
end

function module.choose_workspace()
  local choices = {}
  for _, value in ipairs(workspace_dirs()) do
    table.insert(choices, { label = value })
  end

  return wezterm.action.InputSelector {
    title = "Workspaces",
    choices = choices,
    fuzzy = true,
    action = wezterm.action_callback(function(child_window, child_pane, id, label)
      -- "label" may be empty if nothing was selected. Don't bother doing anything
      -- when that happens.
      if not label then return end

      -- The SwitchToWorkspace action will switch us to a workspace if it already exists,
      -- otherwise it will create it for us.
      child_window:perform_action(wezterm.action.SwitchToWorkspace {
        -- We'll give our new workspace a nice name, like the last path segment
        -- of the directory we're opening up.
        name = label:match("([^/]+)$"),
        -- Here's the meat. We'll spawn a new terminal with the current working
        -- directory set to the directory that was picked.
        spawn = { cwd = label },
      }, child_pane)
    end),
  }
end

return module
