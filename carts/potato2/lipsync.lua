create_module("lipsync", function(export)
  local sounds_normal = {
    ["a"] = potato_sprites.bottom_half[9],
    ["e"] = potato_sprites.bottom_half[9],
    ["i"] = potato_sprites.bottom_half[9],
    ["c"] = potato_sprites.bottom_half[9],
    ["d"] = potato_sprites.bottom_half[9],
    ["g"] = potato_sprites.bottom_half[9],
    ["k"] = potato_sprites.bottom_half[9],
    ["n"] = potato_sprites.bottom_half[9],
    ["s"] = potato_sprites.bottom_half[9],
    ["t"] = potato_sprites.bottom_half[9],
    ["x"] = potato_sprites.bottom_half[9],
    ["y"] = potato_sprites.bottom_half[9],
    ["z"] = potato_sprites.bottom_half[9],
    ["o"] = potato_sprites.bottom_half[6],
    ["ee"] = potato_sprites.bottom_half[9],
    ["ch"] = potato_sprites.bottom_half[1],
    ["j"] = potato_sprites.bottom_half[1],
    ["sh"] = potato_sprites.bottom_half[1],
    ["b"] = potato_sprites.bottom_half[3],
    ["m"] = potato_sprites.bottom_half[3],
    ["p"] = potato_sprites.bottom_half[3],
    ["q"] = potato_sprites.bottom_half[2],
    ["w"] = potato_sprites.bottom_half[2],
    ["oo"] = potato_sprites.bottom_half[2],
    ["r"] = potato_sprites.bottom_half[1],
    ["l"] = potato_sprites.bottom_half[9],
    ["th"] = potato_sprites.bottom_half[9],
    ["f"] = potato_sprites.bottom_half[1],
    ["v"] = potato_sprites.bottom_half[1],
  }

  local sounds_masked = {
    ["a"] = potato_sprites.bottom_half[10],
    ["e"] = potato_sprites.bottom_half[10],
    ["i"] = potato_sprites.bottom_half[10],
    ["c"] = potato_sprites.bottom_half[10],
    ["d"] = potato_sprites.bottom_half[10],
    ["g"] = potato_sprites.bottom_half[10],
    ["k"] = potato_sprites.bottom_half[10],
    ["n"] = potato_sprites.bottom_half[10],
    ["s"] = potato_sprites.bottom_half[10],
    ["t"] = potato_sprites.bottom_half[10],
    ["x"] = potato_sprites.bottom_half[10],
    ["y"] = potato_sprites.bottom_half[10],
    ["z"] = potato_sprites.bottom_half[10],
    ["o"] = potato_sprites.bottom_half[11],
    ["ee"] = potato_sprites.bottom_half[10],
    ["ch"] = potato_sprites.bottom_half[11],
    ["j"] = potato_sprites.bottom_half[11],
    ["sh"] = potato_sprites.bottom_half[11],
    ["b"] = potato_sprites.bottom_half[11],
    ["m"] = potato_sprites.bottom_half[11],
    ["p"] = potato_sprites.bottom_half[11],
    ["q"] = potato_sprites.bottom_half[11],
    ["w"] = potato_sprites.bottom_half[11],
    ["oo"] = potato_sprites.bottom_half[11],
    ["r"] = potato_sprites.bottom_half[11],
    ["l"] = potato_sprites.bottom_half[10],
    ["th"] = potato_sprites.bottom_half[10],
    ["f"] = potato_sprites.bottom_half[11],
    ["v"] = potato_sprites.bottom_half[11],
  }

  export("parse", function(s, mouth)
    local sounds = mouth == "talking_masked" and sounds_masked or sounds_normal
    local two_letter_sound_sprite_coords = nil
    local res = {}
    for i = 1, #s do
      if (two_letter_sound_sprite_coords) then
        res[i] = two_letter_sound_sprite_coords
        two_letter_sound_sprite_coords = nil
      else
        local lookahead = i < #s and sub(s, i + 1, i + 1) or nil
        local sprite_coords
        local c = sub(s, i, i)
        if (lookahead and sounds[c .. lookahead]) then
          sprite_coords = sounds[c .. lookahead]
          two_letter_sound_sprite_coords = sprite_coords
        else
          sprite_coords = sounds[c] or sounds["j"]
        end
        res[i] = sprite_coords
      end
    end

    return res
  end)
end)
