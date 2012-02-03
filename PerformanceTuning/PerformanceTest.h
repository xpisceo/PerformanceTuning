//
//  PerformanceTest.h
//  PerformanceTuning
//
//  Created by Tang Xiaoping on 7/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBManager.h"



@protocol PerformanceTest <NSObject>

- (NSString *)name;
- (void)run;
- (void)updateUI:(NSString *)str;
@end
