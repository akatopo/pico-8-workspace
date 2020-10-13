local actions
local state_from_btn
local components
local ch_width = 4
local ch_height = 6

function _init()
  components = map(
    {{mouth, "sc1_mouth"}, {eyes, "sc1_eyes"}, {text, "sc1_text"}},
      (function(v) return component_wrapper(unpack(v)) end))
end

function _update()

  -- reset_hooks()
  reset_hooks()
end

function consume_actions(actions)
  for c in all(actions) do
    if (costatus(c) ~= "dead") then
      assert(coresume(c))
    end
  end
end

function _draw()
  cls()
  print(stat(7), 0, 0)
  print(stat(7), 128 - ch_width * #tostr(stat(7)), 128 - ch_height)
  -- spr(1, 10, 10)
  -- spr(2, 18, 10)
  -- spr(17, 10, 18)
  -- spr(18, 18, 18)

  -- sspr(12,2,20+1-12,14+1-2,40,40)
  -- quad_spr(1, 40, 40)

  -- for c in all(actions) do
  --   if (not coresume(c)) then
  --     del(actions,c)
  --   end
  -- end

  -- print("a", 10, 10)
  -- print("b", 14, 10)

  -- local scene = {mouth(), eyes()}

  -- applu props properly?
  local txt = [[
Convert val to a string.
When val is a number,
function or table,
use_hex can be used to
include the raw hexidecimal
value]]
  local scene = map(components, function(f) return f({txt = txt}) end)
  foreach(scene, consume_actions)
  -- for c2 in all(mouth_actions) do
  --   coresume(c2)
  -- end
  -- hooks_debug();
end

function quad_spr(sprite, x, y)
  local sprite_x_offset = 1
  local sprite_y_offset = 16
  local sprite_dim = 8
  local sprites = {
    {sprite, x, y}, {sprite + sprite_x_offset, x + sprite_dim, y},
    {sprite + sprite_y_offset, x, y + sprite_dim},
    {sprite + sprite_x_offset + sprite_y_offset, x + sprite_dim, y + sprite_dim},
  }
  foreach(sprites, function(s) spr(unpack(s)) end)
end

function double_spr(sprite, x, y)
  local sprite_x_offset = 1
  local sprite_y_offset = 16
  local sprite_dim = 8
  local sprites = {
    {sprite, x, y}, {sprite + sprite_x_offset, x + sprite_dim, y},
  }
  foreach(sprites, function(s) spr(unpack(s)) end)
end

function count_lines(s)
  local count = 1
  for i = 1, #s do
    if (sub(s, i, i) == "\n") then
      count = count + 1
    end
  end
  return count
end

function yield_print(t, s, x, y, blink)
  for frame = 1, t do
    print(s, x, y)
    if (blink) then
      local block = chr(16)
      local line_total = count_lines(s)
      local line_length = #(split(s, "\n")[line_total])
      local y_offset = (line_total - 1) * ch_height
      local x_offset = line_length * ch_width
      print(block, x + x_offset, y + y_offset)
    end
    yield()
  end
end

function yield_frames(t, i)
  for frame = 1, t do
    double_spr(i, 80, 80)
    yield()
  end
end

function yield_frames_eyes(t, i)
  for frame = 1, t do
    double_spr(i, 80, 72)
    yield()
  end
end

function text(props)
  local txt = props.txt
  function c_text_print(s)
    return cocreate(
      function()
        local i = 1
        local frame_printing = 1
        local frames_per_ch = 3
        while (i ~= #s + 1) do
          yield_print(
            frames_per_ch, sub(s, 1, i), 10, 30, frame_printing % 30 < 15)
          frame_printing = i * frames_per_ch
          i = i + 1
        end
        while (true) do
          for frame = 1, 30 do
            yield_print(1, s, 10, 30, frame < 15)
          end
        end
      end)
  end
  -- cursor as state?
  local prev_actions = use_state(function() return {c_text_print(txt)} end)

  return prev_actions
end

function eyes()
  function c_eyes_move()
    return cocreate(
      function()
        while (true) do
          for i in all({1, 7, 1, 9}) do
            yield_frames_eyes(30, i)
          end
        end
      end)
  end

  function c_eyes_blink()
    return cocreate(
      function()
        while (true) do
          for i in all({1, 11}) do
            if (i == 1) then
              yield_frames_eyes(60, i)
            else
              yield_frames_eyes(7, i)
            end
          end
        end
      end)
  end

  local prev_actions, set_prev_actions =
    use_state(function() return {c_eyes_blink()} end)

  return prev_actions
end

function mouth()
  function c_mouth_talking()
    return cocreate(
      function()
        while (true) do
          for i in all({21, 17, 19}) do
            yield_frames(5, i)
          end
        end
      end)
  end

  function c_mouth_neutral()
    return cocreate(
      function()
        while (true) do
          yield_frames(1, 17)
        end
      end)
  end

  local prev_state, set_prev_state = use_state("talking")
  local prev_actions, set_prev_actions =
    use_state(function() return {c_mouth_talking()} end)
  local key_state = use_keys()
  local state
  if (key_state.up) then
    state = "talking"
  elseif (key_state.down) then
    state = "neutral"
  else
    state = prev_state
  end

  if (prev_state == state) then
    return prev_actions
  end

  local new_action
  if (state == "neutral") then
    new_actions = {c_mouth_neutral()}
  else
    new_actions = {c_mouth_talking()}
  end
  set_prev_state(state)
  set_prev_actions(new_actions)

  return new_actions
end
