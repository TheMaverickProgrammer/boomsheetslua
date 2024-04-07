# `boomsheetslua`
This is a PARTIAL lua port of the boomsheet animation file format for 2D spritesheets.

## Warning
This parser is not spec-compliant with the underlining file format that boomsheet animations uses!
It should work with the standard output file of the boomsheet tool.

## Example
```lua
    anim = boom.load(path)       -- loads the animation from path and stores it in the anim table
    t    = anim:duration(state)  -- returns the duration of the animation state in frames
    f    = anim:set(state)       -- sets `elapsed` ticks to zero and applies the first frame from that state
    f    = anim:update(ticks)    -- updates animation by ticks elapsed and returns the current frame

    anim.image_path              -- prints the image path
    anim.elapsed                 -- the elapsed time for this animation in ticks (hertz agnostic)
    anim.curr_frame              -- can access the a copy of the frame's table
    anim.curr_state              -- can access the last set state table ref
    anim.curr_state_name         -- string name of the last set state

    anim.states.ATTACK_PUNCH.loop = true -- tell this animation state to loop (default false)
```