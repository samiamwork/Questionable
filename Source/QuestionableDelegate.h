//
//  QuestionableDelegate.h
//  Questionable
//
//  Created by Nur Monson on 2/12/07.
//  Copyright theidiotproject 2007. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Controllers/TriviaOutlineViewController.h"
#import "BoolToStatusImageTransformer.h"
#import "BoolToStatusStringTransformer.h"

@interface QuestionableDelegate : NSObject
{
	IBOutlet TriviaOutlineViewController *viewController;
}

@end
