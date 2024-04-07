--[[
    @author TheMaverickProgrammer
    @github https://github.com/TheMaverickProgrammer/boomsheetslua
    @module boom
    @date 1/23/2021
    @updated 4/6/2024
    @description This is PARTIAL lua port of the boomsheet anim file format for 2D spritesheets
    @warning It can be used as-is withs files from boomsheets but does not comply to the full file format spec!

    @example
    ```
    anim = boom.load(path)       -- loads the animation from path and stores it in the anim table
    t    = anim:duration(state)  -- returns the duration of the animation state in frames
    f    = anim:set(state)       -- sets `elapsed` ticks to zero and applies the first frame from that state
    f    = anim:update(ticks)    -- updates animation by ticks elapsed and returns the current frame

    print(anim.image_path)       -- prints the image path
    print(anim.elapsed)          -- the elapsed time for this animation in ticks (hertz agnostic)
    anim.curr_frame              -- can access the a copy of the frame's table
    anim.curr_state              -- can access the last set state table ref
    anim.curr_state_name         -- string name of the last set state

    anim.states.ATTACK_PUNCH.loop = true -- tell this animation state to loop (default false)
    ```
--]]

local boom = {}

-- Load a *.anim file at `path`. Return true if parsing was successful, false otherwise.
function boom.load(path)
    -- animations keep a list of all states, elapsed time, image path, 
    -- and the lookup for the recent frame
    local animation = {
        elapsed=0,
        curr_state_name="",
        image_path="",
        states={},
        curr_frame={},
        curr_state={},
}

    -- @return result of removed quotes in input string
    local function cleanstr(str)
        if str ~= nil then
            str, _ = str:gsub('\"', '')
        end

        return str
    end

    -- @return the total duration of an anim state in seconds
    function animation.duration(self, state)
        local time = 0
        for _,frame in ipairs(self.states[state].framelist) do
            time = time + frame.duration
        end
        return time
    end

    -- reset the current frame and the ticks to zero
    -- @return changes `curr_frame` and `curr_state`
    function animation.set(self, state)
        self.elapsed = 0
        self.curr_state = self.states[state]
        self.curr_state_name = state
        return animation.update(self, 0)
    end

    -- update the animation state by elapsed ticks
    -- @return updated frame `curr_frame`
    function animation.update(self, ticks)
        self.elapsed = self.elapsed + ticks

        local duration = self:duration(self.curr_state_name)

        if self.elapsed > duration then
            self.elapsed = duration
        end

        local e = self.elapsed
        local index = 1

        while e > 0 and index <= #self.curr_state.framelist do
            e = e - self.curr_state.framelist[index].duration

            -- If true, this frame had time left to complete
            if e > 0 then
                index = index + 1
            end

            if index > #self.curr_state.framelist then
                if self.curr_state.loop then
                    index = 1
                else
                    index = index - 1
                end
            end
        end

        local curr_frame = self.curr_state.framelist[index]

        -- COPY values over to lookup table
        for k,v in pairs(curr_frame) do
            self.curr_frame[k] = v
        end

        return self.curr_frame
    end

    -- extract the contents of the file
    local file = io.open(path, "rb")
    if not file then
        -- failed to open? return nil
        return nil
    else
        -- otherwise, close
        file:close()
    end

    local curr_state = ""

    -- for each line, tokenize everything between spaces
    for line in io.lines(path) do
        local tokens = {}
        for token in line:gmatch("([^%s]+)%s*") do
            table.insert(tokens, token)
        end

        local key = tokens[1]

        -- most keys have attributes in the form of "key=value"
        -- some keys like "image_path" are directly assigned to their value
        if  key == "!image_path" then
            animation.image_path = cleanstr(tokens[2])
        elseif key == "!frame_rate" then
            animation.frame_rate = tonumber(cleanstr(tokens[2]))
        elseif key == "animation" or key == "anim" then
            -- add a new state table to our animation
            local fields = {}
            for token in tokens[2]:gmatch("([^=]+)") do
                table.insert(fields, token)
            end

            local state = fields[2]

            if not state then
                state = fields[1] -- optional no "state" key being used
            end

            curr_state = cleanstr(state)

            -- prepopulate our state table with framelist and set looping to false
            animation.states[curr_state] = {framelist={},loop=false}
        elseif key == "frame" then
            -- remove the key, we already accounted for it
            table.remove(tokens, 1)

            -- construct new frame data
            local frame = {}
            for _, v in ipairs(tokens) do
                -- string.gmatch() doesn't return a counter or iterator
                -- so we must toggle whether our first token was the key
                -- or the value...
                local is_key = true
                local last_key = nil -- track the key
                for token in v:gmatch("([^=]+)") do
                    token = cleanstr(token)
                    if is_key then
                        last_key = token
                        -- "duration" can be shortened to "dur"
                        if last_key == "dur" then
                            --[[ 
                                Expand so that in lua the prop is always
                                accessed by `.duration`
                            --]]
                            last_key = "duration"
                        end
                    elseif last_key then -- extract value

                        -- Edge case: frames have an f at the end
                        local tail = #token
                        if token:sub(tail) == "f" then
                            token = token:sub(0, tail-1)
                        end

                        local value = tonumber(token)

                        -- set the table
                        frame[last_key] = value
                    end
                    is_key = not is_key -- toggle flag
                end
            end
            -- add this new frame into our animation state's frame list
            table.insert(animation.states[curr_state].framelist, frame)
        end
    end

    -- return the fully constructed animation object
    return animation
end

-- export module
return boom