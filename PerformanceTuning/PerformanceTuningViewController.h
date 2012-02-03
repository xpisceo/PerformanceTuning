//
//  PerformanceTuningViewController.h
//  PerformanceTuning
//
//  Created by Tang Xiaoping on 7/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PerformanceTuningViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate> {
    IBOutlet UILabel *startTime; 
	IBOutlet UILabel *stopTime; 
	IBOutlet UILabel *elapsedTime; 
	IBOutlet UITextView *results; 
	IBOutlet UIPickerView *testPicker;
	NSArray *tests;
}
@property (nonatomic, retain) UILabel *startTime; 
@property (nonatomic, retain) UILabel *stopTime; 
@property (nonatomic, retain) UILabel *elapsedTime; 
@property (nonatomic, retain) UITextView *results; 
@property (nonatomic, retain) UIPickerView *testPicker;
@property (nonatomic, retain) NSArray *tests;

- (IBAction)runTest:(id)sender;
- (IBAction)retriveTest:(id)sender;
- (IBAction)insertTest:(id)sender;
- (IBAction)deleteTest:(id)sender;
@end
