//
//  DataManager.m
//  Kredit
//
//  Created by Noam Etzion-Rosenberg on 15-Oct-15.
//  Copyright © 2015 PleasantLight. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <Crashlytics/Crashlytics.h>

#import "DataManager.h"
#import "CommManager.h"

@interface DataManager()

@property (nonatomic, strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel* managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator* persistentStoreCoordinator;
@property (nonatomic, strong) dispatch_queue_t dataManagerDispatchQueue;

- (instancetype)initPrivate;
- (NSURL*)applicationDocumentsDirectory;
- (void)removeAllCards;
- (void)addCardWithDict:(NSDictionary*)theCardDict;
- (NSArray*)loadAllCards;

@end


@implementation DataManager

#pragma mark - Class Methods:

+ (DataManager*)sharedInstance {
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] initPrivate];
    });
}


#pragma mark - Public Methods:

- (void)initializeWithCompletion:(void(^)(BOOL))completion {
    dispatch_async(self.dataManagerDispatchQueue, ^{
        NSArray* cards = [self loadAllCards];
        BOOL success = ([cards isKindOfClass:[NSArray class]] && [cards count] > 0);
        if (success == NO) {
            ELog(@"Unable to execute fetch request.");
        }
        else {
            success = ([cards count] > 0);
        }
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(success);
            });
        }
    });
}

- (void)saveContextWithCompletion:(void(^)(BOOL))completion {
    dispatch_async(self.dataManagerDispatchQueue, ^{
        NSManagedObjectContext* managedObjectContext = self.managedObjectContext;
        if (managedObjectContext != nil) {
            NSError* error = nil;
            if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
                // TODO: Failed to save to data store - need to add a better method of handling this error.
                CLog(@"Unresolved error %@, %@", error, [error userInfo]);
                [[Crashlytics sharedInstance] throwException];
            }
        }
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(YES);
            });
        }
    });
}

- (void)getCardsWithCompletion:(void(^)(BOOL success, NSArray* cards))completion {
    __block NSArray* localCards = nil;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_async(self.dataManagerDispatchQueue, ^{
            localCards = [self loadAllCards];
            dispatch_semaphore_signal(semaphore);
        });
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion([localCards isKindOfClass:[NSArray class]], localCards);
        });
    });
}

- (void)updateCardsWithCompletion:(void(^)(BOOL success))completion {
    void(^localCompletionBlock)(BOOL, NSString*) = ^(BOOL success, NSString* error) {
        if ([error length] > 0) {
            ELog(@"%@", error);
        }
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(success);
            });
        }
    };
    
    [[CommManager sharedInstance] loadCardsWithCompletion:^(BOOL success, NSArray* cardsData) {
        if (success == NO) {
            localCompletionBlock(NO, @"Failed to download new card data.");
            return;
        }
        
        dispatch_async(self.dataManagerDispatchQueue, ^{
            [self removeAllCards];
            
            [cardsData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop) {
                NSDictionary* cardDict = (NSDictionary*)(obj);
                [self addCardWithDict:cardDict];
            }];
            
            localCompletionBlock(YES, nil);
        });
    }];
}


#pragma mark - Core Data stack

- (NSURL*)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel*)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSURL* modelURL = [[NSBundle mainBundle] URLForResource:@"Kredit" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator*)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL* storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Kredit.sqlite"];
    NSError* error = nil;
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // TODO: Database failed to initialize - need to add a better method of handling this error.
        NSString* failureReason = @"There was an error creating or loading the application's saved data.";
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        
        ELog(@"Unresolved error %@, %@", error, [error userInfo]);
        [[Crashlytics sharedInstance] throwException];
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext*)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator* coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}


#pragma mark - Private Methods:

- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        _dataManagerDispatchQueue = dispatch_queue_create("data_manager_dispatch_queue", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

- (void)removeAllCards {
    [self.managedObjectContext performBlockAndWait:^{
        NSFetchRequest* fetch = [[NSFetchRequest alloc] init];
        [fetch setEntity:[NSEntityDescription entityForName:@"Card" inManagedObjectContext:self.managedObjectContext]];
        NSArray* result = [self.managedObjectContext executeFetchRequest:fetch error:nil];
        for (id card in result) {
            [self.managedObjectContext deleteObject:card];
        }        
    }];
}

- (void)addCardWithDict:(NSDictionary*)theCardDict {
    __block NSString* attribute = nil;
    __block id value = nil;
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:sszzzz"];
    
    NSEntityDescription* entityDescription = [NSEntityDescription entityForName:@"Card" inManagedObjectContext:self.managedObjectContext];
    
    @try {
        NSManagedObject* aCard = [[NSManagedObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:self.managedObjectContext];
        [theCardDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop) {
            attribute = (NSString*)key;
            value = obj;

            if ([attribute compare:@"created" options:NSCaseInsensitiveSearch] == NSOrderedSame ||
                [attribute compare:@"updated" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                value = [dateFormatter dateFromString:(NSString*)(obj)];
            }
            
            [aCard setValue:value forKey:attribute];
        }];
        
        NSError* saveError = nil;
        if (![aCard.managedObjectContext save:&saveError]) {
            ELog(@"Unable to save managed object context. Error: %@", [saveError localizedDescription]);
            ELog(@"Card raw data: %@", theCardDict);
        }
    }
    @catch (NSException* exception) {
        ELog(@"Failed to create a managed object for card with data: %@", theCardDict);
        ELog(@"Last attribute set: %@.", attribute);
        ELog(@"Last value set: %@.", value);
    }
}

- (NSArray*)loadAllCards {
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"Card" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError* error = nil;
    NSArray* loadedCards = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    return loadedCards;
}

@end
