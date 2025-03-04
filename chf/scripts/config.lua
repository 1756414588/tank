
-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = 0

-- display FPS stats on screen
DEBUG_FPS = false

-- dump memory info every 10 seconds
DEBUG_MEM = false

-- load deprecated API
LOAD_DEPRECATED_API = false

-- load shortcodes API
LOAD_SHORTCODES_API = true

-- screen orientation
CONFIG_SCREEN_ORIENTATION = "portrait"

-- design resolution
CONFIG_SCREEN_WIDTH  = 640
CONFIG_SCREEN_HEIGHT = 1136

local winSize = CCDirector:sharedDirector():getWinSize()
local winRate = winSize.height / winSize.width
local textureRate = 960 / 640

if winRate < textureRate then
	CONFIG_SCREEN_AUTOSCALE = "FIXED_HEIGHT"
else
	CONFIG_SCREEN_AUTOSCALE = "FIXED_WIDTH"
end

-- auto scale mode
-- CONFIG_SCREEN_AUTOSCALE = "FIXED_WIDTH"
