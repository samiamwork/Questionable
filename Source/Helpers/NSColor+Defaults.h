//
//  NSColor+defaults.h
//  Questionable
//
//  Created by Nur Monson on 10/18/08.
//  Copyright 2008 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSColor(Defaults)

+ (NSColor*)colorWithDifferenceHue:(float)hue saturation:(float)saturation brightness:(float)brightness;

@end
