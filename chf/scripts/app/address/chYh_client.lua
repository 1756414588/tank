--
-- Author: gf
-- Date: 2016-03-11 11:04:43
-- 草花硬核


LOGIN_PLATFORM_PARAM = "chYh"

--草花客户端
GameConfig.accountURL = "http://caohua1.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://caohua1.tank.hundredcent.com/serverlist_tank.json"
GameConfig.downRootURL = "http://cdn.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://cdn.tank.hundredcent.com/version/tank_apk_hf.json"

function getPayCallBackUrl()
    return "http://caohua1.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=chYh"
end