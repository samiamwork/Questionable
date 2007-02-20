#import "TIPFreeWindow.h"

@implementation TIPFreeWindow

- (NSRect)constrainFrameRect:(NSRect)frameRect toScreen:(NSScreen *)aScreen
{
	return frameRect;
}

@end
