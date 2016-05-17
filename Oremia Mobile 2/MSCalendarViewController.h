//
//  MSCalendarViewController.h
//  Example
//
//  Created by Eric Horacek on 2/26/13.
//  Copyright (c) 2015 Eric Horacek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THDatePickerViewController.h"
#import "UIViewController+KNSemiModal.h"


@class MSEventCell;
@interface MSCalendarViewController : UICollectionViewController

- (void)showEditEvent:(MSEventCell*) cell;
- (IBAction)unwindToContactTVC:(UIStoryboardSegue *)unwindSegue;
-(void) reloadItMotherFucker;
-(void) reloadCalendars;
-(void) iSaidReloadit;
-(void)showEditEventFromEvent:(UITapGestureRecognizer*) sender;
@property (nonatomic, strong) THDatePickerViewController * datePicker;
@property (nonatomic, assign) Boolean *isScrollingVertical;


@end
