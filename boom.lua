local boom = {}

function boom.load(path)
    local animation = {states={},imagePath=""}

    function cleanstr(str)
        str, _ = str:gsub('\"', '')
        return str
    end

    function animation.duration(self, state)
        local time = 0
        for _,frame in ipairs(self.states[state].framelist) do
            time = time + frame.duration
        end
        return time
    end

    function animation.update(self, seconds)
        self.elapsed = self.elasped + seconds
        local duration = self:duration()

        if self.elapsed > duration then
            self.elapsed = duration
        end

        local e = self.elapsed 
        local index = 1

        while e > 0 and index <= #self.framelist do 
            e = e - self.framelist[index].seconds
            index = index + 1

            if index > #self.framelist then
                self.elapsed = self.elapsed - duration

                if self.loop then
                    index = 1
                end
            end
        end

        local currFrame = self.framelist[index]
        self.currWidth = currFrame.currWidth
        self.currHeight = currFrame.currWidth
        self.origin = currFrame.origin
    end

    -- extract the contents of the file
    local file = io.open(path, "rb")
    if not file then 
        return nil
    else
        file:close()
    end

    local currState = ""

    for line in io.lines(path) do
        local tokens = {}
        for token in line:gmatch("([^%s]+)%s*") do
            table.insert(tokens, token)
        end

        local key = tokens[1]
        local imagePathKey = nil
        
        if key then 
            imagePathKey = key:sub(0,9)
        end
        
        if  imagePathKey == "imagePath" then
            animation.imagePath = cleanstr(key:sub(11))
        elseif key == "animation" then 
            local attrs = {}
            for token in tokens[2]:gmatch("([^=]+)") do
                table.insert(attrs, token)
            end

            if not attrs[2] then 
                return nil -- malformed
            end

            currState = cleanstr(attrs[2])
            animation.states[currState] = {framelist={}}
        elseif key == "frame" then
            table.remove(tokens, 1)
            local frame = {}
            for _, v in ipairs(tokens) do
                local is_key = true
                local last_key = nil
                for token in v:gmatch("([^=]+)") do
                    if is_key then
                        last_key = cleanstr(token)
                    else
                        local value = tonumber(cleanstr(token))
                        frame[last_key] = value
                    end
                    is_key = not is_key
                end
            end
            table.insert(animation.states[currState].framelist, frame)
        end 
    end

    return animation
end

-- export module
return boom