package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1;
import com.game.pb.GamePb1.DelMailRq;
import com.game.service.MailService;

public class CollectionsMailRqlHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		GamePb1.CollectionsMailRq req = msg.getExtension(GamePb1.CollectionsMailRq.ext);
		getService(MailService.class).collectionsMailRq(req, this);
	}

}
