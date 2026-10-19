-- Ability-first Skillchains learning display.
-- This renderer only PRESENTS predictions; Skillchains.lua owns the FFXI
-- priority rules and chooses exactly one resulting chain for each action.
local texts=require('texts')
local images=require('images')
local M={}
local fallback={Radiance='light',Umbra='darkness'}
local function clamp(x,lo,hi) return math.max(lo,math.min(hi,x)) end
local function viewport()
    local w=windower.get_windower_settings() or {}
    return w.ui_x_res or w.x_res or 1280,w.ui_y_res or w.y_res or 720
end
local function glyph(name)
    return (fallback[name] or name:lower())..'.png'
end
local function flatten(groups)
    local rows={}
    for _,group in ipairs(groups or {}) do
        for _,action in ipairs(group.actions or {}) do
            rows[#rows+1]={name=action.name,result=group.property,
                properties=action.properties or {}}
        end
    end
    return rows
end
local function make_label(size)
    return texts.new('',{
        pos={x=0,y=0},
        flags={draggable=false,bold=true,italic=true},
        text={font='Arial',size=size,alpha=245,red=240,green=240,blue=240,
            stroke={width=2,alpha=235,red=0,green=0,blue=0}},
        bg={visible=false}
    })
end
local function make_icon(path,size)
    return images.new('',{
        pos={x=0,y=0},visible=false,draggable=false,
        size={width=size,height=size},
        color={alpha=240,red=255,green=255,blue=255},
        texture={path=path,fit=false} -- otherwise native PNG size overrides UI sizing
    })
end
function M.new(color_for_result)
    local self={rows={},color_for_result=color_for_result,
        icon_root=windower.addon_path..'images/skillchain/',
        displayed=0,height_px=0}
    function self:hide()
        for _,row in ipairs(self.rows) do
            row.label:hide()
            for _,icon in ipairs(row.icons) do icon.image:hide() end
        end
        self.displayed=0
        self.height_px=0
    end
    function self:height() return self.height_px end
    function self:ensure_row(i,size)
        local row=self.rows[i]
        if not row then
            row={label=make_label(size),icons={},last_name=nil,last_color=nil}
            self.rows[i]=row
        end
        return row
    end
    function self:render(groups,x,bottom,scale,opacity)
        local width,height=viewport()
        local alpha=math.floor(245*clamp(opacity or 1,0,1)+.5)
        x=clamp(x,8,math.max(8,width-215))
        bottom=clamp(bottom,25,math.max(25,height-12))
        local rh=math.max(12,math.floor(18*scale+.5))
        local font=math.max(7,math.floor(11*scale+.5))
        local glyphsize=math.max(5,math.floor(font*.78+.5)) -- visual glyph smaller than letters
        local gap=math.max(3,math.floor(4*scale+.5))
        local all=flatten(groups)
        if #all==0 then all[1]={name='No compatible learned actions',properties={}} end
        -- One fixed icon COLUMN starts just after the widest learned name.
        -- Recompute from unscaled text metrics each time the list changes;
        -- reserve room for every property in dual/multi-property abilities.
        local longest,max_icons=0,0
        -- The original invisible probe underestimated Windower's italic,
        -- stroked text. Use the SAME pooled label instances we actually
        -- render, and conservatively allow for italic overhang and stroke.
        -- The fallback is deliberate: fonts can report glyph extents smaller
        -- than their visible raster bounds before their first visible frame.
        local stroke=math.max(1,math.floor(1.5*scale+.5))
        for i,item in ipairs(all) do
            max_icons=math.max(max_icons,math.min(6,#item.properties))
            local row=self:ensure_row(i,font)
            if row.measure_name~=(item.name or '') or row.measure_font~=font then
                row.label:size(font)
                row.label:stroke_width(stroke)
                row.label:text(item.name or '')
                row.measured_width=tonumber(row.label:extents()) or 0
                row.measure_name=item.name or ''
                row.measure_font=font
                row.last_name=nil -- The row may need ellipsis with the new column.
            end
            local fallback_width=#(item.name or '')*font*.82
            longest=math.max(longest,row.measured_width+2*stroke,
                fallback_width+2*stroke)
        end
        local max_available=math.max(65,width-x-8)
        local icons_width=max_icons>0 and
            max_icons*glyphsize+(max_icons-1)*gap or 0
        -- Give lettering and its black outline 8px of breathing space.
        local column_gap=math.max(8,math.floor(8*scale+.5))+stroke
        local reserved=max_icons>0 and (icons_width+column_gap) or 0
        local label_width=math.max(32,math.min(math.ceil(longest+2),
            max_available-reserved))
        local column_x=x+label_width+column_gap
        self.icon_column_x=column_x
        self.label_width=label_width
        self.icon_column_gap=column_gap
        local label_max=label_width-stroke
        local limit=math.max(0,math.floor((bottom-9)/rh))
        local visible=math.min(#all,limit)
        local truncated=#all>visible
        if truncated and visible>0 then visible=visible-1 end
        local count=visible+(truncated and limit>0 and 1 or 0)
        self.height_px=count*rh
        self.displayed=count
        local top=bottom-self.height_px
        for i=1,count do
            local item=all[i]
            if i>visible then item={name='+'..(#all-visible)..' more',properties={}} end
            local row=self:ensure_row(i,font)
            if row.last_font~=font then
                row.label:size(font)
                row.label:stroke_width(math.max(1,math.floor(1.5*scale+.5)))
            end
            local c=item.result and self.color_for_result(item.result) or {205,205,210}
            local color_key=table.concat(c,',')
            if row.last_color~=color_key then
                row.label:color(c[1],c[2],c[3]);row.last_color=color_key
            end
            local n=math.min(#item.properties,6)
            -- Keep long names out of the property-icon column.
            if row.last_name~=item.name or row.last_max~=label_max or row.last_font~=font then
                local label=item.name or ''
                row.label:text(label)
                while #label>4 do
                    local measured=tonumber(row.label:extents()) or 0
                    local conservative=#label*font*.82
                    if math.max(measured,conservative)+2*stroke<=label_max then break end
                    label=label:sub(1,-2)
                    row.label:text(label..'...')
                end
                if label~=item.name then label=label..'...' end
                row.label:text(label)
                row.last_name=item.name;row.last_max=label_max;row.last_font=font
            end
            local yy=math.floor(top+(i-1)*rh+.5)
            if row.last_x~=x or row.last_y~=yy then
                row.label:pos(x,yy)
                row.last_x,row.last_y=x,yy
            end
            row.label:alpha(alpha)
            row.label:stroke_alpha(math.floor(235*clamp(opacity or 1,0,1)+.5))
            -- Both foreground and outline fade; otherwise stroke looks black
            -- even while the foreground is transparent.
            row.label:show()
            local start=column_x
            for j=1,n do
                local name=item.properties[j]
                local path=self.icon_root..glyph(name)
                local slot=row.icons[j]
                if not slot then
                    slot={image=make_icon(path,glyphsize),path=path}
                    row.icons[j]=slot
                elseif slot.path~=path then
                    slot.image:path(path);slot.path=path
                end
                local ix=math.floor(start+(j-1)*(glyphsize+gap)+.5)
                if slot.last_size~=glyphsize then
                    slot.image:size(glyphsize,glyphsize);slot.last_size=glyphsize
                end
                local iy=yy+math.max(0,math.floor((rh-glyphsize)/2))
                if slot.last_x~=ix or slot.last_y~=iy then
                    slot.image:pos(ix,iy);slot.last_x,slot.last_y=ix,iy
                end
                slot.image:alpha(math.floor(240*clamp(opacity or 1,0,1)+.5))
                slot.image:show()
            end
            for j=n+1,#row.icons do row.icons[j].image:hide() end
        end
        for i=count+1,#self.rows do
            local row=self.rows[i]
            row.label:hide()
            for _,icon in ipairs(row.icons) do icon.image:hide() end
        end
    end
    function self:destroy()
        self:hide()
        for _,row in ipairs(self.rows) do
            row.label:destroy()
            for _,icon in ipairs(row.icons) do icon.image:destroy() end
        end
        self.rows={}
    end
    return self
end
return M
