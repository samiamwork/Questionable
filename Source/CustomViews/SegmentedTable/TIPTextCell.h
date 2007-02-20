//
//  TIPTextCell.h
//  TriviaPlayer
//
//  Created by Nur Monson on 11/13/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TIPTextCell : NSTextFieldCell {
	NSMutableDictionary *titleStyle;
	NSMutableDictionary *normalStyle;
	BOOL isTitle;
}

- (BOOL)isTitle;
- (void)setIsTitle:(BOOL)newIsTitle;

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;

@end
