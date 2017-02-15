//
//  NSURLRequest+MutableCopySubstitute.m
//  WebviewPersistenceCache
//
//  Created by lmsgsendnilself on 2017/2/13.
//  Copyright © 2017年 p. All rights reserved.
//

#import "NSURLRequest+MutableCopySubstitute.h"

@implementation NSURLRequest (MutableCopySubstitute)

- (id)mutableCopySubstitute{
    NSMutableURLRequest *mutableCopy = [[NSMutableURLRequest alloc] initWithURL:[self URL]
                                                                           cachePolicy:[self cachePolicy]
                                                                       timeoutInterval:[self timeoutInterval]];
   
    [mutableCopy setAllHTTPHeaderFields:[self allHTTPHeaderFields]];
    [mutableCopy setHTTPMethod:[self HTTPMethod]];
    
    if ([self HTTPBodyStream]) {
        
        [mutableCopy setHTTPBodyStream:[self HTTPBodyStream]];
        
    } else {
        
        [mutableCopy setHTTPBody:[self HTTPBody]];
    }
    
    return mutableCopy;
}

@end
