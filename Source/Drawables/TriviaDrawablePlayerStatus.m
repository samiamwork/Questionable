//
//  TriviaDrawablePlayerStatus.m
//  TriviaPlayer
//
//  Created by Nur Monson on 10/20/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import "TriviaDrawablePlayerStatus.h"
#include "TIPCGUtils.h"


@implementation TriviaDrawablePlayerStatus

- (id)init
{
	if( (self = [super init]) ) {
		players = nil;
		
		//blackShine = [[CTGradient blackShine] retain];
		blackShine = TIPGradientBlackShineCreate();
		
		playerBox = [[TriviaDrawablePlayerStatusBox alloc] init];
		
		nameContainer = [[TIPTextContainer containerWithString:@"name"
														   color:[NSColor colorWithCalibratedRed:1.0f green:1.0f blue:1.0f alpha:1.0f]
														fontName:@"HelveticaNeue"] retain];
		[nameContainer setAlignment:kTIPTextAlignmentLeft];
		pointContainer = [[TIPTextContainer containerWithString:@"0"
														  color:[NSColor colorWithCalibratedRed:1.0f green:0.8f blue:0.8f alpha:1.0f]
													   fontName:@"Impact"] retain];
		[pointContainer setAlignment:kTIPTextAlignmentRight];
	}
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
	if( players != nil )
		[players release];
	
	//[blackShine release];
	TIPGradientRelease(blackShine);
	[playerBox release];
	
	[nameContainer release];
	[pointContainer release];
}

- (void)setPlayers:(NSArray *)newPlayers
{
	if( newPlayers == players )
		return;
	
	if( players )
		[players release];
	
	players = [newPlayers retain];
	
}
- (NSArray *)players
{
	return players;
}

- (void)drawInRect:(NSRect)theRect inContext:(CGContextRef)theContext
{
	if( players == nil ) {
		printf("no Players!\n");
		return;
	}

	CGContextSaveGState( theContext );

	CGContextSetRGBFillColor(theContext,0.0f,0.0f,0.0f,1.0f);
	CGContextFillRect(theContext, *(CGRect *)&theRect);
	
	float margin = theRect.size.height * 0.05f;
	// margin*3 because the bottom is twice as high to make room for the shine
	float spacing = (theRect.size.height - (margin*3.0f))*0.2f/(float)([players count]-1);
	
	NSRect playerStatsRect;
	NSRect playerTextRect;
	playerStatsRect.size.width = theRect.size.width - (margin*2.0f);
	playerStatsRect.size.height = (theRect.size.height-(margin*3.0f)-((float)[players count]-1.0f)*spacing)/(float)[players count];

	playerStatsRect.origin.x = margin;
	playerStatsRect.origin.y = theRect.size.height - playerStatsRect.size.height-margin;
	
	CGContextSetRGBFillColor(theContext,0.5f,0.5f,0.5f,1.0f);
	
	playerTextRect = playerStatsRect;
	playerTextRect.size.width = playerStatsRect.size.width-playerStatsRect.size.height;
	playerTextRect.origin.x += playerStatsRect.size.height/2.0f;
	
	CGLayerRef boxLayer = [playerBox makeLayerForSize:playerStatsRect.size withContext:theContext];
	
	NSEnumerator *playerEnumerator = [players objectEnumerator];
	TriviaPlayer *aPlayer;
	while( (aPlayer = [playerEnumerator nextObject]) ) {
		
		[pointContainer setText:[NSString stringWithFormat:@"%d",[aPlayer points]]];
		[nameContainer setText:[aPlayer name]];
		
		// drawing
		CGContextDrawLayerAtPoint( theContext, *(CGPoint *)&playerStatsRect.origin, boxLayer );
		
		[nameContainer setFontSize:playerStatsRect.size.height/2.0f];
		[pointContainer setFontSize:playerStatsRect.size.height/2.0f];
		
		[nameContainer drawTextInRect:playerTextRect inContext:theContext];
		[pointContainer drawTextInRect:playerTextRect inContext:theContext];
		
		playerStatsRect.origin.y -= playerStatsRect.size.height + spacing;
		playerTextRect.origin.y = playerStatsRect.origin.y;
	}
	
	playerStatsRect.origin.y += playerStatsRect.size.height + spacing;
	CGContextSaveGState( theContext );
		CGContextScaleCTM( theContext, 1.0f, -1.0f);
		CGContextTranslateCTM( theContext, 0.0f, -1.9f*playerStatsRect.origin.y );
		
		CGContextDrawLayerAtPoint( theContext, *(CGPoint *)&playerStatsRect.origin, boxLayer);
	CGContextRestoreGState( theContext );
	//[blackShine fillRect:NSMakeRect(0.0f,0.0f,theRect.size.width,1.8f*margin) angle:90.0f withContext:theContext];
	TIPGradientAxialFillRect(theContext,blackShine,CGRectMake(0.0f,0.0f,theRect.size.width,1.8f*margin),90.0f);
	
	CGContextRestoreGState( theContext );
}

@end
