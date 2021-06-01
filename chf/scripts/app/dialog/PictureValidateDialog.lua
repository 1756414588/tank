local COL_NUM = 3

local PictureValidateTableView = class("PictureValidateTableView",TableView)

function PictureValidateTableView:ctor(size)
	PictureValidateTableView.super.ctor(self, size, SCROLL_DIRECTION_VERTICAL)
	self.m_cellSize = cc.size(size.width,160)
	gdump(self.m_pictures)
	self.m_chosenData = {}
	self.m_curChoseIndex = 0
end

function PictureValidateTableView:numberOfCells()
	return math.ceil(#PictureValidateBO.validatePic/COL_NUM)
end

function PictureValidateTableView:cellSizeForIndex(index)
	return self.m_cellSize
end

function PictureValidateTableView:createCellAtIndex(cell,index)
	PictureValidateTableView.super.createCellAtIndex(self, cell, index)

	local t = PictureValidateBO.validatePic
	self.m_pictures = PictureValidateMO.getPicNameById(t)

	for numIndex = 1, COL_NUM do
		local posIndex = (index - 1) * COL_NUM + numIndex
		if posIndex <= #self.m_pictures then
			local sprite = display.newScale9Sprite(IMAGE_COMMON.."btn_head_normal.png")
			sprite:setPreferredSize(cc.size(150, 150))
			local btn = CellTouchButton.new(sprite,nil, nil, nil, handler(self,self.onChosenCallback))
			btn.isChosen = false
			--btn.id = self.m_pictures[posIndex]
			btn.posIndex = posIndex
			cell:addButton(btn, 10 + (numIndex - 0.5) * 150, self.m_cellSize.height / 2)

			local picture = self.m_pictures[posIndex]
			gprint(picture)
			local spritePic = display.newScale9Sprite(picture):addTo(btn)
			spritePic:setCapInsets(cc.rect(0,0,spritePic:getContentSize().width,spritePic:getContentSize().height))
			spritePic:setContentSize(cc.size(100,110))
			spritePic:setPosition(btn:getContentSize().width / 2, btn:getContentSize().height / 2 + 4)
		end
	end

	return cell
end

function PictureValidateTableView:onChosenCallback(tag,sender)
	if sender.isChosen == false then 
		sender.isChosen = true 
		self:showChosenEffect(sender)
		table.insert(self.m_chosenData,sender.posIndex)
		gdump(self.m_chosenData,"插入元素后输出")
	else
		sender.isChosen = false
		self:showChosenEffect(sender)
		gprint(sender.isChosen)
		gprint(sender.posIndex)
		for i,v in ipairs(self.m_chosenData) do
			if v == sender.posIndex then
				table.remove(self.m_chosenData,i)
			end
		end
		gdump(self.m_chosenData,"删除元素后输出")
	end
end

function PictureValidateTableView:showChosenEffect(button)
	if button.isChosen == true then
		button.chosenFrame = display.newScale9Sprite(IMAGE_COMMON .. "chose_5.png")  --效果圖片
		button.chosenFrame:setContentSize(cc.size(button:getContentSize().width,button:getContentSize().height))
		button.chosenFrame:setAnchorPoint(0,0)
		button.chosenFrame:addTo(button)
		button.chosenSprite = display.newSprite(IMAGE_COMMON.."btn_7_checked.png")
		button.chosenSprite:addTo(button)
		button.chosenSprite:setPosition(button:getContentSize().width * 3 / 4, button:getContentSize().height / 4)
	else
		button.chosenFrame:removeSelf()
		button.chosenSprite:removeSelf()
	end
end

function PictureValidateTableView:getChosenPicture()
	return self.m_chosenData
end


------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------

local Dialog = require("app.dialog.Dialog")
local PictureValidateDialog = class("PictureValidateDialog",Dialog)

function PictureValidateDialog:ctor(keyWord1,keyWord2,callback)
	PictureValidateDialog.super.ctor(self,IMAGE_COMMON.."bg_dlg_1.png", UI_ENTER_NONE, {scale9Size = cc.size(588,860), closeBtn = false})
	self.m_sendData = {}
	self.m_word1 = keyWord1
	self.m_word2 = keyWord2
	self.successCallback = callback --验证成功后执行的回调函数
end

function PictureValidateDialog:onEnter()
	PictureValidateDialog.super.onEnter(self)

	PictureValidateDialog.time_ = 25
	PictureValidateDialog.flush = false
	PictureValidateDialog.flushCount = 5

	local btm = display.newSprite(IMAGE_COMMON .. "info_bg_10.jpg"):addTo(self:getBg(),-1)
	btm:setPosition(self:getBg():getContentSize().width / 2,self:getBg():getContentSize().height / 2 - 6)
	btm:setScaleY((self:getBg():getContentSize().height - 70) / btm:getContentSize().height)
	self:setTitle(CommonText[2300])

	--验证时间
	self.timeLabel=ui.newTTFLabel({text=string.format(CommonText[2301]..PictureValidateDialog.time_), size = 18, color = display.COLOR_RED})
	self.timeLabel:addTo(self:getBg())
	self.timeLabel:setAnchorPoint(0,0)
	self.timeLabel:setPosition(80,760)
	self.timeLabel:performWithDelay(handler(self, self.tick), 1, true)

	--刷新按钮
	local normal=display.newSprite(IMAGE_COMMON.."validate/new.png")
	local selected=display.newSprite(IMAGE_COMMON.."validate/new.png")
	local disabled=display.newSprite(IMAGE_COMMON.."validate/new.png")
	self.updateBtn=MenuButton.new(normal,selected,disabled,handler(self, self.updateCallback)):addTo(self:getBg())
	self.updateBtn:setPosition(525,770)

	--刷新次数显示
	local f = UiUtil.label(CommonText[2305], FONT_SIZE_SMALL):addTo(self:getBg())
	f:setPosition(400,770)
	self.updateLabel = UiUtil.label(PictureValidateDialog.flushCount, FONT_SIZE_SMALL,COLOR[2]):rightTo(f)
	UiUtil.label("/5",FONT_SIZE_SMALL):rightTo(self.updateLabel)

	--题目
	local t = ui.newTTFLabel({text = CommonText[2302][1], font = G_FONT, size = FONT_SIZE_SMALL, x=80, y = self:getBg():getContentSize().height - 140}):addTo(self:getBg())
	UiUtil.label(CommonText[2302][2],FONT_SIZE_SMALL, COLOR[2]):rightTo(t)
	self.keyWord1 = UiUtil.label(self.m_word1,FONT_SIZE_SMALL, COLOR[5]):addTo(self:getBg())
	self.keyWord1:setAnchorPoint(0,0)
	self.keyWord1:setPosition(80, self:getBg():getContentSize().height - 180)
	self.AndLabel = UiUtil.label(CommonText[2302][3],FONT_SIZE_SMALL):addTo(self:getBg())
	self.AndLabel:setAnchorPoint(0,0)
	self.AndLabel:setPosition(80 + self.keyWord1:getContentSize().width, self:getBg():getContentSize().height - 180)
	self.keyWord2 = UiUtil.label(self.m_word2,FONT_SIZE_SMALL,COLOR[5]):addTo(self:getBg())
	self.keyWord2:setAnchorPoint(0,0)
	self.keyWord2:setPosition(80 + self.keyWord1:getContentSize().width + self.AndLabel:getContentSize().width, self:getBg():getContentSize().height - 180)

	local view = PictureValidateTableView.new(cc.size(500,500)):addTo(self:getBg())--,self.m_pictures
	view:setPosition(60, 150)
	self.m_pictureTableView = view
	self.m_pictureTableView:reloadData()

	--确定按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_1_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_normal.png")
	self.m_okBtn = MenuButton.new(normal,selected,disabled,handler(self,self.okCallback)):addTo(self:getBg())
	self.m_okBtn:setLabel(CommonText[1])
	self.m_okBtn:setPosition(self:getBg():getContentSize().width / 2,100)
end

function PictureValidateDialog:tick()
	PictureValidateDialog.time_=PictureValidateDialog.time_-1
	self.timeLabel:setString(string.format(CommonText[2301]..PictureValidateDialog.time_))
	--end
	if PictureValidateDialog.time_==0 then
		self.timeLabel:stopAllActions()
		--获得选中的图片
		local t = self.m_pictureTableView:getChosenPicture()
		self.m_sendData = self:getPicId(t)
		gdump(self.m_sendData,"发送的图片ID")
		--转换为图片ID
		PictureValidateBO.getisSuccess(self.m_sendData,function (data)
			if PictureValidateBO.isSuccess == 1 then  --成功
				Toast.show("恭喜你，验证正确!")
				if table.isexist(data,"award") then
					gprint("获得奖励")--显示奖励
					local awardsShow = {awards={}}
					local a= {kind=data.award.type,id=data.award.id,count=data.award.count}
					table.insert(awardsShow.awards, a)
					UiUtil.showAwards(awardsShow)
					UserMO.addResource(data.award.type, data.award.count, data.award.id)
					Notify.notify(LOCAL_RES_EVENT, {tag = 1})
				else
					Toast.show("每日侦察验证通过奖励已达上限")
				end

				if self.successCallback then 
					self:runAction(transition.sequence({cc.DelayTime:create(0.5),
					cc.CallFunc:create(function() self:pop() end),
					cc.CallFunc:create(function() self.successCallback() end)}))
				end
			else
				Toast.show("验证错误！")
				gprint("UserMO.VerificationFailure",UserMO.VerificationFailure)
				if UserMO.VerificationFailure ==0 then
					Mtime=ManagerTimer.getTime()
					local s=UserMO.prohibitedTime-Mtime
					local freeTime=UiUtil.strBuildTime(s, "hms")
					Toast.show("您的验证操作次数过多，冻结侦察功能"..freeTime)
					self:pop()
					PictureValidateBO.getScoutInfo(function ()
						Mtime=ManagerTimer.getTime()
						local s=UserMO.prohibitedTime-Mtime
						if  s>0 then   --被禁止时间的显示
							local view=UiDirector.getUiByName("HomeView")
							view.m_mainUIs[3]:showTick(s)
						end
					end)
				else    --没有超过验证次数则刷新,重新验证
					local ccFunc = CCCallFunc:create(function() 
						PictureValidateDialog.time_=25
						PictureValidateDialog.flush = true
						self:updateCallback()
					end)
					self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.5), ccFunc))
				end
			end
		end)
	end
end

function PictureValidateDialog:updateCallback()
	if PictureValidateDialog.flushCount == 0 and not PictureValidateDialog.flush then
		self.updateLabel:setString(PictureValidateDialog.flushCount)
		Toast.show(CommonText[2306])
		return
	else
		if PictureValidateDialog.flushCount > 0 and not PictureValidateDialog.flush then
			PictureValidateDialog.flushCount = PictureValidateDialog.flushCount - 1
			self.updateLabel:setString(PictureValidateDialog.flushCount)
		end
	    --从服务端获取新的图片组
		local k1 = nil
		local k2 = nil
		PictureValidateBO.getValidatePic(false,function ()
			if PictureValidateBO.validateKeyWord1 >100 then
				k1 = PictureValidateMO.getSpeciesById(PictureValidateBO.validateKeyWord1)
			else
				k1 = PictureValidateMO.getGenusById(PictureValidateBO.validateKeyWord1)
			end

			if PictureValidateBO.validateKeyWord2 >100 then
				k2 = PictureValidateMO.getSpeciesById(PictureValidateBO.validateKeyWord2)
			else
				k2 = PictureValidateMO.getGenusById(PictureValidateBO.validateKeyWord2)
			end

			self.m_word1 = k1
			self.m_word2 = k2

			gdump(self.m_pictureTableView.m_chosenData,"刷新前选择的")
			self.m_pictureTableView.m_chosenData = nil
			self.m_pictureTableView.m_chosenData = {}
			gdump(self.m_pictureTableView.m_chosenData,"刷新后")

			self.m_pictureTableView:reloadData()
	        --新的题目
			gprint("111111111111111111",self.m_word1)
			gprint("222222222222222222",self.m_word2)
			self.keyWord1:setString(self.m_word1)
			self.AndLabel:setPosition(80 + self.keyWord1:getContentSize().width, self:getBg():getContentSize().height - 180)
			self.keyWord2:setString(self.m_word2)
			self.keyWord2:setPosition(80 + self.keyWord1:getContentSize().width + self.AndLabel:getContentSize().width, self:getBg():getContentSize().height - 180)
		end)

		if PictureValidateDialog.flush then
			self.timeLabel:setString(string.format(CommonText[2301]..PictureValidateDialog.time_))
			self.timeLabel:performWithDelay(handler(self, self.tick),1,true)
			PictureValidateDialog.flush = false
		end
	end
end

function PictureValidateDialog:okCallback()
	if PictureValidateDialog.time_ == 0 then
		return
	end

	self.timeLabel:stopAllActions()
	--获取选中的图片唯一id
	--发送协议给服务发送选中图片的id
	local t = self.m_pictureTableView:getChosenPicture()
	gdump(t,"最后选中的图片")
	self.m_sendData = self:getPicId(t)
	gdump(self.m_sendData,"发送的图片ID")
	
	--获取成功还是失败
	--成功 弹信息 显示奖励 添加奖励
	--失败 失败次数够 刷新重新验证
	--     失败次数不够.弹信息.被冻结
	PictureValidateBO.getisSuccess(self.m_sendData,function (data)
		if PictureValidateBO.isSuccess == 1 then  --成功
			Toast.show("恭喜你，验证正确!")
			if table.isexist(data,"award") then
				gprint("获得奖励")--显示奖励
				local awardsShow = {awards={}}
				local a= {kind=data.award.type,id=data.award.id,count=data.award.count}
				table.insert(awardsShow.awards, a)
				UiUtil.showAwards(awardsShow)
				UserMO.addResource(data.award.type, data.award.count, data.award.id)
				Notify.notify(LOCAL_RES_EVENT, {tag = 1})
			else
				Toast.show("每日侦察验证通过奖励已达上限")
			end

			if self.successCallback then
				self:runAction(transition.sequence({cc.DelayTime:create(0.5),
				cc.CallFunc:create(function() self:pop() end),
				cc.CallFunc:create(function() self.successCallback() end)}))
			end
		else
			Toast.show("验证错误！")
			gprint("UserMO.VerificationFailure",UserMO.VerificationFailure)
			if UserMO.VerificationFailure ==0 then
				Mtime=ManagerTimer.getTime()
				local s=UserMO.prohibitedTime-Mtime
				local freeTime=UiUtil.strBuildTime(s, "hms")
				Toast.show("您的验证操作次数过多，冻结侦察功能"..freeTime)
				self:pop()
				PictureValidateBO.getScoutInfo(function ()
					Mtime=ManagerTimer.getTime()
					local s=UserMO.prohibitedTime-Mtime
					if  s>0 then   --被禁止时间的显示
						local view=UiDirector.getUiByName("HomeView")
						view.m_mainUIs[3]:showTick(s)
					end
				end)
			else    --没有超过验证次数则刷新,重新验证
				local ccFunc = CCCallFunc:create(function() 
					PictureValidateDialog.time_=25
					PictureValidateDialog.flush = true
					self:updateCallback()
				end)
				self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.5), ccFunc))
			end
		end
	end)
	--self:pop()
end

--将图片的位置信息通过服务端发来的序号转化为图片ID
function PictureValidateDialog:getPicId(t)
	gdump(t,"图片的位置")
	gdump(PictureValidateBO.validatePic,"发送过来的图片")
	local pictures = {}
	for index=1, #t do
		gprint(t[index])
		local Picid = PictureValidateBO.validatePic[t[index]]
		table.insert(pictures,Picid)
	end
	gdump(pictures,"图片id")
	return pictures
end

return PictureValidateDialog