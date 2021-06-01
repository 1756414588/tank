
local BlendClipNode = class("BlendClipNode", function()
	local node = display.newNode()
	nodeExportComponentMethod(node)
	node:setNodeEventEnabled(true)
	return node
end)

function BlendClipNode:ctor(maskPath, bgPath, clipX, clipY)
	self.maskPath_ = maskPath
	self.bgPath_ = bgPath
	self.clipX_ = clipX
	self.clipY_ = clipY
end

function BlendClipNode:onEnter()
	local bgPic = display.newSprite(self.bgPath_):addTo(self)
	bgPic:setVisible(false)
	self.bgPic_ = bgPic
	local holePic = display.newSprite(self.maskPath_)
	-- gl.ZERO
	-- gl.ONE
	-- gl.SRC_COLOR
	-- gl.ONE_MINUS_SRC_COLOR
	-- gl.SRC_ALPHA
	-- gl.ONE_MINUS_SRC_ALPHA
	-- gl.DST_ALPHA
	-- gl.ONE_MINUS_DST_ALPHA
	-- gl.DST_COLOR
	-- gl.ONE_MINUS_DST_COLOR    
	local blendFuc = ccBlendFunc:new()
	blendFuc.src = gl.GL_ZERO
	blendFuc.dst = gl.GL_SRC_ALPHA
	holePic:setBlendFunc(blendFuc)  
	holePic:setVisible(false)
	self.holePic_ = holePic
	bgPic:addChild(holePic)
	holePic:setPosition(self.clipX_, self.clipY_)

	local size = bgPic:getContentSize()
	local size1 = holePic:getContentSize()
	bgPic:setPosition(size.width/2-holePic:getPositionX() + size1.width * 0.5, size.height/2-holePic:getPositionY() + size1.height * 0.5)

	local renderTexture = cc.RenderTexture:create(size1.width,size1.height)
	renderTexture:retain()
	renderTexture:setVisible(false)
	self.renderTexture_ = renderTexture

	local renderPic = cc.Sprite:createWithTexture(renderTexture:getSprite():getTexture()) 
	renderPic:setFlipY(true)
	renderPic:addTo(self)
	renderPic:setPosition(0, 0)
end

function BlendClipNode:erase( pos )
	if self.renderTexture_ then
		self.renderTexture_:beginWithClear(0.0, 0.0, 0.0, 1.0)  
		self.bgPic_:setVisible(true)
		self.holePic_:setVisible(true)
		self.bgPic_:visit()
		self.renderTexture_:endToLua()  
		self.bgPic_:setVisible(false)
		self.holePic_:setVisible(false)     
	end
end

function BlendClipNode:onExit()
	if self.renderTexture_ then
		local renderTexture = self.renderTexture_
		self.renderTexture_ = nil

		scheduler.performWithDelayGlobal(function ()
			renderTexture:release()
			gprint("@^^^^^^^^^^renderTexture:release^^^^^^^")
		end,0.5)
	end
end


local Dialog = require("app.dialog.Dialog")
local ValidateDialog=class("ValidateDialog",Dialog)


function ValidateDialog:ctor(callback)
	-- body
	ValidateDialog.super.ctor(self,IMAGE_COMMON.."validate/".."validateBG.png",UI_ENTER_NONE) --调用父类的构造函数,{scale9Size=cc.size(560,550)}
	ValidateDialog.time_=nil     --验证限时
	ValidateDialog.isSuccess=nil  --1表示成功,2表示失败
	ValidateDialog.flush = nil  --表示错误刷新或者时间到刷新
	self.successCallback = callback
end

function ValidateDialog:onEnter()
	ValidateDialog.super.onEnter(self)
	ValidateDialog.time_ = 10
	ValidateDialog.flush = false
	--UserMO.scoutValidate = true
	
	--创建切下来的图块
	local num1=random(1,3)
	--要刷新的node
	self.m_node=display.newSprite():addTo(self:getBg())
	self.m_node:setAnchorPoint(0,0)
	self.m_node:setPosition(5,78)
	--先创建底板
	self.bg_=display.newScale9Sprite(IMAGE_COMMON.."validate/".."bottom"..num1..".png"):addTo(self.m_node)
	self.bg_:setAnchorPoint(0,0)

	--添加计时显示
	self.timeLabel=ui.newTTFLabel({text="验证时间："..ValidateDialog.time_,size = 18,color = display.COLOR_RED})
	self.timeLabel:addTo(self:getBg())
	self.timeLabel:setAnchorPoint(0,0)
	self.timeLabel:setPosition(5,355)
	self.timeLabel:performWithDelay(handler(self, self.tick),1,true)

	self.randomx=random(236,456)
	self.randomy=random(65,240)
	local num2=random(1,3)
	gprint("num1",num1)
	gprint("num2",num2)
	self.target=display.newSprite(IMAGE_COMMON.."validate/".."clipping"..num2..".png"):addTo(self.bg_)
	self.target:setPosition(self.randomx,self.randomy)
	gprint(self.randomx,self.randomy)
	self.m_origOffsetX=100
	self.clipping=ValidateDialog.creatClip("bottom"..num1..".png","clipping"..num2.."_mask.png",self.randomx,self.randomy, self.m_origOffsetX, 0)--,randomx,randomy
	self.clipping:addTo(self.bg_)
	self.clipping:setPosition(self.m_origOffsetX,self.randomy)
	self.barWidth = 520
	self.barHeight = 63

	--添加滑块
	--self.slider=cc.ui.UISlider.new(display.LEFT_TO_RIGHT,{bar=IMAGE_COMMON.."validate/bar_empty.png",button=IMAGE_COMMON.."validate/button_normal.png"},{scale9=true})
	self.slider = Slider.new(display.LEFT_TO_RIGHT, {bar = IMAGE_COMMON.."validate/bar_empty.png", button = IMAGE_COMMON.."validate/button_normal.png"}, {scale9 = true})--,min=self.m_minNum,max = self.m_maxNum
	self.slider:addTo(self:getBg(), 1)
	self.slider:setSliderSize(self.barWidth, self.barHeight)
	self.slider:setSliderSize(520,70)
	self.slider:setPosition(10,5)
	self.slider:setSliderValue(0)
	self.slider:onSliderValueChanged(handler(self, self.onValueChanged))
	self.slider:onSliderRelease(handler(self, self.onRelease))

	self.valueLable=ui.newTTFLabel({text = "向右滑动以填充图片", font = G_FONT, size = FONT_SIZE_MEDIUM, color = COLOR[1]}):addTo(self.slider)--, align = ui.TEXT_ALIGN_CENTER
	self.valueLable:setPosition(self.barWidth/2,self.barHeight/2)

	self.grayBar=cc.ui.UILoadingBar.new({image=IMAGE_COMMON.."validate/".."bar_press.png",viewRect=cc.rect(0,0,self.barWidth,self.barHeight)})  --灰色,scale9=true
	self.grayBar:addTo(self:getBg())
	self.grayBar:setPosition(10,10)
	self.grayBar:setVisible(false)

	local normal=display.newSprite(IMAGE_COMMON.."validate/".."new.png")
	local selected=display.newSprite(IMAGE_COMMON.."validate/".."new.png")
	local disabled=display.newSprite(IMAGE_COMMON.."validate/".."new.png")
	self.Btn=MenuButton.new(normal,selected,disabled,handler(self, self.onClickCallback)):addTo(self.bg_)
	self.Btn:setPosition(495,275)

	self.greenBar=cc.ui.UILoadingBar.new({image=IMAGE_COMMON.."validate/".."bar_relase.png",viewRect=cc.rect(0,0,440,63)}) --绿色 
	self.greenBar:addTo(self:getBg(),2)
	self.greenBar:setPosition(10,10)
	self.greenBar:setVisible(false)
	self.successButton=display.newSprite(IMAGE_COMMON.."validate/".."button_relase.png")   --成功
	self.successButton:addTo(self:getBg(),2)
	self.successButton:setAnchorPoint(0,0)
	self.successButton:setVisible(false)
	self.redBar=cc.ui.UILoadingBar.new({image=IMAGE_COMMON.."validate/".."bar_failure.png",viewRect=cc.rect(0,0,440,63)}) --绿色 
	self.redBar:addTo(self:getBg(),2)
	self.redBar:setPosition(10,10)
	self.redBar:setVisible(false)
	self.failButton=display.newSprite(IMAGE_COMMON.."validate/".."btn_cancel_normal.png")  --失败
	self.failButton:addTo(self:getBg(),2)
	self.failButton:setAnchorPoint(0,0)
	self.failButton:setVisible(false)
	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.onEnterFrame))
	self:scheduleUpdate()
end

function ValidateDialog:onEnterFrame(dt)
	if self.clipping then
		self.clipping:erase(cc.p(0, 0))
	end
end

function ValidateDialog.creatClip(clipBg,stencil,x,y, t_x, t_y)
	-- body
	local bgPath=""  --背景
	local stencilPath="" --遮罩
	if type(clipBg)=="string" then 
		bgPath=clipBg 
	else
		gprint("缺少背景图片路径") 
	end

	if type(stencil)=="string" then 
		stencilPath=stencil
	else
		gprint("缺少遮罩图片路劲") 
	end

	-- local bg= display.newScale9Sprite(IMAGE_COMMON.."validate/"..bgPath)
	-- bg:setAnchorPoint(cc.p(0,0))
	-- local stencil=display.newSprite(IMAGE_COMMON.."validate/"..stencilPath)
	-- local clipping=cc.ClippingNode:create()
	-- clipping:setPosition(cc.p(t_x, t_y))
	-- if x and y then 
	-- 	stencil:setPosition(cc.p(x,y))
	-- end

	-- clipping:setInverted(false)
	-- clipping:setAlphaThreshold(0.0)
	-- clipping:setStencil(stencil)
	-- clipping:addChild(bg)

	local fog = BlendClipNode.new(IMAGE_COMMON.."validate/"..stencilPath, IMAGE_COMMON.."validate/"..bgPath, x, y)

	return fog
end

function ValidateDialog:onValueChanged(event)  --当滑块的按钮移动，减下来的图块跟着移动
	self.valueLable:setVisible(false)
	local slideV = self.slider:getSliderValue()
	local x_cur=slideV/100.00*(self.barWidth-87)
	if slideV>0 then
		self.grayBar:setVisible(true)
		self.grayBar:setPercent(slideV)
	else
		self.grayBar:setVisible(false)
		self.grayBar:setPercent(0)
	end

	if self.m_origOffsetX+x_cur>=527-60 then
		self.clipping:setPositionX(527-60)
	else
		self.clipping:setPositionX(self.m_origOffsetX+x_cur)
	end

end

function ValidateDialog:onRelease(event) --当手放开滑块，则验证
		-- body
	local x_=self.clipping:getPositionX()
	local deltaX = x_ - self.randomx
	local y_=self.clipping:getPositionY()
	gprint("x=%0.2f,y=%0.2f",x_,y_)
	self.timeLabel:stopAllActions()
	local movePercent = self.slider:getSliderValue()
	if deltaX >= -5 and deltaX <= 3 then
		if ValidateDialog.time_==0 then --如果时间等于0，那么表示验证失败 
			--ValidateDialog.isSuccess=2 --失败
			return
		else
			ValidateDialog.isSuccess=1  --成功
			self.slider:setVisible(false)
			self.greenBar:setPercent(movePercent)
			self.greenBar:setVisible(true)
			self.successButton:setPosition(movePercent/100*(520-87)+12,9)
			self.successButton:setVisible(true)
			Toast.show("恭喜你，验证正确!")
			ValidateBO.getisSuccess(ValidateDialog.isSuccess,function(data)
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
			end)
			gprint("scoutCount+++++++++",UserMO.scout_)
			if self.successCallback then
				self:runAction(transition.sequence({cc.DelayTime:create(0.5),
				cc.CallFunc:create(function() self:pop() end),
				cc.CallFunc:create(function() self.successCallback() end)}))
			else
				self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.5),CCCallFunc:create(function() self:pop() end)))
			end
		end
	else
		if ValidateDialog.time_==0 then 
			return
		else
			--如果验证错误次数大于3次，则显示被冻结多少分钟
			ValidateDialog.isSuccess=2
			self.slider:setVisible(false)
			self.redBar:setPercent(movePercent)
			self.redBar:setVisible(true)
			self.failButton:setPosition(movePercent/100*(520-87)+12,9)
			self.failButton:setVisible(true)
			Toast.show("验证错误！")
			ValidateBO.getisSuccess(ValidateDialog.isSuccess,function (data)
				-- body
				gprint("UserMO.VerificationFailure",UserMO.VerificationFailure)
				if UserMO.VerificationFailure ==0 then
					Mtime=ManagerTimer.getTime()
					local s=UserMO.prohibitedTime-Mtime
					local freeTime=UiUtil.strBuildTime(s, "hms")
					Toast.show("您的验证操作次数过多，冻结侦察功能"..freeTime)
					self:pop()
					ValidateBO.getScoutInfo(function ()
					Mtime=ManagerTimer.getTime()
					local s=UserMO.prohibitedTime-Mtime
					if  s>0 then   --被禁止时间的显示
						local view=UiDirector.getUiByName("HomeView")
						view.m_mainUIs[3]:showTick(s)
					end   
					end)
				else    --没有超过验证次数则刷新,重新验证
					local ccFunc = CCCallFunc:create(function() 
						ValidateDialog.time_=10
						ValidateDialog.flush = true
						self.redBar:setVisible(false)
						self.failButton:setVisible(false)
						self.grayBar:setVisible(false)
						self.grayBar:setPercent(0)
						self:onClickCallback()
					end)
					self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.5), ccFunc))
					ValidateDialog.time_=10
				end
			end)
		end
	end
end

function ValidateDialog:onClickCallback()  --刷新的回掉函数
	self.grayBar:setVisible(false)
	self.grayBar:setPercent(0)
	self.m_node:removeAllChildren()
	local num1=random(1,3)
	local num2=random(1,3)
	gprint("num1==",num1)
	gprint("num2==",num2)
	self.randomx=random(236,456)
	self.randomy=random(65,240)
	self.bg_=display.newScale9Sprite(IMAGE_COMMON.."validate/".."bottom"..num1..".png"):addTo(self.m_node)
	self.bg_:setAnchorPoint(0,0)
	self.target=display.newSprite(IMAGE_COMMON.."validate/".."clipping"..num2..".png"):addTo(self.bg_)
	self.target:setPosition(self.randomx,self.randomy)
	self.clipping=ValidateDialog.creatClip("bottom"..num1..".png","clipping"..num2.."_mask.png",self.randomx,self.randomy, self.m_origOffsetX, 0)--,randomx,randomy
	self.clipping:addTo(self.bg_)
	self.clipping:setPosition(self.m_origOffsetX,self.randomy)
	local normal=display.newSprite(IMAGE_COMMON.."validate/".."new.png")
	local selected=display.newSprite(IMAGE_COMMON.."validate/".."new.png")
	local disabled=display.newSprite(IMAGE_COMMON.."validate/".."new.png")
	self.Btn=MenuButton.new(normal,selected,disabled,handler(self, self.onClickCallback)):addTo(self.bg_)
	self.Btn:setPosition(495,275)
	self.slider:removeFromParent()
	self.slider=nil
	self.slider = Slider.new(display.LEFT_TO_RIGHT, {bar = IMAGE_COMMON.."validate/bar_empty.png", button = IMAGE_COMMON.."validate/button_normal.png"}, {scale9 = true})--,min=self.m_minNum,max = self.m_maxNum
	self.slider:addTo(self:getBg(), 1)
	self.slider:setSliderSize(self.barWidth, self.barHeight)
	self.slider:setSliderSize(520,70)
	self.slider:setPosition(10,5)
	self.slider:setSliderValue(0)
	self.valueLable=ui.newTTFLabel({text = "向右滑动以填充图片", font = G_FONT, size = FONT_SIZE_MEDIUM, color = COLOR[1]}):addTo(self.slider)--, align = ui.TEXT_ALIGN_CENTER
	self.valueLable:setPosition(self.barWidth/2,self.barHeight/2)
	self.slider:onSliderValueChanged(handler(self, self.onValueChanged))
	self.slider:onSliderRelease(handler(self, self.onRelease))
	--self.timeLabel=ui.newTTFLabel({text="验证时间："..ValidateDialog.time_,size = 18,color = display.COLOR_RED})
	--self.timeLabel:addTo(self.bg_)
	--self.timeLabel:setAnchorPoint(0,0)
	--self.timeLabel:setPosition(5,283)
	if ValidateDialog.flush then
		self.timeLabel:setString(string.format("验证时间："..ValidateDialog.time_))
		self.timeLabel:performWithDelay(handler(self, self.tick),1,true)
		ValidateDialog.flush = false
	end
end

function ValidateDialog:tick()
	ValidateDialog.time_=ValidateDialog.time_-1
	gprint("time+++++++++",ValidateDialog.time_)
	self.timeLabel:setString(string.format("验证时间："..ValidateDialog.time_))
	--end
	if ValidateDialog.time_==0 then
		self.timeLabel:stopAllActions()
		ValidateDialog.isSuccess=2 --失败
		ValidateBO.getisSuccess(ValidateDialog.isSuccess,function ()
			if UserMO.VerificationFailure==0 then
				Mtime=ManagerTimer.getTime()
				local s=UserMO.prohibitedTime-Mtime
				local freeTime=UiUtil.strBuildTime(s, "hms")
				Toast.show("您的验证操作次数过多，冻结侦察功能"..freeTime)
				self:pop()
				ValidateBO.getScoutInfo(function ()
					Mtime=ManagerTimer.getTime()
					local s=UserMO.prohibitedTime-Mtime
					if  s>0 then   --被禁止时间的显示
						local view=UiDirector.getUiByName("HomeView")
						view.m_mainUIs[3]:showTick(s)
					end
				end)
			else
				ValidateDialog.time_=10
				ValidateDialog.flush = true
				self:onClickCallback()
				Toast.show("验证时间到!请重新验证")
			end
		end)
	end
end

return ValidateDialog