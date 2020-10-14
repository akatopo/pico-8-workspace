create_module("hooks", function(export)
  local cur_component_id
  local state_hook_initial_vals = {}
  local state_hook_vals = {}
  local state_hook_indices = {}
  local cur_store = {}
  -- local store_hook_selectors = {}

  local prev_output
  function hooks_debug()
    local output = "\nstate_hook_vals: " .. tostring(state_hook_vals)
    if (prev_output == nil) then
      printh("------", "hooks_debug_log", true)
    end
    if (prev_output == output) then
      return
    end

    prev_output = output
    printh(output, "hooks_debug_log")
  end

  export("component_wrapper", function(component, id, store)
    assert(store ~= nil)
    cur_store = store
    return function(props)
      cur_component_id = id
      return component(props)
    end
  end)

  export("use_dispatch", function() return cur_store.dispatch end)

  export("use_selector", function(f)
    assert(cur_store.get_state ~= nil)
    return f(cur_store.get_state())
  end)

  export("use_store", function()
    assert(cur_store.get_state ~= nil)
    return cur_store
  end)

  export("use_keys", function()
    return {
      left = btn(0),
      right = btn(1),
      up = btn(2),
      down = btn(3),
      a = btn(4),
      b = btn(5),
    }
  end)

  export("use_state", function(initial)
    local component_id = cur_component_id
    -- maybe move elsewhere
    if (state_hook_indices[component_id] == nil) then
      state_hook_indices[component_id] = 0
    end

    if (state_hook_initial_vals[component_id] == nil) then
      state_hook_initial_vals[component_id] = {}
    end

    if (state_hook_vals[component_id] == nil) then
      state_hook_vals[component_id] = {}
    end
    --

    assert(component_id ~= nil)
    state_hook_indices[component_id] = state_hook_indices[component_id] + 1

    local state_idx = state_hook_indices[component_id]

    if (state_hook_initial_vals[component_id][state_idx] == nil) then
      local calculated_initial = type(initial) == "function" and initial() or
                                   initial
      state_hook_initial_vals[component_id][state_idx] = true
      state_hook_vals[component_id][state_idx] = calculated_initial
    end

    local set_state = function(v)
      state_hook_vals[component_id][state_idx] = v
    end

    return state_hook_vals[component_id][state_idx], set_state
  end)

  export("reset_hooks", function()
    for component_id, value in pairs(state_hook_indices) do
      state_hook_indices[component_id] = 0
    end

    cur_component_id = nil
    -- cur_store = {}
  end)
end)
