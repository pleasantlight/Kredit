//
//  AppDelegate.m
//  Kredit
//
//  Created by Noam Etzion-Rosenberg on 15-Oct-15.
//  Copyright © 2015 PleasantLight. All rights reserved.
//

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

#import "AppDelegate.h"
#import "DataManager.h"
#import "CommManager.h"
#import "ViewController.h"

@interface AppDelegate()

- (void)initSubsystemsWithCompletion:(void(^)(void))completion;

@end


@implementation AppDelegate


- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
    [Fabric with:@[[Crashlytics class]]];

    ViewController* rootVC = (ViewController*)(self.window.rootViewController);
    
    [rootVC showSpinner];
    [self initSubsystemsWithCompletion:^{
        [(ViewController*)self.window.rootViewController refresh];
        [rootVC hideSpinner];
    }];
    
    return YES;
}


#pragma mark - Application lifecycle:

- (void)applicationWillResignActive:(UIApplication*)application {
}

- (void)applicationDidEnterBackground:(UIApplication*)application {
}

- (void)applicationWillEnterForeground:(UIApplication*)application {
}

- (void)applicationDidBecomeActive:(UIApplication*)application {
}

- (void)applicationWillTerminate:(UIApplication*)application {
    [[DataManager sharedInstance] saveContextWithCompletion:nil];
}


#pragma mark - Private Methods:

- (void)initSubsystemsWithCompletion:(void(^)(void))completion {
    [[DataManager sharedInstance] initializeWithCompletion:^(BOOL success) {
        [[CommManager sharedInstance] initializeWithCompletion:^(BOOL success) {
            [[DataManager sharedInstance] updateCardsWithCompletion:^(BOOL success) {
                completion();
            }];
        }];
    }];
}

@end
