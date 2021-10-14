create_module("mouth", function(export)
  local use_state, use_keys, use_selector, use_dispatch = import("use_state",
                                                            "use_keys",
                                                            "use_selector",
                                                            "use_dispatch").from(
    "hooks")
  local double_spr = import("double_spr").from("animation")
  local mouth_selector, mouth_sprite_coords_selector = import("mouth",
                                                         "mouth_sprite_coords").from(
    "selectors")

  local function draw_mouth(sprite_coords)
    local sprite_x, sprite_y = unpack(sprite_coords)

    double_spr(sprite_x, sprite_y, potato_mouth_x, potato_mouth_y)
  end

  local function c_mouth_neutral()
    return cocreate(function()
      while (true) do
        draw_mouth(potato_sprites.bottom_half[1])
        yield()
      end
    end)
  end

  local function c_mouth_smiling()
    return cocreate(function()
      while (true) do
        draw_mouth(potato_sprites.bottom_half[7])
        yield()
      end
    end)
  end

  local function c_mouth_talking()
    return cocreate(function(params)
      assert(params)
      local new_params = params
      while (true) do
        local sprite_coords = new_params and new_params.sprite_coords or nil
        draw_mouth(sprite_coords or potato_sprites.bottom_half[1])
        new_params = yield()
        assert(new_params)
      end
    end)
  end

  export("default", function(props)
    local prev_state, set_prev_state = use_state()
    local prev_actions, set_prev_actions = use_state()
    local dispatch = use_dispatch()

    local mouth_state = use_selector(mouth_selector)
    local sprite_coords = use_selector(mouth_sprite_coords_selector)

    if (prev_state == mouth_state) then
      return prev_actions, {sprite_coords = sprite_coords}
    end

    local new_actions = {}
    if (mouth_state == "neutral") then
      new_actions = {c_mouth_neutral()}
    elseif (mouth_state == "smiling") then
      new_actions = {c_mouth_smiling()}
    else
      new_actions = {c_mouth_talking()}
    end
    set_prev_state(mouth_state)
    set_prev_actions(new_actions)

    return new_actions, {sprite_coords = sprite_coords}
  end)
end)
