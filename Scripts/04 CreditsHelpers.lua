
local line_height = 30 -- so that actor logos can use it.

local stepmania_credits = {
	{
		name = "Project Lead",
		"Prim"
	},
	{
		name = "SCWH devs",
		"Prim",
		"poco0317"
	},
	{
		name = "StepMania Team",
		"Chris Danford",
		"Glenn Maynard",
		"Steve Checkoway"
	},
	{
		name = "StepMania Etterna Team",
		"MinaciousGrace",
		"poco0317",
		"theropfather",
		"Fission",
		"ixsetf",
		"Frustration",
		"xwidghet",
		"Nick12",
		"Noderum",
		"Jousway",
		"SpaceGorilla"
	},
	{
		name = "Shoutouts",
		"The Lua team",
		"--from the main theme--",
		"People in the SM IRC",
		"The Rhythm Gamers Discord",
		"Jousway (for Stepmania-Zpawn)"
	},
	{
		name = "Now smash some keys!",
	}
}

local function position_logo(self)
	local name = self:GetParent():GetChild("name")
	local name_width = name:GetZoomedWidth()
	local logo_width = self:GetZoomedWidth()
	self:x(0 - (name_width / 2) - 4 - (logo_width / 2))
end

StepManiaCredits = {
	AddSection = function(section, pos, insert_before)
		if not section.name then
			lua.ReportScriptError("A section being added to the credits must have a name field.")
			return
		end
		if #section < 1 then
			lua.ReportScriptError("Adding a blank section to the credits doesn't make sense.")
			return
		end
		if type(pos) == "string" then
			for i, section in ipairs(stepmania_credits) do
				if section.name == pos then
					pos = i -- insert_after is default behavior
				end
			end
		end
		if pos and type(pos) ~= "number" then
			lua.ReportScriptError("Credits section '" .. tostring(pos) .. " not found, cannot use position to add new section.")
			return
		end
		pos = pos or #stepmania_credits
		if insert_before then
			pos = pos - 1
		end
		-- table.insert does funny things if you pass an index <= 0
		if pos < 1 then
			lua.ReportScriptError("Cannot add credits section at position " .. tostring(pos) .. ".")
			return
		end
		table.insert(stepmania_credits, pos, section)
	end,
	AddLineToScroller = function(scroller, text, command)
		if type(scroller) ~= "table" then
			lua.ReportScriptError("scroller passed to AddLineToScroller must be an actor table.")
			return
		end
		local actor_to_insert
		if type(text) == "string" or not text then
			actor_to_insert =
				Def.ActorFrame {
				Def.BitmapText {
					Font = "Common Normal",
					Text = text or "",
					OnCommand = command or lineOn
				}
			}
		elseif type(text) == "table" then
			actor_to_insert =
				Def.ActorFrame {
				Def.BitmapText {
					Name = "name",
					Font = "Common Normal",
					Text = text.name or "",
					InitCommand = command or lineOn
				}
			}
			if text.logo then
				if type(text.logo) == "string" then
					actor_to_insert[#actor_to_insert + 1] =
						Def.Sprite {
						Name = "logo",
						InitCommand = function(self)
							-- Use LoadBanner to disable the odd dimension warning.
							self:LoadBanner(THEME:GetPathG("CreditsLogo", text.logo))
							-- Scale to slightly less than the line height for padding.
							local yscale = (line_height - 2) / self:GetHeight()
							self:zoom(yscale)
							-- Position logo to the left of the name.
							position_logo(self)
						end
					}
				else -- assume logo is an actor
					-- Insert positioning InitCommand.
					text.logo.InitCommand = position_logo
					actor_to_insert[#actor_to_insert + 1] = text.logo
				end
			end
		end
		table.insert(scroller, actor_to_insert)
	end,
	Get = function()
		-- Copy the base credits and add the copyright message at the end.
		local ret = DeepCopy(stepmania_credits)
		ret[#ret + 1] = StepManiaCredits.RandomCopyrightMessage()
		return ret
	end,
	RandomCopyrightMessage = function()
		return {
			name = "Copyright",
			"StepMania Etterna is released under the terms of-- ",
			"haha, who are we kidding, this doesn't have a license.",
			"If you paid for this, you're a dumbass.",
			"All content is the sole property of their respectful owners."
		}
	end,
	SetLineHeight = function(height)
		if type(height) ~= "number" then
			lua.ReportScriptError("height passed to StepManiaCredits.SetLineHeight must be a number.")
			return
		end
		line_height = height
	end
}
