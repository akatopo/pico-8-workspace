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

  local function double_spr(sprite, x, y)
    local sprite_x_offset = 1
    local sprite_y_offset = 16
    local sprite_dim = 8
    local sprites = {
      {sprite, x, y}, {sprite + sprite_x_offset, x + sprite_dim, y},
    }
    foreach(sprites, function(s) spr(unpack(s)) end)
  end

  export("double_spr", double_spr)

  export("yield_frames", function(t, i)
    for frame = 1, t do
      double_spr(i, 80, 80)
      yield()
    end
  end)

end)
