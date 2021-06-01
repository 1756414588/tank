-- 计算平均位置 以中心点为准
local function CalculateX( all, index, width, dexScaleOfWidth)
	-- body
	local c = all + 1
	local q = c / 2
	local sw = width * dexScaleOfWidth
	local w = q * sw
	return index * sw - w
end

----------------------------------------------------------
--						奖励显示						--
----------------------------------------------------------
local Dialog = require("app.dialog.Dialog")
local ShowDilog = class("ShowDilog", Dialog)

function ShowDilog:ctor(dataList, text, title, type)
	ShowDilog.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588, 330)})
	self.Showdata = dataList
	self.title = title or CommonText[1057][2]
	self.text = text or ""
	self.type = type or 0
end

function ShowDilog:onEnter()
	ShowDilog.super.onEnter(self)

	self:setOutOfBgClose(true)
	self:hasCloseButton(true)
	self:setTitle(self.title)

	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(558, 300))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)

	local lb_time_title = ui.newTTFLabel({text = self.text, font = G_FONT, size = FONT_SIZE_SMALL, align = ui.TEXT_ALIGN_CENTER, color = cc.c3b(18, 255, 3)}):addTo(self:getBg())
	lb_time_title:setPosition(self:getBg():getContentSize().width / 2 , self:getBg():getContentSize().height * 0.5 + 70)


	local centerX = self:getBg():getContentSize().width * 0.5
	local size = #self.Showdata

	for index = 1 , size do
		local _db = self.Showdata[index]
		-- dump(_db,"ShowDilog " .. index)
		
		local kind , id ,count = 0,0,0
		if self.type == 0 then
			kind , id ,count =  _db[1], _db[2], _db[3]
		else
			kind , id ,count =  _db.kind, _db.id, _db.count
		end
		

		-- 元素
		local item = UiUtil.createItemView(kind,id,{count = count}):addTo(self:getBg())
		item:setPosition(centerX + CalculateX(size, index,  item:getContentSize().width , 1.2) ,self:getBg():getContentSize().height * 0.5 - 10)
		UiUtil.createItemDetailButton(item)

		local namedata = UserMO.getResourceData(kind,id)
		local name = UiUtil.label(namedata.name2,FONT_SIZE_SMALL,COLOR[1]):addTo(self:getBg())
		name:setPosition(item:getPositionX() , item:getPositionY() - item:getContentSize().height * 0.5 - name:getContentSize().height * 0.5 - 10)

	end
end

function ShowDilog:onExit()
	ShowDilog.super.onExit(self)
	-- body
end

return ShowDilog