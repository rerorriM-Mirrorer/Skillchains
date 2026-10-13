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
_addon.version = '2.20.08.25-resonance.4'

require('luau')
require('pack')
require('actions')
texts = require('texts')
skills = require('skills')
local resonance_view = require('resonance_ui')

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
    mode='learn', display='sc', names='full', scale=1,
    -- Text offsets are relative to the SC bar, not absolute screen coordinates.
    name_offset={x=0,y=0},
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
                        via=via or table.concat(props,'/')
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
            temp[k] = '%s%s\\cr':format(colors[t[k]], t[k])
        end
    end
    return _raw.table.concat(temp or t, ',')
end

local next_frame = os.clock()

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
            resonating[id]=nil
        end
    end
    if not ensure_player() then overlay:render(nil) return end
    local target=windower.ffxi.get_mob_by_target('t','bt')
    local reson=target and resonating[target.id]
    if not target or target.hpp<=0 or not reson then
        overlay:render(nil)
        return
    end
    local sc_left=math.max(0,reson.times-now)
    local mb_left=math.max(0,(reson.mb_window or 0)-now)
    if sc_left<=0 and mb_left<=0 then
        overlay:render(nil)
        return
    end
    if not reson.groups and sc_left>0 and not reson.closed then
        reson.groups=check_results(reson)
    end
    overlay:render({
        active=reson.active,step=reson.step,closed=reson.closed,
        sc_left=sc_left,sc_wait=math.max(0,reson.delay-now),
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

function apply_properties(target, resource, action_id, properties, delay, step, closed, bound)
    local clock = os.clock()
    resonating[target] = {
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
        bound=bound
    }
    if target == targ_id then
        next_frame = clock
    end
end

function action_handler(act)
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

        apply_properties(target.id, resource, action_id, {skillchain}, delay, step, closed)
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

local function message(str)
    windower.add_to_chat(207,'Skillchains: '..str)
end

windower.register_event('addon command', function(cmd, ...)
    cmd=(cmd or 'status'):lower()
    local args={...}
    local option=args[1] and args[1]:lower()
    local opts=settings.Resonance
    if cmd=='display' then
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
            '. Drag SC BAR and the separate learning panel.')
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
        opts.name_offset.x,opts.name_offset.y=0,0
        opts.bar.x,opts.bar.y,opts.bar.width=466,696,310
        opts.list.x,opts.list.y=465,300
        overlay:scale(1)
        overlay:edit(false)
        overlay.handle:pos(opts.bar.x,opts.bar.y-19)
        overlay.panel:pos(opts.list.x,opts.list.y)
        config.save(settings)
        message('Display, scale and positions reset to testing defaults.')
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
        message(('v%s | %s | %s | names %s | scale %.2f | width %d | edit %s'):format(
            _addon.version,opts.display,opts.mode,opts.names or 'full',
            opts.scale,opts.bar.width,
            overlay.editing and 'on' or 'off'))
    elseif cmd=='help' then
        message('display sc|mb|both; mode learn|compact|minimal; names full|short|off|offset <x> <y>; edit [on|off]; center; pos [x y]; scale [.5-2.5|edit]; width [pixels]; default; save [all]; status')
    else
        message('Unknown command. Use //sc help.')
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
    resonating = {}
    overlay:hide()
end)

windower.register_event('load', function()
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
    if check_weapon then coroutine.close(check_weapon) end
    overlay:destroy()
end)

windower.register_event('logout', function()
    if check_weapon then coroutine.close(check_weapon) end
    overlay:hide()
    check_weapon = nil
    info = {}
    resonating = {}
    buffs = {}
end)
