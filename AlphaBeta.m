//
//  AlphaBeta.m
//  AlphaBeta
//
//  Created by Stig Brautaset on 11/12/2005.
//  Copyright 2005 Stig Brautaset. All rights reserved.
//

#import "AlphaBeta.h"
#import "AlphaBetaState.h"

const float AlphaBetaFitnessMax =  1000000000.0;
const float AlphaBetaFitnessMin = -1000000000.0;

@implementation AlphaBeta

- (id)init
{
    if (self = [super init]) {
        states = [NSMutableArray new];
        moves = [NSMutableArray new];
        canUndo = NO;
        [self setMaxPly:3];
        [self setMaxTime:0.3];
        reachedPly = -1;
    }
    return self;
}

- (id)initWithState:(id)st
{
    if (self = [self init]) {
        [self setState:st];
    }
    return self;
}

- (void)dealloc
{
    [states release];
    [moves release];
    [super dealloc];
}

- (float)fitness
{
    return [[self currentState] fitness];
}

- (void)setState:(id)st
{
    if ([states count]) {
        [NSException raise:@"state set" format:@"State already set"];
    }
    [states addObject:st];
    canUndo = [st conformsToProtocol:@protocol(AlphaBetaStateWithUndo)];
}

- (id)currentState
{
    return [states lastObject];
}

- (id)lastMove
{
    return [moves lastObject];
}

- (unsigned)countMoves
{
    return [moves count];
}

- (unsigned)countStates
{
    return [states count];
}

- (float)abWithAlpha:(float)alpha beta:(float)beta plyLeft:(unsigned)ply
{
    NSMutableArray *mvs = [[self currentState] listAvailableMoves];

    if (![mvs count] || ply <= 0) {
        if (![mvs count]) {
            foundEnd = YES;
        }
        return [[self currentState] fitness];
    }

    int i;
    for (i = 0; i < [mvs count]; i++) {
        if ([self move:[mvs objectAtIndex:i]]) {
            float sc = -[self abWithAlpha:-beta beta:-alpha plyLeft:ply-1];
            alpha = alpha > sc ? alpha : sc;
            [self undo];
        }
        else {
            NSLog(@"internal ab failure at ply %u; %@", ply, [mvs objectAtIndex:i]);
        }
    }
    return alpha;
}

- (id)fixedDepthSearch
{
    return [self fixedDepthSearchToDepth:[self maxPly]];
}

- (id)fixedDepthSearchToDepth:(unsigned)depth
{
    NSMutableArray *mvs = [[self currentState] listAvailableMoves];
    int i;
    id best = nil;
    float alpha = AlphaBetaFitnessMin - 1; // worse than min fitness.
    float beta  = AlphaBetaFitnessMax;
    int reachedEnd = 0;
    for (i = 0; i < [mvs count]; i++) {
        foundEnd = NO;
        id m = [mvs objectAtIndex:i];
        if ([self move:m]) {
            float sc = -[self abWithAlpha:-beta beta:-alpha plyLeft:depth-1];
            if (sc > alpha) {
                alpha = sc;
                best = m;
            }
            [self undo];
        }
        else {
            NSLog(@"failed to perform move: %@", m);
        }
        if (foundEnd) {
            reachedEnd++;
        }
    }
    if (reachedEnd == [mvs count]) {
        foundEnd = YES;
    }
    return [self move:best];
}

- (id)iterativeSearch
{
    return [self iterativeSearchWithTime:[self maxTime]];
}

- (id)iterativeSearchWithTime:(NSTimeInterval)time
{
    id best = nil;
    int ply;
    
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:time];
    for (ply = 1;; ply++) {
        if ([self fixedDepthSearchToDepth:ply]) {
            [best autorelease];
            best = [[self lastMove] retain];
            [self undo];
            reachedPly = ply;
        }
        if (foundEnd || [date compare:[NSDate date]] < 0) {
            break;
        }
    }
    return [self move:best];
}

- (int)reachedPly
{
    return reachedPly;
}

- (id)move:(id)m
{
    id s = [self currentState];
    if (!canUndo) {
        id cp = [s copy];
        if (!cp) {
            [NSException raise:@"copyfail" format:@"Copying state failed"];
        }
        [states addObject:cp];
    }
    
    @try {
        if (![[self currentState] applyMove:m]) {
            [NSException raise:@"movefail" format:@"Failed applying move"];
        }
        [moves addObject:m];
    }
    @catch (id any) {
        NSLog(@"Failed applying move: %@", [any reason]);
        if (!canUndo) {
            [[states lastObject] release];
            [states removeLastObject];
            NSLog(@"removing last state");
        }
        return nil;
    }
    return [self currentState];
}

- (id)undo
{
    if (![moves count]) {
        [NSException raise:@"undo" format:@"No moves to undo"];
    }

    id s = [self currentState];
    if (!canUndo) {
        [[states lastObject] release];
        [states removeLastObject];
    }
    else if (![s undoMove:[moves lastObject]]) {
        [NSException raise:@"undofail" format:@"Failed to undo move"];
    }
    [moves removeLastObject];
    return [self currentState];
}

- (unsigned)maxPly
{
    return maxPly;
}

- (void)setMaxPly:(unsigned)ply
{
    maxPly = ply;
}

- (NSTimeInterval)maxTime
{
    return maxTime;
}

- (void)setMaxTime:(NSTimeInterval)time
{
    maxTime = time;
}

- (BOOL)isGameOver
{
    NSArray *a = [[self currentState] listAvailableMoves];
    return [a count] ? NO : YES;
}

@end
