create_module("hooks", function(export)
  local cur_component_id
  local state_hook_initial_vals = {}
  local state_hook_vals = {}
  local state_hook_indices = {}
  local cur_store = {}
  -- local store_hook_selectors = {}

  local prev_output
  local function hooks_debug()
    local output = "\n " .. tojson(state_hook_vals)
    local delimeter = ""
    if (prev_output == nil) then
      printh("[\n", "hooks", true)
    else
      delimeter = "\n,\n"
    end
    if (prev_output == output) then
      return
    end

    prev_output = output
    printh(delimeter .. output, "hooks")
  end

  local function use_state(initial)
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

  export("use_keys", function(use_btnp)
    local use_btnp = use_btnp == nil and true or use_btnp
    local f = use_btnp and btnp or btn
    return {
      left = f(0),
      right = f(1),
      up = f(2),
      down = f(3),
      a = f(4),
      b = f(5),
    }
  end)

  export("use_memo", function(f, deps)
    local memo_tuple, set_memo_tuple = use_state(function()
      return {f(), deps}
    end)
    local memo = memo_tuple[1]
    local old_deps = memo_tuple[2]

    assert(#deps == #old_deps,
      "deps must have the same length" .. tojson(memo_tuple))

    local equal = true
    for i, v in pairs(deps) do
      if (v ~= old_deps[i]) then
        equal = false
      end
    end

    if (equal) then
      return memo
    else
      local res = f()
      set_memo_tuple({res, deps})
      return res
    end
  end)

  export("use_state", use_state)

  export("reset_hooks", function()
    for component_id, value in pairs(state_hook_indices) do
      state_hook_indices[component_id] = 0
    end

    cur_component_id = nil
    -- cur_store = {}
  end)

  export("destroy_hooks", function()
    cur_component_id = nil
    state_hook_initial_vals = {}
    state_hook_vals = {}
    state_hook_indices = {}
    cur_store = {}
  end)
end)
