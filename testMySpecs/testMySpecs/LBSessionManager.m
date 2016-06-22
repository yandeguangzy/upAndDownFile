//
//  LBSessionManager.m
//  testMySpecs
//
//  Created by Dagan on 16/6/19.
//  Copyright © 2016年 ydg. All rights reserved.
//

#import "LBSessionManager.h"
#import "AFNetworking.h"
#import "DownLoad.h"

@interface LBSessionManager ()

@property (nonatomic, strong) NSMutableArray <Model *> *downingArray;

@end

@implementation LBSessionManager{
    AFURLSessionManager *session1;
}

//static LBSessionManager *handler = nil;
//
//
//
//+ (instancetype) shardLBSessionManager{
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        handler = [[LBSessionManager alloc] init];
//        handler.queue = [[NSOperationQueue alloc]init];
//        
//    });
//    return handler;
//}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.downingArray = [[NSMutableArray alloc] init];
    }
    return self;
}


- (void) downloadWithModels:(NSArray *)models
                    success:(void (^)(int Id))success
                    failure:(void (^)(int Id))fail
                    progress:(void (^)(int, NSURLSessionDownloadTask *task))progress allDownCompletion:(void (^)())allDownCompletion{
    
    
    self.successBlock = success;
    self.failBlock = fail;
    self.progressBlock = progress;
    self.allDownCompletion = allDownCompletion;
    //self.models = [[NSArray alloc] initWithArray:models];
    
    //[self.queue setMaxConcurrentOperationCount:1];
    
    
    for (Model *model in self.models){
        
        if(self.downingArray.count >= _MaxCount){
            break;
        }
        
        NSInvocationOperation *operation = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(downloadWithModel:) object:model];
        [self.queue addOperation:operation];
        
        [self.downingArray addObject:model];
    }
    
}

- (void) downloadWithModel:(Model *)model{
    DownLoad *download = [[DownLoad alloc] init];
    __weak typeof(self) weakSelf = self;
    [download downloadWithM:model success:^(int Id) {
        weakSelf.successBlock(Id);
        [weakSelf.downingArray removeObject:model];
        [weakSelf addOperation];
        
    } failure:^(int Id) {
        weakSelf.failBlock(Id);
        [weakSelf.downingArray removeObject:model];
        [weakSelf addOperation];
        
    } progress:^(int Id, NSURLSessionDownloadTask *task) {
        weakSelf.progressBlock(Id,task);
    }];
}

- (void) addOperation{
    if(self.downingArray.count >= _MaxCount){
        return;
    }
    BOOL allDown = YES;
    for (Model *model in self.models){
        if(model.downloadComplete == NO && model.isDownloading == NO&& self.downingArray.count < _MaxCount){
            NSInvocationOperation *operation = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(downloadWithModel:) object:model];
            allDown = NO;
            [self.queue addOperation:operation];
            [self.downingArray addObject:model];
            break;
        }
    }
    if(allDown){
        self.allDownCompletion();
    }
}

- (NSMutableArray *) downingArray{
    if(!_downingArray){
        _downingArray = [[NSMutableArray alloc] init];
    }
    return _downingArray;
}

- (void) cancelAllRequest{
    for (Model *model in self.downingArray){
        if(model.isDownloading && !model.downloadComplete){
            [model.downloadTask suspend];
            model.isDownloading = NO;
            [self.queue cancelAllOperations];
        }
    }
}

- (void)dealloc{
    NSLog(@"dealloc");
}
- (void) LBcontinue{
    for (Model *model in self.downingArray){
        if(!model.isDownloading && !model.downloadComplete){
            [model.downloadTask resume];
            model.isDownloading = YES;
        }
    }
}

@end
