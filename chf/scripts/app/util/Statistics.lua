--
-- 埋点统计
--
local s_eventtracking = require("app.data.s_eventtracking")

Statistics = {}


STATIS_LOTTERY		= 500
STATIS_POINT_PK		= 512		-- 竞技场发起挑战
STATIS_POINT_REPAIR1 = 513 		-- 修理部队
STATIS_POINT_REPAIR2 = 514 		-- 修理部队
STATIS_POINT_COMM = 515 		-- 点统帅
STATIS_POINT_COMMANDER = 516	-- 点指挥官技能 
STATIS_POINT_HERO	= 517		-- 招募将领
STATIS_POINT_PART_C	= 518 		-- 创建
STATIS_POINT_PART_J	= 519		-- 加入军团
--TASK 					= 1000 - 5000
STATIS_SCIENCE			= 6000
STATIS_ACTIVITY			= 7000
STATIS_ATTACK			= 8000
STATIS_SCOUT			= 9000
STATIS_COMBAT	= 10000
STATIS_BUILDING = 1000000





ST_P_1 = 1 			-- 点击跳过动画
ST_P_3 = 3 			-- 谭雅的对话框【点击任意位置继续】
ST_P_5 = 5 			-- 我的对话框【点击任意位置继续】
ST_P_10 = 10 		-- 点击【刺激战场】图标
ST_P_13 = 13 		-- 点击靶子2
ST_P_15 = 15 		-- 点击靶子3
ST_P_17 = 17 		-- 点击靶子4
ST_P_20 = 20 		-- 谭雅的对话框【点击任意位置继续】
ST_P_25 = 25 		-- 点击刺激战场中的【返回】按钮
ST_P_30 = 30 		-- 点击主界面【关卡】图标
ST_P_31 = 31 		-- 谭雅的对话框【点击任意位置继续】
ST_P_32 = 32		-- 点击【战车小队】图标
ST_P_34 = 34 		-- 点击【跳过】按钮
ST_P_35 = 35 		-- 点击【继续战斗】按钮
ST_P_37 = 37 		-- 工程师的对话框【点击任意位置继续】
ST_P_39 = 39 		-- 点击关卡中的【返回】按钮
ST_P_40 = 40 		-- 点击【科技馆】
ST_P_45 = 45 		-- 点击科技馆中的【建造】按钮
ST_P_50 = 50 		-- 再次点击【科技馆】
ST_P_55 = 55 		-- 点击维修小队后的【↑】按钮
ST_P_57 = 57 		-- 谭雅的对话框【点击任意位置继续】
ST_P_59 = 59 		-- 点击科技馆中的【返回】按钮
ST_P_60 = 60 		-- 再次点击主界面【关卡】图标
ST_P_62 = 62 		-- 点击【通关宝箱】图标
ST_P_64 = 64 		-- 谭雅的对话框【点击任意位置继续】
ST_P_66 = 66 		-- 点击副本奖励界面的【关闭】按钮
ST_P_68 = 68 		-- 谭雅的对话框【点击任意位置继续】
ST_P_70 = 70 		-- 点击新手礼包的【领取】按钮


-- to local file test
local _POST = {
[1  ]     = "点击跳过动画 ",
[3  ]     = "谭雅的对话框【点击任意位置继续】",
[5  ]	  = "我的对话框【点击任意位置继续】",
[10 ]    = "点击【刺激战场】图标 ",
[13 ]    = "点击靶子2 ",
[15 ]     = "点击靶子3 ",
[17 ]     = "点击靶子4 ",
[20 ]     = "谭雅的对话框【点击任意位置继续】",
[25 ]     = "点击刺激战场中的【返回】按钮 ",
[30 ] 	  = "点击主界面【关卡】图标 ",
[31 ] 	  = "谭雅的对话框【点击任意位置继续】",
[32 ] 	  = "点击【战车小队】图标 ",
[34 ] 	  = "点击【跳过】按钮 ",
[35 ] 	  = "点击【继续战斗】按钮 ",
[37 ] 	  = "工程师的对话框【点击任意位置继续】",
[39 ] 	  = "点击关卡中的【返回】按钮 ",
[40 ] 	  = "点击【科技馆】",
[45 ] 	  = "点击科技馆中的【建造】按钮 ",
[50 ] 	  = "再次点击【科技馆】",
[55 ] 	  = "点击维修小队后的【↑】按钮 ",
[57 ] 	  = "谭雅的对话框【点击任意位置继续】",
[59 ] 	  = "点击科技馆中的【返回】按钮 ",
[60 ] 	  = "再次点击主界面【关卡】图标 ",
[62 ] 	  = "点击【通关宝箱】图标 ",
[64 ] 	  = "谭雅的对话框【点击任意位置继续】",
[66 ] 	  = "点击副本奖励界面的【关闭】按钮 ",
[68 ] 	  = "谭雅的对话框【点击任意位置继续】",
[70 ] 	  = "点击新手礼包的【领取】按钮 "
}

local db_eventtracking_ = nil
local URL = nil -- "http://192.168.1.39/tank_account/account/rolePoint.do"
function Statistics.Init()
	db_eventtracking_ = {}
	local records = DataBase.query(s_eventtracking)
	for index = 1, #records do
		local data = records[index]
		db_eventtracking_[#db_eventtracking_ + 1] = data.id
	end
	URL = db_eventtracking_[1] .. "?deviceNo=%s&platNo=%s&point=%d&vip=%d&level=%d&userId=%s&serverId=%d"
end

-- 设备id 			deviceNo
-- 渠道ID			platNo
-- 服务器ID			serverId
-- 角色ID			userId
-- 角色等级 		level
-- 角色VIP等级		vip
-- 记录点 			point
function Statistics.setInfo(deviceNo,platName)
	Statistics.deviceNo = deviceNo
	Statistics.platName = platName
end

--
function Statistics.postPoint(point)
	if true then return end --暂时屏蔽埋点
	if UserMO.level_ >= 30 then return end
	
	if not URL then
		print("[Statistics] URL IS NONE")
		return
	end
	-- body
	local deviceNo = tostring((Statistics.deviceNo or 0))
	local platNo = tostring((Statistics.platName or 0))
	local _point = point
	local vip = UserMO.vip_ or 0
	local level = UserMO.level_ or 0
	local userId = tostring((UserMO.lordId_ or 0))
	local serverId = GameConfig.areaId or 0
	
	
	if false then
		-- local str = _POST[point]
		-- print("======================= _POST: " .. str)

		-- to local file test
		local _URL = "======================= deviceNo=%s&platNo=%d&point=%d&vip=%d&level=%d&userId=%s&serverId=%d\n%s\n"
		local httpURL = string.format(_URL, deviceNo, platNo, _point, vip, level, userId, serverId, str)
		local f = assert(io.open("statistics.log", "a+"))
		if f then
			f:write(httpURL) 
			f:close()
		end
	end

	-- to romate server
	local function resoult(event)
		-- body
	end
	print("[Statistics] postPoint: " .. tostring(point))
	local httpURL = string.format(URL, deviceNo, platNo, _point, vip, level, userId, serverId)
	local request = network.createHTTPRequest(resoult, httpURL, "post")
    if request then
        request:setTimeout(30)
        request:start()
    end
	

end

-- function Statistics.actionPoint(info)
-- 	local p = 0
-- 	for k,v in pairs(POINT) do
-- 		if info[k] then
-- 			if type(v) == "table" then
-- 				p = v[info[k]]
-- 			else
-- 				p = v
-- 			end
-- 			break
-- 		end
-- 	end
-- 	if p and p > 0 then
-- 		SocketWrapper.wrapSend(function() end, NetRequest.new("ActionPoint",{point=p}))
-- 	end
-- end

-- local LogURL = "http://caohuaEn.tank.hundredcent.com:9200/tank_account/account/actionLog.do?log=%s"
-- function Statistics.postLog( point )
-- 	gprint("@^^^^^^^Statistics.postLog>>>>>", point)
-- 	if device.platform == "ios" or device.platform == "mac" or true then
-- 	    local request = network.createHTTPRequest(function(event)
-- 		    	-- local request = event.request
-- 	        end, string.format(LogURL, string.format("%s|%s|%s",Statistics.deviceNo,Statistics.platName, point)), "post")
-- 	    if request then
-- 	        request:setTimeout(30)
-- 	        request:start()
-- 	    end	
-- 	end
-- end



-- 1	激活APP图标（安装游戏后，点击icon，启动游戏）
-- 2	loading（成功/失败）
-- 3	启动成功，进入账号登陆界面
-- 4	点击账号注册/一键登录/FB登陆
-- 5	点击登录游戏
-- 6	登录成功，开始创建角色
-- 7	点击选择性别
-- 8	点击为角色起名
-- 9	点击确定
-- 10	loading（成功/失败）
-- local POINT = {
-- 	combat = { --点击关卡战斗
-- 		[101] = 11,
-- 		[102] = 16,
-- 		[103] = 27,
-- 		[104] = 32,
-- 		[105] = 40,
-- 		[106] = 45,
-- 		[107] = 58,
-- 		[108] = 63,
-- 		[109] = 78,
-- 	},
-- 	demo = 15,
-- 	head = 22,
-- 	tongshuai = 23,
-- 	skillTab = 24,
-- 	upskill = 25,
-- 	clickCombat3 = 41,--点击第三关按钮
-- 	openCombat1 = {
-- 		[26] = 26,
-- 		[39] = 39,
-- 		[57] = 57,
-- 	},
-- 	openBuildEquip = 37, --点击装备工厂
-- 	equipAll = 38, --点击一键装备
-- 	openBuildChariotA = 50, --点击坦克生产工厂A
-- 	clickTankProduct = 51, --点击生产坦克
-- 	clickTank = 52, --点击坦克
-- 	productTank = 53, --生产坦克
-- 	speedTank = 54, --坦克加速
-- 	speedTankConfirm = 55, --确认坦克加速
-- 	toWildMap = 68, --跳转到资源建造界面
-- 	openBuildIron = 69, --打开建造iron
-- 	buildIron = 70, --建造iron矿
-- 	toWorldMap = 71, --跳转到世界
-- 	toBaseMap = 72, --返回主城
-- 	openBuildCommand = 73,  --点击司令部
-- 	maxPower = 120,--点击最大战力
-- 	lotteryTreasure = 130, --点击幸运币抽奖
-- 	openTankdetail = 140, --点击查看坦克属性
-- 	openWorldDetail = 150,--点击查看世界玩法介绍
-- 	clickDaySign = 160, --点击签到
-- 	awardDaySign = 170, --领取签到奖励
-- 	clickSerect = 180, --点击小秘书
-- 	openTaskView = {
-- 		[75] = 75,
-- 	},
-- 	battleLeave = 80, --点击离开战斗奖励界面
-- 	finishTask = 76, --完成任务奖励
-- 	openGuideGift = 84, --打开新手引导奖励
-- 	startMain = 85,      --加载完loading开始进入mainscene
-- }