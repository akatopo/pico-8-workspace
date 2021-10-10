create_module("text", function(export)
  local use_state, use_keys, use_selector, use_dispatch = import("use_state",
                                                            "use_keys",
                                                            "use_selector",
                                                            "use_dispatch").from(
    "hooks")
  local text_skip_selector, can_print_selector, text_index_selector,
    text_done_selector, script_done_selector, text_selector = import(
                                                                "text_skip",
                                                                "can_print",
                                                                "text_index",
                                                                "text_done",
                                                                "script_done",
                                                                "text").from(
    "selectors")
  local lipsync = import("*").from("lipsync")
  local draw_text = import("draw_text").from("animation")

  -- 1px border size, 42px text box height, 128 px width
  local text_box_coords = {1, 126, 126, 128 - text_box.height + 2}
  local text_frame_coords = {0, 127, 127, 128 - text_box.height + 1}

  local function c_text_print(s, text_index, dispatch)
    return cocreate(function(params)
      local i = 1
      local frame_printing = 1
      local frames_per_ch = 2
      local skip = params.skip
      local text_x = ch_width - 1
      local text_y = 128 - text_box.height + ch_width
      local mouth_sprites = lipsync.parse(s)

      while (i ~= #s + 1) do
        if (skip) then
          break
        end

        dispatch({type = "letter_printed", sprite_coords = mouth_sprites[i]})
        sfx(30)
        for frame = 1, frames_per_ch do
          draw_text(sub(s, 1, i), text_x, text_y, frame_printing % 30 < 15)
          local new_params = yield()
          skip = new_params.skip
        end
        frame_printing = i * frames_per_ch
        i = i + 1
      end
      dispatch({type = "text_done"})
      dispatch({type = "stop_talking", text_index = text_index})

      local x_button = chr(151)
      while (true) do
        for frame = 1, 30 do
          draw_text(s, text_x, text_y, frame < 15)

          draw_text(x_button, 128 - ch_width * 2 - 2, frame < 15 and
            (128 - ch_height - 2) or (128 - ch_height - 1), false)

          yield()
        end
      end
    end)
  end

  local function c_fill_bg()
    return cocreate(function()
      local args = assign({}, text_box_coords)
      local args2 = assign({}, text_frame_coords)
      add(args, colors["dark-blue"])
      add(args2, colors.white)
      while (true) do
        rect(unpack(args2))
        rectfill(unpack(args))
        yield()
      end
    end)
  end

  export("default", function(props)
    local dispatch = use_dispatch()
    local key_state = use_keys()
    local skip = use_selector(text_skip_selector)
    local can_print = use_selector(can_print_selector)
    local text_index = use_selector(text_index_selector)
    local text = use_selector(text_selector)
    local prev_index, set_prev_index = use_state()
    local text_done = use_selector(text_done_selector)
    local script_done = use_selector(script_done_selector)
    local prev_actions, set_prev_actions = use_state({})
    local actions = prev_actions

    if (not can_print) then
      actions = {c_fill_bg()}
      set_prev_actions({})
    else
      if (prev_index ~= text_index) then
        actions = {c_fill_bg(), c_text_print(text, text_index, dispatch)}
        set_prev_actions(actions)
        set_prev_index(text_index)
      end
    end

    if (key_state.b and text_done) then
      if (not script_done) then
        dispatch({type = "text_start"})
        dispatch({type = "start_talking"})
      else
        dispatch({type = "scene_done"})
      end
    elseif (key_state.b and can_print) then
      dispatch({type = "request_text_skip"})
    elseif (key_state.a and not can_print) then
      dispatch({type = "text_start"})
      dispatch({type = "start_talking"})
    end

    return actions, {skip = skip}
  end)
end)
