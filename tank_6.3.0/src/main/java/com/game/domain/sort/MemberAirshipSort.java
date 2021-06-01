package com.game.domain.sort;

import com.game.util.UnsafeSortInfo;

/**
 * @author zhangdh
 * @ClassName: MemberSort
 * @Description:
 * @date 2017-05-29 23:04
 */
public class MemberAirshipSort implements UnsafeSortInfo.ISortVO<MemberAirshipSort> {
    //军团职位
    private int job;
    //军衔
    private int ranks;
    //战力
    private long fight;
    //军团总贡献
    private int donate;
    //指挥官ID
    private long lordId;
    //排序对象对应的索引值
    private String key;

    public MemberAirshipSort(int job, int ranks, long fight, int donate, long lordId) {
        this.job = job;
        this.ranks = ranks;
        this.fight = fight;
        this.donate = donate;
        this.lordId = lordId;
        this.key = String.valueOf(lordId);
    }

    public int getJob() {
        return job;
    }

    public int getRanks() {
        return ranks;
    }

    public long getFight() {
        return fight;
    }

    public int getDonate() {
        return donate;
    }

    public long getLordId() {
        return lordId;
    }

    @Override
    public String getKey() {
        return key;
    }

    @Override
    public long getValue() {
        return 0;
    }

    @Override
    public int compareTo(MemberAirshipSort o) {
        if (job > o.job) {
            return -1;
        } else if (job < o.job) {
            return 1;
        } else {
            if (ranks > o.ranks) {
                return -1;
            } else if (ranks < o.ranks) {
                return 1;
            } else {
                if (fight > o.fight) {
                    return -1;
                } else if (fight < o.fight) {
                    return 1;
                } else {
                    if (donate > o.donate) {
                        return -1;
                    } else if (donate < o.donate) {
                        return 1;
                    } else {
                        return lordId < o.lordId ? -1 : lordId > o.lordId ? 1 : 0;
                    }
                }
            }
        }
    }
}
