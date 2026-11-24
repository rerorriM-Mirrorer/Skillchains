-- Test7.29: Cioara's look became the default. Frame tests written against the
-- Test7.28 defaults pin them (resonance_motion.base) in place, so every
-- module holding the defaults table sees the same values.
local m=require('resonance_motion')
for k in pairs(m.defaults)do m.defaults[k]=nil end
for k,v in pairs(m.base)do m.defaults[k]=v end
return m.defaults
