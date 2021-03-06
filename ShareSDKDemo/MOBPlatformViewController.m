//
//  MOBPlatformViewController.m
//  ShareSDKDemo
//
//  Created by youzu on 17/3/7.
//  Copyright © 2017年 mob. All rights reserved.
//

#import "MOBPlatformViewController.h"
#import <ShareSDKExtension/ShareSDK+Extension.h>

@interface MOBPlatformViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSIndexPath *selectIndexPath;
}

@end

@implementation MOBPlatformViewController

- (instancetype)init
{
//    self = [self initWithNibName:@"MOBPlatformViewController" bundle:nil];
    if (self) {
        authTypeArray = @[];
        shareTypeArray = @[];
        selectorNameArray = @[];
        authSelectorNameArray = @[];
        otherTypeArray = @[];
        otherSelectorNameArray = @[];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    mobTableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    mobTableView.delegate =self;
    mobTableView.dataSource = self;
    [self.view addSubview:mobTableView];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
        {
            return authTypeArray.count;
        }
        case 1:
        {
            return shareTypeArray.count;
        }
        case 2:
        {
            return otherTypeArray.count;
        }
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"reuseCell"];
    }
    switch (indexPath.section)
    {
        case 0:
        {
            if([ShareSDK hasAuthorized:platformType])
            {
                cell.detailTextLabel.text = @"已授权";
                cell.detailTextLabel.textColor = [UIColor blueColor];
            }
            else
            {
                cell.detailTextLabel.text = @"未授权";
                cell.detailTextLabel.textColor = [UIColor grayColor];
            }
            cell.textLabel.text = authTypeArray[indexPath.row];
            break;
        }
        case 1:
            cell.textLabel.text = shareTypeArray[indexPath.row];
            cell.detailTextLabel.text = @"";
            break;
        case 2:
            cell.textLabel.text = otherTypeArray[indexPath.row];
            cell.detailTextLabel.text = @"";
            break;
        default:
            cell.textLabel.text = @"";
            cell.detailTextLabel.text = @"";
            break;
    }
    return cell;
}

- (void)shareWithParameters:(NSMutableDictionary *)parameters
{
    if(parameters.count == 0){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"请先设置分享参数"
                                                           delegate:nil
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    [ShareSDK share:platformType
         parameters:parameters
     onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
         if(state == SSDKResponseStateBegin){
             return ;
         }
         NSString *titel = @"";
         NSString *message = @"";
         NSString *typeStr = @"";
         UIColor *typeColor = [UIColor grayColor];
         switch (state) {
             case SSDKResponseStateSuccess:
             {
                 titel = @"分享成功";
                 typeStr = @"成功";
                 typeColor = [UIColor blueColor];
                 break;
             }
             case SSDKResponseStateFail:
             {
                 message = [NSString stringWithFormat:@"%@", error];
                 NSLog(@"error :%@",error);
                 typeStr = @"失败";
                 typeColor = [UIColor redColor];
                 break;
             }
             case SSDKResponseStateCancel:
             {
                 titel = @"分享已取消";
                 typeStr = @"取消";
                 break;
             }
             default:
                 break;
         }
         [mobTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
         if(selectIndexPath != nil)
         {
             UITableViewCell *cell = [mobTableView cellForRowAtIndexPath:selectIndexPath];
             cell.detailTextLabel.text = typeStr;
             cell.detailTextLabel.textColor = typeColor;
             selectIndexPath = nil;
         }
         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:titel
                                                             message:message
                                                            delegate:nil
                                                   cancelButtonTitle:@"确定"
                                                   otherButtonTitles:nil];
         [alertView show];
     }];
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section)
    {
        case 0:
        {
            if(indexPath.row < authSelectorNameArray.count)
            {
                if([ShareSDK hasAuthorized:platformType])
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"是否取消授权"
                                                                        message:nil
                                                                       delegate:self
                                                              cancelButtonTitle:@"暂不"
                                                              otherButtonTitles:@"确认",nil];
                    alertView.tag = 1000;
                    [alertView show];
                }
                else
                {
                    NSString *selectorName = authSelectorNameArray[indexPath.row];
                    [self funcWithSelectorName:selectorName];
                }
            }
            break;
        }
        case 1:
        {
            if(indexPath.row < selectorNameArray.count)
            {
                selectIndexPath = indexPath;
                NSString *selectorName = selectorNameArray[indexPath.row];
                [self funcWithSelectorName:selectorName];
            }
            break;
        }
        case 2:
        {
            if(indexPath.row < otherSelectorNameArray.count)
            {
                NSString *selectorName = otherSelectorNameArray[indexPath.row];
                [self funcWithSelectorName:selectorName];
            }
            break;
        }
        default:
            break;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 1000 && buttonIndex == 1)
    {
        [ShareSDK cancelAuthorize:platformType];
        [mobTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
        {
            if(authTypeArray.count > 0)
            {
                return @" ";
            }
            return nil;
        }
        case 1:
        {
            if(shareTypeArray.count > 0)
            {
                return @" ";
            }
            return nil;
        }
        case 2:
        {
            if(otherTypeArray.count > 0)
            {
                return @" ";
            }
            return nil;
        }
        default:
            return nil;
    }
}

- (void)funcWithSelectorName:(NSString *)selectorName
{
    SEL sel = NSSelectorFromString(selectorName);
    if([self respondsToSelector:sel])
    {
        IMP imp = [self methodForSelector:sel];
        void (*func)(id, SEL) = (void *)imp;
        func(self, sel);
    }
}

- (void)authAct
{
    [ShareSDK authorize:platformType
               settings:nil
         onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
             NSString *titel = @"";
             switch (state) {
                 case SSDKResponseStateSuccess:
                 {
                     
                     titel = @"授权成功";
                     NSLog(@"%@",user.rawData);
                     [mobTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
                     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:titel
                                                                         message:nil
                                                                        delegate:nil
                                                               cancelButtonTitle:@"确定"
                                                               otherButtonTitles:nil];
                     [alertView show];
                     break;
                 }
                 case SSDKResponseStateFail:
                 {
                     titel = @"授权失败";
                     NSLog(@"error :%@",error);
                     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                         message:[NSString stringWithFormat:@"%@", error]
                                                                        delegate:nil
                                                               cancelButtonTitle:@"确定"
                                                               otherButtonTitles:nil];
                     [alertView show];
                     break;
                 }
                 case SSDKResponseStateCancel:
                 {
                     titel = @"取消授权";
                     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:titel
                                                                         message:nil
                                                                        delegate:nil
                                                               cancelButtonTitle:@"确定"
                                                               otherButtonTitles:nil];
                     [alertView show];
                      break;
                 }
                 default:
                     break;
             }
         }];
}

- (void)isInstallAPP
{
    NSString *titel = @"";
    if([ShareSDK isClientInstalled:platformType])
    {
        titel = @"已安装";
    }
    else
    {
        titel = @"未安装";
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:titel
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
