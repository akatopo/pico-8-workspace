function _init()
  local reset_hooks, component_wrapper, destroy_hooks =
    import("reset_hooks", "component_wrapper", "destroy_hooks").from("hooks")
  local create_store, combine_reducers =
    import("create_store", "combine_reducers").from("store")
  local mouth_reducer, text_reducer, scene_reducer, eyes_reducer, choice_reducer =
    import("mouth", "text", "scene", "eyes", "choice").from("reducers")
  local scene_done = import("scene_done").from("selectors")
  local script = import().from("script")
  local outrage_script = import("outrage").from("script")
  local mouth = import().from("mouth")
  local eyes = import().from("eyes")
  local text = import().from("text")
  local choice = import().from("choice")
  local bg = import().from("bg")
  local intro = import().from("intro")
  local outro = import().from("outro")
  local outro_troll = import().from("outro_troll")
  local terrain = import().from("terrain")

  local actions
  local state_from_btn
  local components
  local scene_index = 1

  local scene_reducers = {
    combine_reducers({scene = scene_reducer}), combine_reducers({
      mouth = mouth_reducer,
      text = text_reducer,
      scene = scene_reducer,
      eyes = eyes_reducer,
      choice = choice_reducer,
    }), combine_reducers({scene = scene_reducer}), combine_reducers({
      mouth = mouth_reducer,
      text = text_reducer,
      scene = scene_reducer,
      eyes = eyes_reducer,
      choice = choice_reducer,
    }), combine_reducers({scene = scene_reducer}),
  }

  local initial_states = {
    {}, {
      mouth = {mouth = "start_talking"},
      eyes = {eyes = "blink"},
      choice = {choice = nil},
      text = {text = "text_printing", text_index = 1, script = script},
    }, {}, {
      mouth = {mouth = "start_talking"},
      eyes = {eyes = "blink"},
      choice = {choice = nil},
      text = {text = "text_printing", text_index = 1, script = outrage_script},
    }, {mouth = {mouth = "smiling"}, eyes = {eyes = "happy"}},
  }

  local function component_with_static_props(component, static_props)
    return function(props)
      return component(assign({}, props or {}, static_props or {}))
    end
  end

  -- FIXME: component ordering unfortunately matters
  -- adding choice _after_ text (A) will cause
  -- choice to crash since the state will be changed
  -- when choice tries to render when text has previously
  -- dispatched a "scene_done"
  local scene_components = {
    {{intro, "intro"}}, {
      {bg, "sc1_bg"}, {terrain, "sc1_terrain"}, {mouth, "sc1_mouth"},
      {eyes, "sc1_eyes"}, {choice, "sc1_choice"}, {text, "sc1_text"}, -- A
    }, {{outro_troll, "outro_troll"}}, {
      {bg, "outrage_bg"}, {terrain, "outrage_terrain"},
      {mouth, "outrage_mouth"}, {eyes, "outrage_eyes"},
      {choice, "outrage_choice"}, {text, "outrage_text"},
    }, {
      {outro, "outro"}, {
        component_with_static_props(eyes, {
          x = potato_mouth_x - 32,
          y = 97 - potato_sprites.height,
          eyes = "so",
        }), "outro_eyes_so",
      }, {
        component_with_static_props(mouth, {
          x = potato_mouth_x - 32,
          y = 97,
          mouth = "so",
        }), "outro_mouth_so",
      }, {
        component_with_static_props(eyes, {
          x = potato_mouth_x + 32,
          y = 97 - potato_sprites.height,
          eyes = "loosely",
        }), "outro_eyes_loosely",
      }, {
        component_with_static_props(mouth, {
          x = potato_mouth_x + 32,
          y = 97,
          mouth = "loosely",
        }), "outro_mouth_loosely",
      }, {
        component_with_static_props(eyes, {
          x = potato_mouth_x,
          y = 97 - potato_sprites.height,
          eyes = "alex",
        }), "outro_eyes_alex",
      }, {
        component_with_static_props(mouth, {
          x = potato_mouth_x,
          y = 97,
          mouth = "alex",
        }), "outro_mouth_alex",
      },
    },
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

