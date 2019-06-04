--[[

what do you need to know to make slices of an image?

1) its height.
	Solution: Load one copy as visible,false and use commands.

2) ratios.
	Fuck.

]]

local ret = Def.ActorFrame{
	OnCommand=function(self)
		self:zoom(2)
	end;
};

local numSlices = 12;
local picHeight = 0;
local pixelChunk = 0;
local curPixel = 0;
local baseEffectOffset = 0.65;
local baseEffectAdd = 0.08;		-- this is the value you want to tweak.

for i=1,numSlices do
	ret[#ret+1] = LoadActor("_cloud fade")..{
		InitCommand=function(self)
            self:blend("BlendMode_Add");
			self:diffusealpha(0.05);
--[[ 			self:cropright(1);
			self:faderight(1); --]]
		end;
		
		BeginCommand=function(self)
			if picHeight == 0 then
				picHeight = self:GetHeight();
				pixelChunk = picHeight / numSlices;
			end;
			
			local top = curPixel;
			local bot = top + pixelChunk;
			
			-- 1.0 - 0.8333 = 0.1667
			-- which will be for the next one.
			-- ratio = botRatio below.
			--local quint = 1.0 - ratio;
			
			local topRatio = scale( ( picHeight - top ) / picHeight, 0.0, 1.0, 1.0, 0.0 );
			local botRatio = ( picHeight - bot ) / picHeight;
			
			self:croptop( topRatio );
			self:cropbottom( botRatio );
			
			curPixel = pixelChunk * i;
		end;
		
		OnCommand=function(self)
			self:sleep(0.25):linear(0.25):cropright(0):faderight(0):sleep(0.25):linear(0.2):addy(-20):playcommand("Yes")
		end;
		
		YesCommand=function(self)
			self:bob();
			self:effectperiod(4);
			self:effectmagnitude(6,0,0);
			self:effectoffset( baseEffectOffset + (baseEffectAdd * i-1) );
			self:playcommand("Pulse");
		end;
		PulseCommand=function(self)
			local offsetIntro = 0.1;
			local offsetOn = 0.05;
			local offsetOff = 0.1;
			
			self:sleep( 0.5 + (offsetIntro * i) );
			self:decelerate( 0.35 + (offsetOn * i) );
			self:diffuse(color("0,0.75,1,0.1"));
			self:decelerate( 1 + (offsetOff * i) );
			self:diffuse(color("1,1,1,0.05"));
			
			local perfectSleep = ( 13.85 + ( 0.25 * (picHeight - i) ) );
			
			--[[
			
			i  | 
			---------------------------
			1  | 25.6
			2  | 25.35
			3  | 25.1
			4  | 24.85
			5  | 24.6
			
			
			]]
			
			--self:sleep( scale(perfectSleep, 25.6, 13.85, 6.4, 3.4625) );
			self:sleep(perfectSleep);
			self:queuecommand("Pulse");
		end;
		
		CycleZCommand=function(self)
			self:linear(1):zoomz(2):decelerate(0.5):zoomz(-2):accelerate(0.5):zoomz(1):queuecommand("CycleZ")
		end;
	};
end;

return ret;