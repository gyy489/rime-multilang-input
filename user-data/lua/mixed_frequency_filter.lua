-- 中文和英文各按 Rime 词频排序，再以非线性分数交错输出。
local M = {}

local function is_han(text)
    for _, codepoint in utf8.codes(text) do
        if codepoint >= 0x4e00 and codepoint <= 0x9fff then
            return true
        end
    end
    return false
end

local function language(cand)
    if cand.text:match("^[A-Za-z]+$") and cand.comment ~= "〔FR〕" then
        return "en"
    end
    if not cand.text:match("[A-Za-z]") and is_han(cand.text) then
        return "cn"
    end
    return nil
end

local function prepare_group(group, power)
    local minimum, maximum = math.huge, -math.huge
    for _, cand in ipairs(group) do
        local quality = tonumber(cand.quality) or 0
        minimum = math.min(minimum, quality)
        maximum = math.max(maximum, quality)
    end
    local range = maximum - minimum
    local scores = {}
    for rank, cand in ipairs(group) do
        local normalized = range > 0 and ((tonumber(cand.quality) or 0) - minimum) / range or 0
        scores[rank] = 1 / rank ^ power + 0.5 * normalized ^ power
    end
    return scores
end

function M.init(env)
    local config = env.engine.schema.config
    env.mixed_frequency_scan_limit = config:get_int("mixed_frequency/scan_limit") or 120
    env.mixed_frequency_power = config:get_double("mixed_frequency/power") or 1.6
    env.mixed_frequency_switch_bonus = config:get_double("mixed_frequency/switch_bonus") or 0.25
end

function M.func(input, env)
    -- 标点、日期、计算器等模式没有普通的中英文拼写候选。
    if not env.engine.context.input:match("^[A-Za-z]+$") then
        for cand in input:iter() do
            yield(cand)
        end
        return
    end

    local head, groups, slots = {}, { cn = {}, en = {} }, {}
    local iter, state, var = input:iter()
    for _ = 1, env.mixed_frequency_scan_limit do
        local cand = iter(state, var)
        if not cand then
            break
        end
        var = cand
        head[#head + 1] = cand
        local lang = language(cand)
        if lang then
            groups[lang][#groups[lang] + 1] = cand
            slots[#slots + 1] = #head
        end
    end

    if #groups.cn > 0 and #groups.en > 0 then
        local scores = {
            cn = prepare_group(groups.cn, env.mixed_frequency_power),
            en = prepare_group(groups.en, env.mixed_frequency_power),
        }
        local next_index = { cn = 1, en = 1 }
        local previous = nil
        local first_language = language(head[slots[1]])
        for _, slot in ipairs(slots) do
            local cn_score = scores.cn[next_index.cn] or -math.huge
            local en_score = scores.en[next_index.en] or -math.huge
            if previous == "en" then
                cn_score = cn_score + env.mixed_frequency_switch_bonus
            elseif previous == "cn" then
                en_score = en_score + env.mixed_frequency_switch_bonus
            end
            local lang
            if cn_score == en_score and previous == nil then
                lang = first_language
            else
                lang = cn_score >= en_score and "cn" or "en"
            end
            head[slot] = groups[lang][next_index[lang]]
            next_index[lang] = next_index[lang] + 1
            previous = lang
        end
    end

    for _, cand in ipairs(head) do
        yield(cand)
    end
    while true do
        local cand = iter(state, var)
        if not cand then
            break
        end
        var = cand
        yield(cand)
    end
end

return M
