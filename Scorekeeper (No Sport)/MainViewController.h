//
//  ViewController.h
//  Scorekeeper (No Sport)
//
//  Created by Ali ElSayed on 9/26/13.
//  Copyright (c) 2013 Aperture Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <AVFoundation/AVFoundation.h>

#import "Player.h"
#import "TimerCell.h"
#import "TimerPickerCell.h"
#import "ScorekeeperCell.h"

@interface MainViewController : UITableViewController <UIAlertViewDelegate, UITextFieldDelegate>
{
    NSMutableArray *players;
    UIView *buttonsView;
    TimerCell *timerCell;
    TimerPickerCell *timerPickerCell;
    NSTimer *timer;
    BOOL timerModeSelected; // If timer mode, yes. If stopwatch mode, no.
    BOOL datePickerIsVisible;
    BOOL stopwatchDidRun, timerDidRun;
    UIView *headerView;
    NSDate *startDate;
    NSTimeInterval timerSecondsAlreadyRun, stopwatchSecondsAlreadyRun;
    NSString *stopwatchString, *timerString;
    NSTimeInterval totalCountdownInterval;
    AVAudioPlayer *audioPlayer;
}

@end
