local processor = {}

local function shifted_letter(key)
    local repr = key:repr():gsub("^Shift%+", "")
    if key:shift() and repr:match("^%a$") then
        return repr:upper()
    end

    if repr:match("^%u$") then
        return repr:upper()
    end

    return nil
end

function processor.func(key, env)
    local context = env.engine.context

    if
        key:release()
        or key:ctrl()
        or key:alt()
        or key:super()
    then
        return 2
    end

    local letter = shifted_letter(key)
    if not letter then
        return 2
    end

    local input = context.input or ""
    if (context:is_composing() or context:has_menu()) and not input:match("^%u+$") then
        return 2
    end

    if input:match("^%u+$") then
        letter = input .. letter
        context:clear()
    end

    env.engine:commit_text(letter)
    return 1
end

return processor
