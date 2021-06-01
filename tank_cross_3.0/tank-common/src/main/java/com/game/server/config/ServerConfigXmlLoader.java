package com.game.server.config;

import com.game.server.config.gameServer.GameServerConfig;
import com.thoughtworks.xstream.XStream;
import com.thoughtworks.xstream.io.xml.DomDriver;

import java.io.IOException;
import java.io.InputStream;

public class ServerConfigXmlLoader {
    /**
     * 初始化服务器配置信息
     *
     * @param inputStream
     * @return
     */
    public GameServerConfig load(InputStream inputStream) {
        GameServerConfig gameServerConfig;
        try {
            XStream xstream = new XStream(new DomDriver());
            xstream.processAnnotations(GameServerConfig.class);
            gameServerConfig = (GameServerConfig) xstream.fromXML(inputStream);
        } finally {
            try {
                inputStream.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        return gameServerConfig;
    }
}
