//
//  CacheRequestProtocol.h
//  WebviewPersistenceCache
//
//  Created by lmsgsendnilself on 2017/2/13.
//  Copyright © 2017年 p. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CacheRequestProtocol : NSURLProtocol

+(void)addSupportedScheme:(NSString *)scheme;

@end
