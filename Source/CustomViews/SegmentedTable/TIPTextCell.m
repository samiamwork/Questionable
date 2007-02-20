//
//  TIPTextCell.m
//  TriviaPlayer
//
//  Created by Nur Monson on 11/13/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import "TIPTextCell.h"


@implementation TIPTextCell

- (id)init
{
	if( (self = [super init]) ) {
		NSMutableParagraphStyle *style = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
		[style setLineBreakMode:NSLineBreakByTruncatingTail];

		NSFont *font = [NSFont fontWithName:@"Helvetica-Bold" size:17.0f];
		//NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
		//[shadow set
		titleStyle = [[NSMutableDictionary alloc] initWithObjectsAndKeys:style, NSParagraphStyleAttributeName, font, NSFontAttributeName, nil];
		//normalStyle = [[NSMutableDictionary alloc] initWithObjectsAndKeys:style, NSParagraphStyleAttributeName, nil];
		normalStyle = titleStyle;
		
		isTitle = NO;
	}
	
	return self;
}

- (void)dealloc
{	
	[titleStyle release];
	[normalStyle release];
	
	[super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
	TIPTextCell *newCell = [super copyWithZone:zone];
	
	newCell->titleStyle = [titleStyle mutableCopy];
	newCell->normalStyle = [normalStyle mutableCopy];
	
	return newCell;
}
- (BOOL)isTitle
{
	return isTitle;
}
- (void)setIsTitle:(BOOL)newIsTitle
{
	isTitle = newIsTitle;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    //[super drawWithFrame:cellFrame inView:controlView];
	
	//printf("drawing\n");
	NSRect insetRect = NSInsetRect(cellFrame,2.0f,2.0f);
	NSString *stringValue = [self stringValue];
	//NSRect boundingRect = [stringValue boundingRectWithSize:insetRect.size options:nil attributes:nil];
	//NSFont *font = [NSFont fontWithName:@"HelveticaNeue" size:15.0f];
	/*
	NSMutableParagraphStyle *style = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
	[style setLineBreakMode:NSLineBreakByTruncatingTail];
	NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:style, NSParagraphStyleAttributeName, [self textColor], NSForegroundColorAttributeName, nil];
	*/
	NSDictionary *info = normalStyle;
	if( isTitle )
		info = titleStyle;
	
	if( info == nil )
		printf(" nil color!\n");
	//printf("retainCount for info = %d\n", [info retainCount]);
	[info setValue:[self textColor] forKey:NSForegroundColorAttributeName];
	
	NSSize textSize = [stringValue sizeWithAttributes:info];
	
	if( textSize.height > insetRect.size.height ) {
		[stringValue drawInRect:insetRect withAttributes:info];
	} else {
		float dy = (insetRect.size.height - textSize.height)/2.0f;
		insetRect = NSInsetRect(insetRect,0.0f,dy);
		[stringValue drawInRect:insetRect withAttributes:info];
	}

}

@end
