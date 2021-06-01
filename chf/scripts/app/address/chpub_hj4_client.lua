--
-- Author: gf
-- Date: 2016-05-07 14:11:01
--

LOGIN_PLATFORM_PARAM = "chHj4"

--草花客户端
GameConfig.accountURL = "http://hj4yxfc.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://hj4yxfc.tank.hundredcent.com/serverlist_tank.json"
GameConfig.downRootURL = "http://hj4yxfc.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://hj4yxfc.tank.hundredcent.com/version/tank_apk_ch.json"

function getPayCallBackUrl()
    return "http://hj4yxfc.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=chHj4"
end