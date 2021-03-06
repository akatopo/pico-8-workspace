ch_width = 4
ch_height = 6

-- https://pico-8.fandom.com/wiki/Palette
colors = {
  black = 0, -- #000000 	0, 0, 0
  ["dark-blue"] = 1, -- #1D2B53 	29, 43, 83
  ["dark-purple"] = 2, -- #7E2553 	126, 37, 83
  ["dark-green"] = 3, -- #008751 	0, 135, 81
  brown = 4, -- #AB5236 	171, 82, 54
  ["dark-grey"] = 5, -- #5F574F 	95, 87, 79
  ["light-grey"] = 6, -- #C2C3C7 	194, 195, 199
  white = 7, -- #FFF1E8 	255, 241, 232
  red = 8, -- #FF004D 	255, 0, 77
  orange = 9, -- #FFA300 	255, 163, 0
  yellow = 10, -- #FFEC27 	255, 236, 39
  green = 11, -- #00E436 	0, 228, 54
  blue = 12, -- #29ADFF 	41, 173, 255
  lavender = 13, -- #83769C 	131, 118, 156
  pink = 14, -- #FF77A8 	255, 119, 168
  ["light-peach"] = 15, -- #FFCCAA 	255, 204, 170
}

text_box = {height = 42}

potato_sprites = {
  top_half = {
    {8, 0}, {8 + 1 * 16, 0}, {8 + 2 * 16, 0}, {8 + 3 * 16, 0}, {8 + 4 * 16, 0},
    {8 + 5 * 16, 0}, {8 + 6 * 16, 0}, {8, 16}, {8 + 1 * 16, 16},
  },
  bottom_half = {
    {8, 8}, {8 + 1 * 16, 8}, {8 + 2 * 16, 8}, {8 + 3 * 16, 8}, {8 + 4 * 16, 8},
    {8 + 5 * 16, 8}, {8 + 6 * 16, 8}, {8, 24}, {8 + 1 * 16, 24},
  },
  height = 16,
  width = 16,
}

potato_mouth_x = 48
potato_mouth_y = 40
potato_eyes_x = potato_mouth_x
potato_eyes_y = potato_mouth_y - potato_sprites.height

function map(table, f)
  local new_table = {}
  for k, v in pairs(table) do
    new_table[k] = f(v)
  end

  return new_table
end

function assign(table, ...)
  local others = {...}
  for i = 1, #others do
    for k, v in pairs(others[i]) do
      table[k] = v
    end
  end
  return table
end

function identity(x) return x end

-- https://www.lexaloffle.com/bbs/?pid=43636
function tostring(any)
  if type(any) == "function" then
    return "function"
  end
  if any == nil then
    return "nil"
  end
  if type(any) == "string" then
    return any
  end
  if type(any) == "boolean" then
    if any then
      return "true"
    end
    return "false"
  end
  if type(any) == "table" then
    local str = "{ "
    for k, v in pairs(any) do
      str = str .. tostring(k) .. " -> " .. tostring(v) .. " "
    end
    return str .. "}"
  end
  if type(any) == "number" then
    return "" .. any
  end
  return type(any) -- coroutines, anything else?
end
