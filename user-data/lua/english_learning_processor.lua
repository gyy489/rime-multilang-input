local store = require("english_learning_store")

local processor = {}

function processor.init(env)
    store.init()
    store.configure(env.engine.schema.config)
end

function processor.fini()
    store.flush()
end

function processor.func(key, env)
    local context = env.engine.context
    local repr = key:repr()

    if
        key:release()
        or key:ctrl()
        or key:alt()
        or key:super()
        or (repr ~= "Return" and repr ~= "KP_Enter")
        or not context:is_composing()
    then
        return 2
    end

    local raw_input = context.input
    if not store.normalize(raw_input) then
        return 2
    end

    store.increment(raw_input)
    env.engine:commit_text(raw_input)
    context:clear()
    context.commit_history:push("english_learning", raw_input)
    return 1
end

return processor
