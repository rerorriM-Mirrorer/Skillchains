-- Pure simulated Windower smoke check: no FFXI client or external libs.
local created_labels,created_images=0,0
local viewport_w,viewport_h=960,540
windower={addon_path='TargetSC/',get_windower_settings=function()
    return {ui_x_res=viewport_w,ui_y_res=viewport_h}
end}
package.preload.texts=function()
    return {new=function(initial,settings)
        created_labels=created_labels+1
        local obj={_text=initial or '',_size=11,visible=false,
            x=settings and settings.pos and settings.pos.x or 0,
            y=settings and settings.pos and settings.pos.y or 0}
        function obj:text(v) if v then self._text=v end return self._text end
        function obj:extents() return #self._text*self._size*.60,self._size end
        function obj:size(v) if v then self._size=v end return self._size end
        function obj:stroke_width() end
        function obj:stroke_alpha(v) if v~=nil then self.outline_opacity=v end return self.outline_opacity end
        function obj:alpha(v) if v then self.opacity=v end return self.opacity or 245 end
        function obj:color(r,g,b) self.rgb={r,g,b} end
        function obj:pos(x,y)
            if x==nil then return self.x,self.y end
            self.x,self.y=x,y
        end
        function obj:show() self.visible=true end
        function obj:hide() self.visible=false end
        function obj:destroy() self.destroyed=true end
        function obj:draggable(v) self.is_draggable=v end
        return obj
    end}
end
package.preload.images=function()
    return {new=function(_,settings)
        created_images=created_images+1
        local obj={path_value=settings.texture.path,fit=settings.texture.fit,
            visible=settings.visible==true,
            alpha_initial=settings.color and settings.color.alpha}
        function obj:path(v) if v then self.path_value=v end return self.path_value end
        function obj:alpha(v) if v then self.opacity=v end return self.opacity or 240 end
        function obj:color(r,g,b) self.rgb={r,g,b} end
        function obj:size(w,h) self.width,self.height=w,h end
        function obj:pos(x,y) self.x,self.y=x,y end
        function obj:show()
            self.visible=true;self.show_calls=(self.show_calls or 0)+1
        end
        function obj:hide()
            self.visible=false;self.hide_calls=(self.hide_calls or 0)+1
        end
        function obj:destroy() self.destroyed=true end
        return obj
    end}
end
package.path='./TargetSC/?.lua;./?.lua;'..package.path
local r=require('learning_ui').new(function(result)
    return result=='Light' and {242,232,201} or {169,150,189}
end)
local groups={
    {level=3,property='Light',actions={
        {name='Savage Blade',properties={'Fragmentation','Scission'}}}},
    {level=2,property='Gravitation',actions={
        {name='Swift Blade',properties={'Gravitation'}}}}
}
r:render(groups,80,420,1)
assert(r.displayed==2 and r:height()==36)
assert(r.rows[1].label._text=='Savage Blade')
assert(r.rows[1].label.visible and r.rows[2].label.visible)
assert(r.rows[1].label._text=='Savage Blade')
assert(r.rows[1].label.rgb[1]==242)
assert(r.rows[1].icons[1].image.x==r.rows[2].icons[1].image.x,
    'All property icons should begin in one compact fixed column')
assert(r.rows[1].icons[1].image.width==9 and
    r.rows[1].icons[1].image.fit==false and
    r.rows[1].icons[1].image.x+r.rows[1].icons[1].image.width<
        r.rows[1].icons[2].image.x,
    'Icons match font size and have visible spacing between properties')
assert(r.icon_column_x < 80+300,
    'Icon column follows actual longest ability name, not distant fixed edge')
assert(r.icon_column_x>=80+math.ceil(#'Savage Blade'*11*.82)+8,
    'Column reserves the italic text width AND a gap beyond its stroke')
local long_actions={{level=3,property='Light',actions={
    {name='Extremely Long Double-Property Weapon Skill Name',properties={
        'Fragmentation','Scission','Detonation','Liquefaction'}}}}}
r:render(long_actions,80,420,1)
local long_row=r.rows[1]
local measured=math.max(long_row.label:extents(),
    #long_row.label._text*11*.82)
assert(long_row.label.x+measured+3 < long_row.icons[1].image.x,
    'Long names must ellipsize BEFORE the fixed icon column on 960px view')
assert(long_row.icons[4].image.x+long_row.icons[4].image.width<=960-8,
    'Even four-property abilities must remain within client bounds')
r:render(groups,80,420,1)
assert(r.rows[1].icons[1].image.path_value:match('fragmentation.png$'))
assert(r.rows[1].icons[2].image.path_value:match('scission.png$'))
local before_l,before_i=created_labels,created_images
r:render(groups,80,420,1)
assert(created_labels==before_l and created_images==before_i,
    'Stable list should reuse rendered resources')
r:render(groups,80,300,1)
assert(r.rows[1].label.y==300-36, 'Learning list must extend UP from its bottom anchor')
r:render({},80,300,1)
assert(r.displayed==0 and r:height()==0,
    'Empty learning panel draws no placeholder, box or rows')
assert(not r.rows[1].label.visible and not r.rows[2].label.visible
    and not r.rows[1].icons[1].image.visible)
r:render(groups,80,35,1)
assert(r:height()<=26, 'Clamp list to small viewport/top edge')
r:hide()
assert(not r.rows[1].label.visible and not r.rows[1].icons[1].image.visible)
r:destroy()
assert(r.rows and #r.rows==0)
print('learning_ui simulation passed: ordering, property images, alignment, anchor, pooling and clipping')
-- Integration with the actual resonance bars: no live FFXI required.
local prims={}
windower.prim={
    create=function(id) prims[id]={} end,
    set_color=function(id,a,r,g,b) assert(prims[id]);prims[id].alpha=a;prims[id].color={r,g,b} end,
    set_visibility=function(id,on) assert(prims[id]);prims[id].visible=on end,
    set_position=function(id,x,y) assert(prims[id]);prims[id].x=x;prims[id].y=y end,
    set_size=function(id,w,h) assert(prims[id]);prims[id].w=w;prims[id].h=h end,
    delete=function(id) prims[id]=nil end
}
local opt={
    mode='learn',display='both',names='full',scale=1,
    name_offset={x=0,y=-11},icon_offset={x=0,y=0},
    bar={x=180,y=370,width=260},list={x=180,y=320}
}
local info={
    Liquefaction={'Fire'},Detonation={'Wind'},Fragmentation={'Wind','Lightning'},
    Scission={'Earth'},Light={'Light'},Gravitation={'Dark','Earth'}
}
local overlay=require('resonance_ui').new(opt,info)
local state={
    active={'Fragmentation','Scission'},step=2,sc_left=4.5,sc_total=8,
    sc_wait=0,mb_left=7,mb_total=10,closed=false,
    groups=groups
}
overlay:render(state)
assert(overlay.learning.displayed==2)
opt.display='off'
overlay:render(state)
assert(overlay.learning.displayed==2,'learn mode must survive ribbon hide')
assert(overlay.names.sc.hidden and overlay.names.mb.hidden,'both ribbons must be hidden')
assert(not overlay.properties.visible and not overlay.mb_caption.visible)
assert(not prims.sc_resonance_mb_ribbon_glow.visible,'MB halo hidden too')
opt.display='both'
overlay:render(state)
assert(not overlay.names.sc.hidden and not overlay.names.mb.hidden,
    're-enabling ribbons restores both')
opt.display='off'
opt.mode='compact'
overlay:render(state)
assert(overlay.learning.displayed==0,'compact mode has no learning suggestions')
opt.mode='learn'
state.sc_left=0
overlay:render(state)
assert(overlay.learning.displayed==0,'expired SC has no follow-up suggestions')
state.sc_left=5
overlay:render(state)
assert(overlay.learning.displayed==2,'helper returns with live opportunity')
overlay:destroy()
print('PASS helper-only presentation, restoration, compact mode and expiry')
