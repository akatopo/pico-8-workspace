function _init()
  local reset_hooks, component_wrapper, destroy_hooks =
    import("reset_hooks", "component_wrapper", "destroy_hooks").from("hooks")
  local create_store, combine_reducers =
    import("create_store", "combine_reducers").from("store")
  local mouth_reducer, text_reducer, scene_reducer, eyes_reducer =
    import("mouth", "text", "scene", "eyes").from("reducers")
  local scene_done = import("scene_done").from("selectors")
  local mouth = import().from("mouth")
  local eyes = import().from("eyes")
  local text = import().from("text")
  local bg = import().from("bg")
  local intro = import().from("intro")
  local outro = import().from("outro")

  local actions
  local state_from_btn
  local components
  local scene_index = 1

  local scene_reducers = {
    combine_reducers({scene = scene_reducer}), combine_reducers(
      {
        mouth = mouth_reducer,
        text = text_reducer,
        scene = scene_reducer,
        eyes = eyes_reducer,
      }), combine_reducers({scene = scene_reducer}),
  }

  local initial_states = {
    {}, {
      mouth = {mouth = "start_talking"},
      eyes = {eyes = "blink"},
      text = {
        text = "text_printing",
        text_index = 1,
        script = {
          --[[
-- 3456789012345678903456789012
--]]
          [[
well, hello there!]], [[
mr. potato nugget here!]], [[
why they call me that you ask?]], [[
because i look like a... oh,
you don't want to know after
all? too bad!]], [[
so... you probably know where
this is going...]], [[
yup. your gift has not
arrived yet.]], [[
but!]], [[
that's not the whole truth.
one half is here~]], [[
the other half might take
a while longer.]], [[
canada is far away you know?]], [[i'm sure you understand]], [[right?]],
          [[that being said...]],
        },
      },
    }, {mouth = {mouth = "smiling"}, eyes = {eyes = "starry"}},
  }

  local scene_components = {
    {{intro, "intro"}},
    {
      {bg, "sc1_bg"}, {mouth, "sc1_mouth"}, {eyes, "sc1_eyes"},
      {text, "sc1_text"},
    }, {{outro, "outro"}, {mouth, "sc1_mouth"}, {eyes, "sc1_eyes"}},
  }

  local store = create_store(scene_reducers[scene_index],
    initial_states[scene_index])
  store.subscribe(function(state)
    if (scene_done(state)) then
      scene_index = scene_index + 1
      store = create_store(scene_reducers[scene_index],
        initial_states[scene_index])
      destroy_hooks()
      components = map(scene_components[scene_index], (function(v)
        add(v, store)
        return component_wrapper(unpack(v))
      end))
    end
  end)

  local function consume_actions(x)
    local actions, params = unpack(x)
    local ctr = 1
    for c in all(actions) do
      if (costatus(c) ~= "dead") then
        assert(coresume(c, params))
      end
      ctr = ctr + 1
    end
  end

  components = map(scene_components[scene_index], (function(v)
    add(v, store)
    return component_wrapper(unpack(v))
  end))

  function _update() reset_hooks() end

  function _draw()
    cls()

    local scene = map(components, function(f)
      local actions, params = f({})
      return {actions, params}
    end)
    foreach(scene, consume_actions)
  end
end

