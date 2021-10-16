create_module("selectors", function(export)
  local function is_branch(state)
    local text_index = state.text.text_index
    local path = state.text.script

    return type(path[text_index + 1]) == "table"
  end

  local function get_text_table(state)
    local index = state.text.text_index
    local script = state.text.script
    if (index == nil) then
      return nil
    end
    assert(index <= #script and index > 0, "index out of bounds")
    assert(type(script[index]) == "string" or type(script[index]) == "table")
    if (type(script[index]) == "table") then
      return script[index]
    else
      return {text = script[index]}
    end
  end

  local function choice(state) return state.choice.choice end

  export("mouth", function(state) return state.mouth.mouth end)

  export("text_mouth_reaction", function(state)
    local text_table = get_text_table(state)
    return text_table.mouth_reaction and text_table.mouth_reaction or "neutral"
  end)

  export("mouth_text", function(state) return state.mouth.text end)

  export("mouth_text_index", function(state) return state.mouth.text_index end)

  export("eyes", function(state) return state.eyes.eyes end)

  export("text_skip",
    function(state) return state.text.text == "request_skip" end)

  export("can_print", function(state) return state.text.text ~= "no_text" end)

  export("text_index", function(state) return state.text.text_index end)

  export("is_branch", is_branch)

  export("branch_choices", function(state)
    if (not is_branch(state)) then
      return nil
    end
    local text_index = state.text.text_index
    local path = state.text.script

    local choices = map(path[text_index + 1],
      function(branch) return branch.choice end)
    return choices
  end)

  export("choice", choice)

  export("is_pending_choice",
    function(state) return is_branch(state) and choice(state) == nil end)

  export("text", function(state) return get_text_table(state).text end)

  export("text_eyes_reaction", function(state)
    local text_table = get_text_table(state)
    return text_table.eyes_reaction and text_table.eyes_reaction or "blink"
  end)

  export("text_done", function(state) return state.text.text == "text_done" end)

  export("script_done", function(state)
    local index = state.text.text_index
    local script = state.text.script
    return index == #script
  end)

  export("scene_done", function(state) return state.scene.scene_done end)

end)

create_module("reducers", function(export)
  export("scene", function(state, action)
    local action_type = action.type
    local dispatchers = {
      scene_done = function(state)
        return assign({}, state, {scene_done = true})
      end,
    }
    return (dispatchers[action_type] or identity)(state or {scene_done = false})
  end)

  export("eyes", function(state, action)
    local action_type = action.type
    local dispatchers = {
      start_talking = function(state)
        return assign({}, state, {eyes = "blink"})
      end,
      stop_talking = function(state)
        return assign({}, state, {eyes = action.eyes or "blink"})
      end,
    }
    return (dispatchers[action_type] or identity)(state or {eyes = "blink"})
  end)

  export("mouth", function(state, action)
    local action_type = action.type
    local dispatchers = {
      letter_printed = function(state)
        return assign({}, state,
          {text = action.text, text_index = action.text_index})
      end,
      start_talking = function(state)
        return assign({}, state, {mouth = action.mouth or "talking"})
      end,
      stop_talking = function(state)
        return assign({}, state, {mouth = action.mouth or "neutral"})
      end,
      -- request_text_skip = function(state) return state end,
      -- text_done = function(state) return state end,
    }
    return (dispatchers[action_type] or identity)(state or {mouth = "neutral"})
  end)

  export("choice", function(state, action)
    local action_type = action.type
    local dispatchers = {
      choice_made = function(state)
        return assign({}, state, {choice = action.choice})
      end,
      text_start = function(state)
        local next_state = assign({}, state)
        -- FIXME: assign does not play well w/ nil table values
        next_state.choice = nil
        return next_state
      end,
    }
    return (dispatchers[action_type] or identity)(state or {choice = nil})
  end)

  export("text", function(state, action)
    local action_type = action.type
    local choice = action.choice
    local dispatchers = {
      request_text_skip = function(state)
        if (state.text == "text_printing") then
          return assign({}, state, {text = "request_skip"})
        else
          return state
        end
      end,
      text_done = function(state)
        return assign({}, state, {text = "text_done"})
      end,
      text_start = function(state)
        local text_index = state.text_index
        local path = state.script

        if (type(path[text_index + 1]) == "table") then
          assert(text_index + 1 == #path,
            "branches should be in the end of paths")
          path = path[text_index + 1][choice or 1].path
          assert(type(path[1]) == "string")
          text_index = 1
        else
          text_index = text_index and text_index + 1 or 1
        end

        return assign({}, state, {
          text = "text_printing",
          text_index = text_index,
          script = path,
        })
      end,
      text_clear = function(state)
        return assign({}, state, {text = "no_text"})
      end,
    }
    return (dispatchers[action_type] or identity)(state or {text = "no_text"})
  end)
end)
