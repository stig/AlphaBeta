//
//  ReversiMove.m
//  AlphaBeta
//
//  Created by Stig Brautaset on 18/12/2005.
//  Copyright 2005 Stig Brautaset. All rights reserved.
//

#import "ReversiMove.h"

@implementation ReversiMove

- (id)initWithCol:(int)x andRow:(int)y
{
    if (self = [super init]) {
        col = x;
        row = y;
    }
    return self;
}

+ (id)newWithCol:(int)x andRow:(int)y
{
    return [[ReversiMove alloc] initWithCol:x andRow:y];
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
