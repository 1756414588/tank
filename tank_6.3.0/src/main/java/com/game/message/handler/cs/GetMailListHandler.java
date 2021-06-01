package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.GetMailListRq;
import com.game.service.MailService;

public class GetMailListHandler extends ClientHandler{

	/** 
	* Overriding: action    
	* @see com.game.server.ICommand#action()    
	*/
	@Override
	public void action() {
		//Auto-generated method stub
		GetMailListRq req = msg.getExtension(GetMailListRq.ext);
		getService(MailService.class).getMailListRq(req, this);
	}

}
