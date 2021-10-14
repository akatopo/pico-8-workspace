create_module("choice", function(export)
  local use_state, use_keys, use_selector, use_dispatch = import("use_state",
                                                            "use_keys",
                                                            "use_selector",
                                                            "use_dispatch").from(
    "hooks")

  local text_done_selector, is_branch_selector, branch_choices_selector =
    import("text_done", "is_branch", "branch_choices").from("selectors")
  local draw_text = import("draw_text").from("animation")

  local arrow_margin = 1
  local frame_dim = 1
  local padding = 2
  local margin = 2

  local function calculate_box_width(choices)
    local max_len = reduce(choices,
      function(prev, cur) return max(prev, #cur) end, 0)

    return (max_len + 1) * ch_width + arrow_margin + (frame_dim + padding) * 2
  end

  local function c_fill_bg(choices)
    local num_choices = #choices
    local box_width = calculate_box_width(choices)
    return cocreate(function()
      local h = 3 + (num_choices) * (ch_height + 2) - 1
      local choice_box_coords = {
        128 - box_width + 1 - margin, 1 + margin, 128 - margin - 2,
        h - 1 + margin,
      }
      local choice_frame_coords = {
        128 - box_width - margin, 0 + margin, 128 - margin - 1, h + margin,
      }

      local args = assign({}, choice_box_coords)
      local args2 = assign({}, choice_frame_coords)
      add(args, colors["dark-blue"])
      add(args2, colors.white)
      while (true) do
        rect(unpack(args2))
        rectfill(unpack(args))
        yield()
      end
    end)
  end

  local function c_draw_choices(choices, cur_choice)
    local box_width = calculate_box_width(choices)
    return cocreate(function(params)
      while (true) do
        for index, choice in pairs(choices) do
          local y = margin + padding + frame_dim + (index - 1) * (ch_height + 2)
          draw_text(choice, 128 - margin - box_width + padding + frame_dim +
            ch_width + arrow_margin, y)
          if (index == cur_choice) then
            draw_text("\23", 128 - box_width - margin + padding + frame_dim, y)
          end
        end
        yield()
      end
    end)
  end

  export("default", function(props)
    local dispatch = use_dispatch()
    local key_state = use_keys()
    local text_done = use_selector(text_done_selector)
    local is_branch = use_selector(is_branch_selector)
    local branch_choices = use_selector(branch_choices_selector)
    local total_choices = branch_choices and #branch_choices or 0
    local prev_actions, set_prev_actions = use_state({})
    local prev_choice, set_prev_choice = use_state(nil)
    local prev_text_done, set_prev_text_done = use_state(text_done)
    local actions = prev_actions

    if (text_done and is_branch) then
      local new_choice
      local cur_choice = prev_choice or 1

      if (key_state.down) then
        new_choice = mid(1, cur_choice + 1, total_choices)
      elseif (key_state.up) then
        new_choice = mid(1, cur_choice - 1, total_choices)
      else
        new_choice = cur_choice
      end

      if (key_state.b) then
        dispatch({type = "choice_made", choice = new_choice})
      end

      if (new_choice ~= prev_choice) then
        assert(new_choice ~= nil)
        actions = {
          c_fill_bg(branch_choices), c_draw_choices(branch_choices, new_choice),
        }
        set_prev_choice(new_choice)
        set_prev_actions(actions)
      end
    else
      actions = {}
      set_prev_choice(nil)
      set_prev_actions(actions)
    end

    return actions, {}
  end)

end)
