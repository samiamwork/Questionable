//
//  TriviaDrawableQA.m
//  TriviaPlayer
//
//  Created by Nur Monson on 10/22/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import "TriviaDrawableQA.h"
#include "TIPCGUtils.h"

@implementation TriviaDrawableQA

- (id)init
{
	if( (self = [super init]) ) {
		titleString = [[NSString alloc] initWithString:@"title"];
		titleContainer = [[TIPTextContainer containerWithString:titleString color:[NSColor colorWithCalibratedWhite:0.8f alpha:1.0f] fontName:@"Impact"] retain];
		[titleContainer setAlignment:kTIPTextAlignmentCenter];
		
		textString = [[NSString alloc] initWithString:@"text"];
		textContainer = [[TIPTextContainer containerWithString:textString color:[NSColor colorWithCalibratedWhite:1.0f alpha:1.0f] fontName:@"HelveticaNeue"] retain];
		[textContainer setAlignment:kTIPTextAlignmentCenter];
		
		titleBox = NULL;
		textBox = NULL;
		
		blackShine = TIPGradientBlackShineCreate();
		textGradient = TIPMutableGradientCreate();
		TIPGradientAddRGBColorStop(textGradient,0.0f,0.2f,0.2f,0.4f,1.0f);
		TIPGradientAddRGBColorStop(textGradient,1.0f,0.55f,0.55f,0.9f,1.0f);
		
		titleGradient = TIPMutableGradientCreate();
		TIPGradientAddRGBColorStop(titleGradient,0.0f,0.3f,0.3f,0.4f,1.0f);
		TIPGradientAddRGBColorStop(titleGradient,0.0f,0.4f,0.4f,0.5f,1.0f);
	}
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
	
	[titleString release];
	[titleContainer release];
	
	TIPGradientRelease(blackShine);
	TIPGradientRelease(textGradient);
	TIPGradientRelease(titleGradient);
}

#pragma mark Set and Get

- (void)setTitle:(NSString *)newTitle
{
	if( newTitle == titleString )
		return;
	
	[titleString release];
	titleString = [newTitle retain];
	
	[titleContainer setText:titleString];
}
- (NSString *)title
{
	return titleString;
}

- (void)setText:(NSString *)newText
{
	if( newText == textString )
		return;
	
	[textString release];
	textString = [newText retain];
	
	[textContainer setText:textString];
}
- (NSString *)text
{
	return textString;
}

#pragma mark helpers

- (void)setRectsforSize:(NSSize)theSize
{
	float margins = theSize.height * 0.05f;
	
	titleRect.size.width = theSize.width - margins*2.0f;
	titleRect.size.height = (theSize.height - margins*2.0f)*0.2f;
	titleRect.origin.x = margins;
	titleRect.origin.y = theSize.height - margins - titleRect.size.height;
	
	textRect.size.width = titleRect.size.width;
	// might want to remove the last "margins" if it looks strange
	textRect.size.height = (theSize.height - margins*2.0f) - titleRect.size.height - margins;
	textRect.origin.x = titleRect.origin.x;
	textRect.origin.y = margins + margins;
}

#pragma mark overrides

- (void)drawInRect:(NSRect)theRect inContext:(CGContextRef)theContext
{
	CGContextSaveGState( theContext );
	
	[self setRectsforSize:theRect.size];
	
	if( titleBox )
		CGPathRelease( titleBox );
	titleBox = TIPCGUtilsPartialRoundedBoxCreate( *(CGRect *)&titleRect, titleRect.size.height*0.2f,FALSE,TRUE,TRUE,FALSE);
	if( textBox )
		CGPathRelease( textBox );
	// radius maybe should match the title radius
	textBox = TIPCGUtilsPartialRoundedBoxCreate( *(CGRect *)&textRect, titleRect.size.width*0.1f, TRUE,FALSE,FALSE,TRUE);
	
	CGContextSetRGBFillColor(theContext,0.0f,0.0f,0.0f,1.0f);
	CGContextFillRect(theContext, *(CGRect *)&theRect);
	
	CGContextSetRGBStrokeColor( theContext, 0.5f,0.5f,0.5f,5.0f);
	CGContextSetLineWidth( theContext, 1.0f);
	// draw the shine first
	CGContextSaveGState( theContext );
		CGContextScaleCTM( theContext, 1.0f, -1.0f);
		CGContextTranslateCTM( theContext, 0.0f, -1.8f*textRect.origin.y );
		//[textGradient fillPath:textBox inContext:theContext withAngle:0.0f];
		TIPGradientAxialFillPath(theContext,titleGradient,textBox,0.0f);
		CGContextAddPath( theContext, textBox);
		CGContextStrokePath( theContext );
	CGContextRestoreGState( theContext );
	//[blackShine fillRect:NSMakeRect(0.0f,0.0f,theRect.size.width,textRect.origin.y) angle:90.0f withContext:theContext];
	TIPGradientAxialFillRect(theContext,blackShine,CGRectMake(0.0f,0.0f,theRect.size.width,textRect.origin.y),90.0f);
	
	// draw textbox
	//[textGradient fillPath:textBox inContext:theContext withAngle:0.0f];
	TIPGradientAxialFillPath(theContext,textGradient,textBox,0.0f);
	CGContextAddPath( theContext, textBox );
	CGContextStrokePath( theContext );
	
	// draw titleBox
	//[titleGradient fillPath:titleBox inContext:theContext withAngle:90.0f];
	TIPGradientAxialFillPath(theContext,titleGradient,titleBox,90.0f);
	CGContextAddPath( theContext, titleBox );
	CGContextStrokePath( theContext );
	
	[titleContainer setFontSize:titleRect.size.height*0.7f];
	[titleContainer drawTextInRect:titleRect inContext:theContext];
	
	NSRect textRectWithMargins = textRect;
	float textMargins = titleRect.size.width*0.1f;
	textRectWithMargins.size.width -= 2.0f*textMargins;
	textRectWithMargins.size.height -= 2.0f*textMargins;
	textRectWithMargins.origin.x += textMargins;
	textRectWithMargins.origin.y += textMargins;
	[textContainer setFontSize:textRectWithMargins.size.height/8.0f];
	[textContainer drawTextInRect:textRectWithMargins inContext:theContext];
	
	// draw some screws or some glare over stuff...
	
	CGContextRestoreGState( theContext );
}	

@end
