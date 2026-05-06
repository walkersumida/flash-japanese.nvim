local M = {}

M.defaults = {
  -- Default keymap
  keys = {
    jump = "sj", -- Japanese jump
  },
  -- Options passed to flash.nvim
  flash_opts = {},
  -- Debug mode (logs search patterns when true)
  debug = false,
  -- Include raw romaji input as literal match (matches English text too)
  include_raw_input = false,
  -- Cooldown period (ms) after jump to ignore accidental keystrokes (0 to disable)
  cooldown_ms = 1000,
}

function M.setup(opts)
  opts = vim.tbl_deep_extend("force", M.defaults, opts or {})
  M.opts = opts

  -- Setup keymap
  if opts.keys.jump then
    vim.keymap.set({ "n", "x", "o" }, opts.keys.jump, function()
      M.jump(opts.flash_opts)
    end, { desc = "Flash Japanese (Romaji)" })
  end
end

function M.jump(opts)
  local romaji = require("flash-japanese.romaji")
  local flash = require("flash")

  local cursor_before = vim.api.nvim_win_get_cursor(0)

  flash.jump(vim.tbl_deep_extend("force", opts or {}, {
    search = {
      mode = function(input)
        local pattern = romaji.to_pattern(input, M.opts and M.opts.include_raw_input)
        -- Debug log
        if M.opts and M.opts.debug then
          local preview = #pattern > 100 and pattern:sub(1, 100) .. "..." or pattern
          vim.notify("flash-japanese: input=" .. input .. " pattern=" .. preview, vim.log.levels.DEBUG)
        end
        return pattern
      end,
    },
    -- Use uppercase labels to avoid conflicts with romaji input
    labels = "ASDFGHJKLQWERTYUIOPZXCVBNM",
  }))

  -- Cooldown: only when flash exited without jumping (cursor didn't move)
  local cursor_after = vim.api.nvim_win_get_cursor(0)
  local jumped = cursor_before[1] ~= cursor_after[1] or cursor_before[2] ~= cursor_after[2]
  if not jumped then
    local cooldown_ms = M.opts and M.opts.cooldown_ms or 1000
    if cooldown_ms > 0 then
      vim.cmd("redraw")
      vim.cmd("sleep " .. cooldown_ms .. "m")
      while vim.fn.getchar(0) ~= 0 do end
    end
  end
end

return M
