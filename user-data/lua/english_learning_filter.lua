local store = require("english_learning_store")

local M = {}

local function pass_all(input)
    for cand in input:iter() do
        yield(cand)
    end
end

local function is_exact_english(cand, key)
    return cand.text and cand.text:lower() == key and cand.text:match("^[A-Za-z]+$")
end

function M.init(env)
    store.init()

    local config = env.engine.schema.config
    M.scan_limit = config:get_int("english_learning/scan_limit") or 20
    M.promote_to_first_at = config:get_int("english_learning/promote_to_first_at") or 5
end

function M.func(input, env)
    local key = store.normalize(env.engine.context.input)
    if not key then
        pass_all(input)
        return
    end

    local count = store.get(key)
    if count <= 0 then
        pass_all(input)
        return
    end

    local head = {}
    local tail = {}
    for cand in input:iter() do
        if #head < M.scan_limit then
            table.insert(head, cand)
        else
            table.insert(tail, cand)
        end
    end

    local english_index = nil
    for i, cand in ipairs(head) do
        if is_exact_english(cand, key) then
            english_index = i
            break
        end
    end

    if english_index then
        local english_cand = table.remove(head, english_index)
        local target = count >= M.promote_to_first_at and 1 or 2
        if target > #head + 1 then
            target = #head + 1
        end
        table.insert(head, target, english_cand)
    end

    for _, cand in ipairs(head) do
        yield(cand)
    end

    for _, cand in ipairs(tail) do
        yield(cand)
    end
end

return M
