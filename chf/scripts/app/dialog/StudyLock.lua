--
-- Author: Xiaohang
-- Date: 2016-05-05 17:35:07
--
-- 军工科技解锁
local Dialog = require("app.dialog.Dialog")
local StudyLock = class("StudyLock", Dialog)

function StudyLock:ctor(id,data,rhand)
	StudyLock.super.ctor(self, IMAGE_COMMON .. "bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(582, 834)})
	self:size(582,834)
	self.id = id
	self.data = data
	self.rhand = rhand
end

function StudyLock:onEnter()
	StudyLock.super.onEnter(self)
	self:setTitle(CommonText[902][2])
	local btm = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(), -1)
	btm:setPreferredSize(cc.size(552, 804))
	btm:setPosition(self:getBg():getContentSize().width / 2, self:getBg():getContentSize().height / 2 - 6)
	self:showUI()
end

function StudyLock:showUI()
	local attrBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(self:getBg())
	attrBg:setPreferredSize(cc.size(self:getBg():width() - 80, 132))
	attrBg:setPosition(self:getBg():width() / 2, 695)
	local img = display.newSprite(IMAGE_COMMON .. "item_fame_1.png"):addTo(attrBg):pos(75,attrBg:height()/2)
	display.newSprite(IMAGE_COMMON.."icon_lock_1.png"):addTo(img):center()
	local tankDB = TankMO.queryTankById(self.id)
	local mo = OrdnanceMO.queryTankById(self.id)
	--名字
	UiUtil.label(CommonText[932]):addTo(attrBg):align(display.LEFT_CENTER, 134, 92)
	UiUtil.label(CommonText[933] ..tankDB.name)
		:addTo(attrBg):align(display.LEFT_CENTER, 134, 42)
	--消耗信息
	local bg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_15.png"):addTo(self:getBg())
	bg:setPreferredSize(cc.size(self:getBg():width() - 80, 545))
	bg:setPosition(self:getBg():width() / 2, 350)
	local h = bg:height()
	display.newSprite(IMAGE_COMMON .."info_bg_12.png"):addTo(bg):align(display.LEFT_CENTER, 20, h-33)
	UiUtil.label(CommonText[934]):addTo(bg):align(display.LEFT_CENTER, 65, h-33)
	local index = 1
	local data = json.decode(mo.gridStatus)
	for k, v in ipairs(data) do
		local grid = OrdnanceBO.getGridInfo(self.id,k)
		if v[1] == 1 and grid.status ~= 1 then
			index = index + 1
		end
	end
	local test = json.decode(mo.unLockConsume)
	local x,ex = 40,105
	local n = 0
	for k,v in ipairs(test) do
		if v[1] == index then
			local t = UiUtil.createItemView(v[2], v[3],{count = v[4]}):addTo(bg):align(display.LEFT_CENTER, x+n*ex, h-106):scale(0.9)
			local propDB = UserMO.getResourceData(v[2], v[3])
			UiUtil.label(propDB.name, nil, UserMO.getResource(v[2],v[3]) < v[4] and COLOR[6] or COLOR[1]):addTo(bg):pos(t:x()+t:width()/2,t:y()-60)
			n = n + 1
		end
	end
	-- 确定
	UiUtil.button("btn_1_normal.png", "btn_1_selected.png", nil, handler(self,self.unlock), CommonText[902][2])
		:addTo(self:getBg()):pos(self:getBg():width()/2, 25)
end

function StudyLock:onExit()
	StudyLock.super.onExit(self)
end

function StudyLock:unlock(tag, sender)
	ManagerSound.playNormalButtonSound()
	Loading.getInstance():show()
	OrdnanceBO.UnLockMilitaryGrid(function()
			Loading.getInstance():unshow()
			Toast.show(CommonText[20003])
			self.rhand()
			self:pop()
		end,self.id)
end

return StudyLock
