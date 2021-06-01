package com.game.server.structs;

import java.util.concurrent.ConcurrentHashMap;

/**
 * 
* @ClassName: OrderedQueuePool 
* @Description: 队列池 将以键值对的形式存放ChannelHandlerContext的id（key） 和 改连接的消息队列(值)
* @author 
* @param <K>
* @param <V>
 */
public class OrderedQueuePool<K, V> {

	ConcurrentHashMap<K, TasksQueue<V>> map = new ConcurrentHashMap<K, TasksQueue<V>>();

	/**
	 * 获得任务队列
	 * 
	 * @param key ChannelHandlerContext的id
	 * @return
	 */
	public TasksQueue<V> getTasksQueue(K key) {
		synchronized (map) {
			TasksQueue<V> queue = map.get(key);

			if (queue == null) {
				queue = new TasksQueue<V>();
				map.put(key, queue);
			}

			return queue;
		}
	}

	/**
	 * 
	* @Title: getTasksQueues 
	* @Description: 获得全部任务队列
	* @return  
	* ConcurrentHashMap<K,TasksQueue<V>>   

	 */
	public ConcurrentHashMap<K, TasksQueue<V>> getTasksQueues() {
		return map;
	}

	/**
	 * 
	* @Title: removeTasksQueue 
	* @Description:  移除任务队列
	* @param key  
	* void   

	 */
	public void removeTasksQueue(K key) {
		map.remove(key);
	}
}
