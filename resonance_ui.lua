-- Resonance display for Skillchains (testing branch).
-- Rendering belongs here; action-packet interpretation stays in Skillchains.lua.
-- The bars and learning panel are independent of EnemyBar2 and XIVCrossbar.
local texts = require('texts')
local ui = {}

local elements = {
    Fire={224,94,76}, Ice={147,215,235}, Wind={117,193,132},
    Earth={178,141,93}, Lightning={193,145,221}, Water={85,145,221},
    Light={242,232,201}, Dark={78,63,111},
}
local fallback = {185,171,204}
local segments = 24

local function clamp(v, lo, hi)
    return math.max(lo, math.min(hi, v))
end

local function interpolate(stops, t)
    if #stops == 0 then return fallback end
    if #stops == 1 then return stops[1] end
    local p = clamp(t, 0, 1) * (#stops - 1)
    local a = math.min(#stops, math.floor(p) + 1)
    local b = math.min(#stops, a + 1)
    local part = p - math.floor(p)
    return {
        math.floor(stops[a][1]*(1-part) + stops[b][1]*part + .5),
        math.floor(stops[a][2]*(1-part) + stops[b][2]*part + .5),
        math.floor(stops[a][3]*(1-part) + stops[b][3]*part + .5),
    }
end

-- A resonating WS can have several properties. An actual skillchain has
-- one resulting property whose elements determine compatible burst spells.
local function palette(state, sc_info, burst)
    local properties = state and state.active or {}
    -- Advanced Light/Dark chains need only their two recognizable families.
    if properties[1]=='Light' or properties[1]=='Radiance' then
        return {elements.Light}
    elseif properties[1]=='Darkness' or properties[1]=='Umbra' then
        return {elements.Dark}
    end
    local stops, seen = {}, {}
    for i=1,#properties do
        local name = properties[i]
        local element_names = sc_info[name]
        if element_names then
            for j=1,#element_names do
                local el = element_names[j]
                if elements[el] and not seen[el] then
                    seen[el] = true
                    stops[#stops+1] = elements[el]
                end
            end
        end
        if burst then break end
    end
    return #stops > 0 and stops or {fallback}
end

local function create_prim(id, alpha, r, g, b)
    windower.prim.create(id)
    windower.prim.set_color(id,alpha,r,g,b)
    windower.prim.set_visibility(id,false)
end

local function text_settings(x,y,size,draggable)
    return {
        pos={x=x,y=y},
        flags={draggable=draggable},
        text={font='Verdana',size=size,alpha=245,red=231,green=225,blue=236,
            stroke={width=1,alpha=210,red=14,green=13,blue=30}},
        bg={visible=true,alpha=175,red=16,green=18,blue=38},
        padding=4
    }
end

local function format_list(state, show_sc, show_mb)
    local output = {}
    local property = table.concat(state.active or {}, ', ')
    output[#output+1] = property .. '  |  Step ' .. tostring(state.step or 1)
    if show_sc and state.sc_left > 0 and not state.closed then
        output[#output+1] = 'AVAILABLE SKILLCHAINS'
        local groups = state.groups or {}
        if #groups == 0 then
            output[#output+1] = '  No compatible learned actions'
        else
            for i=1,#groups do
                local group=groups[i]
                output[#output+1] = ('Lv.%d  %s'):format(group.level,group.property)
                for j=1,#group.actions do
                    local action=group.actions[j]
                    output[#output+1] = ('  %s  (%s)'):format(action.name,action.via or '?')
                end
            end
        end
    end
    if show_mb and state.mb_left > 0 and state.step and state.step > 1 then
        local property=state.active[1]
        local match = state.sc_info and state.sc_info[property] or {}
        local label=(property=='Light' or property=='Radiance') and 'Light'
            or (property=='Darkness' or property=='Umbra') and 'Dark'
            or table.concat(match, ' / ')
        output[#output+1] = 'MAGIC BURST  ' .. label
    end
    return table.concat(output, '\n')
end

function ui.new(settings, sc_info)
    local self = {options=settings, sc_info=sc_info, editing=false, names={}}
    local prefix = 'sc_resonance_'
    for _,kind in ipairs({'sc','mb'}) do
        self.names[kind] = {frame=prefix..kind..'_frame',base=prefix..kind..'_base',slices={}}
        local bar=self.names[kind]
        create_prim(bar.frame,190,10,10,27)
        create_prim(bar.base,135,42,44,66)
        for i=1,segments do
            local id=prefix..kind..'_'..i
            create_prim(id,220,200,190,220)
            bar.slices[i]=id
        end
    end

    self.handle = texts.new('SC BAR  [drag]', text_settings(settings.bar.x,settings.bar.y-19,10,true))
    self.scalehandle = texts.new('SC SCALE  [drag left/right]',
        text_settings(settings.bar.x+math.floor(100*settings.scale+.5),
            settings.bar.y-36,10,true))
    self.scaling = false
    self.panel = texts.new('Skillchains', text_settings(settings.list.x,settings.list.y,
        math.floor(11*settings.scale+.5),false))
    self.handle:hide()
    self.scalehandle:hide()
    self.panel:hide()

    function self:hide_bars()
        for _,bar in pairs(self.names) do
            windower.prim.set_visibility(bar.frame,false)
            windower.prim.set_visibility(bar.base,false)
            for i=1,segments do windower.prim.set_visibility(bar.slices[i],false) end
        end
    end

    function self:hide()
        self:hide_bars()
        if not self.editing then
            self.handle:hide()
            self.scalehandle:hide()
            self.panel:hide()
        end
    end

    -- The full color spectrum is compressed into the remaining length,
    -- rather than cutting off its final element as the timer approaches zero.
    function self:draw_bar(kind, y, fraction, waiting, palette_stops)
        local bar=self.names[kind]
        local opts=self.options
        local scale=opts.scale
        local x=math.floor(opts.bar.x+.5)
        local width=math.max(24,math.floor(opts.bar.width+.5))
        local height=math.max(3,math.floor(5*scale+.5))
        local remaining=clamp(fraction,0,1)
        local usable=width-2
        local fill=math.floor(remaining*usable+.5)
        windower.prim.set_position(bar.frame,x,y)
        windower.prim.set_size(bar.frame,width,height+2)
        windower.prim.set_visibility(bar.frame,true)
        windower.prim.set_position(bar.base,x+1,y+1)
        windower.prim.set_size(bar.base,usable,height)
        windower.prim.set_visibility(bar.base,true)
        for i=1,segments do
            local id=bar.slices[i]
            local start=math.floor((i-1)*fill/segments)
            local finish=math.floor(i*fill/segments)
            local count=finish-start
            if count > 0 then
                local c=interpolate(palette_stops,(i-.5)/segments)
                windower.prim.set_color(id,waiting and 105 or 230,c[1],c[2],c[3])
                windower.prim.set_position(id,x+1+start,y+1)
                windower.prim.set_size(id,count,height)
                windower.prim.set_visibility(id,true)
            else
                windower.prim.set_visibility(id,false)
            end
        end
        return height+2
    end

    function self:edit(toggle)
        if toggle==nil then toggle=not self.editing end
        self.editing=toggle
        if not toggle then self.scaling=false; self.scalehandle:hide() end
        self.panel:draggable(toggle)
        if toggle then
            self.handle:pos(self.options.bar.x,self.options.bar.y-19)
            self.handle:show()
            self.panel:pos(self.options.list.x,self.options.list.y)
            self.panel:show()
        else
            self.handle:hide()
        end
        return toggle
    end

    function self:scale(n)
        self.options.scale=clamp(n,.5,2.5)
        self.panel:size(math.max(7,math.floor(11*self.options.scale+.5)))
        self.handle:size(math.max(7,math.floor(10*self.options.scale+.5)))
        self.scalehandle:size(math.max(7,math.floor(10*self.options.scale+.5)))
    end

    -- Drag the separate scaling handle horizontally. This changes thickness,
    -- spacing and typography, but keeps the bar's HP-matched width independent.
    function self:scale_edit(toggle)
        if toggle==nil then toggle=not self.scaling end
        if toggle then
            self:edit(true)
            self.scalehandle:pos(self.options.bar.x+math.floor(100*self.options.scale+.5),
                self.options.bar.y-36)
            self.scalehandle:show()
        else
            self.scalehandle:hide()
        end
        self.scaling=toggle
        return toggle
    end

    function self:render(state)
        local opt=self.options
        if self.editing then
            -- Position follows draggable text objects. Saving happens when
            -- the user exits edit mode; no writes on every frame.
            local hx,hy=self.handle:pos()
            opt.bar.x, opt.bar.y = math.floor(hx+.5),math.floor(hy+19+.5)
            local px,py=self.panel:pos()
            opt.list.x,opt.list.y=math.floor(px+.5),math.floor(py+.5)
            if self.scaling then
                local sx=self.scalehandle:pos()
                local value=clamp((sx-opt.bar.x)/100,.5,2.5)
                if math.abs(value-opt.scale) > .015 then self:scale(value) end
            end
            state=state or {
                active={'Fusion'},step=2,sc_left=5,sc_total=8,
                sc_wait=0,mb_left=7,mb_total=10,closed=false,
                groups={{level=3,property='Light',
                    actions={{name='Savage Blade',via='Fragmentation'}}}},
            }
        elseif not state then
            self:hide()
            return
        end

        state.sc_info=self.sc_info
        local mode=opt.display
        local show_sc=(mode=='sc' or mode=='both')
        local show_mb=(mode=='mb' or mode=='both')
        local sc_alive=show_sc and state.sc_left and state.sc_left>0 and not state.closed
        local mb_alive=show_mb and state.mb_left and state.mb_left>0 and state.step>1
        self:hide_bars()
        local y=math.floor(opt.bar.y+.5)
        if sc_alive then
            local total=math.max(.1,state.sc_total or 8)
            local fraction=state.sc_left/total
            self:draw_bar('sc',y,fraction,state.sc_wait>0,palette(state,self.sc_info,false))
            y=y+math.max(3,math.floor(5*opt.scale+.5))+math.max(4,math.floor(5*opt.scale+.5))
        end
        if mb_alive then
            local total=math.max(.1,state.mb_total or 10)
            self:draw_bar('mb',y,state.mb_left/total,false,palette(state,self.sc_info,true))
        end
        if opt.mode=='learn' and (sc_alive or mb_alive or self.editing) then
            self.panel:text(format_list(state,show_sc,show_mb))
            self.panel:show()
        elseif opt.mode=='compact' and (sc_alive or mb_alive or self.editing) then
            local str=table.concat(state.active or {},', ')
            if sc_alive then str=str..('  SC %.1fs'):format(state.sc_left) end
            if mb_alive then str=str..('  MB %.1fs'):format(state.mb_left) end
            self.panel:text(str)
            self.panel:show()
        else
            if self.editing then
                self.panel:text('SC LEARNING PANEL  [drag]')
                self.panel:show()
            else
                self.panel:hide()
            end
        end
    end

    function self:destroy()
        self.panel:destroy()
        self.handle:destroy()
        self.scalehandle:destroy()
        for _,bar in pairs(self.names) do
            windower.prim.delete(bar.frame)
            windower.prim.delete(bar.base)
            for i=1,segments do windower.prim.delete(bar.slices[i]) end
        end
    end
    return self
end

return ui
