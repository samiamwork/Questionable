//
//  PlayerNameView.h
//  Questionable
//
//  Created by Nur Monson on 6/26/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "../Helpers/TransitionAnimation.h"

@interface PlayerNameView : NSTextField<NSAnimationDelegate> {
	TransitionAnimation *_fadeAnimation;
}

@end
