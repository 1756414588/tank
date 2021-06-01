package com.game.server.task;

import com.alibaba.fastjson.JSONObject;
import com.game.server.GameServer;
import com.game.util.DateHelper;
import com.game.util.LogUtil;
import com.game.util.TimeHelper;

import java.lang.management.GarbageCollectorMXBean;
import java.lang.management.ManagementFactory;
import java.lang.management.MemoryPoolMXBean;
import java.lang.management.MemoryUsage;
import java.util.ArrayList;
import java.util.List;

/**
 * 服务器状态信息日志打印任务
 *
 * @author Tandonghai
 * @date 2018-01-18 16:13
 */
public class ServerStatusLogTask {
    public static final double KB = 1024;
    public static final double MB = KB * 1024;
    public static final double GB = MB * 1024;

    public static void print() {
        long nano = System.currentTimeMillis();

        MemoryUsage usage;
        HeapMemory memory;
        ServerStatus serverStatus = new ServerStatus();
        List<MemoryPoolMXBean> memoryPoolMXBeans = ManagementFactory.getMemoryPoolMXBeans();
        for (MemoryPoolMXBean bean : memoryPoolMXBeans) {
            usage = bean.getUsage();
            memory = new HeapMemory();
            memory.setName(bean.getName());
            memory.setCommited(usage.getCommitted());
            memory.setUsed(usage.getUsed());
            memory.setMax(usage.getMax());
            serverStatus.getMemoryList().add(memory);
        }

        Runtime runtime = Runtime.getRuntime();
        memory = new HeapMemory();
        memory.setName("Runtime");
        // 返回 Java 虚拟机中的内存总量
        memory.setCommited(runtime.totalMemory());
        //返回 Java 虚拟机中的空闲内存量。调用 gc 方法可能导致 freeMemory 返回值的增加。
        memory.setUsed(runtime.totalMemory() - runtime.freeMemory());
        //返回 Java 虚拟机试图使用的最大内存量
        memory.setMax(runtime.maxMemory());
        serverStatus.setRuntimeHeapMemory(memory);
        List<GarbageCollectorMXBean> garbageCollectorMXBeans = ManagementFactory.getGarbageCollectorMXBeans();
        for (GarbageCollectorMXBean gcBean : garbageCollectorMXBeans) {
            if (gcBean.getName().contains("MarkSweep")) {
                serverStatus.setFullGC(gcBean.getCollectionCount());
                serverStatus.setFullGCTime(gcBean.getCollectionTime());
            }
        }

        LogUtil.flow("Monitor Memory {}", serverStatus.format(System.currentTimeMillis() - nano));
    }


    public static String format(long count) {
        if (count < KB) {
            return String.format("%.2f B", count * 1.0f);
        } else if (count < MB) {
            return String.format("%.2f K", (count >>> 10) * 1.0f);
        } else if (count < GB) {
            return String.format("%.2f M", count / MB);
        } else {
            return String.format("%.2f G", count / GB);
        }
    }

}

class ServerStatus {
    private List<HeapMemory> memoryList = new ArrayList<>(4);

    private HeapMemory runtimeHeapMemory;

    private int time = TimeHelper.getCurrentSecond();
    private long fullGC;
    private long fullGCTime;

    public List<HeapMemory> getMemoryList() {
        return memoryList;
    }

    public void setFullGC(long fullGC) {
        this.fullGC = fullGC;
    }

    public void setFullGCTime(long fullGCTime) {
        this.fullGCTime = fullGCTime;
    }

    public int getTime() {
        return time;
    }

    public void setTime(int time) {
        this.time = time;
    }

    public HeapMemory getRuntimeHeapMemory() {
        return runtimeHeapMemory;
    }

    public void setRuntimeHeapMemory(HeapMemory runtimeHeapMemory) {
        this.runtimeHeapMemory = runtimeHeapMemory;
    }

    @Override
    public String toString() {
        return "ServerStatus{" + "memoryList=" + memoryList + ", fullGC=" + fullGC + ", fullGCTime=" + fullGCTime
                + ", time=" + time + '}';
    }

    public String format(long time) {


        JSONObject jsonObject = new JSONObject();

        JSONObject serverJson = new JSONObject();
        serverJson.put("statistics", time+" ms");
        serverJson.put("start-up time", DateHelper.formatTime(GameServer.getServerStartTime(),"yyyy-MM-dd HH:mm:ss"));
        float hour = (System.currentTimeMillis()-GameServer.getServerStartTime())/1000.0f/60/60;
        serverJson.put("start-up hour", hour);
        jsonObject.put("server info", serverJson);

        JSONObject fullGCJson = new JSONObject();
        fullGCJson.put("fullGC", fullGC);
        fullGCJson.put("fullGCTime", fullGCTime);
        fullGCJson.put("avg", fullGC == 0 ? 0 : fullGCTime / fullGC * 1.0f);
        jsonObject.put("fgc", fullGCJson);

        JSONObject runtimeJson = new JSONObject();
        runtimeJson.put("Total Memory(总量)", ServerStatusLogTask.format(getRuntimeHeapMemory().getCommited()));
        runtimeJson.put("used(使用量)", ServerStatusLogTask.format(getRuntimeHeapMemory().getUsed()));
        runtimeJson.put("max(最大量)", ServerStatusLogTask.format(getRuntimeHeapMemory().getMax()));
        runtimeJson.put("used/TotalMemory(使用)", Math.round((getRuntimeHeapMemory().getUsed() / (getRuntimeHeapMemory().getCommited() * 1.0f)) * 100000) / 1000 + "%");
        runtimeJson.put("used/max(最大量使用)", Math.round((getRuntimeHeapMemory().getUsed() / (getRuntimeHeapMemory().getMax() * 1.0f)) * 100000) / 1000 + "%");
        jsonObject.put("JVM", runtimeJson);

        for (HeapMemory memory : memoryList) {
            JSONObject memoryJson = new JSONObject();
            memoryJson.put("Commited(总量)", ServerStatusLogTask.format(memory.getCommited()));
            memoryJson.put("used(使用量)", ServerStatusLogTask.format(memory.getUsed()));
            memoryJson.put("max(最大量)", ServerStatusLogTask.format(memory.getMax()));
            memoryJson.put("used/Commited(使用)", Math.round((memory.getUsed() / (memory.getCommited() * 1.0f)) * 100000) / 1000 + "%");
            memoryJson.put("used/max(最大量使用)", Math.round((memory.getUsed() / (memory.getMax() * 1.0f)) * 100000) / 1000 + "%");
            jsonObject.put(memory.getName(), memoryJson);
        }


        return jsonObject.toJSONString();
    }

}

class HeapMemory {
    private String name;
    /**
     * 返回已提交给 Java 虚拟机使用的内存量（以字节为单位）
     */
    private long commited;
    /**
     * 返回已使用的内存量（以字节为单位）
     */
    private long used;
    /**
     * 返回可以用于内存管理的最大内存量（以字节为单位）
     */
    private long max;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public long getCommited() {
        return commited;
    }

    public void setCommited(long commited) {
        this.commited = commited;
    }

    public long getUsed() {
        return used;
    }

    public void setUsed(long used) {
        this.used = used;
    }

    public long getMax() {
        return max;
    }

    public void setMax(long max) {
        this.max = max;
    }

    @Override
    public String toString() {
        return "HeapMemory{" + "name='" + name + '\'' + ", commited=" + commited + ", used=" + used + ", max=" + max
                + '}';
    }
}
