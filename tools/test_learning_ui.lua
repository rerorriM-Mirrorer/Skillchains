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
assert(prims.sc_resonance_fx_wash~=nil,'Pooled resonance strike graphics initialized')
assert(overlay.fx.sprites.glow_cap_l and
    overlay.fx.sprites.glow_cap_l.fit==false and
    overlay.fx.sprites.glow_cap_l.path_value:match('capsule_halo_l.png$'),
    'Rounded ghost cap replaces vertical flare sprites')
assert(overlay.fx.sprites.glow_cap_r and
    overlay.fx.sprites.glow_cap_r.path_value:match('capsule_halo_r.png$'),
    'Mirrored endcap uses a second real ghost-glow asset')
assert(not overlay.fx.sprites.left and not overlay.fx.sprites.moving,
    'Retired edge and center flare sprites are no longer allocated')
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
-- Source-clock animation presentation; no FFXI packets are simulated.
local opener={
    now=100.15,created=100,sc_open=103,step=1,level=0,
    active={'Liquefaction','Detonation'},sc_wait=2.85,
    sc_left=7,sc_total=7,mb_left=0,mb_total=10,
    groups=groups,closed=false
}
opt.animation={enabled=true,intensity=1,glow=1,flare=2,fade=false}
opt.glow={levels='34',rail12=.3,cap12=.35,rail34=.75,cap34=.85,
    level1=1,level2=.65,level3=.70,level4=1,
    pre12=.18,pre3=.38,pre4=.85,scale=1,l4='gold'}
opt.track={alpha=155,color={6,8,17}}
opt.transition={duration=.30,style='energized'}
assert(overlay.fx.sprites.glow_cap_l.path_value:match('capsule_halo_l.png$'))
assert(overlay.fx.sprites.glow_cap_r.path_value:match('capsule_halo_r.png$'))
assert(overlay.fx.sprites.border_glow.path_value:match('capsule_halo_rail.png$'))
assert(overlay.fx.sprites.moving==nil and overlay.fx.sprites.edge==nil,
    'Vertical and center flare sprites are retired')
overlay:render(opener)
assert(prims.sc_resonance_fx_wash.visible,
    'Opener retains smoothly expanding white primitive')
assert(prims.sc_resonance_sc_frame.alpha==0 and
    not prims.sc_resonance_sc_base.visible,
    'First opener beat hides actual SC gauge and gradient work')
assert(overlay.fx:bar_fraction(opener,opt.animation)==1,
    'SC window cannot decay during opener wait')
assert(prims.sc_resonance_fx_wash_cap_l.visible and
    prims.sc_resonance_fx_wash_cap_r.visible,
    'White bar uses the same rounded endcap silhouette')
assert(overlay.properties.opacity>0 and overlay.properties.opacity<245,
    'Opener caption starts fading in during first beat')
opener.now=101.5;opener.sc_wait=1.5
overlay:render(opener)
assert(overlay.properties.opacity==245 and
    prims.sc_resonance_fx_wash.visible and
    prims.sc_resonance_fx_wash.alpha<255,
    'Opener fades white into dim property on second beat')
assert(prims.sc_resonance_sc_base.visible,
    'Real dark bar appears behind fading white opener')
opener.now=102.5;opener.sc_wait=.5
overlay:render(opener)
assert(not prims.sc_resonance_fx_wash.visible)
opener.now=103.5;opener.sc_wait=0;opener.sc_left=6.5
overlay:render(opener)
assert(overlay.fx:bar_fraction(opener,opt.animation)<1,
    'Continuation begins only when real opener window opens')

local chain={
    now=110,created=110,sc_open=113,step=2,level=2,active={'Fusion'},
    sc_wait=3,sc_left=6,sc_total=6,mb_left=10,mb_total=10,
    groups=groups,closed=false,from_fraction=.27,
    from_active={'Liquefaction'}
}
overlay:render(chain)
assert(overlay.fx:bar_fraction(chain,opt.animation)==.27,
    'Successful chain keeps previous fill fraction at beginning')
assert(prims.sc_resonance_sc_base.visible,
    'Successful chain does not hide previous dark track')
assert(prims.sc_resonance_sc_frame.h==1
    and prims.sc_resonance_sc_frame_bottom.h==1,
    'Crisp border is TWO horizontal 1px rails, not a bright sheet')
assert(prims.sc_resonance_sc_frame_bottom.y==
    prims.sc_resonance_sc_base.y+prims.sc_resonance_sc_base.h,
    'Lower border belongs below track, never behind transparent interior')
assert(prims.sc_resonance_sc_base.color[1]==6
    and prims.sc_resonance_sc_base.color[2]==8
    and prims.sc_resonance_sc_base.color[3]==17,
    'New translucent track is darker and level-independent')
chain.now=110.5;chain.sc_wait=2.5
overlay:render(chain)
local middle=overlay.fx:bar_fraction(chain,opt.animation)
assert(middle>.27 and middle<1,'Successful underlay expands from previous fraction')
assert(prims.sc_resonance_fx_wash.x==opt.bar.x+1 and
    prims.sc_resonance_fx_wash.w>20,
    'White refill grows from left edge, not previous fill endpoint')
assert(not overlay.fx.sprites.border_glow.visible and
    not overlay.fx.sprites.glow_cap_r.visible,
    'Level 2 glow is disabled by default, even when white refill active')
assert(overlay.fx.sprites.moving==nil,
    'No center flares on any successful level')
chain.now=112.2;chain.sc_wait=.8
overlay:render(chain)
assert(prims.sc_resonance_fx_wash.visible and
    prims.sc_resonance_fx_wash.alpha==255,
    'Successful chain stays pure white after expansion')
assert(overlay.fx:transition_progress(chain,opt.transition)==0,
    '0.3 second fade must not start early')
chain.now=112.925;chain.sc_wait=.075
overlay:render(chain)
local first_alpha=prims.sc_resonance_fx_wash.alpha
assert(first_alpha>0 and first_alpha<255,
    'White begins giving way to property shortly BEFORE decay')
chain.now=113;chain.sc_wait=0;chain.sc_left=6
overlay:render(chain)
local overlap=overlay.fx:transition_progress(chain,opt.transition)
assert(overlap>.45 and overlap<.55,
    'White-to-property fade is centered on exact countdown boundary')
assert(prims.sc_resonance_fx_wash.visible and
    prims.sc_resonance_fx_wash.alpha<first_alpha,
    'White alpha keeps fading as decay starts')
chain.now=113.15;chain.sc_left=5.85
overlay:render(chain)
assert(overlay.fx:transition_progress(chain,opt.transition)==1 and
    not prims.sc_resonance_fx_wash.visible,
    'White disappears at countdown +0.15s without changing deadline')
assert(overlay.fx:bar_fraction(chain,opt.animation)<1)
assert(prims.sc_resonance_sc_base.alpha==155,
    'Dark empty track remains constant')
local deadline=chain.sc_left
opt.animation.fade=true
overlay:render(chain)
assert(chain.sc_left==deadline and prims.sc_resonance_sc_base.alpha==155,
    'Optional countdown opacity wave does not alter deadlines or empty track')
opt.animation.fade=false

-- Both caps are a little stronger than the rail, while ALL three
-- textures sample exactly the same border path.
local lvl4={
    now=403.3,created=400,sc_open=403,step=2,level=4,
    active={'Radiance'},sc_wait=0,sc_left=5.7,sc_total=6,
    from_fraction=.5,closed=false,groups=groups
}
overlay:render(lvl4)
local left=overlay.fx.sprites.glow_cap_l
local right=overlay.fx.sprites.glow_cap_r
local top=overlay.fx.sprites.border_glow
assert(left.visible and right.visible and top.visible
    and overlay.fx.sprites.border_lower==nil,
    'Three seamless halo pieces; no overlapping second rail sprites')
assert(left.x<opt.bar.x and right.x+right.width>opt.bar.x+opt.bar.width
    and left.x+left.width==top.x and top.x+top.width==right.x,
    'Caps bloom just outside frame while joining central twin rail exactly')
assert(left.opacity>top.opacity and right.opacity==left.opacity,
    'Default cap-forward mode makes endcaps moderately stronger')
assert(left.rgb[1]==249 and left.rgb[2]==207 and left.rgb[3]==103,
    'Preferred prewindow electric level-4 glow defaults gold')
local electric_a=top.opacity
lvl4.now=403.37;lvl4.sc_left=5.63
overlay:render(lvl4)
assert(top.opacity~=electric_a,
    '23/28 rad/s oscillation still animates border electricity')
local show_count=right.show_calls
local hide_count=right.hide_calls or 0
overlay:render(lvl4)
assert(right.show_calls==show_count and
    (right.hide_calls or 0)==hide_count,
    'Cached sprites avoid unnecessary hide/show on identical frames')

opt.glow.cap34=opt.glow.rail34
overlay:render(lvl4)
assert(right.opacity==top.opacity,
    'Balanced option equalizes cap and rail brightness')
opt.glow.l4='gold'
overlay:render(lvl4)
assert(left.rgb[1]==249 and left.rgb[2]==207 and left.rgb[3]==103,
    'Optional gold L4 palette remains available')
opt.glow.l4='white'
overlay:render(lvl4)
assert(left.rgb[1]==255 and left.rgb[2]==255 and left.rgb[3]==255,
    'Optional white L4 palette remains available')
opt.glow.l4='whitegold'
opt.glow.cap34=.85
opt.glow.levels='off'
overlay:render(lvl4)
assert(not left.visible and not top.visible,
    'Master level mask off removes glow without affecting SC bar')
opt.glow.levels='1234'
opt.glow.level1=.6
local lvl1={
    now=203.4,created=200,sc_open=203,step=2,level=1,
    active={'Liquefaction'},sc_wait=0,sc_left=5.6,sc_total=6,
    from_fraction=.5,closed=false,groups=groups
}
overlay:render(lvl1)
assert(left.visible and top.visible and top.opacity>0,
    'Glow is optionally enabled for level 1')
-- A real saved Windower settings.xml can load a digit-only mask as a number.
-- Rendering must tolerate that value on every frame without throwing.
opt.glow.levels=1234
overlay:render(lvl1)
assert(left.visible and top.visible,
    'Numeric saved glow mask 1234 renders enabled level 1')
local low_alpha=top.opacity
opt.glow.level1=2
overlay:render(lvl1)
assert(top.opacity>low_alpha,
    'Per-level strength is adjustable independent of tier groups')
opt.glow.levels='34'
local lvl3={
    now=303.4,created=300,sc_open=303,step=2,level=3,
    active={'Light'},sc_wait=0,sc_left=5.6,sc_total=6,
    from_fraction=.5,closed=false,groups=groups
}
opt.transition.style='uniform'
overlay:render(lvl3)
assert(left.visible and top.visible,'Level 3 retains continuous white glow')
opt.glow.levels=34
overlay:render(lvl3)
assert(left.visible and top.visible,
    'Numeric saved glow mask 34 renders enabled level 3 without a Lua error')
opt.transition.style='energized'
local transient={
    now=302.96,created=300,sc_open=303,step=2,level=3,
    active={'Light'},sc_wait=.04,sc_left=6,sc_total=6,
    from_fraction=.5,closed=false,groups=groups
}
overlay:render(transient)
local energized_alpha=top.opacity
opt.transition.style='uniform'
overlay:render(transient)
assert(top.opacity~=energized_alpha,
    'Uniform fade and energized border coming-online remain distinct options')
opt.transition.style='energized'
opt.animation.enabled=false
overlay:render(lvl3)
assert(not left.visible and not top.visible,
    'Turning animation off hides optional glow cleanly')
opt.animation.enabled=true
overlay:render(nil)
assert(not left.visible and not prims.sc_resonance_fx_wash.visible)
overlay:destroy()
print('resonance FX simulation passed: white refill, 0.30s overlap, glow cap geometry, levels, options, flicker, pooling')
print('resonance_ui integration simulation passed: bars, captions, icons, drag guide, cleanup')
