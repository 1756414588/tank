package com.game.server.Actor;

import com.game.domain.Player;
import com.game.util.NumberHelper;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.*;

/**
 * @author zhangdh
 * @ClassName: ActorManager
 * @Description: 将一些actor初始化
 * @date 2017/4/1 10:53
 */
@Component
public class ActorDataManager {
    private Map<String, Actor> actorMap = new ConcurrentHashMap<>();
    private ExecutorService executorService;
    LinkedBlockingQueue<Runnable> queue = new LinkedBlockingQueue<>();


    //玩家登录日志发送Actor处理
    private static final String LOG_ACTOR = "LOG_ROLE_LOGIN_ACTOR";
    private Actor logActor = new Actor(LOG_ACTOR, NumberHelper.I_MILLION, this);

    //玩家Actor
    private static final String PLAYER_ACTOR = "PLAYER_ACTOR-";
    private static final int PLAYER_ACTOR_COUNT = 50;//玩家Actor数量
    private static Map<Integer, Actor> playerActors = new HashMap<>();

    //排行版Actor
    //排行榜Actor队列长队
    private static final String RANK_ACTOR = "RANK_ACTOR";
    private Actor rankActor = new Actor(RANK_ACTOR, NumberHelper.I_MILLION , this);


    //记录玩家装备信息
    private static final String LOG_PLAYER_ACT = "LOG_PLAYER_ACT";
    private Actor logPlayerActor = new Actor(LOG_PLAYER_ACT, NumberHelper.I_MILLION, this);

    private static final String SERVER_ACTOR = "SERVER_ACTOR";
    private Actor serverActor = new Actor(SERVER_ACTOR, NumberHelper.TEN_THOUSAND, this);
    
    public Actor regist(Actor actor) {
        if (actor == null || actor.getName() == null) {
            throw new NullPointerException("actor name is null");
        }
        return actorMap.put(actor.getName(), actor);
    }


    public void execut(Actor actor) {
        executorService.execute(actor);
    }

    @PostConstruct
    public void init() {
        //初始化线程池
        initExecutorService();

        //注册日志Actor
        regist(logActor);

        //注册排行榜Actor
        regist(rankActor);

        //玩家Actor
        for (int i = 0; i < PLAYER_ACTOR_COUNT; i++) {
            Actor actor = new OptimizeActor(PLAYER_ACTOR + i, NumberHelper.I_MILLION, this);
            regist(actor);
            playerActors.put(i, actor);
        }

        regist(logPlayerActor);

        regist(serverActor);
    }

    public void stop() {
        //不再处理新的Actor消息
        executorService.shutdown();
        //关闭日志Actor
        logActor.deactivate();
    }

    private void initExecutorService() {
        ThreadPoolExecutor.AbortPolicy policy = new ThreadPoolExecutor.AbortPolicy();
        executorService = new ThreadPoolExecutor(50, 50, 10 * 60 * 1000, TimeUnit.MILLISECONDS, queue, policy);
    }


    public Actor getLogActor() {
        return logActor;
    }

    public Actor getRankActor() {
        return rankActor;
    }

    public Actor getPlayerActor(Player player) {
        int index = (int) (player.lord.getLordId() % PLAYER_ACTOR_COUNT);
        return playerActors.get(index);
    }

    public Map<Integer, Actor> getAllPlayerActor() {
        return playerActors;
    }
    
    public Actor getLogPlayerActor() {
    	return logPlayerActor;
    }

    public Actor getServerActor() {
        return serverActor;
    }
}
