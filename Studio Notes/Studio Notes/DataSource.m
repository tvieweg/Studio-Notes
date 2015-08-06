//
//  DataSource.m
//  Studio Notes
//
//  Created by Trevor Vieweg on 7/23/15.
//  Copyright (c) 2015 Trevor Vieweg. All rights reserved.
//

#import "DataSource.h"

@implementation DataSource

+ (instancetype) sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses an app group. 
    return [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.studionotes"];

}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Studio_Notes" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    _persistentStoreCoordinator = [self setPersistentStore];
    
    return _persistentStoreCoordinator;

}

- (NSPersistentStoreCoordinator *)setPersistentStore {
    
    [self observeCloudActions];

    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                             nil];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"iCloudSetting"] == YES)
    {
        NSMutableDictionary *addiCloud = [NSMutableDictionary dictionaryWithDictionary:options];
        [addiCloud setObject:[NSString stringWithFormat:@"StudioNotesCloudStore"] forKey:NSPersistentStoreUbiquitousContentNameKey];
        options = addiCloud;
    }
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.studionotes"];
    storeURL = [storeURL URLByAppendingPathComponent:@"Studio_Notes.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
    {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    NSLog(@"PS: %@", _persistentStoreCoordinator);
    return _persistentStoreCoordinator;
    
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        
        return nil;
        
    } else {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - New object

- (void)insertNewObject:(id)sender {
    NSManagedObjectContext *context = self.managedObjectContext;
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Note"inManagedObjectContext:context];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:[NSDate date] forKey:@"dateModified"];
    [newManagedObject setValue:@"New Song" forKey:@"title"];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (void)insertNewObjectWithTitle:(NSString *)title bpm:(NSString *)bpm key:(NSString *)key productionNotes:(NSString *)productionNotes {
    
    NSManagedObjectContext *context = self.managedObjectContext;
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Note"inManagedObjectContext:context];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:[NSDate date] forKey:@"dateModified"];
    [newManagedObject setValue:title forKey:@"title"];
    [newManagedObject setValue:bpm forKey:@"bpm"];
    [newManagedObject setValue:key forKey:@"key"];
    [newManagedObject setValue:productionNotes forKey:@"productionNotes"]; 
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

#pragma mark - iCloud Core Data Notification Methods

- (void)observeCloudActions
{
    NSNotificationCenter *notifications = [NSNotificationCenter defaultCenter];
    
    [notifications addObserver:self
                      selector:@selector(storesDidChange:)
                          name:NSPersistentStoreCoordinatorStoresDidChangeNotification
                        object:nil];
    
    [notifications addObserver:self
                      selector:@selector(storesWillChange:)
                          name:NSPersistentStoreCoordinatorStoresWillChangeNotification
                        object:nil];
    
    [notifications addObserver:self
                      selector:@selector(storesDidImportContent:)
                          name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
                        object:nil];
}

- (void)storesWillChange:(NSNotification *)notification
{
    NSManagedObjectContext *context = self.managedObjectContext;
    
    [context performBlockAndWait:^{
        if ([context hasChanges])
        {
            [self saveContext];
        }
        
        [context reset];
    }];
    
    self.iCloudConnectivityDidChange = YES;
    
}

- (void)storesDidChange:(NSNotification *)notification
{
    self.iCloudConnectivityDidChange = YES;
}

- (void)storesDidImportContent:(NSNotification *)notification
{
    NSManagedObjectContext *context = self.managedObjectContext;
    
    [context performBlock:^{
        NSLog(@"Importing content");
        
        [context mergeChangesFromContextDidSaveNotification:notification];
    }];
    
    self.iCloudConnectivityDidChange = NO;
}




@end
