create_module("text", function(export)
  local use_state = import("use_state").from("hooks")

  function count_lines(s)
    local count = 1
    for i = 1, #s do
      if (sub(s, i, i) == "\n") then
        count = count + 1
      end
    end
    return count
  end

  function yield_print(t, s, x, y, blink)
    for frame = 1, t do
      print(s, x, y)
      if (blink) then
        local block = chr(16)
        local line_total = count_lines(s)
        local line_length = #(split(s, "\n")[line_total])
        local y_offset = (line_total - 1) * ch_height
        local x_offset = line_length * ch_width
        print(block, x + x_offset, y + y_offset)
      end
      yield()
    end
  end

  function c_text_print(s)
    return cocreate(function()
      local i = 1
      local frame_printing = 1
      local frames_per_ch = 3
      while (i ~= #s + 1) do
        yield_print(frames_per_ch, sub(s, 1, i), 10, 30,
          frame_printing % 30 < 15)
        frame_printing = i * frames_per_ch
        i = i + 1
      end
      while (true) do
        for frame = 1, 30 do
          yield_print(1, s, 10, 30, frame < 15)
        end
      end
    end)
  end

  export("default", function(props)
    local txt = props.txt

    -- cursor as state?
    local prev_actions = use_state(function() return {c_text_print(txt)} end)

    return prev_actions
  end)
end)
