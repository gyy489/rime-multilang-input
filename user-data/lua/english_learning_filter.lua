local store = require("english_learning_store")

local M = {}

local function pass_all(input)
    for cand in input:iter() do
        yield(cand)
    end
end

local function candidate_iter(input)
    local iter, state, var = input:iter()
    return function()
        local cand = iter(state, var)
        var = cand
        return cand
    end
end

local function is_exact_english(cand, key)
    return cand.text and cand.text:lower() == key and cand.text:match("^[A-Za-z]+$")
end

function M.init(env)
    store.init()

    local config = env.engine.schema.config
    store.configure(config)
    M.scan_limit = config:get_int("english_learning/scan_limit") or 20
    M.promote_to_first_at = config:get_int("english_learning/promote_to_first_at") or 5
end

function M.fini()
    store.flush()
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
    local iter = candidate_iter(input)
    for _ = 1, M.scan_limit do
        local cand = iter()
        if not cand then
            break
        end
        table.insert(head, cand)
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

    while true do
        local cand = iter()
        if not cand then
            break
        end
        yield(cand)
    end
end

return M
