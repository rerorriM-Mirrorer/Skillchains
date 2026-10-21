--[[
Copyright © 2017, Ivaar
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright
  notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.
* Neither the name of SkillChains nor the
  names of its contributors may be used to endorse or promote products
  derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL IVAAR BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
_addon.author = 'Ivaar'
_addon.command = 'sc'
_addon.name = 'SkillChains'
_addon.version = '2.20.08.25-resonance.7-animation.8.8'

require('luau')
require('pack')
require('actions')
texts = require('texts')
skills = require('skills')
local resonance_view = require('resonance_ui')
local skillchains_demo = require('skillchains_demo')
local chat = require('chat') -- Provides string:color for BattleStations-style help.

_static = S{'WAR','MNK','WHM','BLM','RDM','THF','PLD','DRK','BST','BRD','RNG','SAM','NIN','DRG','SMN','BLU','COR','PUP','DNC','SCH','GEO','RUN'}

default = {}
default.Show = {burst=_static, pet=S{'BST','SMN'}, props=_static, spell=S{'SCH','BLU'}, step=_static, timer=_static, weapon=_static}
default.UpdateFrequency = 0.2
default.aeonic = false
default.color = false
default.display = {text={size=12,font='Consolas'},pos={x=0,y=0},bg={visible=true}}
-- The UI is independent of EnemyBar2. The initial position suits a small
-- client; //sc edit can relocate the bar and learning panel separately.
default.Resonance = {
    mode='learn', display='sc', names='full', scale=1, grid=10,
    animation={enabled=true,intensity=2.0,flare=2.0,glow=2.0,fade=false,fade_period=1/2.4},
    -- Rails + rounded ends share color/flicker. Tier mask defaults to L3/4.
    -- Strengths are multipliers, with no artificial upper bound. Actual
    -- Windower alpha ultimately saturates at 255.
    -- Do not type a numeric-looking level mask in Windower defaults.
    -- Its XML reader turns string '34' into number 34 on every fresh load.
    -- Keep legacy masks and use a textual key for newly saved changes.
    glow={rail12=.30,cap12=.35,rail34=.75,cap34=.85,
          level1=1,level2=.70,level3=1,level4=1,
          pre12=.18,pre2=.85,pre3=.38,pre4=.85,scale=1,l4='gold'},
    -- RGB controls the hue; alpha sets how much game scenery shows through.
    track={alpha=155,color={6,8,17}},
    transition={duration=.30,style='energized'},
    tip={enabled=true,length=16,opacity=.85},
    mb={position='below',gap=3,height=2,text='on',icon='on',
        scale=1,fontsize=10,iconsize=10,flash='on',flash_duration=.24},
    -- Text offsets are relative to the SC bar, not absolute screen coordinates.
    name_offset={x=5,y=-9},
    -- Additional positioning applies only to SC property icons.
    icon_offset={x=0,y=0},
    bar={x=466,y=696,width=310},
    list={x=465,y=300},
}

settings = config.load(default)
-- The original full-text window is superseded by resonance_ui.lua.
-- Existing settings.display is retained for migration compatibility.
message_ids = S{110,185,187,317,802}
skillchain_ids = S{288,289,290,291,292,293,294,295,296,297,298,299,300,301,385,386,387,388,389,390,391,392,393,394,395,396,397,767,768,769,770}
buff_dur = {[163]=40,[164]=30,[470]=60}
info = {}
resonating = {}
buffs = {}

colors = {}            -- Color codes by Sammeh
colors.Light =         '\\cs(255,255,255)'
colors.Dark =          '\\cs(0,0,204)'
colors.Ice =           '\\cs(0,255,255)'
colors.Water =         '\\cs(0,0,255)'
colors.Earth =         '\\cs(153,76,0)'
colors.Wind =          '\\cs(102,255,102)'
colors.Fire =          '\\cs(255,0,0)'
colors.Lightning =     '\\cs(255,0,255)'
colors.Gravitation =   '\\cs(102,51,0)'
colors.Fragmentation = '\\cs(250,156,247)'
colors.Fusion =        '\\cs(255,102,102)'
colors.Distortion =    '\\cs(51,153,255)'
colors.Darkness =      colors.Dark
colors.Umbra =         colors.Dark
colors.Compression =   colors.Dark
colors.Radiance =      colors.Light
colors.Transfixion =   colors.Light
colors.Induration =    colors.Ice
colors.Reverberation = colors.Water
colors.Scission =      colors.Earth
colors.Detonation =    colors.Wind
colors.Liquefaction =  colors.Fire
colors.Impaction =     colors.Lightning

skillchains = {'Light','Darkness','Gravitation','Fragmentation','Distortion','Fusion','Compression','Liquefaction','Induration','Reverberation','Transfixion','Scission','Detonation','Impaction','Radiance','Umbra'}

sc_info = {
    Radiance = {'Fire','Wind','Lightning','Light', lvl=4},
    Umbra = {'Earth','Ice','Water','Dark', lvl=4},
    Light = {'Fire','Wind','Lightning','Light', Light={4,'Light','Radiance'}, lvl=3},
    Darkness = {'Earth','Ice','Water','Dark', Darkness={4,'Darkness','Umbra'}, lvl=3},
    Gravitation = {'Earth','Dark', Distortion={3,'Darkness'}, Fragmentation={2,'Fragmentation'}, lvl=2},
    Fragmentation = {'Wind','Lightning', Fusion={3,'Light'}, Distortion={2,'Distortion'}, lvl=2},
    Distortion = {'Ice','Water', Gravitation={3,'Darkness'}, Fusion={2,'Fusion'}, lvl=2},
    Fusion = {'Fire','Light', Fragmentation={3,'Light'}, Gravitation={2,'Gravitation'}, lvl=2},
    Compression = {'Darkness', Transfixion={1,'Transfixion'}, Detonation={1,'Detonation'}, lvl=1},
    Liquefaction = {'Fire', Impaction={2,'Fusion'}, Scission={1,'Scission'}, lvl=1},
    Induration = {'Ice', Reverberation={2,'Fragmentation'}, Compression={1,'Compression'}, Impaction={1,'Impaction'}, lvl=1},
    Reverberation = {'Water', Induration={1,'Induration'}, Impaction={1,'Impaction'}, lvl=1},
    Transfixion = {'Light', Scission={2,'Distortion'}, Reverberation={1,'Reverberation'}, Compression={1,'Compression'}, lvl=1},
    Scission = {'Earth', Liquefaction={1,'Liquefaction'}, Reverberation={1,'Reverberation'}, Detonation={1,'Detonation'}, lvl=1},
    Detonation = {'Wind', Compression={2,'Gravitation'}, Scission={1,'Scission'}, lvl=1},
    Impaction = {'Lightning', Liquefaction={1,'Liquefaction'}, Detonation={1,'Detonation'}, lvl=1},
}

-- Optional companion publisher; the existing UI and timing remain authoritative.
local targetsc = require('targetsc_bridge').new(sc_info, res, windower.send_command)

chainbound = {}
chainbound[1] = L{'Compression','Liquefaction','Induration','Reverberation','Scission'}
chainbound[2] = L{'Gravitation','Fragmentation','Distortion'} + chainbound[1]
chainbound[3] = L{'Light','Darkness'} + chainbound[2]

local aeonic_weapon = {
    [20515] = 'Godhands',
    [20594] = 'Aeneas',
    [20695] = 'Sequence',
    [20843] = 'Chango',
    [20890] = 'Anguta',
    [20935] = 'Trishula',
    [20977] = 'Heishi Shorinken',
    [21025] = 'Dojikiri Yasutsuna',
    [21082] = 'Tishtrya',
    [21147] = 'Khatvanga',
    [21485] = 'Fomalhaut',
    [21694] = 'Lionheart',
    [21753] = 'Tri-edge',
    [22117] = 'Fail-Not',
    [22131] = 'Fail-Not',
    [22143] = 'Fomalhaut'
}

-- Previously, a long text object was constructed on every configuration reload.
-- The new renderer owns its own independently draggable bar and learning panel.
local overlay = resonance_view.new(settings.Resonance, sc_info)

local function ensure_player()
    if not windower.ffxi.get_info().logged_in then return false end
    local player = windower.ffxi.get_player()
    if not player then return false end
    info.job, info.player = player.main_job, player.id
    buffs[info.player] = buffs[info.player] or {}
    return true
end

function update_weapon()
    if not settings.Show.weapon[info.job] then
        return
    end
    -- Gear data may not yet be populated when an addon is loaded or reloaded.
    -- Preserve upstream's guarded lookup instead of indexing a missing item.
    local main=info.main_bag and info.main_weapon and
        windower.ffxi.get_items(info.main_bag,info.main_weapon)
    local main_weapon=main and main.id or 0
    if main_weapon ~= 0 then
        local ranged=info.range_bag and info.range and
            windower.ffxi.get_items(info.range_bag,info.range)
        info.aeonic=aeonic_weapon[main_weapon] or
            (ranged and aeonic_weapon[ranged.id])
        return
    end
    if not check_weapon or coroutine.status(check_weapon) ~= 'suspended' then
        check_weapon = coroutine.schedule(update_weapon, 10)
    end
end

function aeonic_am(step)
    for x=270,272 do
        if buffs[info.player][x] then
            return 272-x < step
        end
    end
    return false
end

function aeonic_prop(ability, actor)
    if ability.aeonic and (ability.weapon == info.aeonic and actor == info.player or settings.aeonic and info.player ~= actor) then
        return {ability.skillchain[1], ability.skillchain[2], ability.aeonic}
    end
    return ability.skillchain
end

function check_props(old, new)
    for k = 1, #old do
        local first = old[k]
        local combo = sc_info[first]
        for i = 1, #new do
            local second = new[i]
            local result = combo[second]
            if result then
                return unpack(result)
            end
            if #old > 3 and combo.lvl == sc_info[second].lvl then
                break
            end
        end
    end
end

-- Group all *learned* compatible actions by resulting skillchain, rather
-- than imposing a fixed number of suggestions. TP/recast readiness is not
-- checked; this teaches properties, not immediate execution availability.
function check_results(reson)
    local by_key = {}
    local all = {}
    local function append(abilities, resource, am)
        if not abilities or not skills[resource] then return end
        for _,id in ipairs(abilities) do
            local ability = skills[resource][id]
            if ability then
                local props = aeonic_prop(ability, info.player)
                local level, prop, aeonic = check_props(reson.active, props)
                if prop then
                    local result = (am and aeonic) or prop
                    local key = tostring(level)..':'..result
                    local group = by_key[key]
                    if not group then
                        group={level=level, property=result, actions={}}
                        by_key[key]=group
                        all[#all+1]=group
                    end
                    local via
                    -- Identify the property that actually completed this chain.
                    for _,first in ipairs(reson.active) do
                        local options=sc_info[first]
                        if options then
                            for _,second in ipairs(props) do
                                if options[second] and (options[second][2]==prop or
                                    options[second][3]==result) then
                                    via=second
                                    break
                                end
                            end
                        end
                        if via then break end
                    end
                    local label=res[resource] and res[resource][id]
                    group.actions[#group.actions+1]={
                        name=label and label.name or ability.en or tostring(id),
                        via=via or table.concat(props,'/'),
                        -- Retain every inherent property for the right-aligned
                        -- icon column; result detection still chooses one
                        -- actual expected skillchain per action.
                        properties=props,
                    }
                end
            end
        end
    end

    if settings.Show.spell[info.job] and info.job == 'SCH' then
        append({0,1,2,3,4,5,6,7},'elements')
    elseif settings.Show.spell[info.job] and info.job == 'BLU' then
        local mjob = windower.ffxi.get_mjob_data()
        append(mjob and mjob.spells,'spells')
    elseif settings.Show.pet[info.job] and windower.ffxi.get_mob_by_target('pet') then
        local abilities=windower.ffxi.get_abilities()
        append(abilities and abilities.job_abilities,'job_abilities')
    end
    if settings.Show.weapon[info.job] then
        local abilities=windower.ffxi.get_abilities()
        append(abilities and abilities.weapon_skills,'weapon_skills',
            info.aeonic and aeonic_am(reson.step))
    end
    table.sort(all,function(left,right)
        if left.level ~= right.level then return left.level > right.level end
        return left.property < right.property
    end)
    for _,group in ipairs(all) do
        table.sort(group.actions,function(left,right) return left.name < right.name end)
    end
    return all
end

function colorize(t)
    local temp
    if settings.color then
        temp = {}
        for k=1,#t do
            temp[k] = ('%s%s\\cr'):format(colors[t[k]], t[k])
        end
    end
    return _raw.table.concat(temp or t, ',')
end

local next_frame = os.clock()
-- Visual preview never publishes any TargetSC events or acts on FFXI.
local animation_preview=nil
local hud_demo=nil
local message -- Forward declaration: the prerender demo reports each milestone.
local function preview_state(now)
    if not animation_preview then return nil end
    local p=animation_preview
    if now>p.ends then animation_preview=nil;return nil end
    local total=math.max(.1,p.times-p.delay)
    return {
        now=now,created=p.created,sc_open=p.delay,
        active=p.active,from_active={'Liquefaction'},step=p.step,level=p.level,closed=p.closed,
        sc_wait=math.max(0,p.delay-now),
        sc_left=math.max(0,p.times-math.max(now,p.delay)),
        sc_total=total,mb_left=p.step>1 and math.max(0,p.created+10-now) or 0,
        mb_total=10,groups={},
        from_fraction=.34,
        expire_age=p.step==1 and now>p.times and now-p.times or nil
    }
end

windower.register_event('prerender', function()
    local now=os.clock()
    if now < next_frame then return end
    -- Previous 0.1s updates made the countdown visibly step between pixels.
    -- The remaining width comes from absolute expiry timestamps; at ~30Hz
    -- it glides during the same window, yet resets immediately on a new WS.
    next_frame=now+(1/30)
    for id,state in pairs(resonating) do
        -- Do not remove a completed chain while its MB window is active.
        if math.max(state.times,state.mb_window or 0) + 1 < now then
            targetsc:expire(id)
            resonating[id]=nil
        end
    end
    if not ensure_player() then overlay:render(nil) return end
    if hud_demo then
        local state,stage=hud_demo:frame(now)
        if stage=='finished' then
            hud_demo=nil
        elseif state then
            if stage then message('Demo: '..stage) end
            overlay:render(state)
            return
        end
    end
    local simulated=preview_state(now)
    if simulated then overlay:render(simulated);return end
    local target=windower.ffxi.get_mob_by_target('t','bt')
    local reson=target and resonating[target.id]
    if not target or target.hpp<=0 or not reson then
        overlay:render(nil)
        return
    end
    -- The opening weapon skill's animation is a WAIT for the real SC window.
    -- The displayed bar remains at 100% during that wait; do not spend its
    -- continuation countdown before the ability's reported delay elapses.
    local sc_wait=math.max(0,reson.delay-now)
    local sc_left=math.max(0,reson.times-math.max(now,reson.delay))
    local mb_left=math.max(0,(reson.mb_window or 0)-now)
    local expire_age=reson.step==1 and now>reson.times and now-reson.times or nil
    if sc_left<=0 and mb_left<=0 and
        not (expire_age and expire_age<.35) then
        overlay:render(nil)
        return
    end
    if not reson.groups and sc_left>0 and not reson.closed then
        reson.groups=check_results(reson)
    end
    overlay:render({
        active=reson.active,step=reson.step,closed=reson.closed,
        level=reson.result_level or 0,now=now,created=reson.created,
        sc_open=reson.delay,from_fraction=reson.from_fraction,
        from_active=reson.from_active,
        sc_left=sc_left,sc_wait=sc_wait,expire_age=expire_age,
        sc_total=math.max(.1,reson.times-reson.delay),
        mb_left=mb_left,mb_total=10,groups=reson.groups,
    })
end)

function check_buff(t, i)
    if t[i] == true or t[i] - os.time() > 0 then
        return true
    end
    t[i] = nil
end

function chain_buff(t)
    local i = t[164] and 164 or t[470] and 470
    if i and check_buff(t, i) then
        t[i] = nil
        return true
    end
    return t[163] and check_buff(t, 163)
end

categories = S{
    'weaponskill_finish',
    'spell_finish',
    'job_ability',
    'mob_tp_finish',
    'avatar_tp_finish',
    'job_ability_unblinkable',
}

function apply_properties(target, resource, action_id, properties, delay, step, closed, bound, result_level)
    local clock = os.clock()
    local previous=resonating[target]
    local from_fraction=previous and math.max(0,math.min(1,
        (previous.times-math.max(clock,previous.delay))/
        math.max(.1,previous.times-previous.delay))) or .4
    resonating[target] = {
        created=clock,from_fraction=from_fraction,
        from_active=previous and previous.active or nil,
        res=resource,
        id=action_id,
        active=properties,
        delay=clock+delay,
        times=clock+delay+8-step,
        -- Burst is possible only after a real chain result, not after its opener.
        -- Keep this clock independent of the next skillchain step's delay.
        mb_window=step>1 and clock+10 or 0,
        step=step,
        closed=closed,
        bound=bound,
        result_level=result_level, -- Publish the already resolved aeonic tier.
    }
    targetsc:state(target,resonating[target])
    if target == targ_id then
        next_frame = clock
    end
end

function action_handler(act)
    targetsc:bursts(act)
    local actionpacket = ActionPacket.new(act)
    local category = actionpacket:get_category_string()

    if not categories:contains(category) or act.param == 0 then
        return
    end

    local actor = actionpacket:get_id()
    local target = actionpacket:get_targets()()
    local action = target:get_actions()()
    local message_id = action:get_message_id()
    local add_effect = action:get_add_effect()
    --local basic_info = action:get_basic_info()
    local param, resource, action_id, interruption, conclusion = action:get_spell()
    local ability = skills[resource] and skills[resource][action_id]

    if add_effect and conclusion and skillchain_ids:contains(add_effect.message_id) then
        local skillchain = add_effect.animation:ucfirst()
        local level = sc_info[skillchain].lvl
        local reson = resonating[target.id]
        local delay = ability and ability.delay or 3
        local step = (reson and reson.step or 1) + 1

        if level == 3 and reson and ability then
            level = check_props(reson.active, aeonic_prop(ability, actor))
        end

        local closed = step > 5 or level == 4

        apply_properties(target.id, resource, action_id, {skillchain}, delay, step, closed, nil, level)
    elseif ability and (message_ids:contains(message_id) or message_id == 2 and buffs[actor] and chain_buff(buffs[actor])) then
        apply_properties(target.id, resource, action_id, aeonic_prop(ability, actor), ability.delay or 3, 1)
    elseif message_id == 529 then
        apply_properties(target.id, resource, action_id, chainbound[param], 2, 1, false, param)
    elseif message_id == 100 and buff_dur[param] then
        buffs[actor] = buffs[actor] or {}
        buffs[actor][param] = buff_dur[param] + os.time()
    end
end

ActionPacket.open_listener(action_handler)

windower.register_event('incoming chunk', function(id, data)
    if id == 0x29 and data:unpack('H', 25) == 206 and data:unpack('I', 9) == info.player then
        buffs[info.player][data:unpack('H', 13)] = nil
    elseif id == 0x50 and data:byte(6) == 0 then
        info.main_weapon = data:byte(5)
        info.main_bag = data:byte(7)
        update_weapon()
    elseif id == 0x50 and data:byte(6) == 2 then
        info.range = data:byte(5)
        info.range_bag = data:byte(7)
        update_weapon()
    elseif id == 0x63 and data:byte(5) == 9 then
        local set_buff = {}
        for n=1,32 do
            local buff = data:unpack('H', n*2+7)
            if buff_dur[buff] or buff > 269 and buff < 273 then
                set_buff[buff] = true
            end
        end
        buffs[info.player] = set_buff
    end
end)

message = function(str)
    windower.add_to_chat(207,'Skillchains: '..str)
end

local function finite_nonnegative(s)
    local n=tonumber(s)
    if not n or n~=n or n==math.huge or n==-math.huge or n<0 then
        return nil
    end
    return n
end

local function glow_levels(g)
    return tostring(g.level_mask or g.levels or 'L2,L3,L4')
end

local function glow_setting(opts,key,value)
    local numeric=finite_nonnegative(value)
    local defaults=default.Resonance.glow
    if not numeric then
        message(('Glow %s %.3f (default %.3f). Use //sc glow %s <number >= 0>.'):format(
            key,opts.glow[key] or defaults[key],defaults[key],key))
        return
    end
    opts.glow[key]=numeric
    config.save(settings)
    message(('Glow %s %.3f (default %.3f; alpha saturates at 255).'):format(
        key,numeric,defaults[key]))
end

-- BattleStations convention: chat-only syntax, actionable examples,
-- colored sections and deterministic order. Never mirror help to console.
local function show_help()
    local function heading(value)
        windower.add_to_chat(0,('Skillchains  /  '..value):color(167))
    end
    local function line(syntax,description)
        windower.add_to_chat(0,('//sc '):color(200)..syntax:color(207)
            ..(' -> '):color(200)..description:color(0))
    end
    windower.add_to_chat(0,('-----------------------------------'):color(140))
    heading('Resonance HUD')
    line('status','Version, display, mode and positions')
    line('demo [start|status|off]','Local five-stage Umbra HUD preview')
    line('display sc|mb|both','Select independent SC and MB opportunities')
    line('mode learn|compact|minimal','Choose learning suggestions or small labels')
    line('names full|short|off','SC result labels')
    line('names offset <x> <y>','Move SC labels and icons together')
    line('icons offset <x> <y>','Move SC property icons independently')
    heading('Effects')
    line('tip on|off','Toggle moving bright SC endpoint')
    line('tip length <8-40>','Set ghostflare length in base UI pixels')
    line('tip opacity <0-1>','Set ghostflare brightness')
    line('mb pos <x> <y>','Move independent MB anchor in screen pixels')
    line('mb position above|below','Align MB once relative to SC')
    line('mb center','Recover MB ribbon near screen center')
    line('mb width <40-1600>','Independent MB ribbon width')
    line('mb scale <0.5-2.5>','Independent MB ribbon and icon scale')
    line('mb gap <0-32>','MB alignment spacing for above/below')
    line('mb height <1-6>','MB ribbon thickness')
    line('mb fontsize <6-24>','Independent MB caption text size')
    line('mb iconsize <6-32>','Independent MB property icon size')
    line('mb text on|off','Show/hide MB timer text')
    line('mb icon on|off','Show/hide MB property icon')
    line('mb flash on|off','Flash MB white at new/replaced window')
    line('mb flash duration <0.05-1>','White introduction duration')
    line('anim on|off','Enable/disable animated bar effects')
    line('anim fade on|off','Toggle SC countdown opacity pulse')
    line('anim fade period <seconds>','Set SC pulse rhythm (e.g. 0.24)')
    line('anim preview opener|level1|level2|level3|level4|umbra|radiance|off',
         'Preview local visuals without sending game actions')
    line('glow levels 1234|234|off','Choose enabled border-glow levels')
    line('glow level1|level2|level3|level4 <number>','Per-level glow strength')
    line('glow pre2|pre4 <number>','Pre-window glow strength')
    line('glow rail34|cap34 <number>','Bright-tier halo rail / cap power')
    line('glow l4 gold|whitegold|white','Terminal border palette')
    line('transition <seconds>','Window-opening color transition')
    heading('Layout and lifecycle')
    line('edit on|off','Drag SC, MB and Learning handles; Ctrl snaps')
    line('scale <0.5-2.5>|edit','Scale HUD or edit scaling interactively')
    line('grid <pixels>','Ctrl-drag grid spacing')
    line('pos <x> <y>','Position SC bar only')
    line('width <pixels>','Width of SC bar only')
    line('center','Recover HUD on screen')
    line('save [all]','Save settings')
    line('restart|unload','Reload or unload Skillchains')
    line('help','Show this guide')
    windower.add_to_chat(0,('-----------------------------------'):color(140))
end

-- Read modifiers without intercepting normal keyboard/controller input.
-- Either Ctrl key can request snap while existing draggable text moves.
windower.register_event('keyboard', function(dik, down)
    if dik==29 or dik==157 then overlay:set_ctrl(dik,down) end
end)

windower.register_event('addon command', function(cmd, ...)
    cmd=(cmd or 'help'):lower()
    local args={...}
    local option=args[1] and args[1]:lower()
    local opts=settings.Resonance
    if cmd=='targetsc' then
        if option=='subscribe' then targetsc:subscribe(resonating)
        elseif option=='unsubscribe' then targetsc.subscribed=false
        else message(('TargetSC bridge v1: subscribed=%s, events=%d, send failures=%d'):format(
            tostring(targetsc.subscribed),targetsc.sequence,targetsc.failures)) end
        return
    elseif cmd=='demo' then
        if option=='off' then
            hud_demo=nil
            overlay:hide()
            message('Umbra HUD demo stopped; normal tracking restored.')
        elseif option=='status' then
            message(hud_demo and ('Umbra HUD demo: '..hud_demo:status(os.clock()))
                or 'Umbra HUD demo idle. Use //sc demo.')
        elseif not option or option=='start' then
            animation_preview=nil
            hud_demo=skillchains_demo.new(os.clock())
            next_frame=os.clock()
            message('Umbra HUD demo: Fast Blade -> Scission (opener).')
            message('Gust Slash 9s; Nightmare Scythe 17s; Rudra\'s Storm 24s; Entropy 30s; MB ends 40s. No game actions or TargetSC events.')
        else
            message('Use //sc demo [start|status|off].')
        end
        return
    elseif cmd=='tip' then
        opts.tip=opts.tip or {enabled=true,length=16,opacity=.85}
        local t=opts.tip
        if option=='on' or option=='off' then
            t.enabled=(option=='on')
        elseif option=='length' or option=='opacity' then
            local v=finite_nonnegative(args[2])
            local hi=option=='length' and 40 or 1
            local lo=option=='length' and 8 or 0
            if not v or v<lo or v>hi then
                message(('Use //sc tip %s <%.2f-%.2f>.'):format(option,lo,hi))
                return
            end
            t[option]=v
        else
            message(('SC ghost tip %s; length %.1f, opacity %.2f.'):format(
                t.enabled~=false and 'on' or 'off',t.length or 16,t.opacity or .85))
            return
        end
        config.save(settings)
        message(('SC ghost tip %s; length %.1f, opacity %.2f.'):format(
            t.enabled~=false and 'on' or 'off',t.length or 16,t.opacity or .85))
    elseif cmd=='mb' then
        opts.mb=opts.mb or {}
        local m=opts.mb
        if option=='pos' then
            local x,y=finite_nonnegative(args[2]),finite_nonnegative(args[3])
            if not x or not y then
                message(('MB position %d, %d. Use //sc mb pos <x> <y>.'):format(m.x,m.y))
                return
            end
            overlay:set_mb_position(x,y)
        elseif option=='center' then
            local v=windower.get_windower_settings() or {}
            local w,h=v.ui_x_res or v.x_res or 1280,v.ui_y_res or v.y_res or 720
            overlay:set_mb_position(math.floor((w-(m.width or opts.bar.width))/2),
                math.floor(h*.72))
        elseif option=='position' then
            local v=(args[2] or ''):lower()
            if v~='above' and v~='below' then
                message('Use //sc mb position above|below.')
                return
            end
            overlay:mb_align(v)
        elseif option=='gap' or option=='height' or option=='width'
            or option=='scale' or option=='fontsize' or option=='iconsize' then
            local v=finite_nonnegative(args[2])
            local limits={
                gap={0,32},height={1,6},width={40,1600},
                scale={.5,2.5},fontsize={6,24},iconsize={6,32}
            }
            local lo,hi=limits[option][1],limits[option][2]
            if not v or v<lo or v>hi then
                message(('Use //sc mb %s <%.1f-%.1f>.'):format(option,lo,hi))
                return
            end
            m[option]=v
            -- Gap means a one-time alignment adjustment; manually
            -- positioned MB widgets remain independent afterward.
            if option=='gap' and m.position~='custom' then
                overlay:mb_align(m.position or 'below')
            end
        elseif option=='flash' and (args[2] or ''):lower()=='duration' then
            local value=finite_nonnegative(args[3])
            if not value or value<.05 or value>1 then
                message('Use //sc mb flash duration <0.05-1>.')
                return
            end
            m.flash_duration=value
        elseif option=='text' or option=='icon' or option=='flash' then
            local value=(args[2] or ''):lower()
            if value~='on' and value~='off' then
                message('Use //sc mb '..option..' on|off.')
                return
            end
            m[option]=value
        else
            message(('MB pos %d %d, width %d, scale %.2f, height %.1f, font %.1f, icon %.1f, text %s, icon %s, flash %s (%.2fs).'):format(
                m.x,m.y,m.width or opts.bar.width,m.scale or 1,m.height or 2,
                m.fontsize or 10,m.iconsize or 10,m.text or 'on',m.icon or 'on',
                m.flash or 'on',m.flash_duration or .24))
            return
        end
        if option=='pos' then m.position='custom' end
        config.save(settings)
        message(('MB ribbon at %d, %d, width %d, scale %.2f; text %s, icon %s, white intro %s.'):format(
            m.x,m.y,m.width or opts.bar.width,m.scale or 1,
            m.text or 'on',m.icon or 'on',m.flash or 'on'))
    elseif cmd=='display' then
        if option~='sc' and option~='mb' and option~='both' then
            message('Display: '..opts.display..'. Use sc, mb, or both.')
            return
        end
        opts.display=option
        config.save(settings)
        message('Display set to '..option..'.')
    elseif cmd=='mode' then
        if option~='learn' and option~='compact' and option~='minimal' then
            message('Mode: '..opts.mode..'. Use learn, compact, or minimal.')
            return
        end
        opts.mode=option
        config.save(settings)
        message('Mode set to '..option..'.')
    elseif cmd=='names' then
        if option=='offset' then
            local offset=opts.name_offset
            local x,y=tonumber(args[2]),tonumber(args[3])
            if not x or not y then
                message(('Name offset: %d, %d. Use //sc names offset <x> <y>.'):format(
                    offset.x,offset.y))
                return
            end
            -- Restrict extremes while allowing text to slightly overlap
            -- the bar or move below it for small-screen arrangements.
            offset.x=math.floor(math.max(-200,math.min(200,x))+.5)
            offset.y=math.floor(math.max(-100,math.min(100,y))+.5)
            config.save(settings)
            message(('Name offset set to %d, %d pixels.'):format(offset.x,offset.y))
        elseif option=='full' or option=='short' or option=='off' then
            opts.names=option
            config.save(settings)
            message('Property labels set to '..option..'.')
        else
            message('Property labels: '..(opts.names or 'full')..
                '. Use full, short, off, or offset <x> <y>.')
        end
    elseif cmd=='icons' then
        if option=='offset' then
            opts.icon_offset=opts.icon_offset or {x=0,y=0}
            local offset=opts.icon_offset
            local x,y=tonumber(args[2]),tonumber(args[3])
            if not x or not y then
                message(('SC icon offset: %d, %d. Use //sc icons offset <x> <y>.'):format(
                    offset.x or 0,offset.y or 0))
                return
            end
            offset.x=math.floor(math.max(-200,math.min(200,x))+.5)
            offset.y=math.floor(math.max(-100,math.min(100,y))+.5)
            config.save(settings)
            message(('SC icon offset set to %d, %d pixels.'):format(
                offset.x,offset.y))
        else
            message('Use //sc icons offset <x> <y>. //sc names offset moves both caption text and icons.')
        end
    elseif cmd=='center' then
        overlay:center()
        config.save(settings)
        message('Resonance bar and learning panel moved into the screen center.')
    elseif cmd=='pos' then
        local x,y=tonumber(args[1]),tonumber(args[2])
        if not x or not y then
            message(('Bar position: %d, %d. Use //sc pos <x> <y>.'):format(
                opts.bar.x,opts.bar.y))
            return
        end
        overlay:set_position(x,y)
        config.save(settings)
        message(('Bar moved to %d, %d.'):format(opts.bar.x,opts.bar.y))
    elseif cmd=='edit' or cmd=='move' then
        local desired
        if option=='on' then desired=true
        elseif option=='off' then desired=false end
        local active=overlay:edit(desired)
        config.save(settings)
        message('Edit '..(active and 'ON' or 'OFF')..
            '. Drag SC, MB, or learning separately; hold Ctrl to snap to grid.')
    elseif cmd=='scale' then
        if option=='edit' then
            local on=overlay:scale_edit()
            config.save(settings)
            message('Drag scaling '..(on and 'ON' or 'OFF')..'.')
            return
        end
        local number=tonumber(option)
        if not number then
            message(('Scale: %.2f (range .5 to 2.5). Use //sc scale edit to drag.'):format(opts.scale))
            return
        end
        overlay:scale(number)
        config.save(settings)
        message(('Scale set to %.2f.'):format(opts.scale))
    elseif cmd=='glow' then
        opts.glow=opts.glow or {}
        local g=opts.glow
        local defs=default.Resonance.glow
        for key,val in pairs(defs) do
            if g[key]==nil then g[key]=val end
        end
        if option=='levels' then
            local value=(args[2] or ''):lower()
            if value=='off' then
                g.level_mask='off'
            elseif value~='' and value:match('^[1-4]+$') then
                local unique={}
                for level=1,4 do
                    if value:find(tostring(level),1,true) then
                        unique[#unique+1]=tostring(level)
                    end
                end
                g.level_mask='L'..table.concat(unique,',L')
            else
                message('Glow levels: '..glow_levels(g)..
                    ' (default 234). Use //sc glow levels 34|1234|off|<digits 1-4>.')
                return
            end
            config.save(settings)
            message('Glow levels '..glow_levels(g)..' (default 234).')
        elseif option=='rail12' or option=='rail34' or
            option=='cap12' or option=='cap34' or option=='scale' or
            option=='pre12' or option=='pre2' or option=='pre3' or option=='pre4' or
            option=='level1' or option=='level2' or
            option=='level3' or option=='level4' then
            glow_setting(opts,option,args[2])
        elseif option=='l4' then
            local value=(args[2] or ''):lower()
            if value~='gold' and value~='white' and value~='whitegold' then
                message('Glow L4 '..g.l4..' (default '..defs.l4..
                    '). Use //sc glow l4 whitegold|gold|white.')
                return
            end
            g.l4=value
            config.save(settings)
            message('Glow L4 '..value..' (default '..defs.l4..').')
        elseif option=='preset' then
            local preset=(args[2] or ''):lower()
            if preset~='balanced' and preset~='capforward' then
                message('Use //sc glow preset balanced|capforward (default capforward).')
                return
            end
            -- Ratio follows the currently favored .75 rail / .85 cap
            -- rather than exaggerating the round tip with extra bloom.
            g.cap12=g.rail12*(preset=='balanced' and 1 or defs.cap12/defs.rail12)
            g.cap34=g.rail34*(preset=='balanced' and 1 or defs.cap34/defs.rail34)
            config.save(settings)
            message(('Glow %s: cap12 %.3f, cap34 %.3f; rail12 %.3f, rail34 %.3f. Default capforward.'):format(
                preset,g.cap12,g.cap34,g.rail12,g.rail34))
        elseif option=='reset' then
            opts.glow={}
            for key,val in pairs(defs) do opts.glow[key]=val end
            opts.glow.level_mask='L2,L3,L4'
            config.save(settings)
            message('Glow restored to Animation8 defaults (positions unchanged).')
        else
            message(('Glow levels %s (default 234), rail12 %.2f cap12 %.2f, rail34 %.2f cap34 %.2f; pre2 %.2f pre3 %.2f pre4 %.2f; scale %.2f L4 %s.'):format(
                glow_levels(g),g.rail12,g.cap12,g.rail34,g.cap34,
                g.pre2,g.pre3,g.pre4,g.scale,g.l4))
            message('Use //sc glow levels 34|1234|off; rail12|cap12|rail34|cap34|level1-4|pre12|pre2|pre3|pre4|scale <number>; preset balanced|capforward; l4 gold|whitegold|white; reset.')
        end
    elseif cmd=='track' then
        opts.track=opts.track or {}
        local t=opts.track
        local defs=default.Resonance.track
        t.alpha=t.alpha==nil and defs.alpha or t.alpha
        t.color=t.color or {defs.color[1],defs.color[2],defs.color[3]}
        if option=='alpha' then
            local alpha=finite_nonnegative(args[2])
            if not alpha or alpha>255 then
                message(('Track alpha %d/255 (default %d). Use //sc track alpha <0-255>.'):format(t.alpha,defs.alpha))
                return
            end
            t.alpha=math.floor(alpha+.5)
            config.save(settings)
            message(('Track alpha %d/255 (default %d; 0 is fully transparent).'):format(t.alpha,defs.alpha))
        elseif option=='rgb' then
            local rgb={}
            for i=1,3 do
                local v=finite_nonnegative(args[i+1])
                if not v or v>255 then
                    message('Use //sc track rgb <0-255> <0-255> <0-255> (default 6 8 17).')
                    return
                end
                rgb[i]=math.floor(v+.5)
            end
            t.color=rgb
            config.save(settings)
            message(('Track RGB %d %d %d (default 6 8 17).'):format(rgb[1],rgb[2],rgb[3]))
        elseif option=='reset' then
            opts.track={alpha=defs.alpha,color={defs.color[1],defs.color[2],defs.color[3]}}
            config.save(settings)
            message('Track alpha/RGB restored to default 155 / 6 8 17.')
        else
            message(('Track alpha %d/255, RGB %d %d %d (defaults 155 / 6 8 17).'):format(
                t.alpha,t.color[1],t.color[2],t.color[3]))
            message('Use //sc track alpha <0-255> | rgb <r> <g> <b> | reset.')
        end
    elseif cmd=='transition' then
        opts.transition=opts.transition or {}
        local t=opts.transition
        if option=='style' then
            local value=(args[2] or ''):lower()
            if value~='uniform' and value~='energized' then
                message('Transition style '..(t.style or 'energized')..
                    ' (default energized). Use //sc transition style energized|uniform.')
                return
            end
            t.style=value
            config.save(settings)
            message('Transition style '..value..' (default energized).')
        elseif option then
            local seconds=finite_nonnegative(option)
            if not seconds then
                message('Transition duration '..(t.duration or .3)..
                    's (default .30s). Use //sc transition <seconds >= 0>.')
                return
            end
            t.duration=seconds
            config.save(settings)
            message(('Transition %.3fs centered on countdown start (default .300s).'):format(seconds))
        else
            message(('Transition %.3fs, style %s (defaults .300s, energized).'):format(
                t.duration or .3,t.style or 'energized'))
        end
    elseif cmd=='anim' or cmd=='animation' then
        opts.animation=opts.animation or {enabled=true,intensity=2,flare=2,glow=2,fade=false}
        local a=opts.animation
        if option=='on' or option=='off' then
            a.enabled=(option=='on')
            config.save(settings)
            message('Resonance animations '..(a.enabled and 'ON' or 'OFF')..'.')
        elseif option=='intensity' or option=='flare' or option=='glow' then
            local value=finite_nonnegative(args[2])
            if not value then
                message('Use //sc anim '..option..
                    ' <number >= 0> (default '..tostring(default.Resonance.animation[option])..').')
                return
            end
            a[option]=value
            config.save(settings)
            message(('Animation %s %.2f (default %.2f%s).'):format(
                option,value,default.Resonance.animation[option],
                option=='flare' and '; legacy flare sprites retired' or
                '; drawable opacity saturates at 255'))
        elseif option=='fade' then
            local value=args[2] and args[2]:lower()
            if value=='period' then
                local n=tonumber(args[3])
                if not n or n~=n or n<.08 or n>5 then
                    message(('Countdown pulse period %.3fs. Use //sc anim fade period <0.08-5 seconds>.'):format(a.fade_period or 1/2.4))
                    return
                end
                a.fade_period=n
                config.save(settings)
                message(('Countdown pulse period %.3fs (TargetSC default L1 hum ~0.24s).'):format(n))
                return
            end
            if value~='on' and value~='off' then
                message('Use //sc anim fade on|off | period <seconds>.')
                return
            end
            a.fade=(value=='on')
            config.save(settings)
            message('Countdown opacity wave '..(a.fade and 'ON' or 'OFF')..'.')
        elseif option=='preview' then
            local kind=args[2] and args[2]:lower() or 'opener'
            local examples={opener={1,0,{'Liquefaction','Detonation'}},
                level1={2,1,{'Liquefaction'}},level2={2,2,{'Fusion'}},
                level3={2,3,{'Light'}},level4={2,4,{'Radiance'}},
                radiance={2,4,{'Radiance'},true},lux={2,4,{'Radiance'},true},
                umbra={2,4,{'Umbra'},true}}
            if kind=='off' then
                animation_preview=nil;overlay:hide()
                message('Animation preview off.')
            elseif examples[kind] then
                hud_demo=nil
                local example=examples[kind]
                local clock=os.clock()
                animation_preview={
                    created=clock,delay=clock+3,times=clock+3+(8-example[1]),
                    ends=example[4] and clock+3+.85 or clock+3+(8-example[1])+.35,
                    step=example[1],level=example[2],active=example[3],
                    -- Preview deliberately shows the provisional level-4
                    -- border on a mock bar. Real Radiance/Umbra remain closed.
                    closed=example[4] or false
                }
                message('Local HUD preview: '..kind..'. No combat or TargetSC event sent.')
            else
                message('Use //sc anim preview opener|level1|level2|level3|level4|radiance|umbra|lux|off.')
            end
        else
            message(('Animations %s, intensity %.2f, flare %.2f, glow %.2f, opacity wave %s (period %.3fs); //sc anim preview opener|level1|level2|level3|level4|radiance|umbra|lux|off'):format(
                a.enabled and 'on' or 'off',a.intensity or 1,
                a.flare or 1,a.glow or 1,a.fade and 'on' or 'off',a.fade_period or 1/2.4))
        end
    elseif cmd=='grid' then
        local grid=tonumber(option)
        if option==nil then
            message(('Ctrl+drag grid: %d UI pixels from screen 0,0. Use //sc grid <pixels>.'):format(opts.grid or 10))
            return
        end
        if not grid or grid~=math.floor(grid) or grid<1 or grid>200 then
            message('Use //sc grid <pixels> with a whole number from 1 to 200.')
            return
        end
        opts.grid=grid
        config.save(settings)
        message(('Ctrl+drag grid set to %d UI pixels, screen origin 0,0.'):format(grid))
    elseif cmd=='width' then
        local number=tonumber(option)
        if not number then
            message('Bar width: '..opts.bar.width..' pixels.')
            return
        end
        opts.bar.width=math.max(40,math.min(1600,math.floor(number+.5)))
        config.save(settings)
        message('Bar width set to '..opts.bar.width..'.')
    elseif cmd=='default' then
        opts.display,opts.mode,opts.names,opts.scale='sc','learn','full',1
        opts.grid=10
        opts.animation={enabled=true,intensity=2,flare=2,glow=2,fade=false,fade_period=1/2.4}
        opts.glow={level_mask='L2,L3,L4',rail12=.30,cap12=.35,rail34=.75,cap34=.85,
                   level1=1,level2=.70,level3=1,level4=1,
                   pre12=.18,pre2=.85,pre3=.38,pre4=.85,scale=1,l4='gold'}
        opts.track={alpha=155,color={6,8,17}}
        opts.transition={duration=.30,style='energized'}
        opts.tip={enabled=true,length=16,opacity=.85}
        opts.mb={position='below',gap=3,height=2,text='on',icon='on',
            scale=1,fontsize=10,iconsize=10,flash='on',flash_duration=.24,
            x=opts.bar.x,y=opts.bar.y+25,width=opts.bar.width}
        opts.name_offset.x,opts.name_offset.y=5,-9
        opts.icon_offset=opts.icon_offset or {x=0,y=0}
        opts.icon_offset.x,opts.icon_offset.y=0,0
        opts.bar.x,opts.bar.y,opts.bar.width=466,696,310
        opts.list.x,opts.list.y=465,300
        overlay:scale(1)
        overlay:edit(false)
        overlay.handle:pos(opts.bar.x,opts.bar.y-34)
        overlay.panel:pos(opts.list.x,opts.list.y)
        config.save(settings)
        message('Display, scale, name offset and positions reset to testing defaults.')
    elseif cmd=='save' then
        config.save(settings,option=='all' and 'all' or nil)
        message('Settings saved.')
    elseif cmd=='burst' or cmd=='props' or cmd=='step' or cmd=='timer' or cmd=='color' then
        message('Legacy text-layout toggle replaced by //sc mode and //sc display.')
    elseif cmd=='aeonic' then
        settings.aeonic=not settings.aeonic
        config.save(settings)
        message('Aeonic fallback '..(settings.aeonic and 'on' or 'off')..'.')
    elseif default.Show[cmd] then
        if not ensure_player() then message('Log in before changing job filters.') return end
        local on=settings.Show[cmd][info.job]
        if on then settings.Show[cmd]:remove(info.job)
        else settings.Show[cmd]:add(info.job) end
        config.save(settings)
        message(cmd..' suggestions '..(on and 'disabled' or 'enabled')..' for '..info.job..'.')
    elseif cmd=='status' then
        message(('v%s | %s | %s | names %s | scale %.2f | width %d | grid %d | anim %s %.2f | edit %s'):format(
            _addon.version,opts.display,opts.mode,opts.names or 'full',
            opts.scale,opts.bar.width,opts.grid or 10,
            (opts.animation or {}).enabled~=false and 'on' or 'off',
            (opts.animation or {}).intensity or 1,
            overlay.editing and 'on' or 'off'))
    elseif cmd=='help' then
        show_help()
    elseif cmd=='restart' or cmd=='unload' then
        message(cmd=='restart' and 'Reloading Skillchains.' or 'Unloading Skillchains.')
        windower.send_command(cmd=='restart' and 'lua reload Skillchains'
            or 'lua unload Skillchains')
    else
        message('Unknown command: '..tostring(cmd))
        show_help()
    end
end)

windower.register_event('job change', function(job, lvl)
    job = res.jobs:with('id', job).english_short
    if job ~= info.job then
        info.job = job
        config.reload(settings)
    end
end)

windower.register_event('zone change', function()
    hud_demo=nil
    animation_preview=nil
    targetsc:reset('zone')
    resonating = {}
    overlay:hide()
end)

windower.register_event('load', function()
    targetsc:announce()
    if ensure_player() then
        local equip = windower.ffxi.get_items('equipment')
        info.main_weapon = equip.main
        info.main_bag = equip.main_bag
        info.range = equip.range
        info.range_bag = equip.range_bag
        update_weapon()
        buffs[info.player] = {}
    end
end)

windower.register_event('login', function()
    ensure_player()
end)

windower.register_event('unload', function()
    hud_demo=nil
    targetsc:stop()
    if check_weapon then coroutine.close(check_weapon) end
    overlay:destroy()
end)

windower.register_event('logout', function()
    hud_demo=nil
    animation_preview=nil
    targetsc:reset('logout')
    if check_weapon then coroutine.close(check_weapon) end
    overlay:hide()
    check_weapon = nil
    info = {}
    resonating = {}
    buffs = {}
end)
