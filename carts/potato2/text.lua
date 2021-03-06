create_module("text", function(export)
  local use_state, use_keys, use_selector, use_dispatch = import("use_state",
                                                            "use_keys",
                                                            "use_selector",
                                                            "use_dispatch").from(
    "hooks")
  local text_skip_selector, can_print_selector, text_index_selector,
    text_done_selector, script_done_selector, text_selector, choice_selector,
    is_pending_choice_selector = import("text_skip", "can_print", "text_index",
                                   "text_done", "script_done", "text", "choice",
                                   "is_pending_choice").from("selectors")
  local text_eyes_reaction_selector, text_mouth_reaction_selector,
    text_mouth_selector = import("text_eyes_reaction", "text_mouth_reaction",
                            "text_mouth").from("selectors")
  local lipsync = import("*").from("lipsync")
  local draw_text = import("draw_text").from("animation")

  -- 1px border size, 42px text box height, 128 px width
  local text_box_coords = {1, 126, 126, 128 - text_box.height + 2}
  local text_frame_coords = {0, 127, 127, 128 - text_box.height + 1}

  local function c_text_print(s, eyes, mouth, dispatch)
    return cocreate(function(params)
      local i = 1
      local frame_printing = 1
      local frames_per_ch = 2
      local skip = params.skip
      local is_pending_choice = params.is_pending_choice
      local text_x = ch_width - 1
      local text_y = 128 - text_box.height + ch_width

      while (i ~= #s + 1) do
        if (skip) then
          break
        end

        dispatch({type = "letter_printed", text = s, text_index = i})
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
      dispatch({type = "stop_talking", eyes = eyes, mouth = mouth})

      local x_button = chr(151)
      while (true) do
        for frame = 1, 30 do
          draw_text(s, text_x, text_y,
            -- see http://lua-users.org/wiki/TernaryOperator
            not is_pending_choice and frame < 15 or false)

          if (not is_pending_choice) then
            draw_text(x_button, 128 - ch_width * 2 - 2, frame < 15 and
              (128 - ch_height - 2) or (128 - ch_height - 1), false)
          end
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
    local is_pending_choice = use_selector(is_pending_choice_selector)
    local text = use_selector(text_selector)
    local choice = use_selector(choice_selector)
    local prev_index, set_prev_index = use_state()
    local prev_text, set_prev_text = use_state()
    local text_done = use_selector(text_done_selector)
    local script_done = use_selector(script_done_selector)
    local text_eyes_reaction = use_selector(text_eyes_reaction_selector)
    local text_mouth = use_selector(text_mouth_selector)
    local text_mouth_reaction = use_selector(text_mouth_reaction_selector)
    local prev_actions, set_prev_actions = use_state({})
    local actions = prev_actions

    if (not can_print) then
      actions = {c_fill_bg()}
      set_prev_actions({})
    else
      -- FIXME: not the best comparison but it will do
      if (prev_text ~= text) then
        dispatch({type = "start_talking", mouth = text_mouth or "talking"})
        actions = {
          c_fill_bg(),
          c_text_print(text, text_eyes_reaction, text_mouth_reaction, dispatch),
        }
        set_prev_actions(actions)
        set_prev_text(text)
      end
    end

    if (key_state.b and text_done and not is_pending_choice) then
      if (not script_done) then
        dispatch({type = "text_start", choice = choice})

      else
        dispatch({type = "scene_done"})
      end
    elseif (key_state.b and can_print) then
      dispatch({type = "request_text_skip"})
    end

    return actions, {skip = skip, is_pending_choice = is_pending_choice}
  end)
end)
