local t = Def.ActorFrame {
	Def.ActorFrame {
		FOV=90;
		LoadActor( "CJ108" )..{
			InitCommand=function(self)
				self:x(SCREEN_CENTER_X):y(SCREEN_CENTER_Y):scale_or_crop_background():diffusealpha(0.325)
			end;
		};
		LoadActor( "stream" )..{
			InitCommand=function(self)
				self:z(240):x(SCREEN_CENTER_X):y(SCREEN_CENTER_Y):zoomto(SCREEN_WIDTH*2,SCREEN_HEIGHT*2)
			end;
			OnCommand=function(self)
				self:blend("BlendMode_Add"):diffusealpha(0.03):rotationx(-15):customtexturerect(0,0,SCREEN_WIDTH/256*2,SCREEN_HEIGHT/256*2):texcoordvelocity(0.25,0)
			end;
		};
	};
	LoadActor( "stripes" )..{
		InitCommand=function(self)
			self:diffusetopedge(color("0,0.5,0.5")):x(SCREEN_CENTER_X):y(SCREEN_CENTER_Y):zoomx(2):texcoordvelocity(-0.05,0):diffusealpha(0.3):skewx(0.12)
		end;
	};
	LoadActor( "stripes" )..{
		InitCommand=function(self)
			self:diffusetopedge(color("0.5,0.5,0.5")):x(SCREEN_CENTER_X):y(SCREEN_CENTER_Y):zoomx(2):zoomy(-1):texcoordvelocity(0.025,0):diffusealpha(0.2):skewx(-0.2)
		end;
	};
}
t[#t+1] = LoadActor( "shade" )..{
	InitCommand=function(self)
		self:Center():zoomto(SCREEN_WIDTH+2,SCREEN_HEIGHT):blend("BlendMode_WeightedMultiply")
	end;
}
if GetUserPrefB("ShowBackgroundLights") then
t[#t+1] = Def.ActorFrame {
	InitCommand=function(self)
		self:x(SCREEN_CENTER_X):y(SCREEN_CENTER_Y)
	end;
	LoadActor("lights") .. {
		InitCommand=function(self)
			self:rotationz(90):blend("BlendMode_Add"):zoomtowidth(SCREEN_HEIGHT+75):zoomtoheight(30):diffusealpha(0.45):x(-SCREEN_CENTER_X-8):y(0):diffuseramp():effectclock('beat')
		end;
	};
	LoadActor("lights") .. {
		InitCommand=function(self)
			self:rotationz(-90):blend("BlendMode_Add"):zoomtowidth(SCREEN_HEIGHT+75):zoomtoheight(30):diffusealpha(0.45):x(SCREEN_CENTER_X+8):y(0):diffuseramp():effectclock('beat')
		end;
	};
};
end

return t