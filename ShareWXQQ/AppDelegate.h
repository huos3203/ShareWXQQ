//
//  AppDelegate.h
//  ShareWXQQ
//
//  Created by pengyucheng on 21/04/2017.
//  Copyright © 2017 PBBReader. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WechatOpenSDK/WXApi.h>
#import <TencentOpenAPI/TencentOAuth.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate,WXApiDelegate,TencentSessionDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

