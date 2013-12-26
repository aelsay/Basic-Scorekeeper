//
//  TimerCell.h
//  Scorekeeper (No Sport)
//
//  Created by Ali ElSayed on 9/27/13.
//  Copyright (c) 2013 Aperture Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
typedef enum {
    Stopwatch,
    Timer
} Mode;*/

@interface TimerCell : UITableViewCell

@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIButton *resetButton;
@property (nonatomic, strong) UIButton *startStopButton;
@property (nonatomic, strong) UIButton *modeButton;

//@property (nonatomic, assign) Mode mode;

@end
