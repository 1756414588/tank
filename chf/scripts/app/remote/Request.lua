local Request = class("Request")

function Request:ctor(requestName)
	if not requestName or requestName == "" then
		gprint("Request:ctor request name is empty!!! error !!!!")
	end

	self.name_ = requestName

	self.data_ = {}
end

function Request:setData(data)
	self.data_ = data
end

function Request:getData()
	return self.data_
end

function Request:getName()
	return self.name_
end

-- function Request:bindUpdate(listener)
-- 	if listener then
-- 		Notify.register(self.name_, listener)
-- 	end
-- end

-- function Request:unbindUpdate(handler)
-- 	if handler then
-- 		Notify.unregister(self.name_, handler)
-- 	end
-- end

-- function Request:unbindAll()
-- 	Notify.unregisterAll(self.name_)
-- end

-- function Request:notify()
-- 	Notify.notify(self.name_, self)
-- end

return Request
