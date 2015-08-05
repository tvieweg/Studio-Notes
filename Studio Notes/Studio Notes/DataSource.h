//
//  DataSource.h
//  Studio Notes
//
//  Created by Trevor Vieweg on 7/23/15.
//  Copyright (c) 2015 Trevor Vieweg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DataSource : NSObject


@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (instancetype) sharedInstance;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)insertNewObject:(id)sender;
- (void)insertNewObjectWithTitle:(NSString *)title bpm:(NSString *)bpm key:(NSString *)key lyrics:(NSString *)lyrics productionNotes:(NSString *)productionNotes; 

@end
