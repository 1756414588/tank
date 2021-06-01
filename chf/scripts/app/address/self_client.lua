-- 
-- -- 登录平台参数
LOGIN_PLATFORM_PARAM = "self"

-- -- 金山云
-- GameConfig.accountURL = "http://self.tank.hundredcent.com:9200/tank_account/account/account.do"
-- GameConfig.areaURL = "http://self.tank.hundredcent.com/serverlist_tank.json"
-- GameConfig.downRootURL = "http://self.tank.hundredcent.com/tank_2.0.1/"
----  策划服

-- GameConfig.accountURL = "http://192.168.2.166:9200/tank_account/account/account.do"
-- GameConfig.areaURL = "http://192.168.2.166/serverlist_tank.json"
-- GameConfig.downRootURL = "http://192.168.2.166/tank_2.0.1/"

----  策划服(new)
GameConfig.accountURL = "http://192.168.1.166:9200/tank_account/account/account.do"
GameConfig.areaURL = "http://192.168.1.166/serverlist_tank.json"
GameConfig.downRootURL = "http://192.168.1.166/tank_2.0.1/"

-- -- 金山云
-- GameConfig.accountURL = "http://self.tank.hundredcent.com:9200/tank_account/account/account.do"
-- GameConfig.areaURL = "http://self.tank.hundredcent.com/serverlist_tank.json"
-- GameConfig.downRootURL = "http://self.tank.hundredcent.com/tank_2.0.1/"


-- ----- 预发布
-- GameConfig.accountURL = "http://119.29.180.212:9200/tank_account/account/account.do"
-- GameConfig.areaURL = "http://119.29.180.212/serverlist_tank.json"
-- GameConfig.downRootURL = "http://119.29.180.212/tank_2.0.1/"


-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
-- GameConfig.versionURL = "http://cdn.tank.hundredcent.com/version/tank_apk_hf.json"

--GameConfig.downRootURL = "http://localhost/tank_1.0.1/"
 -- GameConfig.payTypeURL = "http://localhost/version/ch_ios_payType.json"

-- GameConfig.accountURL = "http://muzhi.tank.hundredcent.com:9200/tank_account/account/account.do"
-- GameConfig.areaURL = "http://muzhi.tank.hundredcent.com/serverlist_tank.json"
-- GameConfig.downRootURL = "http://cdn.tank.hundredcent.com/tank_2.0.1/"
-- GameConfig.versionURL = "http://cdn.tank.hundredcent.com/version/tank_apk_hf.json"

-- GameConfig.verifyURL = "http://af_appstore.tank.hundredcent.com/version/tank_ios_test.json"

-- GameConfig.verifyURL = "http://af_appstore.tank.hundredcent.com/version/tank_ios_test.json"
-- GameConfig.verifyURL = "http://mztkjj_appstore.tank.hundredcent.com/version/tank_ios_test.json"

-- GameConfig.accountURL = "http://119.29.180.212:9200/tank_account/account/account.do"
-- GameConfig.areaURL = "http://119.29.180.212/serverlist_tank.json"
-- GameConfig.downRootURL = "http://119.29.180.212/tank_1.0.1/"

-- GameConfig.accountURL = "http://muzhi.tank.hundredcent.com:9200/tank_account/account/account.do"
-- GameConfig.areaURL = "http://muzhi.tank.hundredcent.com/serverlist_tank.json"


function getPayCallBackUrl()
    return "http://self.tank.hundredcent.com:9200/tank_account/account/payCallback.do?plat=self"
end
