create_module("choice", function(export)
  local use_state, use_keys, use_selector, use_dispatch = import("use_state",
                                                            "use_keys",
                                                            "use_selector",
                                                            "use_dispatch").from(
    "hooks")

  local text_done_selector, is_branch_selector, branch_choices_selector =
    import("text_done", "is_branch", "branch_choices").from("selectors")
  local draw_text = import("draw_text").from("animation")

  local function c_test(choices, cur_choice)
    return cocreate(function(params)
      local s = reduce(choices,
        function(prev, cur) return prev .. "\n" .. cur end, cur_choice .. " ")
      while (true) do
        draw_text(s, 10, 10)
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
    local cur_choice, set_cur_choice = use_state(1)
    local prev_text_done, set_prev_text_done = use_state(text_done)

    if (text_done and is_branch) then
      local new_choice = cur_choice
      if (key_state.down) then
        new_choice = mid(1, cur_choice + 1, total_choices)
      elseif (key_state.up) then
        new_choice = mid(1, cur_choice - 1, total_choices)
      elseif (key_state.b) then
        dispatch({type = "choice_made", choice = new_choice})
      end

      set_cur_choice(new_choice)
      set_prev_actions({c_test(branch_choices, new_choice)})
    else
      set_prev_actions({})
    end

    local actions = prev_actions

    return actions, {}
  end)

end)
