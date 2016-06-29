//
//  MSEventCell.h
//  Example
//
//  Created by Eric Horacek on 2/26/13.
//  Copyright (c) 2015 Eric Horacek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import "Masonry.h"
#import "UIColor+HexString.h"
#import "MSCalendarViewController.h"

@class Evennement;
@class EventManager;
@class MSEvent;

@interface MSEventCell : UICollectionViewCell

-(void)updateLocation:(NSString*)text;
@property (nonatomic, strong) EKEvent *event;
@property (nonatomic, weak) MSCalendarViewController *collectionView;
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UIView *statut;
@property (nonatomic, strong) UILabel *location;
@property (nonatomic, strong) UIColor *calendarColor;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) Evennement *evenement;
@property (nonatomic, strong) EventManager *eventManager;
@end
