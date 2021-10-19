create_module("eyes", function(export)
  local use_state, use_selector = import("use_state", "use_selector").from(
    "hooks")
  local double_spr = import("double_spr").from("animation")
  local eyes_selector = import("eyes").from("selectors")

  local function draw_eyes(sprite_coords, x, y)
    local sprite_x, sprite_y = unpack(sprite_coords)
    double_spr(sprite_x, sprite_y, x, y)
  end

  local function c_eyes_move(x, y)
    return cocreate(function()
      while (true) do
        for sprite_coords in all({
          potato_sprites.top_half[1], potato_sprites.top_half[4],
          potato_sprites.top_half[1], potato_sprites.top_half[5],
        }) do
          for frame = 1, 15 do
            draw_eyes(sprite_coords, x, y)
            yield()
          end
        end
      end
    end)
  end

  local function c_eyes_sweat(x, y)
    return cocreate(function()
      local final_y_offset = 5
      for y_offset = -1, final_y_offset, 1 do
        for frame = 1, 3 do
          draw_eyes(potato_sprites.top_half[8], x, y)
          spr(16, potato_eyes_x + potato_sprites.width + 3,
            potato_eyes_y + y_offset)
          yield()
        end
      end
      while (true) do
        draw_eyes(potato_sprites.top_half[8], x, y)
        spr(16, potato_eyes_x + potato_sprites.width + 3,
          potato_eyes_y + final_y_offset)
        yield()
      end
    end)
  end

  local function cocreate_static_sprite_draw(sprite_coords, x, y)
    return cocreate(function()
      while (true) do
        draw_eyes(sprite_coords, x, y)
        yield()
      end
    end)
  end

  local function c_eyes_happy(x, y)
    return cocreate_static_sprite_draw(potato_sprites.top_half[7], x, y)
  end

  local function c_eyes_so(x, y)
    return cocreate_static_sprite_draw(potato_sprites.top_half[13], x, y)
  end

  local function c_eyes_loosely(x, y)
    return cocreate_static_sprite_draw(potato_sprites.top_half[14], x, y)
  end

  local function c_eyes_alex(x, y)
    return cocreate_static_sprite_draw(potato_sprites.top_half[12], x, y)
  end

  local function c_eyes_blink(x, y)
    return cocreate(function()
      while (true) do
        for sprite_coords in all({
          potato_sprites.top_half[1], potato_sprites.top_half[6],
        }) do
          if (sprite_coords == potato_sprites.top_half[1]) then
            for frame = 1, 60 do
              draw_eyes(sprite_coords, x, y)
              yield()
            end
          else
            for frame = 1, 7 do
              draw_eyes(sprite_coords, x, y)
              yield()
            end
          end
        end
      end
    end)
  end

  export("default", function(props)
    local position = {props.x or potato_eyes_x, props.y or potato_eyes_y}
    local prev_actions, set_prev_actions =
      use_state(function() return {c_eyes_blink()} end)
    local eye_state = use_selector(eyes_selector)
    local prev_state, set_prev_state = use_state()

    eye_state = props.eyes or eye_state
    if (prev_state == eye_state) then
      return prev_actions, {}
    end

    local new_actions
    local f
    if (eye_state == "blink") then
      f = c_eyes_blink
    elseif (eye_state == "happy") then
      f = c_eyes_happy
    elseif (eye_state == "sweat") then
      f = c_eyes_sweat
    elseif (eye_state == "move") then
      f = c_eyes_move
    elseif (eye_state == "alex") then
      f = c_eyes_alex
    elseif (eye_state == "so") then
      f = c_eyes_so
    elseif (eye_state == "loosely") then
      f = c_eyes_loosely
    else
      assert(false, "invalid eye state")
    end
    new_actions = {f(unpack(position))}
    set_prev_state(eye_state)
    set_prev_actions(new_actions)

    return new_actions, {}
  end)
end)
