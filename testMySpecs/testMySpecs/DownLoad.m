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

- (NSURLSessionDownloadTask *) downloadWithM:(Model *)model{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:model.filaName];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:model.url]];
    
    AFURLSessionManager *session = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
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
}

@end
