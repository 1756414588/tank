/**
 * @Title: ServerHandler.java @Package com.game.message.handler @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年8月10日 下午12:18:01
 * @version V1.0
 */
package com.game.message.handler;

/**
 * @ClassName: ServerHandler @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年8月10日 下午12:18:01
 */
public abstract class ServerHandler extends Handler {
  public DealType dealType() {
    // TODO Auto-generated method stub
    return DealType.PUBLIC;
  }
}
