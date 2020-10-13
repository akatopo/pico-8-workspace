create_module("eyes", function(export)
  local use_state = import("use_state").from("hooks")
  local double_spr = import("double_spr").from("animation")

  local function yield_frames_eyes(t, i)
    for frame = 1, t do
      double_spr(i, 80, 72)
      yield()
    end
  end

  local function c_eyes_move()
    return cocreate(function()
      while (true) do
        for i in all({1, 7, 1, 9}) do
          yield_frames_eyes(30, i)
        end
      end
    end)
  end

  local function c_eyes_blink()
    return cocreate(function()
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

  export("default", function()
    local prev_actions, set_prev_actions =
      use_state(function() return {c_eyes_blink()} end)

    return prev_actions
  end)
end)
