--
-- Author: gf
-- Date: 2015-10-16 13:59:33
--

GMMO = {}

GMMO.showToolBtn = true

--GM邮件类型
GM_MAIL_SEND_TYPE = {
	{name = "全服玩家",str = "mail all"},
	{name = "在线玩家",str = "mail online"},
	{name = "自定义",str = "mail %s"},
	{name = "渠道全服", str = "platMail %s"}
}

-- GM_MAIL_AWARD = {
-- 	{
-- 		{type = ITEM_KIND_PROP,id = 25,count = 1},
-- 		{type = ITEM_KIND_PROP,id = 26,count = 1},
-- 		{type = ITEM_KIND_PROP,id = 27,count = 1},
-- 		{type = ITEM_KIND_PROP,id = 28,count = 1},
-- 		{type = ITEM_KIND_PROP,id = 29,count = 1}
-- 	},
-- 	{
-- 		{type = ITEM_KIND_PROP,id = 109,count = 10},
-- 		{type = ITEM_KIND_PROP,id = 1,count = 2}
-- 	},
-- 	{
-- 		{type = ITEM_KIND_PROP,id = 119,count = 100}
-- 	},
-- 	{
-- 		{type = ITEM_KIND_COIN,id = 0,count = 2000}
-- 	},
-- 	{
-- 		{type = ITEM_KIND_COIN,id = 0,count = 8000}
-- 	},
-- 	{
-- 		{type = ITEM_KIND_COIN,id = 0,count = 10000}
-- 	},
-- 	{
-- 		{type = 5,id = 137,count = 1},
-- 		{type = 14,id = 13,count = 5},
-- 		{type = 5,id = 90,count = 1}
-- 	}
-- }

GM_CHAT_GAG_STR = {"silence %s 1","silence %s 0","kick %s"}
GM_SET_VIP_STR = "ganVip %s %s"
GM_SET_TOPUP_STR = "ganTopup %s %s"

GM_CLEAR_PLAYER_MAIL = "clearPlayer %s mail"