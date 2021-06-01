--游戏打包版本号
GAME_APK_VERSION = "2.4.0"


function __G__TRACKBACK__(errorMessage)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
    print(debug.traceback("", 2))
    print("----------------------------------------")
end

CACHE_DIR = CCFileUtils:sharedFileUtils():getCachePath() .. "cache/"
package.path = CACHE_DIR .. "scripts/;" .. package.path
-- print("[main] path:", package.path)

CCFileUtils:sharedFileUtils():addSearchPath(CACHE_DIR .. "res/")
CCFileUtils:sharedFileUtils():addSearchPath("res/")
CCFileUtils:sharedFileUtils():addSearchPath(CACHE_DIR .. "scripts/")
CCFileUtils:sharedFileUtils():addSearchPath("scripts/")
CCFileUtils:sharedFileUtils():setPopupNotify(false)

require("app.MyApp").new():run()
