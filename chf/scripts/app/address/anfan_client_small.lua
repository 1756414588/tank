--
-- Author: gf
-- Date: 2016-05-13 10:01:46
--

LOGIN_PLATFORM_PARAM = "anfanSmall"

--安峰客户端
GameConfig.accountURL = "http://anfanSmall.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://anfanSmall.tank.hundredcent.com/serverlist_tank.json"
GameConfig.downRootURL = "http://cdn.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://cdn.tank.hundredcent.com/version/tank_apk_hf.json"


function getPayCallBackUrl()
    return "http://anfanSmall.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=anfanSmall"
end