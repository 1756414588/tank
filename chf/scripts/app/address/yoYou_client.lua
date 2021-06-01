--
-- Author: gf
-- Date: 2016-02-23 14:55:14
-- 新快游（混服） 安峰

LOGIN_PLATFORM_PARAM = "yoYou"

--乐七玩客户端

GameConfig.accountURL = "http://yoYou.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://yoYou.tank.hundredcent.com/serverlist_tank.json"

GameConfig.downRootURL = "http://cdn.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://cdn.tank.hundredcent.com/version/tank_apk_hf.json"
--李超
-- GameConfig.accountURL = "http://192.168.2.80:8080/tank_account/account/account.do"
-- GameConfig.areaURL = "http://192.168.2.80:8080/tank_account/serverlist.json"


function getPayCallBackUrl()
    return "http://yoYou.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=yoYou"
end