//
//  PerformanceTuningViewController.m
//  PerformanceTuning
//
//  Created by Tang Xiaoping on 7/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PerformanceTuningViewController.h"
#import "PerformanceTest.h" 
#import "FetchAllMoviesActorsAndStudiosTest.h"
#import "FetchAllMoviesAndActorsWithThreadingTest.h"
#import "PerformanceTuningAppDelegate.h"
#import "DBManager.h"
#import "Actor.h"

@implementation PerformanceTuningViewController
@synthesize startTime, stopTime, elapsedTime, results, testPicker, tests;

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	startTime.text = @""; 
	stopTime.text = @""; 
	elapsedTime.text = @""; 
	results.text = @"";
	
	FetchAllMoviesActorsAndStudiosTest *famaasTest = [[FetchAllMoviesActorsAndStudiosTest alloc] init];
    FetchAllMoviesAndActorsWithThreadingTest *threadTest = [FetchAllMoviesAndActorsWithThreadingTest shareInstance];
	self.tests = [[NSArray alloc] initWithObjects:famaasTest, threadTest, nil]; 
	[famaasTest release];
    [threadTest release];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - 
#pragma mark UIPickerViewDataSource methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView { 
	return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return [self.tests count];
}
#pragma mark - 
#pragma mark UIPickerViewDelegate methods
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	id <PerformanceTest> test = [self.tests objectAtIndex:row]; 
	return [test name];
}
#pragma mark - 
#pragma mark Run the test 
- (IBAction)runTest:(id)sender { 
	
	id <PerformanceTest> test = [self.tests objectAtIndex:[testPicker selectedRowInComponent:0]];
	
    [test run]; 
	
}


- (IBAction)retriveTest:(id)sender
{
    DBManager *sharedDB = [DBManager shareInstance];
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    NSManagedObjectContext *moContext = [sharedDB managedObjectContext];
    
    //1. set the entity
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Actor" inManagedObjectContext:moContext];
    [request setEntity:entity];
    
    //2. set the sort
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [[NSMutableArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    [sortDescriptor release];
	[sortDescriptors release];
    
    //3. set limit
    //[request setFetchLimit:1];
    
    //4. set predicate 
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name=%@", @"tangxp"]; 
//    [request setPredicate:predicate];
    
    [sharedDB retriveObject:request success:^(NSArray *array) {
        if ([array count] > 0) {
            for (NSManagedObject *object in array) 
            {
                
                Actor *actor = (Actor *)object;
                NSLog(@"name=%@", actor.name);
            }
            
        }
    } failed:^(NSError *err) {
        NSLog(@"retrive error = %@", [err localizedDescription]);
    }];
}

- (IBAction)insertTest:(id)sender
{
    DBManager *sharedDB = [DBManager shareInstance];
    [sharedDB insertObject:^(NSManagedObject *object) {
        NSLog(@"will insert");
        Actor *actor = (Actor*)object;
        actor.name = [[NSDate date] description];
        actor.rating = [NSNumber numberWithInt:arc4random()];
    } entityName:@"Actor" success:^{
        NSLog(@"success insert");
    } failed:^(NSError *err) {
        NSLog(@"error= %@", [err localizedDescription]);
    }];
}

- (IBAction)deleteTest:(id)sender
{
    DBManager *sharedDB = [DBManager shareInstance];
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    NSManagedObjectContext *moContext = [sharedDB managedObjectContext];
    
    //1. set the entity
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Actor" inManagedObjectContext:moContext];
    [request setEntity:entity];
    
    //2. set the sort
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortDescriptors = [[NSMutableArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    [sortDescriptor release];
	[sortDescriptors release];
    
    
    [sharedDB deleteObject:request success:^{
        NSLog(@"delete successfull");
    } failed:^(NSError *err) {
        NSLog(@"error= %@", [err localizedDescription]);
    }];
}

@end
