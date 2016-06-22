//
//  ViewController.m
//  testMySpecs
//
//  Created by Dagan on 16/6/4.
//  Copyright © 2016年 ydg. All rights reserved.
//

#import "ViewController.h"
#import "Model.h"
#import "LBSessionManager.h"
#import "UIProgressView+AFNetworking.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UIProgressView *progress1;

@property (weak, nonatomic) IBOutlet UIProgressView *progress2;

@property(nonatomic,strong) NSMutableArray *models;
@end

@implementation ViewController{
    LBSessionManager *sessionManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _models = [[NSMutableArray alloc] init];
     NSString *path=[NSHomeDirectory() stringByAppendingString:[NSString stringWithFormat:@"/Documents"]];
    
    Model *model = [[Model alloc] init];
    model.filaName = @"vlc_mac_2.2.3.dmg";
    model.SavePath = [path stringByAppendingString:@"/vlc_mac_2.2.3.dmg"];
    model.url = @"http://sw.bos.baidu.com/sw-search-sp/software/4b62ed1bf64/vlc_mac_2.2.3.dmg";
    model.Id = 1;
    
    Model *model2 = [[Model alloc] init];
    model2.filaName = @"WeChatzhCN1.0.0.6.1428545414.dmg";
    model2.SavePath = [path stringByAppendingString:@"/WeChatzhCN1.0.0.6.1428545414.dmg"];
    model2.url = @"http://dlsw.baidu.com/sw-search-sp/soft/c6/25790/WeChatzhCN1.0.0.6.1428545414.dmg";
    model2.Id = 2;
    
    
    Model *model3 = [[Model alloc] init];
    model3.filaName = @"QQ_4.2.1_mac.dmg";
    model3.SavePath = [path stringByAppendingString:@"/QQ_4.2.1_mac.dmg"];
    model3.url = @"http://sw.bos.baidu.com/sw-search-sp/software/bfe69c1ecac/QQ_4.2.1_mac.dmg";
    model3.Id = 3;
    
    [_models addObject:model];
    [_models addObject:model2];
    [_models addObject:model3];
    
    _progress.progress = 0.0f;
    _progress1.progress = 0.0f;
    _progress2.progress = 0.0f;
    
    sessionManager = [[LBSessionManager alloc] init];
    sessionManager.models = [[NSArray alloc] initWithArray:(NSArray *)_models];
    sessionManager.MaxCount = 2;
}




- (IBAction)strat:(id)sender {
    [sessionManager downloadWithModels:_models success:^(int Id) {
        NSLog(@"成功:%d",Id);
    } failure:^(int Id) {
        NSLog(@"失败:%d",Id);
    } progress:^(int Id, NSURLSessionDownloadTask *task) {
        switch (Id) {
            case 1:
                [_progress setProgressWithDownloadProgressOfTask:task animated:YES];
                break;
            case 2:
                [_progress1 setProgressWithDownloadProgressOfTask:task animated:YES];
                break;
            case 3:
                [_progress2 setProgressWithDownloadProgressOfTask:task animated:YES];
                break;
            default:
                break;
        }
    } allDownCompletion:^{
        NSLog(@"全部下载完成");
    }];
    
}
- (IBAction)pause:(id)sender {
    
    [sessionManager LBcontinue];
}
- (IBAction)stop:(id)sender {
    [sessionManager cancelAllRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
