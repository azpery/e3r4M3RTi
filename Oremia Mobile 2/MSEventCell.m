//
//  MSEventCell.m
//  Example
//
//  Created by Eric Horacek on 2/26/13.
//  Copyright (c) 2015 Eric Horacek. All rights reserved.
//

#import "MSEventCell.h"
#import "OremiaMobile2-Swift.h"



@interface MSEventCell ()

@property (nonatomic, strong) UIView *borderView;

@end

@implementation MSEventCell

#pragma mark - UIView

- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        self.layer.shouldRasterize = YES;
        
        self.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.layer.shadowOffset = CGSizeMake(0.0, 4.0);
        self.layer.shadowRadius = 5.0;
        self.layer.shadowOpacity = 0.0;
        self.layer.borderWidth = 1;
        
        self.borderView = [UIView new];
        [self.contentView addSubview:self.borderView];
        
        self.title = [UILabel new];
        self.title.numberOfLines = 0;
        self.title.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.title];
        
        self.statut = [[UIView alloc] initWithFrame:CGRectMake(3,3,14,14)];
        self.statut.translatesAutoresizingMaskIntoConstraints = NO;
        //self.statut.backgroundColor = [UIColor colorWithHexString:@"2C3E50"];
        self.statut.layer.cornerRadius = 7;
        [self.contentView addSubview:self.statut];
        
        self.location = [UILabel new];
        self.location.numberOfLines = 0;
        self.location.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.location];
        
        [self updateColors];
        
        CGFloat borderHeight = 2.0;
        CGFloat contentMargin = 2.0;
        UIEdgeInsets contentPadding = UIEdgeInsetsMake(1.0, (borderHeight + 4.0), 1.0, 4.0);
        
        [self.borderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(borderHeight));
            make.width.equalTo(self.mas_width);
            make.bottom.equalTo(self.mas_bottom);
            make.left.equalTo(self.mas_left);
        }];
        
        [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top).offset(contentPadding.top);
            make.left.equalTo(self.mas_left).offset(contentPadding.left + 15);
            make.right.equalTo(self.mas_right).offset(contentPadding.right);
        }];
        
//        [self.statut mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self.mas_top).offset(contentPadding.top);
//            make.left.equalTo(self.mas_left).offset(contentPadding.left);
//            make.right.equalTo(self.mas_right).offset(contentPadding.right);
//        }];
        
        [self.location mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.title.mas_bottom).offset(contentMargin);
            make.left.equalTo(self.mas_left).offset(contentPadding.left);
            make.right.equalTo(self.mas_right).offset(-contentPadding.right);
            make.bottom.lessThanOrEqualTo(self.mas_bottom).offset(-contentPadding.bottom);
        }];

    }
    
    return self;
}

#pragma mark - UICollectionViewCell

- (void)setSelected:(BOOL)selected
{
    if (selected && (self.selected != selected)) {
        [UIView animateWithDuration:0.1 animations:^{
            self.transform = CGAffineTransformMakeScale(1.025, 1.025);
            self.layer.shadowOpacity = 0.2;
            self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self.collectionView action:@selector(showEditEventFromEvent:)];
            _tapGesture.numberOfTapsRequired = 1;
            [self addGestureRecognizer:_tapGesture];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                self.transform = CGAffineTransformIdentity;
            }completion:^(BOOL finished) {
                [self.collectionView showEditEvent:self];
            }];
        }];
    } else if (selected) {
        self.layer.shadowOpacity = 0.2;
    } else {
        self.layer.shadowOpacity = 0.0;
        [self removeGestureRecognizer:self.tapGesture];
    }
    [super setSelected:selected]; // Must be here for animation to fire
    [self updateColors];
    
    
    
    
}

#pragma mark - MSEventCell

- (void)setEvent:(EKEvent *)event
{
    NSDateFormatter *date = [[NSDateFormatter alloc ] init];
    date.dateFormat = @"HH:mm";
    _event = event;
    self.calendarColor = [UIColor colorWithCGColor:_event.calendar.CGColor];
    NSString *title = @"Pas de titre";
    if (event.title != nil) title = event.title ;
    self.title.attributedText = [[NSAttributedString alloc] initWithString:title attributes:[self titleAttributesHighlighted:self.selected]];
    NSString *dateDebFin = [NSString stringWithFormat:@"%@ - %@",[date stringFromDate:event.startDate], [date stringFromDate:event.endDate]];
    self.location.attributedText = [[NSAttributedString alloc] initWithString:dateDebFin attributes:[self subtitleAttributesHighlighted:self.selected]];
    [self updateColors];
    self.evenement = [[Evennement alloc] initWithEvent:self.event statut:self.statut cell:self eventManager:self.eventManager];
    CGFloat height = self.bounds.size.height;
    if(height >= 50){
        self.location.hidden = false;
    }else{
        self.location.hidden = true;
    }
//    [self.evenement updateStatut];
}

- (void)updateColors
{
    self.contentView.backgroundColor = [self backgroundColorHighlighted:self.selected];
    self.borderView.backgroundColor = [self borderColor];
    self.layer.borderColor = (__bridge CGColorRef _Nullable)(self.calendarColor);
    self.title.textColor = [self textColorHighlighted:self.selected];
    self.location.textColor = [self textColorHighlighted:self.selected];
    
}
-(void)updateLocation:(NSString*)text{
    if (![text  isEqual: @""]) {
            NSString *dateDebFin = [NSString stringWithFormat:@"%@ : %@",text, self.location.text];
            self.location.attributedText = [[NSAttributedString alloc] initWithString:dateDebFin attributes:[self subtitleAttributesHighlighted:self.selected]];
        
    }
}

- (NSDictionary *)titleAttributesHighlighted:(BOOL)highlighted
{
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.hyphenationFactor = 1.0;
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    return @{
        NSFontAttributeName : [UIFont boldSystemFontOfSize:12.0],
        NSForegroundColorAttributeName : [self textColorHighlighted:highlighted],
        NSParagraphStyleAttributeName : paragraphStyle
    };
}

- (NSDictionary *)subtitleAttributesHighlighted:(BOOL)highlighted
{
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.hyphenationFactor = 1.0;
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    return @{
        NSFontAttributeName : [UIFont systemFontOfSize:12.0],
        NSForegroundColorAttributeName : [self textColorHighlighted:highlighted],
        NSParagraphStyleAttributeName : paragraphStyle
    };
}

- (UIColor *)backgroundColorHighlighted:(BOOL)selected
{
    
    return selected ? self.calendarColor : [self.calendarColor colorWithAlphaComponent:0.3];
}

- (UIColor *)textColorHighlighted:(BOOL)selected
{
    
    return selected ? [UIColor whiteColor] : [UIColor colorWithHexString:@"22313F"];
}

- (UIColor *)borderColor
{
    return [[self backgroundColorHighlighted:NO] colorWithAlphaComponent:1.0];
}

@end
