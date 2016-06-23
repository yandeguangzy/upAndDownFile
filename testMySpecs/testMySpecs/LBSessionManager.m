//
//  LBSessionManager.m
//  testMySpecs
//
//  Created by Dagan on 16/6/19.
//  Copyright © 2016年 ydg. All rights reserved.
//

#import "LBSessionManager.h"
#import "DownLoad.h"

@interface LBSessionManager ()

@property (nonatomic, strong) NSOperationQueue *queue;

@property (nonatomic, strong) NSArray *models;

@property (nonatomic, strong) NSDictionary *info;
@end

@implementation LBSessionManager{
    AFURLSessionManager *session1;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.queue = [[NSOperationQueue alloc] init];
        self.info = [[NSDictionary alloc] init];
    }
    return self;
}

#pragma mark - Down
- (void) downloadWithModels:(NSMutableArray *)models
                    success:(void (^)(int Id))success
                    failure:(void (^)(int Id))fail
                   progress:(void (^)(NSInteger failCount,NSInteger completeCount,NSInteger totoalCount))totalProgressBlock{
    self.totalProgressBlock = totalProgressBlock;
    [self downloadWithModels:models success:success failure:fail progress:nil allDownCompletion:nil];
}

- (void) downloadWithModels:(NSArray *)models
                    success:(void (^)(int Id))success
                    failure:(void (^)(int Id))fail
                    progress:(void (^)(int, NSURLSessionDownloadTask *task))progress allDownCompletion:(void (^)())allDownCompletion{
    self.successBlock = success;
    self.failBlock = fail;
    self.progressBlock = progress;
    self.allDownCompletion = allDownCompletion;
    self.models = models;
    
    [self addDownOperation];
}



- (void) downloadWithModel:(Model *)model{
    DownLoad *download = [[DownLoad alloc] init];
    __weak typeof(self) weakSelf = self;
    [download downloadWithM:model success:^(int Id) {
        if(weakSelf.successBlock){
            weakSelf.successBlock(Id);
        }
        if (weakSelf.totalProgressBlock) {
            weakSelf.totalProgressBlock([weakSelf countOfFail],[weakSelf countOfComplete],weakSelf.models.count);
        }
        [weakSelf addDownOperation];
        
    } failure:^(int Id) {
        if(weakSelf.failBlock){
            weakSelf.failBlock(Id);
        }
        if (weakSelf.totalProgressBlock) {
            weakSelf.totalProgressBlock([weakSelf countOfFail],[weakSelf countOfComplete],weakSelf.models.count);
        }
        [weakSelf addDownOperation];
        
    } progress:^(int Id, NSURLSessionDownloadTask *task) {
        if(weakSelf.progressBlock){
            weakSelf.progressBlock(Id,task);
        }
    }];
}

- (void) addDownOperation{
    if([self isAllDownloadComplete]){
        if(self.allDownCompletion){
            self.allDownCompletion();
        }
    }else{
        for (Model *model in self.models){
            if([self countOfDownloading] < _MaxCount){
                if(model.loadComplete == NO && model.inQueue == NO){
                    NSInvocationOperation *operation = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(downloadWithModel:) object:model];
                    [self.queue addOperation:operation];
                    model.inQueue = YES;
                }
            }else{
                break;
            }
        }
    }
}


#pragma mark - Upload

- (void) uploadWithModels:(NSMutableArray *)models
                     Info:(NSDictionary *)info
              Infosuccess:(void (^)(NSError *error,AFHTTPRequestOperation *operation))infoComplete
                  success:(void (^)(int Id))success
                  failure:(void (^)(int Id))fail
                 progress:(void (^)(NSInteger failCount,NSInteger completeCount,NSInteger totoalCount))totalProgressBlock{
    self.info = info;
    self.infoCompletion = infoComplete;
    [self uploadInfo:^{
        [self uploadWithModels:models success:success failure:fail progress:nil allDownCompletion:nil];
    }];
    
}

- (void) uploadWithModels:(NSArray *)models
                    success:(void (^)(int Id))success
                    failure:(void (^)(int Id))fail
                   progress:(void (^)(int Id, NSURLSessionDownloadTask *task))progress allDownCompletion:(void (^)())allDownCompletion{
    self.successBlock = success;
    self.failBlock = fail;
    self.progressBlock = progress;
    self.allDownCompletion = allDownCompletion;
    self.models = models;
    
    [self addUpOperation];
}

- (void) uploadWithModels:(NSMutableArray *)models
                  success:(void (^)(int Id))success
                  failure:(void (^)(int Id))fail
                 progress:(void (^)(NSInteger failCount,NSInteger completeCount,NSInteger totoalCount))totalProgressBlock{
    self.totalProgressBlock = totalProgressBlock;
    [self uploadWithModels:models success:success failure:fail progress:nil allDownCompletion:nil];
}


- (void) uploadWithModel:(Model *)model{
    DownLoad *download = [[DownLoad alloc] init];
    __weak typeof(self) weakSelf = self;
    [download uploadWithM:model success:^(int Id) {
        if(weakSelf.successBlock){
            weakSelf.successBlock(Id);
        }
        if (weakSelf.totalProgressBlock) {
            weakSelf.totalProgressBlock([weakSelf countOfFail],[weakSelf countOfComplete],weakSelf.models.count);
        }
        [weakSelf addUpOperation];
        
    } failure:^(int Id) {
        if(weakSelf.failBlock){
            weakSelf.failBlock(Id);;
        }
        if (weakSelf.totalProgressBlock) {
            weakSelf.totalProgressBlock([weakSelf countOfFail],[weakSelf countOfComplete],weakSelf.models.count);
        }
        [weakSelf addUpOperation];
        
    } progress:^(int Id, NSURLSessionDownloadTask *task) {
        if(weakSelf.progressBlock){
            weakSelf.progressBlock(Id,task);
        }
    }];
}

- (void) addUpOperation{
    if([self isAllDownloadComplete]){
        if(self.allDownCompletion){
            self.allDownCompletion();
        }
    }else{
        for (Model *model in self.models){
            if([self countOfDownloading] < _MaxCount){
                if(model.loadComplete == NO && model.inQueue == NO){
                    NSInvocationOperation *operation = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(uploadWithModel:) object:model];
                    [self.queue addOperation:operation];
                    model.inQueue = YES;
                }
            }else{
                break;
            }
        }
    }
}

#pragma mark - uploadInfo
- (void) uploadInfo:(void (^)())infoCompltion{
    AFHTTPRequestOperationManager *httpManager = [AFHTTPRequestOperationManager manager];
    [httpManager POST:@"" parameters:self.info success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        self.infoCompletion(nil, operation);
        infoCompltion();
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        self.infoCompletion(error, operation);
    }];
}



-(NSInteger)countOfDownloading{
    
    NSInteger count = 0;
    
    for (Model *model in self.models){
        if (model.inQueue) {
            count++;
        }
    }
    return count;
}

-(NSInteger)countOfComplete{
    
    NSInteger count = 0;
    
    for (Model *model in self.models){
        if (model.loadComplete) {
            count++;
        }
    }
    return count;
}

-(NSInteger)countOfFail{
    
    NSInteger count = 0;
    
    for (Model *model in self.models){
        if (model.fail) {
            count++;
        }
    }
    return count;
}

-(BOOL)isAllDownloadComplete{
    for (Model *model in self.models){
        if (!model.loadComplete) {
            return NO;
        }
    }
    return YES;
}



- (void) cancelAllRequest{
    for (Model *model in self.models){
        if(model.inQueue && !model.loadComplete){
            [model.downloadTask suspend];
            model.inQueue = NO;
            [self.queue cancelAllOperations];
        }
    }
}

- (void) LBcontinue{
    for (Model *model in self.models){
        if(model.downloadTask.state == NSURLSessionTaskStateSuspended){
            [model.downloadTask resume];
            model.inQueue = YES;
        }
    }
}

- (NSArray *) models{
    if(!_models){
        _models = [[NSArray alloc] init];
    }
    return _models;
}


@end
