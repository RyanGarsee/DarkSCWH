-- theme identification file

themeInfo = {
	Name = "DarkSCWH",
	Version = "2.2.1", -- a.b.c, a for complete overhauls, b for major releases, c for minor additions/bugfix.
	Date = "20190527",
}

function getThemeName()
	return themeInfo["Name"]
end

function getThemeVersion()
	return themeInfo["Version"]
end

function getThemeDate()
	return themeInfo["Date"]
end
