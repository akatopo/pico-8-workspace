create_module("intro", function(export)
  local use_state, use_keys = import("use_state", "use_keys").from("hooks")
  local use_dispatch = import("use_dispatch").from("hooks")
  local draw_text = import("draw_text").from("animation")

  local function c_draw()
    return cocreate(function()
      local start_text = "press \151 to begin!"
      local start_text_x = (128 - #start_text * ch_width - ch_width) / 2
      local start_text_y = 128 - 20
      -- local sx, sy = (64 % 16) * 8, (64 \ 16) * 8
      music(0)

      while (true) do

        for color in all({
          "red", "orange", "yellow", "green", "blue", "lavender",
        }) do
          for frame = 1, 3 do
            rectfill(0, 0, 128, 128, colors["dark-blue"])
            palt(14, true)
            palt(0, false)
            sspr(0, 32, 68, 32, 30, 10)
            sspr(72, 32, 127 - 72, 32, 30, 10 + 32)
            palt()
            draw_text(start_text, start_text_x, start_text_y + 1, false,
              colors["black"])
            draw_text(start_text, start_text_x, start_text_y, false,
              colors[color])
            yield()
          end
        end
      end
    end)
  end

  export("default", function(props)
    local prev_actions = use_state(function() return {c_draw()} end)
    local dispatch = use_dispatch()
    local keys = use_keys()

    if (keys.b) then
      music(-1, 300)
      dispatch({type = "scene_done"})
    end

    return prev_actions
  end)
end)
