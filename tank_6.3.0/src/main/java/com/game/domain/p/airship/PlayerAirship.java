package com.game.domain.p.airship;

import com.game.pb.CommonPb;
import com.game.pb.SerializePb;

import java.util.HashMap;
import java.util.Map;

/**
 * @author zhangdh
 * @ClassName: PlayerAirship
 * @Description: 玩家自己参与飞艇信息
 * @date 2017-06-14 11:27
 */
public class PlayerAirship {
    //今日免费创建队伍的次数(注意此属性是static修饰的,PlayerAirship下的所有对象共享此字段)
    private int freeCrtCount;
    //创建免费队伍的时间(单位天), (注意此属性是static修饰的,PlayerAirship下的所有对象共享此字段)
    private int freeCrtDay;

    //KEY:飞艇ID, VALUE:飞艇侦查有效时间(结算时间)
    private Map<Integer, Integer> scoutMap = new HashMap<>();

    public PlayerAirship(){}

    public PlayerAirship(SerializePb.SerPlayerAirship pbPlayerAirship){
        this.freeCrtCount = pbPlayerAirship.getFreeCnt();
        this.freeCrtDay = pbPlayerAirship.getFreeDay();
        for (CommonPb.Kv kv : pbPlayerAirship.getScoutList()) {
            scoutMap.put(kv.getKey(), kv.getValue());
        }
    }

    public int getFreeCrtCount() {
        return freeCrtCount;
    }

    public void setFreeCrtCount(int freeCrtCount) {
        this.freeCrtCount = freeCrtCount;
    }

    public int getFreeCrtDay() {
        return freeCrtDay;
    }

    public void setFreeCrtDay(int freeCrtDay) {
        this.freeCrtDay = freeCrtDay;
    }

    public Map<Integer, Integer> getScoutMap() {
        return scoutMap;
    }

    public void setScoutMap(Map<Integer, Integer> scoutMap) {
        this.scoutMap = scoutMap;
    }
}
