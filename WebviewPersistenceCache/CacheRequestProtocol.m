//
//  CacheRequestProtocol.m
//  WebviewPersistenceCache
//
//  Created by lmsgsendnilself on 2017/2/13.
//  Copyright © 2017年 p. All rights reserved.
//

#import "CacheRequestProtocol.h"

#import "NSURLRequest+MutableCopySubstitute.h"
#import "CacheModel.h"
#import "NSString+Hashes.h"
#import "Reachability.h"

static NSString *CustomPersistenceMark  = @"customPersistenceMark";
static NSString *CustomPersistenceValue = @"customPersistenceValue";

static NSSet *SupportSchemes = nil;

@interface CacheRequestProtocol ()<NSURLSessionDataDelegate,NSURLSessionTaskDelegate>

@property (nonatomic, strong)NSURLSessionTask *task;
@property (nonatomic, strong)NSMutableData *data;
@property (nonatomic, strong)NSURLResponse *response;
@property (nonatomic, strong)NSURLRequest *redirectRequest;

@end

@implementation CacheRequestProtocol

+(void)load{
    
    [NSURLProtocol registerClass:[CacheRequestProtocol class]];
}

+(void)initialize{
    
    if (self == [CacheRequestProtocol class]){
        
        [self defaultSupportedSchemes];
    }
}

-(instancetype)init{

    if(self = [super init]){
    
        _data = [NSMutableData mutableCopy];
    }
    
    return self;
}

+(BOOL)canInitWithTask:(NSURLSessionTask *)task{

    return [self canInitWithACertainRequest:task.currentRequest];
}

+(BOOL)canInitWithRequest:(NSURLRequest *)request{
    
    return [self canInitWithACertainRequest:request];
}

+(NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request{

    return request;
}

- (void)startLoading{
    
    if ([self needCache]){
        
        CacheModel *cacheModel = [NSKeyedUnarchiver unarchiveObjectWithFile:[self cachePathForRequest:self.request]];
        if (cacheModel) {
            
            if (cacheModel.redirectRequest) {
                [[self client] URLProtocol:self wasRedirectedToRequest:cacheModel.redirectRequest redirectResponse:cacheModel.response];
            }else
                
            //because we cache by ourselves,so prevent from default cache policy
            [self.client URLProtocol:self didReceiveResponse:cacheModel.response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
            [self.client URLProtocol:self didLoadData:cacheModel.data];
            [self.client URLProtocolDidFinishLoading:self];

        }else{
            
            [self.client URLProtocol:self didFailWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCannotConnectToHost userInfo:nil]];
        }
    }else{
        
        _task = [self taskAfreshSend];
        [_task resume];
    }
}

- (void)stopLoading{
    
    [_task cancel];
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler{
   
    _response = response;
    
    //because of using cache policy by ourselves,so prevent from default cache policy
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data{
    
    [self.client URLProtocol:self didLoadData:data];
    [_data appendData:data];
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)newRequest completionHandler:(void (^)(NSURLRequest *))completionHandler {
    
    if (response) {
        NSMutableURLRequest *redirectRequest = [newRequest mutableCopySubstitute];
        [redirectRequest setValue:CustomPersistenceValue forHTTPHeaderField:CustomPersistenceMark];
        [self archiverWithRedirectRequest:redirectRequest];
        
        [[self client] URLProtocol:self wasRedirectedToRequest:redirectRequest redirectResponse:response];
        
        completionHandler(redirectRequest);
        
    } else {
        completionHandler(newRequest);
    }}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
    didCompleteWithError:(nullable NSError *)error{
    
    if (error) {
        [self.client URLProtocol:self didFailWithError:error];
        
    }else {
        
        [self.client URLProtocolDidFinishLoading:self];
        [self archiver];
    }
    
    [self resetCurrentCache];
}

#pragma mark- private

+(BOOL)canInitWithACertainRequest:(NSURLRequest *)request{

    if ([SupportSchemes containsObject:[request.URL scheme]] &&
        (![request valueForHTTPHeaderField:CustomPersistenceMark])){
        
        return YES;
    }
    return NO;
}

-(NSURLSessionTask *)taskAfreshSend{
    
    NSMutableURLRequest *request = [self.request mutableCopySubstitute];
    [request setValue:CustomPersistenceValue forHTTPHeaderField:CustomPersistenceMark];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    //add custom protocol to session config
    config.protocolClasses = [config.protocolClasses arrayByAddingObject:self.class];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    
    return [session dataTaskWithRequest:request];
}

- (BOOL)needCache{
    return [[Reachability reachabilityWithHostname:self.request.URL.host] currentReachabilityStatus] == NotReachable;
}

-(void)archiver{
    [self archiverWithRedirectRequest:nil];
}

-(void)resetCurrentCache{
    _task = nil;
    _data = nil;
    _response = nil;
}

-(void)archiverWithRedirectRequest:(NSURLRequest *)request{
    
    CacheModel *cacheModel = [[CacheModel alloc]init];
    cacheModel.data = _data;
    cacheModel.response = _response;
    cacheModel.redirectRequest = request;
    
    NSString *cachePath = [self cachePathForRequest:self.request];
    [NSKeyedArchiver archiveRootObject:cacheModel toFile:cachePath];
}

- (NSString *)cachePathForRequest:(NSURLRequest *)request{
    
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName = [[[request URL] absoluteString] sha1];
    
    return [cachePath stringByAppendingPathComponent:fileName];
}

#pragma mark - Scheme ref
+(NSSet *)defaultSupportedSchemes{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SupportSchemes = [NSSet setWithObjects:@"http",@"https", nil];
    });
    
    return SupportSchemes;
}

+(void)setSupportedSchemes:(NSSet *)supportedSchemes{

    SupportSchemes = supportedSchemes;
}

+(void)addSupportedScheme:(NSString *)scheme{
    
    SupportSchemes = [SupportSchemes setByAddingObject:scheme];
}

-(void)removeSupportedScheme:(NSString *)scheme{
    
    NSMutableSet *mutableSetCopy = [SupportSchemes mutableCopy];
    [mutableSetCopy removeObject:scheme];
    SupportSchemes = mutableSetCopy;
}

@end

