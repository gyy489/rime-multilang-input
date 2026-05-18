-- macOS Chinese keyboard punctuation.
-- Keep unshifted keys ASCII-friendly, while shifted symbol keys follow the
-- Chinese legends printed on Apple Chinese keyboards.
local processor = {}

local shifted_punctuation = {
    ["1"] = "！",
    ["exclam"] = "！",
    ["2"] = "＠",
    ["at"] = "＠",
    ["3"] = "＃",
    ["numbersign"] = "＃",
    ["4"] = "￥",
    ["dollar"] = "￥",
    ["5"] = "％",
    ["percent"] = "％",
    ["6"] = "……",
    ["asciicircum"] = "……",
    ["7"] = "＆",
    ["ampersand"] = "＆",
    ["8"] = "＊",
    ["asterisk"] = "＊",
    ["9"] = "（",
    ["parenleft"] = "（",
    ["0"] = "）",
    ["parenright"] = "）",
    ["minus"] = "——",
    ["underscore"] = "——",
    ["equal"] = "＋",
    ["plus"] = "＋",
    ["comma"] = "《",
    ["less"] = "《",
    ["period"] = "》",
    ["greater"] = "》",
    ["slash"] = "？",
    ["question"] = "？",
    ["semicolon"] = "：",
    ["colon"] = "：",
    ["bracketleft"] = "「",
    ["braceleft"] = "「",
    ["bracketright"] = "」",
    ["braceright"] = "」",
    ["backslash"] = "｜",
    ["bar"] = "｜",
    ["grave"] = "～",
    ["asciitilde"] = "～",
}

local shifted_pairs = {
    ["apostrophe"] = { "“", "”", "double_quote_close" },
    ["quotedbl"] = { "“", "”", "double_quote_close" },
}

function processor.func(key, env)
    local context = env.engine.context

    if
        key:release()
        or context:get_option("ascii_mode")
        or context:is_composing()
        or context:has_menu()
        or key:ctrl()
        or key:alt()
        or key:super()
    then
        return 2
    end

    local repr = key:repr():gsub("^Shift%+", "")
    if context:get_option("ascii_punct") then
        if repr == "asciitilde" then
            env.engine:commit_text("~")
            return 1
        end
        if repr == "grave" then
            env.engine:commit_text(key:shift() and "~" or "`")
            return 1
        end
        return 2
    end

    local pair = shifted_pairs[repr]
    if pair and key:shift() then
        local state_key = pair[3]
        local text = env[state_key] and pair[2] or pair[1]
        env[state_key] = not env[state_key]
        env.engine:commit_text(text)
        return 1
    end

    local text = shifted_punctuation[repr]
    if text and key:shift() then
        env.engine:commit_text(text)
        return 1
    end

    return 2
end

return processor
