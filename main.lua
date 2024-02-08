#!/usr/bin/lua5.1

boom = require "boom"

local anim = boom.load("data/test.animation")

if not anim then
    print("animation object was nil")
    os.exit()
end

print("anim sprite path is: "..anim.imagePath)

for k,v in pairs(anim.states) do
    print("state="..k)
end

print("Duration of SHOOT3 is "..anim:duration("SHOOT3"))

anim:refresh("SHOOT3")

print("origin=(x="..anim.currFrame.originx..",y="..anim.currFrame.originy..")")

print("Done")