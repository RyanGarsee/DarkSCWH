local t = Def.ActorFrame{}
local song = GAMESTATE:GetCurrentSong()
local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(PLAYER_1)
local steps = GAMESTATE:GetCurrentSteps(pn)

--ScoreBoard
local judges = {'TapNoteScore_W1','TapNoteScore_W2','TapNoteScore_W3','TapNoteScore_W4','TapNoteScore_W5','TapNoteScore_Miss'}
local hjudges = {'HoldNoteScore_Held','HoldNoteScore_LetGo','HoldNoteScore_MissedHold'}
local frameX = SCREEN_CENTER_X/2
local frameY = 150
local frameWidth = SCREEN_CENTER_X-WideScale(get43size(40),40)
local frameHeight = 300
local rate = getCurRate()
local judge = GetTimingDifficulty()

-- Reset preview music starting point since song was finished.
GHETTOGAMESTATE:setLastPlayedSecond(0)

-- etc timing info
local nrv = pss:GetNoteRowVector()
local dvt = pss:GetOffsetVector()
local ctt = pss:GetTrackVector()
local ntt = pss:GetTapNoteTypeVector()
local totalTaps = pss:GetTotalTaps()

local rescoredPercentage

local t = Def.ActorFrame {}

t[#t+1] = Def.ActorFrame {
	OffsetPlotModificationMessageCommand = function(self, params)
		local score = pss:GetHighScore()
		local totalHolds =
			pss:GetRadarPossible():GetValue("RadarCategory_Holds") + pss:GetRadarPossible():GetValue("RadarCategory_Rolls")
		local holdsHit =
			score:GetRadarValues():GetValue("RadarCategory_Holds") + score:GetRadarValues():GetValue("RadarCategory_Rolls")
		local minesHit =
			pss:GetRadarPossible():GetValue("RadarCategory_Mines") - score:GetRadarValues():GetValue("RadarCategory_Mines")
		if enabledCustomWindows then
			if params.Name == "PrevJudge" then
				judge = judge < 2 and #customWindows or judge - 1
				customWindow = timingWindowConfig:get_data()[customWindows[judge]]
				rescoredPercentage = getRescoredCustomPercentage(dvt, customWindow, totalHolds, holdsHit, minesHit, totalTaps)
			elseif params.Name == "NextJudge" then
				judge = judge == #customWindows and 1 or judge + 1
				customWindow = timingWindowConfig:get_data()[customWindows[judge]]
				rescoredPercentage = getRescoredCustomPercentage(dvt, customWindow, totalHolds, holdsHit, minesHit, totalTaps)
			end
		elseif params.Name == "PrevJudge" and judge > 1 then
			judge = judge - 1
			rescoredPercentage = getRescoredWifeJudge(dvt, judge, totalHolds - holdsHit, minesHit, totalTaps)
		elseif params.Name == "NextJudge" and judge < 9 then
			judge = judge + 1
			rescoredPercentage = getRescoredWifeJudge(dvt, judge, totalHolds - holdsHit, minesHit, totalTaps)
		end
		if params.Name == "ResetJudge" then
			judge = enabledCustomWindows and 0 or GetTimingDifficulty()
			self:GetParent():playcommand("ResetJudge")
		elseif params.Name ~= "ToggleHands" then
			self:GetParent():playcommand("SetJudge", params)
		end
	end
}

-- Timing/Judge Difficulty
t[#t+1] = LoadFont("Common Normal")..{
	InitCommand = function(self)
		self:xy(10,40)
		self:zoom(0.4)
		self:halign(0)
		self:diffuse(color(colorConfig:get_data().evaluation.BackgroundText)):diffusealpha(0.8)
		self:queuecommand("Set")
	end,
	SetCommand = function(self)
		self:settextf("Timing Difficulty: %d",judge)
	end,
	SetJudgeCommand = function(self)
		self:queuecommand("Set")
	end,
	ResetJudgeCommand = function(self)
		self:queuecommand("Set")
	end
}

-- Life Difficulty
t[#t+1] = LoadFont("Common Normal")..{
	InitCommand = function(self)
		self:xy(10,55)
		self:zoom(0.4)
		self:halign(0)
		self:diffuse(color(colorConfig:get_data().evaluation.BackgroundText)):diffusealpha(0.8)
		self:settextf("Life Difficulty: %d",GetLifeDifficulty())
	end
}

-- Music Rate/Haste
t[#t+1] = LoadFont("Common Normal")..{
	InitCommand = function(self)
		self:xy(10,70)
		self:zoom(0.4)
		self:halign(0)
		self:diffuse(color(colorConfig:get_data().evaluation.BackgroundText)):diffusealpha(0.8)
		self:settextf("Music Rate: %s", rate)
	end
}

-- Mod List
t[#t+1] = LoadFont("Common Normal")..{
	InitCommand = function(self)
		self:xy(10,85)
		self:zoom(0.4)
		self:halign(0)
		self:maxwidth(SCREEN_WIDTH - (266/2) - 45)
		self:diffuse(color(colorConfig:get_data().evaluation.BackgroundText)):diffusealpha(0.8)
		local mods = GAMESTATE:GetPlayerState(PLAYER_1):GetPlayerOptionsString("ModsLevel_Current")
		self:settextf("Mods: %s", mods)
	end
}

-- Background Quad for Song banner
t[#t+1] = Def.Quad{
	InitCommand = function(self)
		self:zoomto(256+10,80+10)
		self:xy(SCREEN_CENTER_X,70)
		self:diffuse(getMainColor("frame")):diffusealpha(0.8)
	end
}

-- Song banner
t[#t+1] = Def.Sprite {
	BeginCommand = function(self)
		if song then
			local bnpath = song:GetBannerPath()
			if not bnpath then
				bnpath = THEME:GetPathG("Common", "fallback banner")
			end
			self:LoadBackground(bnpath)
		end
		self:scaletofit(0,0,256,80)
		self:xy(SCREEN_CENTER_X,70)
	end
}


-- Song title
t[#t+1] = LoadFont("Common Normal")..{
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X+5+(266/2),50)
		self:zoom(0.6)
		self:maxwidth(((SCREEN_WIDTH/2 -5 -266/2)/0.6) - 10)
		self:diffuse(color(colorConfig:get_data().evaluation.BackgroundText)):diffusealpha(0.8)
		self:halign(0):valign(0)
	end,
	BeginCommand = function(self) 
		self:settext(song:GetDisplayMainTitle()) 
	end
}

-- Artist and subtitles
t[#t+1] = LoadFont("Common Normal")..{
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X+5+(266/2),65)
		self:zoom(0.4)
		self:maxwidth(((SCREEN_WIDTH/2 -5 -266/2)/0.4) - 10)
		self:diffuse(color(colorConfig:get_data().evaluation.BackgroundText)):diffusealpha(0.8)
		self:halign(0):valign(0)
	end,
	BeginCommand = function(self) 
		if song:GetDisplaySubTitle() ~= "" then
			self:settextf("%s\n// %s",song:GetDisplaySubTitle(),song:GetDisplayArtist())
		else
			self:settext("//"..song:GetDisplayArtist())
		end
	end
}


-- Life graph and the stuff that goes with it
local function GraphDisplay( pn )
	local t = Def.ActorFrame {

		Def.GraphDisplay {
			InitCommand = function(self)
				self:Load("GraphDisplay")
			end,
			BeginCommand = function(self)
				local ss = SCREENMAN:GetTopScreen():GetStageStats()
				self:Set(ss,pss)
				self:diffusealpha(0.5)
				self:GetChild("Line"):diffusealpha(0)
				self:y(55)
			end
		},

		LoadFont("Common Large")..{
			Name = "Grade",
			InitCommand = function(self)
				self:xy(-frameWidth/2+35,55):zoom(0.7):maxwidth(70/0.8)
			end,
			BeginCommand=function(self) 
				self:settext(THEME:GetString("Grade",ToEnumShortString(pss:GetHighScore():GetWifeGrade()))) 
			end,
			SetJudgeCommand = function(self)
				self:settext(THEME:GetString("Grade", ToEnumShortString(getWifeGradeTier(rescoredPercentage))))
			end,
			ResetJudgeCommand = function(self)
				self:playcommand("Begin")
			end
		},

		LoadFont("Common Normal")..{
			Font= "Common Normal", 
			InitCommand= function(self)
				self:y(50):zoom(0.6)
				self:halign(0)
			end,
			BeginCommand=function(self) 
				local wifeScore = pss:GetHighScore():GetWifeScore()
				self:x(self:GetParent():GetChild("Grade"):GetX()+(math.min(self:GetParent():GetChild("Grade"):GetWidth()/0.8/2+15,35/0.8+15))*0.6)

				if wifeScore > 0.99 then
					self:settextf("%.4f%%",math.floor((wifeScore)*1000000)/10000)
				else
					self:settextf("%.2f%%",math.floor((wifeScore)*10000)/100)
				end
			end,
			SetJudgeCommand = function(self, params)
				if enabledCustomWindows then
					self:settextf(
						"%05.2f%% (%s)",
						rescoredPercentage,
						customWindow.name
					)
				elseif params.Name == "PrevJudge" and judge >= 1 then
					self:settextf(
						"%05.2f%% (%s)",
						rescoredPercentage,
						"Wife J" .. judge
					)
				elseif params.Name == "NextJudge" and judge <= 9 then
					if judge == 9 then
						self:settextf(
							"%05.2f%% (%s)",
							rescoredPercentage,
							"Wife Justice"
						)
					else
						self:settextf(
							"%05.2f%% (%s)",
							rescoredPercentage,
							"Wife J" .. judge
						)
					end
				end
			end,
			ResetJudgeCommand = function(self)
				self:playcommand("Begin")
			end
		},

		LoadFont("Common Normal")..{
			InitCommand= function(self)
				self:y(63):zoom(0.4)
				self:halign(0)
			end,
			BeginCommand=function(self) 
				-- Fix when maxwife is available to lua
				local grade,diff = getNearbyGrade(pn,pss:GetWifeScore()*getMaxNotes(pn)*2,pss:GetGrade())
				diff = diff >= 0 and string.format("+%0.2f", diff) or string.format("%0.2f", diff)
				self:settextf("%s %s",THEME:GetString("Grade",ToEnumShortString(grade)),diff)
				self:x(self:GetParent():GetChild("Grade"):GetX()+(math.min(self:GetParent():GetChild("Grade"):GetWidth()/0.8/2+15,35/0.8+15))*0.6)
			end,
			OffsetPlotModificationMessageCommand = function(self, params)
				if params.Name == "ResetJudge" then
					self:playcommand("Begin")
					self:diffusealpha(1)
				elseif params.Name == "NextJudge" or params.Name == "PrevJudge" then
					self:diffusealpha(0)
				end
			end
		},



		LoadFont("Common Normal")..{
			InitCommand = function(self)
				self:xy(frameWidth/2-5,60-25+5):zoom(0.4):halign(1):valign(0):diffusealpha(0.7)
			end,
			BeginCommand=function(self)
				local text = ""
				text = string.format("Life: %.0f%%",pss:GetCurrentLife()*100)
				if pss:GetCurrentLife() == 0 then
					text = string.format("%s\n%.2fs Survived",text,pss:GetAliveSeconds())
				end
				self:settext(text)
			end
		}
	}
	return t
end

local function ComboGraph( pn ) 
  	local t = Def.ActorFrame { 
	    Def.ComboGraph {
	    	InitCommand = function(self)
				self:Load("ComboGraph"..ToEnumShortString(pn))
			end,
		    BeginCommand=function(self) 
		        local ss = SCREENMAN:GetTopScreen():GetStageStats() 
		        self:Set(ss,ss:GetPlayerStageStats(pn)) 
			end 
		}
  	}
  	return t
end

local function scoreBoard(pn)
	local hsTable = getScoreTable(pn, rate)
	local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)
	local profile = PROFILEMAN:GetProfile(pn)
	local index
	if hsTable == nil then
		index = 1
	else
		index = getHighScoreIndex(hsTable, pss:GetHighScore())
	end
	local recScore = getBestScore(pn, index, rate, true)
	local curScore = pss:GetHighScore()

	local clearType = getClearType(pn,steps,curScore)

	local t = Def.ActorFrame{
		InitCommand = function(self)
			if GAMESTATE:GetNumPlayersEnabled() > 1 then
				if pn == PLAYER_1 then
					self:x(frameX)
				else 
					self:x(SCREEN_WIDTH - frameX)
				end
			else
				self:x(frameX)
			end
			self:y(frameY+100)
			self:zoom(0.5)
			self:diffusealpha(0)
		end,
		OnCommand = function(self)
			self:RunCommandsOnChildren(function(self) self:queuecommand("Set") end)
			self:bouncy(0.3)
			self:y(frameY)
			self:zoom(1)
			self:diffusealpha(1)
		end,
		OffCommand = function(self)
			self:bouncy(0.3)
			self:y(500)
		end
	}

	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:zoomto(frameWidth,frameHeight):valign(0)
			self:diffuse(getMainColor("frame")):diffusealpha(0.8)
		end
	}

	t[#t+1] = StandardDecorationFromTable("GraphDisplay"..ToEnumShortString(pn), GraphDisplay(pn))
	t[#t+1] = StandardDecorationFromTable("ComboGraph"..ToEnumShortString(pn),ComboGraph(pn))

	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:xy(25+10-(frameWidth/2),5)
			self:zoomto(56,56)
			self:diffuse(color("#000000"))
			self:diffusealpha(0.8)
		end,
		SetCommand = function(self)
			self:diffuse(getBorderColor())
		end
	}

	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:xy(25+10-(frameWidth/2),5)
			self:zoomto(56,56)
			self:diffusealpha(0.8)
			self:diffuseramp()
			self:effectcolor2(color("1,1,1,0.6"))
			self:effectcolor1(color("1,1,1,0"))
			self:effecttiming(2,1,0,0)
		end
	}

	t[#t+1] = Def.Sprite {
		InitCommand = function (self) 
			self:xy(25+10-(frameWidth/2),5)
			self:visible(true)
			self:LoadBackground(assetFolders.avatar .. findAvatar(PROFILEMAN:GetProfile(PLAYER_1):GetGUID()))
			self:zoomto(50,50)
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		Name = "DisplayName",
		InitCommand  = function(self)
			self:xy(69-frameWidth/2,9)
			self:zoom(0.6)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))

			local text = profile:GetDisplayName()
			if text == "" then
				text = pn == PLAYER_1 and "Player 1" or "Player 2"
			end
			self:settext(text)
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand  = function(self)
			self:xy(69-frameWidth/2,20)
			self:zoom(0.3)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
		end,
		SetCommand = function(self)
			local text = "Lv.%d (%d/%d)"
			local level = getLevel(getProfileExp(pn))
			local currentExp = getProfileExp(pn) - getLvExp(level)
			local nextExp = getNextLvExp(level)
			if playerLeveled(pn) then
				text = text.." - Level Up!"
				self:diffuse(getMainColor("positive"))
			end

			self:settextf(text,level, currentExp,nextExp)
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand  = function(self)
			self:xy(69-frameWidth/2,28)
			self:zoom(0.3)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
		end,
		SetCommand = function(self)
			if DLMAN:IsLoggedIn() then
				local rank = DLMAN:GetSkillsetRank("Overall")
				local rating = DLMAN:GetSkillsetRating("Overall")
				local localrating = profile:GetPlayerRating()
				local rankDiff = GHETTOGAMESTATE:checkOnlineRank()
				local finalStr = ""
				if rankDiff < 0 then
					finalStr = string.format("Rating: %0.2f (%0.2f #%d Online) %d rank change!", localrating, rating, rank, rankDiff)
					self:settext(finalStr)
				elseif rankDiff > 0 then
					finalStr = string.format("Rating: %0.2f (%0.2f #%d Online) +%d rank change!", localrating, rating, rank, rankDiff)
					self:settext(finalStr)
				else
					finalStr = string.format("Rating: %0.2f (%0.2f #%d Online)", localrating, rating, rank)
					self:settext(finalStr)
				end
				self:AddAttribute(#"Rating:", {Length = 7, Zoom =0.3 ,Diffuse = getMSDColor(localrating)})
				self:AddAttribute(#"Rating: 00.00 ", {Length = -1, Zoom =0.3 ,Diffuse = getMSDColor(rating)})			
				if rankDiff ~= 0 then
					local tempStr = string.format("Rating: %0.2f (%0.2f #%d Online)", localrating, rating, rank)
					self:AddAttribute(#tempStr+1, {Length = -1, Diffuse = color(colorConfig:get_data().evaluation.ScoreCardText)})
				end
			else
				self:settextf("Rating: %0.2f",profile:GetPlayerRating())
			end
		end
	}


	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand  = function(self)
			self:xy(self:GetParent():GetChild("DisplayName"):GetX()+self:GetParent():GetChild("DisplayName"):GetWidth()*0.6+5,10)
			self:zoom(0.3)
			self:halign(0)
			self:diffuse(getMainColor("positive"))
		end,
		SetCommand = function(self)
			self:settextf("+%d", getExpDiff(pn))
			self:smooth(4)
			self:diffusealpha(0)
			self:addy(-5)
		end
	}

	--Diff & MSD
	t[#t+1] = LoadFont("Common Normal")..{

		InitCommand = function(self)
			self:xy(frameWidth/2-5,5):zoom(0.5):halign(1):valign(0)
			self:glowshift():effectcolor1(color("1,1,1,0.05")):effectcolor2(color("1,1,1,0")):effectperiod(2)
		end,
		SetCommand=function(self) 
			local diff = steps:GetDifficulty()
			local stype = ToEnumShortString(steps:GetStepsType()):gsub("%_"," ")

			local meter = steps:GetMSD(getCurRateValue(),1)
			meter = meter == 0 and steps:GetMeter() or meter

			local difftext
			if diff == 'Difficulty_Edit' and IsUsingWideScreen() then
				difftext = steps:GetDescription()
				difftext = difftext == '' and getDifficulty(diff) or difftext
			else
				difftext = getDifficulty(diff)
			end

			if IsUsingWideScreen() then
				self:settextf("%s %s %5.2f", stype, difftext, meter)
				self:diffuse(getDifficultyColor(GetCustomDifficulty(steps:GetStepsType(),steps:GetDifficulty())))
				self:AddAttribute(#stype + #difftext + 2, {Length = -1, Diffuse = byMSD(meter)})
			else
				self:settextf("%s %5.2f", difftext, meter)
				self:diffuse(getDifficultyColor(GetCustomDifficulty(steps:GetStepsType(),steps:GetDifficulty())))
				self:AddAttribute(#difftext + 1, {Length = -1, Diffuse = byMSD(meter)})
			end
		end
	}

	-- SSR
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self) 
		 	self:xy(frameWidth/2-5,19):zoom(0.4):halign(1):valign(0)
		end,
		SetCommand=function(self) 
			
			local meter = curScore:GetSkillsetSSR("Overall")
			self:settextf("Score Specific Rating   %5.2f", meter)
			self:AddAttribute(#"Score Specific Rating", {Length = -1, Diffuse = byMSD(meter)})
		end
	}

	--ClearType
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(-frameWidth/2+5,107)
			self:zoom(0.35)
			self:halign(0):valign(1)
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardCategoryText))
			self:playcommand("Set")
		end,
		SetCommand = function(self)
			self:settext(THEME:GetString("ScreenEvaluation","CategoryClearType"))
		end,
		SetJudgeCommand = function(self)
			self:settextf("%s (J%d)", THEME:GetString("ScreenEvaluation", "CategoryClearType"), GetTimingDifficulty())
		end,
		ResetJudgeCommand = function(self)
			self:playcommand("Set")
		end
	}

	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:y(110)
			self:zoomto(frameWidth-10,2)
			self:valign(0)
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardDivider)):diffusealpha(0.8)
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameWidth/2-50,107)
			self:zoom(0.5)
			self:halign(1):valign(1)
		end,
		SetCommand = function(self)
			self:settext(getClearTypeText(clearType))
			self:diffuse(getClearTypeColor(clearType))
		end
	}


	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameWidth/2-50,113)
			self:zoom(0.35)
			self:halign(1):valign(0)
		end,
		SetCommand = function(self)
			local clearType = getHighestClearType(pn,steps,hsTable,index)
			self:settext(getClearTypeText(clearType))
			self:diffuse(getClearTypeColor(clearType))
			self:diffusealpha(0.5)
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameWidth/2-40,106)
			self:zoom(0.30)
			self:valign(1)
		end,
		SetCommand = function(self) 
			local recCTLevel = getClearTypeLevel(getHighestClearType(pn,steps,hsTable,index))
			local curCTLevel = getClearTypeLevel(clearType)
			if curCTLevel < recCTLevel then
				self:settext("▲")
				self:diffuse(getMainColor("positive"))
			elseif curCTLevel > recCTLevel then
				self:settext("▼")
				self:diffuse(getMainColor("negative"))
			else
				self:settext("-")
				self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
			end
		end
	}

	-- Score


	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(-frameWidth/2+5,137)
			self:zoom(0.35)
			self:halign(0):valign(1)
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardCategoryText))
			self:playcommand("Set")
		end,
		SetCommand = function(self)
			self:settextf("%s - %s",THEME:GetString("ScreenEvaluation","CategoryScore"),getScoreTypeText(1))
		end,
		SetJudgeCommand = function(self)
			self:settextf("%s - %s J%d", THEME:GetString("ScreenEvaluation", "CategoryScore"), getScoreTypeText(1), GetTimingDifficulty())
		end,
		ResetJudgeCommand = function(self)
			self:playcommand("Set")
		end
	}

	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:y(140)
			self:zoomto(frameWidth-10,2)
			self:valign(0)
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardDivider)):diffusealpha(0.8)
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameWidth/2-50,137)
			self:zoom(0.5)
			self:halign(1):valign(1)
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
		end,
		SetCommand = function(self)
			local notes = steps:GetRadarValues(pn):GetValue("RadarCategory_Notes")
			local curScoreValue = getScore(curScore, steps, false)
			local curScorePercent = getScore(curScore, steps, true)
			local maxScoreValue = notes * 2
			local percentText = string.format("%05.2f%%",math.floor(curScorePercent*10000)/100)
			self:settextf("%s (%d/%d)",percentText,curScoreValue,maxScoreValue)
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameWidth/2-50,143)
			self:zoom(0.35)
			self:halign(1):valign(0)
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText)):diffusealpha(0.3)
		end,
		SetCommand = function(self)
			local recScoreValue = getScore(recScore, steps, true)

			local maxScore = getMaxScore(pn)
			local percentText = string.format("%05.2f%%",math.floor(recScoreValue*10000)/100)
			self:settextf("%s (%0.0f/%d)",percentText,recScoreValue*maxScore,maxScore)
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameWidth/2-40,136)
			self:zoom(0.30)
			self:valign(1)
		end,
		SetCommand = function(self) 
			local curScoreValue = getScore(curScore, steps, false)
			local recScoreValue = getScore(recScore, steps, false)
			local diff = curScoreValue - recScoreValue

			if diff > 0 then
				self:settext("▲")
				self:diffuse(getMainColor("positive"))
			elseif diff < 0 then
				self:settext("▼")
				self:diffuse(getMainColor("negative"))
			else
				self:settext("-")
				self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
			end
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameWidth/2-20,136)
			self:zoom(0.30)
			self:valign(1)
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
		end,
		SetCommand = function(self) 
			local curScoreValue = getScore(curScore, steps, false)
			local recScoreValue = getScore(recScore, steps, false)
			local diff = curScoreValue - recScoreValue

			local extra = ""
			if diff >= 0 then
				extra = "+"
			end
			self:settextf("%s%0.2f",extra,diff)
		end
	}

	-- Misscount

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(-frameWidth/2+5,167)
			self:zoom(0.35)
			self:halign(0):valign(1)
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardCategoryText))
			self:playcommand("Set")
		end,
		SetCommand = function(self)
			self:settext(THEME:GetString("ScreenEvaluation","CategoryMissCount"))
		end
	}

	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:y(170)
			self:zoomto(frameWidth-10,2)
			self:valign(0)
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardDivider)):diffusealpha(0.8)
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameWidth/2-50,167)
			self:zoom(0.5)
			self:halign(1):valign(1)
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
		end,
		SetCommand = function(self)
			local missCount = getScoreMissCount(curScore)
			self:settext(missCount)
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameWidth/2-50,173)
			self:zoom(0.35)
			self:halign(1):valign(0)
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText)):diffusealpha(0.3)
		end,
		SetCommand = function(self)
			local score = getBestMissCount(pn,index, rate)
			local missCount = getScoreMissCount(score)

			if missCount ~= nil then
				self:settext(missCount)
			else
				self:settext("-")
			end
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameWidth/2-40,166)
			self:zoom(0.30)
			self:valign(1)
		end,
		SetCommand = function(self) 

			local score = getBestMissCount(pn,index, rate)
			local recMissCount = getScoreMissCount(score)
			local curMissCount = getScoreMissCount(curScore)
			local diff = 0

			if score ~= nil then
				diff = curMissCount - recMissCount
				if diff > 0 then
					self:settext("▼")
					self:diffuse(getMainColor("negative"))
				elseif diff < 0 then
					self:settext("▲")
					self:diffuse(getMainColor("positive"))
				else
					self:settext("-")
					self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
				end
			else
				self:settext("-")
				self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
			end
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameWidth/2-20,166)
			self:zoom(0.30)
			self:valign(1)
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
		end,
		SetCommand = function(self) 
			local score = getBestMissCount(pn,index, rate)
			local recMissCount = getScoreMissCount(score)
			local curMissCount = getScoreMissCount(curScore)
			local diff = 0

			local extra = ""
			if score ~= nil then
				diff = curMissCount - recMissCount
				if diff >= 0 then
					extra = "+"
				end
				self:settext(extra..diff)
			else
				self:settext("+"..curMissCount)
			end
		end
	}

	-- Tap judgments

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(-frameWidth/2+5,196)
			self:zoom(0.35)
			self:halign(0):valign(1)
			self:settext(THEME:GetString("ScreenEvaluation","CategoryJudgment"))
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardCategoryText))
		end
	}

	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:y(200)
			self:zoomto(frameWidth-10,2)
			self:valign(0)
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardDivider)):diffusealpha(0.8)
		end
	}

	for k,v in ipairs(judges) do
		t[#t+1] = LoadFont("Common Normal")..{
			InitCommand= function(self)
				self:xy(((-(frameWidth+frameWidth/6)/2)+((frameWidth+frameWidth/6)/7)*k),210)
				self:zoom(0.4)
				self:settext(getJudgeStrings(v))
				self:diffuse(TapNoteScoreToColor(v))
			end
		}

		t[#t+1] = LoadFont("Common Normal")..{
			InitCommand= function(self)
				self:xy(((-(frameWidth+frameWidth/6)/2)+((frameWidth+frameWidth/6)/7)*k),225)
				self:zoom(0.35)
			end,
			SetCommand=function(self) 
				local percent = pss:GetPercentageOfTaps(v)
				if tostring(percent) == tostring(0/0) then
					percent = 0
				end
				self:diffuse(lerp_color(percent,Saturation(TapNoteScoreToColor(v),0.1),Saturation(TapNoteScoreToColor(v),0.4)))
				self:settext(pss:GetTapNoteScores(v))
			end,
			SetJudgeCommand = function(self)
				if enabledCustomWindows then
					self:settext(getRescoredCustomJudge(dvt, customWindow.judgeWindows, k))
				else
					self:settext(getRescoredJudge(dvt, judge, k))
				end
			end,
			ResetJudgeCommand = function(self)
				self:playcommand("Set")
			end
		}

		t[#t+1] = LoadFont("Common Normal")..{
			InitCommand= function(self)
				self:xy(((-(frameWidth+frameWidth/6)/2)+((frameWidth+frameWidth/6)/7)*k),235)
				self:zoom(0.30)
			end,
			SetCommand=function(self) 
				local percent = pss:GetPercentageOfTaps(v)
				if tostring(percent) == tostring(0/0) then
					percent = 0
				end
				self:diffuse(lerp_color(percent,Saturation(TapNoteScoreToColor(v),0.1),Saturation(TapNoteScoreToColor(v),0.4)))
				self:settextf("(%.2f%%)",math.floor(percent*10000)/100)
			end,
			SetJudgeCommand = function(self)
				if enabledCustomWindows then
					self:settextf("(%.2f%%)", getRescoredCustomJudge(dvt, customWindow.judgeWindows, k) / totalTaps * 100)
				else
					self:settextf("(%.2f%%)", getRescoredJudge(dvt, judge, k) / totalTaps * 100)
				end
			end,
			ResetJudgeCommand = function(self)
				self:playcommand("Set")
			end
		}
	end

	for k,v in ipairs(hjudges) do
		t[#t+1] = LoadFont("Common Normal")..{
			InitCommand= function(self)
				self:xy(((-(frameWidth+frameWidth/6)/2)+((frameWidth+frameWidth/6)/7)*k),260)
				self:zoom(0.4)
				self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))

				local text = getJudgeStrings(v)
				if text == "OK" or text == "NG" then
					text = "Hold "..text
				end
				self:settext(text)
			end
		}

		t[#t+1] = LoadFont("Common Normal")..{
			InitCommand= function(self)
				self:xy(((-(frameWidth+frameWidth/6)/2)+((frameWidth+frameWidth/6)/7)*k),275)
				self:zoom(0.35)
		    	self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
			end,
			SetCommand=function(self) 
				local percent = pss:GetHoldNoteScores(v)/(pss:GetRadarPossible():GetValue('RadarCategory_Holds')+pss:GetRadarPossible():GetValue('RadarCategory_Rolls'))
				if tostring(percent) == tostring(0/0) then
					percent = 0
				end
				self:diffuse(lerp_color(percent,Saturation(color(colorConfig:get_data().evaluation.ScoreCardText),0.1),Saturation(color(colorConfig:get_data().evaluation.ScoreCardText),0.4)))
				self:settext(pss:GetHoldNoteScores(v))
			end
		}

		t[#t+1] = LoadFont("Common Normal")..{
			InitCommand= function(self)
				self:xy(((-(frameWidth+frameWidth/6)/2)+((frameWidth+frameWidth/6)/7)*k),285)
				self:zoom(0.30)
		    	self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
			end,
			SetCommand=function(self) 
				local percent = pss:GetHoldNoteScores(v)/(pss:GetRadarPossible():GetValue('RadarCategory_Holds')+pss:GetRadarPossible():GetValue('RadarCategory_Rolls'))
				if tostring(percent) == tostring(0/0) then
					percent = 0
				end
				self:diffuse(lerp_color(percent,Saturation(color(colorConfig:get_data().evaluation.ScoreCardText),0.1),Saturation(color(colorConfig:get_data().evaluation.ScoreCardText),0.4)))
				self:settextf("(%.2f%%)",math.floor(percent*10000)/100)
			end
		}
	end

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand= function(self)
			self:xy(((-(frameWidth+frameWidth/6)/2)+((frameWidth+frameWidth/6)/7)*4),260)
			self:zoom(0.4)
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
			self:settext("Mines Hit")
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand= function(self)
			self:xy(((-(frameWidth+frameWidth/6)/2)+((frameWidth+frameWidth/6)/7)*4),275)
			self:zoom(0.35)
		    self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
		end,
		SetCommand=function(self) 
			local percent = pss:GetTapNoteScores('TapNoteScore_HitMine')/(pss:GetRadarPossible():GetValue('RadarCategory_Mines'))*100
			if tostring(percent) == tostring(0/0) then
				percent = 0
			end
			self:diffuse(lerp_color(percent,Saturation(color(colorConfig:get_data().evaluation.ScoreCardText),0.1),Saturation(color(colorConfig:get_data().evaluation.ScoreCardText),0.4)))
			self:settext(pss:GetTapNoteScores('TapNoteScore_HitMine'))
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand= function(self)
			self:xy(((-(frameWidth+frameWidth/6)/2)+((frameWidth+frameWidth/6)/7)*4),285)
			self:zoom(0.30)
		    self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
		end,
		SetCommand=function(self) 
			local percent = pss:GetTapNoteScores('TapNoteScore_HitMine')/(pss:GetRadarPossible():GetValue('RadarCategory_Mines'))*100
			if tostring(percent) == tostring(0/0) then
				percent = 0
			end
			self:diffuse(lerp_color(percent,Saturation(color(colorConfig:get_data().evaluation.ScoreCardText),0.1),Saturation(color(colorConfig:get_data().evaluation.ScoreCardText),0.4)))
			self:settextf("(%.2f%%)",percent)
		end
	}

	-- stolen from Til Death without any shame
	local tracks = pss:GetTrackVector()
	local devianceTable = pss:GetOffsetVector()
	local cbl = 0
	local cbr = 0

	local tst = ms.JudgeScalers
	local tso = tst[judge]
	if enabledCustomWindows then
		tso = 1
	end
	local ncol = GAMESTATE:GetCurrentSteps(PLAYER_1):GetNumColumns() - 1
	for i = 1, #devianceTable do
		if tracks[i] then
			if math.abs(devianceTable[i]) > tso * 90 then
				if tracks[i] <= math.floor(ncol/2) then
					cbl = cbl + 1
				else
					cbr = cbr + 1
				end
			end
		end
	end
	local statCategory = {
		"Mean",
		"Mean(Abs)",
		"Sd",
		"Left cbs",
		"Right cbs"
	}
	local statInfo = {
		wifeMean(devianceTable),
		wifeAbsMean(devianceTable),
		wifeSd(devianceTable),
		cbl,
		cbr
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand= function(self)
			self:xy(((-(frameWidth+frameWidth/6)/2)+((frameWidth+frameWidth/6)/7)*5),260)
			self:zoom(0.4)
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
			self:settext("Mean")
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand= function(self)
			self:xy(((-(frameWidth+frameWidth/6)/2)+((frameWidth+frameWidth/6)/7)*5),275)
			self:zoom(0.35)
		    self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
		end,
		SetCommand=function(self) 
			self:diffuse(Saturation(color(colorConfig:get_data().evaluation.ScoreCardText),0.1),Saturation(color(colorConfig:get_data().evaluation.ScoreCardText),0.4))
			self:settextf("%.2fms", statInfo[1])
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand= function(self)
			self:xy(((-(frameWidth+frameWidth/6)/2)+((frameWidth+frameWidth/6)/7)*5),285)
			self:zoom(0.25)
		    self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
		end,
		SetCommand=function(self) 
			self:diffuse(Saturation(color(colorConfig:get_data().evaluation.ScoreCardText),0.1),Saturation(color(colorConfig:get_data().evaluation.ScoreCardText),0.4))
			self:settextf("%.2fms (abs)", statInfo[2])
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand= function(self)
			self:xy(((-(frameWidth+frameWidth/6)/2)+((frameWidth+frameWidth/6)/7)*5),292)
			self:zoom(0.25)
		    self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
		end,
		SetCommand=function(self) 
			self:diffuse(Saturation(color(colorConfig:get_data().evaluation.ScoreCardText),0.1),Saturation(color(colorConfig:get_data().evaluation.ScoreCardText),0.4))
			self:settextf("%.2fms (std dev)", statInfo[3])
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand= function(self)
			self:xy(((-(frameWidth+frameWidth/6)/2)+((frameWidth+frameWidth/6)/7)*6),260)
			self:zoom(0.4)
			self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
			self:settext("CBs")
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand= function(self)
			self:xy(((-(frameWidth+frameWidth/6)/2)+((frameWidth+frameWidth/6)/7)*6),275)
			self:zoom(0.3)
		    self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
		end,
		SetCommand=function(self) 
			self:diffuse(Saturation(color(colorConfig:get_data().evaluation.ScoreCardText),0.1),Saturation(color(colorConfig:get_data().evaluation.ScoreCardText),0.4))
			self:settextf("Left: %d", statInfo[4])
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand= function(self)
			self:xy(((-(frameWidth+frameWidth/6)/2)+((frameWidth+frameWidth/6)/7)*6),285)
			self:zoom(0.30)
		    self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardText))
		end,
		SetCommand=function(self) 
			self:diffuse(Saturation(color(colorConfig:get_data().evaluation.ScoreCardText),0.1),Saturation(color(colorConfig:get_data().evaluation.ScoreCardText),0.4))
			self:settextf("Right: %d", statInfo[5])
		end
	}

	return t
end

for _,pn in pairs(GAMESTATE:GetEnabledPlayers()) do
	t[#t+1] = scoreBoard(pn)
end


local player = GAMESTATE:GetEnabledPlayers()[1]
local song = STATSMAN:GetCurStageStats():GetPlayedSongs()[1]
local profile = GetPlayerOrMachineProfile(player)
local hsTable = getScoreTable(player, getCurRate())
local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
local score = pss:GetHighScore()
local scoreIndex = getHighScoreIndex(hsTable, score)
local newScoreboardInitialLocalIndex = scoreIndex
local newScoreboardInitialLocalIndex2 = scoreIndex -- dont ask about this please i dont want to explain myself

local lbActor
local offsetScoreID
local offsetIndex
local offsetisLocal
local currentCountry = "Global"
local scoresPerPage = 5
local maxPages = math.ceil(#hsTable/scoresPerPage)
local curPage = 1
local alreadyPulled = false

local function updateLeaderBoardForCurrentChart()
	alreadyPulled = true
	if steps then
		DLMAN:RequestChartLeaderBoardFromOnline(
			steps:GetChartKey(),
			function(leaderboard)
				lbActor:queuecommand("SetFromLeaderboard", leaderboard)
			end
		)
	else
		lbActor:queuecommand("SetFromLeaderboard", {})
	end
end

local function movePage(n)
	if maxPages <= 1 then
		return
	end

	if n > 0 then 
		curPage = ((curPage+n-1) % maxPages + 1)
	else
		curPage = ((curPage+n+maxPages-1) % maxPages+1)
	end
	MESSAGEMAN:Broadcast("UpdateList")
end

local function scoreboardInput(event)
	if event.type == "InputEventType_FirstPress" then
		if maxPages <= 1 then
			return
		end
		if event.DeviceInput.button == "DeviceButton_mousewheel up" then
			MESSAGEMAN:Broadcast("WheelUpSlow")
		end
		if event.DeviceInput.button == "DeviceButton_mousewheel down" then
			MESSAGEMAN:Broadcast("WheelDownSlow")
		end
		if event.button == "MenuLeft" then
			movePage(-1)
		end

		if event.button == "MenuRight" then
			movePage(1)
		end

	end
end

-- this is the dynamic scoreboard for all the cool scores
-- bad name dont ask (do ask)
local function boardOfScores()
	local frameWidth = SCREEN_CENTER_X-WideScale(get43size(40),40)
	local frameHeight = 150
	local frameX = SCREEN_WIDTH - frameWidth - WideScale(get43size(40),40)/2
	local frameY = 154
	local spacing = 1
	local isLocal = true
	local topScoresOnly = true
	local loggedIn = DLMAN:IsLoggedIn()

	local scoreItemWidth = frameWidth / 1.7
	local scoreItemHeight = frameHeight / 8
	local scoreItemX = frameWidth / 6 + 3 + 2 -- button width + divider width + spacing width
	local scoreItemY = 8
	local scoreItemSpacing = spacing

	local t = Def.ActorFrame {
		Name = "ScoreBoardContainer",
		InitCommand = function(self)
			lbActor = self
		end,
		OnCommand = function(self)
			self:addy(-25)
			self:bouncy(0.2)
			self:addy(25)
			SCREENMAN:GetTopScreen():AddInputCallback(scoreboardInput)
			self:queuecommand("UpdateScores")
		end,
		OffCommand = function(self)
			self:stoptweening()
			self:bouncy(0.2)
			self:x(SCREEN_CENTER_X*3/2-frameWidth/2 + 100)
			self:diffusealpha(0)
		end,
		UpdateScoresMessageCommand = function(self, params)
			if isLocal then
				scoreList = getScoreTable(player, getCurRate())
			else
				scoreList = DLMAN:GetChartLeaderBoard(steps:GetChartKey(), currentCountry)
				if #scoreList == 0 and not alreadyPulled then
					updateLeaderBoardForCurrentChart()
				end
			end
			curPage = 1
			if scoreList ~= nil then
				maxPages = math.ceil(#scoreList / scoresPerPage)
			else
				maxPages = 1
			end
			if isLocal or #scoreList ~= 0 then
				self:queuecommand("Set")
			elseif #scoreList == 0 then
				self:queuecommand("ListEmpty")
			end

		end,
		SetFromLeaderboardCommand = function(self, leaderboard)
			self:queuecommand("UpdateScores")
		end,

		-- the quad for the background of the container
		Def.Quad {
			InitCommand = function(self)
				self:zoomto(frameWidth, frameHeight)
				self:halign(0):valign(0)
				self:diffuse(getMainColor("frame")):diffusealpha(0.8)
			end,
			WheelUpSlowMessageCommand = function(self)
				if self:isOver() then
					movePage(-1)
				end
			end,
			WheelDownSlowMessageCommand = function(self)
				if self:isOver() then
					movePage(1)
				end
			end
		},

		-- the sneaky quad for the divider between this container and the one below
		Def.Quad {
			InitCommand = function(self)
				self:y(frameHeight - 1)
				self:zoomto(frameWidth,1)
				self:halign(0):valign(0)
				self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardDivider)):diffusealpha(0.8)
			end
		},

		-- the quad for other divider just separating stuff
		Def.Quad {
			InitCommand = function(self)
				self:xy(frameWidth/6, 5)
				self:zoomto(2,frameHeight - 10)
				self:halign(0):valign(0)
				self:diffuse(color(colorConfig:get_data().evaluation.ScoreCardDivider)):diffusealpha(0.8)
			end
		},

		-- Page info text
		LoadFont("Common Normal") .. {
			InitCommand = function(self)
				--self:settext("Showing ? - ? of ? scores")
				self:zoom(0.35)
				self:xy((frameWidth - (frameWidth/6))/2 + frameWidth/6, frameHeight - 25)
			end,
			SetCommand = function(self)
				self:settextf("Showing %d - %d of %d scores", (curPage-1) * scoresPerPage + 1, math.min((curPage) * scoresPerPage,#scoreList), #scoreList)
			end,
			UpdateListMessageCommand = function(self)
				self:playcommand("Set")
			end,
			ListEmptyCommand = function(self)
				self:settext("Showing 0 - 0 of 0 scores")
			end
		},

		-- Sort info text
		LoadFont("Common Normal") .. {
			InitCommand = function(self)
				--self:settext("Placeholder.")
				self:zoom(0.35)
				self:xy((frameWidth - (frameWidth/6))/2 + frameWidth/6, frameHeight - 15)
			end,
			SetCommand = function(self)
				if isLocal then
					self:settext("Highest local scores for this rate")
				else
					local allRates = not DLMAN:GetCurrentRateFilter()
					local allScores = not DLMAN:GetTopScoresOnlyFilter()
					if allRates and allScores then
						self:settext("All online scores for all rates")
					elseif allRates and not allScores then
						self:settext("Highest online scores for all rates")
					elseif not allRates and allScores then
						self:settext("All online scores for this rate") -- this is actually no different from the one below
					else
						self:settext("Highest online scores for this rate") -- but i wanted to make the distinction
					end
				end
			end,
			ListEmptyCommand = function(self)
				self:settext("No scores found")
			end
		},

		-- Basic info text
		LoadFont("Common Normal") .. {
			InitCommand = function(self)
				self:settext("Click for Offset Plot")
				self:zoom(0.2)
				self:valign(0)
				self:xy(scoreItemX + scoreItemWidth/2, (scoreItemHeight + scoreItemSpacing + 1) * scoresPerPage + scoreItemY)
				self:diffusealpha(0)
			end,
			UpdateListMessageCommand = function(self)
				local scoresOnThisPage = math.abs((curPage-1) * scoresPerPage + 1 - math.min((curPage) * scoresPerPage,#scoreList))
				if #scoreList == 0 then
					self:diffusealpha(0)
					return
				end
				self:stoptweening()
				self:diffusealpha(0)
				self:y((scoreItemHeight) * (scoresOnThisPage+1) + (scoreItemSpacing*scoresOnThisPage) + scoreItemY - 8)
				self:sleep((scoresOnThisPage+1)*0.03)
				self:diffusealpha(1)
				self:easeOut(0.5)
				self:y((scoreItemHeight) * (scoresOnThisPage+1) + (scoreItemSpacing*scoresOnThisPage) + scoreItemY + 2)
			end,
			UpdateScoresCommand = function(self)
				self:playcommand("UpdateList")
			end,
			ListEmptyCommand = function(self)
				self:playcommand("UpdateList")
			end
		},

		-- Basic info text 2
		LoadFont("Common Normal") .. {
			InitCommand = function(self)
				self:settext("Click for Replay")
				self:zoom(0.2)
				self:valign(0)
				self:diffusealpha(0)
				self:xy(scoreItemX + scoreItemWidth + 10 + (frameWidth - scoreItemWidth - scoreItemX - 20)/2, (scoreItemHeight + scoreItemSpacing + 1) * scoresPerPage + scoreItemY)
			end,
			UpdateListMessageCommand = function(self)
				local scoresOnThisPage = math.abs((curPage-1) * scoresPerPage + 1 - math.min((curPage) * scoresPerPage,#scoreList))
				if #scoreList == 0 then
					self:diffusealpha(0)
					return
				end
				self:stoptweening()
				self:diffusealpha(0)
				self:y((scoreItemHeight) * (scoresOnThisPage+1) + (scoreItemSpacing*scoresOnThisPage) + scoreItemY - 8)
				self:sleep((scoresOnThisPage+1)*0.03)
				self:diffusealpha(1)
				self:easeOut(0.5)
				self:y((scoreItemHeight) * (scoresOnThisPage+1) + (scoreItemSpacing*scoresOnThisPage) + scoreItemY + 2)
			end,
			UpdateScoresCommand = function(self)
				self:playcommand("UpdateList")
			end,
			ListEmptyCommand = function(self)
				self:playcommand("UpdateList")
			end
		},

		-- Local scores button
		quadButton(6) .. {
			InitCommand = function(self)
				self:xy(3, 8)
				self:zoomto(frameWidth/6 - 6, frameHeight / 8)
				self:halign(0):valign(0)
				self:diffusealpha(0.05)
			end,
			SetCommand = function(self)
				if not loggedIn then
					self:diffusealpha(0.05)
					return
				end
				if not isLocal then
					self:diffusealpha(0.1)
				else
					self:diffusealpha(0.4)
				end
			end,
			TopPressedCommand = function(self)
				if not isLocal and loggedIn then
					isLocal = true
					self:GetParent():queuecommand("UpdateScores")
				end
			end,
			ListEmptyCommand = function(self)
				self:queuecommand("Set")
			end
		},
		LoadFont("Common Bold") .. {
			InitCommand = function(self)
				self:settext("Local")
				self:zoom(0.45)
				self:xy(3, 8)
				self:addx((frameWidth/6 - 6)/2)
				self:addy((frameHeight / 8)/2)
				self:diffusealpha(0.05)
			end,
			SetCommand = function(self)
				self:linear(0.1)
				if not loggedIn then
					self:diffusealpha(0.05)
					return
				else
					self:diffusealpha(1)
				end
			end,
			ListEmptyCommand = function(self)
				self:queuecommand("Set")
			end
		},

		-- Online scores button
		quadButton(6) .. {
			InitCommand = function(self)
				self:xy(3, 8 + (frameHeight / 8) + spacing)
				self:zoomto(frameWidth/6 - 6, frameHeight / 8)
				self:halign(0):valign(0)
				self:diffusealpha(0.05)
			end,
			SetCommand = function(self)
				self:linear(0.1)
				if not loggedIn then
					self:diffusealpha(0.05)
					return
				end
				if isLocal then
					self:diffusealpha(0.1)
				else
					self:diffusealpha(0.4)
				end
			end,
			TopPressedCommand = function(self)
				if isLocal and loggedIn then
					isLocal = false
					self:GetParent():queuecommand("UpdateScores")
				end
			end,
			ListEmptyCommand = function(self)
				self:queuecommand("Set")
			end
		},
		LoadFont("Common Bold") .. {
			InitCommand = function(self)
				self:settext("Online")
				self:zoom(0.45)
				self:xy(3, 8 + (frameHeight / 8) + spacing)
				self:addx((frameWidth/6 - 6)/2)
				self:addy((frameHeight / 8)/2)
				self:diffusealpha(0.05)
			end,
			SetCommand = function(self)
				self:linear(0.1)
				if not loggedIn then
					self:diffusealpha(0.05)
					return
				else
					self:diffusealpha(1)
				end
			end,
			ListEmptyCommand = function(self)
				self:queuecommand("Set")
			end
		},

		-- Current rate button
		quadButton(6) .. {
			InitCommand = function(self)
				self:xy(3, frameHeight - 8 - (frameHeight/8/2) * 2 - spacing)
				self:zoomto(frameWidth/6 - 6, frameHeight / 8 / 2)
				self:halign(0):valign(0)
				self:diffusealpha(0.05)
			end,
			SetCommand = function(self)
				self:linear(0.1)
				if isLocal then
					self:diffusealpha(0.05)
				else
					if DLMAN:GetCurrentRateFilter() then
						self:diffusealpha(0.4)
					else
						self:diffusealpha(0.1)
					end
				end
			end,
			TopPressedCommand = function(self)
				if not isLocal and loggedIn then
					if not DLMAN:GetCurrentRateFilter() then
						DLMAN:ToggleRateFilter()
						self:GetParent():queuecommand("UpdateScores")
					end
				end
			end,
			ListEmptyCommand = function(self)
				self:queuecommand("Set")
			end
		},
		LoadFont("Common Bold") .. {
			InitCommand = function(self)
				self:settext("Current Rate")
				self:zoom(0.25)
				self:xy(3, frameHeight - 8 - (frameHeight/8/2) * 2 - spacing)
				self:addx((frameWidth/6 - 6)/2)
				self:addy((frameHeight / 8 / 2)/2)
				self:diffusealpha(0.05)
			end,
			SetCommand = function(self)
				self:linear(0.1)
				if isLocal then
					self:diffusealpha(0.05)
				else
					self:diffusealpha(1)
				end
			end,
			ListEmptyCommand = function(self)
				self:queuecommand("Set")
			end
		},

		-- All rates button
		quadButton(6) .. {
			InitCommand = function(self)
				self:xy(3, frameHeight - 8 - (frameHeight/8/2))
				self:zoomto(frameWidth/6 - 6, frameHeight / 8 / 2)
				self:halign(0):valign(0)
				self:diffusealpha(0.05)
			end,
			SetCommand = function(self)
				self:linear(0.1)
				if isLocal then
					self:diffusealpha(0.05)
				else
					if DLMAN:GetCurrentRateFilter() then
						self:diffusealpha(0.1)
					else
						self:diffusealpha(0.4)
					end
				end
			end,
			TopPressedCommand = function(self)
				if not isLocal and loggedIn then
					if DLMAN:GetCurrentRateFilter() then
						DLMAN:ToggleRateFilter()
						self:GetParent():queuecommand("UpdateScores")
					end
				end
			end,
			ListEmptyCommand = function(self)
				self:queuecommand("Set")
			end
		},
		LoadFont("Common Bold") .. {
			InitCommand = function(self)
				self:settext("All Rates")
				self:zoom(0.25)
				self:xy(3, frameHeight - 8 - (frameHeight/8/2))
				self:addx((frameWidth/6 - 6)/2)
				self:addy((frameHeight / 8 / 2)/2)
				self:diffusealpha(0.05)
			end,
			SetCommand = function(self)
				self:linear(0.1)
				if isLocal then
					self:diffusealpha(0.05)
				else
					self:diffusealpha(1)
				end
			end,
			ListEmptyCommand = function(self)
				self:queuecommand("Set")
			end
		},

		-- Top Scores button
		quadButton(6) .. {
			InitCommand = function(self)
				self:xy(3, frameHeight - 8 - (frameHeight/8/2)*3 - spacing*3)
				self:zoomto(frameWidth/6 - 6, frameHeight / 8 / 2)
				self:halign(0):valign(0)
				self:diffusealpha(0.05)
			end,
			SetCommand = function(self)
				self:linear(0.1)
				if isLocal then
					self:diffusealpha(0.05)
				else
					if DLMAN:GetTopScoresOnlyFilter() then
						self:diffusealpha(0.4)
					else
						self:diffusealpha(0.1)
					end
				end
			end,
			TopPressedCommand = function(self)
				if not isLocal and loggedIn then
					if not DLMAN:GetTopScoresOnlyFilter() then
						DLMAN:ToggleTopScoresOnlyFilter()
						self:GetParent():queuecommand("UpdateScores")
					end
				end
			end,
			ListEmptyCommand = function(self)
				self:queuecommand("Set")
			end
		},
		LoadFont("Common Bold") .. {
			InitCommand = function(self)
				self:settext("Top Scores")
				self:zoom(0.25)
				self:xy(3, frameHeight - 8 - (frameHeight/8/2)*3 - spacing*3)
				self:addx((frameWidth/6 - 6)/2)
				self:addy((frameHeight / 8 / 2)/2)
				self:diffusealpha(0.05)
			end,
			SetCommand = function(self)
				self:linear(0.1)
				if isLocal then
					self:diffusealpha(0.05)
				else
					self:diffusealpha(1)
				end
			end,
			ListEmptyCommand = function(self)
				self:queuecommand("Set")
			end
		},

		-- All Scores button
		quadButton(6) .. {
			InitCommand = function(self)
				self:xy(3, frameHeight - 8 - (frameHeight/8/2)*4 - spacing*4)
				self:zoomto(frameWidth/6 - 6, frameHeight / 8 / 2)
				self:halign(0):valign(0)
				self:diffusealpha(0.05)
			end,
			SetCommand = function(self)
				self:linear(0.1)
				if isLocal then
					self:diffusealpha(0.05)
				else
					if DLMAN:GetTopScoresOnlyFilter() then
						self:diffusealpha(0.1)
					else
						self:diffusealpha(0.4)
					end
				end
			end,
			TopPressedCommand = function(self)
				if not isLocal and loggedIn then
					if DLMAN:GetTopScoresOnlyFilter() then
						DLMAN:ToggleTopScoresOnlyFilter()
						self:GetParent():queuecommand("UpdateScores")
					end
				end
			end,
			ListEmptyCommand = function(self)
				self:queuecommand("Set")
			end
		},
		LoadFont("Common Bold") .. {
			InitCommand = function(self)
				self:settext("All Scores")
				self:zoom(0.25)
				self:xy(3, frameHeight - 8 - (frameHeight/8/2)*4 - spacing*4)
				self:addx((frameWidth/6 - 6)/2)
				self:addy((frameHeight / 8 / 2)/2)
				self:diffusealpha(0.05)
			end,
			SetCommand = function(self)
				self:linear(0.1)
				if isLocal then
					self:diffusealpha(0.05)
				else
					self:diffusealpha(1)
				end
			end,
			ListEmptyCommand = function(self)
				self:queuecommand("Set")
			end
		}
	}

	-- individual items for the score buttons
	local function scoreItem(i)
		local scoreIndex = (curPage - 1) * scoresPerPage + i

		local d = Def.ActorFrame {
			InitCommand = function(self)
				self:xy(scoreItemX, scoreItemY + (i-1) * (scoreItemHeight + scoreItemSpacing))
				self:diffusealpha(0)
			end,
			ShowCommand = function(self)
				self:y(scoreItemY + (i-1)*(scoreItemHeight + scoreItemSpacing)-10)
				self:diffusealpha(0)
				self:finishtweening()
				self:sleep(math.max(0.01, (i-1)*0.03))
				self:easeOut(1)
				self:y(scoreItemY + (i-1)*(scoreItemHeight + scoreItemSpacing))
				self:diffusealpha(1)
			end,
			HideCommand = function(self)
				self:stoptweening()
				self:easeOut(0.5)
				self:diffusealpha(0)
				self:y(SCREEN_HEIGHT*10)
			end,
			UpdateListMessageCommand = function(self)
				self:playcommand("UpdateScores")
			end,
			UpdateScoresMessageCommand = function(self)
				scoreIndex = (curPage - 1) * scoresPerPage + i
				if scoreList[scoreIndex] ~= nil then
					self:playcommand("Show")
				else
					self:playcommand("Hide")
				end
				self:RunCommandsOnChildren(function(self) self:playcommand("Set") end)
			end
		}

		-- BG+Button for score item
		d[#d+1] = quadButton(6) .. {
			InitCommand = function(self)
				self:halign(0):valign(0)
				self:diffusealpha(0.1)
				self:zoomto(scoreItemWidth, scoreItemHeight)
			end,
			SetCommand = function(self)
				if scoreList[scoreIndex] ~= nil and ((scoreIndex == offsetIndex and offsetisLocal and isLocal) or (scoreList[scoreIndex]:GetScoreid() == offsetScoreID and not offsetisLocal and not isLocal) or (isLocal and offsetIndex == nil and scoreIndex == newScoreboardInitialLocalIndex)) then
					self:diffusealpha(0.3)
				else
					self:diffusealpha(0.1)
				end
			end,
			TopPressedCommand = function(self)
				if scoreList[scoreIndex] == nil or not scoreList[scoreIndex]:HasReplayData() then
					return
				end
				newScoreboardInitialLocalIndex = 0
				offsetIndex = scoreIndex
				offsetScoreID = scoreList[scoreIndex]:GetScoreid()
				offsetisLocal = isLocal
				MESSAGEMAN:Broadcast("ShowScoreOffset")
				self:finishtweening()
				self:diffusealpha(0.3)
				self:GetParent():GetParent():playcommand("Set")
			end
		}

		-- symbol indicating that this is the score you just set
		d[#d+1] = LoadActor(THEME:GetPathG("", "_triangle")) .. {
			Name = "CurrentScoreIndicator",
			InitCommand = function(self)
				self:zoom(0.10)
				self:diffusealpha(0.8)
				self:rotationz(90)
				self:diffuse(color("#aaaaff"))
				self:diffusealpha(0)
				self:xy(3, scoreItemHeight/4)
			end,
			SetCommand = function(self)
				if scoreList[scoreIndex] == nil then
					return
				end
				if (isLocal == true and scoreIndex == newScoreboardInitialLocalIndex2) then
					self:linear(0.1)
					self:diffusealpha(1)
				else
					self:diffusealpha(0)
				end
			end
		}

		-- grade
		d[#d+1] = LoadFont("Common Normal") .. {
			InitCommand = function(self)
				self:xy(22,scoreItemHeight/4)
				self:zoom(0.3)
			end,
			SetCommand = function(self)
				if scoreList[scoreIndex] == nil then
					return
				end
				local grade = scoreList[scoreIndex]:GetWifeGrade()
				self:settext(THEME:GetString("Grade",ToEnumShortString(grade)))
				self:diffuse(getGradeColor(grade))
			end
		}
		-- cleartype
		d[#d+1] = LoadFont("Common Normal") .. {
			InitCommand = function(self)
				self:xy(22,scoreItemHeight/4 * 3)
				self:zoom(0.3)
				self:maxwidth(135)
			end,
			SetCommand = function(self)
				if scoreList[scoreIndex] == nil then
					return
				end
				local clearType = getClearType(PLAYER_1, steps, scoreList[scoreIndex])
				self:settext(getClearTypeShortText(clearType))
				self:diffuse(getClearTypeColor(clearType))
			end
		}
		-- score percent and judgments
		d[#d+1] = LoadFont("Common Normal") .. {
			InitCommand = function(self)
				self:xy(45,scoreItemHeight/4)
				self:halign(0)
				self:zoom(0.3)
			end,
			SetCommand = function(self)
				if scoreList[scoreIndex] == nil then
					return
				end
				local score = scoreList[scoreIndex]:GetWifeScore()
				local w1 = scoreList[scoreIndex]:GetTapNoteScore("TapNoteScore_W1")
				local w2 = scoreList[scoreIndex]:GetTapNoteScore("TapNoteScore_W2")
				local w3 = scoreList[scoreIndex]:GetTapNoteScore("TapNoteScore_W3")
				local w4 = scoreList[scoreIndex]:GetTapNoteScore("TapNoteScore_W4")
				local w5 = scoreList[scoreIndex]:GetTapNoteScore("TapNoteScore_W5")
				local miss = scoreList[scoreIndex]:GetTapNoteScore("TapNoteScore_Miss")
				if score >= 0.99 then
					self:settextf("%0.4f%% | %d - %d - %d - %d - %d - %d",math.floor(score*1000000)/10000, w1, w2, w3, w4, w5, miss)
					self:AddAttribute(11, {Length = #tostring(w1), Diffuse = byJudgment("TapNoteScore_W1")})
					self:AddAttribute(14 + #tostring(w1), {Length = #tostring(w2), Diffuse = byJudgment("TapNoteScore_W2")})
					self:AddAttribute(17 + #tostring(w1) + #tostring(w2), {Length = #tostring(w3), Diffuse = byJudgment("TapNoteScore_W3")})
					self:AddAttribute(20 + #tostring(w1) + #tostring(w2) + #tostring(w3), {Length = #tostring(w4), Diffuse = byJudgment("TapNoteScore_W4")})
					self:AddAttribute(23 + #tostring(w1) + #tostring(w2) + #tostring(w3) + #tostring(w4), {Length = #tostring(w5), Diffuse = byJudgment("TapNoteScore_W5")})
					self:AddAttribute(26 + #tostring(w1) + #tostring(w2) + #tostring(w3) + #tostring(w4) + #tostring(w5), {Length = #tostring(miss), Diffuse = byJudgment("TapNoteScore_Miss")})
				else
					self:settextf("%0.2f%% | %d - %d - %d - %d - %d - %d",math.floor(score*10000)/100, w1, w2, w3, w4, w5, miss)
					self:AddAttribute(9, {Length = #tostring(w1), Diffuse = byJudgment("TapNoteScore_W1")})
					self:AddAttribute(12 + #tostring(w1), {Length = #tostring(w2), Diffuse = byJudgment("TapNoteScore_W2")})
					self:AddAttribute(15 + #tostring(w1) + #tostring(w2), {Length = #tostring(w3), Diffuse = byJudgment("TapNoteScore_W3")})
					self:AddAttribute(18 + #tostring(w1) + #tostring(w2) + #tostring(w3), {Length = #tostring(w4), Diffuse = byJudgment("TapNoteScore_W4")})
					self:AddAttribute(21 + #tostring(w1) + #tostring(w2) + #tostring(w3) + #tostring(w4), {Length = #tostring(w5), Diffuse = byJudgment("TapNoteScore_W5")})
					self:AddAttribute(24 + #tostring(w1) + #tostring(w2) + #tostring(w3) + #tostring(w4) + #tostring(w5), {Length = #tostring(miss), Diffuse = byJudgment("TapNoteScore_Miss")})
				end
			end
		}
		-- date and ssr
		d[#d+1] = LoadFont("Common Normal") .. {
			InitCommand = function(self)
				self:xy(45,scoreItemHeight/4 * 3)
				self:halign(0)
				self:zoom(0.3)
			end,
			SetCommand = function(self)
				if scoreList[scoreIndex] == nil then
					return
				end
				local date = scoreList[scoreIndex]:GetDate()
				local ssr = scoreList[scoreIndex]:GetSkillsetSSR("Overall")
				self:settextf("%s | %0.2f", date, ssr)
				self:AddAttribute(#date + #" | ", {Length = -1, Diffuse = byMSD(ssr)})
			end
		}

		-- BG quad for score item player info
		d[#d+1] = quadButton(6) .. {
			InitCommand = function(self)
				self:addx(scoreItemWidth + 10)
				self:halign(0):valign(0)
				self:diffusealpha(0.1)
				self:zoomto(frameWidth - scoreItemWidth - scoreItemX - 20, scoreItemHeight)
			end,
			TopPressedCommand = function(self)
				if scoreList[scoreIndex] == nil or not scoreList[scoreIndex]:HasReplayData() then
					return
				end
				GHETTOGAMESTATE:setReplay(scoreList[scoreIndex], not isLocal)
				SCREENMAN:GetTopScreen():Cancel()
			end
		}

		-- Tiny green box that means the score has replay data
		d[#d+1] = LoadActor(THEME:GetPathG("", "_triangle")) .. {
			InitCommand = function(self)
				self:addx(scoreItemWidth + 10 + (frameWidth - scoreItemWidth - scoreItemX - 20) - 5)
				self:addy(scoreItemHeight * 3/4)
				self:diffuse(color("#00ff00"))
				self:zoom(0.12)
				self:visible(false)
				self:rotationz(90)
			end,
			SetCommand = function(self)
				if scoreList[scoreIndex] == nil then
					return
				end
				self:visible(scoreList[scoreIndex]:HasReplayData())
			end
		}

		-- player name
		d[#d+1] = LoadFont("Common Normal") .. {
			InitCommand = function(self)
				self:xy(scoreItemWidth + 10 + (frameWidth - scoreItemWidth - scoreItemX - 20)/2,scoreItemHeight/4)
				self:maxwidth((frameWidth - scoreItemWidth - scoreItemX - 20)*3)
				self:zoom(0.3)
			end,
			SetCommand = function(self)
				if scoreList[scoreIndex] == nil then
					return
				end
				local name = profile:GetDisplayName()
				if not isLocal then
					name = scoreList[scoreIndex]:GetDisplayName()
				end
				self:settext(name)
			end
		}

		-- rate
		d[#d+1] = LoadFont("Common Normal") .. {
			InitCommand = function(self)
				self:xy(scoreItemWidth + 10 + (frameWidth - scoreItemWidth - scoreItemX - 20)/2,scoreItemHeight/4 * 3)
				self:maxwidth((frameWidth - scoreItemWidth - scoreItemX - 20)*3)
				self:zoom(0.3)
			end,
			SetCommand = function(self)
				if scoreList[scoreIndex] == nil then
					return
				end
				local ratestring = "("..string.format("%.2f", scoreList[scoreIndex]:GetMusicRate()):gsub("%.?0$", "") .. "x)"
				self:settext(ratestring)
			end
		}


		return d

	end

	for i=1, scoresPerPage do
		t[#t+1] = scoreItem(i)
	end


	return t

end

local newScoreboard = themeConfig:get_data().global.EvalScoreboard
local inMulti = NSMAN:IsETTP() and IsSMOnlineLoggedIn() or false
if newScoreboard and not inMulti then
	t[#t+1] = boardOfScores() .. {
		InitCommand = function(self)
			self:xy(SCREEN_CENTER_X*3/2-frameWidth/2, SCREEN_HEIGHT - 180 - 150)
		end
	}
elseif not inMulti then
	t[#t+1] = LoadActor("scoreboard")
else
	t[#t+1] = LoadActor("MPscoreboard")
end


local function offsetInput(event)
	if event.type == "InputEventType_FirstPress" then
		local outputName = ""
		if event.button == "EffectUp" then
			outputName = "NextJudge"
		elseif event.button == "EffectDown" then
			outputName = "PrevJudge"
		elseif event.button == "MenuDown" then
			outputName = "ToggleHands"
		elseif event.button == "MenuUp" then
			outputName = "ResetJudge"
		end

		if outputName ~= "" then
			MESSAGEMAN:Broadcast("OffsetPlotModification", {Name = outputName})
		end
	end
end

t[#t+1] = LoadActor(THEME:GetPathG("","OffsetGraph"))..{
	InitCommand = function(self, params)
		self:xy(SCREEN_CENTER_X*3/2-frameWidth/2, SCREEN_HEIGHT - 180)
		self:zoom(0.5)

		local pn = GAMESTATE:GetEnabledPlayers()[1]
		local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)
		local steps = GAMESTATE:GetCurrentSteps(pn)

		self:RunCommandsOnChildren(function(self)
			local params = 	{width = frameWidth, 
							height = 150, 
							song = song, 
							steps = steps, 
							nrv = nrv,
							dvt = dvt,
							ctt = ctt,
							ntt = ntt,
							columns = steps:GetNumColumns()}
			self:playcommand("Update", params) end
		)
	end,
	ShowScoreOffsetMessageCommand = function(self, params)
		if scoreList[offsetIndex]:HasReplayData() then
			if not offsetisLocal then
				DLMAN:RequestOnlineScoreReplayData(
					scoreList[offsetIndex],
					function()
						MESSAGEMAN:Broadcast("DelayedShowOffset")
					end
				)
			else
				MESSAGEMAN:Broadcast("DelayedShowOffset")
			end
		else
			self:RunCommandsOnChildren(function(self) self:playcommand("Update", {width = frameWidth, height = 150}) end)
		end
	end,
	DelayedShowOffsetMessageCommand = function(self)
		self:RunCommandsOnChildren(function(self)
			local params = 	{width = frameWidth, 
							height = 150, 
							song = song, 
							steps = steps, 
							nrv = scoreList[offsetIndex]:GetNoteRowVector(),
							dvt = scoreList[offsetIndex]:GetOffsetVector(),
							ctt = scoreList[offsetIndex]:GetTrackVector(),
							ntt = scoreList[offsetIndex]:GetTapNoteTypeVector(),
							columns = steps:GetNumColumns()}
			self:playcommand("Update", params) end
		)
	end,
	OnCommand = function(self)
		self:stoptweening()
		self:zoom(1)
		self:addy(25)
		self:bouncy(0.2)
		self:addy(-25)
		self:xy(SCREEN_CENTER_X*3/2-frameWidth/2, SCREEN_HEIGHT - 180)
		self:diffusealpha(1)
		SCREENMAN:GetTopScreen():AddInputCallback(offsetInput)
	end,
	OffCommand = function(self)
		self:stoptweening()
		self:bouncy(0.2)
		self:x(SCREEN_CENTER_X*3/2-frameWidth/2 + 100)
		self:diffusealpha(0)
	end

}

-- Missing noterows text
t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand = function(self)
		self:xy(SCREEN_WIDTH * 3/4, SCREEN_HEIGHT * 3/4)
		self:settext("Missing Noterows from Online Replay\n(゜´Д｀゜)")
		self:zoom(0.4)
		self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText)):diffusealpha(0.6)
		self:visible(false)
	end,
	DelayedShowOffsetMessageCommand = function(self)
		if scoreList[offsetIndex]:GetNoteRowVector() == nil then
			self:visible(true)
		else
			self:visible(false)
		end
	end
}
return t