--
-- Author: Your Name
-- Date: 2017-06-16 15:07:38
--
--老玩家回归
PlayerBackBO = {}

function PlayerBackBO.update(data)
	if not data then return end

	local backTime = data.backTime
	if backTime == -1 then -- -1就代表没有活动
		return
	elseif backTime > 0 then
		PlayerBackMO.isBack_ = true
	else
		PlayerBackMO.isBack_ = false
		if UiDirector.getTopUiName() == "ActivityPlayerReturnView" then
			Toast.show(CommonText[100021])
			UiDirector.popMakeUiTop("HomeView")
		end
	end

	PlayerBackMO.backPackage_ = {}
	PlayerBackMO.backTime_ = data.backTime
	PlayerBackMO.backPackage_.status = data.status
	PlayerBackMO.backPackage_.today = data.today
	PlayerBackMO.backPackage_.endTime = data.endTime


	if not PlayerBackMO.tickTimer_ then
		PlayerBackMO.tickTimer_ = ManagerTimer.addTickListener(PlayerBackBO.onTick)
	end

	if PlayerBackMO.isBack_ then
		Notify.notify(LOCAL_PLAYER_BACK_UPDATE_EVENT)
	end
end

function PlayerBackBO.onTick( dt )
	if PlayerBackMO.isBack_ then
		if PlayerBackMO.backPackage_.endTime > 0 then
			PlayerBackMO.backPackage_.endTime = PlayerBackMO.backPackage_.endTime - dt
		end

		if PlayerBackMO.backPackage_.endTime <= 0 then
			PlayerBackBO.GetPlayerBackInfo()
		end
	end
end

--老玩家回归活动
function PlayerBackBO.GetPlayerBackInfo(rhand)
	local function parseResult(name,data)
		if rhand then
			Loading.getInstance():unshow()
			PlayerBackBO.update(data)
			rhand()
		else
			PlayerBackBO.update(data)
		end
	end
	if rhand then
		Loading.getInstance():show()
	end
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetPlayerBackMessage"))
end

--老玩家回归buff
function PlayerBackBO.GetPlayerBackbuffs(rhand)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetPlayerBackBuff"))
end

--领取奖励
function PlayerBackBO.getBackAwards(rhand,awardTypeId)
	local function parseResult(name,data)
		Loading.getInstance():unshow()
		PlayerBackMO.backPackage_.status = data.status
		local awards = PbProtocol.decodeArray(data["award"])
		 --加入背包
		local ret = CombatBO.addAwards(awards)
		UiUtil.showAwards(ret)
		--TK统计 金币消耗
		if table.isexist(data, "gold") then
			TKGameBO.onUseCoinTk(data.gold,TKText[67],TKGAME_USERES_TYPE_UPDATE)
			UserMO.updateResource(ITEM_KIND_COIN, data.gold)
		end
		rhand(data)
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("GetPlayerBackAwards",{awardTypeId = awardTypeId}))
end