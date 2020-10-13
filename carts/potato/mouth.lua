create_module("mouth", function(export)
  local use_state, use_keys = import("use_state", "use_keys").from("hooks")
  local yield_frames = import("yield_frames").from("animation")

  local function c_mouth_talking()
    return cocreate(function()
      while (true) do
        for i in all({21, 17, 19}) do
          yield_frames(5, i)
        end
      end
    end)
  end

  local function c_mouth_neutral()
    return cocreate(function()
      while (true) do
        yield_frames(1, 17)
      end
    end)
  end

  export("default", function(props)
    local prev_state, set_prev_state = use_state("talking")
    local prev_actions, set_prev_actions =
      use_state(function() return {c_mouth_talking()} end)
    local key_state = use_keys()
    local state
    if (key_state.up) then
      state = "talking"
    elseif (key_state.down) then
      state = "neutral"
    else
      state = prev_state
    end

    if (prev_state == state) then
      return prev_actions
    end

    local new_action
    if (state == "neutral") then
      new_actions = {c_mouth_neutral()}
    else
      new_actions = {c_mouth_talking()}
    end
    set_prev_state(state)
    set_prev_actions(new_actions)

    return new_actions
  end)
end)
