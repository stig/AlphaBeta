//
//  AlphaBeta.m
//  AlphaBeta
//
//  Created by Stig Brautaset on 11/12/2005.
//  Copyright 2005 Stig Brautaset. All rights reserved.
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
        [self setState:st];
        [self setMaxPly:3];
        moves = [NSMutableArray new];
    }
    return self;
}

- (void)dealloc
{
    [state release];
    [moves release];
    [super dealloc];
}

- (void)setState:(id)st
{
    if (state) {
        [NSException raise:@"state set" format:@"State already set"];   
    }
    state = [st retain];
}

- (id)currentState
{
    return state;
}

- (int)countMoves
{
    return [moves count];
}

- (float)abWithAlpha:(float)alpha beta:(float)beta plyLeft:(int)ply
{
    NSMutableArray *mvs = [[[self currentState] listAvailableMoves] autorelease];
    
    return [[self currentState] fitness];
    
    if ([mvs count] == 0 || !ply) {
        return [[self currentState] fitness];
    }
    
    int i;
    for (i = 0; i < [mvs count]; i++) {
        id m = [mvs objectAtIndex:i];
        [self move:m];
        float sc = -[self abWithAlpha:-beta beta:-alpha plyLeft:ply-1];
        alpha = alpha > sc ? alpha : sc;
        [self undo];
    }
    return alpha;
}

- (void)aiMove
{
    NSMutableArray *mvs = [[[self currentState] listAvailableMoves] autorelease];
    int i;
    id best = nil;
    float max = 0.0;
    for (i = 0; i < [mvs count]; i++) {
        id m = [mvs objectAtIndex:i];
        [self move:m];
        float sc = -[self abWithAlpha:-100.0 beta:100.0 plyLeft:maxPly-1];
        if (sc > max) {
            max = sc;
            [best autorelease];
            best = [m retain];
        }
        [self undo];
    }
    [self move:best];
}

- (void)move:(id)m
{
    [self move:m];
    [moves addObject:m];
}

- (void)undo
{
    id m = [moves lastObject];
    [self undo];
    [moves removeLastObject];
    [m autorelease];
}

- (int)maxPly
{
    return maxPly;
}

- (void)setMaxPly:(int)ply
{ 
    if (ply < 0) {
        [NSException raise:@"negative ply" format:@"maxPly must be positive"];
    }
    maxPly = ply;
}
@end
