//
//  ViewController.m
//  Scorekeeper (No Sport)
//
//  Created by Ali ElSayed on 9/26/13.
//  Copyright (c) 2013 Aperture Mobile. All rights reserved.
//

#import "MainViewController.h"

#define SCREEN_WIDTH    [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT   [UIScreen mainScreen].bounds.size.height

#define LIGHT_BLACK_COLOR   [UIColor colorWithRed:22/255.0 green:22/255.0 blue:22/255.0 alpha:1.0]

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.tableView.backgroundColor = [UIColor lightGrayColor];
    self.tableView.separatorColor = [UIColor grayColor];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    players = [[NSMutableArray alloc] init];
    [players addObject:[self createPlayerWithName:@"" withScore:0]];
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                         target:self action:@selector(addPlayer)];
    UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                           target:self action:@selector(share)];
    UIBarButtonItem *reset = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                           target:self action:@selector(resetButtonPressed)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [self setToolbarItems:@[add, space, share, space, reset]];
    timer = [[NSTimer alloc] init];
    
    timerCell = [[TimerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"timerCell"];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(tapGestureHandler:)];
    [timerCell.timeLabel addGestureRecognizer:tapGesture];
    [timerCell.modeButton addTarget:self
                             action:@selector(setModeButtonHandler:)
                   forControlEvents:UIControlEventTouchUpInside];
    [timerCell.startStopButton addTarget:self
                                  action:@selector(onStartStopButtonPressed:)
                        forControlEvents:UIControlEventTouchUpInside];
    [timerCell.resetButton addTarget:self
                              action:@selector(reset)
                    forControlEvents:UIControlEventTouchUpInside];
    timerPickerCell = [[TimerPickerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"timerPickerCell"];
    [timerPickerCell.timerPicker addTarget:self action:@selector(setTimerHandler:) forControlEvents:UIControlEventValueChanged];
    
    timerModeSelected = YES;
    datePickerIsVisible = NO;
    
    timerDidRun = NO;
    stopwatchDidRun = NO;
    
    stopwatchString = @"00:00:00";
    timerString = [self getTimerPickerString];
    
    [self setupTableViewHeader];
    
    UITapGestureRecognizer *dismissKeyboardTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                                action:@selector(dismissKeyboardHandler:)];
    [self.tableView addGestureRecognizer:dismissKeyboardTapGesture];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onViewDidAppear)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void) onViewDidAppear // Called when the view appears and when returned from background
{
    if (players.count == 0) { // If there are no players, add one.
        [self addPlayer];
    }
    else if (players.count == 1) // If there is 1 player with no name. Bring up the keyboard.
    {
        if ([[[players objectAtIndex:0] name] isEqualToString:@""]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
            ScorekeeperCell *cell = (ScorekeeperCell*)[self.tableView cellForRowAtIndexPath:indexPath];
            [cell.nameField becomeFirstResponder];
        }
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self onViewDidAppear];
}

- (void) setTimerHandler: (UIDatePicker*) datePicker
{
    timerCell.timeLabel.text = [self getTimerPickerString];
}

-(void) updateStopwatchLabel:(NSTimer *)timer { // Called every second with a timer
    
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:startDate];
    timeInterval += stopwatchSecondsAlreadyRun; // Add saved interval
    stopwatchString = [self stringValueOfTimeInterval:timeInterval];
    timerCell.timeLabel.text = stopwatchString;
}

- (void) updateTimerLabel // Called every second with a timer
{
    NSTimeInterval elapsedTime = [[NSDate date] timeIntervalSinceDate:startDate];
    
    NSTimeInterval remainingTime = totalCountdownInterval - elapsedTime;
    remainingTime -= timerSecondsAlreadyRun;
    if (remainingTime <= 0.0) {
        [self reset];
        timerCell.timeLabel.textColor = [UIColor whiteColor];
        // Play sound
        [self playSound];
    }
    timerString = [self stringValueOfTimeInterval:remainingTime];
    timerCell.timeLabel.text =  timerString;
}

- (void) stopSound // Stops sound if sound is playing
{
    if (audioPlayer)
    {
        if (audioPlayer.isPlaying) {
            [audioPlayer stop];
        }
    }
}

- (void) playSound // Plays sound. Called when timer ends
{
    NSString *soundPath =[[NSBundle mainBundle] pathForResource:@"timer" ofType:@"wav"];
    NSURL *soundURL;
    if (soundPath) {
        soundURL = [NSURL fileURLWithPath:soundPath];
    } else {
        NSLog(@"Sound path not found. Returning...");
        return;
    }
    NSError *error;
    if (soundURL) {
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:&error];
    } else {
        NSLog(@"Sound url is nil! Returning...");
        return;
    }
    if (audioPlayer) {
        [audioPlayer setNumberOfLoops:6]; // About 30 seconds
        [audioPlayer play];
    } else {
        NSLog(@"Could not alloc audio player. Error %@", error);
    }
}

- (void) startTimer // Called by onStartStopButtonPressed to start/resume the timer
{
    timerDidRun = YES;
    totalCountdownInterval = timerPickerCell.timerPicker.countDownDuration;
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimerLabel) userInfo:nil repeats:YES];
    startDate = [NSDate date];
    [timer fire];
}

- (void) startStopwatch // Called by onStartStopButtonPressed to start/resume the stopwatch
{
    stopwatchDidRun = YES;
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                            target:self
                                          selector:@selector(updateStopwatchLabel:)
                                          userInfo:nil
                                           repeats:YES];
    startDate = [NSDate date];
    [timer fire]; // Force initial fire
}

- (void) stopTimer // Called when start/stop button is pressed (by onStartStopButtonPressed) if timer is running
{
    timerSecondsAlreadyRun += [[NSDate date] timeIntervalSinceDate:startDate];
    [timer invalidate];
    timer = nil;
}

- (void) stopStopwatch // Called when start/stop button is pressed (by onStartStopButtonPressed) if stopwatch is running
{
    stopwatchSecondsAlreadyRun += [[NSDate date] timeIntervalSinceDate:startDate];
    [timer invalidate];
    timer = nil;
}

- (void) onStartStopButtonPressed: (UIButton*) sender // When start button is pressed
{
    if (![sender isSelected]) {
        if (timerModeSelected) {
            [self startTimer];
        } else {
            [self startStopwatch];
        }
        [sender setSelected:YES];
        [sender setTitle:@"resume" forState:UIControlStateNormal];
    } else {
        if (timerModeSelected) {
            [self stopTimer];
        } else {
            [self stopStopwatch];
        }
        [sender setSelected:NO];
    }
    if (timer) {
        [timerCell.modeButton setEnabled:NO];
    } else {
        [timerCell.modeButton setEnabled:YES];
    }
}

- (NSString*) getTimerPickerString
{
    NSTimeInterval timeInterval = timerPickerCell.timerPicker.countDownDuration;
    return [self stringValueOfTimeInterval:timeInterval];
}

- (NSString*) stringValueOfTimeInterval: (NSTimeInterval) timeInterval
{
    NSInteger time = (NSInteger)timeInterval;
    NSInteger seconds = time % 60;
    NSInteger minutes = (time / 60) % 60;
    NSInteger hours = (time / 3600);
    return [NSString stringWithFormat:@"%02i:%02i:%02i", hours, minutes, seconds];
}

- (void) resetTimer // Called by the function reset to reset the timer
{
    timerDidRun = NO; // It's been reset
    if ([timer isValid]) { // End timer
        [timer invalidate];
        timer = nil;
    }
    timerCell.timeLabel.text = timerString = [self getTimerPickerString];
    timerSecondsAlreadyRun = 0;
}

- (void) resetStopwatch // Called by the function reset to reset the stopwatch
{
    stopwatchDidRun = NO;
    if ([timer isValid]) { // End timer
        [timer invalidate];
        timer = nil;
    }
    timerCell.timeLabel.text = stopwatchString = @"00:00:00";
    stopwatchSecondsAlreadyRun = 0;
}

- (void) reset
{
    [self resetTimer];
    [self stopSound];
    [self resetStopwatch];
    timerCell.modeButton.enabled = YES;
    [timerCell.startStopButton setSelected:NO];
    [timerCell.startStopButton setTitle:@"start" forState:UIControlStateNormal];
}

- (void) keyboardDidShow:(id) object // Called when the keyboard shows. If the picker is visible, it hides it.
{
    if (datePickerIsVisible) {
        [self hideDatePicker];
    }
}

// Called to dismiss keyboard if user taps on table view
- (void) dismissKeyboardHandler: (UITapGestureRecognizer*) tapGesture
{
    if (tapGesture.state == UIGestureRecognizerStateEnded) {
        [self endEditing];
    }
}

- (void) endEditing // Called by dismissKeyboardHandler to dismiss the keyboard
{
    [[self view] endEditing:YES];
}

//
- (void) setModeButtonHandler: (UIButton*) button
{
    if (timerModeSelected) {
        [timerCell.modeButton setTitle:@"mode: stopwatch" forState:UIControlStateNormal];
        timerCell.timeLabel.text = stopwatchString;
        timerModeSelected = NO;
        if (stopwatchDidRun) {
            [timerCell.startStopButton setTitle:@"resume" forState:UIControlStateNormal];
        } else {
            [timerCell.startStopButton setTitle:@"start" forState:UIControlStateNormal];
        }
    } else {
        [timerCell.modeButton setTitle:@"mode: timer" forState:UIControlStateNormal];
        timerCell.timeLabel.text = timerString;
        timerModeSelected = YES;
        if (timerDidRun) {
            [timerCell.startStopButton setTitle:@"resume" forState:UIControlStateNormal];
        } else {
            [timerCell.startStopButton setTitle:@"start" forState:UIControlStateNormal];
        }
    }
}


// Sets up the table header for section == 1 (second section)
- (void) setupTableViewHeader
{
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    headerView.backgroundColor = [UIColor grayColor];
    
    UILabel *playerNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 60, 20)];
    [self setupLabel:playerNameLabel withText:@"Players"];
    [headerView addSubview:playerNameLabel];
    
    UILabel *scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(164, 0, 48, 20)];
    [self setupLabel:scoreLabel withText:@"Score"];
    [headerView addSubview:scoreLabel];
}

// Sets up a label with some settings
- (void) setupLabel: (UILabel*) label withText: (NSString*) text
{
    label.text = text;
    label.textColor = [UIColor lightTextColor];
    label.font = [UIFont boldSystemFontOfSize:15.0];
    label.textAlignment = NSTextAlignmentCenter;
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return headerView;
    }
    return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return 20.0;
    }
    return 0.0;
}

- (void) tapGestureHandler: (UITapGestureRecognizer*) tapGesture
{
    if (tapGesture.state == UIGestureRecognizerStateEnded)
    {
        if (!timer.isValid && !timerDidRun)
        {
            if (timerModeSelected)
            {
                if (!datePickerIsVisible)
                {
                    [self endEditing];
                    [self showDatePicker];
                }
                else
                {
                    [self hideDatePicker];
                }
            }
            else
            {
                [self onStartStopButtonPressed:timerCell.startStopButton]; // Start stopwatch if time is tapped
            }
        }
        else if (timer.isValid && !timerModeSelected)
        {
            [self onStartStopButtonPressed:timerCell.startStopButton]; // Pause stopwatch if time label is tapped
        }
    }
}

// Called in tapGestureHandler when the time label in timer mode is tapped.
// It shows a picker by adding its cell to the table view.
- (void) showDatePicker
{
    datePickerIsVisible = YES;
    timerCell.modeButton.enabled = NO;
    timerCell.startStopButton.enabled = NO;
    timerCell.resetButton.enabled = NO;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    [self insertRowAtIndexPath:indexPath];
}

// Called in tapGestureHandler when the time label is tapped and the date picker cell is already shown. It hides it.
- (void) hideDatePicker
{
    datePickerIsVisible = NO;
    timerCell.modeButton.enabled = YES;
    timerCell.startStopButton.enabled = YES;
    timerCell.resetButton.enabled = YES;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    [self deleteRowAtIndexPath:indexPath];
}

// Called when the reset button in the toolbar is pressed.
// We get an alert warning the user that all scores/time will be reset.
- (void) resetButtonPressed
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are You Sure?"
                                                    message:@"Scores, names and time will be reset."
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    [alert show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [players removeAllObjects];
        [self.tableView reloadData];
        [self addPlayer];
        [self reset];
    }
}

// Called when the share button is pressed.
- (void) share
{
    NSString* tag = @"#AEScorekeeper";
    NSArray* data = @[tag];
    UIActivityViewController* activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:data
                                      applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion:^{ }];
}

- (void) addPlayer // Creates an empty/new player and adds it to players array
{
    Player *player = [Player alloc];
    player.name = @"";
    player.score = 0;
    [players addObject:player];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:players.count - 1 inSection:1];
    [self insertRowAtIndexPath:indexPath];
    // Bring up keyboard to enter player name
    ScorekeeperCell *cell = (ScorekeeperCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell.nameField becomeFirstResponder];
}

- (void) insertRowAtIndexPath: (NSIndexPath*) indexPath
{
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation: UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

- (Player*) createPlayerWithName: (NSString*) name withScore: (NSInteger) score
{
    Player *player = [Player alloc];
    player.name = name;
    player.score = score;
    return player;
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) { // Rows in section 1 have text fields which are editable
        return YES;
    }
    return NO;
}

- (void) tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    ScorekeeperCell *cell = (ScorekeeperCell*)[tableView cellForRowAtIndexPath:indexPath];
    [cell setViewsEnabled:YES];
}

- (void) tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    ScorekeeperCell *cell = (ScorekeeperCell*)[tableView cellForRowAtIndexPath:indexPath];
    [cell setViewsEnabled:NO];
}


- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        if (indexPath.section == 1)
        {
            [players removeObjectAtIndex:indexPath.row];
            [self deleteRowAtIndexPath:indexPath];
        }
    }
}

- (void) deleteRowAtIndexPath: (NSIndexPath*) indexPath // Deletes row at given indexPath
{
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        if (datePickerIsVisible)
        {
            return 2; // 2 rows in section 0: timerCell, and the timer picker cell.
        }
        return 1; // 1 row in section 0 which is the timerCell
    }
    return players.count;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 1)
        {
            return 216.0; // The picker cell height
        }
        return 122.0; // Timer cell height
    }
    // 206 is the total number of pixels for all UI elements but the cells
    CGFloat height = [UIScreen mainScreen].bounds.size.height - 206 - players.count * 66;
    CGFloat remainingHeight = SCREEN_HEIGHT - 206;
    
    if (height < 0.0)
    {
        if (remainingHeight/players.count > 44.0)
        {
            return remainingHeight/players.count;
        }
        return 44.0;
    }
    return 66.0;
}

- (UIColor*) getLighterColorThan: (UIColor*) color by: (CGFloat) value
{
    CGFloat r, g, b, a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    return [UIColor colorWithRed:r + value/255.0 green:g + value/255.0 blue:b + value/255.0 alpha:a];
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(ScorekeeperCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        cell.nameField.textColor = [UIColor whiteColor];
        cell.scoreLabel.textColor = [UIColor whiteColor];
    //    cell.backgroundColor = (indexPath.row %2) ? [UIColor colorWithWhite:0.75 alpha:1.0] : [UIColor lightGrayColor];
    }
    //else if(indexPath.section == 0)
    //{
        cell.backgroundColor = [UIColor lightGrayColor];
    //}
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            return timerCell;
        }
        else
        {
            return timerPickerCell;
        }
    }
    else
    {
        return [self scorekeeperCellForRowAtIndexPath:indexPath];
    }
}

- (ScorekeeperCell*) scorekeeperCellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    static NSString *cellIdentifier = @"scorekeeperCell";
    ScorekeeperCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil)
        cell = [[ScorekeeperCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    cell.player = [players objectAtIndex:indexPath.row];
    [cell setViewsEnabled:YES];
    return cell;
}

/*
- (TimerPickerCell*) timerPickerCellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    static NSString *cellIdentifier = @"timerPickerCell";
    TimerPickerCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil)
    {
        NSLog(@"dequeueReusableCellWithIdentifier returned nil!");
        cell = [[TimerPickerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    return cell;
}*/

/*
- (TimerCell*) timerCellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    static NSString *cellIdentifier = @"timerCell";
    TimerCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil)
    {
        NSLog(@"dequeueReusableCellWithIdentifier returned nil!");
        cell = [[TimerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    return cell;
}*/


@end
