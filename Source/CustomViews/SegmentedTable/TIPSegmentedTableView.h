//
//  TIPSegmentedTableView.h
//  SegmentedTableView
//
//  Created by Nur Monson on 12/7/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TIPSideGradientTableView.h"
#import "TIPTextCell.h"

@interface TIPSegmentedTableView : TIPSideGradientTableView<NSTableViewDelegate,NSTableViewDataSource> {
	NSMutableArray *items;
	
	IBOutlet NSTabView *managedTabs;
}


@end
