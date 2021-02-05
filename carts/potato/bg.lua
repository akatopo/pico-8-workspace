create_module("bg", function(export)
  local use_state = import("use_state").from("hooks")

  local function c_fill_bg()
    return cocreate(function()
      while (true) do
        rectfill(0, 0, 128, 128 - text_box.height, colors["black"])
        yield()
      end
    end)
  end

  export("default", function(props)
    local prev_actions = use_state(function() return {c_fill_bg()} end)

    return prev_actions
  end)
end)
