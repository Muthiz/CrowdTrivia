//
//  TriviaBettingiPhoneViewController.m
//  TriviaBettingiPhone
//
//  Created by Hugo Troche on 2/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TriviaBettingiPhoneViewController.h"
#import "PuzzlesViewController.h"
#import "Game.h"
#import "Question.h"

static NSString* kAppId = @"136114726451991";

@implementation TriviaBettingiPhoneViewController

@synthesize facebook;


/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



- (void)viewDidLoad {
    [super viewDidLoad];
	[[NSNotificationCenter defaultCenter] addObserverForName:@"creditsChange" object:nil queue:nil usingBlock:^(NSNotification *arg1) {
		Game *game = [Game getGame];
		creditsLabel.text = [NSString stringWithFormat:@"%d", [game.credits intValue]];
	}];
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	Game *game = [Game getGame];
	if(game.puzzle == nil) {
		[self selectCategoryPressed:nil];
		return;
	}
	if(game.question == nil) {
		NSArray *questions = [game.puzzle.questions allObjects];
		game.question = [questions objectAtIndex:0];
		[game save:nil];
	}
	[self setupQuestion];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (IBAction) selectCategoryPressed:(id) sender {
	//Game *game = [Game getGame];
	//NSError *error;
	//[game save:error];
	PuzzlesViewController *controller = [[PuzzlesViewController alloc] init];
	[self presentModalViewController:controller animated:YES];
	[controller release];
	[timer invalidate];
}

- (IBAction) answer1Pressed:(id) sender {
	Game *game = [Game getGame];
	if([game.question.correctAnswer intValue] == 1) {
		[self correctAnswer];
	} else {
		[self wrongAnswer];
	}
}

- (IBAction) answer2Pressed:(id) sender {
	Game *game = [Game getGame];
	if([game.question.correctAnswer intValue] == 2) {
		[self correctAnswer];
	} else {
		[self wrongAnswer];
	}
}

- (IBAction) answer3Pressed:(id) sender {
	Game *game = [Game getGame];
	if([game.question.correctAnswer intValue] == 3) {
		[self correctAnswer];
	} else {
		[self wrongAnswer];
	}
}

- (IBAction) answer4Pressed:(id) sender {
	Game *game = [Game getGame];
	if([game.question.correctAnswer intValue] == 4) {
		[self correctAnswer];
	} else {
		[self wrongAnswer];
	}
}

- (IBAction) upBetPressed:(id) sender {
	int bet = [betLabel.text intValue];
	Game *game = [Game getGame];
	[game bet:BET_DELTA];
	bet +=  BET_DELTA;
	betLabel.text = [NSString stringWithFormat:@"%d",bet];
	
}

- (IBAction) downBetPressed:(id) sender {
	int bet = [betLabel.text intValue];
	Game *game = [Game getGame];
	[game bet:-1*BET_DELTA];
	bet -=  BET_DELTA;
	betLabel.text = [NSString stringWithFormat:@"%d",bet];
}

- (void) correctAnswer {
	int bet = [betLabel.text intValue];
	Game *game = [Game getGame];
	[game winBet:bet];
	if([game isLastQuestion]) {
		[self selectCategoryPressed:nil];
		[game resetPuzzle];
		return;
	}
	NSLog(@"question index: %@", game.questionIndex);
	[timer invalidate];
	UIActionSheet *laserActionSheet = [[UIActionSheet alloc] initWithTitle:@"Correct Answer" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
    [laserActionSheet addButtonWithTitle:@"Next"];
	[laserActionSheet showInView:self.view];
}

- (void) wrongAnswer {
	Game *game = [Game getGame];
	if([game isLastQuestion]) {
		[self selectCategoryPressed:nil];
		[game resetPuzzle];
		return;
	}
	[timer invalidate];
	NSLog(@"question index: %@", game.questionIndex);
	UIActionSheet *laserActionSheet = [[UIActionSheet alloc] initWithTitle:@"Wrong Answer" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
    [laserActionSheet addButtonWithTitle:@"Next"];
	[laserActionSheet addButtonWithTitle:@"Retry"];
	[laserActionSheet showInView:self.view];
}

- (void) timeOut {
	Game *game = [Game getGame];
	if([game isLastQuestion]) {
		[self selectCategoryPressed:nil];
		[game resetPuzzle];
		return;
	}
	UIActionSheet *laserActionSheet = [[UIActionSheet alloc] initWithTitle:@"Out of Time" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
    [laserActionSheet addButtonWithTitle:@"Next"];
	[laserActionSheet addButtonWithTitle:@"Retry"];
	[laserActionSheet showInView:self.view];
}

- (void) puzzleFinished {
	UIActionSheet *laserActionSheet = [[UIActionSheet alloc] initWithTitle:@"Puzzle Finished!" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
    [laserActionSheet addButtonWithTitle:@"Choose another puzzle"];
	[laserActionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(buttonIndex == 0) {Game *game = [Game getGame];
		betLabel.text = @"100";
		timerLabel.text = @"30";
		[game bet:100];
		timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(downClock:) userInfo:nil repeats:YES];
		[self setupQuestion];
		
	}
	if(buttonIndex == 1) {
		[self resetBoard];
	}
	[actionSheet release];
}

- (void) downClock:(NSTimer *) t {
	int timeLeft = [timerLabel.text intValue];
	timeLeft--;
	timerLabel.text = [NSString stringWithFormat:@"%d", timeLeft];
	if(timeLeft == 0) {
		[timer invalidate];
		[self timeOut];
	}
}

- (void) setupQuestion {	
	Game *game = [Game getGame];
	[game nextQuestion];
	question.text = game.question.question;
	answer1Label.text = game.question.answer1;
	answer2Label.text = game.question.answer2;
	answer3Label.text = game.question.answer3;
	answer4Label.text = game.question.answer4;
	[self resetBoard];
}

- (void) resetBoard {
	Game *game = [Game getGame];
	betLabel.text = @"100";
	timerLabel.text = @"30";
	[game bet:100];
	timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(downClock:) userInfo:nil repeats:YES];
}

- (IBAction) facebookPressed:(id) sender {
	NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
	NSDate *expirationDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"token_expiration"];
	if(self.facebook == nil)
		self.facebook = [[Facebook alloc] initWithAppId:kAppId];
	if(accessToken == nil) {
		NSArray *permissions =  [NSArray arrayWithObjects:
						 @"read_stream", @"offline_access", @"publish_stream", nil];
		[self.facebook authorize:permissions delegate:self];
	} else {
		self.facebook.accessToken = accessToken;
		self.facebook.expirationDate = expirationDate;
		//[self.facebook requestWithGraphPath:@"me" andDelegate:self];
		NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
		NSMutableString *message = [NSMutableString stringWithCapacity:10];
		Game *game = [Game getGame];
		[message appendString:game.question.question];
		[message appendFormat:@"\n  %@", game.question.answer1];
		[message appendFormat:@"\n  %@", game.question.answer2];
		[message appendFormat:@"\n  %@", game.question.answer3];
		[message appendFormat:@"\n  %@", game.question.answer4];
		[params setObject:message forKey:@"message"];
		[params setObject:@"www.triviabetting.com" forKey:@"link"];
		[params setObject:@"Help me with this question!" forKey:@"description"];
		[params setObject:@"name" forKey:@"name"];
		[self.facebook requestWithGraphPath:@"me/feed" andParams:params andHttpMethod:@"POST" andDelegate:self];
	}
}

- (void)fbDidLogin {
	[[NSUserDefaults standardUserDefaults] setObject:self.facebook.accessToken forKey:@"access_token"];
	[[NSUserDefaults standardUserDefaults] setObject:self.facebook.expirationDate forKey:@"token_expiration"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
}

- (void)fbDidNotLogin:(BOOL)cancelled {
}


- (void)fbDidLogout {
}

- (void)fbDialogLogin:(NSString*)token expirationDate:(NSDate*)expirationDate {
	[[NSUserDefaults standardUserDefaults] setObject:token forKey:@"access_token"];
	[[NSUserDefaults standardUserDefaults] setObject:expirationDate forKey:@"token_expiration"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)fbDialogNotLogin:(BOOL)cancelled {
}

- (void)requestLoading:(FBRequest *)request {
}

- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
	NSLog(@"Error: %@", [error description]);
}

- (void)request:(FBRequest *)request didLoad:(id)result {
	if ([result isKindOfClass:[NSArray class]]) {
		result = [result objectAtIndex:0];
	}
	NSLog(@"name: %@ id: %@", [result objectForKey:@"name"], [result objectForKey:@"id"]);
}

- (void)request:(FBRequest *)request didLoadRawResponse:(NSData *)data {
}

- (void)dealloc {
    [super dealloc];
}

@end