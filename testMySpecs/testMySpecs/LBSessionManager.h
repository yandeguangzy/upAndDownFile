//
//  LBSessionManager.h
//  testMySpecs
//
//  Created by Dagan on 16/6/19.
//  Copyright © 2016年 ydg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Model.h"
#import "AFNetworking.h"

@interface LBSessionManager : NSObject<NSURLSessionDelegate>

@property(nonatomic, copy) void (^successBlock)(int Id);
@property(nonatomic, copy) void (^failBlock)(int Id);
@property(nonatomic, copy) void (^progressBlock)(int Id,NSURLSessionDownloadTask *task);
@property(nonatomic, copy) void (^totalProgressBlock)(NSInteger failCount,NSInteger completeCount,NSInteger totoalCount);
@property(nonatomic, copy) void (^allDownCompletion)();
@property(nonatomic, copy) void (^infoCompletion)(int Id);

/**
 *  @author Yan deguang, 16-06-22 17:06:24
 *
 *  最大上传或下载任务个数，默认为3
 */
@property (nonatomic, assign) NSInteger MaxCount;

//暂停所有任务
- (void) cancelAllRequest;

//(测试使用)
- (void) downloadWithModels:(NSMutableArray *)models
                 success:(void (^)(int Id))success
                 failure:(void (^)(int Id))fail
                progress:(void (^)(int Id,NSURLSessionDownloadTask *task))progress
          allDownCompletion:(void(^)())allDownCompletion;

/**
 *  @author Yan deguang, 16-06-22 17:06:18
 *
 *  下载
 *
 *  @param models             所有模型数组
 *  @param success            单一图片下载成功回调
 *  @param fail               单一图片下载失败
 *  @param totalProgressBlock 下载进度 completeCount：已完成数量  totoalCount：需要下载总数量
 */
- (void) downloadWithModels:(NSMutableArray *)models
                    success:(void (^)(int Id))success
                    failure:(void (^)(int Id))fail
                   progress:(void (^)(NSInteger failCount,NSInteger completeCount,NSInteger totoalCount))totalProgressBlock;
//继续下载
- (void) LBcontinue;

/**
 *  @author Yan deguang, 16-06-22 17:06:06
 *
 *  上传
 *
 *  @param models             所有模型数组
 *  @param success            单一图片上传成功回调
 *  @param fail               单一图片上传失败
 *  @param totalProgressBlock 上传进度 completeCount：已完成数量  totoalCount：需要上传总数量
 */
- (void) uploadWithModels:(NSArray *)models
                  success:(void (^)(int Id))success
                  failure:(void (^)(int Id))fail
                 progress:(void (^)(int Id, NSURLSessionDownloadTask *task))progress allDownCompletion:(void (^)())allDownCompletion;

- (void) uploadWithModels:(NSMutableArray *)models
                     Info:(NSDictionary *)info
              Infosuccess:(void (^)(int Id))infoComplete
                  success:(void (^)(int Id))success
                  failure:(void (^)(int Id))fail
                 progress:(void (^)(NSInteger failCount,NSInteger completeCount,NSInteger totoalCount))totalProgressBlock;

@end
