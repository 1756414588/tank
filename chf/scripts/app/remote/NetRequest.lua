
local NetRequest = class("NetRequest", Request)

function NetRequest:ctor(requestName, param)
	NetRequest.super.ctor(self, requestName)

	self.param_ = {}  -- 请求中用于存放参数

	if param then self.param_ = param end
end

function NetRequest:setParam(param)
	self.param_ = param
end

function NetRequest:getParam()
	return self.param_
end

function NetRequest:pack()
	local msg = {}
	msg.request = self.name_
	msg.param = self.param_
	return msg
end

return NetRequest