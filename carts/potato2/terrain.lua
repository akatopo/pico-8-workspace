-- basic perspective tline demo by @powersaurus
-- https://gist.github.com/Powersaurus/a2f14141efef62c32fb9bf8f1f889f6f
create_module("terrain", function(export)
  local use_state, use_keys, use_selector, use_dispatch = import("use_state",
                                                            "use_keys",
                                                            "use_selector",
                                                            "use_dispatch").from(
    "hooks")

  local text_done_selector, is_branch_selector =
    import("text_done", "is_branch").from("selectors")

  local function c_draw_terrain()
    return cocreate(function(params)
      local new_params = params
      while (true) do
        local rotation = new_params.rotation
        local mx = new_params.mx
        local my = new_params.my
        -- loop map outside of 8x8
        poke(0x5f38, 1)
        poke(0x5f39, 1)

        -- player direction
        local sty = sin(rotation)
        local stx = cos(rotation)

        -- camera direction
        local msy = cos(rotation)
        local msx = -sin(rotation)

        camera(0, text_box.height)
        -- not bothering with
        -- 64..71 - too noisy
        for y = 72, 128 do
          local dist = (128 / (2 * y - 128 + 1))

          -- printh(">"..msx.." "..msy)
          -- divide by smaller number to zoom in
          local dby4 = dist / 2
          local d16 = dby4 / 64

          tline(0, y, 127, y, mx + (-msx + stx) * dby4,
            my + (-msy + sty) * dby4, d16 * msx, d16 * msy -- after every pixel *drawn*
          -- not texel!!!!
          )
        end
        camera()
        new_params = yield()
      end
    end)
  end

  export("default", function(props)
    local dispatch = use_dispatch()
    local key_state = use_keys(false)
    local text_done = use_selector(text_done_selector)
    local is_branch = use_selector(is_branch_selector)
    -- player rotation
    local rotation, set_rotation = use_state(0)
    -- player screen pos
    -- local px, set_px = use_state(64)
    -- local py, set_py = use_state(64)
    local mx, set_mx = use_state(0)
    local my, set_my = use_state(0)

    local prev_actions, set_prev_actions = use_state({c_draw_terrain()})
    local new_rotation = rotation
    local new_mx = mx
    local new_my = my

    local actions = prev_actions

    if (not (text_done and is_branch)) then
      if (key_state.up) then
        new_mx = new_mx + cos(new_rotation) / 16
        new_my = new_my + sin(new_rotation) / 16
      elseif (key_state.down) then
        new_mx = new_mx - cos(new_rotation) / 16
        new_my = new_my - sin(new_rotation) / 16
      end

      if (key_state.left) then
        new_rotation = new_rotation + 2.5 / 360
      elseif (key_state.right) then
        new_rotation = new_rotation - 2.5 / 360
      end

      if (new_rotation < 0) then
        new_rotation = new_rotation + 1.0
      elseif (new_rotation >= 1.0) then
        new_rotation = new_rotation - 1.0
      end
    end

    set_rotation(new_rotation)
    set_mx(new_mx)
    set_my(new_my)

    return actions, {rotation = new_rotation, mx = new_mx, my = new_my}
  end)

end)
