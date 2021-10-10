create_module("eyes", function(export)
  local use_state, use_selector = import("use_state", "use_selector").from(
    "hooks")

  local double_spr = import("double_spr").from("animation")

  local function draw_eyes(sprite_coords)
    local sprite_x, sprite_y = unpack(sprite_coords)
    double_spr(sprite_x, sprite_y, potato_eyes_x, potato_eyes_y)
  end

  local function c_eyes_move()
    return cocreate(function()
      while (true) do
        for sprite_coords in all({
          potato_sprites.top_half[1], potato_sprites.top_half[4],
          potato_sprites.top_half[1], potato_sprites.top_half[5],
        }) do
          for frame = 1, 15 do
            draw_eyes(sprite_coords)
            yield()
          end
        end
      end
    end)
  end

  local function c_eyes_sweat()
    return cocreate(function()
      local final_y_offset = 5
      for y_offset = -1, final_y_offset, 1 do
        for frame = 1, 3 do
          draw_eyes(potato_sprites.top_half[8])
          spr(16, potato_eyes_x + potato_sprites.width + 3,
            potato_eyes_y + y_offset)
          yield()
        end
      end
      while (true) do
        draw_eyes(potato_sprites.top_half[8])
        spr(16, potato_eyes_x + potato_sprites.width + 3,
          potato_eyes_y + final_y_offset)
        yield()
      end
    end)
  end

  local function c_eyes_starry()
    return cocreate(function()
      while (true) do
        draw_eyes(potato_sprites.top_half[7])
        yield()
      end
    end)
  end

  local function c_eyes_blink()
    return cocreate(function()
      while (true) do
        for sprite_coords in all({
          potato_sprites.top_half[1], potato_sprites.top_half[6],
        }) do
          if (sprite_coords == potato_sprites.top_half[1]) then
            for frame = 1, 60 do
              draw_eyes(sprite_coords)
              yield()
            end
          else
            for frame = 1, 7 do
              draw_eyes(sprite_coords)
              yield()
            end
          end
        end
      end
    end)
  end

  export("default", function()
    local prev_actions, set_prev_actions =
      use_state(function() return {c_eyes_blink()} end)
    local eye_state = use_selector(function(state) return state.eyes.eyes end)
    local prev_state, set_prev_state = use_state()

    if (prev_state == eye_state) then
      return prev_actions, {}
    end

    local new_actions
    if (eye_state == "blink") then
      new_actions = {c_eyes_blink()}
    elseif (eye_state == "starry") then
      new_actions = {c_eyes_starry()}
    elseif (eye_state == "sweat") then
      new_actions = {c_eyes_sweat()}
    elseif (eye_state == "move") then
      new_actions = {c_eyes_move()}
    else
      assert(false)
    end
    set_prev_state(eye_state)
    set_prev_actions(new_actions)

    return new_actions, {}
  end)
end)
