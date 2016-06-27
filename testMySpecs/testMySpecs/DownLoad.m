//
//  DownLoad.m
//  testMySpecs
//
//  Created by FSLB on 16/6/21.
//  Copyright © 2016年 ydg. All rights reserved.
//

#import "DownLoad.h"
#import "AFNetworking.h"
#import "AppDelegate.h"

@interface DownLoad()

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic , strong) Model *model;
@end

@implementation DownLoad

- (NSURLSession *)backgroundSession
{
    //Use dispatch_once_t to create only one background session. If you want more than one session, do with different identifier
   // static NSURLSession *session = nil;
   // static dispatch_once_t onceToken;
   // dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[NSString stringWithFormat:@"%d",_model.Id]];
        //NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"com.yourcompany.appId.BackgroundSession"];
    
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
   // });
    return session;
}

- (void) beginDownload:(Model *)model
               success:(void (^)(int Id))success
               failure:(void (^)(int Id))fail
              progress:(void (^)(int Id,NSURLSessionDownloadTask *task))progress
{
    self.successBlock = success;
    self.failBlock = fail;
    self.progressBlock = progress;
    _model = model;
    
    NSURL *downloadURL = [NSURL URLWithString:model.url];
    NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL];
    self.session = [self backgroundSession];
    model.downloadTask = [self.session downloadTaskWithRequest:request];
    [model.downloadTask resume];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location{
    NSLog(@"haahhahah");
    __block NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *destinationFilename = downloadTask.originalRequest.URL.lastPathComponent;
    NSArray *URLs = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL * docDirectoryURL = [URLs objectAtIndex:0];
    NSURL *destinationURL = [docDirectoryURL URLByAppendingPathComponent:destinationFilename];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        if ([fileManager fileExistsAtPath:[destinationURL path]]) {
            [fileManager removeItemAtURL:destinationURL error:nil];
        }
        [fileManager copyItemAtURL:location
                             toURL:destinationURL
                             error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL success = [fileManager copyItemAtURL:location
                                                toURL:destinationURL
                                                error:&error];
            
//            _model.inQueue = NO;
//            if(success){
//                NSLog(@"复制成功");
//                _model.loadComplete = YES;
//                NSLog(@"Download finished successfully.");
//                self.successBlock(_model.Id);
//                
//            }else{
//                NSLog(@"复制失败");
//                _model.fail = YES;
//                NSLog(@"Download completed with error: %@", [error localizedDescription]);
//                self.failBlock(_model.Id);
//            }
//            
        });
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (appDelegate.backgroundSessionCompletionHandler) {
            
            void (^completionHandler)() = appDelegate.backgroundSessionCompletionHandler;
            
            appDelegate.backgroundSessionCompletionHandler = nil;
            
            completionHandler();
            
        }
    });
    
    
    
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error{
    _model.inQueue = NO;
    if (error != nil) {
        _model.fail = YES;
        NSLog(@"Download completed with error: %@", [error localizedDescription]);
        self.failBlock(_model.Id);
    }
    else{
        _model.loadComplete = YES;
        

        NSLog(@"Download finished successfully.");
        self.successBlock(_model.Id);
    }
}



-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    NSLog(@"%@,%ld,%lld,%lld,%lld",session.configuration.identifier,downloadTask.taskIdentifier,bytesWritten,totalBytesWritten,totalBytesExpectedToWrite);
    self.progressBlock(_model.Id,_model.downloadTask);
}







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
        NSLog(@"zaozaozoa");
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
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (appDelegate.backgroundSessionCompletionHandler) {
            
            void (^completionHandler)() = appDelegate.backgroundSessionCompletionHandler;
            
            appDelegate.backgroundSessionCompletionHandler = nil;
            
            completionHandler();
            
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

#pragma mark - DataTask
- (void) postData:(NSDictionary *) Info
          success:(void (^)(int Id))success
          failure:(void (^)(int Id))fail{
    self.successBlock = success;
    self.failBlock = fail;
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"com.lubaocar."];
    AFURLSessionManager *sManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    AFHTTPRequestSerializer *serialization = [AFHTTPRequestSerializer serializer];
    NSURLRequest *requets = [serialization requestWithMethod:@"POST" URLString:nil parameters:Info error:nil];
    
    
    
//    NSURLRequest *request = [serialization multipartFormRequestWithMethod:@"POST"URLString:model.url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
//        [formData appendPartWithFileURL:[NSURL fileURLWithPath:model.SavePath] name:@"file" error:nil];
//    } error:nil];
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask *dataTask = [sManager dataTaskWithRequest:requets completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if(error){
            NSLog(@"%@",error);
            if(weakSelf.failBlock){
                weakSelf.failBlock(10000);
            }
        }else{
            NSLog(@"%@",response);
            if(weakSelf.successBlock){
                weakSelf.successBlock(10000);
            }
        }
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (appDelegate.backgroundSessionCompletionHandler) {
            
            void (^completionHandler)() = appDelegate.backgroundSessionCompletionHandler;
            
            appDelegate.backgroundSessionCompletionHandler = nil;
            
            completionHandler();
            
        }

    }];
    [dataTask resume];
}


@end
