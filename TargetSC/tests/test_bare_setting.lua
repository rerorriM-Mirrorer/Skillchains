-- Test7.10: a bare number setting reports its current value with the range.
package.path='./TargetSC/?.lua;'..package.path
require('tests.pin_classic') -- Test7.29: Test7.28 defaults
local R=require('resonance')
local C=require('resonance_controls')
local function copy(t)local r={}for k,v in pairs(t)do r[k]=v end return r end
local settings=copy(R.defaults)
local said={}
local cmd=C.new(settings,R.defaults,function()end,function(m)said[#said+1]=m end,R.killala)
local function last()return said[#said]end
assert(cmd('rings',{'level4','gap'}))
assert(last()=='Use //tsc rings level4 gap <-0.2-0.3>. Now 0.030.',last())
assert(cmd('rings',{'level4','gap','.05'})and last()=='rings level4 gap = 0.050')
assert(cmd('rings',{'level4','gap'})and last():find('Now 0.050%.$'),last())
assert(cmd('rings',{'level4','gap','9'})and last():find('Now 0.050%.$')and settings.ring_level4_gap==.05,last())
-- A setting missing from the saved file falls back to the default.
settings.mb_level4_depth=nil
assert(cmd('mb',{'level4','depth'})and last()=='Use //tsc mb level4 depth <0-1>. Now 1.000.',last())
-- Group settings (mb, hum, sky ...) share the helper.
assert(cmd('mb',{'opacity'})and last():find('^Use //tsc mb opacity <0%-1>%. Now 0%.390%.$'),last())
for _,m in ipairs(said)do assert(not m:find('[\128-\255]'),'ASCII only: '..m)end
print('PASS Test7.10 bare settings report the current value with the range (incl. defaults fallback, groups, ASCII)')
