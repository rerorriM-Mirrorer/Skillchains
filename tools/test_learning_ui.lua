-- Pure simulated Windower smoke check: no FFXI client or external libs.
local created_labels,created_images=0,0
windower={addon_path='Skillchains/',get_windower_settings=function()
    return {ui_x_res=960,ui_y_res=540}
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
        function obj:color(r,g,b) self.rgb={r,g,b} end
        function obj:pos(x,y) self.x,self.y=x,y end
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
        local obj={path_value=settings.texture.path}
        function obj:path(v) if v then self.path_value=v end return self.path_value end
        function obj:size(w,h) self.width,self.height=w,h end
        function obj:pos(x,y) self.x,self.y=x,y end
        function obj:show() self.visible=true end
        function obj:hide() self.visible=false end
        function obj:destroy() self.destroyed=true end
        return obj
    end}
end
package.path='./?.lua;'..package.path
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
assert(r.rows[1].label.rgb[1]==242)
assert(r.rows[1].icons[2].image.x+r.rows[1].icons[2].image.width==
    r.rows[2].icons[1].image.x+r.rows[2].icons[1].image.width,
    'Rightmost property icons should share the same right edge')
assert(r.rows[1].icons[1].image.path_value:match('fragmentation.png$'))
assert(r.rows[1].icons[2].image.path_value:match('scission.png$'))
local before_l,before_i=created_labels,created_images
r:render(groups,80,420,1)
assert(created_labels==before_l and created_images==before_i,
    'Stable list should reuse rendered resources')
r:render(groups,80,300,1)
assert(r.rows[1].label.y==300-36, 'Learning list must extend UP from its bottom anchor')
r:render({},80,300,1)
assert(r.rows[1].label._text=='No compatible learned actions')
assert(not r.rows[2].label.visible and not r.rows[1].icons[1].image.visible)
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
    set_color=function(id,a,r,g,b) end,
    set_visibility=function(id,on) assert(prims[id]);prims[id].visible=on end,
    set_position=function(id,x,y) assert(prims[id]);prims[id].x=x;prims[id].y=y end,
    set_size=function(id,w,h) assert(prims[id]);prims[id].w=w;prims[id].h=h end,
    delete=function(id) prims[id]=nil end
}
local opt={
    mode='learn',display='both',names='full',scale=1,
    name_offset={x=0,y=-11},
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
assert(overlay.properties.visible and overlay.mb_caption.visible)
assert(overlay.caption_icons.sc[1].image.visible)
assert(overlay.caption_icons.sc[2].image.visible)
assert(overlay.caption_icons.mb[1].image.visible)
local original_bottom=opt.list.y
overlay:edit(true)
overlay:render(state)
local px,py=overlay.panel:pos()
overlay.panel:pos(px+12,py-20)
overlay:render(state)
assert(opt.list.x==192 and opt.list.y==original_bottom-20,
    'Dragging guide should move the anchored list once')
overlay:render(state)
assert(opt.list.x==192 and opt.list.y==original_bottom-20,
    'Guide repositioning should not move the list again')
overlay:edit(false)
overlay:render(state)
assert(not overlay.panel.visible and overlay.learning.displayed==2)
overlay:render(nil)
assert(overlay.learning.displayed==0)
overlay:destroy()
print('resonance_ui integration simulation passed: bars, captions, icons, drag guide, cleanup')

