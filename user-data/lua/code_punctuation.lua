-- Coding punctuation that would otherwise be consumed by the pinyin speller.
local processor = {}

local quote_pairs = {
    apostrophe = { "‘", "’", "single_quote_close" },
    quotedbl = { "“", "”", "double_quote_close" },
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
    if repr == "apostrophe" then
        if context:get_option("ascii_punct") then
            env.engine:commit_text(key:shift() and '"' or "'")
        else
            local pair = key:shift() and quote_pairs.quotedbl or quote_pairs.apostrophe
            local state_key = pair[3]
            env.engine:commit_text(env[state_key] and pair[2] or pair[1])
            env[state_key] = not env[state_key]
        end
        return 1
    end
    if repr == "quotedbl" then
        if context:get_option("ascii_punct") then
            env.engine:commit_text('"')
        else
            local pair = quote_pairs.quotedbl
            local state_key = pair[3]
            env.engine:commit_text(env[state_key] and pair[2] or pair[1])
            env[state_key] = not env[state_key]
        end
        return 1
    end

    return 2
end

return processor
