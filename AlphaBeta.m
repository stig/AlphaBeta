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
    if (self = [super init]) {
        states = [NSMutableArray new];
        moves = [NSMutableArray new];
        [self setMaxPly:3];
    }
    return self;
}

- (id)initWithState:(id)st
{
    [self init];
    [self setState:st];
    return self;
}

- (void)dealloc
{
    [states release];
    [moves release];
    [super dealloc];
}

- (void)setState:(id)st
{
    if ([states count]) {
        [NSException raise:@"state set" format:@"State already set"];
    }
    [states addObject:st];
}

- (id)currentState
{
    return [states lastObject];
}

- (id)lastMove
{
    return [moves lastObject];
}

- (int)countMoves
{
    return [moves count];
}

- (int)countStates
{
    return [states count];
}
- (float)abWithAlpha:(float)alpha beta:(float)beta plyLeft:(int)ply
{
    NSMutableArray *mvs = [[self currentState] listAvailableMoves];

    if (![mvs count] || !ply) {
        return [[self currentState] fitness];
    }

    int i;
    for (i = 0; i < [mvs count]; i++) {
        [self move:[mvs objectAtIndex:i]];
        float sc = -[self abWithAlpha:-beta beta:-alpha plyLeft:ply-1];
        alpha = alpha > sc ? alpha : sc;
        [self undo];
    }
    return alpha;
}

- (void)aiMove
{
    NSMutableArray *mvs = [[self currentState] listAvailableMoves];
    int i;
    id best = nil;
    float alpha = -10000.0;
    float beta  = +10000.0;
    for (i = 0; i < [mvs count]; i++) {
        id m = [mvs objectAtIndex:i];
        [self move:m];
        float sc = -[self abWithAlpha:-beta beta:-alpha plyLeft:maxPly-1];
        if (sc > alpha) {
            alpha = sc;
            best = m;
        }
        [self undo];
    }
    [self move:best];
}

- (void)move:(id)m
{
    id s = [self currentState];
    if (![s canUndo]) {
        [states addObject:[s copy]];
    }
    [[self currentState] applyMove:m];
    [moves addObject:m];
}

- (void)undo
{
    if (![moves count]) {
        [NSException raise:@"undo" format:@"No moves to undo"];
    }

    id s = [self currentState];
    if (![s canUndo]) {
        [states removeLastObject];
    }
    else {
        [s undoMove:[moves lastObject]];
    }
    [moves removeLastObject];
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
