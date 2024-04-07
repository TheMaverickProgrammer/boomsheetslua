#!/usr/bin/lua5.1

--[[
    @author TheMaverickProgrammer
    @github https://github.com/TheMaverickProgrammer/boomsheetslua
    @date 1/23/2021
    @description Test this minimal port of the boom lua lib
--]]

local boom = require "boom"
local anim = boom.load("data/test.anim")

if not anim then
    print("animation object was nil")
    os.exit()
end

print("===============\n=RUNNING TESTS=\n===============")

print("anim sprite path is: "..anim.image_path)

for k,v in pairs(anim.states) do
    print("state="..k)
end

-- Calculate frames (but do not switch state!)
local duration = anim:duration("SHOOT3")

-- If framerate is set, frame durations are in ticks per refresh rate (hz)
if anim.frame_rate ~= nil then
    duration = duration.." frames @ "..anim.frame_rate.." hz"
else
    -- Otherwise, support legacy seconds...
    duration = duration.." seconds"
end

print("Duration of SHOOT3 is "..duration)

-- Now try changing states
anim:set("SHOOT3")
print("origin=(x="..anim.curr_frame.originx..",y="..anim.curr_frame.originy..")")

if anim.frame_rate ~= nil then
    anim:update(18) -- add 18 ticks of time to animation
else
    anim:update(18*60) -- convert to legacy seconds
end

-- print the frame data
print("current state="..anim.curr_state_name)
print("elapsed ticks="..anim.elapsed)
print("x="..anim.curr_frame.x..",y="..anim.curr_frame.y..",w="..anim.curr_frame.w..",h="..anim.curr_frame.h)

 -- change state resets
anim:set("IDLE3")
print("current state="..anim.curr_state_name)
print("elapsed ticks="..anim.elapsed)
print("x="..anim.curr_frame.x..",y="..anim.curr_frame.y..",w="..anim.curr_frame.w..",h="..anim.curr_frame.h)

print("==========\n=COMPLETE=\n==========")