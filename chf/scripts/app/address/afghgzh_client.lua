--
-- Author: Your Name
-- Date: 2017-03-07 10:17:08
--


LOGIN_PLATFORM_PARAM = "afghgzh"

--安峰客户端
GameConfig.accountURL = "http://anfan.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://anfan.tank.hundredcent.com/serverlist_tank.json"
GameConfig.downRootURL = "http://cdn.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://cdn.tank.hundredcent.com/version/tank_apk_hf.json"


function getPayCallBackUrl()
    return "http://anfan.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=afghgzh"
end