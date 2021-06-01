--
-- Author: Xiaohang
-- Date: 2016-05-19 10:01:25
-- 总决赛
-------------------------------------------------------
local CrossFinal = class("CrossFinal",function ()
	return display.newNode()
end)
local LINE_W = 76
function CrossFinal:ctor(width,height,type)
	self:size(width,height)
	self.type = type
	local list = CrossMO.getOutTime(1)
	local t = UiUtil.label(CommonText[30024][1],nil,COLOR[12]):addTo(self):pos(116,height-22)	
	UiUtil.label(list[1]):addTo(self):alignTo(t, -20, 1)
	t = UiUtil.label(CommonText[30024][2],nil,COLOR[12]):addTo(self):alignTo(t,206)
	UiUtil.label(list[2]):addTo(self):alignTo(t, -20, 1)
	t = UiUtil.label(CommonText[30024][3],nil,COLOR[12]):addTo(self):alignTo(t,206)
	UiUtil.label(list[2]):addTo(self):alignTo(t, -20, 1)

	self.data = {}
	CrossBO.getFinalInfo(self.type,function(data)
			self.data = data
			self:show(self:width(),self:height())
		end)
end


function CrossFinal:show(width,height)
	local x,y,ey = 103,height-92,76
	local pos1 = {}
	for i=0,5 do
		local group = math.floor(i/2)+1
		if i >= 4 then
			group = 4
		end
		local ty = y - i*ey
		local index = i%2 + 1
		local t = UiUtil.button("an.png", "an.png", nil, handler(self, self.lookInfo))
			:addTo(self):pos(x,ty)
		local data = self.data[group]
		local info = nil
		if data then info = data["c"..index] end
		if info then info = PbProtocol.decodeRecord(info) end
		if info then
			t.info = info
			UiUtil.label(info.nick,20):addTo(t):pos(t:width()/2,36)
			UiUtil.label(info.serverName,20):addTo(t):pos(t:width()/2,16)
		end
		local l = display.newSprite(IMAGE_COMMON.."line.jpg")
			:addTo(self):align(display.CENTER_BOTTOM,t:x()+t:width()/2,t:y())
		l:rotation(90)
		l:scaleTY(LINE_W)
		self:checkFalse(index == 1,data,l)
		l = display.newSprite(IMAGE_COMMON.."dot.png")
			:addTo(self):align(display.CENTER_BOTTOM,t:x()+t:width()/2,t:y())
		l:rotation(90)
		l = display.newSprite(IMAGE_COMMON.."line.jpg"):scaleTY(ey/2)
			:addTo(self):align(display.RIGHT_BOTTOM, t:x()+t:width()/2+LINE_W, t:y())
		if i%2 == 0 then
			l:scaleY(-1*l:getScaleY())
			table.insert(pos1,cc.p(l:x(),l:y()-ey/2))
		end
		self:checkFalse(index == 1,data,l)
	end
	ey = 2*ey
	local TE = CommonText[30043]
	for k,v in ipairs(pos1) do
		local l = display.newSprite(IMAGE_COMMON.."line.jpg")
			:addTo(self):align(display.CENTER_BOTTOM,v.x,v.y):scaleTY(LINE_W)
		l:rotation(90)
		local item = nil
		if k == 3 then
			-- self:checkFalse(4,self.data[4],l)
			l = display.newSprite(IMAGE_COMMON.."line.jpg")
				:addTo(self):align(display.CENTER_BOTTOM,v.x+LINE_W,v.y):scaleTY(LINE_W)
			l:rotation(90)

			local state = self:checkData(4)
			if state == 2 then
				local t = UiUtil.button("back_normal.png", "back_selected.png", nil, handler(self, self.PlayBack))
					:addTo(self):pos(v.x,v.y)
				t.group = 4
				t.name = CommonText[30024][3]
			end

			item = display.newSprite(IMAGE_COMMON.."an.png")
				:addTo(self):align(display.LEFT_CENTER, v.x+LINE_W*2, v.y)
			if state == 2 then
				local index = 1
				if self.data[4].win == 0 then index = 2 end
				local info = PbProtocol.decodeRecord(self.data[4]["c"..index])
				UiUtil.label(info.nick,20):addTo(item):pos(item:width()/2,36)
				UiUtil.label(info.serverName,20):addTo(item):pos(item:width()/2,16)
			end
			local t = display.newSprite(IMAGE_COMMON.."dot.png")
				:addTo(self):align(display.CENTER_BOTTOM,v.x+LINE_W*2, v.y)
			t:rotation(-90)
		else
			local state = self:checkData(k)
			if state == 2 then
				local t = UiUtil.button("back_normal.png", "back_selected.png", nil, handler(self, self.PlayBack))
					:addTo(self):pos(v.x,v.y)
				t.group = k
				t.name = CommonText[30024][1]
			end
			l = display.newSprite(IMAGE_COMMON.."line.jpg"):scaleTY(ey/2)
				:addTo(self):align(display.RIGHT_BOTTOM, v.x+LINE_W,v.y)
			local ty = v.y + 25
			if k%2 == 1 then
				l:scaleY(-1*l:getScaleY())
				ty = v.y - 25
			end
			--冠军
			l = display.newSprite(IMAGE_COMMON.."line.jpg")
				:addTo(self):align(display.CENTER_BOTTOM,v.x+LINE_W,ty):scaleTY(LINE_W)
			l:rotation(90)
			local state = self:checkData(3)
			if k%2 == 1 then
				if state == 2 then
					local t = UiUtil.button("back_normal.png", "back_selected.png", nil, handler(self, self.PlayBack))
						:addTo(self,1):pos(v.x+LINE_W,ty-50)
					t.group = 3
					t.name = CommonText[30024][2]
				end
			end

			item = display.newSprite(IMAGE_COMMON.."an.png")
				:addTo(self):align(display.LEFT_CENTER, v.x+LINE_W*2, ty)
			if state == 2 then
				local flag = {1,2}
				if self.data[3].win == 0 then
					flag = {2,1}
				end
				local info = PbProtocol.decodeRecord(self.data[3]["c"..flag[k]])
				if info then
					UiUtil.label(info.nick,20):addTo(item):pos(item:width()/2,36)
					UiUtil.label(info.serverName,20):addTo(item):pos(item:width()/2,16)
				end
			end
			local t = display.newSprite(IMAGE_COMMON.."dot.png")
				:addTo(self):align(display.CENTER_BOTTOM,v.x+LINE_W*2, ty)
			t:rotation(-90)
		end
		UiUtil.label(TE[k],24,COLOR[12]):addTo(item):pos(item:width()/2,70)
	end
end

function CrossFinal:lookInfo(tag,sender)
	if sender.info then
		require("app.dialog.CrossPlayer").new(sender.info):push()
	end
end

function CrossFinal:PlayBack(tag,sender)
	require("app.dialog.CrossPlayback").new(self.data[sender.group],sender.name):push()
end


--检查失败线条
function CrossFinal:checkFalse(isUp,data,l)
	if not data then return end
	if data.win ~= -1 then
		if isUp and data.win == 0 then
			l:setOpacity(30)
			return true
		elseif not isUp and data.win == 1 then
			l:setOpacity(30)
			return true
		end
	end
end

--检查数据
function CrossFinal:checkData(group)
	if self.data[group] then
		if table.isexist(self.data[group],"c1") or table.isexist(self.data[group],"c2") then 
			if self.data[group].win == -1 then --未战斗
				return 1
			end 
			return 2
		end
	end
end

return CrossFinal