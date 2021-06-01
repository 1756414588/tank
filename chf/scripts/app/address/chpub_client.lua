--
-- Author: gf
-- Date: 2015-11-06 18:40:11
--

LOGIN_PLATFORM_PARAM = "caohua"

--草花客户端
GameConfig.accountURL = "http://caohua.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://caohua.tank.hundredcent.com/serverlist_tank.json"
GameConfig.downRootURL = "http://cdn.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://cdn.tank.hundredcent.com/version/tank_apk_hf.json"

function getPayCallBackUrl()
    return "http://caohua.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=caohua"
end