//
//  FetchAllMoviesActorsAndStudiosTest.m
//  PerformanceTuning
//
//  Created by Tang Xiaoping on 7/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FetchAllMoviesActorsAndStudiosTest.h"
#import "PerformanceTuningAppDelegate.h"
#import "PerformanceTuningViewController.h"


@implementation FetchAllMoviesActorsAndStudiosTest
- (NSString *)name {
	return @"Fetch all test";
}

- (void)run
{ 
    start = [NSDate date];
    
    NSManagedObjectContext *context = [[DBManager shareInstance] managedObjectContext];
	NSFetchRequest *request = [[NSFetchRequest alloc] init]; 
	[request setEntity:[NSEntityDescription entityForName:@"Movie" inManagedObjectContext:context]];
	NSArray *results = [context executeFetchRequest:request error:nil]; 
	int actorsRead = 0, studiosRead = 0; 
	for (NSManagedObject *movie in results) {
		actorsRead += [[movie valueForKey:@"actors"] count]; 
		studiosRead += [[movie valueForKey:@"studios"] count];
		[context refreshObject:movie mergeChanges:NO];
	} 
	[request release]; 
    NSString *str = [NSString stringWithFormat:@"Fetched %d actors and %d studios", actorsRead,studiosRead];
    
    
    if ([NSThread currentThread] == [NSThread mainThread]) {
        [self updateUI:str];
    }
    else
    {
        [self performSelectorOnMainThread:@selector(updateUI:) withObject:str waitUntilDone:NO];
    }
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
