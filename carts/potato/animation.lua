create_module("animation", function(export)
  local function count_lines(s)
    local count = 1
    for i = 1, #s do
      if (sub(s, i, i) == "\n") then
        count = count + 1
      end
    end
    return count
  end

  export("double_spr", function(sprite_x, sprite_y, x, y)
    local sprite_dim = 8
    palt(14, true)
    palt(0, false)
    sspr(sprite_x, sprite_y, sprite_dim * 2, sprite_dim, x, y, sprite_dim * 4,
      sprite_dim * 2)
    palt()
  end)

  export("draw_text", function(s, x, y, blink, text_color)
    local text_color = text_color or colors["white"]

    print(s, x, y, text_color)
    if (blink) then
      local block = chr(16)
      local line_total = count_lines(s)
      local line_length = #(split(s, "\n")[line_total])
      local y_offset = (line_total - 1) * ch_height
      local x_offset = line_length * ch_width
      print(block, x + x_offset, y + y_offset, text_color)
    end
  end)

end)
