//
//  CommManager.h
//  Kredit
//
//  Created by Noam Etzion-Rosenberg on 15-Oct-15.
//  Copyright © 2015 PleasantLight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CommManager : NSObject

+ (CommManager*)sharedInstance;

- (void)initializeWithCompletion:(void(^)(BOOL success))completion;

- (void)loadCardsWithCompletion:(void(^)(BOOL success, NSArray* cardsData))completion;
- (void)loadImageWithURL:(NSURL*)theURL andCompletion:(void(^)(BOOL success, UIImage* image))completion;

@end
