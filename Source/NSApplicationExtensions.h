//
//  NSApplicationExtensions.h
//  Questionable
//
//  Created by Nur Monson on 4/9/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSApplication (TIPExtensions)

- (NSString *)registeredString;
- (BOOL)registered;

@end
