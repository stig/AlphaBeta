//
//  TTTMove.m
//  AlphaBeta
//
//  Created by Stig Brautaset on 11/12/2005.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "TTTMove.h"

@implementation TTTMove

- (TTTMove *)initWithX:(int)x andY:(int)y
{
    if (self = [super init]) {
        col = x;
        row = y;
    }
    return self;
}
- (int)x
{
    return col;
}
- (int)y
{
    return row;
}

@end
