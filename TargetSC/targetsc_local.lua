-- Internal Skillchains -> TargetSC transport. Kept deliberately compatible with
-- bridge v1 frames during the first merger; no Windower command dispatch or
-- second addon state is required. Author: A.
local M={}
local receiver,source_subscribe,source_unsubscribe
function M.set_receiver(fn) receiver=fn end
function M.set_source(subscribe,unsubscribe)
    source_subscribe=subscribe
    source_unsubscribe=unsubscribe
end
function M.subscribe()
    if not source_subscribe then return false end
    source_subscribe()
    return true
end
function M.unsubscribe()
    if source_unsubscribe then source_unsubscribe() end
end
function M.send(command)
    if command=='lua c TargetSC _ready' then
        -- The combined addon subscribes once on its own load event.
        return true
    end
    local body=type(command)=='string' and command:match('^lua c TargetSC _event (.+)$')
    if not body or not receiver then return false end
    local fields={}
    for field in body:gmatch('%S+') do fields[#fields+1]=field end
    receiver(fields)
    return true
end
return M
