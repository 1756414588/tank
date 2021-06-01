package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.NewTaskLiveAwardRq;
import com.game.service.TaskService;

public class NewTaskLiveAwardHandler extends ClientHandler {

    @Override
    public void action() {
        NewTaskLiveAwardRq req = msg.getExtension(NewTaskLiveAwardRq.ext);
        getService(TaskService.class).newTaskLiveAward(req, this);

    }

}
