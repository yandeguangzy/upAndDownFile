//
//  DownLoad.h
//  testMySpecs
//
//  Created by FSLB on 16/6/21.
//  Copyright © 2016年 ydg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Model.h"

@interface DownLoad : NSObject<NSURLSessionDelegate, NSURLSessionDownloadDelegate, NSURLSessionTaskDelegate>

@property(nonatomic, copy) void (^successBlock)(int Id);
@property(nonatomic, copy) void (^failBlock)(int Id);
@property(nonatomic, copy) void (^progressBlock)(int Id,NSURLSessionDownloadTask *task);

@property (nonatomic, strong) NSMutableArray <Model *>*isDownLoads;

- (void) beginDownload:(Model *)model
               success:(void (^)(int Id))success
               failure:(void (^)(int Id))fail
              progress:(void (^)(int Id,NSURLSessionDownloadTask *task))progress;

- (void) downloadWithM:(Model *)model
               success:(void (^)(int Id))success
               failure:(void (^)(int Id))fail
              progress:(void (^)(int Id,NSURLSessionDownloadTask *task))progress;

- (void) uploadWithM:(Model *)model
               success:(void (^)(int Id))success
               failure:(void (^)(int Id))fail
              progress:(void (^)(int Id,NSURLSessionDownloadTask *task))progress;
@end
