create_module("animation", function(export)
  local function quad_spr(sprite, x, y)
    local sprite_x_offset = 1
    local sprite_y_offset = 16
    local sprite_dim = 8
    local sprites = {
      {sprite, x, y}, {sprite + sprite_x_offset, x + sprite_dim, y},
      {sprite + sprite_y_offset, x, y + sprite_dim},
      {
        sprite + sprite_x_offset + sprite_y_offset, x + sprite_dim,
        y + sprite_dim,
      },
    }
    foreach(sprites, function(s) spr(unpack(s)) end)
  end

  local function double_spr(sprite_x, sprite_y, x, y)
    local sprite_dim = 8
    palt(14, true)
    palt(0, false)
    sspr(sprite_x, sprite_y, sprite_dim * 2, sprite_dim, x, y, sprite_dim * 4,
      sprite_dim * 2)
    palt()
  end

  export("double_spr", double_spr)

  export("yield_frames", function(t, sprite_coords)
    local sprite_x, sprite_y = unpack(sprite_coords)
    for frame = 1, t do
      double_spr(sprite_x, sprite_y, 80, 80)
      yield()
    end
  end)

end)
