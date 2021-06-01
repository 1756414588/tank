package com.account.handle;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.context.ContextLoader;

import com.account.constant.GameError;
import com.account.msg.MessageBase;
import com.account.util.MessageHelper;
import com.account.util.PrintHelper;
import com.game.pb.AccountPb;
import com.game.pb.BasePb;
import com.game.pb.BasePb.Base;
import com.game.pb.InnerPb;
import com.google.protobuf.ExtensionRegistry;
import com.google.protobuf.GeneratedMessage;
import com.google.protobuf.InvalidProtocolBufferException;

abstract public class MessageHandle {
    public Logger LOG = LoggerFactory.getLogger(this.getClass());

    class PbMsg {
        public MessageBase msg;
        public GeneratedMessage.GeneratedExtension<Base, ?> req;
        public GeneratedMessage.GeneratedExtension<Base, ?> res;
    }

    private Map<String, MessageBase> messageBump;
    private Map<Integer, PbMsg> pbMessageBump;
    // private Map<Integer, MessageBase> pbMessageBump;

    public static ExtensionRegistry PB_EXTENDSION_REGISTRY = ExtensionRegistry.newInstance();

    static {
        BasePb.registerAllExtensions(PB_EXTENDSION_REGISTRY);
        AccountPb.registerAllExtensions(PB_EXTENDSION_REGISTRY);
        InnerPb.registerAllExtensions(PB_EXTENDSION_REGISTRY);
    }

    public void init() {
        messageBump = new HashMap<String, MessageBase>();
        pbMessageBump = new HashMap<>();
        this.addMessage();
    }

    abstract public void addMessage();

    public JSONArray handle(JSONArray requests, Long lordId) {
        return this.dealMsgs(requests);
    }

    public byte[] handle(byte[] requests) throws IOException {
        byte[] back = this.dealMsgs(requests);
        LOG.error("[back msgs][len]:" + back.length);
        return back;
    }

    public JSONArray dealMsgs(JSONArray requests) {
        JSONArray backMsgs = new JSONArray();
        for (int i = 0; i < requests.size(); i++) {
            JSONObject req = requests.getJSONObject(i);
            JSONObject backMsg = route(req);
            backMsgs.add(backMsg);
        }

        return backMsgs;
    }

    public byte[] dealMsgs(byte[] data) throws IOException {

        ByteArrayOutputStream output = new ByteArrayOutputStream();
        int totalLen = data.length;
        int curLen = 0;

        int index = 0;
        while (true) {
            if (totalLen - curLen <= 2) {
                break;
            }
            index++;
            short len = MessageHelper.getShort(data, 0);
            curLen += 2;
            byte[] packet = new byte[len];

            System.arraycopy(data, curLen, packet, 0, len);
            byte[] backPacket = route(packet);
            if (backPacket == null) {
                return output.toByteArray();
            }

            output.write(MessageHelper.putShort((short) backPacket.length));
            output.write(backPacket);
            curLen += len;
        }

        return output.toByteArray();
    }

    public JSONObject route(JSONObject request) {
        String cmd = MessageHelper.getRequestCmd(request);
        MessageBase executer = messageBump.get(cmd);
        if (executer == null) {
            return new JSONObject();
        }
        return executer.execute(request);
    }

    public byte[] route(byte[] packet) throws InvalidProtocolBufferException {
        Base base = Base.parseFrom(packet, PB_EXTENDSION_REGISTRY);
        LOG.error(base.toString());
        if (!base.hasCmd()) {
            return null;
        }

        int cmd = base.getCmd();
        PbMsg pbMsg = pbMessageBump.get(cmd);
        if (pbMsg == null) {
            return null;
        }

        MessageBase executer = pbMsg.msg;
        if (executer == null) {
            return null;
        }

        Base.Builder builder = Base.newBuilder();
        GameError gameError = executer.execute(base.getExtension(pbMsg.req), builder);
        builder.setCmd(cmd + 1);
        builder.setCode(gameError.getCode());
        Base out = builder.build();
        LOG.error(out.toString());
        return out.toByteArray();
    }

    protected Object getPbExtension(Base base, GeneratedMessage.GeneratedExtension<Base, ?> ext) {
        return base.getExtension(ext);
    }

    protected void registerMessage(String name, Class<?> c) {
        messageBump.put(name, (MessageBase) ContextLoader.getCurrentWebApplicationContext().getBean(c));
    }

    protected void registerPbMessage(int cmd, Class<?> c, GeneratedMessage.GeneratedExtension<Base, ?> rq, GeneratedMessage.GeneratedExtension<Base, ?> rs) {
        PbMsg pbMsg = new PbMsg();
        pbMsg.msg = (MessageBase) ContextLoader.getCurrentWebApplicationContext().getBean(c);
        pbMsg.req = rq;
        pbMsg.res = rs;
        pbMessageBump.put(cmd, pbMsg);
    }
}
