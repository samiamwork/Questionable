//
//  TIPSegmentedTableView.h
//  SegmentedTableView
//
//  Created by Nur Monson on 12/7/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TIPGradientTableView.h"
#import "TIPTextCell.h"

@interface TIPSegmentedTableView : TIPGradientTableView {
	NSMutableArray *items;
	
	IBOutlet NSTabView *managedTabs;
}


@end
