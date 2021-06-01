package com.game.server.executor;

import com.game.message.handler.Handler;
import com.game.util.LogUtil;

import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

/**
 * @ClassName: NonOrderedQueuePoolExecutor
 * @Description: 不使用队列 立即执行任务 调用execute执行
 * @author ZhangJun
 * @date 2015年7月29日 下午7:42:00
 * 
 */
public class NonOrderedQueuePoolExecutor extends ThreadPoolExecutor {

    
	public NonOrderedQueuePoolExecutor(int corePoolSize) {
		super(corePoolSize, corePoolSize, 30, TimeUnit.SECONDS, new LinkedBlockingQueue<Runnable>());
	}

	public void execute(Handler command) {
		Work work = new Work(command);
		execute(work);
	}

	private class Work implements Runnable {

		private Handler command;

		public Work(Handler command) {
			this.command = command;
		}

		@Override
		public void run() {
			try {
				long start = System.currentTimeMillis();
				command.action();
				long end = System.currentTimeMillis();
				if (end - start > 50)
				{
//					LogHelper.HAUST_LOGGER.trace("NonOrderedQueuePoolExecutor-->" + command.getClass().getSimpleName() + " run:" + (end - start));
					LogUtil.haust("NonOrderedQueuePoolExecutor-->" + command.getClass().getSimpleName() + " run:" + (end - start));
				}
			} catch (Exception e) {
//				LogHelper.ERROR_LOGGER.error(e, e);
				LogUtil.error("command.getClass().getSimpleName() Exception", e);
			}

		}
	}
}
