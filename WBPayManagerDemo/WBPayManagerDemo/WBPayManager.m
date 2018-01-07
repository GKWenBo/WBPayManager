//
//  WBPayManager.m
//  WBPayManagerDemo
//
//  Created by Admin on 2018/1/4.
//  Copyright © 2018年 WENBO. All rights reserved.
//

#import "WBPayManager.h"
#import <CommonCrypto/CommonDigest.h>

/**  < 支付宝 >  */
#import <AlipaySDK/AlipaySDK.h>
/**  < 微信 >  */
#import "WXApi.h"

NSString * const ALIPAY_URLIDENTIFIER = @"zhifubao";
NSString * const WECHAT_URLIDENTIFIER = @"weixin";

/**  回调url为空  */
#define WBTIP_CALLBACKURLISEMPTY @"url地址不能为空！"
/**  订单信息为空字符串或者nil  */
#define WBTIP_ORDERINFOISEMPTY @"订单信息不能为空！"
/**  没添加url type  */
#define WBTIP_PLEASEADDURLTYPE @"请先在Info.plist 添加 URL Type"
/**   添加了 URL Types 但信息不全  */
#define WBTIP_URLTYPE_SCHEME(name) [NSString stringWithFormat:@"请先在Info.plist 的 URL Type 添加 %@ 对应的 URL Scheme",name]

@interface WBPayManager () <WXApiDelegate>

@property (nonatomic,copy) WBPayCompleteCallBack callBack;/**  缓存回调  */
@property (nonatomic,strong) NSMutableDictionary * appSchemeDict;

@end

@implementation WBPayManager

+ (instancetype)shareManager {
    static WBPayManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc]init];
    });
    return manager;
}

- (BOOL)wb_handleUrl:(NSURL *)url {
    NSAssert(url, WBTIP_CALLBACKURLISEMPTY);
    if ([url.host isEqualToString:@"pay"]) {
        /**  微信  */
        return [WXApi handleOpenURL:url delegate:self]
        ;
    }else if ([url.host isEqualToString:@"safepay"]) {
        /**  支付宝  */
        /**  支付跳转支付宝钱包进行支付，处理支付结果(在app被杀模式下，通过这个方法获取支付结果）  */
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSString *resultStatus = resultDic[@"resultStatus"];
            NSString *errStr = resultDic[@"memo"];
            WBPayStatusCode errorCode = WBPayStatusSuccess;
            switch (resultStatus.integerValue) {
                case 9000:// 成功
                    errorCode = WBPayStatusSuccess;
                    break;
                case 6001:// 取消
                    errorCode = WBPayStatusCancel;
                    break;
                default:
                    errorCode = WBPayStatusFailure;
                    break;
            }
            if ([WBPayManager shareManager].callBack) {
                [WBPayManager shareManager].callBack(errorCode,errStr);
            }
        }];
        /**  授权跳转支付宝钱包进行支付，处理支付结果  */
        [[AlipaySDK defaultService] processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDic) {
            // 解析 auth code
            NSString *result = resultDic[@"result"];
            NSString *authCode = nil;
            if (result.length > 0) {
                NSArray *resultArr = [result componentsSeparatedByString:@"&"];
                for (NSString *subResult in resultArr) {
                    if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="]) {
                        authCode = [subResult substringFromIndex:10];
                        break;
                    }
                }
            }
            NSLog(@"授权结果 authCode = %@", authCode?:@"");
        }];
        return YES;
    }else {
        return NO;
    }
}

- (void)wb_registerApp {
    /**  info.plist 文件路径  */
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray *urlTypes = dict[@"CFBundleURLTypes"];
    NSAssert(urlTypes, WBTIP_PLEASEADDURLTYPE);
    for (NSDictionary *urlTypeDict in urlTypes) {
        NSString *urlName = urlTypeDict[@"CFBundleURLName"];
        NSArray *urlSchemes = urlTypeDict[@"CFBundleURLSchemes"];
        NSAssert(urlSchemes.count, WBTIP_URLTYPE_SCHEME(urlName));
        // 一般对应只有一个
        NSString *urlScheme = urlSchemes.lastObject;
        if ([urlName isEqualToString:WECHAT_URLIDENTIFIER]) {
            [self.appSchemeDict setValue:urlScheme forKey:WECHAT_URLIDENTIFIER];
            // 注册微信
            [WXApi registerApp:urlScheme];
        }
        else if ([urlName isEqualToString:ALIPAY_URLIDENTIFIER]){
            // 保存支付宝scheme，以便发起支付使用
            [self.appSchemeDict setValue:urlScheme forKey:ALIPAY_URLIDENTIFIER];
        }
        else{
            
        }
    }
}

- (void)wb_payWithOrderInfo:(id)orderInfo payCallBack:(WBPayCompleteCallBack)payCallBack {
    NSAssert(orderInfo, WBTIP_ORDERINFOISEMPTY);
    /**  缓存block  */
    self.callBack = payCallBack;
    
    /**  发起支付  */
    if ([orderInfo isKindOfClass:[PayReq class]]) {
        /**  判断是否安装了微信  */
//        if (![ShareSDK isClientInstalled:SSDKPlatformTypeWechat]) {
//            [SVProgressHUD showErrorWithStatus:@"尚未安装微信客户端，无法完成支付！"];
//            return;
//        }
        /**  微信  */
        NSAssert(self.appSchemeDict[WECHAT_URLIDENTIFIER], WBTIP_URLTYPE_SCHEME(WECHAT_URLIDENTIFIER));
        
        [WXApi sendReq:(BaseReq *)orderInfo];
    }else if ([orderInfo isKindOfClass:[NSString class]]) {
        /**  支付宝  */
        NSAssert(![orderInfo isEqualToString:@""], WBTIP_ORDERINFOISEMPTY);
        NSAssert(self.appSchemeDict[ALIPAY_URLIDENTIFIER], WBTIP_URLTYPE_SCHEME(ALIPAY_URLIDENTIFIER));
        
        [[AlipaySDK defaultService] payOrder:(NSString *)orderInfo fromScheme:self.appSchemeDict[ALIPAY_URLIDENTIFIER] callback:^(NSDictionary *resultDic) {
            NSString *resultStatus = resultDic[@"resultStatus"];
            NSString *errStr = resultDic[@"memo"];
            WBPayStatusCode errorCode = WBPayStatusSuccess;
            switch (resultStatus.integerValue) {
                case 9000:// 成功
                    errorCode = WBPayStatusSuccess;
                    break;
                case 6001:// 取消
                    errorCode = WBPayStatusCancel;
                    break;
                default:
                    errorCode = WBPayStatusFailure;
                    break;
            }
            if ([WBPayManager shareManager].callBack) {
                [WBPayManager shareManager].callBack(errorCode,errStr);
            }
        }];
    }
}

#pragma mark -- WXApiDelegate
#pragma mark
- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[PayResp class]]) {
        //支付回调
        WBPayStatusCode errorCode = WBPayStatusSuccess;
        NSString *errStr = resp.errStr;
        switch (resp.errCode) {
            case 0:
                errorCode = WBPayStatusSuccess;
                errStr = @"订单支付成功";
                break;
            case -1:
                errorCode = WBPayStatusFailure;
                errStr = resp.errStr;
                break;
            case -2:
                errorCode = WBPayStatusCancel;
                errStr = @"用户中途取消";
                break;
            default:
                errorCode = WBPayStatusFailure;
                errStr = resp.errStr;
                break;
        }
        if (self.callBack) {
            self.callBack(errorCode,errStr);
        }
    }
}

#pragma mark ------ < Getter > ------
#pragma mark
- (NSMutableDictionary *)appSchemeDict {
    if (!_appSchemeDict) {
        _appSchemeDict = [[NSMutableDictionary alloc]init];
    }
    return _appSchemeDict;
}


@end
