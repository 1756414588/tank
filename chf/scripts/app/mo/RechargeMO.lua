--
-- Author: gf
-- Date: 2015-11-04 11:06:16
--

local s_pay = require("app.data.s_pay")
local s_pay_ios = require("app.data.s_pay_ios")

RechargeMO = {}

-- 各个充值额度的状态
RechargeMO.recharge_state = {}
RechargeMO.recharge_state_ios = {}

RechargeMO.recharge_new_state = {}
RechargeMO.recharge_new_state_ios = {}

RechargeMO.synActNewPayInfoHandler_ = nil
RechargeMO.synActNew2PayInfoHandler_ = nil


--是否开启充值
RechargeMO.enable = true

FIRST_RECHARGE_ACTIVITY_ID = 97 --首充礼包活动KEYID

RECHARGE_PLATFORM_ANDROID = 1
RECHARGE_PLATFORM_IOS = 2

RECHARGE_RESULT_SUCCESS = "1"
RECHARGE_RESULT_FAIL = "2"
RECHARGE_RESULT_CANCEL = "3"

--充值到账邮件moldId
RECHARGE_MAIL_MOLDID = 39

--兑换比例
GAME_PAY_RATE = 10
--货币单位
GAME_PAY_CURRENCYTYPE = "CNY"

--专属客服开启VIP等级
PERSONAL_SERVICE_VIP = 16
PERSONAL_SERVICE_QQ = {
	""
}



PRODUCTID_CONFIG = {
	ch_appstore = {
		{payId = 1, productId = "com.caohua.tank60"},
		{payId = 2, productId = "com.caohua.tank300"},
		{payId = 3, productId = "com.caohua.tank980"},
		{payId = 4, productId = "com.caohua.tank1980"},
		{payId = 5, productId = "com.caohua.tank3280"},
		{payId = 6, productId = "com.caohua.tank6480"}
	},
	chzzzhg_appstore = {
		{payId = 1, productId = "com.zzzhg2.60"},
		{payId = 2, productId = "com.zzzhg2.300"},
		{payId = 3, productId = "com.zzzhg2.980"},
		{payId = 4, productId = "com.zzzhg2.1980"},
		{payId = 5, productId = "com.zzzhg2.3280"},
		{payId = 6, productId = "com.zzzhg2.6480"}
	},

	chzzzhg1_appstore = {
		{payId = 1, productId = "com.zzzhgx.60"},
		{payId = 2, productId = "com.zzzhgx.300"},
		{payId = 3, productId = "com.zzzhgx.980"},
		{payId = 4, productId = "com.zzzhgx.1980"},
		{payId = 5, productId = "com.zzzhgx.3280"},
		{payId = 6, productId = "com.zzzhgx.6480"}
	},

	chzzzhg2_appstore = {
		{payId = 1, productId = "com.zzzhgzjbt.60"},
		{payId = 2, productId = "com.zzzhgzjbt.300"},
		{payId = 3, productId = "com.zzzhgzjbt.980"},
		{payId = 4, productId = "com.zzzhgzjbt.1980"},
		{payId = 5, productId = "com.zzzhgzjbt.3280"},
		{payId = 6, productId = "com.zzzhgzjbt.6480"}
	},

	chlhtk_appstore = {
		{payId = 1, productId = "com.caohua.lhtk60"},
		{payId = 2, productId = "com.caohua.lhtk.300"},
		{payId = 3, productId = "com.caohua.lhtk980"},
		{payId = 4, productId = "com.caohua.lhtk1980"},
		{payId = 5, productId = "com.caohua.lhtk3280"},
		{payId = 6, productId = "com.caohua.lhtk6480"}
	},
	af_appstore = {
		{payId = 1, productId = "com.anfan.tank60"},
		{payId = 2, productId = "com.anfan.tank300"},
		{payId = 3, productId = "com.anfan.tank980"},
		{payId = 4, productId = "com.anfan.tank1980"},
		{payId = 5, productId = "com.anfan.tank3280"},
		{payId = 6, productId = "com.anfan.tank6480"}
	},
	afTkxjy_appstore = {
		{payId = 1, productId = "com.anfan.tkxjy60"},
		{payId = 2, productId = "com.anfan.tkxjy300"},
		{payId = 3, productId = "com.anfan.tkxjy980"},
		{payId = 4, productId = "com.anfan.tkxjy1980"},
		{payId = 5, productId = "com.anfan.tkxjy3280"},
		{payId = 6, productId = "com.anfan.tkxjy6480"}
	},
	mz_appstore = {
		{payId = 1, productId = "com.muzhi.tank60"},
		{payId = 2, productId = "com.muzhi.tank300"},
		{payId = 3, productId = "com.muzhi.tank980"},
		{payId = 4, productId = "com.muzhi.tank1980"},
		{payId = 5, productId = "com.muzhi.tank3280"},
		{payId = 6, productId = "com.muzhi.tank6480"}
	},
	mztkwz_appstore = {
		{payId = 1, productId = "com.Jrutech.Tank.Produc01.new1"},
		{payId = 2, productId = "com.Jrutech.Tank.Produc02.new1"},
		{payId = 3, productId = "com.Jrutech.Tank.Produc03.new1"},
		{payId = 4, productId = "com.Jrutech.Tank.Produc04.new1"},
		{payId = 5, productId = "com.Jrutech.Tank.Produc05.new1"},
		{payId = 6, productId = "com.Jrutech.Tank.Produc06.new1"}
	},
	mztkdg_appstore = {
		{payId = 1, productId = "com.Jrutech.Tank.Produc01.new2"},
		{payId = 2, productId = "com.Jrutech.Tank.Produc02.new2"},
		{payId = 3, productId = "com.Jrutech.Tank.Produc03.new2"},
		{payId = 4, productId = "com.Jrutech.Tank.Produc04.new2"},
		{payId = 5, productId = "com.Jrutech.Tank.Produc05.new2"},
		{payId = 6, productId = "com.Jrutech.Tank.Produc06.new2"}
	},
	mzeztk_appstore = {
		{payId = 1, productId = "com.Jrutech.Tank.Produc01.new3"},
		{payId = 2, productId = "com.Jrutech.Tank.Produc02.new3"},
		{payId = 3, productId = "com.Jrutech.Tank.Produc03.new3"},
		{payId = 4, productId = "com.Jrutech.Tank.Produc04.new3"},
		{payId = 5, productId = "com.Jrutech.Tank.Produc05.new3"},
		{payId = 6, productId = "com.Jrutech.Tank.Produc06.new3"}
	},
	mztkwc_appstore = {
		{payId = 1, productId = "com.Jrutech.Tank.Produc01.new4"},
		{payId = 2, productId = "com.Jrutech.Tank.Produc02.new4"},
		{payId = 3, productId = "com.Jrutech.Tank.Produc03.new4"},
		{payId = 4, productId = "com.Jrutech.Tank.Produc04.new4"},
		{payId = 5, productId = "com.Jrutech.Tank.Produc05.new4"},
		{payId = 6, productId = "com.Jrutech.Tank.Produc06.new4"}
	},
	mztkjj_appstore = {
		{payId = 1, productId = "com.Jrutech.Tank.Produc01.new5"},
		{payId = 2, productId = "com.Jrutech.Tank.Produc02.new5"},
		{payId = 3, productId = "com.Jrutech.Tank.Produc03.new5"},
		{payId = 4, productId = "com.Jrutech.Tank.Produc04.new5"},
		{payId = 5, productId = "com.Jrutech.Tank.Produc05.new5"},
		{payId = 6, productId = "com.Jrutech.Tank.Produc06.new5"}
	},
	mztktj_appstore = {
		{payId = 1, productId = "com.Jrutech.Tank.Produc01.new6"},
		{payId = 2, productId = "com.Jrutech.Tank.Produc02.new6"},
		{payId = 3, productId = "com.Jrutech.Tank.Produc03.new6"},
		{payId = 4, productId = "com.Jrutech.Tank.Produc04.new6"},
		{payId = 5, productId = "com.Jrutech.Tank.Produc05.new6"},
		{payId = 6, productId = "com.Jrutech.Tank.Produc06.new6"}
	},
	mztkjjylfc_appstore = {
		{payId = 1, productId = "com.muzhiyouwan.tankejingjie60"},
		{payId = 2, productId = "com.muzhiyouwan.tankejingjie300"},
		{payId = 3, productId = "com.muzhiyouwan.tankejingjie980"},
		{payId = 4, productId = "com.muzhiyouwan.tankejingjie1980"},
		{payId = 5, productId = "com.muzhiyouwan.tankejingjie3280"},
		{payId = 6, productId = "com.muzhiyouwan.tankejingjie6480"}
	},
	chdgzhg_appstore = {
		{payId = 1, productId = "com.empirezhg.gz_1"},
		{payId = 2, productId = "com.empirezhg.gz_2"},
		{payId = 3, productId = "com.empirezhg.gz_3"},
		{payId = 4, productId = "com.empirezhg.gz_4"},
		{payId = 5, productId = "com.empirezhg.gz_5"},
		{payId = 6, productId = "com.empirezhg.gz_6"}
	},
	mztkjjhwcn_appstore = {
		{payId = 1, productId = "com.MZYW.tankejingjie60"},
		{payId = 2, productId = "com.MZYW.tankejingjie300"},
		{payId = 3, productId = "com.MZYW.tankejingjie980"},
		{payId = 4, productId = "com.MZYW.tankejingjie1980"},
		{payId = 5, productId = "com.MZYW.tankejingjie3280"},
		{payId = 6, productId = "com.MZYW.tankejingjie6480"}
	},
	chjxtk_appstore = {
		{payId = 1, productId = "com.jxtk.60"},
		{payId = 2, productId = "com.jxtk.300"},
		{payId = 3, productId = "com.jxtk.980"},
		{payId = 4, productId = "com.jxtk.1980"},
		{payId = 5, productId = "com.jxtk.3280"},
		{payId = 6, productId = "com.jxtk.6480"}
	},
	chcjzj_appstore = {
		{payId = 1, productId = "com.cjtk.60"},
		{payId = 2, productId = "com.cjtk.300"},
		{payId = 3, productId = "com.cjtk.980"},
		{payId = 4, productId = "com.cjtk.1980"},
		{payId = 5, productId = "com.cjtk.3280"},
		{payId = 6, productId = "com.cjtk.6480"}
	},
	chxsjt_appstore = {
		{payId = 1, productId = "com.xsjt.60"},
		{payId = 2, productId = "com.xsjt.300"},
		{payId = 3, productId = "com.xsjt.980"},
		{payId = 4, productId = "com.xsjt.1980"},
		{payId = 5, productId = "com.xsjt.3280"},
		{payId = 6, productId = "com.xsjt.6480"}
	},
	chgtfc_appstore = {
		{payId = 1, productId = "com.gtfc.60"},
		{payId = 2, productId = "com.gtfc.300"},
		{payId = 3, productId = "com.gtfc.980"},
		{payId = 4, productId = "com.gtfc.1980"},
		{payId = 5, productId = "com.gtfc.3280"},
		{payId = 6, productId = "com.gtfc.6480"}
	},
	chzdjj_appstore = {
		{payId = 1, productId = "com.zdjj.60"},
		{payId = 2, productId = "com.zdjj.300"},
		{payId = 3, productId = "com.zdjj.980"},
		{payId = 4, productId = "com.zdjj.1980"},
		{payId = 5, productId = "com.zdjj.3280"},
		{payId = 6, productId = "com.zdjj.6480"}
	},
	chdgfb_appstore = {
		{payId = 1, productId = "com.dgfb.60"},
		{payId = 2, productId = "com.dgfb.300"},
		{payId = 3, productId = "com.dgfb.980"},
		{payId = 4, productId = "com.dgfb.1980"},
		{payId = 5, productId = "com.dgfb.3280"},
		{payId = 6, productId = "com.dgfb.6480"}
	},
	chzjqy_appstore = {
		{payId = 1, productId = "com.zdjj.60"},
		{payId = 2, productId = "com.zdjj.300"},
		{payId = 3, productId = "com.zdjj.980"},
		{payId = 4, productId = "com.zdjj.1980"},
		{payId = 5, productId = "com.zdjj.3280"},
		{payId = 6, productId = "com.zdjj.6480"}
	},
	mzAqHszz_appstore = {
		{payId = 1, productId = "com.muzhi.tank60"},
		{payId = 2, productId = "com.muzhi.tank300"},
		{payId = 3, productId = "com.muzhi.tank980"},
		{payId = 4, productId = "com.muzhi.tank1980"},
		{payId = 5, productId = "com.muzhi.tank3280"},
		{payId = 6, productId = "com.muzhi.tank6480"}
	},
	mzAqTkjt_appstore = {
		{payId = 1, productId = "com.muzhi.tank60"},
		{payId = 2, productId = "com.muzhi.tank300"},
		{payId = 3, productId = "com.muzhi.tank980"},
		{payId = 4, productId = "com.muzhi.tank1980"},
		{payId = 5, productId = "com.muzhi.tank3280"},
		{payId = 6, productId = "com.muzhi.tank6480"}
	},
	mztkjjylfcba_appstore = {
		{payId = 1, productId = "com.MZYW.tankejingjie60"},
		{payId = 2, productId = "com.MZYW.tankejingjie300"},
		{payId = 3, productId = "com.MZYW.tankejingjie980"},
		{payId = 4, productId = "com.MZYW.tankejingjie1980"},
		{payId = 5, productId = "com.MZYW.tankejingjie3280"},
		{payId = 6, productId = "com.MZYW.tankejingjie6480"}
	},
	mzXmly_appstore = {
		{payId = 1, productId = "com.muzhiyouwan.tkjjdgjq60"},
		{payId = 2, productId = "com.muzhiyouwan.tkjjdgjq300"},
		{payId = 3, productId = "com.muzhiyouwan.tkjjdgjq980"},
		{payId = 4, productId = "com.muzhiyouwan.tkjjdgjq1980"},
		{payId = 5, productId = "com.muzhiyouwan.tkjjdgjq3280"},
		{payId = 6, productId = "com.muzhiyouwan.tkjjdgjq6480"}
	},
	mzAqGtdg_appstore = {
		{payId = 1, productId = "com.muzhi.tank60"},
		{payId = 2, productId = "com.muzhi.tank300"},
		{payId = 3, productId = "com.muzhi.tank980"},
		{payId = 4, productId = "com.muzhi.tank1980"},
		{payId = 5, productId = "com.muzhi.tank3280"},
		{payId = 6, productId = "com.muzhi.tank6480"}
	},
	mzAqHxzz_appstore = {
		{payId = 1, productId = "com.muzhi.tank60"},
		{payId = 2, productId = "com.muzhi.tank300"},
		{payId = 3, productId = "com.muzhi.tank980"},
		{payId = 4, productId = "com.muzhi.tank1980"},
		{payId = 5, productId = "com.muzhi.tank3280"},
		{payId = 6, productId = "com.muzhi.tank6480"}
	},
	mzAqZbshj_appstore = {
		{payId = 1, productId = "com.muzhi.tank60"},
		{payId = 2, productId = "com.muzhi.tank300"},
		{payId = 3, productId = "com.muzhi.tank980"},
		{payId = 4, productId = "com.muzhi.tank1980"},
		{payId = 5, productId = "com.muzhi.tank3280"},
		{payId = 6, productId = "com.muzhi.tank6480"}
	},
	mzAqZzfy_appstore = {
		{payId = 1, productId = "com.muzhi.tank60"},
		{payId = 2, productId = "com.muzhi.tank300"},
		{payId = 3, productId = "com.muzhi.tank980"},
		{payId = 4, productId = "com.muzhi.tank1980"},
		{payId = 5, productId = "com.muzhi.tank3280"},
		{payId = 6, productId = "com.muzhi.tank6480"}
	},
	mzTkjjQysk_appstore = {
		{payId = 1, productId = "com.muzhi.tank60"},
		{payId = 2, productId = "com.muzhi.tank300"},
		{payId = 3, productId = "com.muzhi.tank980"},
		{payId = 4, productId = "com.muzhi.tank1980"},
		{payId = 5, productId = "com.muzhi.tank3280"},
		{payId = 6, productId = "com.muzhi.tank6480"}
	},
	afGhgxs_appstore = {
		{payId = 1, productId = "com.hj.ghgxs60"},
		{payId = 2, productId = "com.hj.ghgxs300"},
		{payId = 3, productId = "com.hj.ghgxs980"},
		{payId = 4, productId = "com.hj.ghgxs1980"},
		{payId = 5, productId = "com.hj.ghgxs3280"},
		{payId = 6, productId = "com.hj.ghgxs6480"}
	},
	afMjdzh_appstore = {
		{payId = 1, productId = "com.tank.mjdzh60"},
		{payId = 2, productId = "com.tank.mjdzh300"},
		{payId = 3, productId = "com.tank.mjdzh980"},
		{payId = 4, productId = "com.tank.mjdzh1980"},
		{payId = 5, productId = "com.tank.mjdzh3280"},
		{payId = 6, productId = "com.tank.mjdzh6480"}
	},
	afWpzj_appstore = {
		{payId = 1, productId = "com.tank.wpzj60"},
		{payId = 2, productId = "com.tank.wpzj300"},
		{payId = 3, productId = "com.tank.wpzj980"},
		{payId = 4, productId = "com.tank.wpzj1980"},
		{payId = 5, productId = "com.tank.wpzj3280"},
		{payId = 6, productId = "com.tank.wpzj6480"}
	},
	afXzlm_appstore = {
		{payId = 1, productId = "com.tank.xzlm60"},
		{payId = 2, productId = "com.tank.xzlm300"},
		{payId = 3, productId = "com.tank.xzlm980"},
		{payId = 4, productId = "com.tank.xzlm1980"},
		{payId = 5, productId = "com.tank.xzlm3280"},
		{payId = 6, productId = "com.tank.xzlm6480"}
	},
	afTqdkn_appstore = {
		{payId = 1, productId = "com.tank.tqdkn60"},
		{payId = 2, productId = "com.tank.tqdkn300"},
		{payId = 3, productId = "com.tank.tqdkn980"},
		{payId = 4, productId = "com.tank.tqdkn1980"},
		{payId = 5, productId = "com.tank.tqdkn3280"},
		{payId = 6, productId = "com.tank.tqdkn6480"}
	},
	afNew_appstore = {
		{payId = 1, productId = "com.tank.tqdkn60"},
		{payId = 2, productId = "com.tank.tqdkn300"},
		{payId = 3, productId = "com.tank.tqdkn980"},
		{payId = 4, productId = "com.tank.tqdkn1980"},
		{payId = 5, productId = "com.tank.tqdkn3280"},
		{payId = 6, productId = "com.tank.tqdkn6480"}
	},
	afGhgzh_appstore = {
		{payId = 1, productId = "com.zhuayou.ghgzh60"},
		{payId = 2, productId = "com.zhuayou.ghgzh300"},
		{payId = 3, productId = "com.zhuayou.ghgzh980"},
		{payId = 4, productId = "com.zhuayou.ghgzh1980"},
		{payId = 5, productId = "com.zhuayou.ghgzh3280"},
		{payId = 6, productId = "com.zhuayou.ghgzh6480"}
	},
	mzGhgzh_appstore = {
		{payId = 1, productId = "com.mzyw.hj60"},
		{payId = 2, productId = "com.mzyw.hj300"},
		{payId = 3, productId = "com.mzyw.hj980"},
		{payId = 4, productId = "com.mzyw.hj1980"},
		{payId = 5, productId = "com.mzyw.hj3280"},
		{payId = 6, productId = "com.mzyw.hj6480"}
	},
	mzYiwanCyzc_appstore = {
		{payId = 1, productId = "com.muzhi.tank60"},
		{payId = 2, productId = "com.muzhi.tank300"},
		{payId = 3, productId = "com.muzhi.tank980"},
		{payId = 4, productId = "com.muzhi.tank1980"},
		{payId = 5, productId = "com.muzhi.tank3280"},
		{payId = 6, productId = "com.muzhi.tank6480"}
	},
	afTqdknHD_appstore = {
		{payId = 1, productId = "com.dg.tqdknhd60"},
		{payId = 2, productId = "com.dg.tqdknhd300"},
		{payId = 3, productId = "com.dg.tqdknhd980"},
		{payId = 4, productId = "com.dg.tqdknhd1980"},
		{payId = 5, productId = "com.dg.tqdknhd3280"},
		{payId = 6, productId = "com.dg.tqdknhd6480"}
	},
	chCjzjtkzz_appstore = {
		{payId = 1, productId = "com.cjzjtk.60"},
		{payId = 2, productId = "com.cjzjtk.300"},
		{payId = 3, productId = "com.cjzjtk.980"},
		{payId = 4, productId = "com.cjzjtk.1980"},
		{payId = 5, productId = "com.cjzjtk.3280"},
		{payId = 6, productId = "com.cjzjtk.6480"}
	},
	chZjqytkdz_appstore = {
		{payId = 1, productId = "com.zjqytkfb.60"},
		{payId = 2, productId = "com.zjqytkfb.300"},
		{payId = 3, productId = "com.zjqytkfb.980"},
		{payId = 4, productId = "com.zjqytkfb.1980"},
		{payId = 5, productId = "com.zjqytkfb.3280"},
		{payId = 6, productId = "com.zjqytkfb.6480"}
	},
	mzLzwz_appstore = {
		{payId = 1, productId = "com.mzyw.luzhan_6"},
		{payId = 2, productId = "com.mzyw.luzhan_30"},
		{payId = 3, productId = "com.mzyw.luzhan_98"},
		{payId = 4, productId = "com.mzyw.luzhan_198"},
		{payId = 5, productId = "com.mzyw.luzhan_328"},
		{payId = 6, productId = "com.mzyw.luzhan_648"}
	},

	afNewMjdzh_appstore = {
		{payId = 1, productId = "com.hj.mjdzh60"},
		{payId = 2, productId = "com.hj.mjdzh300"},
		{payId = 3, productId = "com.hj.mjdzh980"},
		{payId = 4, productId = "com.hj.mjdzh1980"},
		{payId = 5, productId = "com.hj.mjdzh3280"},
		{payId = 6, productId = "com.hj.mjdzh6480"}
	},

	afNewWpzj_appstore = {
		{payId = 1, productId = "com.hj.wpzj60"},
		{payId = 2, productId = "com.hj.wpzj300"},
		{payId = 3, productId = "com.hj.wpzj980"},
		{payId = 4, productId = "com.hj.wpzj1980"},
		{payId = 5, productId = "com.hj.wpzj3280"},
		{payId = 6, productId = "com.hj.wpzj6480"}
	},

	afLzyp_appstore = {
		{payId = 1, productId = "com.hongjing.lzyp60"},
		{payId = 2, productId = "com.hongjing.lzyp300"},
		{payId = 3, productId = "com.hongjing.lzyp980"},
		{payId = 4, productId = "com.hongjing.lzyp1980"},
		{payId = 5, productId = "com.hongjing.lzyp3280"},
		{payId = 6, productId = "com.hongjing.lzyp6480"}
	},
	chhjfc_appstore = {
		{payId = 1, productId = "com.qzkj.hjfc_60"},
		{payId = 2, productId = "com.qzkj.hjfc_300"},
		{payId = 3, productId = "com.qzkj.hjfc_980"},
		{payId = 4, productId = "com.qzkj.hjfc_1980"},
		{payId = 5, productId = "com.qzkj.hjfc_3280"},
		{payId = 6, productId = "com.qzkj.hjfc_6480"}
	}

	
}



RechargeMO.rechargeList = {}

local db_pay_
local db_pay_ios_

function RechargeMO.init()
	if not db_pay_ then
		db_pay_ = {}
		local records = DataBase.query(s_pay)
		for index = 1, #records do
			local data = records[index]
			db_pay_[data.payId] = data
			RechargeMO.recharge_state[data.payId] = 0
		end
	end

	if not db_pay_ios_ then
		db_pay_ios_ = {}
		local records = DataBase.query(s_pay_ios)
		for index = 1, #records do
			local data = records[index]
			db_pay_ios_[data.payId] = data
			RechargeMO.recharge_state_ios[data.payId] = 0
		end
	end
	--排序
	function sortFun(a,b)
		return a.asset < b.asset
	end
	table.sort(db_pay_,sortFun)
end

-- function RechargeMO.queryRecharge(payId)
-- 	if not db_pay_[payId] then return nil end
-- 	return db_pay_[payId]
-- end

--根据平台获取充值挡
function RechargeMO.getRechargeByPlatform(platform)
	-- local list = {}
	-- for index=1,#db_pay_ do
	-- 	data = db_pay_[index]
	-- 	if data.platform == platform then
	-- 		list[#list + 1] = data
	-- 	end
	-- end
	-- return list
	if device.platform == "android" or device.platform == "windows" then
		return db_pay_
	else
		return db_pay_ios_
	end
	
end

function RechargeMO.setRechargeState(payId, state)
	-- body
	if device.platform == "android" or device.platform == "windows" then
		RechargeMO.recharge_state[payId] = state
	else
		RechargeMO.recharge_state_ios[payId] = state
	end
end

function RechargeMO.getRechargeState(payId)
	-- body
	if device.platform == "android" or device.platform == "windows" then
		return RechargeMO.recharge_state[payId]
	else
		return RechargeMO.recharge_state_ios[payId]
	end
end

function RechargeMO.setRechargeNewState(payId, state)
	-- body
	if device.platform == "android" or device.platform == "windows" then
		RechargeMO.recharge_new_state[payId] = state
	else
		RechargeMO.recharge_new_state_ios[payId] = state
	end
end

function RechargeMO.getRechargeNewState(payId)
	-- body
	if device.platform == "android" or device.platform == "windows" then
		return RechargeMO.recharge_new_state[payId]
	else
		return RechargeMO.recharge_new_state_ios[payId]
	end
end

--获取支付需要用到的productId
function RechargeMO.getProductId(payId)
	local productId = ""
	if GameConfig.environment == "af_appstore" or GameConfig.environment == "ch_appstore" 
		or GameConfig.environment == "mz_appstore" or GameConfig.environment == "mztkwz_appstore" 
		or GameConfig.environment == "mztkdg_appstore" or GameConfig.environment == "mzeztk_appstore" 
		or GameConfig.environment == "mztkwc_appstore" or GameConfig.environment == "mztkjj_appstore" 
		or GameConfig.environment == "chlhtk_appstore" or GameConfig.environment == "afTkxjy_appstore" 
		or GameConfig.environment == "mztktj_appstore" or GameConfig.environment == "mztkjjylfc_appstore" 
		or GameConfig.environment == "chdgzhg_appstore" or GameConfig.environment == "mztkjjhwcn_appstore" 
		or GameConfig.environment == "chjxtk_appstore" or GameConfig.environment == "chcjzj_appstore" 
		or GameConfig.environment == "chxsjt_appstore" or GameConfig.environment == "chgtfc_appstore"
        or GameConfig.environment == "chzdjj_appstore" or GameConfig.environment == "chdgfb_appstore" 
        or GameConfig.environment == "chzjqy_appstore" or GameConfig.environment == "mzAqHszz_appstore" 
        or GameConfig.environment == "mzAqTkjt_appstore" or GameConfig.environment == "mztkjjylfcba_appstore" 
        or GameConfig.environment == "mzXmly_appstore" or GameConfig.environment == "mzAqGtdg_appstore"
        or GameConfig.environment == "mzAqHxzz_appstore" or GameConfig.environment == "mzAqZbshj_appstore" 
        or GameConfig.environment == "mzAqZzfy_appstore" or GameConfig.environment == "mzTkjjQysk_appstore" 
        or GameConfig.environment == "chzzzhg_appstore" or GameConfig.environment == "afGhgxs_appstore" 
        or GameConfig.environment == "afMjdzh_appstore" or GameConfig.environment == "afWpzj_appstore" 
        or GameConfig.environment == "afXzlm_appstore" or GameConfig.environment == "afTqdkn_appstore" 
        or GameConfig.environment == "chzzzhg1_appstore" or GameConfig.environment == "chzzzhg2_appstore" 
        or GameConfig.environment == "afGhgzh_appstore" or GameConfig.environment == "mzGhgzh_appstore" 
        or GameConfig.environment == "mzYiwanCyzc_appstore" or GameConfig.environment == "afTqdknHD_appstore" 
        or GameConfig.environment == "chCjzjtkzz_appstore" or GameConfig.environment == "afNew_appstore" 
        or GameConfig.environment == "chZjqytkdz_appstore" or GameConfig.environment == "mzLzwz_appstore" 
        or GameConfig.environment == "afNewMjdzh_appstore" or GameConfig.environment == "afNewWpzj_appstore" 
        or GameConfig.environment == "afLzyp_appstore" or GameConfig.environment == "chhjfc_appstore" then
		local config = PRODUCTID_CONFIG[GameConfig.environment]
		for index=1,#config do
			local data = config[index]
			if payId == data.payId then
				productId = data.productId
			end
		end
	end
	return productId
end

-- --根据渠道获取充值挡
-- function RechargeMO.getRechargeByPlattype(plattype)
-- 	local list = {}
-- 	for index=1,#db_pay_ do
-- 		data = db_pay_[index]
-- 		if data.plattype == plattype then
-- 			list[#list + 1] = data
-- 		end
-- 	end
-- 	return list
-- end



