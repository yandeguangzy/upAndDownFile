//
//  DownLoad.h
//  testMySpecs
//
//  Created by FSLB on 16/6/21.
//  Copyright © 2016年 ydg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Model.h"

@interface DownLoad : NSObject

@property(nonatomic, copy) void (^successBlock)(int Id);
@property(nonatomic, copy) void (^failBlock)(int Id);
@property(nonatomic, copy) void (^progressBlock)(int Id,NSURLSessionDownloadTask *task);

@property (nonatomic, strong) NSMutableArray <Model *>*isDownLoads;

- (NSURLSessionDownloadTask *) downloadWithM:(Model *)model;

@end
