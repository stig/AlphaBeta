/*
Copyright (C) 2006,2007 Stig Brautaset. All rights reserved.

This file is part of AlphaBeta.

AlphaBeta is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

AlphaBeta is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with AlphaBeta; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

*/


#import "SBAlphaBeta.h"

@implementation SBAlphaBeta

#pragma mark Creation & Cleanup

- (id)init
{
    [NSException raise:@"abort"
                format:@"Use -initWithState: instead"];
    return nil;
}


- (id)initWithState:(id)this
{
    if (self = [super init]) {
        if ([this conformsToProtocol:@protocol(SBUndoableAlphaBetaSearching)])
            mutableStates = YES;
        
        if (![this conformsToProtocol:@protocol(SBAlphaBetaSearching)])
            [NSException raise:@"not-a-state"
                        format:@"State %@ lacks necessary methods", this];

        stateHistory = [[NSMutableArray arrayWithObject:this] retain];
        moveHistory = [NSMutableArray new];
    }
    return self;
}

+ (id)newWithState:(id)this
{
    return [[self alloc] initWithState:this];
}

- (void)dealloc
{
    [stateHistory release];
    [moveHistory release];
    [super dealloc];
}


#pragma mark Private methods

- (id)move:(id)m
{
    id state = [self currentState];
    if (mutableStates) {
        [state applyMove:m];
    
    } else {
        state = [[state copy] autorelease];
        [state applyMove:m];
        [stateHistory addObject:state];
    }
    return state;
}

- (id)undo:(id)m
{
    if (mutableStates) {
        [[self currentState] undoMove:m];

    } else {
        [stateHistory removeLastObject];
    }
    
    return [self currentState];
}

- (double)abWithState:(id)state alpha:(double)alpha beta:(double)beta plyLeft:(unsigned)ply
{
    statesVisited++;
    
    /* If we're doing iterative search and have run out of time, return.
       It doesn't matter what value we return, because it will be
       ignored. Benchmarks reveals this test is quite cheap, so taking
       the tiny performance hit is certainly worth it for the accuracy
       it gives us in timekeeping.
     */
    if (dateLimit && [dateLimit compare:[NSDate date]] < 0)
        return 0.0;
    
    /* For correctness we should really check for end of the game before
       we check if we have reached max ply, but doing this speeds up
       fixed-depth search by 33% (for Reversi).
     */
    if (!ply) {
        foundEnd = NO;
        return [self currentFitness];
    }
    
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    NSArray *mvs = [self currentLegalMoves];
    if (![mvs count])
        return [self currentFitness];
    
    id iter = [mvs objectEnumerator];
    for (id m; m = [iter nextObject];) {
        id nextState = [self move:m];
        double sc = -[self abWithState:nextState alpha:-beta beta:-alpha plyLeft:ply-1];
        alpha = alpha > sc ? alpha : sc;
        [self undo:m];
        
        if (alpha >= beta)
            goto cut;
    }

cut:
    [pool release];
    return alpha;
}

#pragma mark Search methods

- (id)moveFromSearchWithDepth:(unsigned)ply
{
    double alpha = -INFINITY;
    double beta  = +INFINITY;
    
    if (ply < 1)
        [NSException raise:@"ply-too-low" format:@"Ply must be 1 or greater"];
    
    statesVisited = 0;
    dateLimit = nil;
    
    id best = nil;
    NSArray *mvs = [self currentLegalMoves];
    NSEnumerator *iter = [mvs objectEnumerator];
    for (id m; ply && (m = [iter nextObject]); ) {
        
        id state = [self move:m];
        double sc = -[self abWithState:state alpha:-beta beta:-alpha plyLeft:ply-1];
        if (sc > alpha) {
            alpha = sc;
            best = m;
        }
        [self undo:m];
    }
    
    return best;
}

- (id)performMoveFromSearchWithDepth:(unsigned)ply
{
    id best = [self moveFromSearchWithDepth:ply];
    return best ? [self performMove:best] : nil;
}

- (id)moveFromSearchWithInterval:(NSTimeInterval)interval
{
    id best = nil;
    unsigned accumulatedStatesVisited = 0;
    
    dateLimit = [NSDate dateWithTimeIntervalSinceNow:interval * .975];
    NSArray *mvs = [self currentLegalMoves];
    for (unsigned ply = 1;; ply++) {

        unsigned leafCount = 0;
        id bestAtThisPly = nil;

        double alpha = -INFINITY;
        double beta  = +INFINITY;
        statesVisited = 0;

        /** @todo When searching to ply N+1, order the moves so we
            search the most promising one from search to ply N.
            This has the potential of speeding up search a lot.
         */
        NSEnumerator *iter = [mvs objectEnumerator];

        for (id m; m = [iter nextObject]; ) {
        
            /* Reset the 'reached a leaf state' indicator. */
            foundEnd = YES;

            id state = [self move:m];
            double sc = -[self abWithState:state alpha:-beta beta:-alpha plyLeft:ply-1];
            if (sc > alpha) {
                alpha = sc;
                bestAtThisPly = m;
            }
            [self undo:m];

            /* Check if we have any time left. */
            if ([dateLimit compare:[NSDate date]] < 0)
                goto time_is_up;
            
            if (foundEnd)
                leafCount++;
        }

        /* If we got here then we should replace the current best move,
           since we just finished a search to a deeper level than before.
         */
        best = bestAtThisPly;
        plyReached = ply;
        accumulatedStatesVisited += statesVisited;

        /* If we found a leaf state for every move, then we're done. We
           don't need to search deeper. */
        if (leafCount == [mvs count]) {
            /* See note above in the internal ab method. */
            plyReached--;
            break;
        }
    }

time_is_up:
    if (statesVisited = accumulatedStatesVisited)
        return best;

    /* If we got here then we didn't even finish searching to 1 ply. This is
       probably because someone gave a ridiculously low interval. Simply set
       plyReached and perform a fixed-depth search in that case. */
    plyReached = 1;
    return [self moveFromSearchWithDepth:1];
}

- (id)performMoveFromSearchWithInterval:(NSTimeInterval)interval
{
    id best = [self moveFromSearchWithInterval:interval];
    return best ? [self performMove:best] : nil;
}    

#pragma mark Methods

- (id)performMove:(id)m
{
    id moves = [self currentLegalMoves];
    if (NSNotFound == [moves indexOfObject:m]) {
        /* Check that move is in the current allowed move list */
        [NSException raise:@"illegalmove"
                    format:@"%@ is not one of the legal moves: %@", m, moves];
    }

    id state = [[self currentState] copy];
    [state applyMove:m];
    [stateHistory addObject:[state autorelease]];
    [moveHistory addObject:m];
    return state;
}


- (id)undoLastMove
{
    [moveHistory removeLastObject];
    [stateHistory removeLastObject];
    return [self currentState];
}

- (id)currentState
{
    return [stateHistory lastObject];
}

- (id)lastMove
{
    return [moveHistory lastObject];
}

- (unsigned)countPerformedMoves
{
    return [moveHistory count];
}

- (unsigned)currentPlayer
{
    return ([self countPerformedMoves] % 2) + 1;
}

- (unsigned)winner
{
    if (![self isGameOver])
        [NSException raise:@"game-not-over"
                    format:@"Cannot determine winner; game has not ended yet"];

    double score = [[self currentState] endStateScore];
    if (!score)
        return 0;
    unsigned player = [self currentPlayer];
    return score > 0 ? player : 3 - player;
}


- (BOOL)isGameOver
{
    NSArray *a = [self currentLegalMoves];
    return [a count] ? NO : YES;
}

- (unsigned)depthForSearch
{
    return plyReached;
}

- (unsigned)stateCountForSearch
{
    return statesVisited;
}


- (BOOL)isForcedPass
{
    id mvs = [self currentLegalMoves];
    if (mvs && [mvs count] == 1)
        if ([[mvs lastObject] isKindOfClass:[NSNull class]])
            return YES;
    return NO;
}

#pragma mark Simple forwarders

- (double)currentFitness
{
    return [[self currentState] fitness];
}

- (NSArray *)currentLegalMoves
{
    return [[self currentState] legalMoves];
}


@end

