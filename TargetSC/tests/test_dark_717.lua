-- Test7.17: per-surface Dark glows (opener / rings / MB ring / bursts),
-- MB ring black core, Dark ring back side, `preview dark mb`. Simulated, not FFXI.
package.path='./TargetSC/?.lua;'..package.path
local R=require('resonance');local P=require('resonance_preview');local C=require('resonance_controls')
R.native_level=12
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local function cioara()local a=copy(require('tests.fixture_cioara_1122'))for k,v in pairs(R.defaults)do if a[k]==nil then a[k]=v end end return a end
local function rgb(c)return c%16777216 end
local function alpha(c)return math.floor(c/16777216)end
local function hex(t)return t[1]*65536+t[2]*256+t[3]end
local VIOLET,WHITE=hex({130,70,255}),hex({255,255,255})
local function frame_of(args,t,o)
    local p=P.new(P.parse(args,R),81,0,R,o);p:advance(t)
    return p.model:frame(81,t,2,4,o),p
end
local function find(f,pred)local r={}for _,v in ipairs(f)do if pred(v)then r[#r+1]=v end end return r end

assert(R.defaults.dark_glow_opener=='same'and R.defaults.dark_glow_ring=='same'and R.defaults.dark_glow_mb=='same'
    and R.defaults.dark_glow_burst=='mb'and R.defaults.dark_mb_core=='glow'and R.defaults.dark_ring_back=='off'
    and R.defaults.dark_ring_back_gain==1,'defaults keep Test7.16')

-- Defaults ('same') = Test7.16 exactly: violet ring glow, violet MB core.
local o=cioara();o.dark_look='void';R.apply_colors(o)
local f=frame_of({'window','Compression'},5,o)
for _,v in ipairs(find(f,function(v)return v.role=='glow'and v.part=='ground'end))do assert(rgb(v.color)==VIOLET,'same ring glow')end
for _,v in ipairs(find(f,function(v)return v.part=='mb'and v.role=='core'end))do assert(rgb(v.color)~=0,'glow core mode')end

-- A's recipe: base black, opener white, MB violet, black MB core.
o.dark_glow='0,0,0';o.dark_glow_opener='255,255,255';o.dark_glow_mb='elemental';o.dark_mb_core='black';R.apply_colors(o)
assert(hex(R.burst_color('Dark'))==VIOLET,'bursts follow the MB glow')
f=frame_of({'window','Compression'},5,o)
local rg=find(f,function(v)return v.role=='glow'and (v.part=='ground'or v.part=='sky')end)
assert(#rg>=2,'ring glows');for _,v in ipairs(rg)do for _,c in ipairs(v.colors)do assert(rgb(c)==0,'ring glow black')end end
local mc=find(f,function(v)return v.part=='mb'and v.role=='core'end)
local mg=find(f,function(v)return v.part=='mb'and v.role=='glow'end)
assert(#mc>=1 and #mg>=1,'MB ring drawn')
for _,v in ipairs(mc)do assert(rgb(v.color)==0,'MB core black')end
for _,v in ipairs(mg)do assert(rgb(v.color)==VIOLET,'MB glow violet')end
-- Opener: Gravitation's (Dark) arcs glow white; Scission's keep the black opener glow.
f=frame_of({'opener','Gravitation,Scission'},5,o)
local white,black=false,false
for _,v in ipairs(find(f,function(v)return v.kind=='arc'and v.role=='glow'end))do
    if rgb(v.color)==WHITE then white=true elseif rgb(v.color)==0 then black=true end
end
assert(white and black,'opener glow white on Dark arcs only')
-- Burst override and 'mb' follow.
o.dark_glow_burst='same';R.apply_colors(o);assert(hex(R.burst_color('Dark'))==0,'burst same = base')
o.dark_glow_burst='mb';R.apply_colors(o);assert(hex(R.burst_color('Dark'))==VIOLET,'burst back to mb')

-- Back side on: Compression's ring glow = black lit side, violet dim side.
o.dark_ring_back='on'
f=frame_of({'window','Compression'},5,o)
local g=find(f,function(v)return v.role=='glow'and v.part=='ground'end)[1]
assert(#g.colors==4 and rgb(g.colors[1])==0 and rgb(g.colors[2])==0 and rgb(g.colors[3])==VIOLET and rgb(g.colors[4])==VIOLET,'back violet')
local a3=alpha(g.colors[3])
o.dark_ring_back_gain=2
g=find(frame_of({'window','Compression'},5,o),function(v)return v.role=='glow'and v.part=='ground'end)[1]
assert(alpha(g.colors[3])>a3,'gain brightens the back side')
o.dark_ring_back_gain=1
-- Gravitation's two strands are mirrored: strand 1 = Dark lit side (glow
-- stays black there, Earth behind), strand 2 = Earth lit side, Dark dim side violet.
local gg=find(frame_of({'window','Gravitation'},5,o),function(v)return v.role=='glow'and v.part=='ground'end)
assert(rgb(gg[1].colors[1])==0 and rgb(gg[1].colors[4])~=VIOLET,'Gravitation strand 1')
assert(rgb(gg[2].colors[1])~=0 and rgb(gg[2].colors[1])~=VIOLET and rgb(gg[2].colors[4])==VIOLET,'Gravitation strand 2 back')
-- Light-side rings untouched.
g=find(frame_of({'window','Fusion'},5,o),function(v)return v.role=='glow'and v.part=='ground'end)[1]
for _,c in ipairs(g.colors)do assert(rgb(c)~=VIOLET,'Fusion untouched')end
-- Classic look ignores all of it.
local cl=copy(o);cl.dark_look='classic';R.apply_colors(cl)
g=find(frame_of({'window','Compression'},5,cl),function(v)return v.role=='glow'and v.part=='ground'end)[1]
for _,c in ipairs(g.colors)do assert(rgb(c)==hex({25,14,52}),'classic unchanged')end
R.apply_colors(o)

-- preview dark mb: Requiescat links, fifteen Dark bursts, ends 40 s.
for _,a in ipairs({{'dark','mb'},{'requiescat','dark'}})do assert(P.parse(a,R).kind=='darkmb',table.concat(a,' '))end
assert(P.parse({'mb','dark'},R).kind=='mbdark','mb dark unchanged')
assert(P.parse({'requiescat'},R).kind=='requiescatdemo','requiescat unchanged')
local p=P.new(P.parse({'dark','mb'},R),82,0,R,o)
local bursts,chains=0,0
for _,e in ipairs(p.events)do
    if e.kind=='burst'then bursts=bursts+1;assert(e.element=='Dark'and hex(e.color)==VIOLET,'Dark burst')end
    if e.kind=='chain'then chains=chains+1 end
end
assert(bursts==#P.dark_hits and bursts==15 and chains==4,'events')
assert(math.abs(p.ends-40.05)<1e-6,'ends 40s')
assert(p.description:find('^Dark MB demo'),'description')
-- Runs through, drawing every 0.2 s.
local t=0
while not p:advance(t)do assert(p.model:frame(82,t,2,4,o),'frame '..t);t=t+.2 end
assert(t>=40,'played to the end')

-- Commands.
local settings=copy(R.defaults);local said
local cmd=C.new(settings,R.defaults,function()end,function(m)said=m end,R.killala,R.cioara)
assert(cmd('dark',{'glow','0','0','0'})and settings.dark_glow=='0,0,0')
assert(cmd('dark',{'glow','opener','255','255','255'})and settings.dark_glow_opener=='255,255,255'and settings.dark_glow=='0,0,0')
assert(cmd('dark',{'glow','mb','elemental'})and settings.dark_glow_mb=='elemental')
assert(cmd('dark',{'glow','rings','indigo'})and settings.dark_glow_ring=='indigo')
assert(cmd('dark',{'glow','ring','same'})and settings.dark_glow_ring=='same')
assert(cmd('dark',{'glow','burst','mb'})and settings.dark_glow_burst=='mb')
assert(cmd('dark',{'glow','opener','mb'})and settings.dark_glow_opener=='255,255,255'and said:find('^Use'))
assert(cmd('dark',{'glow','same'})and settings.dark_glow=='0,0,0'and said:find('^Use'))
assert(cmd('dark',{'mb','core','black'})and settings.dark_mb_core=='black')
assert(cmd('dark',{'mb','core','grey'})and settings.dark_mb_core=='black'and said:find('^Use'))
assert(cmd('dark',{'back','on'})and settings.dark_ring_back=='on')
assert(cmd('dark',{'back','1.5'})and settings.dark_ring_back_gain==1.5)
assert(cmd('dark',{'back','9'})and settings.dark_ring_back_gain==1.5)
assert(cmd('dark',{'back','off'})and settings.dark_ring_back=='off')
assert(not said:find('[\128-\255]'),'ASCII')
R.apply_colors(copy(R.defaults))
print('PASS Test7.17 per-surface Dark glows, MB black core, Dark ring back side, preview dark mb')
