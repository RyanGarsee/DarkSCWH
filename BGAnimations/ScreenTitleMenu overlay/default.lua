if IsSMOnlineLoggedIn() then
	CloseConnection()
end

local queue = {}
local queueIdx = 1
local vis =
    audioVisualizer:new {
    x = SCREEN_RIGHT * 1 / 3 - 270,
    y = SCREEN_BOTTOM * 3 / 5.95,
    color = getMainColor("darkshit"),
    onInit = function(frame)
        local soundActor = frame.sound.actor
        local songs = SONGMAN:GetAllSongs()
        for i = 1, 100 do
            local idx = math.random(1, #songs)
            queue[#queue + 1] = songs[idx]
        end
        soundActor:stop()
        soundActor:load(queue[queueIdx]:GetMusicPath())
        soundActor:play()
    end
}

t = Def.ActorFrame{}

local frameX = THEME:GetMetric("ScreenTitleMenu","ScrollerX")-10
local frameY = THEME:GetMetric("ScreenTitleMenu","ScrollerY")-20

t[#t+1] = Def.Quad{
	InitCommand=function(self)
		self:draworder(-900):xy(frameX,frameY+11):zoomto(SCREEN_WIDTH,158):halign(0):diffuse(getMainColor('background')):diffusealpha(0.7)
	end	
}

t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand=function(self)
		self:xy(SCREEN_WIDTH-5,frameY-70):zoom(0.5):valign(1):halign(1)
	end,
	OnCommand=function(self)
		self:settext(string.format("%s v%s %s",getThemeName(),getThemeVersion(),getThemeDate()))
	end
}

t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand=function(self)
		self:xy(5,5):zoom(0.4):valign(0):halign(0)
	end,
	OnCommand=function(self)
		self:settext(string.format("%s %s",ProductFamily(),ProductVersion()))
	end
}

t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand=function(self)
		self:xy(5,16):zoom(0.3):valign(0):halign(0)
	end,
	OnCommand=function(self)
		self:settext(string.format("%s %s",VersionDate(),VersionTime()))
	end
}

t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand=function(self)
		self:xy(5,25):zoom(0.3):valign(0):halign(0)
	end,
	OnCommand=function(self)
		self:settext(string.format("%s Songs in %s Groups",SONGMAN:GetNumSongs(),SONGMAN:GetNumSongGroups()))
	end
}

t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand=function(self)
		self:xy(5,SCREEN_HEIGHT-15):zoom(0.4):valign(1):halign(0)
	end,
	OnCommand=function(self)
		if IsNetSMOnline() then
			self:settext("Online")
			self:diffuse(getMainColor('enabled'))
		else
			self:settext("Offline")
			self:diffuse(getMainColor('disabled'))
		end
	end
}

t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand=function(self)
		self:xy(5,SCREEN_HEIGHT-5):zoom(0.35):valign(1):halign(0):diffuse(color("#666666"))
	end,
	OnCommand=function(self)
		if IsNetSMOnline() then
			self:settext(GetServerName())
			self:diffuse(color("#FFFFFF"))
		else
			self:settext("Not Available")
		end
	end
}

t[#t+1]=vis

return t