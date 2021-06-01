/**
 * @Title: ChatDataManager.java
 * @Package com.game.manager
 * @Description:
 * @author ZhangJun
 * @date 2015年9月21日 下午4:01:21
 * @version V1.0
 */
package com.game.manager;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Component;

import com.game.chat.domain.Chat;
import com.game.pb.CommonPb;

/**
 * @author ZhangJun
 * @ClassName: ChatDataManager
 * @Description: 广播数据处理
 * @date 2015年9月21日 下午4:01:21
 */
@Component
public class ChatDataManager {
    static final int MAX_CHAT_COUNT = 15;

    private LinkedList<CommonPb.Chat> world = new LinkedList<>();

    private Map<Integer, LinkedList<CommonPb.Chat>> party = new HashMap<Integer, LinkedList<CommonPb.Chat>>();

    private LinkedList<CommonPb.Chat> corss = new LinkedList<>();

    /**
     * @param chat
     * @return CommonPb.Chat
     * @Title: addWorldChat
     * @Description: 增加世界发言（增加到序列化对象列表）
     */
    public CommonPb.Chat addWorldChat(Chat chat) {
        chat.setChannel(Chat.WORLD_CHANNEL);
        CommonPb.Chat b = chat.ser(0);
        world.add(b);
        if (world.size() > MAX_CHAT_COUNT) {
            world.removeFirst();
        }
        return b;
    }


    /**
     * @param chat
     * @param style
     * @return CommonPb.Chat
     * @Title: addHornChat
     * @Description: 增加大喇叭广播（增加到序列化对象列表）
     */
    public CommonPb.Chat addHornChat(Chat chat, int style) {
        chat.setChannel(Chat.WORLD_CHANNEL);
        CommonPb.Chat b = chat.ser(style);
        world.add(b);
        if (world.size() > MAX_CHAT_COUNT) {
            world.removeFirst();
        }
        return b;
    }

    /**
     * @param chat
     * @return CommonPb.Chat
     * @Title: createPrivateChat
     * @Description: 创建私聊（序列化对象）
     */
    public CommonPb.Chat createPrivateChat(Chat chat) {
        chat.setChannel(Chat.PRIVATE_CHANNEL);
        CommonPb.Chat b = chat.ser(0);
        return b;
    }

    /**
     * @param chat
     * @param partyId
     * @return CommonPb.Chat
     * @Title: addPartyChat
     * @Description: 增加军团发言（增加到序列化对象列表）
     */
    public CommonPb.Chat addPartyChat(Chat chat, int partyId) {
        chat.setChannel(Chat.PARTY_CHANNEL);

        LinkedList<CommonPb.Chat> list = party.get(partyId);
        if (list == null) {
            list = new LinkedList<>();
            party.put(partyId, list);
        }
        CommonPb.Chat b = chat.ser(0);
        list.add(b);

        if (list.size() > MAX_CHAT_COUNT) {
            list.removeFirst();
        }
        return b;
    }

    /**
     * 添加跨服聊天记录
     *
     * @param chat
     */
    public void addCrossChat(CommonPb.Chat chat) {
        corss.add(chat);
        if (corss.size() > MAX_CHAT_COUNT) {
            corss.removeFirst();
        }
    }

    /**
     * 增加跨服世界发言
     *
     * @param chat
     * @return
     */
    public CommonPb.Chat addCrossChat(Chat chat) {
        chat.setChannel(Chat.CROSSTEAM_CHANNEL);
        CommonPb.Chat b = chat.ser(0);
        corss.add(b);
        if (corss.size() > MAX_CHAT_COUNT) {
            corss.removeFirst();
        }
        return b;
    }


    public List<CommonPb.Chat> getWorldChat() {
        return world;
    }

    public List<CommonPb.Chat> getPartyChat(int partyId) {
        return party.get(partyId);
    }

    /**
     * 获取组队跨服聊天记录
     * @return
     */
    public List<CommonPb.Chat> getCrossChat() {
        return corss;
    }

}
