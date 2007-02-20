/* TIPFreeWindow */

#import <Cocoa/Cocoa.h>

@interface TIPFreeWindow : NSWindow
{
}

- (NSRect)constrainFrameRect:(NSRect)frameRect toScreen:(NSScreen *)aScreen;
@end
