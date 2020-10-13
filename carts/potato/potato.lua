function _init()
  local use_state, use_keys, reset_hooks, component_wrapper =
    import("use_state", "use_keys", "reset_hooks", "component_wrapper").from(
      "hooks")
  local mouth = import().from("mouth")
  local eyes = import().from("eyes")
  local text = import().from("text")

  local function consume_actions(actions)
    for c in all(actions) do
      if (costatus(c) ~= "dead") then
        assert(coresume(c))
      end
    end
  end

  local actions
  local state_from_btn
  local components

  components = map({
    {mouth, "sc1_mouth"}, {eyes, "sc1_eyes"}, {text, "sc1_text"},
  }, (function(v) return component_wrapper(unpack(v)) end))

  function _update() reset_hooks() end

  function _draw()
    cls()
    print(stat(7), 0, 0)
    print(stat(7), 128 - ch_width * #tostr(stat(7)), 128 - ch_height)

    -- apply props properly?
    local txt = [[
Convert val to a string.
When val is a number,
function or table,
use_hex can be used to
include the raw hexidecimal
value]]
    local scene = map(components, function(f) return f({txt = txt}) end)
    foreach(scene, consume_actions)
  end
end

