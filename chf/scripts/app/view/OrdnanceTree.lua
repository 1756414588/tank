--
-- Author: Xiaohang
-- Date: 2016-05-04 11:08:42
--
local OrdnanceTree = class("OrdnanceTree",function ()
	return display.newNode()
end)

function OrdnanceTree:ctor(width,height,tankId)
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
	self:showTree()
end

function OrdnanceTree:showTree()
	local data = OrdnanceMO.getTankScience(self.tankId)
	self.node:removeAllChildren()
	table.sort(data,function(a,b)
			return a.id<b.id
		end)
	local temp = {}
	for k,v in ipairs(data) do
		temp[v.id] = v
	end
	local x,y,ex,ey = 90,self:height()-230,150,165
	local list = {}  --每一排的数据
	local s = {} --得到层级关系
	local p = {} --得到每个科技的子类列表
	local to = {} --临时记录从属关系
	for k,v in ipairs(data) do
		if not s[v.id] then
			s[v.id] = 1
			to[v.id] = v.p
		end
		if not s[v.p] or s[v.id] + 1 > s[v.p] then
			s[v.p] = s[v.id]+1
			if to[v.p] and s[v.p] >= s[to[v.p]] then
				s[to[v.p]] = s[v.p] + 1
			end
		end
		if not p[v.p] then
			p[v.p] = {}
		end
		table.insert(p[v.p], v.id)
	end
	for k,v in pairs(s) do
		if not list[v] then
			list[v] ={}
		end
		local t = temp[k] or {id=k}
		if p[t.p] then
			t.num = #p[t.p]
		end
		table.insert(list[v],t)
	end
	for k,v in ipairs(list) do
		table.sort(v,function(a,b)
				return a.id<b.id
			end)
	end
	--解析显示
	for k,v in ipairs(list) do
		for m,n in ipairs(v) do
			local t = OrdnanceMO.getImgById(n.id,self.tankId,OrdnanceMO.checkUnOpen(n.id))
			-- UiUtil.label(n.id,40):addTo(t):center()
			t = TouchButton.new(t, nil, nil, nil, handler(self, self.showDetail))
			if k == 1 then
				local tx,ty = x+(m-1)*ex,y
				t:addTo(self.node,0,n.id):pos(tx,ty)
			else
				local ty = y-(k-1)*ey
				local c = p[n.id]
				local tx = self.node:getChildByTag(c[1]):x()
				if #c > 1 then
					tx = (tx + self.node:getChildByTag(c[2]):x())/2
				end
				t:addTo(self.node,0,n.id):pos(tx,ty)
			end
		end
	end
	self:showLine(p)
end

function OrdnanceTree:showLine(p)
	self:showInfo()
	local node = self.node
	--垂直距离最近的放在第一位,然后水平距离从近到远
	for k,v in pairs(p) do
		table.sort(v,function(a,b)
				local pa,pb = self.node:getChildByTag(a),self.node:getChildByTag(b)
				if pa:y() == pb:y() then
					return pa:x() < pb:x()
				else
					return pa:y() < pb:y()
				end
			end)
	end
	for k,v in pairs(p) do
		local t = node:getChildByTag(k)
		local ey = node:getChildByTag(v[1]):y() - t:y()
		local ex = t:x() - node:getChildByTag(v[1]):x()
		if #v > 1 then
			local line = display.newSprite(IMAGE_COMMON.."line.jpg"):addTo(node)
			line:scaleY((ey - 102)/2/line:height())
			line:align(display.CENTER_BOTTOM, t:x(), t:y() + t:height()/2)
			--左边
			local line1 = display.newSprite(IMAGE_COMMON.."line.jpg"):addTo(node)
			line1:rotation(-90)
			line1:scaleY(ex/line1:height())
			line1:align(display.RIGHT_BOTTOM, t:x() - line:width()/2, t:y()+t:height()/2+line:height()*line:scaleY())
			line1 = display.newSprite(IMAGE_COMMON.."line.jpg"):addTo(node)
			line1:scaleY(line:getScaleY())
			line1:align(display.LEFT_BOTTOM, t:x() - line:width()/2 - ex, t:y()+t:height()/2+line:height()*line:scaleY())
			--右边
			ex = node:getChildByTag(v[#v]):x() - t:x()
			local line1 = display.newSprite(IMAGE_COMMON.."line.jpg"):addTo(node)
			line1:rotation(90)
			line1:scaleY(ex/line1:height())
			line1:align(display.LEFT_BOTTOM, t:x() + line:width()/2, t:y()+t:height()/2+line:height()*line:scaleY())
			for i=2,#v do
				line1 = display.newSprite(IMAGE_COMMON.."line.jpg"):addTo(node)
				line1:scaleY((node:getChildByTag(v[i]):y()-51-(t:y()+t:height()/2+line:height()*line:scaleY()))/line1:height())
				line1:align(display.RIGHT_BOTTOM, node:getChildByTag(v[i]):x() + line:width()/2, t:y()+t:height()/2+line:height()*line:scaleY())
			end
		else
			local line = display.newSprite(IMAGE_COMMON.."line.jpg"):addTo(node)
			line:scaleY((ey - 102)/line:height())
			line:pos(t:x(),t:y()+ey/2)
		end
		display.newSprite(IMAGE_COMMON.."dot.png"):addTo(node)
			:align(display.CENTER_BOTTOM, t:x(), t:y() + t:height()/2)
	end
end

function OrdnanceTree:showInfo()
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

function OrdnanceTree:showDetail(tag,sender)
	require("app.dialog.StudyDialog").new(sender:getTag(),self.tankId, handler(self,self.showTree)):push()
end

return OrdnanceTree