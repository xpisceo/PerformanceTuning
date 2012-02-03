//
//  FetchAllMoviesAndActorsWithThreadingTest.m
//  PerformanceTuning
//
//  Created by  on 12-2-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FetchAllMoviesAndActorsWithThreadingTest.h"
#import "PerformanceTuningAppDelegate.h"
#import "PerformanceTuningViewController.h"

@implementation FetchAllMoviesAndActorsWithThreadingTest

+ (FetchAllMoviesAndActorsWithThreadingTest *)shareInstance
{
    static dispatch_once_t pred;
	static FetchAllMoviesAndActorsWithThreadingTest *shared = nil;
	
	dispatch_once(&pred, ^{
		shared = [[FetchAllMoviesAndActorsWithThreadingTest alloc] init];
        
	});
	
	return shared;
}

- (NSString *)name {
	return @"Fetch all test with threading";
}

- (id)init
{
    if (self = [super init])
    {
        a = 10;
    }
    
    return self;
}

- (void)run
{

    start = [[NSDate date] retain];//如果子线程要用，得用copy,因为会自动回收，不同的runloop
    
    DBManager *sharedDB = [DBManager shareInstance];
    NSManagedObjectContext *moContext = [sharedDB managedObjectContext];
    
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease]; 
	[request setEntity:[NSEntityDescription entityForName:@"Movie" inManagedObjectContext:moContext]];
        
    retriveBlock rBlock = ^(NSArray *array){
        int actorsRead = 0, studiosRead = 0; 
        if ([array count] > 0) 
        {
            for (NSManagedObject *object in array) 
            {
                actorsRead  += [[object valueForKey:@"actors"] count];
                studiosRead += [[object valueForKey:@"studios"] count];
            }
            
        }
        
        NSString *str = [NSString stringWithFormat:@"Fetched %d actors and %d studios", actorsRead,studiosRead];

        if ([NSThread currentThread] == [NSThread mainThread]) {
            [self updateUI:str];
        }
        else
        {
            [self performSelectorOnMainThread:@selector(updateUI:) withObject:str waitUntilDone:NO];
        }
        
    };
    
    
    [sharedDB retriveObject:request success:rBlock failed:^(NSError *err) {
        NSLog(@"run retrive test error:%@", [err localizedDescription]);
    }];
    
}

+ (void)update:(NSString *)str
{
    FetchAllMoviesAndActorsWithThreadingTest *sharedTest = [FetchAllMoviesAndActorsWithThreadingTest shareInstance];
    
    [sharedTest updateUI:str];
}

- (void)updateUI:(NSString *)str
{
    PerformanceTuningAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    PerformanceTuningViewController *appController = appDelegate.viewController;
    
    
    stop = [NSDate date];
    
    
    appController.startTime.text   = [start description]; 
    appController.stopTime.text    = [stop description];
    appController.elapsedTime.text = [NSString stringWithFormat:@"%.03f seconds", [stop timeIntervalSinceDate:start]];
    appController.results.text = str;
    
}

@end
