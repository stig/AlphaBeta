//
//  AlphaBeta.m
//  AlphaBeta
//
//  Created by Stig Brautaset on 11/12/2005.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "AlphaBeta.h"

@implementation AlphaBeta

- (id)init
{
    return [self initWithState:nil];
}

- (id)initWithState:(id)st
{
    if (self = [super init]) {
        state = st;
        moves = [NSMutableArray new];
    }
    return self;
}

- (id)currentState
{
    return state;
}

@end
