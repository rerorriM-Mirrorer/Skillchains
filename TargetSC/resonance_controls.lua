-- Visual-only command handlers. No source state, identity or clock mutations.
-- Author: A.
local M={}
local direct={opacity={0,1},scale={.25,3},height={.25,3},intensity={0,4},width={1,8},brightness={0,4},glow={0,3}}
local strike={prefix='',values={period={.05,.5},amplitude={0,1},damping={0,8}}}
local groups={flutter=strike,strike=strike,
    hum={prefix='hum_',values={amplitude={0,.3},period={.05,1},slowdown={.1,4},gain={0,2}}},
    mb={prefix='mb_',values={opacity={0,1},duration={.2,4},effects={0,1},ending={.15,2},idle={0,1},burst={0,1},floor={0,1},ring={0,1},period={.2,6},rise={0,2},expand={0,2}}},
    sky={prefix='sky_',values={expand={0,2},cutoff={.05,1},curve={1,8}}},
    ground={prefix='ground_',values={height={0,1}}},fade={prefix='fade_',values={duration={.1,1}}}}
local disc_limits={opacity={0,1},outline={0,1},height={0,.5},speed={0,4},slowdown={.1,4}}
local presets={default=true,discson=true,discsoff=true,vivid=true,gentle=true,legacy=true}
function M.new(settings,defaults,save,say)
    local function numeric(key,value,range,syntax)
        local n=tonumber(value)
        if not n or n~=n or n<range[1]or n>range[2]then
            say(('Use //tsc %s <%s-%s>.'):format(syntax,range[1],range[2]));return
        end
        settings[key]=n;save(settings);say(('%s = %.3f'):format(syntax,n))
    end
    local function toggle(key,value,label)
        value=value==''and (settings[key]and 'off'or 'on')or value
        if value~='on'and value~='off'then return false end
        settings[key]=value=='on';save(settings);say(label..' '..value..'.');return true
    end
    local function preset(value)
        if not presets[value]then say('Use //tsc preset default|discson|discsoff|vivid|gentle|legacy.');return end
        for key,v in pairs(defaults)do settings[key]=v end
        if value=='discsoff'then settings.discs=false
        elseif value=='vivid'then
            settings.opacity=1;settings.brightness=1;settings.intensity=2;settings.motion='flutter'
            settings.period=.15;settings.amplitude=.28;settings.damping=.85;settings.glow=.8
        elseif value=='gentle'then
            settings.opacity=.7;settings.brightness=1;settings.intensity=1;settings.amplitude=.16;settings.glow=.4
        elseif value=='legacy'then
            settings.motion='legacy';settings.discs=false;settings.scale=1;settings.opacity=.65
            settings.intensity=.65;settings.width=1
        end
        save(settings);say('Visual preset '..value..'. Enabled/debug preserved; all visual values reset.')
    end
    local function discs(args,value)
        local stage=(args[2]or ''):lower()
        if value=='speed'and (stage=='opener'or stage:match('^level[1-4]$'))then
            numeric('disc_speed_'..stage,args[3],{0,4},'discs speed '..stage)
        elseif disc_limits[value]then numeric('disc_'..value,args[2],disc_limits[value],'discs '..value)
        elseif value=='style'then
            local style=(args[2]or ''):lower()
            if style~='glyph'and style~='outline'and style~='fill'then say('Use //tsc discs style glyph|outline|fill.');return end
            settings.disc_style=style;save(settings);say('Disc style '..style..'.')
        elseif not toggle('discs',value,'Discs')then
            say('See //tsc help for discs on/off, opacity, outline, style, height, speed and slowdown.')
        end
    end
    local function opener(args,value)
        if value=='gap'then
            local v=(args[2]or ''):lower()
            numeric('opener_gap',v=='on'and '12'or v=='off'and '0'or v,{0,60},'opener gap')
        elseif value=='glow'then
            local mode=(args[2]or ''):lower()
            if mode~='color'and mode~='black'and mode~='off'then
                say('Use //tsc opener glow color|black|off.');return
            end
            settings.opener_glow=mode;save(settings);say('Opener glow '..mode..'.')
        elseif value=='muted'then
            if not toggle('opener_muted',(args[2]or ''):lower(),'Opener muted colors')then
                say('Use //tsc opener muted [on|off].')
            end
        elseif value=='preset'then
            local name=(args[2]or ''):lower()
            local choices={original={0,'color',false},gap={12,'color',false},
                black={0,'black',false},muted={0,'color',true},
                combined={12,'black',true},quiet={12,'off',true}}
            local values=choices[name]
            if not values then say('Use //tsc opener preset original|gap|black|muted|combined|quiet.');return end
            settings.opener_gap,settings.opener_glow,settings.opener_muted=unpack(values)
            save(settings);say('Opener preset '..name..'. Other visual settings preserved.')
        else
            say(('Opener gap=%.1f degrees; glow=%s; muted=%s. See //tsc help.'):format(
                settings.opener_gap,settings.opener_glow,tostring(settings.opener_muted)))
        end
    end
    return function(command,args)
        local value=(args[1]or ''):lower()
        local group=groups[command]
        if direct[command]then numeric(command,args[1],direct[command],command)
        elseif group then
            if group.values[value]then numeric(group.prefix..value,args[2],group.values[value],command..' '..value)
            else say('See //tsc help for '..command..' controls.')end
        elseif command=='opener'then opener(args,value)
        elseif command=='discs'then discs(args,value)
        elseif command=='awakening'then
            if value=='opacity'then numeric('awakening_opacity',args[2],{0,1},'awakening opacity')
            elseif not toggle('awakening',value,'Awakening')then say('Use //tsc awakening on|off|opacity <0-1>.')end
        elseif command=='preset'then preset(value)
        elseif command=='display'then
            if not ({sc=true,mb=true,both=true,off=true})[value]then say('Use //tsc display sc|mb|both|off.');return true end
            settings.display=value;save(settings);say('Display '..value..'.')
        elseif command=='motion'or command=='layout'then
            local values=command=='motion'and {flutter=true,sine=true,legacy=true}or {grounded=true,symmetric=true,center=true}
            if not values[value]then say('See //tsc help for '..command..' choices.');return true end
            settings[command]=value;save(settings);say(command..' = '..value)
        else return false end
        return true
    end
end
return M
