local M = {}
local dict = require("flash-japanese.dict")

-- Consonant to hiragana expansion map (for pending consonants)
local consonant_expansions = {
  k = { "か", "き", "く", "け", "こ", "きゃ", "きゅ", "きょ" },
  g = { "が", "ぎ", "ぐ", "げ", "ご", "ぎゃ", "ぎゅ", "ぎょ" },
  s = { "さ", "し", "す", "せ", "そ", "しゃ", "しゅ", "しょ" },
  z = { "ざ", "じ", "ず", "ぜ", "ぞ", "じゃ", "じゅ", "じょ" },
  t = { "た", "ち", "つ", "て", "と", "ちゃ", "ちゅ", "ちょ" },
  d = { "だ", "ぢ", "づ", "で", "ど" },
  n = { "な", "に", "ぬ", "ね", "の", "にゃ", "にゅ", "にょ", "ん" },
  h = { "は", "ひ", "ふ", "へ", "ほ", "ひゃ", "ひゅ", "ひょ" },
  b = { "ば", "び", "ぶ", "べ", "ぼ", "びゃ", "びゅ", "びょ" },
  p = { "ぱ", "ぴ", "ぷ", "ぺ", "ぽ", "ぴゃ", "ぴゅ", "ぴょ" },
  m = { "ま", "み", "む", "め", "も", "みゃ", "みゅ", "みょ" },
  y = { "や", "ゆ", "よ" },
  r = { "ら", "り", "る", "れ", "ろ", "りゃ", "りゅ", "りょ" },
  w = { "わ", "を" },
  f = { "ふぁ", "ふぃ", "ふ", "ふぇ", "ふぉ" },
  j = { "じゃ", "じ", "じゅ", "じぇ", "じょ" },
  c = { "ちゃ", "ち", "ちゅ", "ちぇ", "ちょ" },
  l = { "ら", "り", "る", "れ", "ろ" },
  v = { "ゔぁ", "ゔぃ", "ゔ", "ゔぇ", "ゔぉ" },
  x = { "ぁ", "ぃ", "ぅ", "ぇ", "ぉ" },
}

-- Romaji to hiragana conversion table
local romaji_to_hiragana = {
  -- Vowels
  a = "あ",
  i = "い",
  u = "う",
  e = "え",
  o = "お",
  -- Ka row
  ka = "か",
  ki = "き",
  ku = "く",
  ke = "け",
  ko = "こ",
  ca = "か",
  cu = "く",
  co = "こ",
  -- Ga row
  ga = "が",
  gi = "ぎ",
  gu = "ぐ",
  ge = "げ",
  go = "ご",
  -- Sa row
  sa = "さ",
  si = "し",
  su = "す",
  se = "せ",
  so = "そ",
  shi = "し",
  -- Za row
  za = "ざ",
  zi = "じ",
  zu = "ず",
  ze = "ぜ",
  zo = "ぞ",
  ji = "じ",
  -- Ta row
  ta = "た",
  ti = "ち",
  tu = "つ",
  te = "て",
  to = "と",
  chi = "ち",
  tsu = "つ",
  -- Da row
  da = "だ",
  di = "ぢ",
  du = "づ",
  de = "で",
  ["do"] = "ど",
  -- Na row
  na = "な",
  ni = "に",
  nu = "ぬ",
  ne = "ね",
  no = "の",
  -- Ha row
  ha = "は",
  hi = "ひ",
  hu = "ふ",
  he = "へ",
  ho = "ほ",
  fu = "ふ",
  -- Ba row
  ba = "ば",
  bi = "び",
  bu = "ぶ",
  be = "べ",
  bo = "ぼ",
  -- Pa row
  pa = "ぱ",
  pi = "ぴ",
  pu = "ぷ",
  pe = "ぺ",
  po = "ぽ",
  -- Ma row
  ma = "ま",
  mi = "み",
  mu = "む",
  me = "め",
  mo = "も",
  -- Ya row
  ya = "や",
  yi = "い",
  yu = "ゆ",
  ye = "いぇ",
  yo = "よ",
  -- Ra row
  ra = "ら",
  ri = "り",
  ru = "る",
  re = "れ",
  ro = "ろ",
  la = "ら",
  li = "り",
  lu = "る",
  le = "れ",
  lo = "ろ",
  -- Wa row
  wa = "わ",
  wi = "うぃ",
  we = "うぇ",
  wo = "を",
  -- N
  n = "ん",
  nn = "ん",
  -- Contracted sounds (kya row, etc.)
  kya = "きゃ",
  kyi = "きぃ",
  kyu = "きゅ",
  kye = "きぇ",
  kyo = "きょ",
  gya = "ぎゃ",
  gyi = "ぎぃ",
  gyu = "ぎゅ",
  gye = "ぎぇ",
  gyo = "ぎょ",
  sha = "しゃ",
  shu = "しゅ",
  she = "しぇ",
  sho = "しょ",
  sya = "しゃ",
  syi = "しぃ",
  syu = "しゅ",
  sye = "しぇ",
  syo = "しょ",
  ja = "じゃ",
  ju = "じゅ",
  je = "じぇ",
  jo = "じょ",
  jya = "じゃ",
  jyi = "じぃ",
  jyu = "じゅ",
  jye = "じぇ",
  jyo = "じょ",
  zya = "じゃ",
  zyi = "じぃ",
  zyu = "じゅ",
  zye = "じぇ",
  zyo = "じょ",
  cha = "ちゃ",
  chu = "ちゅ",
  che = "ちぇ",
  cho = "ちょ",
  tya = "ちゃ",
  tyi = "ちぃ",
  tyu = "ちゅ",
  tye = "ちぇ",
  tyo = "ちょ",
  dya = "ぢゃ",
  dyi = "ぢぃ",
  dyu = "ぢゅ",
  dye = "ぢぇ",
  dyo = "ぢょ",
  nya = "にゃ",
  nyi = "にぃ",
  nyu = "にゅ",
  nye = "にぇ",
  nyo = "にょ",
  hya = "ひゃ",
  hyi = "ひぃ",
  hyu = "ひゅ",
  hye = "ひぇ",
  hyo = "ひょ",
  bya = "びゃ",
  byi = "びぃ",
  byu = "びゅ",
  bye = "びぇ",
  byo = "びょ",
  pya = "ぴゃ",
  pyi = "ぴぃ",
  pyu = "ぴゅ",
  pye = "ぴぇ",
  pyo = "ぴょ",
  mya = "みゃ",
  myi = "みぃ",
  myu = "みゅ",
  mye = "みぇ",
  myo = "みょ",
  rya = "りゃ",
  ryi = "りぃ",
  ryu = "りゅ",
  rye = "りぇ",
  ryo = "りょ",
  lya = "りゃ",
  lyi = "りぃ",
  lyu = "りゅ",
  lye = "りぇ",
  lyo = "りょ",
  -- Fa row, etc.
  fa = "ふぁ",
  fi = "ふぃ",
  fe = "ふぇ",
  fo = "ふぉ",
  -- Ti, di, etc.
  tha = "てぁ",
  thi = "てぃ",
  thu = "てゅ",
  the = "てぇ",
  tho = "てょ",
  dha = "でぁ",
  dhi = "でぃ",
  dhu = "でゅ",
  dhe = "でぇ",
  dho = "でょ",
  -- Tsa row
  tsa = "つぁ",
  tsi = "つぃ",
  tse = "つぇ",
  tso = "つぉ",
  -- Vu
  va = "ゔぁ",
  vi = "ゔぃ",
  vu = "ゔ",
  ve = "ゔぇ",
  vo = "ゔぉ",
  -- Small letters
  xa = "ぁ",
  xi = "ぃ",
  xu = "ぅ",
  xe = "ぇ",
  xo = "ぉ",
  xya = "ゃ",
  xyu = "ゅ",
  xyo = "ょ",
  xtu = "っ",
  xtsu = "っ",
  xwa = "ゎ",
  lka = "ヵ",
  lke = "ヶ",
  -- Long vowel mark
  ["-"] = "ー",
}

-- Sorted key list to prioritize longer patterns
local sorted_keys = {}

local function init_sorted_keys()
  if #sorted_keys > 0 then
    return
  end
  for k in pairs(romaji_to_hiragana) do
    table.insert(sorted_keys, k)
  end
  table.sort(sorted_keys, function(a, b)
    return #a > #b
  end)
end

-- Hiragana to katakana conversion
local function to_katakana(hiragana)
  local result = {}
  -- Process UTF-8 characters one by one (pure Lua patterns)
  for char in hiragana:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
    local code = vim.fn.char2nr(char)
    if code >= 0x3041 and code <= 0x3096 then
      table.insert(result, vim.fn.nr2char(code + 96))
    else
      table.insert(result, char)
    end
  end
  return table.concat(result)
end

-- Convert romaji string to hiragana
-- Returns: hiragana, pending_consonant
--   hiragana: converted hiragana string
--   pending_consonant: trailing unconverted consonant (nil if none)
function M.romaji_to_hiragana(input)
  init_sorted_keys()

  local result = {}
  local pos = 1
  local input_lower = input:lower()

  while pos <= #input_lower do
    local matched = false

    -- Double consonant: same consonants in sequence (kka → っか)
    if pos < #input_lower then
      local c1 = input_lower:sub(pos, pos)
      local c2 = input_lower:sub(pos + 1, pos + 1)
      if c1 == c2 and c1:match("[^aiueon]") then
        table.insert(result, "っ")
        pos = pos + 1
        matched = true
      end
    end

    if not matched then
      -- Special handling for n: becomes ん if next is not vowel or y
      if input_lower:sub(pos, pos) == "n" and pos < #input_lower then
        local next_char = input_lower:sub(pos + 1, pos + 1)
        if not next_char:match("[aiueony]") then
          table.insert(result, "ん")
          pos = pos + 1
          matched = true
        end
      end
    end

    if not matched then
      for _, key in ipairs(sorted_keys) do
        if input_lower:sub(pos, pos + #key - 1) == key then
          table.insert(result, romaji_to_hiragana[key])
          pos = pos + #key
          matched = true
          break
        end
      end
    end

    if not matched then
      -- Check if remaining chars are a prefix of a valid romaji key (pending input)
      local remaining = input_lower:sub(pos)
      local is_pending = false
      for _, key in ipairs(sorted_keys) do
        if #key > #remaining and key:sub(1, #remaining) == remaining then
          is_pending = true
          break
        end
      end
      if is_pending then
        return table.concat(result), remaining
      end
      -- Add as-is if no match (alphanumeric, etc.)
      table.insert(result, input_lower:sub(pos, pos))
      pos = pos + 1
    end
  end

  return table.concat(result), nil
end

-- Escape Vim regex special characters
local function escape_pattern(str)
  return (str:gsub("([\\^$.*%[%]~])", "\\%1"))
end

-- Find okurigana (trailing kana) boundary
-- Returns: stem (hiragana), okurigana, kanji_list
local function find_okurigana_split(hiragana)
  local len = vim.fn.strchars(hiragana)
  -- Try removing 1-4 characters from the end
  for i = 1, math.min(4, len - 1) do
    local stem = vim.fn.strcharpart(hiragana, 0, len - i)
    local kanji_list = dict.get_kanji(stem)
    if kanji_list and #kanji_list > 0 then
      local okurigana = vim.fn.strcharpart(hiragana, len - i, i)
      return stem, okurigana, kanji_list
    end
  end
  return nil, nil, nil
end

-- Convert romaji to Vim regex pattern
-- Matches hiragana, katakana, and kanji visible in the current buffer
function M.to_pattern(romaji, include_raw_input)
  local hiragana, pending = M.romaji_to_hiragana(romaji)
  if hiragana == "" and not pending then
    return romaji
  end
  if hiragana == romaji:lower() and not pending then
    return romaji
  end

  local buffer_kanji = dict.extract_kanji_from_buffer()
  local function get_kanji(h)
    return dict.get_kanji_by_prefix_in_buffer(h, buffer_kanji)
  end

  local candidates = {}

  if pending then
    if hiragana ~= "" then
      -- Match confirmed portion (so user can continue typing)
      local katakana = to_katakana(hiragana)
      candidates[#candidates + 1] = escape_pattern(hiragana)
      candidates[#candidates + 1] = escape_pattern(katakana)
      for _, kanji in ipairs(get_kanji(hiragana)) do
        candidates[#candidates + 1] = escape_pattern(kanji)
      end
    else
      -- Consonant only: expand to possible kana + matching kanji in buffer
      local expansions = consonant_expansions[pending]
      if not expansions then
        -- Multi-char pending (e.g., "sh", "ch", "ky"): dynamically compute expansions
        expansions = {}
        local seen = {}
        for _, key in ipairs(sorted_keys) do
          if #key > #pending and key:sub(1, #pending) == pending then
            local kana = romaji_to_hiragana[key]
            if not seen[kana] then
              seen[kana] = true
              expansions[#expansions + 1] = kana
            end
          end
        end
      end
      for _, suffix in ipairs(expansions) do
        candidates[#candidates + 1] = escape_pattern(suffix)
        for _, kanji in ipairs(get_kanji(suffix)) do
          candidates[#candidates + 1] = escape_pattern(kanji)
        end
      end
    end
  else
    local katakana = to_katakana(hiragana)
    local kanji_list = get_kanji(hiragana)

    -- Prefix match for kana (maintains matches while user continues typing)
    -- Uses actual Unicode characters for range since Vim regex doesn't support \x escapes
    candidates[#candidates + 1] = escape_pattern(hiragana) .. "[ぁ-ゟ]*"
    candidates[#candidates + 1] = escape_pattern(katakana) .. "[ァ-ヿ]*"

    for _, kanji in ipairs(kanji_list) do
      candidates[#candidates + 1] = escape_pattern(kanji)
    end

    -- Okurigana split search: try "kangaeru" -> "kangae" + "ru" -> "考え" + "る"
    if #kanji_list == 0 then
      local stem, okurigana, stem_kanji = find_okurigana_split(hiragana)
      if stem then
        for _, kanji in ipairs(stem_kanji) do
          candidates[#candidates + 1] = escape_pattern(kanji .. okurigana)
        end
      end
    end
  end

  -- Also match the raw input as literal text (for English/ASCII matching)
  if include_raw_input then
    candidates[#candidates + 1] = escape_pattern(romaji)
  end

  if #candidates == 0 then
    return romaji
  end

  return "\\(" .. table.concat(candidates, "\\|") .. "\\)"
end

return M
