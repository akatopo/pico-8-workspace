create_module("outro_troll", function(export)
  local use_dispatch = import("use_dispatch").from("hooks")
  local use_state, use_keys = import("use_state", "use_keys").from("hooks")
  local use_dispatch = import("use_dispatch").from("hooks")
  local draw_text = import("draw_text").from("animation")

  local function c_draw(dispatch)
    return cocreate(function()
      music(0)

      local time_started = t()
      while (t() - time_started < 3) do
        cls(4)
        -- https://www.lexaloffle.com/bbs/?pid=9994
        -- for each color
        -- (from pink -> white)

        for col = 14, 7, -1 do

          -- for each letter
          for i = 1, 14 do

            -- t() is the same as time()
            t1 = t() * 30 + i * 4 - col * 2

            -- position
            x = i * 8 + cos(t1 / 90) * 3
            y = 38 + (col - 7) + cos(t1 / 50) * 5
            pal(7, col)
            spr(176 + i, x, y)
          end
        end
        yield()
      end

      sfx(31)
      music(-1)
      time_started = t()
      while (t() - time_started < 2) do
        cls(0)
        yield()
      end
      dispatch({type = "scene_done"})
    end)
  end

  export("default", function(props)
    local dispatch = use_dispatch()
    local prev_actions = use_state(function() return {c_draw(dispatch)} end)

    return prev_actions
  end)
end)
