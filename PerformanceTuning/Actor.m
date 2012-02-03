//
//  Actor.m
//  PerformanceTuning
//
//  Created by Tang Xiaoping on 7/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Actor.h"


@implementation Actor
@dynamic name;
@dynamic rating;
@dynamic movies;

- (void)addMoviesObject:(NSManagedObject *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"movies" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"movies"] addObject:value];
    [self didChangeValueForKey:@"movies" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeMoviesObject:(NSManagedObject *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"movies" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"movies"] removeObject:value];
    [self didChangeValueForKey:@"movies" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addMovies:(NSSet *)value {    
    [self willChangeValueForKey:@"movies" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"movies"] unionSet:value];
    [self didChangeValueForKey:@"movies" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeMovies:(NSSet *)value {
    [self willChangeValueForKey:@"movies" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"movies"] minusSet:value];
    [self didChangeValueForKey:@"movies" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}

- (void)willTurnIntoFault {
	NSLog(@"Actor named %@ will turn into fault", self.name);
}
- (void)didTurnIntoFault { 
	NSLog(@"Actor named %@ did turn into fault", self.name);
}

@end
