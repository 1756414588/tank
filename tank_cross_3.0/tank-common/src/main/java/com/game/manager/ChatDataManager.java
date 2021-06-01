package com.game.manager;

import com.game.domain.p.chat.domain.Chat;
import com.game.pb.CommonPb;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

@Component
public class ChatDataManager {
    static final int MAX_CHAT_COUNT = 15;

    private LinkedList<CommonPb.Chat> world = new LinkedList<>();

    private Map<Integer, LinkedList<CommonPb.Chat>> party =
            new HashMap<Integer, LinkedList<CommonPb.Chat>>();

    public CommonPb.Chat addWorldChat(Chat chat) {
        chat.setChannel(Chat.WORLD_CHANNEL);
        CommonPb.Chat b = chat.ser(0);
        world.add(b);
        if (world.size() > MAX_CHAT_COUNT) {
            world.removeFirst();
        }
        return b;
    }

    public CommonPb.Chat addHornChat(Chat chat, int style) {
        chat.setChannel(Chat.WORLD_CHANNEL);
        CommonPb.Chat b = chat.ser(style);
        world.add(b);
        if (world.size() > MAX_CHAT_COUNT) {
            world.removeFirst();
        }
        return b;
    }

    public CommonPb.Chat createPrivateChat(Chat chat) {
        chat.setChannel(Chat.PRIVATE_CHANNEL);
        CommonPb.Chat b = chat.ser(0);
        return b;
    }

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

    public List<CommonPb.Chat> getWorldChat() {
        return world;
    }

    public List<CommonPb.Chat> getPartyChat(int partyId) {
        return party.get(partyId);
    }
}
