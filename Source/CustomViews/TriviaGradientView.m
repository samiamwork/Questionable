//
//  TriviaGradientView.m
//  Questionable
//
//  Created by Nur Monson on 3/27/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "TriviaGradientView.h"


@implementation TriviaGradientView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
	CGContextRef cxt = [[NSGraphicsContext currentContext] graphicsPort];
	NSRect bounds = [self bounds];
	
	TIPMutableGradientRef bgGradient = TIPMutableGradientCreate();
	TIPGradientAddRGBColorStop(bgGradient,0.0f,0.8f,0.8f,0.8f,1.0f);
	TIPGradientAddRGBColorStop(bgGradient,0.1f,0.9f,0.9f,0.9f,1.0f);
	
	TIPGradientAxialFillRect(cxt,bgGradient,*(CGRect *)&bounds,90.0f);
	TIPGradientRelease(bgGradient);
}

@end
