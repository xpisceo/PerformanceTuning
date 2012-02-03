//
//  FetchAllMoviesAndActorsWithThreadingTest.h
//  PerformanceTuning
//
//  Created by  on 12-2-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PerformanceTest.h"

@interface FetchAllMoviesAndActorsWithThreadingTest : NSObject<PerformanceTest>
{
    NSDate *start;
    NSDate *stop;
    int a;
}

+ (FetchAllMoviesAndActorsWithThreadingTest *)shareInstance;
+ (void)update:(NSString *)str;

@end
