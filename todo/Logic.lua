function Initialize()
	FilePath = SKIN:GetVariable('CURRENTPATH') .. 'List.txt'
	UpdateList()
end

function UpdateList()
	-- Read the file
	local file = io.open(FilePath, "r")
	if not file then return end
	local content = file:read("*all")
	file:close()

	-- Parse lines
	local i = 1
	for line in content:gmatch("[^\r\n]+") do
		if i > 10 then break end -- Limit to 10 tasks for UI stability
		
		-- Split State|Content (e.g., "0|Buy Milk")
		local state, text = line:match("^(%d+)|(.*)")
		
		if state and text then
			SKIN:Bang('!SetOption', 'MeterTask'..i, 'Text', text)
			SKIN:Bang('!SetOption', 'MeterCheck'..i, 'Hidden', '0')
			SKIN:Bang('!SetOption', 'MeterTask'..i, 'Hidden', '0')
			SKIN:Bang('!SetOption', 'MeterDel'..i, 'Hidden', '0')
			
			-- Handle Checkbox visuals
			if state == '1' then
				SKIN:Bang('!SetOption', 'MeterCheck'..i, 'Shape', 'Rectangle 0,0,14,14,3 | Fill Color 138,180,248,255 | StrokeWidth 0')
				SKIN:Bang('!SetOption', 'MeterTask'..i, 'FontColor', '154,160,166,255')
				SKIN:Bang('!SetOption', 'MeterTask'..i, 'InlineSetting', 'Strikethrough')
			else
				SKIN:Bang('!SetOption', 'MeterCheck'..i, 'Shape', 'Rectangle 0,0,14,14,3 | Fill Color 0,0,0,0 | StrokeWidth 2 | Stroke Color 154,160,166,255')
				SKIN:Bang('!SetOption', 'MeterTask'..i, 'FontColor', '232,234,237,255')
				SKIN:Bang('!SetOption', 'MeterTask'..i, 'InlineSetting', 'None')
			end
		end
		i = i + 1
	end

	-- Hide unused slots
	for j = i, 10 do
		SKIN:Bang('!SetOption', 'MeterCheck'..j, 'Hidden', '1')
		SKIN:Bang('!SetOption', 'MeterTask'..j, 'Hidden', '1')
		SKIN:Bang('!SetOption', 'MeterDel'..j, 'Hidden', '1')
	end
	
	SKIN:Bang('!UpdateMeterGroup', 'Tasks')
	SKIN:Bang('!Redraw')
end

function Add(newText)
	if newText == "" then return end
	local file = io.open(FilePath, "a+")
	file:write("0|" .. newText .. "\n")
	file:close()
	UpdateList()
end

function Toggle(index)
	local lines = {}
	for line in io.lines(FilePath) do table.insert(lines, line) end
	
	local state, text = lines[index]:match("^(%d+)|(.*)")
	local newState = (state == '1') and '0' or '1'
	lines[index] = newState .. "|" .. text
	
	WriteFile(lines)
end

function Delete(index)
	local lines = {}
	for line in io.lines(FilePath) do table.insert(lines, line) end
	table.remove(lines, index)
	WriteFile(lines)
end

function WriteFile(lines)
	local file = io.open(FilePath, "w")
	for _, line in ipairs(lines) do file:write(line .. "\n") end
	file:close()
	UpdateList()
end