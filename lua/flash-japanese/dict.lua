-- Dictionary loader for flash-japanese
-- Loads hiragana to kanji mappings from dict.json at runtime

local M = {}

local hiragana_to_kanji = nil
local prefix_index = nil

local function load_dict()
  if hiragana_to_kanji then
    return
  end

  -- Get plugin directory path
  local source = debug.getinfo(1, "S").source:sub(2)
  local dir = vim.fn.fnamemodify(source, ":h")
  local json_path = dir .. "/dict.json"

  -- Load JSON file
  local file = io.open(json_path, "r")
  if not file then
    vim.notify("flash-japanese: dict.json not found", vim.log.levels.ERROR)
    hiragana_to_kanji = {}
    return
  end

  local content = file:read("*a")
  file:close()

  hiragana_to_kanji = vim.json.decode(content)
end

function M.get_kanji(hiragana)
  load_dict()
  return hiragana_to_kanji[hiragana]
end

-- Build prefix index
local function build_prefix_index()
  if prefix_index then
    return
  end
  load_dict()
  prefix_index = {}
  for hiragana, kanji_list in pairs(hiragana_to_kanji) do
    -- Register kanji for each prefix
    for i = 1, vim.fn.strchars(hiragana) do
      local prefix = vim.fn.strcharpart(hiragana, 0, i)
      if not prefix_index[prefix] then
        prefix_index[prefix] = {}
      end
      for _, kanji in ipairs(kanji_list) do
        prefix_index[prefix][kanji] = true
      end
    end
  end
end

-- Add all substrings of a CJK character run (length 1 to 8) into a set
local function add_substrings(chars, set)
  local max_len = math.min(#chars, 8)
  for start = 1, #chars do
    for len = 1, math.min(max_len, #chars - start + 1) do
      set[table.concat(chars, "", start, start + len - 1)] = true
    end
  end
end

-- Extract unique kanji substrings from visible buffer lines
-- Returns a set (table with kanji strings as keys)
function M.extract_kanji_from_buffer()
  local w0 = vim.fn.line("w0")
  local w_end = vim.fn.line("w$")
  local lines = vim.api.nvim_buf_get_lines(0, w0 - 1, w_end, false)

  local kanji_set = {}
  for _, line in ipairs(lines) do
    local run = {}
    -- Iterate UTF-8 characters
    for char in line:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
      local b = char:byte(1)
      -- CJK Unified Ideographs (U+4E00-U+9FFF): first byte 0xE4-0xE9, 3 bytes
      if b >= 0xE4 and b <= 0xE9 and #char == 3 then
        run[#run + 1] = char
      else
        if #run > 0 then
          add_substrings(run, kanji_set)
          run = {}
        end
      end
    end
    if #run > 0 then
      add_substrings(run, kanji_set)
    end
  end
  return kanji_set
end

-- Prefix search filtered to kanji visible in buffer
-- Accepts optional pre-computed buffer_kanji set to avoid redundant scans
function M.get_kanji_by_prefix_in_buffer(prefix, buffer_kanji)
  build_prefix_index()
  local prefix_set = prefix_index[prefix]
  if not prefix_set then
    return {}
  end

  buffer_kanji = buffer_kanji or M.extract_kanji_from_buffer()
  local list = {}
  for kanji in pairs(buffer_kanji) do
    if prefix_set[kanji] then
      list[#list + 1] = kanji
    end
  end
  return list
end

return M
