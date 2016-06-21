//
//  LBSessionManager.h
//  testMySpecs
//
//  Created by Dagan on 16/6/19.
//  Copyright © 2016年 ydg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Model.h"

@interface LBSessionManager : NSObject<NSURLSessionDelegate>

+ (instancetype) shardLBSessionManager;

@property(nonatomic, copy) void (^successBlock)(int Id);
@property(nonatomic, copy) void (^failBlock)(int Id);
@property(nonatomic, copy) void (^progressBlock)(int Id,NSURLSessionDownloadTask *task);

@property (nonatomic, strong) NSOperationQueue *queue;

@property (nonatomic, strong) NSArray *models;

- (void) cancelAllRequest;

- (void) downloadWithUrl:(NSString *)url
              saveToPath:(NSString *)saveToPath
                 success:(void (^)(int Id))success
                 failure:(void (^)(int Id))fail;

- (void) downloadWithModels:(NSMutableArray *)models
                 success:(void (^)(int Id))success
                 failure:(void (^)(int Id))fail
                progress:(void (^)(int Id,NSURLSessionDownloadTask *task))progress;

- (void) LBcontinue;
@end
