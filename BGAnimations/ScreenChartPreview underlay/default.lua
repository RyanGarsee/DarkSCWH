local t = Def.ActorFrame{}

t[#t+1] = Def.Quad {
	InitCommand = function(self)
		self:diffuse(getMainColor("darkshit")):diffusealpha(0.9)
		self:FullScreen()
	end	
}

return t