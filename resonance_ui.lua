-- Resonance display for Skillchains (testing branch).
-- Rendering belongs here; action-packet interpretation stays in Skillchains.lua.
-- The bars and learning panel are independent of EnemyBar2 and XIVCrossbar.
local texts = require('texts')
local images = require('images')
local learning = require('learning_ui')
local resonance_fx = require('resonance_fx')
local ui = {}

local elements = {
    Fire={224,94,76}, Ice={147,215,235}, Wind={117,193,132},
    Earth={178,141,93}, Lightning={193,145,221}, Water={85,145,221},
    Light={242,232,201}, Dark={78,63,111},
}
local fallback = {185,171,204}
local segments = 24
local bar_handle_offset = 34
local scale_handle_offset = 62
local abbreviations = {
    Liquefaction='LQF', Induration='IND', Detonation='DET', Scission='SCI',
    Impaction='IMP', Reverberation='RVB', Transfixion='TRN', Compression='COM',
    Fusion='FUS', Fragmentation='FRG', Distortion='DST', Gravitation='GRV',
    Light='LGT', Darkness='DRK', Radiance='RAD', Umbra='UMB',
}
local function viewport()
    local size=windower.get_windower_settings() or {}
    return size.ui_x_res or size.x_res or 1280,
        size.ui_y_res or size.y_res or 720
end

local function clamp(v, lo, hi)
    return math.max(lo, math.min(hi, v))
end

-- Shared screen-origin grid: snap the widget's anchor, never individual
-- primitives. Floor matches BarFiller2/EnemyBar2; retain bounds on small UIs.
local function snap_axis(pixel, grid, minimum, maximum)
    local value=math.floor(clamp(pixel,minimum,maximum)/grid)*grid
    if value<minimum then
        local first=math.ceil(minimum/grid)*grid
        return first<=maximum and first or minimum
    end
    return value
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
        -- Only the first weapon skill property drives an opener's color.
        -- If that property itself has multiple elements, keep its gradient.
        if burst or state and state.step==1 then break end
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

-- The currently reverberating properties belong visually to the target.
-- Render every opening WS property; replace with the successful chain result.
-- Always display the expiry countdown with the corresponding bar caption.
-- Reserve enough horizontal space for the suffix when wrapping long names.
local function countdown(seconds)
    return ('%.1fs'):format(math.max(0,seconds or 0))
end

local function properties_label(properties, width, text_object, form, timer)
    local lines, current = {}, ''
    for _,original in ipairs(properties or {}) do
        local name=form=='short' and (abbreviations[original] or original) or original
        local joiner=form=='short' and ' / ' or ', '
        local next_line = current == '' and name or (current .. joiner .. name)
        text_object:text(next_line)
        local measured = text_object:extents()
        if current ~= '' and measured > width then
            lines[#lines+1] = current
            current = name
        else
            current = next_line
        end
    end
    if timer then
        local next_line = current == '' and timer or (current .. '  ' .. timer)
        text_object:text(next_line)
        if current ~= '' and text_object:extents() > width then
            lines[#lines+1] = current
            current = timer
        else
            current = next_line
        end
    end
    if current ~= '' then lines[#lines+1] = current end
    return table.concat(lines, '\n'), math.max(1,#lines)
end

-- The detection core already groups possible learned actions by their
-- resulting skillchain and sorts those groups by level (highest first).
-- Display the useful names directly, without redundant level/step headings.

function ui.new(settings, sc_info)
    local self = {options=settings, sc_info=sc_info, editing=false, names={},
        ctrl_keys={[29]=false,[157]=false}}
    -- Native Windower text handles retain mouse capture. Keyboard events
    -- only update modifier state; no mouse or key events are consumed.
    function self:set_ctrl(dik, down)
        if self.ctrl_keys[dik]~=nil then
            self.ctrl_keys[dik]=down and true or false
        end
    end
    function self:grid_active()
        return self.ctrl_keys[29] or self.ctrl_keys[157]
    end
    function self:anchor(value,minimum,maximum)
        local rounded=math.floor(clamp(value,minimum,maximum)+.5)
        if self:grid_active() then
            local grid=tonumber(self.options.grid) or 10
            if grid>=1 and grid<math.huge and grid==math.floor(grid) then
                return snap_axis(rounded,grid,minimum,maximum)
            end
        end
        return rounded
    end
    local prefix = 'sc_resonance_'
    for _,kind in ipairs({'sc','mb'}) do
        self.names[kind] = {
            frame=prefix..kind..'_frame', base=prefix..kind..'_base',
            cap_l=prefix..kind..'_cap_l', cap_r=prefix..kind..'_cap_r',
            fill_l=prefix..kind..'_fill_l', fill_r=prefix..kind..'_fill_r',
            slices={},hidden=true,
        }
        local bar=self.names[kind]
        -- At a 5px bar height, omitting one pixel in each corner is enough
        -- to suggest a capsule without texture assets or antialiasing.
        -- The underlying tracks are darker and somewhat transparent.
        create_prim(bar.frame,180,9,10,21)
        create_prim(bar.cap_l,180,9,10,21)
        create_prim(bar.cap_r,180,9,10,21)
        create_prim(bar.base,115,18,21,39)
        create_prim(bar.fill_l,220,200,190,220)
        create_prim(bar.fill_r,220,200,190,220)
        for i=1,segments do
            local id=prefix..kind..'_'..i
            create_prim(id,220,200,190,220)
            bar.slices[i]=id
        end
    end

    -- Effects are created AFTER the SC bar prims so their softened sprites
    -- can bloom over the gauge. Their alpha textures contain no hard boxes.
    self.fx=resonance_fx.new('sc_resonance_fx_')

    -- EnemyBar2 target names use Arial, bold, italic, and a dark stroke.
    -- The smaller label is attached to the bar, not the draggable learning panel.
    self.properties = texts.new('', {
        pos={x=settings.bar.x+3,y=settings.bar.y+7},
        flags={bold=true,italic=true,draggable=false},
        text={font='Arial',size=10,alpha=245,red=255,green=255,blue=255,
            stroke={width=2,alpha=235,red=0,green=0,blue=0}},
        bg={visible=false}
    })
    self.mb_caption = texts.new('', {
        pos={x=settings.bar.x+3,y=settings.bar.y+7},
        flags={bold=true,italic=true,draggable=false},
        text={font='Arial',size=10,alpha=245,red=255,green=255,blue=255,
            stroke={width=2,alpha=235,red=0,green=0,blue=0}},
        bg={visible=false}
    })
    self.property_cache = nil
    self.mb_caption_cache = nil
    self.caption_icons = {sc={},mb={}}
    -- The same small source PNGs used in the Learn column also precede
    -- the attached SC property names and the Magic Burst label.
    function self:place_caption_icons(kind,properties,x,y,scale,opacity)
        local slots=self.caption_icons[kind]
        local icon_size=math.max(7,math.floor(10*scale+.5))
        local gap=math.max(1,math.floor(scale+.5))
        -- Match the user's preferred SC baseline and permit fine adjustment
        -- independent from //sc names offset (which still moves both).
        local extra=kind=='sc' and (self.options.icon_offset or {x=0,y=0})
            or {x=0,y=0}
        x=x+(extra.x or 0)
        y=y+math.max(2,math.floor(5*scale+.5))+(extra.y or 0)
        for i,property in ipairs(properties or {}) do
            local filename=(property=='Radiance' and 'light'
                or property=='Umbra' and 'darkness' or property:lower())..'.png'
            local path=windower.addon_path..'images/skillchain/'..filename
            local slot=slots[i]
            if not slot then
                slot={path=path,image=images.new('',{
                    pos={x=x,y=y},visible=false,draggable=false,
                    size={width=icon_size,height=icon_size},
                    color={alpha=240,red=255,green=255,blue=255},
                    texture={path=path,fit=false}
                })}
                slots[i]=slot
            elseif slot.path~=path then
                slot.image:path(path);slot.path=path
            end
            slot.image:size(icon_size,icon_size)
            slot.image:pos(x+(i-1)*(icon_size+gap),y)
            slot.image:alpha(math.floor(240*clamp(opacity or 1,0,1)+.5))
            slot.image:show()
        end
        for i=#(properties or {})+1,#slots do slots[i].image:hide() end
        return #(properties or {})>0 and (#properties*icon_size+
            math.max(0,#properties-1)*gap+1) or 0
    end
    function self:hide_caption_icons(kind)
        for _,slot in ipairs(self.caption_icons[kind]) do slot.image:hide() end
    end
    self.panel_cache = nil
    self.is_hidden = true
    self.handle = texts.new('SC BAR  [drag]', text_settings(settings.bar.x,settings.bar.y-bar_handle_offset,10,true))
    self.scalehandle = texts.new('SC SCALE  [drag left/right]',
        text_settings(settings.bar.x+math.floor(100*settings.scale+.5),
            settings.bar.y-scale_handle_offset,10,true))
    self.scaling = false
    self.panel = texts.new('LEARNING  [drag]', text_settings(settings.list.x,settings.list.y,
        math.floor(11*settings.scale+.5),false))
    -- The same element palette drives the bar and ability suggestions.
    -- Lighten dark stop colors to keep small stroked text legible.
    self.learning = learning.new(function(result)
        local col=interpolate(palette({active={result}},sc_info,false),.5)
        return {math.floor(col[1]*.70+255*.30+.5),
            math.floor(col[2]*.70+255*.30+.5),
            math.floor(col[3]*.70+255*.30+.5)}
    end)
    self.handle:hide()
    self.scalehandle:hide()
    self.panel:hide()
    self.properties:hide()
    self.mb_caption:hide()

    -- list.y is the BOTTOM edge of the learning panel; new lines grow upward.
    function self:panel_height()
        if not self.panel_height_px then
            local _,h=self.panel:extents()
            -- Windower text extents cover the glyphs, not our background
            -- padding. Cache the size until the panel text or scale changes.
            self.panel_height_px=math.max(16,math.floor((h or 0)+8+.5))
        end
        return self.panel_height_px
    end

    function self:position_panel()
        local x=self.options.list.x
        local y=math.floor(self.options.list.y-self:panel_height()+.5)
        local px,py=self.panel:pos()
        if px~=x or py~=y then self.panel:pos(x,y) end
    end

    function self:hide_bar(kind)
        local bar=self.names[kind]
        if bar.hidden then return end
        for _,id in ipairs({bar.frame,bar.base,bar.cap_l,bar.cap_r,
            bar.fill_l,bar.fill_r}) do
            windower.prim.set_visibility(id,false)
        end
        for i=1,segments do
            windower.prim.set_visibility(bar.slices[i],false)
        end
        bar.hidden=true
    end

    function self:hide_bars()
        self:hide_caption_icons('sc')
        self:hide_caption_icons('mb')
        self.properties:hide()
        self.mb_caption:hide()
        for kind in pairs(self.names) do self:hide_bar(kind) end
        self.fx:hide()
    end

    function self:hide()
        if self.is_hidden and not self.editing then return end
        self.learning:hide()
        self:hide_bars()
        self.is_hidden=true
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
        bar.hidden=false
        local opts=self.options
        local x=math.floor(opts.bar.x+(self.bar_shake or 0)+.5)
        local width=math.max(24,math.floor(opts.bar.width+.5))
        local height=math.max(3,math.floor(5*opts.scale+.5))
        local fill=math.floor(clamp(fraction,0,1)*(width-2)+.5)

        -- During the first opener beat the underlying bar is fully hidden
        -- behind the free-standing white expansion. Do not pointlessly
        -- update all 24 gradient segments ~30 times per second. This also
        -- avoids hidden-primitive visibility churn on multi-client setups.
        local fully_hidden=kind=='sc' and
            (self.bar_opacity or 1)<=0 and (self.base_opacity or 1)<=0
        if fully_hidden then
            if not bar.visual_hidden then
                for _,id in ipairs({bar.frame,bar.cap_l,bar.cap_r,bar.base,
                    bar.fill_l,bar.fill_r}) do
                    windower.prim.set_visibility(id,false)
                end
                for _,id in ipairs(bar.slices) do
                    windower.prim.set_visibility(id,false)
                end
            end
            bar.visual_hidden=true
            return height+2
        end
        bar.visual_hidden=false

        -- Dark rounded outline: a central rectangle with 1px-inset endcaps.
        windower.prim.set_position(bar.frame,x+1,y)
        windower.prim.set_size(bar.frame,width-2,height+2)
        windower.prim.set_visibility(bar.frame,true)
        windower.prim.set_position(bar.cap_l,x,y+1)
        windower.prim.set_size(bar.cap_l,1,height)
        windower.prim.set_visibility(bar.cap_l,true)
        windower.prim.set_position(bar.cap_r,x+width-1,y+1)
        windower.prim.set_size(bar.cap_r,1,height)
        windower.prim.set_visibility(bar.cap_r,true)

        windower.prim.set_position(bar.base,x+1,y+1)
        -- The dark, translucent empty track NEVER participates in the
        -- countdown-opacity wave. Only the opener's initial reveal hides it.
        windower.prim.set_color(bar.base,math.floor(115*
            clamp(self.base_opacity or 1,0,1)+.5),18,21,39)
        windower.prim.set_size(bar.base,width-2,height)
        windower.prim.set_visibility(bar.base,true)

        -- Update the gradient at the new absolute-time fraction. Do not
        -- tween between distinct weapon skills; only each expiry runs smoothly.
        -- Absolute deadline still controls LENGTH. The separate brightness
        -- tween is continuous across prewindow -> active-window transition.
        local alpha=230*clamp(self.bar_brightness or 1,0,1)*
            clamp(self.bar_opacity or 1,0,1)
        for i=1,segments do
            local id=bar.slices[i]
            local start=math.floor((i-1)*fill/segments)
            local finish=math.floor(i*fill/segments)
            local draw_x=x+1+start
            local count=finish-start
            if start==0 then draw_x=draw_x+1;count=count-1 end
            if finish==fill then count=count-1 end
            if count>0 then
                local c=interpolate(palette_stops,(i-.5)/segments)
                windower.prim.set_color(id,math.floor(alpha+.5),c[1],c[2],c[3])
                windower.prim.set_position(id,draw_x,y+1)
                windower.prim.set_size(id,count,height)
                windower.prim.set_visibility(id,true)
            else
                windower.prim.set_visibility(id,false)
            end
        end
        -- Narrowed end pixels give the filled portion matching rounded ends.
        local cap_h=math.max(1,height-2)
        for _,entry in ipairs({
            {id=bar.fill_l,pos=x+1,color=palette_stops[1]},
            {id=bar.fill_r,pos=x+fill,color=palette_stops[#palette_stops]}
        }) do
            if fill>0 and (entry.id~=bar.fill_r or fill>1) then
                local c=entry.color
                windower.prim.set_color(entry.id,math.floor(alpha+.5),c[1],c[2],c[3])
                windower.prim.set_position(entry.id,entry.pos,y+2)
                windower.prim.set_size(entry.id,1,cap_h)
                windower.prim.set_visibility(entry.id,true)
            else
                windower.prim.set_visibility(entry.id,false)
            end
        end
        return height+2
    end

    -- A saved position from a larger client may put every drag handle beyond
    -- a smaller client's viewport. Recover the layout on entering edit mode.
    function self:rescue()
        local w,h=viewport()
        local opt=self.options
        local max_x=math.max(8,w-90)
        local max_y=math.max(42,h-55)
        opt.bar.x=math.floor(clamp(opt.bar.x,8,max_x)+.5)
        opt.bar.y=math.floor(clamp(opt.bar.y,42,max_y)+.5)
        opt.list.x=math.floor(clamp(opt.list.x,8,math.max(8,w-135))+.5)
        -- The saved anchor is the lower edge, regardless of line count.
        opt.list.y=math.floor(clamp(opt.list.y,20,math.max(20,h-12))+.5)
        self.handle:pos(opt.bar.x,opt.bar.y-bar_handle_offset)
        self.panel:pos(opt.list.x,opt.list.y-24)
        if self.scaling then
            self:place_scalehandle()
        end
    end

    function self:set_position(x,y)
        self.options.bar.x=x
        self.options.bar.y=y
        self:rescue()
    end

    function self:center()
        local w,h=viewport()
        local opt=self.options
        opt.bar.x=math.floor((w-opt.bar.width)/2)
        opt.bar.y=math.floor(h*.65)
        opt.list.x=math.floor(math.max(8,(w-265)/2))
        opt.list.y=math.floor(h*.65)
        self:rescue()
    end

    -- Anchoring relative to the visible handle avoids losing the scale
    -- control when the SC bar is close to the right edge of a small client.
    function self:place_scalehandle()
        local w,h=viewport()
        local x=clamp(self.options.bar.x+100*self.options.scale,8,math.max(8,w-185))
        local y=clamp(self.options.bar.y-scale_handle_offset,5,math.max(5,h-22))
        self.scalehandle:pos(x,y)
        self.scale_anchor=x-100*self.options.scale
    end

    function self:edit(toggle)
        if toggle==nil then toggle=not self.editing end
        self.editing=toggle
        if not toggle then self.scaling=false; self.scalehandle:hide() end
        self.panel:draggable(toggle)
        if toggle then
            self:rescue()
            self.handle:show()
            self:set_panel_text('LEARNING  [drag]')
            self.panel:show()
            self.panel_drag_x,self.panel_drag_y=self.panel:pos()
        else
            self.handle:hide()
        end
        return toggle
    end

    function self:scale(n)
        self.options.scale=clamp(n,.5,2.5)
        self.panel:size(math.max(7,math.floor(11*self.options.scale+.5)))
        self.panel_height_px=nil
        self.handle:size(math.max(7,math.floor(10*self.options.scale+.5)))
        self.scalehandle:size(math.max(7,math.floor(10*self.options.scale+.5)))
        self.properties:size(math.max(7,math.floor(10*self.options.scale+.5)))
        self.properties:stroke_width(math.max(1,math.floor(1.5*self.options.scale+.5)))
        self.mb_caption:size(math.max(7,math.floor(10*self.options.scale+.5)))
        self.mb_caption:stroke_width(math.max(1,math.floor(1.5*self.options.scale+.5)))
        self.property_cache=nil
    end

    -- Drag the separate scaling handle horizontally. This changes thickness,
    -- spacing and typography, but keeps the bar's HP-matched width independent.
    function self:scale_edit(toggle)
        if toggle==nil then toggle=not self.scaling end
        if toggle then
            self:edit(true)
            self:place_scalehandle()
            self.scalehandle:show()
        else
            self.scalehandle:hide()
        end
        self.scaling=toggle
        return toggle
    end

    function self:set_panel_text(str)
        -- A long list of compatible abilities is static until the next
        -- skillchain event. Rebuilding it 30 times a second wastes resources.
        if str~=self.panel_cache then
            self.panel:text(str)
            self.panel_cache=str
            self.panel_height_px=nil
        end
    end

    function self:render(state)
        local opt=self.options
        if self.editing then
            -- Position follows draggable text objects. Saving happens when
            -- the user exits edit mode; no writes on every frame.
            local w,h=viewport()
            local hx,hy=self.handle:pos()
            local bx,by=opt.bar.x,opt.bar.y
            -- A pressed Ctrl without mouse movement must not jump an
            -- already-placed widget onto the grid.
            if hx~=opt.bar.x or hy+bar_handle_offset~=opt.bar.y then
                bx=self:anchor(hx,8,math.max(8,w-90))
                by=self:anchor(hy+bar_handle_offset,42,math.max(42,h-55))
                opt.bar.x,opt.bar.y=bx,by
                if bx~=hx or by-bar_handle_offset~=hy then
                    self.handle:pos(bx,by-bar_handle_offset)
                end
            end
            -- The edit guide is not the list itself. Track its movement
            -- delta so a changing number of suggestions cannot jump rows.
            local px,py=self.panel:pos()
            if self.panel_drag_x and self.panel_drag_y
                and (px~=self.panel_drag_x or py~=self.panel_drag_y) then
                -- list.x and list.y are the panel's own anchor (lower edge).
                -- Only the anchor snaps; pooled text/icons remain local to it.
                local nx=opt.list.x+px-self.panel_drag_x
                local ny=opt.list.y+py-self.panel_drag_y
                opt.list.x=self:anchor(nx,8,math.max(8,w-215))
                opt.list.y=self:anchor(ny,25,math.max(25,h-12))
            end
            self.panel_drag_x,self.panel_drag_y=px,py
            if self.scaling then
                local sx=self.scalehandle:pos()
                local value=clamp((sx-(self.scale_anchor or bx))/100,.5,2.5)
                if math.abs(value-opt.scale) > .015 then self:scale(value) end
            end
            state=state or {
                now=os.clock(),created=os.clock()-5,sc_open=os.clock()-2,
                active={'Fusion'},level=2,step=2,sc_left=5,sc_total=8,
                sc_wait=0,mb_left=7,mb_total=10,closed=false,
                groups={
                    {level=3,property='Light',actions={
                        {name='Savage Blade',properties={'Fragmentation','Scission'}}}},
                    {level=2,property='Gravitation',actions={
                        {name='Swift Blade',properties={'Gravitation'}}}},
                    {level=1,property='Liquefaction',actions={
                        {name='Example Ability',properties={'Liquefaction','Detonation'}}}},
                },
            }
        elseif not state then
            self:hide()
            return
        end

        self.is_hidden=false
        state.sc_info=self.sc_info
        local mode=opt.display
        local show_sc=(mode=='sc' or mode=='both')
        local show_mb=(mode=='mb' or mode=='both')
        local sc_alive=show_sc and (state.sc_left or 0)>0 and not state.closed
        local fading_opener=show_sc and state.step==1 and
            state.expire_age~=nil and state.expire_age<.35
        sc_alive=sc_alive or fading_opener
        local mb_alive=show_mb and state.mb_left and state.mb_left>0 and state.step>1
        -- Avoid hiding the active bar between frames; this also eliminates
        -- repeated visibility flicker at higher redraw rates.
        if not sc_alive then
            self.fx:hide()
            self:hide_caption_icons('sc')
            self:hide_bar('sc')
            self.properties:hide()
        end
        if not mb_alive then self:hide_caption_icons('mb');self:hide_bar('mb') end
        local y=math.floor(opt.bar.y+.5)
        if sc_alive then
            local total=math.max(.1,state.sc_total or 8)
            local effects=opt.animation or {enabled=true,intensity=1,fade=false}
            local fraction=self.fx:bar_fraction(state,effects)
            local result_color=palette(state,self.sc_info,false)
            local bar_color=result_color
            -- From a successful chain's first white flash, cross-fade the
            -- entire gradient from the previous property to the new result.
            local tween=self.fx:palette_blend(state)
            if state.from_active and tween<1 then
                local prior=palette({active=state.from_active,step=1},
                    self.sc_info,false)
                bar_color={}
                for i=1,segments do
                    bar_color[i]=interpolate({
                        interpolate(prior,(i-.5)/segments),
                        interpolate(result_color,(i-.5)/segments)},tween)
                end
            end
            self.bar_brightness=state.step==1 and
                self.fx:open_brightness(state) or
                self.fx:chain_brightness(state)
            local reveal=self.fx:bar_reveal(state,effects)
            self.bar_opacity=self.fx:opacity(state,effects)*reveal
            self.base_opacity=reveal
            self.bar_shake=self.fx:shake(state,effects)
            local shake=self.bar_shake
            local bar_height=self:draw_bar('sc',y,fraction,state.sc_wait>0,
                bar_color)
            self.bar_shake,self.bar_opacity,self.bar_brightness,self.base_opacity=
                0,1,1,1
            local fill=math.floor(clamp(fraction,0,1)*(opt.bar.width-2)+.5)
            self.fx:render(state,effects,{
                x=math.floor(opt.bar.x+shake+.5),y=y,
                width=math.floor(opt.bar.width+.5),
                height=math.max(3,math.floor(5*opt.scale+.5))+2,
                fill=fill,frame=self.names.sc,scale=opt.scale},result_color)
            y=y+bar_height
            local reveal=self.fx:label_alpha(state,effects)
            if opt.mode~='minimal' and opt.names~='off' then
                local inset=math.max(2,math.floor(3*opt.scale+.5))
                local name_offset=opt.name_offset or {x=0,y=0}
                local caption_gap=math.max(1,math.floor(2*opt.scale+.5))
                local caption_y=y+caption_gap+name_offset.y
                local icon_width=self:place_caption_icons('sc',state.active,
                    math.floor(opt.bar.x+inset+name_offset.x+.5),caption_y,opt.scale,reveal)
                local label_width=math.max(30,opt.bar.width-inset*2-icon_width)
                local signature=table.concat(state.active or {},'|')
                    ..':'..tostring(label_width)..':'..tostring(opt.scale)
                    ..':'..tostring(opt.names or 'full')
                    ..':'..countdown(state.sc_left)
                if signature~=self.property_cache then
                    local label,rows=properties_label(state.active,label_width,
                        self.properties,opt.names or 'full',countdown(state.sc_left))
                    self.properties:text(label)
                    self.property_rows=rows
                    self.property_cache=signature
                end
                -- Apply the user's offset after the bar-relative anchor.
                -- Icons occupy a small prefix, while names and timer wrap.
                self.properties:pos(math.floor(opt.bar.x+inset+name_offset.x+icon_width+.5),
                    caption_y)
                self.properties:alpha(math.floor(245*reveal+.5))
                self.properties:stroke_alpha(math.floor(235*reveal+.5))
                self.properties:show()
                -- Positive Y needs extra clearance for the optional MB bar;
                -- negative Y does not collapse the normal safe spacing.
                y=y+caption_gap
                    + (self.property_rows or 1)*math.max(9,math.floor(12*opt.scale+.5))
                    + math.max(2,math.floor(3*opt.scale+.5))
                    + math.max(0,name_offset.y)
            else
                self:hide_caption_icons('sc')
                self.properties:hide()
                y=y+math.max(4,math.floor(5*opt.scale+.5))
            end
        end
        if mb_alive then
            local total=math.max(.1,state.mb_total or 10)
            local mb_height=self:draw_bar('mb',y,state.mb_left/total,false,
                palette(state,self.sc_info,true))
            if opt.mode~='minimal' then
                local caption='Magic Burst: '..countdown(state.mb_left)
                if caption~=self.mb_caption_cache then
                    self.mb_caption:text(caption)
                    self.mb_caption_cache=caption
                end
                local offset=opt.name_offset or {x=0,y=0}
                local gap=math.max(1,math.floor(2*opt.scale+.5))
                local inset=math.max(2,math.floor(3*opt.scale+.5))
                local bx=math.floor(opt.bar.x+inset+offset.x+.5)
                local by=y+mb_height+gap+offset.y
                local icon_w=self:place_caption_icons('mb',
                    {state.active and state.active[1] or 'Light'},bx,by,opt.scale)
                self.mb_caption:pos(bx+icon_w,by)
                self.mb_caption:show()
            else
                self:hide_caption_icons('mb')
                self.mb_caption:hide()
            end
        else
            self:hide_caption_icons('mb')
            self.mb_caption:hide()
        end
        if opt.mode=='learn' and (sc_alive or self.editing) then
            -- Color represents the predicted RESULT. Icons represent the
            -- action's own skillchain properties (possibly several).
            self.learning:render(state.groups or {},opt.list.x,opt.list.y,opt.scale,
                self.editing and 1 or self.fx:label_alpha(state,opt.animation or {}))
            if not self.editing then self.panel:hide() end
        else
            self.learning:hide()
            if opt.mode=='compact' and not self.editing and (sc_alive or mb_alive) then
                local values={}
                if sc_alive then values[#values+1]=('SC %.1fs'):format(state.sc_left) end
                if mb_alive then values[#values+1]=('MB %.1fs'):format(state.mb_left) end
                self:set_panel_text(table.concat(values,'  /  '))
                local fade=self.fx:label_alpha(state,opt.animation or {})
                self.panel:alpha(math.floor(245*fade+.5))
                self.panel:stroke_alpha(math.floor(210*fade+.5))
                self:position_panel()
                self.panel:show()
            elseif not self.editing then
                self.panel:hide()
            end
        end
        if self.editing then
            self:set_panel_text('LEARNING  [drag]')
            -- Place the small draggable guide just above the visible rows.
            local guide_height=math.max(20,math.floor(23*opt.scale+.5))
            local py=math.max(2,math.floor(opt.list.y-self.learning:height()-guide_height+.5))
            self.panel:pos(opt.list.x,py)
            self.panel_drag_x,self.panel_drag_y=opt.list.x,py
            self.panel:show()
        end
    end

    function self:destroy()
        for _,slots in pairs(self.caption_icons) do
            for _,slot in ipairs(slots) do slot.image:destroy() end
        end
        self.fx:destroy()
        self.learning:destroy()
        self.properties:destroy()
        self.mb_caption:destroy()
        self.panel:destroy()
        self.handle:destroy()
        self.scalehandle:destroy()
        for _,bar in pairs(self.names) do
            for _,id in ipairs({bar.frame,bar.base,bar.cap_l,bar.cap_r,
                bar.fill_l,bar.fill_r}) do
                windower.prim.delete(id)
            end
            for i=1,segments do windower.prim.delete(bar.slices[i]) end
        end
    end
    return self
end

return ui
