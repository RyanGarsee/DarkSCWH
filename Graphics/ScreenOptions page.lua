--[[ for some old eval thing I need to fix
local graphy = SCREEN_CENTER_Y+185;
	LoadActor("ScreenEvaluationStage overlay/life graph", PLAYER_1) .. {
		InitCommand = function(self)
			self:x(SCREEN_LEFT+100):y(graphy)
		end;
	};
	LoadActor("ScreenEvaluationStage overlay/life graph", PLAYER_2) .. {
		InitCommand = function(self)
			self:x(SCREEN_RIGHT-100):y(graphy)
		end;
	};
]]

local t = Def.ActorFrame {
-- mid
	Def.Quad {
		InitCommand=function(self)
			self:zoomto(SCREEN_WIDTH,SCREEN_HEIGHT-260):y(SCREEN_CENTER_Y):x(SCREEN_CENTER_X):diffuse(color("#222222dd")):diffusetopedge(color("#000000dd"))
		end;
	};
-- top
	Def.Quad {
		InitCommand=function(self)
			self:zoomto(SCREEN_WIDTH,100):x(SCREEN_CENTER_X):y(SCREEN_CENTER_Y-160):diffuse(color("#000000dd")):diffusetopedge(color("#000000aa"))
		end;
	};
	Def.Quad {
		InitCommand=function(self)
			self:zoomto(SCREEN_WIDTH,50):x(SCREEN_CENTER_X):y(SCREEN_CENTER_Y-160):vertalign(bottom):diffuse(color("#ffffff08")):diffusetopedge(color("#ffffff33"))
		end;
	};
-- bottom
	Def.Quad {
		InitCommand=function(self)
			self:zoomto(SCREEN_WIDTH,100):x(SCREEN_CENTER_X):y(SCREEN_CENTER_Y+160):diffuse(color("#000000dd")):diffusetopedge(color("#222222dd"))
		end;
	};
	Def.Quad {
		InitCommand=function(self)
			self:zoomto(SCREEN_WIDTH,50):x(SCREEN_CENTER_X):y(SCREEN_CENTER_Y+160):vertalign(top):diffuse(color("#00000066")):diffusetopedge(color("#00000022"))
		end;
	};
};
return t;