create_module("mouth", function(export)
  local use_state, use_keys, use_selector, use_dispatch =
    import("use_state", "use_keys", "use_selector", "use_dispatch").from("hooks")
  local yield_frames = import("yield_frames").from("animation")

  local function c_mouth_talking()
    return cocreate(function()
      while (true) do
        for sprite_coords in all({
          potato_sprites.bottom_half[3], potato_sprites.bottom_half[1],
          potato_sprites.bottom_half[2], potato_sprites.bottom_half[3],
          potato_sprites.bottom_half[6],
        }) do
          yield_frames(5, sprite_coords)
        end
      end
    end)
  end

  local function c_mouth_neutral()
    return cocreate(function()
      while (true) do
        yield_frames(1, potato_sprites.bottom_half[1])
      end
    end)
  end

  export("default", function(props)
    local prev_state, set_prev_state = use_state()
    local prev_actions, set_prev_actions =
      use_state(function() return {c_mouth_talking()} end)
    local dispatch = use_dispatch()
    local key_state = use_keys()
    if (key_state.up) then
      dispatch({type = "start_talking"})
    elseif (key_state.down) then
      dispatch({type = "stop_talking"})
    end
    local mouth_state = use_selector(function(state) return state.mouth end)

    if (prev_state == mouth_state) then
      return prev_actions
    end

    local new_action
    if (mouth_state == "neutral") then
      new_actions = {c_mouth_neutral()}
    else
      new_actions = {c_mouth_talking()}
    end
    set_prev_state(mouth_state)
    set_prev_actions(new_actions)

    return new_actions
  end)
end)
