//
//  DownLoad.m
//  testMySpecs
//
//  Created by FSLB on 16/6/21.
//  Copyright © 2016年 ydg. All rights reserved.
//

#import "DownLoad.h"
#import "AFNetworking.h"

@implementation DownLoad

- (void) downloadWithM:(Model *)model
                                     success:(void (^)(int Id))success
                                     failure:(void (^)(int Id))fail
                                    progress:(void (^)(int Id,NSURLSessionDownloadTask *task))progress{
    self.successBlock = success;
    self.failBlock = fail;
    self.progressBlock = progress;
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:model.filaName];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:model.url]];
    
    AFURLSessionManager *session = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    model.downloadTask = [session downloadTaskWithRequest:request progress:nil destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [NSURL fileURLWithPath:model.SavePath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        model.isDownloading = NO;
        if(error){
            NSLog(@"%@",error);
            self.failBlock(model.Id);
        }else{
            NSLog(@"%@,%@",response,filePath);
            model.downloadComplete = YES;
            self.successBlock(model.Id);
            
        }
        
    }];
    
    [session setDownloadTaskDidWriteDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDownloadTask * _Nonnull downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        NSLog(@"%@,%ld,%lld,%lld,%lld",session.configuration.identifier,downloadTask.taskIdentifier,bytesWritten,totalBytesWritten,totalBytesExpectedToWrite);
        self.progressBlock(model.Id,model.downloadTask);
    }];
    
    [model.downloadTask resume];
    model.isDownloading = YES;
}

@end
