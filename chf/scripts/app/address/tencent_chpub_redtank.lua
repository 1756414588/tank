--
-- Author: Your Name
-- Date: 2017-03-11 17:33:51
--
LOGIN_PLATFORM_PARAM = nil
LOGIN_PLATFORM_PARAM_QQ = "chredtankSq"
LOGIN_PLATFORM_PARAM_WX = "chredtankWx"

--草花红色坦克风暴
GameConfig.accountURL = "http://tencent-caohua.hundredcent.com:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://tencent-caohua.hundredcent.com/serverlist_tank.json"
GameConfig.downRootURL = "http://cdn.tank.hundredcent.com/tank_2.0.1/"
GameConfig.versionURL = "http://cdn.tank.hundredcent.com/version/tank_apk_hf.json"


function getPayCallBackUrl()
    return "http://tencent-caohua.hundredcent.com:9200/tank_account/account/payCallback.do?plat=" .. LOGIN_PLATFORM_PARAM
end