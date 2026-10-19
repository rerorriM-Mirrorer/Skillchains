-- Pure simulated Windower smoke check: no FFXI client or external libs.
local created_labels,created_images=0,0
local viewport_w,viewport_h=960,540
windower={addon_path='Skillchains/',get_windower_settings=function()
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
assert(prims.sc_resonance_fx_wash~=nil,'Pooled resonance strike graphics initialized')
assert(overlay.fx.sprites.left and overlay.fx.sprites.left.fit==false,
    'Pooled, size-respecting soft-alpha chain flares initialized')
assert(overlay.fx.sprites.left.path_value:match('edge_flare_left.png$') and
    overlay.fx.sprites.edge.path_value:match('edge_flare_right.png$'),
    'Round-foot mirrored sprites are loaded for each endpoint')
assert(overlay.fx.sprites.moving.path_value:match('ghost_flare.png$'),
    'Three-beat center pulse still uses the original ghost texture')
assert(overlay.properties.visible and overlay.mb_caption.visible)
assert(overlay.caption_icons.sc[1].image.visible)
assert(overlay.caption_icons.sc[2].image.visible)
assert(overlay.caption_icons.sc[2].image.fit==false)
local old_icon_y=overlay.caption_icons.sc[1].image.y
opt.icon_offset.y=3
overlay:render(state)
assert(overlay.caption_icons.sc[1].image.y==old_icon_y+3,
    'Independent SC icon offset shifts icons without moving label')
opt.icon_offset.y=0
overlay:render(state)
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
-- Ctrl+drag: snap the TWO intentional anchors separately. Native text
-- objects simulate the existing Windower drag handles; no mouse hook.
local bx,by=overlay.handle:pos()
overlay.handle:pos(277,by+5)
overlay:render(state)
assert(opt.bar.x==277 and opt.bar.y==375,'Unmodified bar drag remains free')
overlay:set_ctrl(29,true)
overlay.handle:pos(286,112)
overlay:render(state)
assert(opt.bar.x==280 and opt.bar.y==140,'Left Ctrl snaps bar anchor from screen origin')
assert(prims.sc_resonance_sc_frame.x==281,'SC frame follows the same parent anchor')
assert(overlay.properties.x==
    overlay.caption_icons.sc[2].image.x+
    overlay.caption_icons.sc[2].image.width+1,
    'SC caption follows compact property icon column with a 1px gap')
local gx,gy=overlay.panel:pos()
overlay.panel:pos(gx+37,gy-18)
overlay:render(state)
assert(opt.list.x==220 and opt.list.y==280,
    'Learning bottom anchor snaps independently to screen grid')
assert(overlay.learning.rows[1].label.x==opt.list.x)
assert(overlay.learning.rows[1].label.y==opt.list.y-overlay.learning:height())
-- Right Ctrl must remain active if left Ctrl is released.
overlay:set_ctrl(157,true)
overlay:set_ctrl(29,false)
overlay.handle:pos(296,117)
overlay:render(state)
assert(opt.bar.x==290 and opt.bar.y==150,
    'Right Ctrl persists independently of left Ctrl')
overlay:set_ctrl(157,false)
overlay.handle:pos(297,117)
overlay:render(state)
assert(opt.bar.x==297 and opt.bar.y==151,'Releasing Ctrl restores free dragging')
-- Non-10px grid still shares absolute origin (not relative to scale or widget).
opt.grid=16
overlay:set_ctrl(29,true)
overlay.handle:pos(301,115)
overlay:render(state)
assert(opt.bar.x==288 and opt.bar.y==144,'Adjustable grid uses screen 0,0')
-- Snap to valid boundaries, including Y minimum and display's right/bottom.
overlay.handle:pos(9999,9999)
overlay:render(state)
assert(opt.bar.x==864 and opt.bar.y==480)
overlay.handle:pos(-999,-999)
overlay:render(state)
assert(opt.bar.x==16 and opt.bar.y==48)
-- Minimal permitted grid, then extreme small/large scales.
opt.grid=1
for _,scale in ipairs({.5,2.5}) do
    overlay:scale(scale)
    overlay.handle:pos(169,120)
    overlay:render(state)
    assert(opt.bar.x==169 and opt.bar.y==154)
    assert(prims.sc_resonance_sc_frame.x==opt.bar.x+1,
        'No accumulating bar position error after scaling')
    assert(overlay.learning.rows[1].label.x==opt.list.x)
end
viewport_w,viewport_h=1280,720
opt.grid=10
overlay:set_ctrl(29,false)
overlay.handle:pos(643,203)
overlay:render(state)
assert(opt.bar.x==643 and opt.bar.y==237,
    'Larger viewport free movement works independent of scale')
overlay:set_ctrl(29,true)
overlay.handle:pos(643,203)
overlay:render(state)
assert(opt.bar.x==643 and opt.bar.y==237,
    'Holding Ctrl alone does not snap without movement')
overlay.handle:pos(644,204)
overlay:render(state)
assert(opt.bar.x==640 and opt.bar.y==230,
    'Dragging on larger resolution snaps independently of scale')
overlay:set_ctrl(29,false)
overlay:scale(1)
viewport_w,viewport_h=960,540
overlay:edit(false)
overlay:render(state)
assert(not overlay.panel.visible and overlay.learning.displayed==2)
overlay:render(nil)
assert(overlay.learning.displayed==0)
-- Source-clock animation presentation; no game packets are simulated here.
local opener={
    now=100.15,created=100,sc_open=103,step=1,level=0,
    active={'Liquefaction','Detonation'},sc_wait=2.85,sc_left=7,sc_total=7,
    mb_left=0,mb_total=10,groups=groups,closed=false
}
opt.animation={enabled=true,intensity=1,fade=false}
overlay:render(opener)
assert(prims.sc_resonance_fx_wash.visible,
    'New opener should show white strike wash')
assert(overlay.fx:bar_fraction(opener,opt.animation)==1,
    'Countdown may not shrink during opener delay')
assert(prims.sc_resonance_sc_frame.alpha==0 and
    not prims.sc_resonance_sc_base.visible,
    'Underlying SC gauge is not repainted during first white beat')
assert(prims.sc_resonance_fx_wash_cap_l.visible and
    prims.sc_resonance_fx_wash_cap_r.visible,
    'Expanding white bar has rounded left and right end caps')
assert(prims.sc_resonance_fx_wash_cap_l.h<
    prims.sc_resonance_fx_wash.h,
    'Rounded white caps sit inset vertically from the bar')
local fx_edge=overlay.fx.sprites.edge
local bottom=opt.bar.y+math.max(3,math.floor(5*opt.scale+.5))+1
assert(fx_edge.visible and fx_edge.y+fx_edge.height==bottom,
    'Rounded base touches fill bottom, with no dangling body below')
local old_show=fx_edge.show_calls
local old_hide=fx_edge.hide_calls or 0
overlay:render(opener)
assert(fx_edge.show_calls==old_show and (fx_edge.hide_calls or 0)==old_hide,
    'Unchanged frame does not hide/show the same sprite')
assert(overlay.properties.opacity>0 and overlay.properties.opacity<245 and
    overlay.properties.outline_opacity>0 and
    overlay.learning.rows[1].label.outline_opacity>0,
    'Property text, icons and BOTH stroke and foreground start fading in first beat')
opener.now=101.5;opener.sc_wait=1.5
overlay:render(opener)
assert(overlay.properties.opacity==245 and
    overlay.properties.outline_opacity==235 and
    overlay.learning.rows[1].label.opacity==245,
    'Labels reach full opacity by the end of first opener second')
assert(prims.sc_resonance_fx_wash.visible,
    'Rounded white overlay fades out during second beat')
assert(not overlay.fx.sprites.moving.visible,
    'No extra pulses travel during an opener')
opener.now=102.5;opener.sc_wait=.5
overlay:render(opener)
assert(overlay.properties.opacity==245 and
    overlay.learning.rows[1].label.opacity==245,
    'Property labels remain fully visible after first beat')
assert(not prims.sc_resonance_fx_wash.visible,
    'White wash is gone in the third beat')
opener.now=103.5;opener.sc_wait=0;opener.sc_left=6.5
overlay:render(opener)
assert(overlay.fx:bar_fraction(opener,opt.animation)<1,
    'Continuation counts down after actual SC window opening')
local chain={
    now=110,created=110,sc_open=113,step=2,level=2,active={'Fusion'},
    sc_wait=3,sc_left=6,sc_total=6,mb_left=10,mb_total=10,
    groups=groups,closed=false,from_fraction=.27,
    from_active={'Liquefaction'}
}
overlay:render(chain)
assert(overlay.fx:bar_fraction(chain,opt.animation)==.27,
    'Successful chain grows from observed prior fill instead of restarting arbitrarily')
chain.now=110.15
local middle=overlay.fx:bar_fraction(chain,opt.animation)
assert(middle>.27 and middle<1,'White success flare expands fill for 0.3s')
chain.now=110.35
overlay:render(chain)
assert(overlay.fx:bar_fraction(chain,opt.animation)<1)
assert(overlay.fx.sprites.left.visible and not overlay.fx.sprites.right.visible,
    'White pre-window has white edge flare before property edge flares')
assert(overlay.fx.sprites.moving.visible,
    'Original level-4 center pulse restored for level 2')
assert(prims.sc_resonance_fx_wash.x==opt.bar.x+1 and
    prims.sc_resonance_sc_base.visible,
    'Successful chain starts white overlay at LEFT while prior track stays visible')
assert(overlay.fx.sprites.left.y+
    overlay.fx.sprites.left.height<=opt.bar.y+
    math.max(3,math.floor(5*opt.scale+.5))+1,
    'Flare foot is level with the bottom of the SC fill')
local trans_a=overlay.fx:palette_blend(chain)
assert(trans_a==0,'Property transition stays dim during first white expansion')
chain.now=111.3;chain.sc_wait=1.7
overlay:render(chain)
assert(overlay.fx.sprites.moving.visible)
local first_pass=overlay.fx.sprites.moving.x
chain.now=111.6;chain.sc_wait=1.4
overlay:render(chain)
assert(overlay.fx.sprites.moving.visible and
    overlay.fx.sprites.moving.x==first_pass,
    'Level-2 center pulse remains stationary while it flickers')
chain.now=113.1;chain.sc_wait=0;chain.sc_left=5.9
overlay:render(chain)
assert(not overlay.fx.sprites.moving.visible,
    'Traveling flares stop when actual continuation starts')
assert(overlay.fx.sprites.right.visible,
    'Property-colored edge flare follows the bar after countdown starts')
-- Mutation safety: optional opacity wave never alters absolute deadline.
local prior=chain.sc_left
opt.animation.fade=true
overlay:render(chain)
assert(chain.sc_left==prior and overlay.fx:opacity(chain,opt.animation)<1)
assert(prims.sc_resonance_sc_base.alpha==115,
    'Even with fade ON, the empty dark bar must retain its original alpha')
assert(overlay.fx.sprites.border_glow.visible==false,
    'Level-2 has no intrusive full-width glow')
opt.animation.enabled=false
overlay:render(chain)
assert(not prims.sc_resonance_fx_wash.visible and
    not overlay.fx.sprites.left.visible)
opt.animation.enabled=true
local lvl1={now=201,created=200,sc_open=203,step=2,level=1,
    active={'Liquefaction'},sc_wait=2,sc_left=6,sc_total=6,
    from_fraction=.5,closed=false,groups=groups}
overlay:render(lvl1)
assert(overlay.fx.sprites.moving.visible,
    'Level 1 shares the original three-beat center pulse')
local lvl3={now=301,created=300,sc_open=303,step=2,level=3,
    active={'Light'},sc_wait=2,sc_left=6,sc_total=6,
    from_fraction=.5,closed=false,groups=groups}
overlay:render(lvl3)
assert(overlay.fx.sprites.moving.visible and
    overlay.fx.sprites.border_glow.visible and
    overlay.fx.sprites.border_lower.visible,
    'Level 3 has one follow-up and separate top and bottom halo rails')
local first3=overlay.fx.sprites.moving.x
lvl3.now=301.6;lvl3.sc_wait=1.4
overlay:render(lvl3)
assert(overlay.fx.sprites.moving.visible and
    overlay.fx.sprites.moving.x==first3,
    'Level 3 center pulse stays stationary')
local lvl4={now=401,created=400,sc_open=403,step=2,level=4,
    active={'Radiance'},sc_wait=2,sc_left=6,sc_total=6,
    from_fraction=.5,closed=false,groups=groups}
overlay:render(lvl4)
assert(overlay.fx.sprites.moving.rgb[1]==242 and
    overlay.fx.sprites.moving.rgb[2]==232 and
    overlay.fx.sprites.moving.rgb[3]==201,
    'Central Radiance pulse uses fill-center hue, not decorative gold')
local flare_bottom=overlay.fx.sprites.edge.y+overlay.fx.sprites.edge.height
lvl4.now=401.65;lvl4.sc_wait=1.35
overlay:render(lvl4)
assert(overlay.fx.sprites.edge.y+overlay.fx.sprites.edge.height==flare_bottom,
    'Changing flare height preserves exact lower anchor')
overlay:render(nil)
assert(not overlay.fx.sprites.moving.visible)
overlay:destroy()
print('resonance FX simulation passed: opacity/stroke fades, native-sized PNG fix, single opener sweep, palette fade, timed soft flares, cleanup')
print('resonance_ui integration simulation passed: bars, captions, icons, drag guide, cleanup')

