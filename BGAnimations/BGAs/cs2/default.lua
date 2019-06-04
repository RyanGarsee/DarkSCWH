local t = Def.ActorFrame {};

t[#t+1] = LoadActor("sky") .. {
	InitCommand=function(self)
		self:FullScreen():diffuse(getMainColor("darkshit")) --blend,"BlendMode_WeightedMultiply");
	end;
};


t[#t+1] = LoadActor("movie") .. {
    InitCommand=function(self)
    	self:FullScreen():blend("BlendMode_Add"):diffuse(getMainColor("darkshit")):diffusealpha(0.65)
    end;
};

t[#t+1] = Def.ActorFrame {
 FOV=90;
 InitCommand=function(self)
 	self:spin():effectmagnitude(0,80,0):x(SCREEN_LEFT-100):y(SCREEN_CENTER_Y):z(128)
 end;
 	-- 4/4
	LoadActor("textring") .. {
		InitCommand=function(self)
			self:diffuse(Color.Orange)
		end;
		OnCommand=function(self)
			self:zoom(0.3):z(400):rotationy(90):spin():effectmagnitude(0,0,-40)
		end;
	};
	-- 3/4
	LoadActor("textring") .. {
		InitCommand=function(self)
			self:diffuse(Color.Orange)
		end;
		OnCommand=function(self)
			self:zoom(0.3):x(400):rotationy(-180):spin():effectmagnitude(0,0,-40)
		end;
	};	
	-- 2/4
	LoadActor("textring") .. {
		InitCommand=function(self)
			self:diffuse(Color.Orange)
		end;
		OnCommand=function(self)
			self:zoom(0.3):x(-400):rotationy(180):spin():effectmagnitude(0,0,-40)
		end;
	};	
	-- 1/4
	LoadActor("textring") .. {
		InitCommand=function(self)
			self:diffuse(Color.Orange)
		end;
		OnCommand=function(self)
			self:zoom(0.3):z(-400):rotationy(-90):spin():effectmagnitude(0,0,-40)
		end;
	};
	-- 4/4
	LoadActor("halfring") .. {
		InitCommand=function(self)
			self:diffuse(Color.Blue)
		end;
		OnCommand=function(self)
			self:zoom(0.75):diffusealpha(0.5):z(400):rotationy(90):spin():effectmagnitude(0,0,-40)
		end;
	};
	-- 3/4
	LoadActor("halfring") .. {
		InitCommand=function(self)
			self:diffuse(Color.Blue)
		end;
		OnCommand=function(self)
			self:zoom(0.75):diffusealpha(0.5):x(400):rotationy(-180):spin():effectmagnitude(0,0,-40)
		end;
	};	
	-- 2/4
	LoadActor("halfring") .. {
		InitCommand=function(self)
			self:diffuse(Color.Blue)
		end;
		OnCommand=function(self)
			self:zoom(0.75):diffusealpha(0.5):x(-400):rotationy(180):spin():effectmagnitude(0,0,-40)
		end;
	};	
	-- 1/4
	LoadActor("halfring") .. {
		InitCommand=function(self)
			self:diffuse(Color.Blue)
		end;
		OnCommand=function(self)
			self:zoom(0.75):diffusealpha(0.5):z(-400):rotationy(-90):spin():effectmagnitude(0,0,-40)
		end;
	};	
	-- 3/4
	LoadActor("ring") .. {
		InitCommand=function(self)
			self:diffuse(Color.Blue)
		end;
		OnCommand=function(self)
			self:zoom(0.5):z(400):rotationy(90):spin():effectmagnitude(0,0,80)
		end;
	};
	-- 2/4
	LoadActor("ring") .. {
		InitCommand=function(self)
			self:diffuse(Color.Blue)
		end;
		OnCommand=function(self)
			self:zoom(0.5):x(-400):rotationy(180):spin():effectmagnitude(0,0,80)
		end;
	};	
	-- 2/4
	LoadActor("ring") .. {
		InitCommand=function(self)
			self:diffuse(Color.Blue)
		end;
		OnCommand=function(self)
			self:zoom(0.5):z(-400):rotationy(-90):spin():effectmagnitude(0,0,80)
		end;
	};	
	-- 1/4
	LoadActor("ring") .. {
		InitCommand=function(self)
			self:diffuse(Color.Blue)
		end;
		OnCommand=function(self)
			self:zoom(0.5):x(400):rotationy(-180):spin():effectmagnitude(0,0,80)
		end;
	};	
};

t[#t+1] = Def.ActorFrame {
 InitCommand=function(self)
 	self:Center():visible(false):diffuse(getMainColor("darkshit"))
 end;
	LoadActor("stars") .. {
		InitCommand=function(self)
			self:zoomto(SCREEN_WIDTH,SCREEN_HEIGHT):blend("BlendMode_Add"):diffusealpha(0.15):customtexturerect(0,0,SCREEN_WIDTH/1024,SCREEN_HEIGHT/1024):texcoordvelocity(0.0,0.05)
		end;
	}; 	
 	LoadActor("KIRA2") .. {
		InitCommand=function(self)
			self:zoomto(SCREEN_WIDTH,SCREEN_HEIGHT):blend("BlendMode_Add"):customtexturerect(0,0,SCREEN_WIDTH/640,SCREEN_HEIGHT/480):texcoordvelocity(0.0,0.25)
		end;
	}; 	
	LoadActor("KIRA1") .. {
		InitCommand=function(self)
			self:zoomto(SCREEN_WIDTH,SCREEN_HEIGHT):blend("BlendMode_Add"):customtexturerect(0,0,SCREEN_WIDTH/640,SCREEN_HEIGHT/480):texcoordvelocity(0.0,0.125)
		end;
	};
};
-- Rave Lights
t[#t+1] = Def.ActorFrame {
 Condition=SCREENMAN:GetTopScreen() ~= "ScreenTitleMenu" or "ScreenLogo";
	Def.Quad {
--~ 		InitCommand=cmd(horizalign,left;x,SCREEN_LEFT;y,SCREEN_CENTER_Y-((480/6)*0.25);zoomto,100,SCREEN_HEIGHT-((480/6)*0.5)-((480/6)*1));
		InitCommand=function(self)
			self:horizalign(left):x(SCREEN_LEFT):y(SCREEN_CENTER_Y):diffuse(getMainColor("darkshit"))
		end;
		OnCommand=function(self)
			self:zoomto(128,SCREEN_HEIGHT):faderight(1):diffuse(getMainColor("darkshit")):diffusealpha(0.5)
		end;
	};
	Def.Quad {
--~ 		InitCommand=cmd(horizalign,right;x,SCREEN_RIGHT;y,SCREEN_CENTER_Y-((480/6)*0.25);zoomto,100,SCREEN_HEIGHT-((480/6)*0.5)-((480/6)*1));
		InitCommand=function(self)
			self:horizalign(right):x(SCREEN_RIGHT):y(SCREEN_CENTER_Y)
		end;
		OnCommand=function(self)
			self:zoomto(128,SCREEN_HEIGHT):fadeleft(1):diffuse(getMainColor("darkshit")):diffusealpha(0.5)
		end;
	};
};

return t