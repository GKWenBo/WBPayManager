//
//  WBPayManager.h
//  WBPayManagerDemo
//
//  Created by Admin on 2018/1/4.
//  Copyright © 2018年 WENBO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//此处必须保证在Info.plist 中的 URL Types 的 Identifier 对应一致
UIKIT_EXTERN NSString * const ALIPAY_URLIDENTIFIER;/**  支付宝URL NAME  */
UIKIT_EXTERN NSString * const WECHAT_URLIDENTIFIER;/**  微信URL NAME  */

/**  回调状态枚举  */
typedef NS_ENUM(NSInteger,WBPayStatusCode) {
    WBPayStatusSuccess,/**  成功  */
    WBPayStatusFailure,/**  失败  */
    WBPayStatusCancel /**  取消  */
};

typedef void(^WBPayCompleteCallBack)(WBPayStatusCode errorCode,NSString * errorStr);

@interface WBPayManager : NSObject

/**
 *  支付工具类例
 *
 *  @return 单例
 */
+ (instancetype)shareManager;

/**
 *  处理跳转
 *
 *  @param url 跳转地址
 *  @return 是否跳转
 */
- (BOOL)wb_handleUrl:(NSURL *)url;

/**
 *  注册App，需要在 didFinishLaunchingWithOptions 中调用
 */
- (void)wb_registerApp;

/**
 *  发起支付
 *
 *  @param orderInfo  传入订单信息,如果是字符串，则对应是跳转支付宝支付；如果传入PayReq 对象，这跳转微信支付,注意，不能传入空字符串或者nil
 *  @param payCallBack 支付结果回调
 */
- (void)wb_payWithOrderInfo:(id)orderInfo
                payCallBack:(WBPayCompleteCallBack)payCallBack;

@end
