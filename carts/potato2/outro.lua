create_module("outro", function(export)
  local use_state, use_keys = import("use_state", "use_keys").from("hooks")
  local use_dispatch = import("use_dispatch").from("hooks")
  local draw_text = import("draw_text").from("animation")

  local function c_draw()
    return cocreate(function()
      music(0)

      while (true) do
        cls(15)
        -- https://www.lexaloffle.com/bbs/?pid=9994
        -- for each color
        -- (from pink -> white)

        for col = 14, 7, -1 do
          local color = col == 7 and 0 or col
          -- for each letter
          for i = 1, 10 do

            -- t() is the same as time()
            local t1 = t() * 30 + i * 4 - col * 2

            -- position
            local x = 16 + i * 8 + cos(t1 / 90) * 3
            local y = 38 + (col - 7) + cos(t1 / 50) * 5
            pal(7, col == 7 and 0 or col)
            spr(144 + i, x, y)
          end

          for i = 1, 3 do

            -- t() is the same as time()
            local t1 = t() * 30 + i * 4 - col * 2

            -- position
            local x = 16 + 24 + i * 8 + cos(t1 / 90) * 3
            local y = 38 + 24 + (col - 7) + cos(t1 / 50) * 5
            pal(7, col == 7 and 0 or col)
            spr(160 + i, x, y)
          end
        end
        yield()
      end
    end)
  end

  export("default", function(props)
    local prev_actions = use_state(function() return {c_draw()} end)

    return prev_actions
  end)
end)
