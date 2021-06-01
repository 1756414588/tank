/**   
* @Title: AbstractWork.java    
* @Package com.game.server.work    
* @Description:   
* @author ZhangJun   
* @date 2015年7月29日 下午7:47:47    
* @version V1.0   
*/
package com.game.server.work;

import com.game.server.structs.TasksQueue;


/**   
 * @ClassName: AbstractWork    
 * @Description:     消息指令处理的基类 
 * @author ZhangJun   
 * @date 2015年7月29日 下午7:47:47    
 *         
 */
public abstract class AbstractWork implements Runnable {

	private TasksQueue<AbstractWork> tasksQueue;

	public TasksQueue<AbstractWork> getTasksQueue() {
		return tasksQueue;
	}

	public void setTasksQueue(TasksQueue<AbstractWork> tasksQueue) {
		this.tasksQueue = tasksQueue;
	}
}
