--
-- Author: Gss
-- Date: 2018-09-19 14:00:11
--
--有奖问答

local ActivityQuestionView = class("ActivityQuestionView",UiNode)

function ActivityQuestionView:ctor(activity)
	ActivityQuestionView.super.ctor(self, "image/common/bg_ui.jpg")
	self.m_activity = activity
    self.m_timeSecondHand = 0
    self.m_currentQuestionIndex = 1 --默认第一题
    self.m_myCurrenChose = {} --问题答案
end

function ActivityQuestionView:onEnter()
	ActivityQuestionView.super.onEnter(self)
	self:setTitle(self.m_activity.name)
	self:showUI()
	self:showQuestion(self.m_currentQuestionIndex)

	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt) self:onEnterFrame(dt) end)
    self:scheduleUpdate_()
end

function ActivityQuestionView:showUI()
	local questionInfo = ActivityCenterMO.getQuestionById()
	--顶图
	local btm = self:getBg()
	local topBg = display.newSprite(IMAGE_COMMON .. "bar_question_top.jpg"):addTo(btm)
	topBg:setPosition(btm:width() / 2, btm:height() - topBg:height() / 2 - 100)

	local topbg2 = display.newSprite(IMAGE_COMMON .. "bar_bg.png"):addTo(topBg, -1):center()

	--描述
	local desc = UiUtil.label(CommonText[1157], nil, nil, cc.size(topBg:width() - 40, 0), ui.TEXT_ALIGN_LEFT):addTo(topBg)
	desc:setAnchorPoint(cc.p(0, 0.5))
	desc:setPosition(20, topBg:height() - 90)
	--时间
	local time = UiUtil.label(CommonText[853], nil, COLOR[2]):addTo(topBg)
	time:setAnchorPoint(cc.p(0, 0.5))
	time:setPosition(20, 20)
	local timeLab = UiUtil.label("", nil, COLOR[2]):rightTo(time)
	self.m_timelb = timeLab
end

function ActivityQuestionView:showQuestion(index)
	if self.m_contentNode then
		self.m_contentNode:removeSelf()
		self.m_contentNode = nil
	end

	local container = display.newNode():addTo(self:getBg())
	container:setContentSize(self:getBg():getContentSize())
	self.m_contentNode = container
	local allQuestions = ActivityCenterMO.getQuestionById()
	self.m_maxQuestion = #allQuestions
	local questionInfo = allQuestions[index]

	--底部按钮
	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
	local leftBtn = MenuButton.new(normal, selected, disabled, handler(self, self.lastCallBack)):addTo(container)  -- 上一题
	leftBtn:setPosition(container:getContentSize().width / 4, 80)
	leftBtn:setLabel(CommonText[1158][1])
	leftBtn:setEnabled(self.m_currentQuestionIndex > 1)
	self.m_leftBtn = leftBtn

	local normal = display.newSprite(IMAGE_COMMON .. "btn_10_normal.png")
	local selected = display.newSprite(IMAGE_COMMON .. "btn_10_selected.png")
	local disabled = display.newSprite(IMAGE_COMMON .. "btn_1_disabled.png")
	local rightBtn = MenuButton.new(normal, selected, disabled, handler(self, self.nextCallBack)):addTo(container)  -- 下一题
	rightBtn:setPosition(container:getContentSize().width / 4 * 3, 80)
	rightBtn:setLabel(CommonText[1158][2])
	if index == #allQuestions then rightBtn:setLabel(CommonText[1159]) end
	rightBtn:setEnabled(self.m_currentQuestionIndex > 0)
	self.m_rightBtn = rightBtn

	--标题
	local titleBg = display.newSprite(IMAGE_COMMON .. "info_bg_12.png"):addTo(container)
	titleBg:setPosition(titleBg:width() / 2 + 30, container:height() - 310)
	local title = UiUtil.label(string.format(CommonText[1160],index)):addTo(titleBg)
	title:setPosition(90, titleBg:height() / 2)

	--问题
	local question = UiUtil.label(questionInfo.question):addTo(container)
	question:setAnchorPoint(cc.p(0, 0.5))
	question:setPosition(40, titleBg:y() - 60)

	--答案
	self.checkBox = {}
	self.m_inputName = {}
	if not self.m_myCurrenChose[index] then
		self.m_myCurrenChose[index] = {}
		self.m_myCurrenChose[index].value = 0
		self.m_myCurrenChose[index].keyId = index
	end
	local answer = json.decode(questionInfo.answer)
	if answer then
		for num=1,#answer do
			local answerBg = display.newSprite(IMAGE_COMMON .. "answer_bg.png"):addTo(container)
			answerBg:setPosition(container:width() / 2, question:y() - 50 - (num - 1)* 70)
			local answerIndex = UiUtil.label(answer[num]):addTo(answerBg)
			answerIndex:setAnchorPoint(cc.p(0, 0.5))
			answerIndex:setPosition(40,answerBg:height() / 2)

			--选择框
			local function onCheckedChanged(sender, isChecked)
				ManagerSound.playNormalButtonSound()
				
				if not isChecked then
					sender:setChecked(true)
					return 
				end

				for k,v in ipairs(self.checkBox) do
					if v:getTag() ~= sender:getTag() then
						v:setChecked(false)
					end
				end
				local choseNum = sender:getTag()
				self.m_myCurrenChose[index].value = choseNum

				if self.m_inputName[index] then
					if choseNum == #answer then
						self.m_myCurrenChose[index].addtional = self.m_inputName[index]:getText()
						self.m_inputName[index]:setVisible(true)
					else
						self.m_myCurrenChose[index].addtional = nil
						self.m_inputName[index]:setVisible(false)
					end
				end

				if choseNum ~= #answer then
					self.m_myCurrenChose[index].addtional = nil
				end
			end

			if questionInfo.inputId == 1 and num == #answer then --如果需要输入框
				local function onEdit(event, editbox)
			    	if event == "began" then
				    elseif event == "changed" then
			        	self.m_myCurrenChose[index].addtional = editbox:getText()
			        end
			    end
				local input_bg = IMAGE_COMMON .. "info_bg_16.png"

			    local inputName = ui.newEditBox({image = input_bg, listener = onEdit, size = cc.size(190, answerBg:height() - 5)})--:addTo(answerBg)
				inputName:setFontColor(COLOR[1])
				inputName:setFontSize(FONT_SIZE_TINY)
				inputName:setText(self.m_myCurrenChose[index].addtional or CommonText[1161])
				inputName:setMaxLength(CHAT_MAX_LENGTH) --最大输入字符数
				self.m_inputName[index] = inputName
				self.m_myCurrenChose[index].addtional = inputName:getText()
				if self.m_myCurrenChose[index].value ~= #answer then
					self.m_myCurrenChose[index].addtional = nil
				end
				if self.m_myCurrenChose[index].value ~= num then
					self.m_inputName[index]:setVisible(false)
				end

				--进度
				local clipping = cc.ClippingNode:create()
				clipping:setPosition(answerBg:width() - 300, answerBg:height() / 2)
				local mask = display.newScale9Sprite(IMAGE_COMMON.."info_bg_16.png")
				mask:setPreferredSize(cc.size(190, answerBg:height()))
				clipping:setInverted(false)
				clipping:setAlphaThreshold(0.0)
				clipping:setStencil(mask)
				clipping:addChild(inputName)
				clipping:addTo(answerBg)
			end

			local checkBox = CheckBox.new(nil, nil, onCheckedChanged):addTo(answerBg,0,num)
			checkBox:setPosition(answerBg:width() - 70, answerBg:height() / 2)
			checkBox:setChecked(num == self.m_myCurrenChose[index].value)
			table.insert(self.checkBox, checkBox)
		end
	else
		local contentBg = display.newScale9Sprite(IMAGE_COMMON .. "info_bg_14.jpg"):addTo(container)
		contentBg:setPreferredSize(cc.size(550,400))
		contentBg:setPosition(container:getContentSize().width / 2, question:y() - 50 - contentBg:getContentSize().height / 2)

		local contentLab = ui.newTTFLabel({text = " ", font = G_FONT, size = FONT_SIZE_SMALL, 
	   		x = -240, y = contentBg:getContentSize().height - 20, color = COLOR[1], 
	   		align = ui.TEXT_ALIGN_LEFT,valign = ui.TEXT_VALIGN_TOP,
	   		dimensions = cc.size(510, 473)}):addTo(contentBg)
		contentLab:setAnchorPoint(cc.p(0, 1))
		contentLab:setString(self.m_myCurrenChose[index].addtional or "")
		self.contentLab = contentLab

		local function onEdit1(event, editbox)
		   if event == "return" then
		   		editbox:setText("")
		   		editbox:setVisible(true)
		   elseif event == "changed" then
		   		contentLab:setString(editbox:getText())
		   		self.m_myCurrenChose[index].addtional = editbox:getText()
		   elseif event == "began" then
		   		editbox:setVisible(false)
		   		if self.contentLab then 
		   			editbox:setText(self.contentLab:getString())
		   		end
		   end
	    end
		local input_bg = IMAGE_COMMON .. "info_bg_15.png"
		for index=1,10 do
			local inputContent = ui.newEditBox({image = nil, listener = onEdit1, size = cc.size(510, 35)}):addTo(contentBg)
			inputContent:setFontColor(COLOR[1])
			inputContent:setFontSize(FONT_SIZE_SMALL)
			inputContent:setMaxLength(200)  
			inputContent:setPosition(contentBg:getContentSize().width / 2, contentBg:height() - 30 - (index - 1) * 40)
		end
	end
end

function ActivityQuestionView:lastCallBack(tag, sender)
	ManagerSound.playNormalButtonSound()
	self.m_currentQuestionIndex = self.m_currentQuestionIndex - 1
	self:showQuestion(self.m_currentQuestionIndex)
end

function ActivityQuestionView:nextCallBack(tag, sender)
	ManagerSound.playNormalButtonSound()
	local index = self.m_currentQuestionIndex

	if self.m_currentQuestionIndex == self.m_maxQuestion then
		ActivityCenterBO.upLoadAnswer(function (success)
			if success then
				self:pop()
			end
		end, self.m_myCurrenChose)
		return
	end

	if not self.m_myCurrenChose[index].value or self.m_myCurrenChose[index].value == 0 then
		Toast.show(CommonText[1162])
		return
	else
		if self.m_myCurrenChose[index].addtional and (self.m_myCurrenChose[index].addtional == "" or self.m_myCurrenChose[index].addtional == CommonText[1161]) then
			Toast.show(CommonText[1162])
			return
		end
	end

	self.m_currentQuestionIndex = self.m_currentQuestionIndex + 1
	self:showQuestion(self.m_currentQuestionIndex)
end

-- 帧刷新
function ActivityQuestionView:onEnterFrame(dt)
	self.m_timeSecondHand = self.m_timeSecondHand + dt
	if self.m_timeSecondHand >= 1 then
		self.m_timeSecondHand = self.m_timeSecondHand - 1
		if self.m_timelb then
			local time = self.m_activity.endTime - ManagerTimer.getTime()
			if time >= 0 then
				self.m_timelb:setString(UiUtil.strBuildTime(time))
				self.m_activityState = true
			else
				self.m_timelb:setString(CommonText[1781])
				self.m_activityState = false
			end
		end
	end
end

-- 重载，要做特殊处理
function ActivityQuestionView:onReturnCallback(tag, sender)
	ManagerSound.playNormalButtonSound()
	local desc = CommonText[1163]
	require("app.dialog.TipsAnyThingDialog").new(desc,function ()
		self:CloseAndCallback()
		self:pop()
	end):push()
end

function ActivityQuestionView:onExit()
	ActivityQuestionView.super.onExit(self)
end

return ActivityQuestionView