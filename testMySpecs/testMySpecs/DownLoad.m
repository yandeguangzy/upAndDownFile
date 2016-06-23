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
    
    __weak typeof(self) weakSelf = self;
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:model.filaName];
    configuration.allowsCellularAccess = YES;//允许使用所有网络状态进行操作。

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:model.url]];
    
    AFURLSessionManager *session = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];

    model.downloadTask = [session downloadTaskWithRequest:request progress:nil destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [NSURL fileURLWithPath:model.SavePath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        model.inQueue = NO;
        if(error){
            NSLog(@"%@",error);
            model.fail = YES;
            if(weakSelf.failBlock){
                weakSelf.failBlock(model.Id);
            }
        }else{
            NSLog(@"%@,%@",response,filePath);
            model.loadComplete = YES;
            if(weakSelf.successBlock){
                weakSelf.successBlock(model.Id);
            }
        }
    }];
    
    [session setDownloadTaskDidWriteDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDownloadTask * _Nonnull downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        NSLog(@"%@,%ld,%lld,%lld,%lld",session.configuration.identifier,downloadTask.taskIdentifier,bytesWritten,totalBytesWritten,totalBytesExpectedToWrite);
        self.progressBlock(model.Id,model.downloadTask);
    }];
    
    [model.downloadTask resume];
}


- (void) uploadWithM:(Model *)model
             success:(void (^)(int Id))success
             failure:(void (^)(int Id))fail
            progress:(void (^)(int Id,NSURLSessionDownloadTask *task))progress{
    self.successBlock = success;
    self.failBlock = fail;
    self.progressBlock = progress;
    
    __weak typeof(self) weakSelf = self;
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:model.filaName];
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:model.url]];
    AFHTTPRequestSerializer *serialization = [AFHTTPRequestSerializer serializer];
    NSURLRequest *request = [serialization multipartFormRequestWithMethod:@"POST"URLString:model.url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileURL:[NSURL fileURLWithPath:model.SavePath] name:@"file" error:nil];
    } error:nil];
    
    
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    
//    model.uploadTask = [manager POST:model.url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
//        [formData appendPartWithFileURL:[NSURL fileURLWithPath:model.SavePath] name:@"file" error:nil];
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
//        NSLog(@"%@,%@",task,responseObject);
//        model.loadComplete = YES;
//        if(weakSelf.successBlock){
//            weakSelf.successBlock(model.Id);
//        }
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"%@",error);
//        if(weakSelf.failBlock){
//            weakSelf.failBlock(model.Id);
//        }
//    }];
    
    //[model.uploadTask resume];
    
    AFURLSessionManager *session = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    model.uploadTask = [session uploadTaskWithStreamedRequest:request progress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if(error){
            NSLog(@"%@",error);
            if(weakSelf.failBlock){
                weakSelf.failBlock(model.Id);
            }
        }else{
            NSLog(@"%@,%@",response,responseObject);
            model.loadComplete = YES;
            if(weakSelf.successBlock){
                weakSelf.successBlock(model.Id);
            }
        }
    }];

//    [session setDownloadTaskDidWriteDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDownloadTask * _Nonnull downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
//        NSLog(@"%@,%ld,%lld,%lld,%lld",session.configuration.identifier,downloadTask.taskIdentifier,bytesWritten,totalBytesWritten,totalBytesExpectedToWrite);
//        self.progressBlock(model.Id,model.downloadTask);
//    }];
    
    [model.downloadTask resume];
    
}

@end
