local bFirstUpdate = true
local t = Def.ActorFrame {
	LoadActor("gradient_b")..{
		InitCommand=function(self)
			self:zoomtowidth(SCREEN_WIDTH+1):Center():diffuse(getMainColor("darkshit"))
		end;
	};
	LoadActor("gradient_a")..{
		InitCommand=function(self)
			self:zoomtowidth(SCREEN_WIDTH+1):Center():diffuse(getMainColor("darkshit")):playcommand("Update")
		end;
		UpdateCommand=function(self)
			if GetUserPrefB("TimeChangingBackground") then
				local time = scale(Hour(),0,24,0,180)
				-- sinr instead of sind apparently. what a pain.
				time = math.sin(degtorad(time))
				if not bFirstUpdate then
					self:linear(300)
				else
					bFirstUpdate = false
				end
				self:diffusealpha(clamp(time,0.5,1))
				self:queuecommand("Update")
			end
		end;
	};
}
for i=1,3 do
t[#t+1] = LoadActor("clouds_a")..{
	InitCommand=function(self)
		self:FullScreen()
		self:blend("BlendMode_Add")
		self:diffuse({0.5,0.5,0.5})
		self:diffusealpha(0.04)
		self:customtexturerect(0,0,SCREEN_WIDTH/self:GetWidth(),SCREEN_HEIGHT/self:GetHeight())
		if i == 1 then
			self:texcoordvelocity(0.05,0.2)
		elseif i == 2 then
			self:texcoordvelocity(-0.05,0.15)
		else
			self:diffusealpha(0.03)
			self:texcoordvelocity(0,-0.125)
		end
	end;
}
end

t[#t+1] = Def.ActorFrame {
	InitCommand=function(self)
		self:Center()
	end;
	LoadActor("cloud 2") .. {
		InitCommand=function(self)
			self:blend("BlendMode_Add"):diffusealpha(0.025)
		end;
	};
	LoadActor("cloud 1") .. {
		InitCommand=function(self)
			self:blend("BlendMode_Add"):diffusealpha(0.04)
		end;
	};
}

t[#t+1] = Def.ActorFrame {
	LoadActor( "spinna" )..{
		InitCommand=function(self)
			self:Center():spin():effectmagnitude(0,0,-10):zoom(.80):diffusealpha(0.05):blend("BlendMode_Add")
		end;
	};
}

t[#t+1] = Def.ActorFrame {
	LoadActor( "spinna" )..{
		InitCommand=function(self)
			self:Center():spin():effectmagnitude(0,0,20):zoom(.88):diffuse(color("#00000088"))
		end;
	};
}

return t