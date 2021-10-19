create_module("mouth", function(export)
  local use_state, use_keys, use_selector, use_dispatch, use_memo = import(
                                                                      "use_state",
                                                                      "use_keys",
                                                                      "use_selector",
                                                                      "use_dispatch",
                                                                      "use_memo").from(
    "hooks")
  local double_spr = import("double_spr").from("animation")
  local mouth_selector, mouth_text_selector, mouth_text_index_selector = import(
                                                                           "mouth",
                                                                           "mouth_text",
                                                                           "mouth_text_index").from(
    "selectors")
  local lipsync = import("*").from("lipsync")

  local function draw_mouth(sprite_coords, x, y)
    local sprite_x, sprite_y = unpack(sprite_coords)

    double_spr(sprite_x, sprite_y, x, y)
  end

  local function cocreate_static_sprite_draw(sprite_coords, x, y)
    return cocreate(function()
      while (true) do
        draw_mouth(sprite_coords, x, y)
        yield()
      end
    end)
  end

  local function c_mouth_masked(x, y)
    return cocreate_static_sprite_draw(potato_sprites.bottom_half[10], x, y)
  end

  local function c_mouth_neutral(x, y)
    return cocreate_static_sprite_draw(potato_sprites.bottom_half[1], x, y)
  end

  local function c_mouth_smiling(x, y)
    return cocreate_static_sprite_draw(potato_sprites.bottom_half[7], x, y)
  end

  local function c_mouth_so(x, y)
    return cocreate_static_sprite_draw(potato_sprites.bottom_half[13], x, y)
  end

  local function c_mouth_loosely(x, y)
    return cocreate_static_sprite_draw(potato_sprites.bottom_half[14], x, y)
  end

  local function c_mouth_alex(x, y)
    return cocreate_static_sprite_draw(potato_sprites.bottom_half[12], x, y)
  end

  local function c_mouth_talking(x, y)
    return cocreate(function(params)
      assert(params)
      local new_params = params
      while (true) do
        local sprite_coords = new_params and new_params.sprite_coords or nil
        draw_mouth(sprite_coords or potato_sprites.bottom_half[1], x, y)
        new_params = yield()
        assert(new_params)
      end
    end)
  end

  export("default", function(props)
    local x = props.x or potato_mouth_x
    local y = props.y or potato_mouth_y
    local position = {x, y}
    local prev_state, set_prev_state = use_state()
    local prev_actions, set_prev_actions = use_state()
    local dispatch = use_dispatch()

    local mouth_state = use_selector(mouth_selector)
    local text = use_selector(mouth_text_selector)
    local text_index = use_selector(mouth_text_index_selector)

    mouth_state = props.mouth or mouth_state

    local mouth_sprites = use_memo(function()
      return (text and #text) and lipsync.parse(text, mouth_state) or {}
    end, {text or "", mouth_state})

    if (prev_state == mouth_state) then
      return prev_actions, {sprite_coords = mouth_sprites[text_index]}
    end

    local new_actions = {}
    local f
    if (mouth_state == "neutral") then
      f = c_mouth_neutral
    elseif (mouth_state == "smiling") then
      f = c_mouth_smiling
    elseif (mouth_state == "masked") then
      f = c_mouth_masked
    elseif (mouth_state == "alex") then
      f = c_mouth_alex
    elseif (mouth_state == "so") then
      f = c_mouth_so
    elseif (mouth_state == "loosely") then
      f = c_mouth_loosely
    else
      f = c_mouth_talking
    end
    new_actions = {f(unpack(position))}

    set_prev_state(mouth_state)
    set_prev_actions(new_actions)

    return new_actions, {sprite_coords = mouth_sprites[text_index]}
  end)
end)
