create_module("selectors", function(export)
  export("mouth", function(state) return state.mouth.mouth end)

  export("mouth_sprite_coords",
    function(state) return state.mouth.sprite_coords end)

  export("text_skip",
    function(state) return state.text.text == "request_skip" end)

  export("can_print", function(state) return state.text.text ~= "no_text" end)

  export("text_index", function(state) return state.text.text_index end)

  export("text", function(state)
    local index = state.text.text_index
    local script = state.text.script
    if (index == nil) then
      return nil
    end
    assert(index <= #script and index > 0, "index out of bounds")
    return script[index]
  end)

  export("text_done", function(state) return state.text.text == "text_done" end)

  -- XXX script done should take branches into account
  export("script_done", function(state)
    local index = state.text.text_index
    local script = state.text.script
    return index == #script
  end)

  export("scene_done", function(state) return state.scene.scene_done end)

end)

create_module("reducers", function(export)
  export("scene", function(state, action)
    local action_type = action.type;
    local dispatchers = {
      scene_done = function(state)
        return assign({}, state, {scene_done = true})
      end,
    }
    return (dispatchers[action_type] or identity)(state or {scene_done = false})
  end)

  export("eyes", function(state, action)
    local text_reactions = {[6] = "sweat", [8] = "starry", [12] = "sweat"}

    local action_type = action.type;
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

    local action_type = action.type;
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

  export("text", function(state, action)
    local action_type = action.type;
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
        return assign({}, state, {
          text = "text_printing",
          text_index = text_index and text_index + 1 or 1,
        })
      end,
      text_clear = function(state)
        return assign({}, state, {text = "no_text"})
      end,
    }
    return (dispatchers[action_type] or identity)(state or {text = "no_text"})
  end)
end)
