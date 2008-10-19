//
//  NSColor+defaults
//  Questionable
//
//  Created by Nur Monson on 10/18/08.
//  Copyright 2008 theidiotproject. All rights reserved.
//

#import "NSColor+Defaults.h"


@implementation NSColor(Defaults)
+ (NSColor*)colorWithDifferenceHue:(float)hue saturation:(float)saturation brightness:(float)brightness
{
	float defaultHue = [(NSNumber*)[[NSUserDefaults standardUserDefaults] valueForKey:@"DefaultHue"] floatValue];
	float defaultSaturation = 0.6364f;
	float defaultBrightness = 0.55f;
	hue += defaultHue;
	if(hue > 1.0f)
		hue -= 1.0f;
	else if(hue < 0.0f)
		hue += 1.0f;
	saturation += defaultSaturation;
	saturation = MAX(0.0f,saturation);
	saturation = MIN(1.0f,saturation);
	brightness += defaultBrightness;
	brightness = MAX(0.0f,brightness);
	brightness = MIN(1.0f,brightness);
	return [NSColor colorWithCalibratedHue:hue saturation:saturation brightness:brightness alpha:1.0f];
}
@end
