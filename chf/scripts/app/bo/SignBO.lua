--
-- Author: gf
-- Date: 2015-09-21 11:53:40
-- 签到

SignBO = {}

function SignBO.update(data)
	if not data then return end
	SignMO.signData_ = data

	gdump(SignMO.signData_,"SignMO.signData_")
end

function SignBO.updateEveryLogin(data)
	if not data then return end

	SignMO.dailyLogin_ = {}

	SignMO.dailyLogin_.display = data.display
	SignMO.dailyLogin_.accept = data.accept
	SignMO.dailyLogin_.loginIds = data.logins
	gdump(SignMO.dailyLogin_, "SignBO.updateEveryLogin")
end

function SignBO.asynSign(doneCallback,signAward)
	local function parseUpgrade(name, data)
		SignMO.signData_.signs[signAward.signId] = 1
		if table.isexist(data, "award") then
			local awards = PbProtocol.decodeArray(data["award"])
			--加入背包
			local ret = CombatBO.addAwards(awards)
			UiUtil.showAwards(ret)

			--TK统计 金币获得
			for index=1,#awards do
				local award = awards[index]
				if award.type == ITEM_KIND_COIN then
					TKGameBO.onReward(award.count, TKText[1])
				end
			end
		end
		Notify.notify(LOCAL_SIGN_UPDATE_EVENT)
		if doneCallback then doneCallback() end
	end
	local signId = signAward.signId
	SocketWrapper.wrapSend(parseUpgrade, NetRequest.new("Sign",{signId = signId}))
end

function SignBO.getAwardCount()
	local count = 0
	local signs = SignMO.signData_.signs
	local logins = SignMO.signData_.logins
	for index=1,logins do
		if signs[index] == 0 then
			count = count + 1
		end
	end
	return count
end

function SignBO.getCanAwardIndex()
	local idx = 0
	for index=1,#SignMO.signData_.signs do
		local signs = SignMO.signData_.signs[index]
		if signs == 0 and index <= SignMO.signData_.logins then
			idx = index
			break
		end
	end
	if idx > 0 then
		return idx - 1
	else
		return SignMO.signData_.logins - 1
	end

end

function SignBO.asynAcceptEveLogin(doneCallback)
	local function parseAccept(name, data)
		gdump(data, "SignBO.asynAcceptEveLogin")

		local awards = PbProtocol.decodeArray(data.award)
		local statsAward = CombatBO.addAwards(awards)

		SignMO.dailyLogin_.accept = true
		SignMO.dailyLogin_.loginIds = data.logins

		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseAccept, NetRequest.new("AcceptEveLogin"))
end