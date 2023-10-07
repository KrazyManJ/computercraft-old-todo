function writeCenter(dest, text, line)
  local xpos = dest.getSize()/2 - string.len(text)/2+1
  dest.setCursorPos(xpos,line)
  dest.clearLine()
  dest.write(text)    
end

function setStatus(message)
	output = "STATUS: "..message
	writeCenter(term, "#"..string.rep("-", output:len()+6).."#", 11)
	writeCenter(term, "|"..string.rep(" ", output:len()+6).."|", 12)
	writeCenter(term, "|   "..output.."   |", 13)
	writeCenter(term, "|"..string.rep(" ", output:len()+6).."|", 14)
	writeCenter(term, "#"..string.rep("-", output:len()+6).."#", 15)
end

function findSide()
  local sides = {"left","right","top","bottom","back","front"}
  for i=1,6 do 
		if peripheral.getType(sides[i]) == "monitor" then 
			return sides[i]
		end 
	end
end

local disconnected = false
function activateMonitor()
	local tasks = {}
	for task in fs.open("todolist", "r").readAll():gmatch("[^\r\n]+") do
    if task:match("^[^(--)]") then table.insert(tasks, task) end
  end
	if findSide() == nil then 
    disconnected = true
    awaitConnection()
  else
    local side = findSide()
    disconnected = false
		setStatus("Displaying "..side)
    local m = peripheral.wrap(side)
    m.clear()
    writeCenter(m, "TO DO LIST:", 2)
    local start = 3
    for i=1,table.getn(tasks) do
      fit = false
      firstTime = true
      currentText = tasks[i]
      screen = m.getSize()-6
      while not fit do
        m.setCursorPos(2, start+i)
        if string.len(currentText) > screen then 
          split = currentText:sub(0,screen):find("%s[^%s]*$") == nil and screen or currentText:sub(0,screen):find("%s[^%s]*$")
          output = currentText:sub(0,screen):sub(0,split)
          currentText = string.gsub(currentText:sub(split+1), "^%s+", "")
        else
          fit = true
          output = currentText
        end
        start = start + 1
        m.write(firstTime and "=> "..output or "   "..output)
        firstTime = false
      end
    end

    while not disconnected do
			local event, eventArg = os.pullEvent()
			if event == "peripheral_detach" then
				if eventArg == side then
					side = nil
					disconnected = true
					awaitConnection()
				end
			elseif event == "key" then
				if keys.getName(eventArg) == "enter" then
					disconnected = true
					shell.run("edit", "todolist")
					startUp()
				end
			end
      sleep(0.1)  
    end
  end
end

function awaitConnection()
  setStatus("Awaiting monitor connection")
  if not findSide() == nil then activateMonitor() end
  while true do local event, cside = os.pullEvent("peripheral") if disconnected then activateMonitor() end end
end

function startUp()
  if not fs.exists("todolist") then
    local f = fs.open("todolist", "w")
    f.writeLine("--TO DO LIST")
    f.writeLine("")
    f.writeLine("--put each task on new line = new line is separator of them")
    f.writeLine("--also you can add those comments anywhere in file,")
    f.writeLine("--just use double dash symbol combination (--).")
    f.writeLine("")
    f.writeLine("Do the dishes")
    f.writeLine("Make your bed")
    f.writeLine("Mine yourself a lot of lapis lazuli, redstone and diamonds to get rich lmao")
    f.writeLine("Clean you house :) ")
    f.close()
  end
  term.clear()
  writeCenter(term, "##### ####    ###  ####   #    ### #### #####", 2)
  writeCenter(term, "  #   #  #    #  # #  #   #     #  #      #  ", 3)
  writeCenter(term, "  #   #  # ## #  # #  #   #     #  ####   #  ", 4)
  writeCenter(term, "  #   #  #    #  # #  #   #     #     #   #  ", 5)
  writeCenter(term, "  #   ####    ###  ####   #### ### ####   #  ", 6)
  writeCenter(term, "\"Make your tasks to hit your eyes!\"", 8)
  writeCenter(term, "Author: KrazyManJ", 9)
  writeCenter(term, "Press Enter to edit your to-do list!", 17)
  activateMonitor()
end

startUp()
