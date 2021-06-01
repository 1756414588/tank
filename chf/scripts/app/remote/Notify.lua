
Notify = {}

function Notify.register(notifyName, listener)
    if not notifyName or notifyName == "" then
        gprint("[Notify] register wrong notify name. Error!!!")
	    return
    end

	return app:addEventListener(notifyName .. "_NOTIFY", function(event)
		if listener then listener(event) end
		end)
end

function Notify.unregister(handler)
	if handler then
		app:removeEventListener(handler)
	end
end

function Notify.unregisterAll(notifyName)
	if notifyName and notifyName ~= "" then
		app:removeEventListenersByEvent(notifyName .. "_NOTIFY")
	end
end

function Notify.notify(notifyName, obj)
	app:dispatchEvent({name = notifyName .. "_NOTIFY", obj = obj})
end

return Notify
