//
//  CacheModel.m
//  WebviewPersistenceCache
//
//  Created by lmsgsendnilself on 2017/2/13.
//  Copyright © 2017年 p. All rights reserved.
//

#import "CacheModel.h"

@interface CacheModel()<NSCoding>

@end

@implementation CacheModel

- (void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:self.data forKey:@"data"];
    [aCoder encodeObject:self.response forKey:@"response"];
    [aCoder encodeObject:self.redirectRequest forKey:@"redirectRequest"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    
    if (self = [super init]) {
        [self setData:[aDecoder decodeObjectForKey:@"data"]];
        [self setResponse:[aDecoder decodeObjectForKey:@"response"]];
        [self setRedirectRequest:[aDecoder decodeObjectForKey:@"redirectRequest"]];
    }
    
    return self;
}

@end
