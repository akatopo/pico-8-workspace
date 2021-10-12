create_module("selectors", function(export)
  local function is_branch(state)
    local text_index = state.text.text_index
    local path = state.text.script

    return type(path[text_index + 1]) == "table"
  end

  local function choice(state) return state.choice.choice end

  export("mouth", function(state) return state.mouth.mouth end)

  export("mouth_sprite_coords",
    function(state) return state.mouth.sprite_coords end)

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

  export("text", function(state)
    local index = state.text.text_index
    local script = state.text.script
    if (index == nil) then
      return nil
    end
    assert(index <= #script and index > 0, "index out of bounds")
    assert(type(script[index]) == "string")
    return script[index]
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
    local text_reactions = {[6] = "sweat", [8] = "starry", [12] = "sweat"}

    local action_type = action.type
    local dispatchers = {
      start_talking = function(state)
        return assign({}, state, {eyes = "blink"})
      end,
      stop_talking = function(state)
        local text_index = action.text_index
        local eye_state = text_index and text_reactions[text_index] or "blink"

        return assign({}, state, {eyes = eye_state})
      end,
    }
    return (dispatchers[action_type] or identity)(state or {eyes = "blink"})
  end)

  export("mouth", function(state, action)
    local text_reactions = {[8] = "smiling"}

    local action_type = action.type
    local dispatchers = {
      letter_printed = function(state)
        return assign({}, state, {sprite_coords = action.sprite_coords})
      end,
      start_talking = function(state)
        return assign({}, state, {mouth = "talking"})
      end,
      stop_talking = function(state)
        local text_index = action.text_index
        local mouth_state = text_index and text_reactions[text_index] or
                              "neutral"

        return assign({}, state, {mouth = mouth_state})
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
      text_start = function(state) return assign({}, state, {choice = nil}) end,
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
