function _init()
  local use_state, use_keys, reset_hooks, component_wrapper =
    import("use_state", "use_keys", "reset_hooks", "component_wrapper").from(
      "hooks")
  local create_store = import("create_store").from("store")
  local mouth = import().from("mouth")
  local eyes = import().from("eyes")
  local text = import().from("text")
  local bg = import().from("bg")

  local store = create_store(function(state, action)
    local action_type = action.type;
    local dispatchers = {
      start_talking = function(state)
        return assign({}, state, {mouth = "talking"})
      end,
      stop_talking = function(state)
        return assign({}, state, {mouth = "neutral"})
      end,
      request_text_skip = function(state)
        if (state.text ~= "text_done") then
          return assign({}, state, {text = "request_skip"})
        else
          return state
        end
      end,
      text_done = function(state)
        return assign({}, state, {text = "text_done"})
      end,
    }
    return (dispatchers[action_type] or identity)(state)
  end, {mouth = "neutral", text = nil})

  local function consume_actions(x)
    local actions, params = unpack(x)
    for c in all(actions) do
      if (params) then
        -- printh(tostring(params), "store")
      end
      if (costatus(c) ~= "dead") then
        assert(coresume(c, params))
      end
    end
  end

  local actions
  local state_from_btn
  local components

  components = map({
    {bg, "sc1_bg"}, {mouth, "sc1_mouth"}, {eyes, "sc1_eyes"},
    {text, "sc1_text"},

  }, (function(v)
    add(v, store)
    return component_wrapper(unpack(v))
  end))

  function _update() reset_hooks() end

  function _draw()
    cls()

    -- apply props properly?
    local txt = [[
Convert val to a string.
When val is a number,
function or table,
use_hex can be used to
include the raw hexidecimal
value]]
    local scene = map(components, function(f)
      local actions, params = f({txt = txt})
      return {actions, params}
    end)
    foreach(scene, consume_actions)
  end
end

