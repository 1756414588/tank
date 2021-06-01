--
-- Author: Xiaohang
-- Date: 2016-09-28 17:00:26
-- 淬炼10次界面
local Dialog = require("app.dialog.Dialog")
local RefineTenDialog = class("RefineTenDialog", Dialog)
--times 淬炼次数
--tagNum 标签，仅用于显示文本淬炼次数
function RefineTenDialog:ctor(tag,part,times,tagNum)
	RefineTenDialog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(582, 834)})
	self.tag = tag
	self.part = part
	self.m_times = times
	self.m_tagNum = tagNum
	self:size(582,834)
end

function RefineTenDialog:onEnter()
	RefineTenDialog.super.onEnter(self)
	self:setTitle(CommonText[5015][self.m_tagNum])
	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(552, 804))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local bg = self:getBg()
	local infoBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(bg)
	infoBg:setPreferredSize(cc.size(510, 604))
	infoBg:setPosition(bg:width()/2, 150 + infoBg:height()/2)
	self.infoBg = infoBg

	local line = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_22.png"):addTo(infoBg)
	line:setPreferredSize(cc.size(510, line:getContentSize().height))
	line:setPosition(infoBg:getContentSize().width / 2,400)

	--淬炼方式
	local temp = display.newSprite(IMAGE_COMMON.."info_bg_12.png"):addTo(infoBg)
		:align(display.LEFT_CENTER,24,infoBg:getContentSize().height - 30)
	UiUtil.label(CommonText[5069]):alignTo(temp, 50)

	local index = PartMO.oldCheckIndex or 1
	self:onCheckedChanged(index)

	--自动保存
	UiUtil.label(CommonText[5016],26,cc.c3b(161,183,53))
		:addTo(infoBg):align(display.LEFT_CENTER,40,infoBg:height()-235)
	x,y,ey = 80,infoBg:height() - 300, 78
	self.ids = {}
	local partDB = PartMO.queryPartById(self.part.partId)
	local con = json.decode(partDB.s_attrCondition)
	local atts = {}
	for k,v in ipairs(self.part.attr) do
		local ex = nil
		if not self.part.saved then
			ex = v.newVal - v.val
		end
		atts[v.id] = {v.val,ex}
	end
	for k,v in ipairs(con) do
		local attId = v[1][1]
		if attId%2 == 0 then attId = attId - 1 end
		local name = string.format(CommonText[5017], AttributeMO.queryAttributeById(attId).desc)
		local check = CheckBox.new(nil, nil, handler(self, self.checkChoose)):addTo(infoBg,0,k)
			:pos(x, y-(k-1)*ey)
		check.id = v[1][1]
		local t = UiUtil.label(name):rightTo(check, 10)
		if (self.part.upLevel < v[2][1] or self.part.refitLevel < v[2][2]) and atts[v[1][1]] == nil then
			UiUtil.label("("..CommonText[929] ..")",nil,COLOR[6]):rightTo(t,50)
			check:setEnabled(false)
		end
	end

	UiUtil.button("btn_1_normal.png","btn_1_selected.png",nil,handler(self, self.ok),CommonText[5015][self.m_tagNum])
		:addTo(bg):pos(bg:width()/2,90)
end

function RefineTenDialog:onCheckedChanged(index)
	self.index = index
	local list2 = {1,3,12}
	local desc = UiUtil.label(CommonText[5070][index],nil,COLOR[list2[index]]):addTo(self.infoBg):pos(90,self.infoBg:height() - 85)
	local sb = PartMO.querySmeltById(index)
	local cost = json.decode(sb.cost)
	itemView = UiUtil.createItemView(cost[1],cost[2]):addTo(self.infoBg,0,99):pos(90,self.infoBg:height() - 145):scale(0.7)
	UiUtil.createItemDetailButton(itemView)
	local propDB = UserMO.getResourceData(cost[1], cost[2])
	local t = UiUtil.label(propDB.name,nil,COLOR[propDB.quality or 1])
		:addTo(itemView):align(display.LEFT_CENTER,itemView:width()/2 + 70, itemView:height()/2 + 20)
	t:scale(1/itemView:getScale())
	self.cost = cost[3]*self.m_times
	t = UiUtil.label(UiUtil.strNumSimplify(self.cost)):alignTo(t, -40, 1)
	t:scale(1/itemView:getScale())
	local own = UserMO.getResource(cost[1],cost[2])
	UiUtil.label("/"..UiUtil.strNumSimplify(own),nil,COLOR[own<cost[3]*10 and 6 or 2])
		:addTo(itemView):align(display.LEFT_CENTER, t:x() + t:width()*t:getScaleX(),t:y()):scale(1/itemView:getScale())
end

function RefineTenDialog:checkChoose(sender, isChecked)
	ManagerSound.playNormalButtonSound()
	if isChecked then
		self.ids[sender.id] = true
	else
		self.ids[sender.id] = nil
	end
end

function RefineTenDialog:ok()
	ManagerSound.playNormalButtonSound()
	local list = table.keys(self.ids)
	if UserMO.consumeConfirm and self.index > 1 then
		local CoinConfirmDialog = require("app.dialog.CoinConfirmDialog")
		CoinConfirmDialog.new(string.format(CommonText[5018][self.tag - 2],self.cost), function()
				PartBO.refineTenUp(handler(self, self.doResult),self.part, self.index, list, self.m_times, self.m_tagNum)
			end):push()
	else
		PartBO.refineTenUp(handler(self, self.doResult),self.part, self.index, list, self.m_times, self.m_tagNum)
	end
end

function RefineTenDialog:doResult(part,kind,attr,records,result,tag,tagNum)
	self:pop()
	require("app.dialog.RefineResultDialog").new(part,kind,attr,records,result,tag,tagNum):push()
end

function RefineTenDialog:onExit()
	RefineTenDialog.super.onExit(self)
end

return RefineTenDialog