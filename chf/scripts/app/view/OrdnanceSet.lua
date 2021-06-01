--
-- Author: Xiaohang
-- Date: 2016-05-05 15:20:13
--
--军工科技装配
local OrdnanceSet = class("OrdnanceSet",function ()
	return display.newNode()
end)

function OrdnanceSet:ctor(width,height,tankId)
	self:size(width,height)
	local t = UiUtil.sprite9("info_bg_11.png",130,40,1,1,596,156)
		:addTo(self):align(display.CENTER_TOP, width/2, height-20)
	local title = display.newSprite(IMAGE_COMMON .. "info_bg_28.png")
		:addTo(t):pos(t:width()/2,t:height()-10)
	--坦克信息
	local tankDB = TankMO.queryTankById(tankId)
	self.title = UiUtil.label(""):addTo(title):center()

	self.tankId = tankId
	-- 名称
	UiUtil.label(tankDB.name,nil,COLOR[tankDB.grade]):addTo(t):align(display.LEFT_CENTER, 172,107)
	--图片
	local sprite = UiUtil.createItemSprite(ITEM_KIND_TANK, tankDB.tankId):addTo(t)
		:pos(98,77)
	-- 研发点数
	self.point = UiUtil.label("",nil,cc.c3b(140, 140, 140)):addTo(t):align(display.LEFT_CENTER, 172, 77)
	self.setNum = UiUtil.label("",nil,cc.c3b(140, 140, 140)):addTo(t):align(display.LEFT_CENTER, 172, 49)
	--详情
	UiUtil.button("btn_detail_normal.png", "btn_detail_selected.png", nil, function()
			ManagerSound.playNormalButtonSound()
			require("app.dialog.DetailTankDialog").new(tankId):push() 
		end):addTo(t):pos(535,70)
	self.node = display.newNode():size(width,height)
		:addTo(self)
	--科技树
	self:showSet()
end

function OrdnanceSet:showSet()
	self:showInfo()
	self.node:removeAllChildren()
	local mo = OrdnanceMO.queryTankById(self.tankId)
	local data,id = json.decode(mo.gridStatus),mo.productScienceId
	local x,y,ex,ey = 160,self:height()-230,self:width()-360,150
	for k,v in ipairs(data) do
		local grid = OrdnanceBO.getGridInfo(self.tankId,k)
		local tx,ty = x+(k-1)%2*ex,y-math.floor((k-1)/2)*ey
		local img = nil
		local des = ""
		local c = COLOR[1]
		local state =grid.status
		local sid = grid.militaryScienceId
		if grid.militaryScienceId > 0  and state ~= 3 then
			local so = OrdnanceBO.queryScienceById(sid)
			img = OrdnanceMO.getImgById(grid.militaryScienceId,self.tankId)
			des = OrdnanceMO.getNameById(grid.militaryScienceId) .."Lv." ..so.level
			for k,v in ipairs(OrdnanceMO.getAttr(sid,so.level)) do
				UiUtil.label(v, 18):addTo(self.node):align(display.LEFT_TOP, tx+60, ty+42-(k-1)*22)
			end
		else
			-- 0已解锁1未解锁2未开放3效率
			if state == 0  then
				img = display.newSprite(IMAGE_COMMON .. "item_fame_1.png")
				display.newSprite(IMAGE_COMMON.."icon_plus.png"):addTo(img):center()
				des = CommonText[928]
			elseif state == 1 or state == 2 then
				img = display.newSprite(IMAGE_COMMON .. "item_fame_1.png")
				display.newSprite(IMAGE_COMMON.."icon_lock_1.png"):addTo(img):center()
				des = CommonText[20000]
				c = cc.c3b(140, 140, 140)
				if state == 1 then
					des = CommonText[929]
					c = COLOR[6]
				end
			elseif state == 3 then
				local data = OrdnanceBO.queryScienceById(id)
				img = OrdnanceMO.getImgById(id,self.tankId,OrdnanceMO.checkUnOpen(id))
				des = OrdnanceMO.getNameById(id) .."Lv." ..data.level
				if data.level == 0 then
					UiUtil.label(CommonText[20001], 18, COLOR[2], cc.size(60,0), ui.TEXT_ALIGN_LEFT)
						:addTo(self.node):align(display.LEFT_TOP, tx+60, ty+42)
				else
					for k,v in ipairs(OrdnanceMO.getAttr(sid,data.level)) do
						UiUtil.label(v, 18):addTo(self.node):align(display.LEFT_TOP, tx+60, ty+42-(k-1)*22)
					end
				end
			end
		end
		img = TouchButton.new(img, nil, nil, nil, handler(self, self.showDetail)):addTo(self.node):pos(tx,ty)
		img.data = {id = sid, pos = k, state = state}
		UiUtil.label(des,nil,c):addTo(img):pos(img:width()/2,-12)
	end
end

function OrdnanceSet:showDetail(tag,sender)
	local data = sender.data
	if data.state == 3 then
		return
	elseif data.state == 1 then
		require("app.dialog.StudyLock").new(self.tankId,data,handler(self, self.showSet)):push()
	elseif data.state == 0 or data.id>0 then
		require("app.dialog.StudySet").new(self.tankId,data,handler(self, self.showSet)):push()
	end
end

function OrdnanceSet:showInfo()
	local tankDB = TankMO.queryTankById(self.tankId)
	local mo = OrdnanceMO.queryTankById(self.tankId)
	local list = OrdnanceMO.getList()
	local kind = tankDB.canBuild == 0 and tankDB.type or tankDB.type + 4
	local de = 0
	local count = 0
	for k,v in pairs(list[kind].list) do
		count = count + v.developPoint
		de = de + OrdnanceBO.getProgress(v.tankId)
	end
	self.title:setString(CommonText[920] ..de .."/"..count)
	self.point:setString(CommonText[921] ..OrdnanceBO.getProgress(self.tankId) .."/"..mo.developPoint)
	local count = OrdnanceBO.getEquipNum(self.tankId) .."/" ..mo.assembleNum
	self.setNum:setString(CommonText[922] ..count)
end

return OrdnanceSet