//
//  Model.h
//  testMySpecs
//
//  Created by Dagan on 16/6/19.
//  Copyright © 2016年 ydg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Model : NSObject

@property (nonatomic, strong) NSString* filaName;

@property (nonatomic, strong) NSString *SavePath;

@property (nonatomic, strong) NSString *url;

@property (nonatomic, assign) int Id;

@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;

@property (nonatomic, strong) NSURLSessionUploadTask *uploadTask;

@property (nonatomic, strong) NSData *downTaskResumeData;

@property (nonatomic) BOOL isDownloading;

@property (nonatomic) BOOL downloadComplete;



@end
