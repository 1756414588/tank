--
-- Author: Your Name
-- Date: 2017-04-27 16:27:10
--
--材料工坊

MaterialBO = {}

function MaterialBO.updateInfo(data)
	if WeaponryBO.MaterialQueue and #WeaponryBO.MaterialQueue > 0 then
		local needUpdate = false
		for index=1,#WeaponryBO.MaterialQueue do
			if WeaponryBO.MaterialQueue[index].complete < WeaponryBO.MaterialQueue[index].period then
				needUpdate = true
			end
		end
		local function refresh()
			MaterialBO.updateLemb()
		end

		if MaterialMO.refreshHandler_ and needUpdate == false then
			scheduler.unscheduleGlobal(MaterialMO.refreshHandler_)
			MaterialMO.refreshHandler_ = nil
		end

		if not MaterialMO.refreshHandler_ and needUpdate then
			MaterialMO.refreshHandler_ = scheduler.scheduleGlobal(refresh, 60)  -- 每分钟执行一次
		end
	end
end

--材料生产
function MaterialBO.productLordEquipMat(doneCallback,quality,id)
	Loading.getInstance():show()
	local function parseProduct(name,data)
		Loading.getInstance():unshow()
		-- dump(data, "材料生产---------------------data")
		WeaponryBO.MaterialQueue = data.lemb
		MaterialBO.updateInfo()
		Notify.notify(LOCAL_MATERIAL_LEMB) --生产队列刷新
		if doneCallback then doneCallback(data) end
	end

	SocketWrapper.wrapSend(parseProduct, NetRequest.new("ProductLordEquipMat",{quality = quality,costId = id}))
end

--生产位购买
function MaterialBO.buyMateriaPos(doneCallback)
	Loading.getInstance():show()
	local function parseBuy(name,data)
		Loading.getInstance():unshow()
		-- dump(data, "生产位购买---------------------data")
		UserMO.updateResource(ITEM_KIND_COIN, data.gold)
		MaterialMO.buyCount_ = data.buyCount
		if doneCallback then doneCallback() end
	end

	SocketWrapper.wrapSend(parseBuy, NetRequest.new("BuyMaterialPro"))
end

--领取生产材料
function MaterialBO.awardMaterial(doneCallback,index)
	Loading.getInstance():show()
	local function parseBuy(name,data)
		Loading.getInstance():unshow()
		-- dump(data, "收取生产材料---------------------data")
		WeaponryBO.MaterialQueue = 	data.lemb
		MaterialBO.updateInfo()
		Notify.notify(LOCAL_MATERIAL_LEMB) --生产队列刷新
		if doneCallback then doneCallback(data) end
	end

	SocketWrapper.wrapSend(parseBuy, NetRequest.new("CollectLeqMaterial",{queue_idx = index}))
end

--刷新材料队列
function MaterialBO.updateLemb(doneCallback)
	Loading.getInstance():show()
	local function parseLembQueue(name,data)
		Loading.getInstance():unshow()
		-- dump(data, "获取材料生产状况---------------------data")
		WeaponryBO.MaterialQueue = data.lemb
		Notify.notify(LOCAL_MATERIAL_LEMB) --生产队列刷新
		MaterialBO.updateInfo()
		if doneCallback then doneCallback() end
	end
	SocketWrapper.wrapSend(parseLembQueue, NetRequest.new("GetLembQueue"))
end