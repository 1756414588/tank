package merge.v2.thread;

import com.game.dao.impl.p.SmallIdDao;
import com.game.domain.p.Arena;
import com.game.domain.p.SmallId;
import com.game.util.LogUtil;
import com.game.util.TimeHelper;
import merge.MServer;
import merge.v2.MergeDataMgr;
import merge.v2.MergePartyUtils;
import merge.v2.MergePlayerUtils;
import org.springframework.util.CollectionUtils;

import java.util.List;
import java.util.concurrent.CountDownLatch;

/**
 * @author zhangdh
 * @ClassName: MergeSlaveThread
 * @Description:
 * @date 2017-08-07 21:39
 */
public class MergeSlaveThread extends Thread {
    private MServer slave;
    private MergeDataMgr dataMgr;
    private CountDownLatch countDownLatch;
    private int sid;
    private String name;

    public MergeSlaveThread(MergeDataMgr dataMgr, MServer slave, CountDownLatch countDownLatch) {
        this.dataMgr = dataMgr;
        this.slave = slave;
        this.sid = slave.getServerId();
        this.name = slave.getServerName();
        this.countDownLatch = countDownLatch;
        setName("SLAVE_MERGE-" + slave.getServerId());
    }

    @Override
    public void run() {
        LogUtil.error(String.format("start merge server id :%d, name :%s", sid, name));
        int startSec = TimeHelper.getCurrentSecond();
        slaveMerge();
        countDownLatch.countDown();
        LogUtil.error(String.format("merge server id:%d, name :%s, cost :%s", sid, name, TimeHelper.getCurrentSecond() - startSec));
    }


    public void slaveMerge() {
        try {

            //设置小号
            SmallIdDao smallDao = slave.myBatisM.getSmallIdDao();
            smallDao.truncateSmallIdTable();
            //小于指定等级并且30天未登录
            smallDao.insertAllNewSmallId(MergeDataMgr.SMALL_LORD_LEVEL);
            //没有创建account或者没有创建角色名的也是小号
            smallDao.clearNotFountInAccountTablePlayer();
            //相同的accountKey和serverId 的玩家等级低的需要添加到小号表中
            if (!CollectionUtils.isEmpty(slave.getNeedAddSmallIdLords())) {
                for (Long lordId : slave.getNeedAddSmallIdLords()) {
                    SmallId smallId1 = smallDao.selectSmallId(lordId);
                    if (smallId1 == null) {
                        SmallId smallId = new SmallId();
                        smallId.setLordId(lordId);
                        smallDao.insertSmallId(smallId);
                    }
                }
            }


            LogUtil.error(String.format("server id :%d, sname :%s, handler small id finish", sid, name));

            //1.合并工会信息
            MergePartyUtils.mergeParty(dataMgr, slave);
            LogUtil.error(String.format("server id :%d, sname :%s, merge party finish", sid, name));

            //2.合并玩家
            MergePlayerUtils.mergePlayerInThread(dataMgr, slave);
            LogUtil.error(String.format("server id :%d, sname :%s, merge player finish", sid, name));

            //3.加载竞技场玩家，以备后续处理
            List<Arena> arenas = slave.myBatisM.getArenaDao().loadArenaNotInSmallIds();
            int arena_count = 0;
            if (arenas != null && !arenas.isEmpty()) {
                dataMgr.addArena(slave.getServerId(), arenas);
                arena_count = arenas.size();
            }
            LogUtil.error(String.format("sid :%d, name :%s, load arena data finish count :%d", sid, name, arena_count));
        } catch (Exception e) {
            LogUtil.error("合服报错", e);
            System.exit(-1);
        }
    }
}
