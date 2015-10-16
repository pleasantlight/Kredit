//
//  CommManager.m
//  Kredit
//
//  Created by Noam Etzion-Rosenberg on 15-Oct-15.
//  Copyright © 2015 PleasantLight. All rights reserved.
//

#import "CommManager.h"

static NSString* CARD_DATA_URL = @"http://s3.amazonaws.com/mobile.coin.vc/ios/assignment/data.json";

@interface CommManager() <NSURLSessionDelegate>

- (instancetype)initPrivate;

@property (nonatomic, strong) dispatch_queue_t commManagerDispatchQueue;
@property (nonatomic, strong) NSURLSession* session;

@end


@implementation CommManager

+ (CommManager*)sharedInstance {
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] initPrivate];
    });
}


#pragma mark - Public Methods:

- (void)initializeWithCompletion:(void(^)(BOOL))completion {
    dispatch_async(self.commManagerDispatchQueue, ^{
        NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfig.timeoutIntervalForRequest = 15.0;
        self.session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(YES);
            });
        }
    });
}

- (void)loadCardsWithCompletion:(void(^)(BOOL success, NSArray* cardsData))completion {
    void(^localCompletionBlock)(BOOL, NSArray*, NSString*) = ^(BOOL success, NSArray* cardsData, NSString* error) {
        if ([error length] > 0) {
            ELog(@"%@", error);
        }
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(success, cardsData);
            });
        }
    };
    
    dispatch_async(self.commManagerDispatchQueue, ^{
        NSURL* url = [NSURL URLWithString:CARD_DATA_URL];
        NSURLSessionDataTask* dataTask = [self.session dataTaskWithURL:url completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
            if ([error isKindOfClass:[NSError class]]) {
                localCompletionBlock(NO, nil, [NSString stringWithFormat:@"Failed to download recent card data from URL '%@'. Error: %@", CARD_DATA_URL, error]);
                return;
            }
            
            NSDictionary* jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (error || [jsonDictionary isKindOfClass:[NSDictionary class]] == NO) {
                localCompletionBlock(NO, nil, [NSString stringWithFormat:@"Failed to parse data loaded from API at URL '%@'.", CARD_DATA_URL]);
                return;
            }
            
            NSArray* resultsArray = jsonDictionary[@"results"];
            localCompletionBlock(YES, resultsArray, nil);
        }];
        
        [dataTask resume];
    });
}

- (void)loadImageWithURL:(NSURL*)theURL andCompletion:(void(^)(BOOL success, UIImage* image))completion {
    void(^localCompletionBlock)(BOOL, UIImage*, NSString*) = ^(BOOL success, UIImage* image, NSString* error) {
        if ([error length] > 0) {
            ELog(@"%@", error);
        }
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(success, image);
            });
        }
    };
    
    dispatch_async(self.commManagerDispatchQueue, ^{
        NSURLSessionDataTask* dataTask = [self.session dataTaskWithURL:theURL completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
            if ([error isKindOfClass:[NSError class]]) {
                localCompletionBlock(NO, nil, [NSString stringWithFormat:@"Failed to download image from URL '%@'. Error: %@", theURL, error]);
                return;
            }

            UIImage* downloadedImage = [UIImage imageWithData:data];
            if ([downloadedImage isKindOfClass:[UIImage class]] == NO) {
                localCompletionBlock(NO, nil, @"Failed to convert image data to image.");
                return;
            }
            
            localCompletionBlock(YES, downloadedImage, nil);
        }];
        
        [dataTask resume];
    });
}


#pragma mark - Private Methods:

- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        _commManagerDispatchQueue = dispatch_queue_create("comm_manager_dispatch_queue", DISPATCH_QUEUE_CONCURRENT);
        _session = nil;
    }
    
    return self;
}

@end
