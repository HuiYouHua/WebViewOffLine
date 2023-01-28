//
//  HLLOfflineWebConfig.m
//  HLLOfflineWebVC
//
//  Created by 货拉拉 on 2021/11/2.
//

#import "HLLOfflineWebConfig.h"
#import "HLLOfflineWebPackage+callbacks.h"

/**
 参数名    参数含义    是否必填
 rules    H5页面和离线包参数映射规则    选填
 */
/// 子配置项keys
/// switch    1 开启离线包功能，0 关闭    必填
NSString *const kHLLOfflineWebConfigKey_switch = @"switch";
///  disablelist    需要禁用离线包功能到页面    选填
NSString *const kHLLOfflineWebConfigKey_disablelist = @"disablelist";
/// predownloadlist    预下载离线包列表    选填
NSString *const kHLLOfflineWebConfigKey_predownloadList = @"predownloadlist";
///  downloadsdk      设置下载sdk方式，默认不启用断点续传 0,  系统API下载方式
NSString *const kHLLOfflineWebConfigKey_downloadSdk = @"downloadsdk";

@implementation HLLOfflineWebConfig

+ (NSDictionary *)defaultOffWebConfigDic {
    return @{
        kHLLOfflineWebConfigKey_switch : @(0),
        kHLLOfflineWebConfigKey_disablelist : @[].mutableCopy,
        kHLLOfflineWebConfigKey_predownloadList : @[].mutableCopy,
        kHLLOfflineWebConfigKey_downloadSdk : @(0)
    };
}

// logBlock，reportBlock，monitorBlock 为具体的日志、埋点、实时监控SDK实现

/// 离线包初始化
/// - Parameters:
///   - offwebConfigDict: 初始化配置
///   - logBlock: 日志回调
///   - reportBlock: 埋点回调
///   - monitorBlock: 实时监控SDK回调
///   - env: 环境: prd. 设置后端环境，debug需要，release包不需要设置
///   - appVersion: 客户端版本
+ (void)setInitalParam:(NSDictionary *)offwebConfigDict
              logBlock:(HLLOfflineWebLogBlock)logBlock
           reportBlock:(HLLOfflineWebReportBlock)reportBlock
          monitorBlock:(HLLOfflineWebMonitorBlock)monitorBlock
                   env:(NSString *)env
            appversion:(NSString *)appVersion {
    // switch值为1时，打开
    if ([offwebConfigDict isKindOfClass:[NSDictionary class]] && offwebConfigDict.count > 0) {
        if ([offwebConfigDict[kHLLOfflineWebConfigKey_switch] boolValue]) {
            // 全局屏蔽，开启后离线包的更新和加载逻辑暂时实效
            [HLLOfflineWebPackage getInstance].disalbleFlag = NO;
            [HLLOfflineWebPackage getInstance].env = env;
            [[HLLOfflineWebPackage getInstance] setAppVersion:appVersion];
            [HLLOfflineWebPackage getInstance].logBlock = logBlock;
            [HLLOfflineWebPackage getInstance].reportBlock = reportBlock;
            [HLLOfflineWebPackage getInstance].monitorBlock = monitorBlock;
            [HLLOfflineWebPackage getInstance].downloadSDKType =
                [offwebConfigDict[kHLLOfflineWebConfigKey_downloadSdk] intValue];
            NSArray *disableList = offwebConfigDict[kHLLOfflineWebConfigKey_disablelist];
            for (int i = 0; i < [disableList count]; i++) {
                // 将某个离线加入黑名单，暂时禁用更新和加载
                [[HLLOfflineWebPackage getInstance] addToDisableList:disableList[i]];
            }
        } else {
            [HLLOfflineWebPackage getInstance].disalbleFlag = YES;
        }
    } else {
        NSLog(@"[!] => offwebConfig setInital do nothing, because offwebConfigParams is: %@", offwebConfigDict);
    }
}

+ (void)predownloadOffWebPackage:(NSDictionary *)offwebConfigDict {
    // switch值为1时，打开网络请求日志打点功能.
    if ([offwebConfigDict isKindOfClass:[NSDictionary class]] && offwebConfigDict.count > 0) {
        if ([offwebConfigDict[kHLLOfflineWebConfigKey_switch] boolValue]) {
            NSArray *downloadList = offwebConfigDict[kHLLOfflineWebConfigKey_predownloadList];
            for (int i = 0; i < [downloadList count]; i++) {
                [[HLLOfflineWebPackage getInstance] checkUpdate:downloadList[i]
                                                         result:^(HLLOfflineWebResultEvent result, NSString *message){
                                                         }];
            }
            if ([HLLOfflineWebPackage getInstance].logBlock) {
                [HLLOfflineWebPackage getInstance].logBlock(
                    HLLOfflineWebLogLevelInfo, @"offwebpack",
                    [NSString stringWithFormat:@"predownload task count:%lu", (unsigned long)[downloadList count]]);
            } else {
                NSLog(@"[!] => offwebConfig missing logBlock. you should set logBlock in offwebConfig init process by "
                      @"call function setInitalParam:... first.");
            }
        }
    }
}
@end
