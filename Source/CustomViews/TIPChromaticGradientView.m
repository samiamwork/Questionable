//
//  TIPChromaticGradientView.m
//  Questionable
//
//  Created by Nur Monson on 10/18/08.
//  Copyright 2008 theidiotproject. All rights reserved.
//

#import "TIPChromaticGradientView.h"
#import "TIPGradient.h"

@implementation TIPChromaticGradientView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
	TIPMutableGradientRef gradient = TIPMutableGradientCreate();
	TIPGradientSetBlendingMode(gradient, TIPChromaticBlendingMode);
	TIPGradientAddRGBColorStop(gradient, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f);
	TIPGradientAddRGBColorStop(gradient, 1.0f, 360.0f, 1.0f, 1.0f, 1.0f);
	NSRect bounds = [self bounds];
	CGContextRef cxt = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextSaveGState(cxt); {
		TIPGradientAxialFillRect(cxt, gradient, *(CGRect*)&bounds, 0.0f);
	} CGContextRestoreGState(cxt);
	TIPGradientRelease(gradient);
}

@end
