--
-- Author: Gss
-- Date: 2018-12-12 16:33:21
--
-- 战术 TacticsBO

TacticsBO = {}

function TacticsBO.update(data)
	if not data then return end
	local tactics = PbProtocol.decodeArray(data["tactics"]) --战术
	local tacticPieces = PbProtocol.decodeArray(data["tacticsSlice"]) --碎片
	local tacticMaterials = PbProtocol.decodeArray(data["tacticsItem"]) --材料
	local forms = PbProtocol.decodeArray(data["facticsForm"]) --阵型
	if tactics and #tactics > 0 then
		for index=1,#tactics do
			local tactic = tactics[index]
			if not tactic.bind then --初始为0，
				tactic.bind = 0
			end
			TacticsMO.tactics_[tactic.keyId] = tactic
		end
	end

	if tacticPieces then
		for index=1,#tacticPieces do
			TacticsMO.pieces_[tacticPieces[index].v1] = tacticPieces[index].v2
		end
	end

	TacticsMO.updateMatrial(tacticMaterials)

	for idx=1,#forms do
		local info = forms[idx]
		for index=1,TACTIC_CANUSE_MAX_NUM do
			if not info.keyId[index] then
				info.keyId[index] = 0
				break
			end
		end
	end

	--战术阵型初始化
	for num = 1, TACTIC_FORMATION_MAX_NUM do  -- 阵型
		local isexist = false
		if forms and #forms > 0 then
			for k,v in pairs(forms) do
				if v.index == num then
					TacticsMO.TacticForms_[v.index] = v
					isexist = true
					break
				end
			end
		end
		if not isexist then
			TacticsMO.TacticForms_[num] = {index = num, keyId = {[1] = 0, [2] = 0, [3] = 0, [4] = 0, [5] = 0, [6] = 0}}
		end
	end

end

--接收推送
function TacticsBO.parseTacticSync(name, data)
	if not data then return end
	local tactics = PbProtocol.decodeArray(data["tactics"]) --战术
	for index=1,#tactics do
		local tactic = tactics[index]
		TacticsMO.tactics_[tactic.keyId] = tactic  --同一keyId。刷新战术数据
	end
end

--战术升级
--升级的战术keyId,
--consumeKeyId=2;//消耗得战术keyid
--tacticsSlice =3;//需要消耗得战术碎片
function TacticsBO.onTacticUpgrade(doneCallback, consumeList, pieceList, keyId)
	local function parseResult(name, data)
		Loading.getInstance():unshow()

		local tactic = data.tactics
		TacticsMO.tactics_[tactic.keyId] = tactic

		if table.isexist(data, "consumeKeyId") then
			local consumeTactics = data.consumeKeyId
			for k,v in pairs(consumeTactics) do
				TacticsMO.tactics_[v] = nil
			end
		end

		if table.isexist(data, "award") then
			local awards = PbProtocol.decodeArray(data["award"])
			local ret = CombatBO.addAwards(awards)
			UiUtil.showAwards(ret)
		end

		TacticsMO.pieces_ = {}
		if table.isexist(data, "tacticsSlice") then
			local tacticPieces = PbProtocol.decodeArray(data["tacticsSlice"]) --碎片
			for index=1,#tacticPieces do
				TacticsMO.pieces_[tacticPieces[index].v1] = tacticPieces[index].v2
			end
		end

		Notify.notify(LOCAL_TACTICS_UPDATE)
		UserBO.triggerFightCheck()
		if doneCallback then doneCallback(data) end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("UpgradeTactics",{keyId = keyId, consumeKeyId = consumeList, tacticsSlice = pieceList}))
end

--战术突破
-- keyId =1;//需要升级的战术
function TacticsBO.onTacticTp(doneCallback, keyId)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		local tactic = data.tactics
		TacticsMO.tactics_[tactic.keyId] = tactic
		UserMO.updateResources(PbProtocol.decodeArray(data.atom2))

		Notify.notify(LOCAL_TACTICS_UPDATE)
		if doneCallback then doneCallback() end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("TpTactics",{keyId = keyId}))
end

--战术进阶
-- required int32 keyId =1;//需要进阶的战术
-- function TacticsBO.onTacticAdvance(doneCallback, keyId)
	-- local function parseResult(name, data)
	-- 	Loading.getInstance():unshow()
		-- required Tactics tactics=1;//战术
		-- repeated Atom2 atom2 = 2;               //消耗后的剩余资源

		-- dump(data, "战术进阶-------------------")

		-- Notify.notify(LOCAL_TACTICS_UPDATE)
	-- 	if doneCallback then doneCallback() end
	-- end
	-- Loading.getInstance():show()
	-- SocketWrapper.wrapSend(parseResult, NetRequest.new("AdvancedTactics",{keyId = keyId}))
-- end

--战术合成
--tacticsId =1;//碎片ID
function TacticsBO.onTacticCompose(doneCallback, tacticsId)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		local tactic = data.tactics
		TacticsMO.tactics_[tactic.keyId] = tactic
		local stastAwards = {awards = {{kind = ITEM_KIND_TACTIC, id = tactic.tacticsId, count = 1}}}

		--更新碎片数量
		TacticsMO.pieces_ = {}
		local tacticPieces = PbProtocol.decodeArray(data["tacticsSlice"])
		if tacticPieces then
			for index=1,#tacticPieces do
				TacticsMO.pieces_[tacticPieces[index].v1] = tacticPieces[index].v2
			end
		end

		Notify.notify(LOCAL_TACTICS_UPDATE)
		if doneCallback then doneCallback(stastAwards) end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("ComposeTactics",{tacticsId = tacticsId}))
end

--战术阵型设置
-- index =1;//  --8套中的某一套
-- keyId =2;//Tactics keyid
function TacticsBO.setTacticForm(doneCallback, keyIds, index)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		TacticsMO.TacticForms_[data.index] = data --以服务端算的为准

		if doneCallback then doneCallback() end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("SetTacticsForm",{index = index, keyId = keyIds}))
end

--战术锁定/解锁
--keyId//需要升级的战术
function TacticsBO.onTacticLock(doneCallback, keyId)
	local function parseResult(name, data)
		Loading.getInstance():unshow()
		local tactic = data.tactics
		TacticsMO.tactics_[tactic.keyId] = tactic
		local state = tactic.bind
		Notify.notify(LOCAL_TACTICS_UPDATE)
		if doneCallback then doneCallback(state) end
	end
	Loading.getInstance():show()
	SocketWrapper.wrapSend(parseResult, NetRequest.new("BindTacticsForm",{keyId = keyId}))
end