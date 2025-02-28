local settext = BitmapText.settext
local isPractice = GAMESTATE:GetPlayerState(PLAYER_1):GetCurrentPlayerOptions():UsingPractice()

local function highlight(self)
	self:queuecommand("Highlight")
end

local function highlightIfOver(self)
	if isOver(self) then
		self:diffusealpha(0.2)
	else
		self:diffusealpha(1)
	end
end

return Def.ActorFrame {
	OnCommand = function(self)
		SCREENMAN:GetTopScreen():AddInputCallback(MovableInput)
		self:SetUpdateFunction(highlight)
	end,
	Def.BitmapText {
		Name = "message",
		Font = "Common Normal",
		InitCommand = function(self)
			Movable.message = self
			self:horizalign(left):vertalign(top):shadowlength(2):xy(10, 20):zoom(.5):visible(false)
		end
	},
	Def.BitmapText {
		Name = "Instructions",
		Font = "Common Normal",
		InitCommand = function(self)
			self:horizalign(left):vertalign(top):xy(SCREEN_WIDTH - 240, 20):zoom(.45):visible(true)
		end,
		HighlightCommand = function(self)
			highlightIfOver(self)
		end,
		OnCommand = function(self)
			local text = {
				"Enable AutoplayCPU with shift+f8\n",
				"Press keys to toggle active elements",
				"Right click cancels any active element\n",
				"1: Judgement Text Position",
				"2: Judgement Text Size",
				"3: Combo Text Position",
				"4: Combo Text Size",
				"5: Error Bar Position",
				"6: Error Bar Size",
				"7: Target Tracker Position",
				"8: Target Tracker Size",
				"w: Display Percent Text Position",
				"e: Display Percent Text Size",
				"r: Notefield Position",
				"t: Notefield Size",
				"y: NPS Display Text Position",
				"u: NPS Display Text Size",
				"i: NPS Graph Position",
				"o: NPS Graph Size",
				"p: Judge Counter Position",
				"a: Leaderboard Position",
				"s: Leaderboard Size",
				"d: Leaderboard Spacing",
				--"h: Replay Buttons Spacing",
				"j: Player Info Position",
				"k: Player Info Size",
			}
			if playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).LaneCover ~= 0 then
				table.insert(text, "/: Lane Cover Height")
			end
			if isPractice then
				table.insert(text, "z: Density Graph Position")
			end
			self:settext(table.concat(text, "\n"))
		end
	}
}
