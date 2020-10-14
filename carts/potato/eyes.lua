create_module("eyes", function(export)
  local use_state = import("use_state").from("hooks")
  local double_spr = import("double_spr").from("animation")

  local function yield_frames_eyes(t, sprite_coords)
    local sprite_x, sprite_y = unpack(sprite_coords)
    for frame = 1, t do
      double_spr(sprite_x, sprite_y, 80, 80 - potato_sprites.height)
      yield()
    end
  end

  local function c_eyes_move()
    return cocreate(function()
      while (true) do
        for i in all({
          potato_sprites.top_half[1], potato_sprites.top_half[4],
          potato_sprites.top_half[1], potato_sprites.top_half[5],
        }) do
          yield_frames_eyes(30, i)
        end
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
            yield_frames_eyes(60, sprite_coords)
          else
            yield_frames_eyes(7, sprite_coords)
          end
        end
      end
    end)
  end

  export("default", function()
    local prev_actions, set_prev_actions =
      use_state(function() return {c_eyes_blink()} end)

    return prev_actions
  end)
end)
