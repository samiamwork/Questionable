//
//  QuestionView.h
//  TriviaOutlineView
//
//  Created by Nur Monson on 1/23/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MovieDragView.h"
#import "ImageDragView.h"
#import "TextDragView.h"

#import "TIPMovie.h"
#import "TIPImage.h"

@interface QuestionView : NSView<NSTextViewDelegate> {
	MovieDragView *theMovieView;
	NSScrollView *theTextScrollView;
	ImageDragView *theImageView;
	
	id theQuestion;
	NSView *theCurrentView;
	
	IBOutlet NSButton *theTextButton;
	IBOutlet NSButton *theSlowRevealButton;
	
	NSObjectController *theQuestionController;
	NSString *theKVOKeyPath;
	NSDictionary *theKVOOptions;
}

- (id)question;
- (void)setQuestion:(id)newQuestion;

- (IBAction)revertToText:(id)sender;
@end
