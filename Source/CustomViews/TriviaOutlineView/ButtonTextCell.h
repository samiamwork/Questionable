//
//  ButtonTextCell.h
//  TriviaOutlineView
//
//  Created by Nur Monson on 1/19/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "TriviaBoard.h"


@interface ButtonTextCell : NSTextFieldCell {
	NSButtonCell *buttonCell;
}

- (NSButtonCell *)buttonCell;
- (void)setButtonCell:(NSButtonCell *)newButtonCell;

@end
