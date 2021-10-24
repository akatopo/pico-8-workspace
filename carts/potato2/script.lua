create_module("script", function(export)
  local function apply_to_path(o)
    return function(s)
      return assign({}, o, (type(s) == "string" and {text = s} or s))
    end
  end

  local create_masked_text = apply_to_path({
    mouth = "talking_masked",
    mouth_reaction = "masked",
  })

  local create_outrage_text = apply_to_path({
    mouth_reaction = "neutral",
    eyes_reaction = "angry",
  })

  local mask_gag = map({
    --[[
-- 3456789012345678903456789012
--]]
    [[
why am i masked when no one
is here?]], [[
huh . . .
good question!]], {
      text = "lets remove this then",
      mouth_reaction = "smiling",
      eyes_reaction = "happy",
    },
  }, create_masked_text)

  local script = {
    --[[
-- 3456789012345678903456789012
--]]
    {
      text = [[
well, hello there!]],
    }, {
      {path = mask_gag, choice = "choice 1"}, {
        path = {
          [[choice2]], {
            {path = {[[done 1]]}, choice = "2a longer choice"},
            {path = {[[done 2]]}, choice = "2hoice 2"},
            {path = {[[done 3]]}, choice = "2hoice 3!"},
          },
        },
        choice = "choice 2",
      },
    },
  }

  local outrage = map({
    [[who did that!?]], [[not funny!
i'm over 30 . . .
in potato years]], [[i'll make sure to give a
good spanking to whoever
did this!]], {
      text = "with that being said . . .",
      mouth_reaction = "open",
      eyes_reaction = "blink",
    },
  }, create_outrage_text)

  local intro = map({
    [[hello!
mr potato nugget here!]],
    {text = [[did you miiiiiiss meeee?]], eyes_reaction = "happy"},
    [[everything's mighty fine
here]], [[as you can see the place
got an upgrade]], [[you can even rotate the
terrain now!]], [[try pressing ⬅️ ➡️ ⬆️ ⬇️ to
try it out]], {
      text = [[is it useful? no.
is it cool? you bet!]],
      eyes_reaction = "happy",
    }, [[why am i masked when no one
is here?]], [[
huh . . .
good question!]], {
      text = "lets remove this then",
      mouth_reaction = "smiling",
      eyes_reaction = "happy",
    },
  }, create_masked_text)

  local gifts_5 = {
    {
      text = "it's related to c a t s",
      mouth_reaction = "open",
      eyes_reaction = "happy",
    }, "with that being said . . .",
  }

  local gifts_4 = {
    [[nope. good try though]], [[do you want a hint about
the gift?]], {
      {path = gifts_5, choice = "yes"}, {
        path = {
          [[you sure?]], {
            {path = gifts_5, choice = "please tell me"}, {
              path = concat({
                {text = "i'm telling you anyway", mouth_reaction = "smiling"},
              }, gifts_5),
              choice = "pretty sure",
            },
          },
        },
        choice = "no",
      },
    },
  }

  local gifts_3 = {
    {text = [[YOUR GIFT HAS NOT ARRIVED YET]], eyes_reaction = "sweat"},
    [[but!]], {
      text = [[look under your table for a
little surprise]],
      eyes_reaction = "happy",
      mouth_reaction = "smiling",
    }, {
      text = [[hope you like it!
i'd like some but i'm kind
of trapped here]],
      eyes_reaction = "neutral",
      mouth_reaction = "neutral",
    }, [[now about the actual gift]], [[yup]],
    {text = [[stuck in customs]], eyes_reaction = "sweat"},
    [[wanna guess where it is?]], {
      {path = gifts_4, choice = "kathmandu"},
      {path = gifts_4, choice = "ottawa"}, {path = gifts_4, choice = "paris"},
    },
  }

  local gifts_2 = {
    [[well . . .
ok then]], [[see the thing is . . .]], {
      {path = gifts_3, choice = "really?"}, {path = gifts_3, choice = "again?"},
      {path = gifts_3, choice = "come on!"},
    },
  }

  local gifts = {
    [[what? you want me to get to
the gifts?]], {
      {path = gifts_2, choice = "yes"}, {path = gifts_2, choice = "oui"},
      {path = gifts_2, choice = "yeah!"},
    },
  }

  export("default", concat(intro, gifts))
end)

