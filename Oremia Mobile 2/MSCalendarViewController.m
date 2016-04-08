//
//  MSCalendarViewController.m
//  Example
//
//  Created by Eric Horacek on 2/26/13.
//  Copyright (c) 2015 Eric Horacek. All rights reserved.
//

#import "MSCalendarViewController.h"
#import "MSCollectionViewCalendarLayout.h"
// Collection View Reusable Views
#import "MSGridline.h"
#import "MSTimeRowHeaderBackground.h"
#import "MSDayColumnHeaderBackground.h"
#import "MSEventCell.h"
#import "MSDayColumnHeader.h"
#import "MSTimeRowHeader.h"
#import "MSCurrentTimeIndicator.h"
#import "MSCurrentTimeGridline.h"
#import "OremiaMobile2-Swift.h"
#import "SWRevealViewController.h"
#import "NSString+FontAwesome.h"
#import <EventKit/EventKit.h>



NSString * const MSEventCellReuseIdentifier = @"MSEventCellReuseIdentifier";
NSString * const MSDayColumnHeaderReuseIdentifier = @"MSDayColumnHeaderReuseIdentifier";
NSString * const MSTimeRowHeaderReuseIdentifier = @"MSTimeRowHeaderReuseIdentifier";
CGPoint _lastContentOffset;
UIStoryboard *mainStoryboard ;
UINavigationController *controller ;
NewEventTableViewController *destinationView ;
UIPopoverPresentationController *popover;

@interface MSCalendarViewController () <MSCollectionViewDelegateCalendarLayout>
{
    Class<APIControllerProtocol> _apiProtocole;
}

@property (strong) NSTimer *handlerTimer;
@property (strong, nonatomic) EKEventStore *eventStore;
@property (nonatomic, strong) MSCollectionViewCalendarLayout *collectionViewCalendarLayout;
@property (nonatomic, strong) EventManager *fetchedResultsController;
@property (nonatomic, readonly) CGFloat layoutSectionWidth;
@property (nonatomic, strong) NSArray *uniqueEventsArray;
@property (nonatomic, retain) NSDate * curDate;
@property (nonatomic, retain) NSDateFormatter * formatter;

@end

@implementation MSCalendarViewController

- (id)init
{
    self.eventStore = [[EKEventStore alloc] init];

    self.collectionViewCalendarLayout = [[MSCollectionViewCalendarLayout alloc] init];
    self.collectionViewCalendarLayout.delegate = self;
    self = [super initWithCollectionViewLayout:self.collectionViewCalendarLayout];
    [NSTimer scheduledTimerWithTimeInterval:3 target:self.eventStore
                                   selector:@selector(refreshSourcesIfNecessary) userInfo:nil repeats:YES];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (granted) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventStoreChangedNotification:) name:EKEventStoreChangedNotification object:nil];
        }
    }];
   
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    [self.collectionView registerClass:MSEventCell.class forCellWithReuseIdentifier:MSEventCellReuseIdentifier];
    [self.collectionView registerClass:MSDayColumnHeader.class forSupplementaryViewOfKind:MSCollectionElementKindDayColumnHeader withReuseIdentifier:MSDayColumnHeaderReuseIdentifier];
    [self.collectionView registerClass:MSTimeRowHeader.class forSupplementaryViewOfKind:MSCollectionElementKindTimeRowHeader withReuseIdentifier:MSTimeRowHeaderReuseIdentifier];
    
    
    // These are optional. If you don't want any of the decoration views, just don't register a class for them.
    [self.collectionViewCalendarLayout registerClass:MSCurrentTimeIndicator.class forDecorationViewOfKind:MSCollectionElementKindCurrentTimeIndicator];
    [self.collectionViewCalendarLayout registerClass:MSCurrentTimeGridline.class forDecorationViewOfKind:MSCollectionElementKindCurrentTimeHorizontalGridline];
    [self.collectionViewCalendarLayout registerClass:MSGridline.class forDecorationViewOfKind:MSCollectionElementKindVerticalGridline];
    [self.collectionViewCalendarLayout registerClass:MSGridline.class forDecorationViewOfKind:MSCollectionElementKindHorizontalGridline];
    [self.collectionViewCalendarLayout registerClass:MSTimeRowHeaderBackground.class forDecorationViewOfKind:MSCollectionElementKindTimeRowHeaderBackground];
    [self.collectionViewCalendarLayout registerClass:MSDayColumnHeaderBackground.class forDecorationViewOfKind:MSCollectionElementKindDayColumnHeaderBackground];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                             style:UIBarButtonSystemItemDone
                                                                            target:self.revealViewController action:@selector(revealToggle:)] ;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                              style:UIBarButtonSystemItemDone
                                                                             target:self action:@selector(showNewEvent)] ;
    //Navigation Items !!
    UIBarButtonItem *tamere= self.navigationItem.leftBarButtonItem;
    UIBarButtonItem *rightButton= self.navigationItem.rightBarButtonItem;
    [tamere setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIFont fontWithName:kFontAwesomeFamilyName size:24], NSFontAttributeName,
                                    [UIColor whiteColor], NSForegroundColorAttributeName,
                                    nil]forState:UIControlStateNormal];
    [rightButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                         [UIFont fontWithName:kFontAwesomeFamilyName size:24], NSFontAttributeName,
                                         [UIColor whiteColor], NSForegroundColorAttributeName,
                                         nil]forState:UIControlStateNormal];
    
    tamere.title = [NSString fontAwesomeIconStringForEnum:FABars];
    tamere.tintColor = [UIColor whiteColor];
    rightButton.title = [NSString fontAwesomeIconStringForEnum:FAPlus];
    rightButton.tintColor = [UIColor whiteColor];
    UIBarButtonItem *buttonCalendarPicker = [[UIBarButtonItem alloc]
                                             initWithTitle:@"Your Button"
                                             style:UIBarButtonItemStylePlain
                                             target:self
                                             action:@selector(showMiniCalendar)];
    [buttonCalendarPicker setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                  [UIFont fontWithName:kFontAwesomeFamilyName size:24], NSFontAttributeName,
                                                  [UIColor whiteColor], NSForegroundColorAttributeName,
                                                  nil]forState:UIControlStateNormal];
    buttonCalendarPicker.title = [NSString fontAwesomeIconStringForEnum:FAcalendarTimesO];
    buttonCalendarPicker.tintColor = [UIColor whiteColor];
    
    UIBarButtonItem *buttonSetting = [[UIBarButtonItem alloc]
                                      initWithTitle:@"Your Button"
                                      style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(showSettings)];
    [buttonSetting setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                           [UIFont fontWithName:kFontAwesomeFamilyName size:24], NSFontAttributeName,
                                           [UIColor whiteColor], NSForegroundColorAttributeName,
                                           nil]forState:UIControlStateNormal];
    buttonSetting.title = [NSString fontAwesomeIconStringForEnum:FACogs];
    buttonSetting.tintColor = [UIColor whiteColor];
    UIBarButtonItem *buttonAuj = [[UIBarButtonItem alloc]
                                      initWithTitle:@"Aujourd'hui"
                                      style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(showToday)];
    buttonSetting.tintColor = [UIColor whiteColor];
    [self.navigationItem setRightBarButtonItems:@[rightButton,buttonCalendarPicker, buttonSetting]];
    [self.navigationItem setLeftBarButtonItems:@[tamere, buttonAuj]];
    //update Early and lastest hours
    APIController *api = [[APIController alloc] initWithDelegate:self];

    NSArray *pref = [api getPref:@"time"];
    if ([pref count] != 0) {
        NSString *begin = pref[0];
        NSString *end = pref[1];
        [self.collectionViewCalendarLayout setBeginHour: begin.intValue];
        [self.collectionViewCalendarLayout setEndHour: end.intValue];
    } else{
        [api addPref:@"time" prefs:@[@"8",@"18"]];
        [self.collectionViewCalendarLayout setBeginHour:8];
        [self.collectionViewCalendarLayout setEndHour:18];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [LoadingOverlay.shared showOverlay:self.collectionView];
    });
    // Divide into sections by the "day" key path
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.fetchedResultsController = [[EventManager alloc]init];
        [self.fetchedResultsController setAgenda:self];
        [self.fetchedResultsController loadCalendars];
        
        mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        controller = [mainStoryboard instantiateViewControllerWithIdentifier:@"newEvent"];
        destinationView = controller.viewControllers.firstObject;
        controller.modalPresentationStyle = UIModalPresentationPopover;
        destinationView.caller = self;
        destinationView.eventManager = self.fetchedResultsController;

        
        if ([EventManager.allEvents count] > 0) {
            self.uniqueEventsArray = [self.fetchedResultsController sortEventsByDay:[EventManager allEvents]];
            [self reloadItMotherFucker];
        } else{
            self.uniqueEventsArray = [self.fetchedResultsController sortEventsByDay:[self.fetchedResultsController getEventsOfSelectedCalendar]];
        }
        // DATA PROCESSING 1
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView.collectionViewLayout invalidateLayout];
            [self.collectionViewCalendarLayout invalidateLayoutCache];
            self.collectionViewCalendarLayout.sectionWidth = self.layoutSectionWidth;
            [self.collectionView reloadData];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionViewCalendarLayout scrollCollectionViewToClosetSectionToCurrentTimeAnimated:NO];
                [LoadingOverlay.shared hideOverlayView];
            });
        });
        
    });
    UIPinchGestureRecognizer *twoFingerPinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(showMiniCalendar)];
    [self.collectionView addGestureRecognizer:twoFingerPinch];
    //[self touchedButton];
    UILongPressGestureRecognizer *tapped = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(addNewCell:)];
    [self.collectionView addGestureRecognizer:tapped];
    UISwipeGestureRecognizer *upGs = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    UISwipeGestureRecognizer *dwGs = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    [upGs setDirection:UISwipeGestureRecognizerDirectionUp];
    [dwGs setDirection:UISwipeGestureRecognizerDirectionDown];
    [super.view addGestureRecognizer:upGs];
    [super.view addGestureRecognizer:dwGs];
    
    
    
    
    
    
}
-(void) iSaidReloadit
{
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    [self setDecoration];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                             style:UIBarButtonSystemItemDone
                                                                            target:self.revealViewController action:@selector(revealToggle:)] ;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                              style:UIBarButtonSystemItemDone
                                                                             target:self action:@selector(showNewEvent)] ;
    //Navigation Items !!
    UIBarButtonItem *tamere= self.navigationItem.leftBarButtonItem;
    UIBarButtonItem *rightButton= self.navigationItem.rightBarButtonItem;
    [tamere setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIFont fontWithName:kFontAwesomeFamilyName size:24], NSFontAttributeName,
                                    [UIColor whiteColor], NSForegroundColorAttributeName,
                                    nil]forState:UIControlStateNormal];
    [rightButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                         [UIFont fontWithName:kFontAwesomeFamilyName size:24], NSFontAttributeName,
                                         [UIColor whiteColor], NSForegroundColorAttributeName,
                                         nil]forState:UIControlStateNormal];
    
    tamere.title = [NSString fontAwesomeIconStringForEnum:FABars];
    tamere.tintColor = [UIColor whiteColor];
    rightButton.title = [NSString fontAwesomeIconStringForEnum:FAPlus];
    rightButton.tintColor = [UIColor whiteColor];
    UIBarButtonItem *buttonCalendarPicker = [[UIBarButtonItem alloc]
                                             initWithTitle:@"Your Button"
                                             style:UIBarButtonItemStylePlain
                                             target:self
                                             action:@selector(showMiniCalendar)];
    [buttonCalendarPicker setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                  [UIFont fontWithName:kFontAwesomeFamilyName size:24], NSFontAttributeName,
                                                  [UIColor whiteColor], NSForegroundColorAttributeName,
                                                  nil]forState:UIControlStateNormal];
    buttonCalendarPicker.title = [NSString fontAwesomeIconStringForEnum:FAcalendarTimesO];
    buttonCalendarPicker.tintColor = [UIColor whiteColor];
    
    UIBarButtonItem *buttonSetting = [[UIBarButtonItem alloc]
                                      initWithTitle:@"Your Button"
                                      style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(showSettings)];
    [buttonSetting setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                           [UIFont fontWithName:kFontAwesomeFamilyName size:24], NSFontAttributeName,
                                           [UIColor whiteColor], NSForegroundColorAttributeName,
                                           nil]forState:UIControlStateNormal];
    buttonSetting.title = [NSString fontAwesomeIconStringForEnum:FACogs];
    buttonSetting.tintColor = [UIColor whiteColor];
    [self.navigationItem setRightBarButtonItems:@[rightButton,buttonCalendarPicker, buttonSetting]];
    
    //update Early and lastest hours
    APIController *api = [[APIController alloc] initWithDelegate:self];
    NSArray *pref = [api getPref:@"time"];
    if ([pref count] != 0) {
        NSString *begin = pref[0];
        NSString *end = pref[1];
        [self.collectionViewCalendarLayout setBeginHour: begin.intValue];
        [self.collectionViewCalendarLayout setEndHour: end.intValue];
    } else{
        [api addPref:@"time" prefs:@[@"8",@"18"]];
        [self.collectionViewCalendarLayout setBeginHour:8];
        [self.collectionViewCalendarLayout setEndHour:18];
    }
    // Divide into sections by the "day" key path
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.fetchedResultsController = [[EventManager alloc]init];
        [self.fetchedResultsController setAgenda:self];
        
        mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        controller = [mainStoryboard instantiateViewControllerWithIdentifier:@"newEvent"];
        destinationView = controller.viewControllers.firstObject;
        controller.modalPresentationStyle = UIModalPresentationPopover;
        destinationView.caller = self;
        destinationView.eventManager = self.fetchedResultsController;

        
        self.uniqueEventsArray = [self.fetchedResultsController sortEventsByDay:[self.fetchedResultsController getEventsOfSelectedCalendar]];
        // DATA PROCESSING 1
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView.collectionViewLayout invalidateLayout];
            [self.collectionViewCalendarLayout invalidateLayoutCache];
            self.collectionViewCalendarLayout.sectionWidth = self.layoutSectionWidth;
            [self.collectionView reloadData];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionViewCalendarLayout scrollCollectionViewToClosetSectionToCurrentTimeAnimated:NO];
            });
        });
        
    });
    UIPinchGestureRecognizer *twoFingerPinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(showMiniCalendar)];
    [self.collectionView addGestureRecognizer:twoFingerPinch];
    //[self touchedButton];
}
-(void)setDecoration{
    [self.collectionView registerClass:MSEventCell.class forCellWithReuseIdentifier:MSEventCellReuseIdentifier];
    [self.collectionView registerClass:MSDayColumnHeader.class forSupplementaryViewOfKind:MSCollectionElementKindDayColumnHeader withReuseIdentifier:MSDayColumnHeaderReuseIdentifier];
    [self.collectionView registerClass:MSTimeRowHeader.class forSupplementaryViewOfKind:MSCollectionElementKindTimeRowHeader withReuseIdentifier:MSTimeRowHeaderReuseIdentifier];
    
    
    // These are optional. If you don't want any of the decoration views, just don't register a class for them.
    [self.collectionViewCalendarLayout registerClass:MSCurrentTimeIndicator.class forDecorationViewOfKind:MSCollectionElementKindCurrentTimeIndicator];
    [self.collectionViewCalendarLayout registerClass:MSCurrentTimeGridline.class forDecorationViewOfKind:MSCollectionElementKindCurrentTimeHorizontalGridline];
    [self.collectionViewCalendarLayout registerClass:MSGridline.class forDecorationViewOfKind:MSCollectionElementKindVerticalGridline];
    [self.collectionViewCalendarLayout registerClass:MSGridline.class forDecorationViewOfKind:MSCollectionElementKindHorizontalGridline];
    [self.collectionViewCalendarLayout registerClass:MSTimeRowHeaderBackground.class forDecorationViewOfKind:MSCollectionElementKindTimeRowHeaderBackground];
    [self.collectionViewCalendarLayout registerClass:MSDayColumnHeaderBackground.class forDecorationViewOfKind:MSCollectionElementKindDayColumnHeaderBackground];
}
- (void)eventStoreChangedNotification:(NSNotification *)notification {
    [self.handlerTimer invalidate];
    self.handlerTimer = [NSTimer timerWithTimeInterval:8.0
                                                target:self
                                              selector:@selector(respond)
                                              userInfo:nil
                                               repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.handlerTimer
                              forMode:NSDefaultRunLoopMode];
    
}
- (void)respond {
    [self.handlerTimer invalidate];
    [self.eventStore refreshSourcesIfNecessary];
    [self.fetchedResultsController loadCalendars];
    NSLog(@"Event store changed");
//    [self reloadItMotherFucker];
}

-(void) reloadItMotherFucker
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.uniqueEventsArray = [self.fetchedResultsController sortEventsByDay:[self.fetchedResultsController getEventsOfSelectedCalendar]];
        // DATA PROCESSING 1
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView.collectionViewLayout invalidateLayout];
            [self.collectionViewCalendarLayout invalidateLayoutCache];
            self.collectionViewCalendarLayout.sectionWidth = self.layoutSectionWidth;
            [self.collectionView reloadData];
            
        });
        
    });
}
-(void)showToday{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionViewCalendarLayout scrollCollectionViewToClosetSectionToCurrentTimeAnimated:NO];
    });
}
-(void)addNewCell:(UILongPressGestureRecognizer *)sender {
    if(sender.state == UIGestureRecognizerStateBegan){
        
        CGPoint touchPoint = [sender locationInView:self.collectionView];
        [sender setEnabled:NO];
        NSDate *date = [self.collectionViewCalendarLayout dateFromOffset:touchPoint];
        CGFloat calendarContentMinX = (self.collectionViewCalendarLayout.timeRowHeaderWidth + self.collectionViewCalendarLayout.contentMargin.left + self.collectionViewCalendarLayout.sectionMargin.left);
        NSInteger closestSectionToCurrentTime = floor((touchPoint.x-calendarContentMinX )/ self.collectionViewCalendarLayout.sectionWidth);
//        NSInteger closestSectionToCurrentTime = [self.collectionViewCalendarLayout closestSectionToCurrentTime:date];
        self.uniqueEventsArray = [self.fetchedResultsController addNewEventToArray:date];
        NSArray *items = self.uniqueEventsArray[closestSectionToCurrentTime ][@"lesDates"];
        int i = 0;
        bool found = false;
        for(EKEvent* evt in items){
            NSDate* evtDate = evt.startDate;
            if ([evtDate compare:date] == NSOrderedSame) {
                break;
            }
            i++;
        }
        NSMutableArray *arrayWithIndexPaths = [NSMutableArray array];
        [arrayWithIndexPaths addObject:[NSIndexPath indexPathForRow:i
                                                          inSection:closestSectionToCurrentTime ]];
        //
        [self.collectionView performBatchUpdates:^{
            
            [self.collectionView insertItemsAtIndexPaths:arrayWithIndexPaths];
            
        } completion:^(BOOL finished){
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self.collectionView reloadData];
            });
        }];

    } else {
        [sender setEnabled:YES];

    }
}

- (void)datePickerDonePressed:(THDatePickerViewController *)picker {
    if ([self.collectionViewCalendarLayout scrollCollectionViewToClosestSection:picker.date andAnimated:NO]) {
        [self dismissSemiModalView];
    } else {
        [ToolBox shakeIt:self.datePicker.view];
    }
}
- (void)datePickerCancelPressed:(THDatePickerViewController *)picker {
    [self dismissSemiModalView];
}
- (void)showNewEvent
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *controller = [storyboard instantiateViewControllerWithIdentifier:@"newEvent"];
    NewEventTableViewController *destinationView = controller.viewControllers.firstObject;
    destinationView.caller = self;
    // set modal presentation style to popover on your view controller
    // must be done before you reference controller.popoverPresentationController
    controller.modalPresentationStyle = UIModalPresentationPopover;
    
    // configure popover style & delegate
    UIPopoverPresentationController *popover =  controller.popoverPresentationController;
    popover.delegate = controller;
    popover.sourceView = self.view;
    popover.sourceRect = [[self.navigationItem.rightBarButtonItems[0] valueForKey:@"view"] frame];
    popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    
    // display the controller in the usual way
    [self presentViewController:controller animated:YES completion:nil];
    
}
- (void)showEditEvent:(MSEventCell*) cell
{
    popover =  controller.popoverPresentationController;
    popover.delegate = controller;
    popover.sourceView = self.collectionView;
    popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    destinationView.eventManager.editEvent = cell.event;
    destinationView.eventManager.internalEvent = cell.evenement;
    popover.sourceRect = cell.frame;
    // display the controller in the usual way
    [self presentViewController:controller animated:YES completion:^{
        [destinationView loadMe];
        
    }];
}
- (void)showSettings
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *controller = [storyboard instantiateViewControllerWithIdentifier:@"settings"];
    CalendarPreferenceTableViewController *destinationView = controller.viewControllers.firstObject;
    destinationView.caller = self;
    // set modal presentation style to popover on your view controller
    // must be done before you reference controller.popoverPresentationController
    controller.modalPresentationStyle = UIModalPresentationPopover;
    
    // configure popover style & delegate
    UIPopoverPresentationController *popover =  controller.popoverPresentationController;
    popover.delegate = controller;
    popover.sourceView = self.view;
    popover.sourceRect = [[self.navigationItem.rightBarButtonItems[2] valueForKey:@"view"] frame];
    popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    
    // display the controller in the usual way
    [self presentViewController:controller animated:YES completion:nil];
    
}
- (void)showMiniCalendar {
    if(!self.datePicker)
        self.datePicker = [THDatePickerViewController datePicker];
    self.datePicker.date = self.curDate;
    self.datePicker.delegate = self;
    [self.datePicker setAllowClearDate:YES];
    [self.datePicker setClearAsToday:YES];
    [self.datePicker setAutoCloseOnSelectDate:YES];
    [self.datePicker setAllowSelectionOfSelectedDate:YES];
    [self.datePicker setDisableYearSwitch:NO];
    [self.datePicker.currentDay setSelected:YES];
    //[self.datePicker setDisableFutureSelection:NO];
    //    [self.datePicker setDateTimeZoneWithName:@"UTC"];
    //[self.datePicker setAutoCloseCancelDelay:5.0];
    [self.datePicker setSelectedBackgroundColor:[ToolBox UIColorFromRGB:0xe5793b]];
    [self.datePicker setCurrentDateColor:[UIColor colorWithRed:242/255.0 green:121/255.0 blue:53/255.0 alpha:1.0]];
    [self.datePicker setCurrentDateColorSelected:[UIColor whiteColor]];
    
    [self.datePicker setDateHasItemsCallback:^BOOL(NSDate *date) {
        int tmp = (arc4random() % 30)+1;
        return (tmp % 5 == 0);
    }];
    //[self.datePicker slideUpInView:self.view withModalColor:[UIColor lightGrayColor]];
    [self presentSemiViewController:self.datePicker withOptions:@{
                                                                  KNSemiModalOptionKeys.pushParentBack    : @(NO),
                                                                  KNSemiModalOptionKeys.animationDuration : @(0.3),
                                                                  KNSemiModalOptionKeys.shadowOpacity     : @(0.3),
                                                                  }];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue destinationViewController] isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *destination = [segue destinationViewController];
        if ([destination.viewControllers.firstObject isKindOfClass:[NewEventTableViewController class]]) {
            NewEventTableViewController *destinationView = destination.viewControllers.firstObject;
            destinationView.caller = self;
        }
        if ([destination.viewControllers.firstObject isKindOfClass:[CalendarPreferenceTableViewController class]]) {
            CalendarPreferenceTableViewController *destinationView = destination.viewControllers.firstObject;
            destinationView.caller = self;
        }
        
    }
    if ([[segue destinationViewController] isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *destination = [segue destinationViewController];
        NewEventTableViewController *destinationView = destination.viewControllers.firstObject;
        destinationView.caller = self;
    }
}

-(void)handleSwipes:(UISwipeGestureRecognizer*)sender {
    if (sender.direction == UISwipeGestureRecognizerDirectionUp || sender.direction == UISwipeGestureRecognizerDirectionDown) {
        self.isScrollingVertical = TRUE;
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _lastContentOffset = scrollView.contentOffset;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y < 0) {
        scrollView.contentOffset = CGPointMake(self.collectionView.contentOffset.x, 0);
    }
    if (scrollView.contentOffset.y > scrollView.frame.size.height + [self.collectionViewCalendarLayout getCellHeight]) {
        scrollView.contentOffset = CGPointMake(self.collectionView.contentOffset.x, scrollView.frame.size.height + [self.collectionViewCalendarLayout getCellHeight]);
    }
    if (self.isScrollingVertical){
        [self.collectionViewCalendarLayout scrollCollectionViewToClosestSectionAfterScroll:self.collectionView.contentOffset andanimated:YES];
    }
    if (ABS(_lastContentOffset.x - scrollView.contentOffset.x) < ABS(_lastContentOffset.y - scrollView.contentOffset.y) ) {
        [self.collectionViewCalendarLayout scrollCollectionViewToClosestSectionAfterScroll:self.collectionView.contentOffset andanimated:NO];
    } else {
        scrollView.contentOffset = CGPointMake(self.collectionView.contentOffset.x, _lastContentOffset.y);

    }
    
}
- (void)scrollViewWillEndDecelerating:(UIScrollView *)scrollView
{
    [self.collectionViewCalendarLayout scrollCollectionViewToClosestSectionAfterScroll:self.collectionView.contentOffset andanimated:YES];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.collectionViewCalendarLayout scrollCollectionViewToClosestSectionAfterScroll:self.collectionView.contentOffset andanimated:YES];
}
-(void)showEditEventFromEvent:(UITapGestureRecognizer*) sender
{
        MSEventCell *cell = (MSEventCell*)sender.view;
        if(sender.state == UIGestureRecognizerStateEnded){
            [self showEditEvent:cell];
        }
}

//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    
//    [self reloadItMotherFucker];
//}

//- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
//{
//    // Ensure that collection view properly rotates between layouts
//    [self.collectionView.collectionViewLayout invalidateLayout];
//    [self.collectionViewCalendarLayout invalidateLayoutCache];
//
//    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
//        self.collectionViewCalendarLayout.sectionWidth = self.layoutSectionWidth;
//
//    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
//        [self.collectionView reloadData];
//    }];
//}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}
//- (void)releaseBarButton
//{
//    if self. != nil {
//        menuButton.target = self.revealViewController()
//        menuButton.action = "revealToggle:"
//        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
//    }
//}

#pragma mark - MSCalendarViewController


- (CGFloat)layoutSectionWidth
{
    // Default to 254 on iPad.
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 190.0;
    }
    
    // Otherwise, on iPhone, fit-to-width.
    CGFloat width = CGRectGetWidth(self.collectionView.bounds);
    CGFloat timeRowHeaderWidth = self.collectionViewCalendarLayout.timeRowHeaderWidth;
    CGFloat rightMargin = self.collectionViewCalendarLayout.contentMargin.right;
    
    return (width - timeRowHeaderWidth - rightMargin);
}

#pragma mark - NSFetchedResultsControllerDelegate


#pragma mark - UICollectionViewDataSource
- (IBAction)unwindToContactTVC:(UIStoryboardSegue *)unwindSegue
{
    [self reloadItMotherFucker];
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.uniqueEventsArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *items = self.uniqueEventsArray[section][@"lesDates"];
    return items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    EKEvent *event = self.uniqueEventsArray[indexPath.section][@"lesDates"][indexPath.row];
    MSEventCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MSEventCellReuseIdentifier forIndexPath:indexPath];
    cell.eventManager = self.fetchedResultsController;
    cell.event = self.uniqueEventsArray[indexPath.section][@"lesDates"][indexPath.row];
    UIColor *calendarColor = [UIColor colorWithCGColor:event.calendar.CGColor];
    cell.calendarColor = calendarColor;
    cell.collectionView = self;
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *view;
    if (kind == MSCollectionElementKindDayColumnHeader) {
        MSDayColumnHeader *dayColumnHeader = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:MSDayColumnHeaderReuseIdentifier forIndexPath:indexPath];
        NSDate *day = [self.collectionViewCalendarLayout dateForDayColumnHeaderAtIndexPath:indexPath];
        NSDate *currentDay = [self currentTimeComponentsForCollectionView:self.collectionView layout:self.collectionViewCalendarLayout];
        
        NSDate *startOfDay = [[NSCalendar currentCalendar] startOfDayForDate:day];
        NSDate *startOfCurrentDay = [[NSCalendar currentCalendar] startOfDayForDate:currentDay];
        
        dayColumnHeader.day = day;
        dayColumnHeader.currentDay = [startOfDay isEqualToDate:startOfCurrentDay];
        
        view = dayColumnHeader;
    } else if (kind == MSCollectionElementKindTimeRowHeader) {
        MSTimeRowHeader *timeRowHeader = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:MSTimeRowHeaderReuseIdentifier forIndexPath:indexPath];
        timeRowHeader.time = [self.collectionViewCalendarLayout dateForTimeRowHeaderAtIndexPath:indexPath];
        view = timeRowHeader;
        
    }
    return view;
}

#pragma mark - MSCollectionViewCalendarLayout

- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewCalendarLayout dayForSection:(NSInteger)section
{
    return  self.uniqueEventsArray[section][@"date"];
}

- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewCalendarLayout startTimeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    EKEvent *event = self.uniqueEventsArray[indexPath.section][@"lesDates"][indexPath.row];
    return  event.startDate;
}

- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewCalendarLayout endTimeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *vretour;
    EKEvent *event = self.uniqueEventsArray[indexPath.section][@"lesDates"][indexPath.row];
    NSTimeInterval timeInterval = [event.startDate timeIntervalSinceDate:event.endDate];
    if(timeInterval == -86399){
        vretour = [event.startDate dateByAddingTimeInterval:(60 * 60)];
    } else {
        vretour = event.endDate;
    }
    return vretour;
}

- (NSDate *)currentTimeComponentsForCollectionView:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewCalendarLayout
{
    return [NSDate date];
}

@end
