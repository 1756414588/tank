--
-- Author: gf
-- Date: 2016-02-23 14:55:14
-- 拇指 TT

LOGIN_PLATFORM_PARAM = "tt"

--TT玩客户端

GameConfig.accountURL = "http://tt.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://tt.tank.hundredcent.com/serverlist_tank.json"


GameConfig.downRootURL = "http://cdn.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://cdn.tank.hundredcent.com/version/tank_apk_hf.json"


function getPayCallBackUrl()
    return "http://tt.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=tt"
end