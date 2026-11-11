-- Standalone Skillchains HUD-only Umbra demonstration.
-- Same five weaponskills and source-window formulas as TargetSC Test3's demo,
-- but no native module, command transport, game packets, or combat state.
-- Author: A.
local M = {}

M.sequence = {
    {weapon=32,name='Fast Blade',property='Scission',level=0,used='Scission'},
    {weapon=19,name='Gust Slash',property='Detonation',level=1,used='Detonation'},
    {weapon=99,name='Nightmare Scythe',property='Gravitation',level=2,used='Compression'},
    {weapon=31,name="Rudra's Storm",property='Darkness',level=3,used='Distortion'},
    {weapon=109,name='Entropy (Anguta + qualifying Aeonic Aftermath)',
        property='Umbra',level=4,used='Darkness'},
}

function M.new(started)
    local stages = {}
    local previous
    for step, row in ipairs(M.sequence) do
        -- Each successive WS lands one second before the previous
        -- continuation deadline, exactly like TargetSC's Test3 preview.
        local created = previous and (previous.times - 1) or started
        local delay = created + 3
        local times = delay + 8 - step
        local from_fraction = previous and math.max(0,math.min(1,
            (previous.times-math.max(created,previous.delay))/
            math.max(.1,previous.times-previous.delay))) or .34
        stages[step] = {
            created=created,delay=delay,times=times,step=step,
            level=row.level,active={row.property},
            from_active=previous and previous.active or nil,
            from_fraction=from_fraction,closed=step==#M.sequence,
            mb_window=step>1 and created+10 or 0,
            label=row.name..' -> '..row.property..
                (step==1 and ' (opener)' or ' (L'..row.level..')'),
        }
        previous=stages[step]
    end

    local self={started=started,stages=stages,ends=previous.mb_window+.05,
        last_announced=1}
    function self:frame(now)
        if now>=self.ends then return nil,'finished' end
        local stage=stages[1]
        for i=2,#stages do
            if now>=stages[i].created then stage=stages[i] else break end
        end
        local announcement
        if stage.step~=self.last_announced then
            self.last_announced=stage.step
            announcement=stage.label
        end

        -- The final Umbra is closed; only show its preparation glow for
        -- three seconds, then leave the independent Magic Burst tail.
        -- The closed chain never advertises another continuation window.
        local closed=stage.closed and now>=stage.delay
        return {
            now=now,created=stage.created,sc_open=stage.delay,
            active=stage.active,from_active=stage.from_active,
            from_fraction=stage.from_fraction,
            step=stage.step,level=stage.level,closed=closed,
            sc_wait=math.max(0,stage.delay-now),
            sc_left=math.max(0,stage.times-math.max(now,stage.delay)),
            sc_total=math.max(.1,stage.times-stage.delay),
            mb_left=stage.step>1 and math.max(0,stage.mb_window-now) or 0,
            mb_total=10,groups={},expire_age=nil,
        },announcement
    end
    function self:status(now)
        if now>=self.ends then return 'finished' end
        local stage=stages[1]
        for i=2,#stages do
            if now>=stages[i].created then stage=stages[i] else break end
        end
        return ('%.1fs/40s; %s'):format(now-self.started,stage.label)
    end
    return self
end
return M
