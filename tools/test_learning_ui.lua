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
assert(overlay.tip.path_value:find('ghost_flare',1,true)
    and overlay.tip.fit==false,
    'SC marker uses supplied horizontal ghostflare image')
assert(prims.sc_resonance_mb_ribbon_glow.visible
    and not prims.sc_resonance_mb_base.visible
    and not prims.sc_resonance_mb_frame.visible,
    'MB uses luminous fill, no dark track or border')
assert(prims.sc_resonance_mb_1.visible,
    'Independent MB duration renders pooled gradient fill')
assert(overlay:mb_ribbon_y(state)==opt.bar.y+25,
    'Legacy attached MB migrates to its own anchor clear of SC labels')
local original_mb_x,original_mb_y=opt.mb.x,opt.mb.y
opt.mb.gap=4;opt.mb.height=3
overlay:mb_align('above')
overlay:render(state)
assert(overlay:mb_ribbon_y(state)==opt.bar.y-8,
    'Above command moves standalone anchor just once')
opt.mb.text='off';opt.mb.icon='off'
overlay:render(state)
assert(not overlay.mb_caption.visible
    and not overlay.caption_icons.mb[1].image.visible
    and prims.sc_resonance_mb_ribbon_glow.visible,
    'MB ribbon alone is possible with both text and icons hidden')
opt.mb.text='on';opt.mb.icon='off';opt.mb.scale=1.5;opt.mb.fontsize=15
overlay:render(state)
assert(overlay.mb_caption.visible and
    not overlay.caption_icons.mb[1].image.visible,
    'Text-only MB option independent of icon visibility')
opt.mb.text='off';opt.mb.icon='on'
overlay:render(state)
assert(not overlay.mb_caption.visible and
    overlay.caption_icons.mb[1].image.visible,
    'Icon-only MB option independent of text visibility')
opt.mb.text='on';opt.mb.icon='on';opt.mb.iconsize=16
opt.mb.width=220
overlay:set_mb_position(original_mb_x+15,original_mb_y+34)
overlay:render(state)
assert(prims.sc_resonance_mb_1.x>=opt.mb.x
    and prims.sc_resonance_mb_1.y==opt.mb.y,
    'MB coordinates follow their own saved x/y')
assert(overlay.caption_icons.mb[1].image.width==24,
    'MB icon size independent from SC scale and font size')
assert(overlay.mb_caption._size==23,
    'MB font size uses independent setting and scale')
opt.mb.scale=1;opt.mb.fontsize=10;opt.mb.iconsize=10
opt.mb.height=2;opt.mb.width=260
overlay:render(state)
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
assert(opt.mb.x==original_mb_x+15 and opt.mb.y==original_mb_y+34,
    'Dragging SC must not move separately anchored MB')
overlay.mb_handle:pos(319,272)
overlay:render(state)
assert(opt.mb.x==319 and opt.mb.y==300 and opt.mb.position=='custom',
    'Separate MB edit handle moves and saves custom position')
overlay:set_ctrl(29,true)
overlay.handle:pos(286,112)
overlay:render(state)
assert(opt.bar.x==280 and opt.bar.y==140,'Left Ctrl snaps bar anchor from screen origin')
overlay.mb_handle:pos(333,289)
overlay:render(state)
assert(opt.mb.x==330 and opt.mb.y==320,
    'MB handle Ctrl-snaps independently of SC bar anchor')
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
assert(overlay.tip.visible and prims.sc_resonance_tip_core.visible,
    'Live SC countdown carries a bright moving endpoint')

local chain={
    now=110,created=110,sc_open=113,step=2,level=2,active={'Fusion'},
    sc_wait=3,sc_left=6,sc_total=6,mb_left=10,mb_total=10,
    groups=groups,closed=false,from_fraction=.27,
    from_active={'Liquefaction'}
}
overlay:render(chain)
assert(overlay.fx:bar_fraction(chain,opt.animation)==.27,
    'Successful chain keeps previous fill fraction at beginning')
assert(not overlay.tip.visible and not prims.sc_resonance_tip_core.visible,
    'No false SC endpoint during white pre-window charge')
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
    'Existing legacy mask 34 still excludes L2')
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
assert(left.visible and top.visible,'Level 3 remains luminous after effect promotion')
opt.glow.levels=34
overlay:render(lvl3)
assert(left.visible and top.visible,
    'Numeric saved glow mask 34 renders enabled level 3 without a Lua error')
-- New mask overrides old persisted values without a default type conflict.
opt.glow.level_mask='L3,L4'
opt.glow.levels=1234
overlay:render(lvl1)
assert(not left.visible and not top.visible,
    'New mask disables L1 regardless of legacy mask')
overlay:render(lvl3)
assert(left.visible and top.visible, 'New mask enables L3')
opt.glow.level_mask='off'
overlay:render(lvl3)
assert(not left.visible and not top.visible, 'New off value disables glow')
opt.glow.level_mask=nil
opt.glow.levels=34
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
-- Once explicitly enabled, both promoted classes glow during the white
-- pre-window, before countdown decay begins. Old 34 masks remain unchanged.
-- Use Killala's restored intensity 2/glow 2 to resolve opacity oscillations
-- even after Windower's integer alpha quantization.
opt.animation.intensity=2
opt.animation.glow=2
opt.glow.levels='234'
opt.glow.level_mask=nil
opt.glow.l4='gold'
local shimmer={
    now=501.1,created=501,sc_open=504,step=2,level=2,
    active={'Fusion'},sc_wait=2.9,sc_left=6,sc_total=6,
    from_fraction=.4,closed=false,groups=groups
}
overlay:render(shimmer)
assert(top.visible and left.visible and top.opacity>0
    and prims.sc_resonance_fx_wash.visible,
    'L2 white shimmer visible during new skillchain white refill')
assert(top.rgb[1]==255 and top.rgb[2]==255 and top.rgb[3]==255,
    'L2 gets previous L3 halo white')
local slow_alpha=top.opacity
shimmer.now=501
shimmer.sc_wait=3
overlay:render(shimmer)
assert(top.visible and top.opacity>0,
    'L2 halo is already present on the very first white-refill frame')
shimmer.now=501.17;shimmer.sc_wait=2.83
overlay:render(shimmer)
assert(top.opacity~=slow_alpha, 'L2 uses 11 rad/s shimmer')
local charged={
    now=601.1,created=601,sc_open=604,step=2,level=3,
    active={'Darkness'},sc_wait=2.9,sc_left=6,sc_total=6,
    from_fraction=.4,closed=false,groups=groups
}
overlay:render(charged)
assert(top.visible and top.opacity>0
    and prims.sc_resonance_fx_wash.visible,
    'L3 gold electricity visible while white refill is active')
assert(top.rgb[1]==249 and top.rgb[2]==207 and top.rgb[3]==103,
    'L3 gets prior L4 golden halo')
local fast_alpha=top.opacity
charged.now=601
charged.sc_wait=3
overlay:render(charged)
assert(top.visible and top.opacity>0,
    'L3 electric halo exists from the first registered frame')
charged.now=601.17;charged.sc_wait=2.83
overlay:render(charged)
assert(top.opacity~=fast_alpha, 'L3 uses former L4 23 rad/s electricity')
-- Level 4 retains its original electric color and envelope.
opt.glow.levels='34'
opt.glow.level_mask=nil
opt.glow.l4='gold'
overlay:render(lvl4)
assert(top.visible and left.visible and top.opacity>0
    and top.rgb[1]==249 and top.rgb[2]==207 and top.rgb[3]==103,
    'L4 terminal visual effect unchanged')
opt.animation.intensity=1
opt.animation.glow=1
-- The countdown fade pulse period is independently configurable.
local pulse={
    now=801.12,created=801,sc_open=801,step=2,level=2,
    active={'Fusion'},sc_wait=0,sc_left=4,sc_total=6,
    mb_left=5,mb_total=10,closed=false,groups={}
}
opt.animation.fade=true
opt.animation.fade_period=.24
local pulse_a=overlay.fx:opacity(pulse,opt.animation)
opt.animation.fade_period=.42
local pulse_b=overlay.fx:opacity(pulse,opt.animation)
assert(math.abs(pulse_a-pulse_b)>.01,
    'Countdown opacity wave reacts to the configurable period')
opt.animation.fade=false

-- A real terminal arrives with closed=true already set from the WS packet.
-- After one full second the white refill covers the bar, and the track is
-- hidden (not deleted). During its finale no false continuation timer appears.
local terminal={
    now=903.15,created=900,sc_open=903,step=5,level=4,
    active={'Umbra'},closed=true,sc_wait=0,
    sc_left=2.85,sc_total=3,mb_left=6.85,mb_total=10,
    from_fraction=.5,from_active={'Darkness'},groups={}
}
opt.glow.levels='234'
opt.glow.level_mask=nil
opt.mode='learn';opt.display='both';opt.names='full'
overlay:render(terminal)
assert(not prims.sc_resonance_sc_base.visible
    and prims.sc_resonance_sc_frame.visible,
    'Filled terminal SC hides redundant track, not the bar or frame')
assert(not overlay.tip.visible and not prims.sc_resonance_tip_core.visible,
    'Terminal monochrome event has no false countdown endpoint')
assert(prims.sc_resonance_sc_frame.color[1]==0
    and prims.sc_resonance_sc_frame.color[2]==0
    and prims.sc_resonance_mb_ribbon_glow.color[1]>0,
    'Umbra black SC does not recolor separate MB ribbon')
assert(overlay.properties.rgb[1]==0 and overlay.mb_caption.rgb[1]==255
    and overlay.caption_icons.sc[1].image.rgb[1]==0
    and overlay.caption_icons.mb[1].image.rgb[1]==255,
    'Umbra only recolors SC; independent MB stays readable')
assert(overlay.properties._text=='Umbra'
    and overlay.mb_caption._text=='Magic Burst: 6.9s',
    'Terminal SC has no continuation timer; MB retains live countdown')
assert(overlay.properties.outline_opacity==0
    and overlay.mb_caption.outline_opacity==235,
    'Terminal hides SC ink stroke but preserves independent MB stroke')
assert(overlay.caption_icons.sc[1].image.path_value:match('images/terminal/darkness%.png$')
    and overlay.caption_icons.mb[1].image.path_value:match('images/skillchain/darkness%.png$'),
    'Only SC property glyph uses monochrome terminal artwork')
local black_alpha=prims.sc_resonance_sc_frame.alpha
terminal.now=903.55;terminal.mb_left=6.45
overlay:render(terminal)
assert(prims.sc_resonance_sc_frame.alpha<black_alpha,
    'Monochrome terminal SC fades in place')
terminal.now=903.9;terminal.mb_left=6.1
overlay:render(terminal)
assert(not prims.sc_resonance_sc_frame.visible
    and prims.sc_resonance_mb_ribbon_glow.visible
    and not prims.sc_resonance_mb_base.visible
    and prims.sc_resonance_mb_ribbon_glow.color[1]>0,
    'Terminal SC vanishes and MB returns to normal on its original deadline')
assert(overlay.mb_caption._text=='Magic Burst: 6.1s'
    and overlay.mb_caption.outline_opacity==235,
    'MB timer and its standard dark stroke return after finishing fade')
assert(overlay.caption_icons.mb[1].image.path_value:match('images/skillchain/darkness%.png$'),
    'Original full-color icon is restored after terminal fade')

local light={
    now=1003.2,created=1000,sc_open=1003,step=5,level=4,
    active={'Radiance'},closed=true,sc_wait=0,
    sc_left=2.8,sc_total=3,mb_left=6.8,mb_total=10,
    from_fraction=.5,from_active={'Light'},groups={}
}
overlay:render(light)
assert(not prims.sc_resonance_sc_base.visible
    and prims.sc_resonance_sc_frame.color[1]==255
    and prims.sc_resonance_sc_frame.color[2]==255
    and prims.sc_resonance_mb_ribbon_glow.color[3]==255,
    'Radiance pure white perimeter and MB use no redundant SC track')
assert(overlay.properties.rgb[1]==255
    and overlay.caption_icons.sc[1].image.rgb[1]==255
    and overlay.properties.outline_opacity==0
    and overlay.mb_caption.outline_opacity==235,
    'Radiance SC lettering is pure white while MB stroke stays normal')
assert(overlay.properties._text=='Radiance'
    and overlay.mb_caption._text=='Magic Burst: 6.8s',
    'Radiance SC hides timer but MB retains independent deadline')
assert(overlay.caption_icons.sc[1].image.path_value:match('images/terminal/light%.png$')
    and overlay.caption_icons.mb[1].image.path_value:match('images/skillchain/light%.png$'),
    'Radiance white SC art does not replace independent MB icon')
-- Charge begins immediately with a dark track; it is removed when full.
light.now=1000;light.sc_wait=3;light.mb_left=10
overlay:render(light)
assert(overlay.caption_icons.mb[1].image.path_value:match('images/mb_flash/light%.png$')
    and overlay.mb_flash>.98,
    'First newly created MB window flashes full-white including its icon')
assert(prims.sc_resonance_sc_base.visible and
    overlay.fx.sprites.glow_cap_l.visible,
    'Closed L4 shows charge and original track from initial WS frame')
light.now=1001.5;light.sc_wait=1.5;light.mb_left=8.5
overlay:render(light)
assert(overlay.mb_flash==0
    and overlay.caption_icons.mb[1].image.path_value:match('images/skillchain/light%.png$'),
    'MB white introduction settles to native property art after its window starts')
assert(not prims.sc_resonance_sc_base.visible
    and prims.sc_resonance_sc_frame.visible
    and overlay.properties._text=='Radiance',
    'Terminal full white refill hides track without a fake continuation timer')

local ordinary={
    now=1103.3,created=1100,sc_open=1103,step=3,level=2,
    active={'Fusion'},closed=false,sc_wait=0,
    sc_left=5.7,sc_total=6,mb_left=6.7,mb_total=10,
    from_fraction=.5,from_active={'Detonation'},groups={}
}
overlay:render(ordinary)
assert(prims.sc_resonance_sc_base.visible
    and overlay.properties.outline_opacity>0
    and overlay.caption_icons.sc[1].image.path_value:match('images/skillchain/fusion%.png$'),
    'Next ordinary chain restores dark track, normal stroke and color icon')
local mb_only={now=1207,created=1200,sc_open=1203,step=3,level=2,
    active={'Fusion'},sc_left=0,sc_total=6,sc_wait=0,
    mb_left=3,mb_total=10,closed=false,groups={}}
overlay:render(mb_only)
assert(not overlay.tip.visible and prims.sc_resonance_mb_ribbon_glow.visible,
    'MB-only retains ribbon after SC continuation window closes')
local mb_y=prims.sc_resonance_mb_1.y
mb_only.now=1204;mb_only.sc_left=4
overlay:render(mb_only)
assert(prims.sc_resonance_mb_1.y==mb_y,
    'MB ribbon position does not jump on SC expiry')
-- A new skillchain replacement gets a NEW MB white-introduction beat
-- without borrowing the old chain's continuation period.
local replacement={now=1300,created=1300,sc_open=1303,step=3,level=2,
    active={'Gravitation'},closed=false,sc_wait=3,sc_left=6,sc_total=6,
    mb_left=10,mb_total=10,groups={}}
overlay:render(replacement)
assert(overlay.mb_flash>.98
    and prims.sc_resonance_mb_1.color[1]==255
    and overlay.caption_icons.mb[1].image.path_value:match('images/mb_flash/gravitation%.png$'),
    'Subsequent MB replacement also flashes pure-white bar and icon')
replacement.now=1300.4;replacement.sc_wait=2.6;replacement.mb_left=9.6
overlay:render(replacement)
assert(overlay.mb_flash==0
    and prims.sc_resonance_mb_1.color[1]<255,
    'MB introduction resolves into the colored ribbon, clocks unchanged')
opt.mb.flash='off'
replacement.now=1400;replacement.created=1400
overlay:render(replacement)
assert(overlay.mb_flash==0,'MB white flash is individually disableable')
opt.mb.flash='on'
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
