--
-- Author: gf
-- Date: 2016-05-25 18:45:26
-- 安峰聚合


LOGIN_PLATFORM_PARAM = "anfanJh"

--拇指聚合
GameConfig.accountURL = "http://anfanJh.tank.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://anfanJh.tank.hundredcent.com/serverlist_tank.json"
GameConfig.downRootURL = "http://anfanJh.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://anfanJh.tank.hundredcent.com/version/anfanJh_v.json"

function getPayCallBackUrl()
    return "http://anfanJh.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=anfanJh"
end
