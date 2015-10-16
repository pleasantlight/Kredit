//
//  DataManager.h
//  Kredit
//
//  Created by Noam Etzion-Rosenberg on 15-Oct-15.
//  Copyright © 2015 PleasantLight. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Card;

@interface DataManager : NSObject

+ (DataManager*)sharedInstance;

- (void)initializeWithCompletion:(void(^)(BOOL success))completion;

- (void)saveContextWithCompletion:(void(^)(BOOL))completion;

- (void)getCardsWithCompletion:(void(^)(BOOL success, NSArray* cards))completion;

- (void)updateCardsWithCompletion:(void(^)(BOOL success))completion;

@end
