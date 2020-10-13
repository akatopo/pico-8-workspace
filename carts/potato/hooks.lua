local __hooks_cur_component_id
local __state_hook_initial_vals = {}
local __state_hook_vals = {}
local __state_hook_indices = {}

-- local prev_output
-- function hooks_debug()
--   local output = "\n__state_hook_vals: " .. tostring(__state_hook_vals)
--   if (prev_output == nil) then
--     printh("------", "hooks_debug_log", true)
--   end
--   if (prev_output == output) then
--     return
--   end

--   prev_output = output
--   printh(output, "hooks_debug_log")
-- end

function component_wrapper(component, id)
  return function(props)
    __hooks_cur_component_id = id
    return component(props)
  end
end

function use_keys()
  return {
    left = btn(0),
    right = btn(1),
    up = btn(2),
    down = btn(3),
    a = btn(4),
    b = btn(5),
  }
end

function use_state(initial)
  local component_id = __hooks_cur_component_id
  -- maybe move elsewhere
  if (__state_hook_indices[component_id] == nil) then
    __state_hook_indices[component_id] = 0
  end

  if (__state_hook_initial_vals[component_id] == nil) then
    __state_hook_initial_vals[component_id] = {}
  end

  if (__state_hook_vals[component_id] == nil) then
    __state_hook_vals[component_id] = {}
  end
  --

  assert(component_id ~= nil)
  __state_hook_indices[component_id] = __state_hook_indices[component_id] + 1

  local state_idx = __state_hook_indices[component_id]

  if (__state_hook_initial_vals[component_id][state_idx] == nil) then
    local calculated_initial = type(initial) == "function" and initial() or
                                 initial
    __state_hook_initial_vals[component_id][state_idx] = true
    __state_hook_vals[component_id][state_idx] = calculated_initial
  end

  local set_state =
    function(v) __state_hook_vals[component_id][state_idx] = v end

  return __state_hook_vals[component_id][state_idx], set_state
end

function reset_hooks()
  for component_id, value in pairs(__state_hook_indices) do
    __state_hook_indices[component_id] = 0
  end

  __hooks_cur_component_id = nil
end
