//
//  QuestionView.m
//  TriviaOutlineView
//
//  Created by Nur Monson on 1/23/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "QuestionView.h"


@implementation QuestionView

- (id)initWithFrame:(NSRect)frame
{
    if( (self = [super initWithFrame:frame]) ) {
		theQuestion = @"";
		theQuestionController = nil;
		theKVOKeyPath = nil;
		theKVOOptions = nil;
		
		NSRect bounds = [self bounds];
		
		theMovieView = [[MovieDragView alloc] initWithFrame:bounds];
		[theMovieView setDraggingDelegate:self];
		[theMovieView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
		[theMovieView setControllerVisible:YES];
		[theMovieView setPreservesAspectRatio:YES];
		
		theImageView = [[ImageDragView alloc] initWithFrame:bounds];
		[theImageView setDraggingDelegate:self];
		[theImageView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
		[theImageView setImageFrameStyle:NSImageFrameGroove];
		
		TextDragView *aTextView = [[TextDragView alloc] initWithFrame:bounds];
		[aTextView setDraggingDelegate:self];
		[aTextView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
		[aTextView setRichText:NO];
		[aTextView setString:theQuestion];
		[aTextView setDelegate:self];
		
#ifdef MULTIMEDIA_QUESTIONS
		[theMovieView registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
		[theImageView registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
		[aTextView registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
#endif
		
		theTextScrollView = [[NSScrollView alloc] initWithFrame:bounds];
		[theTextScrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
		[theTextScrollView setDocumentView:aTextView];
		[aTextView release];
		[theTextScrollView setHasHorizontalScroller:NO];
		[theTextScrollView setHasVerticalScroller:YES];
		[theTextScrollView setBorderType:NSBezelBorder];
		
		theCurrentView = theTextScrollView;
		
		[self addSubview:theCurrentView];
    }

    return self;
}

- (void)dealloc
{
	[theMovieView release];
	[theImageView release];
	[theTextScrollView release];
	
	[theQuestion release];

	[super dealloc];
}

- (void)awakeFromNib
{
	[theTextButton setHidden:YES];
	[theSlowRevealButton setHidden:YES];
}

- (void)updateViewForQuestion
{
	NSView *newView = nil;
	
	if( [theQuestion isKindOfClass:[NSString class]] ) {
		newView = theTextScrollView;
		//if( theCurrentView != newView )
		//[[theTextScrollView documentView] setString:(NSString *)theQuestion];
	} else if( [theQuestion isKindOfClass:[NSImage class]] ) {
		newView = theImageView;
		[theImageView setImage:(NSImage *)theQuestion];
	} else if( [theQuestion isKindOfClass:[QTMovie class]] ) {
		newView = theMovieView;
		[theMovieView setMovie:(QTMovie *)theQuestion];
	}
	
	if( newView == nil || newView == theCurrentView )
		return;
	
	NSRect oldBounds = [theCurrentView bounds];
	[self replaceSubview:theCurrentView with:newView];
	[newView setFrame:oldBounds];
	
	if( newView == theTextScrollView ) {
		[theTextButton setHidden:YES];
		[theSlowRevealButton setHidden:YES];
	} else if( newView == theImageView ) {
		[theTextButton setHidden:NO];
		[theSlowRevealButton setHidden:NO];
	} else {
		[theTextButton setHidden:NO];
		[theSlowRevealButton setHidden:YES];
	}
	
	theCurrentView = newView;
}

- (void)drawRect:(NSRect)rect
{
	//draw a black background
	NSRect bounds = [self bounds];
	NSColor *backgroundColor = [NSColor blackColor];
	[backgroundColor set];
	NSRectFill(bounds);
}

#pragma mark Accessor Methods

- (id)question
{
	return theQuestion;
}
- (void)setQuestion:(id)newQuestion
{
	if( newQuestion == theQuestion )
		return;
	
	[theQuestion release];
	theQuestion = [newQuestion retain];

	[self updateViewForQuestion];
}

#pragma mark Text Methods

// when the question is text then we bind to it directly so we
// have no need of this function.
/*
- (void)textDidChange:(NSNotification *)aNotification
{
	NSText *textObject = [aNotification object];
	
	if( theQuestionController != nil )
		[theQuestionController setValue:[NSString stringWithString:[textObject string]] forKeyPath:@"selection.question"];
	else
		[self setQuestion:[textObject string]];
}
*/
#pragma mark Action Methods

- (IBAction)revertToText:(id)sender
{
	if( theCurrentView == theTextScrollView )
		return;
	
	if( theQuestionController != nil )
		[theQuestionController setValue:@"" forKeyPath:@"selection.question"];
	else
		[self setQuestion:@""];
}

#pragma mark Drag and Drop

#ifdef MULTIMEDIA_QUESTIONS

- (NSView *)viewForType:(NSPasteboard *)aPasteboard
{
	if( aPasteboard == nil )
		return NO;
	
	NSArray *types = [NSArray arrayWithObject:NSFilenamesPboardType];
	NSString *desiredType = [aPasteboard availableTypeFromArray:types];
	if( desiredType == nil ) {
		if( theCurrentView == theTextScrollView )
			return theTextScrollView;
		return nil;
	}
	
	NSArray *filenames = [aPasteboard  propertyListForType:NSFilenamesPboardType];
	NSString *aFilename = [filenames objectAtIndex:0];
	
	// check the image view first because QTMovie can load pictures as well but
	// NSMovieView is not a good at displaying them.
	NSString *extension = [aFilename pathExtension];
	unsigned result = [[NSImage imageFileTypes] indexOfObject:extension];
	if( result != NSNotFound )
		return theImageView;
	
	result = [[QTMovie movieFileTypes:QTIncludeAggressiveTypes] indexOfObject:extension];
	if( result != NSNotFound )
		return theMovieView;
	
	return nil;
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
	NSView *aView = [self viewForType:[sender draggingPasteboard]];
	if( aView == theMovieView || aView == theImageView )
		return NSDragOperationCopy;
	
	return NSDragOperationNone;
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{
	return [self draggingEntered:sender];
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
	if( [self draggingEntered:sender] == NSDragOperationCopy )
		return YES;
	
	return NO;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	NSView *aView = [self viewForType:[sender draggingPasteboard]];
	id newQuestion = nil;
	
	if( aView == theMovieView ) {
		newQuestion = [[TIPMovie alloc] initWithPasteboard:[sender draggingPasteboard] error:nil];
	} else if( aView == theImageView ) {
		newQuestion = [[TIPImage alloc] initWithPasteboard:[sender draggingPasteboard]];
	}
	
	if( newQuestion == nil )
		return NO;

	if( theQuestionController != nil ) {
		
		// if the new question class is text type and the old was not
		// then we need to just bind directly to the text field.
		if( [newQuestion isKindOfClass:[NSString class]] && ![newQuestion isKindOfClass:[NSString class]] )
			[[theTextScrollView documentView] bind:@"value" toObject:theQuestionController withKeyPath:theKVOKeyPath options:theKVOOptions];
		// if the new question is not text and the old was then we need to unbind
		// from the text box.
		else if( [newQuestion isKindOfClass:[NSString class]] && ![newQuestion isKindOfClass:[NSString class]] )
			[[theTextScrollView documentView] unbind:@"value"];
		
		[theQuestionController setValue:newQuestion forKeyPath:@"selection.question"];
	} else
		[self setQuestion:newQuestion];
	
	[newQuestion release];
	
	return YES;
}

#endif

#pragma mark Binding Methods

- (void)bind:(NSString *)binding toObject:(id)observableController withKeyPath:(NSString *)keyPath options:(NSDictionary *)options
{
	if( [binding isEqualToString:@"question"] ) {
		theQuestionController = observableController;
		if( [theQuestion isKindOfClass:[NSString class]] )
			[[theTextScrollView documentView] bind:@"value" toObject:theQuestionController withKeyPath:keyPath options:options];
		
		if( options != theKVOOptions ) {
			[theKVOOptions release];
			theKVOOptions = [options retain];
		}
		if( keyPath != theKVOKeyPath ) {
			[theKVOKeyPath release];
			theKVOKeyPath = [keyPath retain];
		}
	}

	[super bind:binding toObject:observableController withKeyPath:keyPath options:options];
}

- (void)unbind:(NSString *)binding
{
	if( [binding isEqualToString:@"question"] ) {
		theQuestionController = nil;
		[theKVOKeyPath release];
		theKVOKeyPath = nil;
		[theKVOOptions release];
		theKVOOptions = nil;
		
		if( [theQuestion isKindOfClass:[NSString class]] )
			[[theTextScrollView documentView] unbind:@"value"];
	}
	
	[super unbind:binding];
}

@end
