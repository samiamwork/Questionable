//
//  TriviaOutlineView.m
//  TriviaOutlineView
//
//  Created by Nur Monson on 1/18/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "TriviaOutlineView.h"

@interface NSObject (datasource)
- (id)deleteItem:(id)sender;
@end

@implementation TriviaOutlineView
/*
- (void)keyDown:(NSEvent *)theEvent
{
	if( [[theEvent charactersIgnoringModifiers] characterAtIndex:0] == NSDeleteCharacter ) {
		if( [self dataSource] != nil && [[self dataSource] respondsToSelector:@selector(deleteItem:)] )
			[[self dataSource] deleteItem:self];
		
		return;
	}
	
	[super keyDown:theEvent];
}
*/
@end
