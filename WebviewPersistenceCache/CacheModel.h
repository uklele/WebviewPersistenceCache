//
//  CacheModel.h
//  WebviewPersistenceCache
//
//  Created by lmsgsendnilself on 2017/2/13.
//  Copyright © 2017年 p. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CacheModel : NSObject

@property(nonatomic, strong)NSData *data;
@property(nonatomic, strong)NSURLResponse *response;
@property(nonatomic, strong)NSURLRequest *redirectRequest;
@end
