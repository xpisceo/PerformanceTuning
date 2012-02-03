//
//  DBManager.h
//  pocCameraMap
//
//  Created by Tang Xiaoping on 6/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^retriveBlock) (NSArray *array);
typedef void (^successBlock)();
typedef void (^failedBlock)(NSError *err);
typedef void (^updateBlock)(NSManagedObject *object);

#define COMMAND_INSERT             0x000001
#define COMMAND_UPDATE             0x000002
#define COMMAND_DELETE             0x000003
#define COMMAND_RETRIVE            0x000004

#define COMMAND_TYPE_KEY               @"type"
#define COMMAND_REQUEST_KEY            @"request"
#define ENTITY_NAME_KEY                @"ename"
#define SUCCESS_BLOCK_KEY              @"sblock"
#define FAILED_BLOCK_KEY               @"fblock"
#define RETRIVE_BLOCK_KEY              @"rblock"
#define UPDATE_BLOCK_KEY               @"ublock"

#define LOCK_CONDITION_NODATA          0
#define LOCK_CONDITION_HAVEDATA        1

@interface DBManager : NSObject {
    NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
	
    NSThread     *coreDataThread;
    NSConditionLock  *syCondition;
    
    NSMutableArray *commandArray;
}


+ (DBManager *)shareInstance;
+ (void)clearInstance;


@property (nonatomic, retain) NSThread    *coreDataThread;
@property (nonatomic, retain) NSConditionLock *syCondition;
@property (nonatomic, retain) NSMutableArray *commandArray;


@property (nonatomic, retain, readonly) NSManagedObjectContext       *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel         *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;


- (void)insertObject:(updateBlock)iBlock entityName:(NSString *)name success:(successBlock)sBlock failed:(failedBlock)fBlock;
- (void)updateObject:(updateBlock)uBlock request:(NSFetchRequest *)request success:(successBlock)sBlock failed:(failedBlock)fBlock;
- (void)deleteObject:(NSFetchRequest *)request success:(successBlock)sBlock failed:(failedBlock)fBlock;
- (void)retriveObject:(NSFetchRequest *)request success:(retriveBlock)rBlock failed:(failedBlock)fBlock;

@end
