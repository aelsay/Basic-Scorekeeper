//
//  TimerPickerCell.m
//  Scorekeeper (No Sport)
//
//  Created by Ali ElSayed on 9/27/13.
//  Copyright (c) 2013 Aperture Mobile. All rights reserved.
//

#import "TimerPickerCell.h"

@implementation TimerPickerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _timerPicker = [[UIDatePicker alloc] init];
        [_timerPicker setDatePickerMode:UIDatePickerModeCountDownTimer];
        _timerPicker.countDownDuration = 15 * 60;
        [self addSubview:_timerPicker];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
