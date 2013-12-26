//
//  ScorekeeperCell.m
//  Scorekeeper (No Sport)
//
//  Created by Ali ElSayed on 9/26/13.
//  Copyright (c) 2013 Aperture Mobile. All rights reserved.
//

#import "ScorekeeperCell.h"

#import <objc/runtime.h>

@implementation ScorekeeperCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        // Initialization code
        CGFloat height = 30.0; // Height of UI elements in cell
        _nameField = [[UITextField alloc] initWithFrame:CGRectMake(20,
                                                                   (self.frame.size.height - height) / 2.0,
                                                                   156,
                                                                   height)];
        _nameField.borderStyle = UITextBorderStyleNone;
        _nameField.placeholder = @"Player Name";
        _nameField.textAlignment = NSTextAlignmentCenter;
        _nameField.spellCheckingType = UITextSpellCheckingTypeNo;
        _nameField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        _nameField.keyboardAppearance = UIKeyboardAppearanceDark;
        _nameField.keyboardType = UIKeyboardTypeDefault;
        _nameField.returnKeyType = UIReturnKeyDone;
        _nameField.font = [UIFont fontWithName:@"HelveticaNeue" size:20.0];
        _nameField.minimumFontSize = 15.0;
        _nameField.delegate = self;
        _nameField.adjustsFontSizeToFitWidth = YES;
        _nameField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [self addSubview:_nameField];
        
        _scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(184,
                                                                (self.frame.size.height - height) / 2.0,
                                                                40,
                                                                height)];
        _scoreLabel.textAlignment = NSTextAlignmentCenter;
        _scoreLabel.text = @"0";
        _scoreLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:24.0];
        _scoreLabel.minimumScaleFactor = 0.5;
        _scoreLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:_scoreLabel];
        
        _decrementButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _decrementButton.frame = CGRectMake(232, (self.frame.size.height - height) / 2.0, 40, height);
        _decrementButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:45.0];
        [_decrementButton setTitle:@"⊖" forState:UIControlStateNormal];
        [_decrementButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_decrementButton setTitleColor:[UIColor colorWithRed:128/255.0 green:0 blue:0 alpha:1.0] forState:UIControlStateHighlighted];
        [_decrementButton setTitleColor:[UIColor colorWithRed:128/255.0 green:0 blue:0 alpha:1.0] forState:UIControlStateSelected];
        [_decrementButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
        [_decrementButton addTarget:self action:@selector(decrementButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
        longPressDecrement = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressDecrementHandler:)];
        longPressDecrement.minimumPressDuration = 0.4;
        [_decrementButton addGestureRecognizer:longPressDecrement];
        [self addSubview:_decrementButton];
        
        _incrementButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _incrementButton.frame = CGRectMake(280, (self.frame.size.height - height) / 2.0, 40, height);
        _incrementButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:45.0];
        [_incrementButton setTitle:@"⊕" forState:UIControlStateNormal];
        [_incrementButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        [_incrementButton setTitleColor:[UIColor colorWithRed:0 green:128/255.0 blue:0 alpha:1.0] forState:UIControlStateHighlighted];
        [_incrementButton setTitleColor:[UIColor colorWithRed:0 green:128/255.0 blue:0 alpha:1.0] forState:UIControlStateSelected];
        [_incrementButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
        [_incrementButton addTarget:self action:@selector(incrementButtonHander:) forControlEvents:UIControlEventTouchUpInside];
        longPressIncrement = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressIncrementHandler:)];
        longPressIncrement.minimumPressDuration = 0.4;
        [_incrementButton addGestureRecognizer:longPressIncrement];
        [self addSubview:_incrementButton];
    }
    return self;
}

- (void) longPressDecrementHandler: (UILongPressGestureRecognizer*) longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        [_decrementButton setSelected:YES];
        timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                 target:self
                                               selector:@selector(decrementButtonHandler:)
                                               userInfo:nil
                                                repeats:YES];
    }
    else if(longPress.state == UIGestureRecognizerStateCancelled  ||
            longPress.state == UIGestureRecognizerStateFailed ||
            longPress.state == UIGestureRecognizerStateEnded)
    {
        [_decrementButton setSelected:NO];
        [timer invalidate];
        timer = nil;
    }
}

- (void) longPressIncrementHandler: (UILongPressGestureRecognizer*) longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        [_incrementButton setSelected:YES];
        timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                 target:self
                                               selector:@selector(incrementButtonHander:)
                                               userInfo:nil
                                                repeats:YES];
    }
    else if(longPress.state == UIGestureRecognizerStateCancelled ||
            longPress.state == UIGestureRecognizerStateFailed ||
            longPress.state == UIGestureRecognizerStateEnded)
    {
        [_incrementButton setSelected:NO];
        [timer invalidate];
        timer = nil;
    }
}


- (void) setNeedsLayout
{
    _nameField.frame = CGRectMake(15, (self.frame.size.height - 30) / 2.0, 145, 30);
    _scoreLabel.frame = CGRectMake(168, (self.frame.size.height - 30) / 2.0, 40, 30);
    _decrementButton.frame = CGRectMake(227, (self.frame.size.height - 40) / 2.0, 40, 40);
    _incrementButton.frame = CGRectMake(275, (self.frame.size.height - 40) / 2.0, 40, 40);
}

- (void) setPlayer:(Player *)player
{
    _player = player;
    _nameField.text = player.name;
    _scoreLabel.text = [NSString stringWithFormat:@"%d", _player.score];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) decrementButtonHandler: (UIButton*) button
{
    _player.score =  [_scoreLabel.text integerValue] - 1;
    _scoreLabel.text = [NSString stringWithFormat:@"%d", _player.score];
}

- (void) incrementButtonHander: (UIButton*) button
{
    _player.score = [_scoreLabel.text integerValue] + 1;
    _scoreLabel.text = [NSString stringWithFormat:@"%d", _player.score];
}


- (void) setViewsEnabled: (BOOL) enabled
{
    _nameField.enabled = enabled;
    _scoreLabel.enabled = enabled;
    _decrementButton.enabled = enabled;
    _incrementButton.enabled = enabled;
}

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    _decrementButton.enabled = NO;
    _incrementButton.enabled = NO;
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    _incrementButton.enabled = YES;
    _decrementButton.enabled = YES;
    _player.name = [textField text];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}


@end
