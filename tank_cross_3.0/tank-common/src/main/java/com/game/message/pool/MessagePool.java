package com.game.message.pool;

import com.game.message.handler.ClientHandler;
import com.game.message.handler.ServerHandler;

import java.util.HashMap;

public abstract class MessagePool {
    private HashMap<Integer, Class<? extends ClientHandler>> clientHandlers = new HashMap<>();
    private HashMap<Integer, Class<? extends ServerHandler>> serverHandlers = new HashMap<>();
    private HashMap<Integer, Integer> rsMsgCmd = new HashMap<>();

    public MessagePool() {
        register();
    }

    protected abstract void register();

    protected void registerC(int id, int rsCmd, Class<? extends ClientHandler> handlerClass) {
        if (handlerClass != null) {
            clientHandlers.put(id, handlerClass);
            rsMsgCmd.put(id, rsCmd);
        }
    }

    private void registerS(int id, int rsCmd, Class<? extends ServerHandler> handlerClass) {
        if (handlerClass != null) {
            serverHandlers.put(id, handlerClass);
            rsMsgCmd.put(id, rsCmd);
        }
    }

    public ClientHandler getClientHandler(int id)
            throws InstantiationException, IllegalAccessException {
        if (!clientHandlers.containsKey(id)) {
            return null;
        } else {
            ClientHandler handler = clientHandlers.get(id).newInstance();
            handler.setRsMsgCmd(rsMsgCmd.get(id));
            return handler;
        }
    }

    public ServerHandler getServerHandler(int id)
            throws InstantiationException, IllegalAccessException {
        if (!serverHandlers.containsKey(id)) {
            return null;
        } else {
            ServerHandler handler = serverHandlers.get(id).newInstance();
            handler.setRsMsgCmd(rsMsgCmd.get(id));
            return handler;
        }
    }
}
