
local sdl = require "SDL"
local ttf = require "SDL.ttf"

local Object = require "object"

local _M = {
	Widget    = require "widgets.widget",
	Window    = require "widgets.window",
	Button    = require "widgets.button",
	Frame     = require "widgets.frame",

	fonts = require "fonts"
}

function _M:init()
	local r, err = sdl.init {
		sdl.flags.Video
	}

	if not r then
		return nil, err
	end

	r, err = ttf.init()
	r, err = ttf.init()

	if not r then
		return nil, err
	end

	return true
end

function _M:loadFont(name, path, size)
	local f, err = ttf.open(path, size)

	-- We’re checking it exists to not overwrite any other previously
	-- stored font.
	if f then
		fonts[name] = f
	end

	return f, err
end

local lastTime

function _M:run(elements)
	local time
	local timeDiff

	for e in sdl.pollEvent() do
		local i = 1
		while i <= #elements do
			local element = elements[i]

			if element:handleEvent(e) then
				i = #elements + 1
			else
				i = i + 1
			end
		end
	end

	-- Time differential. Required before updates.
	time = sdl.getTicks()
	if lastTime then
		timeDiff = time - lastTime
	else
		timeDiff = 0
		lastTime = time
	end

	if timeDiff < 1000/60 then
		sdl.delay(1000/60 - timeDiff)

		time = sdl.getTicks()
		timeDiff = time - lastTime
	end

	lastTime = time

	-- Update
	for i = 1, #elements do
		local element = elements[i]

		if element.update then
			element:update(timeDiff)
		end
	end

	-- Drawing
	for i = 1, #elements do
		local element = elements[i]

		element.renderer:setDrawColor(element.backgroundColor)
		element.renderer:clear()

		if element.draw then
			element:draw(element.renderer)
		end

		element.renderer:present()
	end

	-- Checking for exit request
	for i = 1, #elements do
		local element = elements[i]

		if element.exit then
			return false
		end
	end

	return true
end

return _M

