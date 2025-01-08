local wezterm = require 'wezterm'
local workspaces = require 'workspaces'
local act = wezterm.action
local mux = wezterm.mux

-- this will hold the configuration.
local config = wezterm.config_builder()

-- appearance
config.color_scheme = 'catppuccin-latte'
config.font_size = 14.0

-- make CTRL-A the LEADER key combo (puts in command mode)
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }

-- key bindings
config.keys = {
  -- Send "CTRL-A" to the terminal when pressing CTRL - A, CTRL - A
  {
    key = 'a',
    mods = 'LEADER|CTRL',
    action = wezterm.action.SendKey { key = 'a', mods = 'CTRL' },
  },
  {
    key = '|',
    mods = 'LEADER|SHIFT',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    key = '-',
    mods = 'LEADER',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  -- Choose a workspace based on a list of directories --
  {
    key = 'p',
    mods = 'LEADER',
    action = workspaces.choose_workspace(),
  },
  {
    key = 'f',
    mods = 'LEADER',
    -- Present a list of existing workspaces
    action = wezterm.action.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' },
  },
  {
    key = 't',
    mods = 'LEADER',
    action = act.PromptInputLine {
      description = 'Enter new name for tab',
      -- initial_value = 'My Tab Name',
      action = wezterm.action_callback(function(window, pane, line)
        -- line will be `nil` if they hit escape without entering anything
        -- An empty string if they just hit enter
        -- Or the actual line of text they wrote
        if line then
          window:active_tab():set_title(line)
        end
      end),
    },
  },
  -- close tab
  {
    key = 'w',
    mods = 'LEADER',
    action = wezterm.action.CloseCurrentTab { confirm = true },
  },
}

-- ssh stuff, still messing around
config.ssh_domains = {
  {
    -- This name identifies the domain
    name = 'illmatic',
    remote_address = 'illmatic.home.eltimn.com',
    ssh_option = {
      identityfile = '~/.ssh/id_ed25519.pub'
    }
  }
}

-- display the current workspace in the upper right corner of tab bar
wezterm.on('update-right-status', function(window, pane)
  window:set_right_status(window:active_workspace() .. ' ')
end)

-- wezterm won't exit without killing all workspaces
-- creating them on the fly doesn't allow for creating multiple tabs, it's
-- a simple SpawnCommand. See wezterm.action.SwitchToWorkspace -TN
-- wezterm.on('gui-startup', function(cmd)
--   -- allow `wezterm start -- something` to affect what we spawn
--   -- in our initial window
--   local args = {}
--   if cmd then
--     args = cmd.args
--   end

--   -- Set a workspace for coding on a current project
--   -- Top pane is for the editor, bottom pane is for the build tool
--   -- local project_dir = wezterm.home_dir .. '/sysconf'
--   -- local tab, build_pane, window = mux.spawn_window {
--   --   workspace = 'sysconf',
--   --   cwd = project_dir,
--   --   args = args,
--   -- }
--   -- local editor_pane = build_pane:split {
--   --   direction = 'Top',
--   --   size = 0.6,
--   --   cwd = project_dir,
--   -- }
--   -- -- may as well kick off a build in that pane
--   -- build_pane:send_text 'hello\n'

--   -- A workspace for interacting with a local machine that
--   -- runs some docker containers for home automation
--   local tab, pane, window = mux.spawn_window {
--     workspace = 'automation',
--     args = args, -- { 'ssh', 'vault' },
--   }

--   -- sysconf workspace
--   local sysconf_dir = wezterm.home_dir .. '/sysconf'
--   local main_tab, pane, sysconf_window = mux.spawn_window {
--     workspace = 'sysconf',
--     cwd = sysconf_dir,
--     args = args,
--   }

--   sysconf_window:set_title 'sysconf'
--   main_tab:set_title 'Root'

--   local machine_tab, pane = sysconf_window:spawn_tab {
--     cwd = sysconf_dir .. '/nix/machines/ruca',
--     args = args,
--   }

--   machine_tab:set_title 'Ruca'

--   main_tab:activate()

--   -- We want to startup in the sysconf workspace
--   -- mux.set_active_workspace 'sysconf'
-- end)


-- local function segments_for_right_status(window)
--   return {
--     window:active_workspace(),
--     wezterm.strftime('%a %b %-d %H:%M'),
--     wezterm.hostname(),
--   }
-- end

-- wezterm.on('update-status', function(window, _)
--   local SOLID_LEFT_ARROW = utf8.char(0xe0b2)
--   local segments = segments_for_right_status(window)

--   local color_scheme = window:effective_config().resolved_palette
--   -- Note the use of wezterm.color.parse here, this returns
--   -- a Color object, which comes with functionality for lightening
--   -- or darkening the colour (amongst other things).
--   local bg = wezterm.color.parse(color_scheme.background)
--   local fg = color_scheme.foreground

--   -- Each powerline segment is going to be coloured progressively
--   -- darker/lighter depending on whether we're on a dark/light colour
--   -- scheme. Let's establish the "from" and "to" bounds of our gradient.
--   local gradient_to, gradient_from = bg
--   if appearance.is_dark() then
--     gradient_from = gradient_to:lighten(0.2)
--   else
--     gradient_from = gradient_to:darken(0.2)
--   end

--   -- Yes, WezTerm supports creating gradients, because why not?! Although
--   -- they'd usually be used for setting high fidelity gradients on your terminal's
--   -- background, we'll use them here to give us a sample of the powerline segment
--   -- colours we need.
--   local gradient = wezterm.color.gradient(
--     {
--       orientation = 'Horizontal',
--       colors = { gradient_from, gradient_to },
--     },
--     #segments -- only gives us as many colours as we have segments.
--   )

--   -- We'll build up the elements to send to wezterm.format in this table.
--   local elements = {}

--   for i, seg in ipairs(segments) do
--     local is_first = i == 1

--     if is_first then
--       table.insert(elements, { Background = { Color = 'none' } })
--     end
--     table.insert(elements, { Foreground = { Color = gradient[i] } })
--     table.insert(elements, { Text = SOLID_LEFT_ARROW })

--     table.insert(elements, { Foreground = { Color = fg } })
--     table.insert(elements, { Background = { Color = gradient[i] } })
--     table.insert(elements, { Text = ' ' .. seg .. ' ' })
--   end

--   window:set_right_status(wezterm.format(elements))
-- end)

-- code to display hostname in the upper right corner of tab bar
-- wezterm.on('update-status', function(window)
--   -- Grab the utf8 character for the "powerline" left facing
--   -- solid arrow.
--   local SOLID_LEFT_ARROW = utf8.char(0xe0b2)

--   -- Grab the current window's configuration, and from it the
--   -- palette (this is the combination of your chosen colour scheme
--   -- including any overrides).
--   local color_scheme = window:effective_config().resolved_palette
--   local bg = color_scheme.background
--   local fg = color_scheme.foreground

--   window:set_right_status(wezterm.format({
--     -- First, we draw the arrow...
--     { Background = { Color = 'none' } },
--     { Foreground = { Color = bg } },
--     { Text = SOLID_LEFT_ARROW },
--     -- Then we draw our text
--     { Background = { Color = bg } },
--     { Foreground = { Color = fg } },
--     { Text = ' ' .. wezterm.hostname() .. ' ' },
--   }))
-- end)

-- and finally, return the configuration to wezterm
return config
