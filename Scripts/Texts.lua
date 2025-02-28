local shortDiffName = {
	Difficulty_Beginner	= 'BG',
	Difficulty_Easy		= 'EZ',
	Difficulty_Medium	= 'NM',
	Difficulty_Hard		= 'HD',
	Difficulty_Challenge= 'IN',
	Difficulty_Edit 	= 'ED',
	Difficulty_Couple	= 'CP',
	Difficulty_Routine	= 'RT',
	Beginner			= 'BG',
	Easy				= 'EZ',
	Normal				= 'NM',
	Hard				= 'HD',
	Insane 				= 'IN',
	Edit 				= 'ED',
	Couple				= 'CP',
	Routine				= 'RT'
}

local DiffName = {
	Difficulty_Beginner	= 'Beginner',
	Difficulty_Easy		= 'Easy',
	Difficulty_Medium	= 'Normal',
	Difficulty_Hard		= 'Hard',
	Difficulty_Challenge= 'Insane',
	Difficulty_Edit 	= 'Edit',
	Difficulty_Couple	= 'Couple',
	Difficulty_Routine	= 'Routine',
}

local gradeString = {
	Grade_Tier01 = 'AAAA',
	Grade_Tier02 = 'AAA',
	Grade_Tier03 = 'AA',
	Grade_Tier04 = 'A',
	Grade_Tier05 = 'B',
	Grade_Tier06 = 'C',
	Grade_Tier07 = 'D',
	Grade_Failed = 'F'
}

local shortJudgeString = { -- Text strings for each Judgment types
	TapNoteScore_W1 = 'MA',
	TapNoteScore_W2	= 'PR',
	TapNoteScore_W3	 = 'GR',
	TapNoteScore_W4	= 'GD',
	TapNoteScore_W5	= 'BD',
	TapNoteScore_Miss = 'MS',			
	HoldNoteScore_Held = 'OK',	
	HoldNoteScore_LetGo = 'NG',
	HoldNoteScore_MissedHold = 'HM',
}

local judgeString = { -- Text strings for each Judgment types
	TapNoteScore_W1 = 'Marvelous',
	TapNoteScore_W2	= 'Perfect',
	TapNoteScore_W3	 = 'Great',
	TapNoteScore_W4	= 'Good',
	TapNoteScore_W5	= 'Bad',
	TapNoteScore_Miss = 'Miss',			
	HoldNoteScore_Held = 'OK',	
	HoldNoteScore_LetGo = 'NG',	
	HoldNoteScore_MissedHold = 'Hold Miss',
}

local scoreTypeText = {
	[1] = "Wife"
}

function getShortDifficulty(diff)
	local text = shortDiffName[diff]
	if text ~= nil then
		return text
	else
		return "ED"
	end
end

function getDifficulty(diff)
	local text = DiffName[diff]
	if text ~= nil then
		return text
	else
		return "Edit"
	end
end

function getGradeStrings(diff)
	if diff ~= nil then
		return gradeString[diff] or diff
	end
end

function getJudgeStrings(judge)
	if judge ~= nil then
		return judgeString[judge] or judge
	end
end


function getShortJudgeStrings(judge)
	if judge ~= nil then
		return shortJudgeString[judge] or judge
	end
end

function getScoreTypeText(scoreType)
	if scoreType == 0 then
		return scoreTypeText[themeConfig:get_data().global.DefaultScoreType]
	else
		return scoreTypeText[scoreType]
	end
end