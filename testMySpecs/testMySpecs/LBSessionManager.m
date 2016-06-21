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

@implementation LBSessionManager{
    AFURLSessionManager *session1;
}

static LBSessionManager *handler = nil;



+ (instancetype) shardLBSessionManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        handler = [[LBSessionManager alloc] init];
        handler.queue = [[NSOperationQueue alloc]init];
    });
    return handler;
}

- (void) downloadWithUrl:(NSString *)url
              saveToPath:(NSString *)saveToPath
                 success:(void (^)(int Id))success
                 failure:(void (^)(int Id))fail{
//    NSInvocationOperation *operation = [[NSInvocationOperation alloc]initWithTarget:self
//                                                                           selector:@selector(downloadImage:)
//                                                                             object:kURL];
//    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
//    [queue addOperation:operation];
}

- (void) downloadWithModels:(NSArray *)models
                    success:(void (^)(int Id))success
                    failure:(void (^)(int Id))fail
                    progress:(void (^)(int, NSURLSessionDownloadTask *task))progress{
    
    
    self.successBlock = success;
    self.failBlock = fail;
    self.progressBlock = progress;
    //self.models = [[NSArray alloc] initWithArray:models];
    
    [self.queue setMaxConcurrentOperationCount:1];
    for (Model *model in self.models){
        NSInvocationOperation *operation = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(downloadWithModel:) object:model];
        [self.queue addOperation:operation];
    }
    
}

- (void) downloadWithModel1:(Model *)model{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[NSString stringWithFormat:@"%d",model.Id]];
    configuration.TLSMaximumSupportedProtocol = 1;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration
                                                 delegate:self
                                            delegateQueue:nil];
    NSURLSessionDownloadTask *downTask = [session downloadTaskWithURL:[NSURL URLWithString:model.url]];
    
    [downTask resume];
    
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    
    if (totalBytesExpectedToWrite == NSURLSessionTransferSizeUnknown) {
        NSLog(@"Unknown transfer size");
    }
    else{
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            NSLog(@"%@,%ld,%lld,%lld,%lld",session.configuration.identifier,downloadTask.taskIdentifier,bytesWritten,totalBytesWritten,totalBytesExpectedToWrite);
            
            self.progressBlock([session.configuration.identifier intValue],downloadTask);
            

        }];
    }
}





- (void) downloadWithModel:(Model *)model{
    if(model.downloadComplete || model.isDownloading){
        return;
    }
    
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:model.filaName];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:model.url]];
    
    AFURLSessionManager *session = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    //session1 = session;
    if(1){
        model.downloadTask = [session downloadTaskWithRequest:request progress:nil destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            return [NSURL fileURLWithPath:model.SavePath];
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            if(error){
                NSLog(@"%@",error);
                self.failBlock(model.Id);
                model.downTaskResumeData = nil;
            }else{
                NSLog(@"%@,%@",response,filePath);
                self.successBlock(model.Id);
                model.downloadComplete = YES;
            }
            model.isDownloading = NO;
            
        }];
    }else{
        
        model.downloadTask = [session downloadTaskWithResumeData:model.downTaskResumeData progress:nil destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            return [NSURL fileURLWithPath:model.SavePath];
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            if(error){
                NSLog(@"%@",error);
                self.failBlock(model.Id);
                model.downTaskResumeData = nil;
            }else{
                NSLog(@"%@,%@",response,filePath);
                self.successBlock(model.Id);
                model.downloadComplete = YES;
            }
            model.isDownloading = NO;
        }];
    }
    
    [session setDownloadTaskDidWriteDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDownloadTask * _Nonnull downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        NSLog(@"%@,%ld,%lld,%lld,%lld",session.configuration.identifier,downloadTask.taskIdentifier,bytesWritten,totalBytesWritten,totalBytesExpectedToWrite);
        self.progressBlock(model.Id,model.downloadTask);
    }];
    
    [model.downloadTask resume];
    model.isDownloading = YES;
    
}

- (void) cancelAllRequest{
    
    for (Model *model in self.models){
        if(model.isDownloading && !model.downloadComplete){
            [model.downloadTask suspend];
            model.isDownloading = NO;
            
//            [model.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
//                if(resumeData != nil){
//                    model.downTaskResumeData = resumeData;
//                }
//                model.isDownloading = NO;
//            }];
            
        }
    }
    //[session1 invalidateSessionCancelingTasks:YES];
    [self.queue cancelAllOperations];
}

- (void)dealloc{
    NSLog(@"dealloc");
}
- (void) LBcontinue{
    for (Model *model in self.models){
        if(!model.isDownloading && !model.downloadComplete){
            [model.downloadTask resume];
            model.isDownloading = YES;
        }
    }
}

@end
