package com.game.server.thread;

import com.game.domain.p.Party;
import com.game.manager.PartyDataManager;
import com.game.server.GameServer;
import com.game.util.LogUtil;
import com.game.util.SqlPrintHelper;

import java.util.HashMap;
import java.util.concurrent.LinkedBlockingQueue;

/**
 * @author ZhangJun
 * @ClassName: SavePartyThread
 * @Description:
 * @date 2015年8月24日 上午9:53:32
 */
public class SavePartyThread extends SaveThread {
    // 命令执行队列
    private LinkedBlockingQueue<Integer> party_queue = new LinkedBlockingQueue<Integer>();

    private HashMap<Integer, Party> party_map = new HashMap<Integer, Party>();

    private PartyDataManager partyDataManager;

    private static int MAX_SIZE = 10000;


    public SavePartyThread(String threadName) {
        super(threadName);
        dataType = 2;
        this.partyDataManager = GameServer.ac.getBean(PartyDataManager.class);
    }


    @Override
    public void run() {
        stop = false;
        done = false;
        while (!stop || party_queue.size() > 0) {
            Party party = null;
            synchronized (this) {
                Integer partyId = party_queue.poll();
                if (partyId != null) {
                    party = party_map.remove(partyId);
                }
            }
            if (party == null) {
                try {
                    synchronized (this) {
                        wait();
                    }
                } catch (InterruptedException e) {
                    LogUtil.error(threadName + " Wait Exception:" + e.getMessage(), e);
                }
            } else {
                if (party_queue.size() > MAX_SIZE) {
                    party_queue.clear();
                    party_map.clear();
                }
                try {

                    partyDataManager.updatePartyData(party);
                    if (logFlag) {
                        saveCount++;
                    }
                } catch (Exception e) {
                    LogUtil.error("Party Exception UPDATE SQL: " + SqlPrintHelper.printUpdateParty(party), e);
                    LogUtil.warn("Role save Exception");

                    // 记录出错次数
                    addErrorCount(("保存军团数据出错, partyId:" + (party == null ? "军团信息为空" : party.getPartyId())));

                }
            }
        }

        done = true;
        LogUtil.stop("SaveParty [{}] stopped, save done saveCount = {}", threadName, saveCount);
    }


    @Override
    public void add(Object object) {
        try {
            Party party = (Party) object;
            synchronized (this) {
                if (!party_map.containsKey(party.getPartyId())) {
                    this.party_queue.add(party.getPartyId());
                }
                this.party_map.put(party.getPartyId(), party);
                notify();
            }
        } catch (Exception e) {
            LogUtil.error(threadName + " Notify Exception:" + e.getMessage(), e);
        }
    }

}
