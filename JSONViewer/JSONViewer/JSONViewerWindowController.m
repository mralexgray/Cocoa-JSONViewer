//
//  JSONViewerWindowController.m
//  JSONViewer
//
//  Created by Randy Luecke on 2/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JSONViewerWindowController.h"

@implementation JSONViewerWindowController

@synthesize textView;
@synthesize rootNode;
@synthesize outlineView;
@synthesize sv;
@synthesize tvsv;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        dictValueStrings = [NSMutableArray arrayWithCapacity:1];
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)viewJSON:(id)sender
{
    NSData *data = [self.textView.string dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error;
    
    id value = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if (error)
    {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Error parsing JSON" defaultButton:@"Damn that sucks" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Check your JSON"];
        [alert beginSheetModalForWindow:self.window modalDelegate:nil didEndSelector:nil contextInfo:nil];
        return;
    }

    content = value;

    [sv setFrame:[self.tvsv frame]];
    [self.window.contentView addSubview:sv];
    [self.tvsv removeFromSuperview];
    [outlineView reloadData];
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)node
{
    if (!node)
    {
        //NSLog(@"Children: %ld", [content count]);
        return 1;//[content count];
    }

    NSLog(@"node: %@", node);

    if ([node isKindOfClass:[NSArray class]] || [node isKindOfClass:[NSDictionary class]])
        return [node count];
    else
        return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)node
{
    if (!node)
        return content;

    if ([node isKindOfClass:[NSDictionary class]])
    {
        NSArray *keys = [node allKeys];
        id value = [node objectForKey:[keys objectAtIndex:index]];
        
        if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]])
            return value;
        else
        {
            NSString *newValue = [NSString stringWithFormat:@"%@: %@", [keys objectAtIndex:index], value];
            NSInteger index = [dictValueStrings indexOfObject:newValue];
            
            if(index != NSNotFound)
                newValue = [dictValueStrings objectAtIndex:index];
            else
                [dictValueStrings addObject:newValue];

            return newValue;
        }
    }
    else
        return [node objectAtIndex:index];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    if ([item isKindOfClass:[NSArray class]])
        return [NSString stringWithFormat:@"Array: %d item%@", [item count], [item count] == 1 ? @"" : @"s" ];
    else if ([item isKindOfClass:[NSDictionary class]])
        return [NSString stringWithFormat:@"Dictionary: %d item%@", [item count], [item count] == 1 ? @"" : @"s" ];
    else
        return item;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    //return NO;
    return ([item isKindOfClass:[NSArray class]] || [item isKindOfClass:[NSDictionary class]]) && [item count];
}

@end