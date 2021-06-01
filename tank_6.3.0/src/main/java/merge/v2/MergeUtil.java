package merge.v2;

import com.game.dao.impl.p.AccountDao;
import com.game.domain.p.Account;
import com.game.domain.p.Lord;
import com.game.util.LogUtil;
import merge.MServer;
import merge.v2.thread.MergeSlaveThread;
import org.springframework.util.CollectionUtils;

import java.util.*;
import java.util.concurrent.CountDownLatch;

/**
 * @author zhangdh
 * @ClassName: MergeUtil
 * @Description:
 * @date 2017-08-07 18:18
 */
public class MergeUtil {

    public static void mergeSlaveInThread(MergeDataMgr dataMgr, List<MServer> slaves) {
        CountDownLatch countDownLatch = new CountDownLatch(slaves.size());

        checkSlaveDb(slaves);
        processSameAccount(slaves);
        processSameLordId(slaves);

        for (MServer slave : slaves) {
            LogUtil.error(String.format("prepare to merge slave id :%d, sname :%s", slave.getServerId(), slave.getServerName()));
            MergeSlaveThread thread = new MergeSlaveThread(dataMgr, slave, countDownLatch);
            thread.start();
        }

        while (countDownLatch.getCount() > 0) {
            LogUtil.common("slave count down  " + countDownLatch.getCount());
            try {
                Thread.sleep(3000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }

        try {
            countDownLatch.await();
        } catch (InterruptedException e) {
            LogUtil.error("多线程模块错误，请联系开发人员，同时删除Master库，以便重新合服", e);
        }

        LogUtil.error("all slave servers merge lord data finish, start merge arena data...");
        //合并竞技场
        MergeArenaUtils.mergeArena(dataMgr);
        LogUtil.error("merge arena finish");

        //*********数据已经全部处理到Master中了************

        //3.更新军团中军团长名字
        dataMgr.updatePartyLegatusName();
        LogUtil.error("update party legatus name finish");


        LogUtil.error("开始处理世界矿点等级合并后");
        MergeGlobalUtils.mergeGlobal(dataMgr, slaves);

        int totalCount = dataMgr.selectMasterLordCount();
        LogUtil.error(String.format("merge game succ, lord count :%d", totalCount));
    }

    private static void checkSlaveDb(List<MServer> slaves) {
        for (MServer slave : slaves) {
            if (slave.myBatisM == null) {
                LogUtil.error(String.format("sid :%d, sname :%s, db dao not found ", slave.getServerId(), slave.getServerName()));
                LogUtil.error("================ 合服失败 ==========================");
                System.exit(-1);
            }

            if (slave.myBatisM.getSmallIdDao() == null) {
                LogUtil.error(String.format("sid :%d, sname :%s, db dao not init ", slave.getServerId(), slave.getServerName()));
                LogUtil.error("================ 合服失败 ==========================");
                System.exit(-1);
            }

            if (slave.myBatisM.getAccountDao() == null) {
                LogUtil.error(String.format("sid :%d, sname :%s, db dao not init ", slave.getServerId(), slave.getServerName()));
                LogUtil.error("================ 合服失败 ==========================");
                System.exit(-1);
            }

            if (slave.myBatisM.getLordDao() == null) {
                LogUtil.error(String.format("sid :%d, sname :%s, db dao not init ", slave.getServerId(), slave.getServerName()));
                LogUtil.error("================ 合服失败 ==========================");
                System.exit(-1);
            }
        }
    }

    /**
     * 合服时处理有相同的lordId的数据
     *
     * @param slaves
     */
    public static void processSameLordId(List<MServer> slaves) {


        Map<Long, SameLordVo> lordVoMap = new HashMap<>(10000);

        Map<Long, SameLordVo> sameLordVoMap = new HashMap<>(1000);


        for (MServer slave : slaves) {
            List<Lord> lords = slave.myBatisM.getLordDao().load();
            for (Lord lord : lords) {

                if (!lordVoMap.containsKey(lord.getLordId())) {
                    SameLordVo sameLordVo = new SameLordVo();
                    sameLordVo.setRoleId(lord.getLordId());
                    sameLordVo.setSameLordList(new ArrayList<SameLord>());
                    lordVoMap.put(lord.getLordId(), sameLordVo);
                }

                SameLordVo sameLordVo = lordVoMap.get(lord.getLordId());
                SameLord sameLord = new SameLord();
                sameLord.setSlave(slave);
                sameLord.setLevel(lord.getLevel());
                sameLord.setName(lord.getNick());
                sameLord.setRoleId(lord.getLordId());
                sameLordVo.getSameLordList().add(sameLord);
                if (sameLordVo.getSameLordList().size() > 1) {
                    sameLordVoMap.put(lord.getLordId(), sameLordVo);
                }
            }

        }


        if (CollectionUtils.isEmpty(sameLordVoMap)) {
            return;
        }

        LogUtil.error("%%%%%%%%%%处理相同 lordId 的玩家-->共有{}个玩家 ", sameLordVoMap.size());


        for (SameLordVo sameLordVo : sameLordVoMap.values()) {

            List<SameLord> sameLordList = sameLordVo.getSameLordList();

            for (SameLord sameLord : sameLordList) {
                Account account = sameLord.getSlave().myBatisM.getAccountDao().selectAccountByLordId(sameLord.getRoleId());

                if (account != null) {
                    if (account.getCreateDate() != null) {
                        sameLord.setCreateTime(account.getCreateDate().getTime());
                    }
                    sameLord.setServerId(account.getServerId());
                }

                LogUtil.error("%%%%%%%%%%处理相同 lordId 的玩家-->玩家信息 1 lordId={} ,serverId={},name={},roleId={},level={} ", sameLord.getRoleId(), sameLord.getServerId(), sameLord.getName(), sameLord.getRoleId(), sameLord.getLevel());
            }

            LogUtil.error("-----------------------{}","");
        }
        for (SameLordVo sameLordVo : sameLordVoMap.values()) {
            List<SameLord> sameLordList = sameLordVo.getSameLordList();


            Collections.sort(sameLordList, new Comparator<SameLord>() {
                @Override
                public int compare(SameLord o1, SameLord o2) {

                    if (o1.getLevel() == o2.getLevel()) {

                        long createTime = o1.getCreateTime();
                        long createTime2 = o2.getCreateTime();

                        if (createTime > createTime2) {
                            return -1;
                        } else if (createTime < createTime2) {
                            return 1;
                        } else {
                            return 0;
                        }
                    }
                    return o1.getLevel() > o2.getLevel() ? -1 : 1;
                }
            });


            SameLord remove = sameLordList.remove(0);
            LogUtil.error("%%%%%%%%%%处理相同 lordId 的玩家-->保留等级最高的玩家 2 lordId={} ,serverId={},name={},roleId={},level={} ", remove.getRoleId(), remove.getServerId(), remove.getName(), remove.getRoleId(), remove.getLevel());

            for (SameLord sameLord : sameLordList) {
                sameLord.getSlave().getNeedAddSmallIdLords().add(sameLord.getRoleId());
                LogUtil.error("%%%%%%%%%%处理相同 lordId 的玩家-->需要放入小号表的玩家 3 key={} ,serverId={},name={},roleId={},level={} ", sameLord.getRoleId(), sameLord.getServerId(), sameLord.getName(), sameLord.getRoleId(), sameLord.getLevel());
            }

            LogUtil.error("============================={}","");

        }

    }

    /**
     * 合服时，处理有相同的accountKey和serverId的Account的数据
     *
     * @param slaves
     */
    public static void processSameAccount(List<MServer> slaves) {

        Map<String, SameAccountVo> accountVoMap = new HashMap<>(10000);

        Map<String, SameAccountVo> sameAccountVoMap = new HashMap<>(1000);

        for (MServer slave : slaves) {
            AccountDao accountDao = slave.myBatisM.getAccountDao();
            List<Account> accounts = accountDao.load();

            for (Account account : accounts) {
                String key = account.getAccountKey() + "-" + account.getServerId();
                if (!accountVoMap.containsKey(key)) {
                    SameAccountVo sameAccountVo = new SameAccountVo();
                    sameAccountVo.setAccountKey(account.getAccountKey());
                    sameAccountVo.setServerId(account.getServerId());
                    sameAccountVo.setSameAccount(new ArrayList<SameAccount>());
                    accountVoMap.put(key, sameAccountVo);
                }
                SameAccount sameAccount = new SameAccount();
                sameAccount.setAccount(account);
                sameAccount.setSlave(slave);
                SameAccountVo sameAccountVo = accountVoMap.get(key);
                List<SameAccount> sameAccount1 = sameAccountVo.getSameAccount();
                sameAccount1.add(sameAccount);

                if (sameAccount1.size() > 1) {
                    sameAccountVoMap.put(key, sameAccountVo);
                }

            }
        }


        if (CollectionUtils.isEmpty(sameAccountVoMap)) {
            return;
        }

        LogUtil.error("^^^^^^处理相同key的玩家-->共有{}个玩家 accountKey和serverId 相同", sameAccountVoMap.size());


        for (SameAccountVo sameAccountVo : sameAccountVoMap.values()) {
            List<SameAccount> sameAccountList = sameAccountVo.getSameAccount();
            for (SameAccount sameAccount : sameAccountList) {
                Lord lord = sameAccount.getSlave().myBatisM.getLordDao().selectLordById(sameAccount.getAccount().getLordId());
                if (lord != null) {
                    sameAccount.setLevel(lord.getLevel());
                    sameAccount.setName(lord.getNick());
                    sameAccount.setRoleId(lord.getLordId());
                    LogUtil.error("^^^^^^处理相同key的玩家-->玩家信息 1 key={} ,serverId={},name={},roleId={},level={} ", sameAccountVo.getKey(), sameAccount.getAccount().getServerId(), lord.getNick(), lord.getLordId(), lord.getLevel());
                }
            }

            LogUtil.error("-----------------------{}","");
        }

        for (SameAccountVo sameAccountVo : sameAccountVoMap.values()) {
            List<SameAccount> sameAccountList = sameAccountVo.getSameAccount();

            Collections.sort(sameAccountList, new Comparator<SameAccount>() {
                @Override
                public int compare(SameAccount o1, SameAccount o2) {

                    if (o1.getLevel() == o2.getLevel()) {

                        Date createDate = o1.getAccount().getCreateDate();
                        Date createDate2 = o2.getAccount().getCreateDate();

                        if (createDate == null) {
                            return -1;
                        }

                        if (createDate2 == null) {
                            return -1;
                        }
                        if (createDate == null && createDate2 == null) {
                            return 0;
                        }
                        if (createDate.getTime() > createDate2.getTime()) {
                            return -1;
                        } else if (createDate.getTime() < createDate2.getTime()) {
                            return 1;
                        } else {
                            return 0;
                        }
                    }
                    return o1.getLevel() > o2.getLevel() ? -1 : 1;
                }
            });


            SameAccount sameAccountFirst = sameAccountList.remove(0);
            LogUtil.error("^^^^^^处理相同key的玩家-->保留等级最高的玩家 2 key={} ,serverId={},name={},roleId={},level={} ", sameAccountVo.getKey(), sameAccountFirst.getAccount().getServerId(), sameAccountFirst.getName(), sameAccountFirst.getRoleId(),
                    sameAccountFirst.getLevel());

            for (SameAccount sameAccount : sameAccountList) {
                sameAccount.getSlave().getNeedAddSmallIdLords().add(sameAccount.getRoleId());
                LogUtil.error("^^^^^^处理相同key的玩家-->需要放入小号表的玩家 3 key={} ,serverId={},name={},roleId={},level={} ", sameAccountVo.getKey(), sameAccount.getAccount().getServerId(), sameAccount.getName(), sameAccount.getRoleId(), sameAccount.getLevel());
            }

            LogUtil.error("============================={}","");
        }

    }
}