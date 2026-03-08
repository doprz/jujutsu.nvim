# jujutsu.nvim

A Neovim plugin for jujutsu integration. Inspired by lazygit.nvim

![jujutsu.nvim example](./jujutsu-nvim.png) 

## Installation

lazy.nvim

```lua
{
  'doprz/jujutsu.nvim',
  config = function()
    require('jujutsu').setup {
      cmd = 'jjui',
      mappings = {
        toggle = '<leader>jj',
        close = '<C-q>',
      },
    }
  end,
}
```

## Configuration

`setup()` can be called with no arguments. `jujutsu.nvim` comes with sensible defaults.

```lua
require('jujutsu.nvim').setup {
  -- Command to run. Good options:
  --   "jjui"
  --   "lazyjj"
  --   { "jj", "log" }
  cmd = "jjui",

  -- Use the jj root as the cwd
  use_vcs_root = true,

  -- Auto-close the float when the process exits.
  -- Set to false for non-interactive commands like { "jj", "log" }
  -- so the buffer stays open until you press the close mapping.
  auto_close = true,

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
```

## API

```lua
local jj = require('jujutsu.nvim')

jj.open()    -- open the float
jj.close()   -- close the float
jj.toggle()  -- toggle the float
```

## Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines and more info.

## License

SPDX-License-Identifier: MIT

Licensed under the MIT License. See [LICENSE](LICENSE) for full details.
