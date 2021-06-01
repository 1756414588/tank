package merge.v2.thread;

import com.game.util.LogUtil;
import com.game.util.TimeHelper;
import merge.MServer;
import merge.v2.MergeDataMgr;
import merge.v2.MergePlayerUtils;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CountDownLatch;

/**
 * @author zhangdh
 * @ClassName: MergePlayerThread
 * @Description: 处理合服玩家的线程
 * @date 2017-08-07 19:46
 */
public class MergePlayerThread extends Thread {

    private final MergeDataMgr dataMgr;
    private final MServer slave;
    private final List<Long> handIds;
    private final CountDownLatch countDownLatch;

    public MergePlayerThread(MergeDataMgr dataMgr, MServer slave, CountDownLatch countDownLatch, int idx) {
        this.dataMgr = dataMgr;
        this.slave = slave;
        this.countDownLatch = countDownLatch;
        this.handIds = new ArrayList<>();
        setName("thread-lordHander-" + idx);
    }

    public void addHandLord(long lordId) {
        handIds.add(lordId);
    }

    @Override
    public void run() {
        int startSec = TimeHelper.getCurrentSecond();
        for (Long lordId : handIds) {
            MergePlayerUtils.mergePlayer(dataMgr, slave, lordId, startSec);
        }
        countDownLatch.countDown();
        LogUtil.error(String.format("%s, hand lord count :%d, cost :%d", getName(), handIds.size(), TimeHelper.getCurrentSecond() - startSec));
    }
}
