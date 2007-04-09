//
//  TIPSegmentedTableView.m
//  SegmentedTableView
//
//  Created by Nur Monson on 12/7/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import "TIPSegmentedTableView.h"

@implementation TIPSegmentedTableView

- (id)initWithFrame:(NSRect)frame
{
	printf("init!\n");
	if( (self = [super initWithFrame:frame]) ) {
		//items = [[NSMutableArray alloc] initWithObjects:@"Control",@"Questions",@"Players",nil];
	}

	return self;
}

- (void)dealloc
{
	[items release];

	[super dealloc];
}

- (void)awakeFromNib
{
	NSTableColumn *tableColumn = [self tableColumnWithIdentifier:@"name"];
	TIPTextCell *textCell = [[[TIPTextCell alloc] init] autorelease];
	[textCell setIsTitle:NO];
	[tableColumn setDataCell:textCell];
	
	items = [[NSMutableArray alloc] initWithObjects:
		[NSDictionary dictionaryWithObjectsAndKeys:@"Controls",@"name",[NSImage imageNamed:@"controls.tiff"],@"image",nil],
		[NSDictionary dictionaryWithObjectsAndKeys:@"Questions",@"name",[NSImage imageNamed:@"questions.tiff"],@"image",nil],
		[NSDictionary dictionaryWithObjectsAndKeys:@"Players",@"name",[NSImage imageNamed:@"players.tiff"],@"image",nil],
		nil];
	
	[self setDelegate:self];
	[self setDataSource:self];
	[self reloadData];
	
	[self selectRow:0 byExtendingSelection:NO];
	[managedTabs takeSelectedTabViewItemFromSender:self];	
}

#pragma mark Datasource Methods

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [items count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	return [[items objectAtIndex:rowIndex] valueForKey:[aTableColumn identifier]];
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	// do nothing
}

#pragma mark delegate methods
- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	if( ![aCell isKindOfClass:[NSTextFieldCell class]] )
		return;

	NSColor* newTextColor = ([[self selectedRowIndexes] containsIndex:rowIndex]) ? [NSColor alternateSelectedControlTextColor] : [NSColor textColor];
	[(NSTextFieldCell *)aCell setTextColor:newTextColor];
}

#pragma mark Segmented Cell

- (int)indexOfSelectedItem
{
	return [self selectedRow];
}

- (void)selectRowIndexes:(NSIndexSet *)indexes byExtendingSelection:(BOOL)willExtend
{
	[super selectRowIndexes:indexes byExtendingSelection:willExtend];
	[managedTabs takeSelectedTabViewItemFromSender:self];
}
@end
