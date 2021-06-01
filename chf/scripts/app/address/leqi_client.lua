--
-- Author: gf
-- Date: 2016-02-23 14:55:14
-- 乐七

LOGIN_PLATFORM_PARAM = "leqi"

--乐七玩客户端

GameConfig.accountURL = "http://leqi.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://leqi.tank.hundredcent.com/serverlist_tank.json"

GameConfig.downRootURL = "http://cdn.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://cdn.tank.hundredcent.com/version/tank_apk_hf.json"


function getPayCallBackUrl()
    return "http://leqi.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=leqi"
end