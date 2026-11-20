-- Visual-only command handlers. No source state, identity or clock mutations.
-- Author: A.
local M={}
local direct={opacity={0,1},scale={.25,3},height={.25,3},intensity={0,4},width={1,8},brightness={0,4},glow={0,3}}
local strike={prefix='',values={period={.05,.5},amplitude={0,1},damping={0,8}}}
local groups={flutter=strike,strike=strike,
    hum={prefix='hum_',values={amplitude={0,.3},period={.05,1},slowdown={.1,4},gain={0,2}}},
    mb={prefix='mb_',values={opacity={0,1},overall={0,1},intro={0,.6},duration={.2,4},effects={0,1},ending={.15,3},idle={0,1},burst={0,1},floor={0,1},ring={0,1},period={.2,6},rise={0,2},expand={0,2},
        size={0,1},position={0,1},spin={0,.2},hold={0,.6},['return']={.1,2},lift={0,1},shimmer={0,2}}},
    breath={prefix='mb_breath_',values={min={0,1},gain={0,8}}},
    sky={prefix='sky_',values={expand={0,2},cutoff={.05,1},curve={1,8},hold={0,2},descent={-4,4}}},
    ground={prefix='ground_',values={height={0,1},lift={0,.3}}},fade={prefix='fade_',values={duration={.1,1}}}}
local disc_limits={opacity={0,1},outline={0,1},height={0,.5},speed={0,4},minimum={0,4},slowdown={.1,4}}
local presets={default=true,killala=true,discson=true,discsoff=true,vivid=true,gentle=true,legacy=true}
local preset_names='default|killala|discson|discsoff|vivid|gentle|legacy'
function M.new(settings,defaults,save,say,killala)
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
        if not presets[value]then say('Use //tsc preset '..preset_names..'.');return end
        for key,v in pairs(defaults)do settings[key]=v end
        -- killala: the exact pre-Test3 2026-10-22 profile (also Cioara's).
        if value=='killala'then for key,v in pairs(killala or {})do settings[key]=v end end
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
    -- Test4.9 burst bloom: //tsc mb bloom ... (args[1] is 'bloom').
    local bloom_usage='Use //tsc mb bloom on|off | from ring|disc|glyph [to ring|disc|glyph|same] | size <start> [end] | '..
        'time <0.2-4> | ease <0.5-6> | fade <0.3-6> | opacity <center> [middle] [edge] | middle <0.1-0.9> | '..
        'flash <0-1> | core <0-1> | lines <0-4> | lines opacity|delay|size <number>.'
    local bloom_places={ring=true,disc=true,glyph=true}
    local function bloom(args)
        local name=(args[2]or ''):lower()
        local valid=function(n,a,b)return n and n==n and n>=a and n<=b end
        if name==''or name=='on'or name=='off'then
            if name==''then name=settings.mb_bloom and 'off'or 'on'end
            settings.mb_bloom=name=='on';save(settings);say('MB bloom '..name..'.')
        elseif name=='from'then
            local from,to=(args[3]or ''):lower(),(args[5]or ''):lower()
            if not bloom_places[from]or (args[4]and ((args[4]):lower()~='to'or not (bloom_places[to]or to=='same')))then
                say('Use //tsc mb bloom from ring|disc|glyph [to ring|disc|glyph|same].');return
            end
            settings.mb_bloom_from=from;settings.mb_bloom_to=args[4]and to or 'same';save(settings)
            say('MB bloom from '..from..(settings.mb_bloom_to=='same'and ''or (' rising to '..to))..'.')
        elseif name=='size'then
            local a=tonumber(args[3])
            local b=args[4]==nil and settings.mb_bloom_end or tonumber(args[4])
            if not valid(a,.05,4)or not valid(b,.05,4)then say('Use //tsc mb bloom size <start 0.05-4> [end 0.05-4] (MB ring radii).');return end
            settings.mb_bloom_start,settings.mb_bloom_end=a,b;save(settings)
            say(('MB bloom grows from %.2f to %.2f MB ring radii.'):format(a,b))
        elseif name=='opacity'then
            local c=tonumber(args[3])
            local m=args[4]==nil and settings.mb_bloom_middle or tonumber(args[4])
            local e=args[5]==nil and settings.mb_bloom_edge or tonumber(args[5])
            if not valid(c,0,1)or not valid(m,0,1)or not valid(e,0,1)then
                say('Use //tsc mb bloom opacity <center 0-1> [middle 0-1] [edge 0-1].');return
            end
            settings.mb_bloom_center,settings.mb_bloom_middle,settings.mb_bloom_edge=c,m,e;save(settings)
            say(('MB bloom opacity: center %.2f, middle %.2f, edge %.2f.'):format(c,m,e))
        elseif name=='lines'then
            local option=(args[3]or ''):lower()
            local ranges={opacity={0,1},delay={0,.5},size={.2,4}}
            if ranges[option]then numeric('mb_bloom_lines_'..option,args[4],ranges[option],'mb bloom lines '..option)
            else
                local n=tonumber(args[3])
                if not n or n~=math.floor(n)or n<0 or n>4 then say('Use //tsc mb bloom lines <0-4> | lines opacity <0-1> | delay <0-0.5> | size <0.2-4>.');return end
                settings.mb_bloom_lines=n;save(settings);say('MB bloom glyph-line copies: '..n..'.')
            end
        else
            local ranges={time={.2,4},ease={.5,6},fade={.3,6},middle={.1,.9},flash={0,1},core={0,1}}
            if not ranges[name]then say(bloom_usage);return end
            numeric(name=='middle'and 'mb_bloom_position'or 'mb_bloom_'..name,args[3],ranges[name],'mb bloom '..name)
        end
    end
    -- Test5.1: //tsc discs level4 inner|middle|outer|position|size|height.
    local function level4(args)
        local name=(args[2]or ''):lower()
        local raw=(args[3]or ''):lower()
        local ranges={inner={0,1},middle={0,1},outer={0,1},size={.2,3},position={.05,.95},height={-.2,.5}}
        if not ranges[name]then
            say('Use //tsc discs level4 inner|middle|outer <0-1|same> | position <0.05-0.95> | size <0.2-3|same> | height <-0.2-0.5>.');return
        end
        if raw=='same'or raw=='off'then
            if name=='position'or name=='height'then say('Use a number for discs level4 '..name..'.');return end
            settings['disc_level4_'..name]=-1;save(settings)
            say('Level 4 disc '..name..(name=='middle'and ': no middle point.'or ': same as discs.'))
            return
        end
        numeric('disc_level4_'..name,args[3],ranges[name],'discs level4 '..name)
    end
    -- Test5.2: //tsc radiance ... and //tsc umbra ... (level-4 looks).
    local level4_spec={
        radiance={opacity={'n',0,1,same=true},['disc opacity']={'n',0,1,same=true},look={'c','open','classic'},
            close={'c','sequence','classic'},['close time']={'n',.3,6},order={'c','lower','upper','together'},
            direction={'c','inner','outer'},lead={'n',.05,1},fade={'n',.05,2},flash={'n',0,3},
            shimmer={'n',0,1},['shimmer time']={'n',.2,8},['shimmer stagger']={'n',0,1},
            ['shimmer angle']={'n',-180,180},['shimmer when']={'c','close','all'},['shimmer mb']={'b'},
            ['open time']={'n',0,8,same=true},['disc lines']={'b'},glyph={'c','breath','same'},
            ['glyph size']={'n',.2,4},['glyph opacity']={'n',0,1,same=true},['glyph buzz']={'b'},
            stack={'b'},['stack height']={'n',-.2,.5},['stack spacing']={'n',0,.1},
            ['bottom opacity']={'n',0,1},['bottom size']={'n',.2,4},['middle opacity']={'n',0,1},
            ['middle size']={'n',.2,4},['middle cycle']={'n',.2,20},['middle spin']={'n',-4,4}},
        umbra={opacity={'n',0,1,same=true},['disc opacity']={'n',0,1,same=true},look={'c','black','classic'},
            glow={'c','white','violet'},close={'c','sequence','classic'},['close time']={'n',0,6},
            order={'c','upper','lower','together'},direction={'c','outer','inner'},gap={'n',0,.5},
            flash={'n',0,1},['flash time']={'n',.02,.5},smoke={'n',.1,4},['smoke opacity']={'n',0,2},
            ['smoke spread']={'n',0,.3},
            ['open time']={'n',0,8,same=true},after={'c','bloom','smoke','off'},['bloom opacity']={'n',0,1},
            ['bloom time']={'n',.2,8},['bloom size']={'n',.2,4},['bloom growth']={'n',-1,2},
            ['bloom height']={'c','rings','ground','disc','mb'},mb={'c','pulse','classic'},['mb strength']={'n',0,1},
            ['mb size']={'n',.2,4},['disc size']={'n',.2,10,same=true},
            spin={'n',0,6,same=true},sky={'c','same','bell'},glyph={'c','breath','same'},
            ['glyph size']={'n',.2,4},['glyph opacity']={'n',0,1,same=true},['glyph spin']={'n',-4,4},
            ['glyph over']={'b'},copies={'b'},['copies every']={'n',.1,4},['copies life']={'n',.2,6},
            ['copies size']={'n',.2,6},['copies opacity']={'n',0,1},['copies spin']={'n',-4,4},
            ['copies depth']={'n',0,.1},
            ['lines size']={'n',.2,4,same=true},['lines opacity']={'n',0,1,same=true},
            ['disc inner']={'n',0,1,same=true},['disc middle']={'n',0,1,same=true},['disc outer']={'n',0,1,same=true},
            ['disc position']={'n',.05,.95,same=true},['disc steady']={'b'},core={'n',0,1,same=true},flicker={'n',0,1},
            ending={'c','off','gyro','swallow'},['ending when']={'c','open','mb','flash'},
            ['lines color']={'c','white','cream'},['mb height']={'c','ring','disc'},
            collapse={'b'},['collapse curve']={'n',1,10},['collapse time']={'n',.2,6,same=true},['glyph lift']={'n',0,.2,same=true},['ending time']={'n',.3,12},
            ['gyro speed']={'n',-8,8},['gyro rise']={'n',.05,3},['gyro shrink']={'n',0,1},['gyro below']={'c','full','half'},
            ['stand time']={'n',.05,8},['sink time']={'n',.05,10},['swallow stagger']={'n',0,.95},
            ['swallow order']={'c','outer','inner','together'},['swallow pull']={'n',0,1},['swallow lift']={'n',0,4}}}
    -- 0.18 kill animations: //tsc kill ... (same table-driven parser).
    level4_spec.kill={time={'n',.3,5},['mb rings']={'c','freeze','gather'},['mb fade']={'n',.05,3},
        ['mb flicker']={'n',0,1},['mb freeze']={'n',0,1},['mb discs']={'c','element','own'},['mb bloom']={'c','in','fade'},['mb glyphs']={'c','bloom','fade'},['sc flicker']={'n',0,1},['seam flicker']={'n',0,1},
        ['mb gather']={'n',.05,2},['mb curve']={'n',1,10},
        ['bloom delay']={'n',0,1},['bloom time']={'n',.2,4},['bloom size']={'n',.3,5},['bloom opacity']={'n',0,1},
        ['sc freeze']={'n',0,1},['sc split']={'n',0,1},['sc turn']={'n',-1,1},['sc sag']={'n',0,1},
        ['sc flash']={'n',0,.5},['sc seam']={'n',0,2},['sc ghost']={'n',0,1},['seam angle']={'n',-180,180}}
    local function level4_look(command,args)
        local spec=level4_spec[command]
        local a1,a2=(args[1]or ''):lower(),(args[2]or ''):lower()
        local name,rest=a1..' '..a2,3
        if not spec[name]then name,rest=a1,2 end
        local entry=spec[name]
        if not entry then
            local names={}for k in pairs(spec)do names[#names+1]=k end table.sort(names)
            say('Use //tsc '..command..' <setting> <value>. Settings: '..table.concat(names,', ')..'.')return
        end
        local key=command..'_'..name:gsub(' ','_')
        local raw=(args[rest]or ''):lower()
        if entry[1]=='n'then
            if entry.same and raw=='same'then settings[key]=-1;save(settings);say(command..' '..name..': same as the overall setting.')return end
            numeric(key,args[rest],{entry[2],entry[3]},command..' '..name)
        elseif entry[1]=='b'then
            if raw~='on'and raw~='off'then raw=settings[key]and 'off'or 'on'end
            settings[key]=raw=='on';save(settings);say(command..' '..name..' '..raw..'.')
        else
            local ok=false for i=2,#entry do ok=ok or entry[i]==raw end
            if not ok then say('Use //tsc '..command..' '..name..' '..table.concat({select(2,unpack(entry))},'|')..'.')return end
            settings[key]=raw;save(settings);say(command..' '..name..' '..raw..'.')
        end
    end
    local function discs(args,value)
        local stage=(args[2]or ''):lower()
        if value=='level4'then level4(args)
        elseif value=='speed'and (stage=='opener'or stage:match('^level[1-4]$'))then
            numeric('disc_speed_'..stage,args[3],{0,4},'discs speed '..stage)
        elseif disc_limits[value]then numeric('disc_'..value,args[2],disc_limits[value],'discs '..value)
        elseif value=='fade'then
            -- Link property-disc fill (all levels): center/edge multipliers.
            local inner,outer=tonumber(args[2]),tonumber(args[3])
            local valid=function(n)return n and n==n and n>=0 and n<=1 end
            if not valid(inner)or not valid(outer)then
                say('Use //tsc discs fade <inner 0-1> <outer 0-1> (1 1 = unchanged).');return
            end
            settings.disc_inner,settings.disc_outer=inner,outer;save(settings)
            say(('Discs fade: center %.2f, edge %.2f.'):format(inner,outer))
        elseif value=='size'then
            if (args[2]or ''):lower()=='lines'then numeric('disc_size_lines',args[3],{.2,2},'discs size lines')
            else numeric('disc_size',args[2],{.2,2},'discs size')end
        elseif value=='lightdark'then
            local look=(args[2]or ''):lower()
            if look~='classic'and look~='elements'then say('Use //tsc discs lightdark classic|elements.');return end
            settings.disc_lightdark=look;save(settings);say('Light/Darkness discs '..look..'.')
        elseif value=='blend'then
            local blend=(args[2]or ''):lower()
            if blend~='gradient'and blend~='firm'and blend~='split'then say('Use //tsc discs blend gradient|firm|split.');return end
            settings.disc_blend=blend;save(settings);say('Disc blend '..blend..'.')
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
        elseif value=='layout'then
            local layout=(args[2]or ''):lower()
            if layout~='sections'and layout~='rings'then say('Use //tsc opener layout sections|rings.');return end
            settings.opener_layout=layout;save(settings);say('Opener layout '..layout..'.')
        elseif value=='spacing'then numeric('opener_spacing',args[2],{0,.2},'opener spacing')
        elseif value=='spin'then
            local name=(args[2]or ''):lower()
            if name~='slowdown'and name~='minimum'then
                say('Use //tsc opener spin slowdown <0-4> | minimum <0-4>.');return
            end
            numeric('opener_spin_'..name,args[3],{0,4},'opener spin '..name)
        elseif value=='fade'then
            -- Opener arc fade along each arc (native 0.8.0).
            local name=(args[2]or ''):lower()
            if name=='lead'or name=='trail'then
                settings.opener_fade_end=name;save(settings);say('Opener fade bright end: '..name..'.')
            elseif name=='length'then numeric('opener_fade_length',args[3],{.1,1},'opener fade length')
            elseif name=='curve'then numeric('opener_fade_curve',args[3],{.5,3},'opener fade curve')
            elseif name=='glow'then numeric('opener_fade_glow',args[3],{0,1},'opener fade glow')
            elseif tonumber(args[2])then numeric('opener_fade',args[2],{0,1},'opener fade')
            else say('Use //tsc opener fade <0-1> | length <0.1-1> | curve <0.5-3> | lead|trail | glow <0-1>.')end
        elseif value=='discs'then
            -- Opener-only property-disc FILL; glyph lines are unchanged.
            local name=(args[2]or ''):lower()
            if name=='fade'then
                local inner,outer=tonumber(args[3]),tonumber(args[4])
                local valid=function(n)return n and n==n and n>=0 and n<=1 end
                if not valid(inner)or not valid(outer)then
                    say('Use //tsc opener discs fade <inner 0-1> <outer 0-1> (1 1 = unchanged).');return
                end
                settings.opener_disc_inner,settings.opener_disc_outer=inner,outer;save(settings)
                say(('Opener discs fade: center %.2f, edge %.2f.'):format(inner,outer))
            elseif name=='size'then numeric('opener_disc_size',args[3],{.2,2},'opener discs size')
            elseif name=='outline'then
                if (args[3]or ''):lower()=='same'then
                    settings.opener_disc_outline=-1;save(settings);say('Opener discs outline follows discs outline.')
                else numeric('opener_disc_outline',args[3],{0,1},'opener discs outline')end
            else say('Use //tsc opener discs fade <inner> <outer> | size <0.2-2> | outline <0-1>|same.')end
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
        if command=='kill'and (value=='on'or value=='off'or value==nil)then
            if value==nil then value=settings.kill and 'off'or 'on'end
            settings.kill=value=='on';save(settings);say('Kill animations '..value..'.')
        elseif command=='radiance'or command=='umbra'or command=='kill'then level4_look(command,args)
        elseif command=='detarget'then
            -- Test5.0: untarget/ordinary-death dim, from the first moment.
            local n=value=='time'and args[2]or args[1]
            numeric('detarget_time',n,{0,3},'detarget time')
        elseif command=='switch'then
            -- Test5.0: quick handoff when the new target has resonance.
            if value~='out'and value~='in'then say('Use //tsc switch out <0-1> | switch in <0-1>.');return true end
            numeric('switch_'..value,args[2],{0,1},'switch '..value)
        elseif command=='mb'and value=='style'then
            local style=(args[2]or ''):lower()
            if style~='classic'and style~='clapper'then say('Use //tsc mb style classic|clapper.');return true end
            settings.mb_style=style;save(settings);say('MB style '..style..'.')
        elseif command=='mb'and value=='breath'then
            local name=(args[2]or ''):lower()
            local range=groups.breath.values[name]
            if not range then say('Use //tsc mb breath min <0-1> or gain <0-8>.');return true end
            numeric('mb_breath_'..name,args[3],range,'mb breath '..name)
        elseif command=='mb'and value=='glow'then
            -- Confirmed-MB glows on the large glyph and the lifted trace.
            local name=(args[2]or ''):lower()
            local ranges={shade={0,1},spin={-2,2},flicker={0,1},width={.2,2}}
            if not ranges[name]then
                say('Use //tsc mb glow shade <0-1> | spin <-2-2> | flicker <0-1> | width <0.2-2>.');return true
            end
            numeric('mb_glow_'..name,args[3],ranges[name],'mb glow '..name)
        elseif command=='mb'and value=='bloom'then bloom(args)
        elseif command=='mb'and value=='radiance'then
            -- Test5.1 Radiance MB ring.
            local name=(args[2]or ''):lower()
            if name=='light'or name=='classic'then
                settings.mb_radiance=name;save(settings)
                say('Radiance MB ring '..(name=='light'and 'like a level-3 Light middle ring.'or 'classic.'))
            elseif name=='glow'then numeric('mb_radiance_glow',args[3],{0,3},'mb radiance glow')
            elseif name=='cycle'then numeric('mb_radiance_cycle',args[3],{.05,8},'mb radiance cycle')
            else say('Use //tsc mb radiance light|classic | glow <0-3> | cycle <0.05-8>.')end
        elseif command=='mb'and value=='glyph'then
            -- Large lower glyph's confirmed-burst response (Test3).
            local name=(args[2]or ''):lower()
            local ranges={height={0,2},tint={0,1},rise={0,1},opacity={0,1}}
            local choice=(args[3]or ''):lower()
            if name=='after'and (choice=='fade'or choice=='fall')then
                settings.mb_glyph_after=choice;save(settings);say('MB glyph after a burst: '..choice..'.');return true
            elseif name=='rest'and (choice=='hidden'or choice=='breath')then
                settings.mb_glyph_rest=choice;save(settings);say('MB glyph at rest: '..choice..'.');return true
            end
            if not ranges[name]then
                say('Use //tsc mb glyph height <0-2> | tint <0-1> | rise <0-1> | opacity <0-1> | after fade|fall | rest hidden|breath.');return true
            end
            numeric('mb_glyph_'..name,args[3],ranges[name],'mb glyph '..name)
        elseif command=='mb'and value=='intro'and ((args[2]or ''):lower()=='glyph'or (args[2]or ''):lower()=='disc')then
            local name=(args[2]or ''):lower()
            numeric('mb_intro_'..name,args[3],{0,1},'mb intro '..name)
        elseif command=='mb'and value=='intro'and (args[2]or ''):lower()=='flashes'then
            local flashes=tonumber(args[3])
            if flashes~=1 and flashes~=2 then say('Use //tsc mb intro flashes 1|2.');return true end
            settings.mb_intro_flashes=flashes;save(settings);say('MB intro flashes '..flashes..'.')
        elseif command=='mb'and value=='ending'and (args[2]or ''):lower()=='drop'then
            numeric('mb_ending_drop',args[3],{0,1},'mb ending drop')
        elseif command=='mb'and value=='ending'and (args[2]or ''):lower()=='shrink'then
            numeric('mb_ending_shrink',args[3],{0,1},'mb ending shrink')
        elseif command=='mb'and value=='ending'and (args[2]or ''):lower()=='fade'then
            numeric('mb_ending_fade',args[3],{0,1},'mb ending fade')
        elseif command=='mb'and value=='ending'and (args[2]or ''):lower()=='blooms'then
            local mode=(args[3]or ''):lower()
            if mode~='fade'and mode~='linger'then say('Use //tsc mb ending blooms fade|linger.');return true end
            settings.mb_ending_blooms=mode;save(settings);say('MB ending blooms '..mode..'.')
        elseif command=='mb'and value=='ending'and (args[2]or ''):lower()=='style'then
            local style=(args[3]or ''):lower()
            if not ({soft=true,hard=true,both=true,off=true,converge=true})[style]then
                say('Use //tsc mb ending style soft|hard|both|converge|off.');return true
            end
            settings.mb_ending_style=style;save(settings);say('MB ending style '..style..'.')
        elseif direct[command]then numeric(command,args[1],direct[command],command)
        elseif group then
            if group.values[value]then numeric(group.prefix..value,args[2],group.values[value],command..' '..value)
            else say('See //tsc help for '..command..' controls.')end
        elseif command=='rings'then
            local choice=(args[2]or ''):lower()
            if value=='blend'and (choice=='gradient'or choice=='firm'or choice=='split')then
                settings.ring_blend=choice;save(settings);say('Ring blend '..choice..' (openers stay split).')
            elseif value=='spin'and (choice=='disc'or choice=='classic')then
                settings.ring_spin=choice;save(settings);say('Ring spin '..choice..'.')
            elseif value=='light'then
                -- Level-3 Light only (Test4.6); Darkness uses rings lightdark.
                local name=(args[2]or ''):lower()
                if name=='white'or name=='elements'or name=='classic'then
                    settings.ring_light=name;save(settings);say('Light rings '..name..'.')
                elseif name=='cycle'then numeric('ring_light_cycle',args[3],{.5,30},'rings light cycle')
                elseif name=='glow'then numeric('ring_light_glow',args[3],{0,3},'rings light glow')
                elseif name=='opening'and ((args[3]or ''):lower()=='off'or (args[3]or ''):lower()=='on')then
                    settings.ring_light_opening=args[3]:lower();save(settings)
                    say('Light colored glows before the window opens: '..settings.ring_light_opening..'.')
                elseif name=='mb'and ((args[3]or ''):lower()=='match'or (args[3]or ''):lower()=='white')then
                    settings.ring_light_mb=args[3]:lower();save(settings)
                    say('Light MB ring: '..settings.ring_light_mb..'.')
                else say('Use //tsc rings light white|elements|classic | cycle <0.5-30 s> | glow <0-3> | opening off|on | mb match|white.')end
            elseif value=='lightdark'then
                -- Level-3 Light/Darkness rings (Test4.5).
                local name=(args[2]or ''):lower()
                if name=='classic'or name=='elements'then
                    settings.ring_lightdark=name;save(settings);say('Light/Darkness rings '..name..'.')
                elseif name=='spin'then numeric('ring_lightdark_spin',args[3],{-2,2},'rings lightdark spin')
                elseif name=='tint'and ((args[3]or ''):lower()=='gold'or (args[3]or ''):lower()=='white')then
                    settings.ring_lightdark_tint=args[3]:lower();save(settings);say('Light glow tint '..settings.ring_lightdark_tint..'.')
                elseif name=='cycle'then numeric('mb_lightdark_cycle',args[3],{.25,6},'rings lightdark cycle')
                else say('Use //tsc rings lightdark classic|elements | spin <-2-2> | tint gold|white | cycle <0.25-6>.')end
            elseif value=='shade'then numeric('ring_shade',args[2],{0,1},'rings shade')
            elseif value=='glow'and choice=='spin'then numeric('ring_glow_spin',args[3],{0,4},'rings glow spin')
            else
                say('Use //tsc rings blend gradient|firm|split | spin disc|classic | shade <0-1> | glow spin <0-4>.')
            end
        elseif command=='opener'then opener(args,value)
        elseif command=='discs'then discs(args,value)
        elseif command=='awakening'then
            if value=='opacity'then numeric('awakening_opacity',args[2],{0,1},'awakening opacity')
            elseif value=='fade'and (args[2]or ''):lower()=='until'then
                local mode=(args[3]or ''):lower()
                if mode=='window'then mode='open'end
                local n=tonumber(mode)
                if not (mode=='default'or mode=='open'or mode=='close'or
                    (n and n==math.floor(n)and n>=1 and n<=9))then
                    say('Use //tsc awakening fade until default|open|close|<1-9 seconds after the window opens>.');return true
                end
                settings.awakening_until=n and tostring(n)or mode;save(settings)
                local meaning={default='two-thirds of the wait (previous)',open='the window opens',close='the window ends'}
                say('Awakening fades until '..(meaning[mode]or (mode..' s after the window opens'))..'.')
            elseif value=='fade'then
                -- Center-to-edge fill opacity, each a multiplier of the
                -- current awakening opacity. Outer is optional (default 0).
                local inner,outer=tonumber(args[2]),args[3]==nil and 0 or tonumber(args[3])
                local valid=function(n)return n and n==n and n>=0 and n<=1 end
                if not valid(inner)or not valid(outer)then
                    say('Use //tsc awakening fade <inner 0-1> [outer 0-1] (outer defaults to 0).');return true
                end
                settings.awakening_inner,settings.awakening_outer=inner,outer;save(settings)
                say(('Awakening fade: center %.2f, edge %.2f.'):format(inner,outer))
            elseif value=='size'then numeric('awakening_size',args[2],{.1,3},'awakening size')
            elseif not toggle('awakening',value,'Awakening')then
                say('Use //tsc awakening on|off | opacity <0-1> | fade <inner> [outer] | size <0.1-3>.')
            end
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
