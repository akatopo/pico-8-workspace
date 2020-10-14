ch_width = 4
ch_height = 6

potato_sprites = {
  top_half = {
    {8, 0}, {8 + 1 * 16, 0}, {8 + 2 * 16, 0}, {8 + 3 * 16, 0}, {8 + 4 * 16, 0},
    {8 + 5 * 16, 0},
  },
  bottom_half = {
    {8, 8}, {8 + 1 * 16, 8}, {8 + 2 * 16, 8}, {8 + 3 * 16, 8}, {8 + 4 * 16, 8},
    {8 + 5 * 16, 8},
  },
  height = 16,
  width = 16,
}

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
