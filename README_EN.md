[日本語](README.md) | **English**

# flash-japanese.nvim

Jump to Japanese text with romaji input using [flash.nvim](https://github.com/folke/flash.nvim).

https://github.com/user-attachments/assets/64ff36b6-504a-4a54-9506-f89ac2c2ee80

## Features

- Jump to hiragana, katakana, and kanji by typing romaji
- Powered by SKK dictionary (130,000+ entries)
- Seamless integration with flash.nvim

## Why flash-japanese?

- **No external dependencies** — Unlike Migemo-based plugins that require C binaries or Deno, flash-japanese works out of the box with just your plugin manager
- **Built on flash.nvim** — A thin wrapper around flash.nvim, keeping the codebase small and stable. All flash.nvim features (labels, multi-window, operator-pending mode) work as-is
- **Fast buffer-scoped matching** — Only matches kanji visible on screen, resulting in fewer regex candidates, faster search, and fewer keystrokes to jump

## Requirements

- Neovim 0.8+
- [flash.nvim](https://github.com/folke/flash.nvim)

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "walkersumida/flash-japanese.nvim",
  version = "*",
  dependencies = { "folke/flash.nvim" },
  opts = {},
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "walkersumida/flash-japanese.nvim",
  requires = { "folke/flash.nvim" },
  config = function()
    require("flash-japanese").setup()
  end,
}
```

> **Note:** Configuration examples below use lazy.nvim's `opts` syntax. For packer.nvim, pass the same options to `setup()`.

## Usage

1. Press `sj` (default keymap)
2. Type romaji (e.g., `ten`)
3. Labels appear on matching Japanese text (天, 点, 店, てん, テン, etc.)
4. Press the label key to jump

## Configuration

### Default Configuration

```lua
-- Using lazy.nvim
{
  "walkersumida/flash-japanese.nvim",
  version = "*",
  dependencies = { "folke/flash.nvim" },
  opts = {
    -- Key mappings
    keys = {
      jump = "sj",  -- Set to false to disable default keymap
    },

    -- Include raw romaji input as literal match (matches English text too)
    include_raw_input = false,

    -- Cooldown period (ms) after jump to ignore accidental keystrokes (0 to disable)
    cooldown_ms = 1000,

    -- Debug mode (logs search patterns)
    debug = false,

    -- Options passed to flash.nvim
    flash_opts = {},
  },
}
```

### Custom Keymap

```lua
-- Using lazy.nvim
{
  "walkersumida/flash-japanese.nvim",
  version = "*",
  dependencies = { "folke/flash.nvim" },
  opts = {
    keys = {
      jump = false,  -- Disable default keymap
    },
  },
}
```

Then set your own keymap:

```lua
vim.keymap.set({ "n", "x", "o" }, "<leader>j", function()
  require("flash-japanese").jump()
end, { desc = "Flash Japanese" })
```

## Romaji Conversion

The plugin supports standard romaji input:

| Romaji | Hiragana |
|--------|----------|
| a, i, u, e, o | あ, い, う, え, お |
| ka, ki, ku, ke, ko | か, き, く, け, こ |
| sha, shi, shu, she, sho | しゃ, し, しゅ, しぇ, しょ |
| kya, kyu, kyo | きゃ, きゅ, きょ |
| nn | ん |
| kk (doubled consonant) | っk |

## How It Works

1. Romaji input is converted to hiragana, then also to katakana — both are added as search candidates
2. Kanji visible in the current buffer are scanned, and SKK dictionary prefix lookup finds matching kanji to add as candidates
3. All candidates (hiragana, katakana, and kanji) are combined into a Vim regex pattern
4. flash.nvim highlights all matches

## Development

### Regenerating the dictionary

The plugin ships with a prebuilt `dict.json`. To regenerate it from the latest SKK dictionary:

```bash
# Download SKK-JISYO.L
curl -sL "https://raw.githubusercontent.com/skk-dev/dict/master/SKK-JISYO.L" -o /tmp/SKK-JISYO.L

# Regenerate dict.json (requires Go)
cd scripts
go run convert_skk_dict.go /tmp/SKK-JISYO.L ../lua/flash-japanese/dict.json
```

## License

GPL-2.0

## Credits

- [flash.nvim](https://github.com/folke/flash.nvim) by folke
- [SKK Dictionary](https://skk-dev.github.io/dict/) for kanji mappings
