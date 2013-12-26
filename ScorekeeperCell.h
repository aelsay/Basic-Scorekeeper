//
//  ScorekeeperCell.h
//  Scorekeeper (No Sport)
//
//  Created by Ali ElSayed on 9/26/13.
//  Copyright (c) 2013 Aperture Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Player.h"

@interface ScorekeeperCell : UITableViewCell <UITextFieldDelegate>
{
    UILongPressGestureRecognizer *longPressIncrement, *longPressDecrement;
    NSTimer *timer;
}
@property (strong, nonatomic) UITextField *nameField;
@property (strong, nonatomic) UILabel *scoreLabel;
@property (strong, nonatomic) UIButton *decrementButton;
@property (strong, nonatomic) UIButton *incrementButton;

@property (strong, nonatomic) Player *player;

- (void) setViewsEnabled: (BOOL) enabled;

@end
