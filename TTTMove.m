//
//  TTTMove.m
//  AlphaBeta
//
//  Created by Stig Brautaset on 11/12/2005.
//  Copyright 2005 Stig Brautaset. All rights reserved.
//

#import "TTTMove.h"

@implementation TTTMove

+ (TTTMove *)newWithCol:(int)x andRow:(int)y
{
    return [[TTTMove alloc] initWithCol:x andRow:y];
}

- (TTTMove *)initWithCol:(int)x andRow:(int)y
{
    if (self = [super init]) {
        col = x;
        row = y;
    }
    return self;
}

- (int)col
{
    return col;
}

- (int)row
{
    return row;
}

- (NSString *)string
{
    return [NSString stringWithFormat:@"%d%d", col, row];
}
@end
