local top
local whee

-- Actor for handling most mouse interactions.
local function input(event)
	if event.type == "InputEventType_FirstPress" then
		if event.DeviceInput.button == "DeviceButton_left mouse button" then
			MESSAGEMAN:Broadcast("MouseLeftClick")
		end
		if event.DeviceInput.button == "DeviceButton_right mouse button" then
			MESSAGEMAN:Broadcast("MouseRightClick")
		end
	end

	local mouseX = INPUTFILTER:GetMouseX()
	local mouseY = INPUTFILTER:GetMouseY()

	if whee and mouseX > capWideScale(370, 500) and mouseX < SCREEN_WIDTH - 32 then
		if event.DeviceInput.button == "DeviceButton_left mouse button" and event.type == "InputEventType_FirstPress" then
			local n = 0
			local m = 1
			if mouseY > 212 and mouseY < 264 then
				m = 0
			elseif mouseY > 264 and mouseY < 312 then
				m = 1
				n = 1
			elseif mouseY > 312 and mouseY < 360 then
				m = 1
				n = 2
			elseif mouseY > 360 and mouseY < 408 then
				m = 1
				n = 3
			elseif mouseY > 408 and mouseY < 456 then
				m = 1
				n = 4
			elseif mouseY > 456 and mouseY < 500 then
				m = 1
				n = 5
			elseif mouseY > 164 and mouseY < 212 then
				m = -1
				n = 1
			elseif mouseY > 112 and mouseY < 164 then
				m = -1
				n = 2
			elseif mouseY > 68 and mouseY < 112 then
				m = -1
				n = 3
			elseif mouseY > 20 and mouseY < 68 then
				m = -1
				n = 4
			elseif mouseY > -30 and mouseY < 20 then
				m = -1
				n = 5
			end

			local type = whee:MoveAndCheckType(m * n)
			whee:Move(0)
			if m == 0 then
				top:SelectCurrent(0)
			end
		end
	end

	return false

end

local t = Def.ActorFrame{
	OnCommand = function(self)
		BUTTON:resetPressedActors()

		SCREENMAN:set_input_redirected(PLAYER_1, false)

		top = SCREENMAN:GetTopScreen()
		if top:GetName() == "ScreenSelectMusic" or top:GetName() == "ScreenNetSelectMusic" or top:GetName() == "ScreenNetRoom" then
			whee = top:GetMusicWheel()
		end
		top:AddInputCallback(input)
	end,
	OffCommand = function(self)
		BUTTON:resetPressedActors()
	end,
	MouseLeftClickMessageCommand = function(self)
		self:queuecommand("PlayTopPressedActor")
	end,
	MouseRightClickMessageCommand = function(self)
		self:queuecommand("PlayTopPressedActor")
	end,
	PlayTopPressedActorCommand = function(self)
		BUTTON:playTopPressedActor()
		BUTTON:resetPressedActors()
	end,
	ExitScreenMessageCommand = function(self, params)
		if params.screen == top:GetName() then
			top:StartTransitioningScreen("SM_GoToPrevScreen")
		end
	end
}

return t