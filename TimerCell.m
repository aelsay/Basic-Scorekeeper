//
//  TimerCell.m
//  Scorekeeper (No Sport)
//
//  Created by Ali ElSayed on 9/27/13.
//  Copyright (c) 2013 Aperture Mobile. All rights reserved.
//

#import "TimerCell.h"

@implementation TimerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 280, 76)];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.text = @"00:15:00";
        _timeLabel.textColor = [UIColor darkGrayColor];
        _timeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:60.0];
        _timeLabel.userInteractionEnabled = YES;
        [self addSubview:_timeLabel];
        
        _modeButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _modeButton.frame = CGRectMake(20, 84, 120, 30);
        [_modeButton setTitle:@"mode: timer" forState:UIControlStateNormal];
        [_modeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_modeButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
        [self addSubview:_modeButton];
        
        _resetButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _resetButton.frame = CGRectMake(254, 84, 46, 30);
        [_resetButton setTitle:@"reset" forState:UIControlStateNormal];
        [_resetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_resetButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
        [self addSubview:_resetButton];
        
        _startStopButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _startStopButton.frame = CGRectMake(194, 84, 52, 30);
        [_startStopButton setTitle:@"start" forState:UIControlStateNormal];
        [_startStopButton setTitle:@"stop" forState:UIControlStateSelected];
        [_startStopButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_startStopButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
        [self addSubview:_startStopButton];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
