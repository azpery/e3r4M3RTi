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
@property (nonatomic, retain) NSDate *curDate;
@property (nonatomic, retain) NSDate *selectedDate;
@property (nonatomic, retain) NSDateFormatter *formatter;
@property (nonatomic, retain) APIController *api;

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
    [self iSaidReloadit];
    
    
    
}
-(void) iSaidReloadit
{
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.isInitialLoading = true;
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
    UIBarButtonItem *buttonRefresh = [[UIBarButtonItem alloc]
                                      initWithTitle:@"Your Button"
                                      style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(reloadItMotherFucker)];
    [buttonRefresh setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                           [UIFont fontWithName:kFontAwesomeFamilyName size:24], NSFontAttributeName,
                                           [UIColor whiteColor], NSForegroundColorAttributeName,
                                           nil]forState:UIControlStateNormal];
    buttonRefresh.title = [NSString fontAwesomeIconStringForEnum:FARefresh];
    buttonRefresh.tintColor = [UIColor whiteColor];
    UIBarButtonItem *buttonAuj = [[UIBarButtonItem alloc]
                                  initWithTitle:@"Aujourd'hui"
                                  style:UIBarButtonItemStylePlain
                                  target:self
                                  action:@selector(showToday)];
    UIBarButtonItem *buttonLeft = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Your Button"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(showLeft)];
    [buttonLeft setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont fontWithName:kFontAwesomeFamilyName size:24], NSFontAttributeName,
                                        [UIColor whiteColor], NSForegroundColorAttributeName,
                                        nil]forState:UIControlStateNormal];
    buttonLeft.title = [NSString fontAwesomeIconStringForEnum:FAChevronLeft];
    buttonLeft.tintColor = [UIColor whiteColor];
    UIBarButtonItem *buttonRight = [[UIBarButtonItem alloc]
                                    initWithTitle:@"Your Button"
                                    style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(showRight)];
    [buttonRight setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                         [UIFont fontWithName:kFontAwesomeFamilyName size:24], NSFontAttributeName,
                                         [UIColor whiteColor], NSForegroundColorAttributeName,
                                         nil]forState:UIControlStateNormal];
    buttonRight.title = [NSString fontAwesomeIconStringForEnum:FAChevronRight];
    buttonRight.tintColor = [UIColor whiteColor];
    buttonSetting.tintColor = [UIColor whiteColor];
    [self.navigationItem setRightBarButtonItems:@[rightButton,buttonCalendarPicker, buttonSetting, buttonRefresh]];
    [self.navigationItem setLeftBarButtonItems:@[tamere, buttonLeft, buttonAuj, buttonRight]];
    self.api = [[APIController alloc] initWithDelegate:self];
    NSString* time = [NSString stringWithFormat:@"time%i", self.api.getIduser];
    NSArray *pref = [_api getPref:time];
    if ([pref count] != 0) {
        NSString *begin = pref[0];
        NSString *end = pref[1];
        [self.collectionViewCalendarLayout setBeginHour: begin.intValue];
        [self.collectionViewCalendarLayout setEndHour: end.intValue];
    } else{
        
        [_api addPref:time prefs:@[@"8",@"18"]];
        [self.collectionViewCalendarLayout setBeginHour:8];
        [self.collectionViewCalendarLayout setEndHour:18];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [LoadingOverlay.shared showOverlay:self.collectionView];
    });
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
        
        
        self.uniqueEventsArray = [self.fetchedResultsController sortEventsByDay:[self.fetchedResultsController getEventsOfSelectedCalendar]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView.collectionViewLayout invalidateLayout];
            [self.collectionViewCalendarLayout invalidateLayoutCache];
            self.collectionViewCalendarLayout.sectionWidth = self.layoutSectionWidth;
            [self.collectionView reloadData];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionViewCalendarLayout scrollCollectionViewToClosetSectionToCurrentTimeAnimated:NO];
                [LoadingOverlay.shared hideOverlayView];
                self.isInitialLoading = NO;
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
//- (void)eventStoreChangedNotification:(NSNotification *)notification {
//    [self.handlerTimer invalidate];
//    self.handlerTimer = [NSTimer timerWithTimeInterval:8.0
//                                                target:self
//                                              selector:@selector(respond)
//                                              userInfo:nil
//                                               repeats:NO];
//    [[NSRunLoop mainRunLoop] addTimer:self.handlerTimer
//                              forMode:NSDefaultRunLoopMode];
//
//}
//- (void)respond {
//    [self.handlerTimer invalidate];
//    [self.eventStore refreshSourcesIfNecessary];
//    [self.fetchedResultsController loadCalendars];
//    NSLog(@"Event store changed");
////    [self reloadItMotherFucker];
//}

-(void) reloadItMotherFucker
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (self.selectedDate == nil) {
            self.uniqueEventsArray = [self.fetchedResultsController sortEventsByDay:[self.fetchedResultsController getEventsOfSelectedCalendar]];
        } else {
            self.uniqueEventsArray = [self.fetchedResultsController sortEventsByDay:[self.fetchedResultsController getEventsOfSelectedCalendarForCertainDate:self.selectedDate]];
        }
        
        // DATA PROCESSING 1
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView.collectionViewLayout invalidateLayout];
            [self.collectionViewCalendarLayout invalidateLayoutCache];
            self.collectionViewCalendarLayout.sectionWidth = self.layoutSectionWidth;
            [self.collectionView reloadData];
            
        });
        
    });
}

-(void) reloadCalendars
{
    NSMutableArray *cals = [@[@""] mutableCopy];
    for (EKCalendar *cal in [self.fetchedResultsController calendars]) {
        [cals addObject:[cal title]];
    }
    if (self.selectedDate == nil) {
        [self.fetchedResultsController.api getCalDavRessources:nil calendars:cals];
    } else {
        [self.fetchedResultsController.api getCalDavRessources:self.selectedDate calendars:cals];
    }
}

-(void)showToday{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDate *date = [[NSDate alloc] init];
        [self moveToDate:date];
    });
}
-(void)showLeft{
    [self moveTo:-1];
}
-(void)showRight{
    [self moveTo:1];
}
-(void)addNewCell:(UILongPressGestureRecognizer *)sender {
    if(sender.state == UIGestureRecognizerStateBegan){
        
        CGPoint touchPoint = [sender locationInView:self.collectionView];
        [sender setEnabled:NO];
        NSDate *date = [self.collectionViewCalendarLayout dateFromOffset:touchPoint];
        self.uniqueEventsArray = [self.fetchedResultsController addNewEventToArray:date];
        [self reloadItMotherFucker];
    } else {
        [sender setEnabled:YES];
        
    }
}

- (void)datePickerDonePressed:(THDatePickerViewController *)picker {
    
    [self moveToDate:picker.date];
    [self dismissSemiModalView];
}
-(void)moveToDate:(NSDate *)date
{
    if(!self.isLoading){
        self.isLoading = true;
        self.selectedDate = date;
        NSMutableArray *cals = [@[@""] mutableCopy];
        for (EKCalendar *cal in [self.fetchedResultsController calendars]) {
            [cals addObject:[cal title]];
        }
        [self.fetchedResultsController.api getCalDavRessources:date calendars:cals];
        self.uniqueEventsArray = [self.fetchedResultsController sortEventsByDay:[self.fetchedResultsController getEventsOfSelectedCalendarForCertainDate:date]];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView.collectionViewLayout invalidateLayout];
                [self.collectionViewCalendarLayout invalidateLayoutCache];
                self.collectionViewCalendarLayout.sectionWidth = self.layoutSectionWidth;
                [self.collectionView reloadData];
                [self.collectionViewCalendarLayout scrollCollectionViewToClosestSection:date andAnimated:YES];
                self.isLoading = false;
                
            });
            
        });
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
    controller.modalPresentationStyle = UIModalPresentationPopover;
    
    UIPopoverPresentationController *popover =  controller.popoverPresentationController;
    popover.delegate = controller;
    popover.sourceView = self.view;
    popover.sourceRect = [[self.navigationItem.rightBarButtonItems[0] valueForKey:@"view"] frame];
    popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    
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
    destinationView.cell = cell;
    popover.sourceRect = cell.frame;
    [self presentViewController:controller animated:YES completion:^{
//        [destinationView loadMe];
        [destinationView loadEvent];
    }];
}
- (void)showSettings
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *controller = [storyboard instantiateViewControllerWithIdentifier:@"settings"];
    CalendarPreferenceTableViewController *destinationView = controller.viewControllers.firstObject;
    destinationView.caller = self;
    controller.modalPresentationStyle = UIModalPresentationPopover;
    
    UIPopoverPresentationController *popover =  controller.popoverPresentationController;
    popover.delegate = controller;
    popover.sourceView = self.view;
    popover.sourceRect = [[self.navigationItem.rightBarButtonItems[2] valueForKey:@"view"] frame];
    popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    
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
    [self.datePicker setSelectedBackgroundColor:[ToolBox UIColorFromRGB:0xe5793b]];
    [self.datePicker setCurrentDateColor:[UIColor colorWithRed:242/255.0 green:121/255.0 blue:53/255.0 alpha:1.0]];
    [self.datePicker setCurrentDateColorSelected:[UIColor whiteColor]];
    
    [self.datePicker setDateHasItemsCallback:^BOOL(NSDate *date) {
        int tmp = (arc4random() % 30)+1;
        return (tmp % 5 == 0);
    }];
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
    if (!self.isInitialLoading && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (scrollView.contentOffset.y < 0) {
            scrollView.contentOffset = CGPointMake(self.collectionView.contentOffset.x, 0);
        }
        
        if (scrollView.contentOffset.x < 0 + self.collectionViewCalendarLayout.sectionWidth) {
            scrollView.contentOffset = CGPointMake(self.collectionViewCalendarLayout.sectionWidth, self.collectionView.contentOffset.y);
        }
        
        if (self.isScrollingVertical){
            [self.collectionViewCalendarLayout scrollCollectionViewToClosestSectionAfterScroll:self.collectionView.contentOffset andanimated:YES];
        }
        if (ABS(_lastContentOffset.x - scrollView.contentOffset.x) < ABS(_lastContentOffset.y - scrollView.contentOffset.y) ) {
            [self.collectionViewCalendarLayout scrollCollectionViewToClosestSectionAfterScroll:self.collectionView.contentOffset andanimated:NO];
        } else {
            scrollView.contentOffset = CGPointMake(self.collectionView.contentOffset.x, _lastContentOffset.y);
            
        }
    }else{
        self.offsetView = scrollView.contentSize.width - scrollView.frame.size.width;
    }
}

-(void)moveTo:(NSInteger ) coefficient{
    NSDate *now = [NSDate date];
    if (self.selectedDate != nil) {
        now = self.selectedDate;
    }
    NSDate *sevenDaysAfter = [now dateByAddingTimeInterval:7*24*60*60 * coefficient];
    self.selectedDate = sevenDaysAfter;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self moveToDate:sevenDaysAfter];
    });
}

- (void)scrollViewWillEndDecelerating:(UIScrollView *)scrollView
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        [self.collectionViewCalendarLayout scrollCollectionViewToClosestSectionAfterScroll:self.collectionView.contentOffset andanimated:YES];

    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
    [self.collectionViewCalendarLayout scrollCollectionViewToClosestSectionAfterScroll:self.collectionView.contentOffset andanimated:YES];
    }
}
-(void)showEditEventFromEvent:(UITapGestureRecognizer*) sender
{
    MSEventCell *cell = (MSEventCell*)sender.view;
    if(sender.state == UIGestureRecognizerStateEnded){
        [self showEditEvent:cell];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

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
    if(self.uniqueEventsArray.count >= indexPath.section && [self.uniqueEventsArray[indexPath.section][@"lesDates"] count] - 1 >= indexPath.row){
        EKEvent *event = self.uniqueEventsArray[indexPath.section][@"lesDates"][indexPath.row];
        return  event.startDate;
    }
    return [NSDate dateWithTimeIntervalSinceNow:0];
}

- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewCalendarLayout endTimeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *vretour;
    if(self.uniqueEventsArray.count >= indexPath.section && [self.uniqueEventsArray[indexPath.section][@"lesDates"] count] - 1 >= indexPath.row){
        EKEvent *event = self.uniqueEventsArray[indexPath.section][@"lesDates"][indexPath.row];
        NSTimeInterval timeInterval = [event.startDate timeIntervalSinceDate:event.endDate];
        if(timeInterval == -86399){
            vretour = [event.startDate dateByAddingTimeInterval:(60 * 60)];
        } else {
            vretour = event.endDate;
        }
        return vretour;
    }
    return [NSDate dateWithTimeIntervalSinceNow:0];
}

- (NSDate *)currentTimeComponentsForCollectionView:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewCalendarLayout
{
    return [NSDate date];
}

@end
