--
-- Author: Xiaohang
-- Date: 2016-09-28 18:52:27
--
local ContentTableView = class("ContentTableView", TableView)

function ContentTableView:ctor(size,part,tag,max)
	ContentTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.size = size
	self.m_cellSize = cc.size(size.width, 180)
	self.part = part
	self.tag = tag
	self.max = self.tag + 1
	self.awardIsshow = false
end

function ContentTableView:createCellAtIndex(cell, index)
	ContentTableView.super.createCellAtIndex(self, cell, index)
	local sizes = table.getn(self.m_activityList[index].result.attrs)
	if index ~= self.max then
		self.m_cellSize = cc.size(self.m_cellSize.width, 55 + sizes * 25 + 20)
	else
		self.m_cellSize = cc.size(self.m_cellSize.width, 55 + sizes * 25 + 20 + #self.multiples * 25 + 20)
	end
	local data = self.m_activityList[index]
	local t = display.newSprite(IMAGE_COMMON .."info_bg_12.png"):addTo(cell):align(display.LEFT_TOP, 20, self.m_cellSize.height -12)
	local str = CommonText[5021]
	if data.index <= self.tag then
		str = string.format(CommonText[5020],data.index)
	end
	local t = UiUtil.label(str):addTo(t):align(display.LEFT_CENTER, 32, t:height()/2)
	if data.result.save then
		UiUtil.label("(" ..CommonText[309] ..")",nil,COLOR[6]):rightTo(t)
	end

	local list = data.result.attrs
	local partCrit = data.result.crit --key 为暴击倍数,value是增加的经验
	local x,y,ey = 36,self.m_cellSize.height - 80 ,25
	local maxList = PartMO.getRefineMax(self.part,1)
	local lastY = 0
	for k,v in ipairs(list) do
		local attId = v.id
		if attId%2 == 0 then attId = attId - 1 end
		local name = AttributeMO.queryAttributeById(attId).desc .. CommonText[176] ..":"
		local ty = y-(k-1)*ey
		name = UiUtil.label(name):addTo(cell):align(display.LEFT_CENTER,x,ty)
		--如果有经验暴击，则显示经验暴击
		if partCrit.key and partCrit.key > 1 then
			local critSp = display.newSprite(IMAGE_COMMON.."refine_crit_"..partCrit.key..".png"):addTo(cell)
			critSp:setPosition(self.m_cellSize.width - critSp:width() / 2, self.m_cellSize.height -32)
			critSp:setScale(0.6)
		end
		lastY  = ty
		local flag = v.newVal - v.val
		local tag = flag >= 0 and "icon_arrow_up.png" or "icon_arrow_down.png"
		tag = display.newSprite(IMAGE_COMMON..tag):alignTo(name,250)
		local ao = AttributeBO.getAttributeData(v.id,v.val,2)
		local t = UiUtil.label(ao.strValue,nil,COLOR[2]):alignTo(name,100)
		if maxList[v.id] and maxList[v.id] <= v.val then
			UiUtil.label("(MAX)", nil, COLOR[12]):rightTo(t)
		end
		local value = math.abs(v.newVal - v.val)
		if data.index == self.max then
			if flag == 0 then
				tag:rotation(90)
				tag:y(tag:y()+8)
			elseif flag > 0 then
				-- tag:rotation(90)
				-- tag:y(tag:y()+8)
			else
				-- tag:rotation(-90)
				-- tag:y(tag:y()-8)
				tag:y(tag:y())
			end
			value = v.newVal
		end
		ao = AttributeBO.getAttributeData(v.id,value,2)
		UiUtil.label(ao.strValue,nil,COLOR[flag >= 0 and 2 or 6]):rightTo(name, 180)
	end
	--如果有淬炼暴击
	if self.multiples and #self.multiples > 1 and index == self.max then --11 or index == 101 then
		local index = 1
		local temp = {}
		for i,v in pairs(self.multiples) do
			table.insert(temp,i)
		end
		table.sort(temp)
		for k,v in ipairs(temp) do
			if self.multiples[v] > 0 then
				local x,y,ey = 36,self.m_cellSize.height - 80 - sizes * 25 ,25
				local critTimes = UiUtil.label(string.format(CommonText[5026],v)):addTo(cell):align(display.LEFT_CENTER,x, y-(index-1)*ey)
				local times = UiUtil.label(self.multiples[v],nil,COLOR[2]):alignTo(critTimes,120)
				index = index + 1
			end
		end
	end

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(cell)
	line:setPreferredSize(cc.size(self.m_cellSize.width - 10, line:getContentSize().height))
	line:setPosition(self.m_cellSize.width / 2, 0)
	return cell
end

function ContentTableView:numberOfCells()
	return #self.m_activityList
end

function ContentTableView:cellSizeForIndex(index)
	local sizes = table.getn(self.m_activityList[index].result.attrs)
	if index ~= self.max then
		self.m_cellSize = cc.size(self.m_cellSize.width, 55 + sizes * 25 + 20)
	else
		self.m_cellSize = cc.size(self.m_cellSize.width, 55 + sizes * 25 + 20 + #self.multiples * 25 + 20)
	end
	return self.m_cellSize
end

function ContentTableView:updateUI(data)
	self.m_activityList = data
	self:reloadData()
end

function ContentTableView:getMultiple(data)
	self.multiples = data
end

----------------------------------------------------------------
-- 淬炼10次界面
local Dialog = require("app.dialog.Dialog")
local RefineResultDialog = class("RefineResultDialog", Dialog)
function RefineResultDialog:ctor(part,kind,attr,records,result,tag,tagNum)
	RefineResultDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(582, 834)})
	self:size(582,834)
	self.part = part
	self.kind = kind
	self.attr = attr
	self.records = records
	self.result = result
	self.tag = tag
	self.tagNum = tagNum
end

function RefineResultDialog:onEnter()
	RefineResultDialog.super.onEnter(self)

	self:setTitle(CommonText[5015][self.tagNum])
	-- self:getCloseButton():setEnabled(false)
	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(552, 804))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local bg = self:getBg()
	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(bg)
	infoBg:setPreferredSize(cc.size(510, 604))
	infoBg:setPosition(bg:width()/2, 150 + infoBg:height()/2)
	self.infoBg = infoBg

	local view = ContentTableView.new(cc.size(infoBg:width(),infoBg:height()-6),self.part,self.tag)
		:addTo(infoBg):pos(0,3)
	self.view = view
	self:doResult()

	local activity = ActivityCenterBO.getActivityById(ACTIVITY_ID_REFINE_MASTER)
	if activity and activity.open == false then --淬炼大师活动期间退出按钮换成去寻宝按钮
		UiUtil.button("btn_2_normal.png","btn_2_selected.png",nil,function ()
			ManagerSound.playNormalButtonSound()
			UserBO.triggerFightCheck()
			Notify.notify(LOCLA_PART_EVENT)
			Notify.notify(LOCAL_COMPONENT_REFRESH)
			if self.awardIsshow then
				self:pop()
				UiDirector.popMakeUiTop("ComponentView")
				require("app.view.ActivityRefineMasterView").new(activity):push()
			else
				self:pop()
				UiUtil.showAwards(self.part.statsAward)
				UiDirector.popMakeUiTop("ComponentView")
				require("app.view.ActivityRefineMasterView").new(activity):push()
			end
		end,CommonText[1022])
			:addTo(bg):pos(140,90)
	else
		UiUtil.button("btn_2_normal.png","btn_2_selected.png",nil,handler(self, self.quit),CommonText[144])
				:addTo(bg):pos(140,90)
	end
	self.okBtn = UiUtil.button("btn_5_normal.png","btn_5_selected.png",nil,handler(self, self.ok),CommonText[5019])
		:addTo(bg,0,1):pos(bg:width()-140,90)
end

function RefineResultDialog:doResult()
	local data = self:getData()
	local multiple = self:getCritTimes()
	local index = 1
	local time = self.tag
	local function show()
		if index <= time then
			self.view:updateUI({data[index]})
			index = index + 1
			self:performWithDelay(show, 1)
		elseif index == #data then
			self.view:updateUI(data)
			self.view:setContentOffset(cc.p(0, 0))
			self.okBtn:setTag(2)
			--淬炼大师活动期间显示获得到的奖励
			if self.part.statsAward then
				self.awardIsshow = true
				UiUtil.showAwards(self.part.statsAward)
			end
			self.okBtn:setLabel(CommonText[5022])
		end
	end
	self.view:getMultiple(multiple)
	show()
end

function RefineResultDialog:getData()
	local data = {}
	for k,v in ipairs(self.records) do
		local temp = {index = k,result = v}
		table.insert(data,temp)
	end
	table.insert(data,{index = #data + 1,result = self.result})
	return data
end

--获取淬炼暴击X的次数
function RefineResultDialog:getCritTimes()
	local multiple = {}
	for k,v in ipairs(self.records) do
		if not multiple[v.crit.key] then
			multiple[v.crit.key] = 0
		end
		if v.crit.key > 1 then
			multiple[v.crit.key] = multiple[v.crit.key] + 1
		end
	end
	return multiple
end

function RefineResultDialog:quit(sender, isChecked)
	ManagerSound.playNormalButtonSound()
	UserBO.triggerFightCheck()
	Notify.notify(LOCLA_PART_EVENT)
	Notify.notify(LOCAL_COMPONENT_REFRESH)
	self:pop()
end

function RefineResultDialog:ok(tag, sender)
	ManagerSound.playNormalButtonSound()
	if tag == 1 then
		self:stopAllActions()
		self.view:updateUI(self:getData())
		self.view:setContentOffset(cc.p(0, 0))
		sender:setTag(2)
		--淬炼大师活动期间显示获得到的奖励
		if self.part.statsAward then
			self.awardIsshow = true
			UiUtil.showAwards(self.part.statsAward)
		end
		sender:setLabel(CommonText[5022])
	else
		local sb = PartMO.querySmeltById(self.kind)
		local cost = json.decode(sb.cost)
		self.cost = cost[3]*self.tag

		if UserMO.consumeConfirm and self.kind > 1 then
			local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
			CoinConfirmDialog.new(string.format(CommonText[5071],self.cost,CommonText[5015][self.tagNum]), function()
					PartBO.refineTenUp(function(part,kind,attr,records,result,tag,tagNum)
							self:pop()
							require("app.dialog.RefineResultDialog").new(part,kind,attr,records,result,tag,tagNum):push()
						end,self.part, self.kind, self.attr, self.tag,self.tagNum)
				end):push()
		else
			PartBO.refineTenUp(function(part,kind,attr,records,result,tag,tagNum)
					self:pop()
					require("app.dialog.RefineResultDialog").new(part,kind,attr,records,result,tag,tagNum):push()
				end,self.part, self.kind, self.attr, self.tag,self.tagNum)
		end
	end
end

function RefineResultDialog:CloseAndCallback()
	UserBO.triggerFightCheck()
	Notify.notify(LOCLA_PART_EVENT)
	Notify.notify(LOCAL_COMPONENT_REFRESH)
end

function RefineResultDialog:onExit()
	RefineResultDialog.super.onExit(self)
end

return RefineResultDialog