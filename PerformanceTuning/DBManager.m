//
//  DBManager.m
//  pocCameraMap
//
//  Created by Tang Xiaoping on 6/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

//nsconditionlock reference http://www.cocoadev.com/index.pl?ProducersAndConsumerModel

#import "DBManager.h"
#import "Actor.h"

@interface DBManager (Private)

- (void)performanceDB;

- (void)insertData:(updateBlock)iBlock toEntity:(NSString *)name success:(successBlock)sBlock failed:(failedBlock)fBlock;
- (void)updateData:(updateBlock)uBlock request:(NSFetchRequest *)request success:(successBlock)sBlock failed:(failedBlock)fBlock;
- (void)deleteData:(NSFetchRequest *)request success:(successBlock)sBlock failed:(failedBlock)fBlock;
- (void)retriveData:(NSFetchRequest *)request finish:(retriveBlock)sBlock failed:(failedBlock)fBlock;

- (NSURL *)applicationDocumentsDirectory;
- (void)saveContext;

@end



@implementation DBManager

@synthesize coreDataThread;
@synthesize syCondition;
@synthesize commandArray;

+(DBManager *)shareInstance {
	static dispatch_once_t pred;
	static DBManager *shared = nil;
	
	dispatch_once(&pred, ^{
		shared = [[DBManager alloc] init];
        
	});
	
	return shared;
}

+ (void)clearInstance
{
    DBManager *shared = [DBManager shareInstance];
    [shared release];
    shared    = nil;
}

- (void)run
{
    while (YES) 
    {
        [syCondition lockWhenCondition:LOCK_CONDITION_HAVEDATA];
        
        
        if ([commandArray count] > 0) 
        {
            NSDictionary *commandDic = [commandArray objectAtIndex:0];
            
            if (commandArray) 
            {
                NSNumber *command_type = [commandDic objectForKey:COMMAND_TYPE_KEY];
                
                switch ([command_type intValue]) 
                {
                    case COMMAND_INSERT:
                    {
                        updateBlock  uBlock      = [commandDic objectForKey:UPDATE_BLOCK_KEY];
                        successBlock sBlock      = [commandDic objectForKey:SUCCESS_BLOCK_KEY];
                        failedBlock  fBlock      = [commandDic objectForKey:FAILED_BLOCK_KEY];
                        NSString     *entityName = [commandDic objectForKey:ENTITY_NAME_KEY];
                        
                        [self insertData:uBlock toEntity:entityName success:sBlock failed:fBlock];
                        break;
                    }
                    case COMMAND_UPDATE:
                    {
                        updateBlock  uBlock      = [commandDic objectForKey:UPDATE_BLOCK_KEY];
                        successBlock sBlock      = [commandDic objectForKey:SUCCESS_BLOCK_KEY];
                        failedBlock  fBlock      = [commandDic objectForKey:FAILED_BLOCK_KEY];
                        NSFetchRequest *request  = [commandDic objectForKey:COMMAND_REQUEST_KEY];
                        
                        [self updateData:uBlock request:request success:sBlock failed:fBlock];
                        
                        break;
                    }
                    case COMMAND_RETRIVE:
                    {
                        retriveBlock rBlock      = [commandDic objectForKey:RETRIVE_BLOCK_KEY];
                        failedBlock  fBlock      = [commandDic objectForKey:FAILED_BLOCK_KEY];
                        NSFetchRequest *request  = [commandDic objectForKey:COMMAND_REQUEST_KEY];
                        
                        [self retriveData:request finish:rBlock failed:fBlock];
                        
                        break;
                    }
                    case COMMAND_DELETE:
                    {
                        retriveBlock sBlock      = [commandDic objectForKey:SUCCESS_BLOCK_KEY];
                        failedBlock  fBlock      = [commandDic objectForKey:FAILED_BLOCK_KEY];
                        NSFetchRequest *request  = [commandDic objectForKey:COMMAND_REQUEST_KEY];
                        
                        [self deleteData:request success:sBlock failed:fBlock];
                        
                        break;
                    }
                    default:
                        break;
                }
            }
            
            
            [commandArray removeObjectAtIndex:0];
            
        }
        
        int count = [commandArray count];
        [syCondition unlockWithCondition:(count > 0)?LOCK_CONDITION_HAVEDATA : LOCK_CONDITION_NODATA];
    }
}

- (id) init{
	
	if (self = [super init])
	{
		NSManagedObjectContext *context = [self managedObjectContext];
		if (!context) {
			// Handle the error.
			NSLog(@"managedObjectContext Initialization Failed!");
		}
        
        //[context setStalenessInterval:0.0];
        
        self.commandArray    = [[[NSMutableArray alloc] init] autorelease];
        self.syCondition     = [[[NSConditionLock alloc] initWithCondition:LOCK_CONDITION_NODATA] autorelease];
        self.coreDataThread  = [[[NSThread alloc] initWithTarget:self selector:@selector(run) object:nil] autorelease];
        [self.coreDataThread start];

	}
	return self;
}

#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    
    if (managedObjectContext_ != nil) {
        return managedObjectContext_;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext_ = [[NSManagedObjectContext alloc] init];
        [managedObjectContext_ setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext_;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel_ != nil) {
        return managedObjectModel_;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"PerformanceTuning" withExtension:@"momd"];
    managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];  
	//managedObjectModel_ = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];
    return managedObjectModel_;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator_ != nil) {
        return persistentStoreCoordinator_;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"PerformanceTuning.sqlite"];
    NSLog(@"db: %@",[storeURL absoluteURL]);
    NSError *error = nil;
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return persistentStoreCoordinator_;
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma mark --
#pragma mark function

- (void)saveContext {
    
    NSError *error = nil;
	NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}    


- (void)dealloc {
    [super dealloc];
    [managedObjectContext_ release];
    [managedObjectModel_ release];
    [persistentStoreCoordinator_ release];
	//[logicTimer invalidate];
    
    [coreDataThread release]; coreDataThread = nil;
    [syCondition    release]; syCondition    = nil;
    [commandArray   release]; commandArray   = nil;
}


#pragma mark --
#pragma mark action

#pragma mark - private methord
- (void)insertData:(updateBlock)iBlock toEntity:(NSString *)name success:(successBlock)sBlock failed:(failedBlock)fBlock
{
    
    NSError *error = nil;
    
    NSManagedObjectModel   *moModel      = [self managedObjectModel];
    NSManagedObjectContext *moContext    = [self managedObjectContext];
    NSEntityDescription    *EntityDec    = [[moModel entitiesByName] objectForKey:name];
    
    Class EntityObject = NSClassFromString(name);
    if (EntityObject) {
        NSManagedObject *insertValue = [NSEntityDescription insertNewObjectForEntityForName:[EntityDec name] inManagedObjectContext:moContext];
        
        if (insertValue) 
        {
            
            iBlock(insertValue);
            
            if (![moContext save: &error]) {
                fBlock(error);
            }
            else
            {
                sBlock();
            }
            
        }
    }
}

- (void)updateData:(updateBlock)uBlock request:(NSFetchRequest *)request success:(successBlock)sBlock failed:(failedBlock)fBlock
{
    NSError *error = nil;
    
    NSManagedObjectContext *moContext = [self managedObjectContext];
    
    if (moContext) 
    {
        NSArray *fetchedObjects = [moContext executeFetchRequest:request error:&error];
        
        if (error) 
        {
            fBlock(error);
        }
        else
        {
            for (NSManagedObject *info in fetchedObjects) 
            {
                uBlock(info);
            }
            
            if (![moContext save: &error]) 
            {
                fBlock(error);
            }
            else
            {
                sBlock();
            }
        }
    }
}

- (void)deleteData:(NSFetchRequest *)request success:(successBlock)sBlock failed:(failedBlock)fBlock
{
    NSError *error = nil;
    
    NSManagedObjectContext *moContext    = [self managedObjectContext];
    if (moContext) 
    {
        NSArray *fetchedObjects = [moContext executeFetchRequest:request error:&error];
        
        if (error) 
        {
            fBlock(error);
        }
        else
        {
            
            for (NSManagedObject *info in fetchedObjects) 
            {
                [moContext deleteObject:info];
            }
            
            if (![moContext save: &error]) 
            {
                fBlock(error);
            }
            else
            {
                sBlock();
            }
        }
    }
}

- (void)retriveData:(NSFetchRequest *)request finish:(retriveBlock)sBlock failed:(failedBlock)fBlock
{
    NSError *error = nil;
    
    NSManagedObjectContext *moContext = [self managedObjectContext];
    
    if (moContext) 
    {
        NSArray *fetchedObjects = [moContext executeFetchRequest:request error:&error];
        
        if (error) 
        {
            fBlock(error);
        }
        else
        {
            sBlock(fetchedObjects);
        }
    }
}

#pragma mark - For user to use
- (void)insertObject:(updateBlock)iBlock entityName:(NSString *)name success:(successBlock)sBlock failed:(failedBlock)fBlock
{
    updateBlock  iB = [iBlock copy];
    successBlock sB = [sBlock copy];
    failedBlock  fB = [fBlock copy];
    
    NSNumber *type = [NSNumber numberWithInt:COMMAND_INSERT];
    NSDictionary *command = [NSDictionary dictionaryWithObjectsAndKeys:type,COMMAND_TYPE_KEY, iB, UPDATE_BLOCK_KEY, sB, SUCCESS_BLOCK_KEY, fB, FAILED_BLOCK_KEY, name, ENTITY_NAME_KEY, nil];
    
    [syCondition lock];
    [commandArray addObject:command];
    [syCondition unlockWithCondition:LOCK_CONDITION_HAVEDATA];
    
    [iB release];
    [sB release];
    [fB release];
}

- (void)updateObject:(updateBlock)uBlock request:(NSFetchRequest *)request success:(successBlock)sBlock failed:(failedBlock)fBlock
{
    updateBlock  uB = [uBlock copy];
    successBlock sB = [sBlock copy];
    failedBlock  fB = [fBlock copy];
    
    NSNumber *type = [NSNumber numberWithInt:COMMAND_UPDATE];
    
    NSDictionary *command = [NSDictionary dictionaryWithObjectsAndKeys:type, COMMAND_TYPE_KEY, uB, UPDATE_BLOCK_KEY, sB, SUCCESS_BLOCK_KEY, fB, FAILED_BLOCK_KEY, request, COMMAND_REQUEST_KEY, nil];
    
    [syCondition lock];
    [commandArray addObject:command];
    [syCondition unlockWithCondition:LOCK_CONDITION_HAVEDATA];
    
    [uB release];
    [sB release];
    [fB release];
}

- (void)deleteObject:(NSFetchRequest *)request success:(successBlock)sBlock failed:(failedBlock)fBlock
{
    successBlock sB = [sBlock copy];
    failedBlock  fB = [fBlock copy];
    
    NSNumber *type = [NSNumber numberWithInt:COMMAND_DELETE];
    
    NSDictionary *command = [NSDictionary dictionaryWithObjectsAndKeys:type, COMMAND_TYPE_KEY, sB, SUCCESS_BLOCK_KEY, fB, FAILED_BLOCK_KEY, request, COMMAND_REQUEST_KEY, nil];
    
    [syCondition lock];
    [commandArray addObject:command];
    [syCondition unlockWithCondition:LOCK_CONDITION_HAVEDATA];
    
    [sB release];
    [fB release];
}

- (void)retriveObject:(NSFetchRequest *)request success:(retriveBlock)rBlock failed:(failedBlock)fBlock
{
    retriveBlock rB  = [rBlock copy];
    failedBlock  fB  = [fBlock copy];
    NSNumber *type = [NSNumber numberWithInt:COMMAND_RETRIVE];
    NSDictionary *command = [NSDictionary dictionaryWithObjectsAndKeys:type, COMMAND_TYPE_KEY, rB, RETRIVE_BLOCK_KEY, fB, FAILED_BLOCK_KEY, request, COMMAND_REQUEST_KEY, nil];
    
    [rB release];
    [fB release];

    [syCondition lock];
    [commandArray addObject:command];
    [syCondition unlockWithCondition:LOCK_CONDITION_HAVEDATA];
}

@end
