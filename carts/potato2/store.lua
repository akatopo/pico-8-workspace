create_module("store", function(export)
  local global_state = {}
  local subscriptions = {}

  local function debug_state() printh(tojson(global_state), "store") end

  export("create_store", function(reducer, initial)
    if (initial ~= nil) then
      global_state = initial
      debug_state()
    end
    return {
      dispatch = function(action)
        assert(action)
        global_state = reducer(global_state, action)
        debug_state()
        for sub in pairs(subscriptions) do
          sub(global_state)
        end
      end,
      get_state = function() return global_state end,
      subscribe = function(f) subscriptions[f] = f end,
      unsubscribe = function(f)
        assert(subscriptions[f], "no such subscription")
        del(subscriptions[f])
      end,
    }
  end)

  export("combine_reducers", function(name_reducer_map)
    return function(state, action)
      local new_state = {}
      printh("-- dispathed " .. tojson(action), "store")
      for name, reducer in pairs(name_reducer_map) do
        new_state[name] = reducer(state[name], action)
      end
      return new_state
    end
  end)
end)
