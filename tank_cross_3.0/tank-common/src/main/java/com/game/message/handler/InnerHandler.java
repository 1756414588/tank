/**
 * @Title: InnerHandler.java @Package com.game.message.handler @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年8月12日 下午2:34:44
 * @version V1.0
 */
package com.game.message.handler;

/**
 * @ClassName: InnerHandler @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年8月12日 下午2:34:44
 */
public abstract class InnerHandler extends Handler {

  /**
   * Overriding: dealType
   *
   * @return
   * @see com.game.message.handler.Handler#dealType()
   */
  @Override
  public DealType dealType() {
    // TODO Auto-generated method stub
    return DealType.MAIN;
  }
}
