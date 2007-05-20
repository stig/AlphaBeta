/*
Copyright (C) 2006,2007 Stig Brautaset. All rights reserved.

This file is part of SBAlphaBeta.

SBAlphaBeta is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

SBAlphaBeta is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with SBAlphaBeta; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

*/


#import "SBAlphaBeta.h"

/** 
Encapsulation of the Alpha-Beta algorithm.

This class encapsulates the Alpha-Beta algorithm. No prior experience with Artificial Intelligence is required in order to use it.

@section states_sec Requirements for states

States must implement <em>either</em> the SBAlphaBetaState <em>or</em> the SBMutableAlphaBetaState protocol. See their respective documentation for details of which methods this entails.

Though not <em>required</em>, it is advisable that you also override -description. This way some of the exceptions thrown by SBAlphaBeta will make much more sense.

@subsection statemutability_sec Should I use mutable or immutable states?

It's a good question. They each have their own pros and cons.

@li If you go with mutable states, the moves you return from -movesAvailable must contain enough information to undo the effects of a move; with immutable states they don't.

@li With immutable states you have to make a complete copy of the entire state, which can be expensive, but on the other hand undo is extremely cheap: you just pop the stack.

@li Many optimisations should be possible when using immutable states.

@li Immutable states offer the possibility of loop detection (not implemented yet), which can be 

@li Implementation of immutable states is simpler is several cases (no need to implement undo).

@section moves_sec Notes on moves

Moves does not have to be of any particular class (both NSArray and NSDictionary are good candidates), but they must implement the following two methods:

@li -(BOOL)isEqual:(id)object;
@li -(unsigned)hash;

Use NSNull instances for pass moves, if your game allows passing.

Though not <em>required</em>, it is advisable that you also override -description. This way some of the exceptions thrown by SBAlphaBeta will make much more sense.

*/

@implementation SBAlphaBeta

#pragma mark Creation & Cleanup

- (id)init
{
    [NSException raise:@"abort"
                format:@"Use -initWithState: instead"];
    return nil;
}

/** Initialise an SBAlphaBeta object with a starting state. */
- (id)initWithState:(id)this
{
    if (self = [super init]) {
        if ([this conformsToProtocol:@protocol(SBMutableAlphaBetaState)]) {
            mutableStates = YES;
        
        } else if ([this conformsToProtocol:@protocol(SBAlphaBetaState)]) {
            mutableStates = NO;

        } else {
            [NSException raise:@"not-a-state"
                        format:@"State %@ lacks necessary methods"];
        }
        stateHistory = [[NSMutableArray arrayWithObject:this] retain];
        moveHistory = [NSMutableArray new];
    }
    return self;
}

/** Shortcut for calling alloc & initWithState:. */
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
    if (mutableStates) {
        [[self currentState] transformWithMove:m];
    
    } else {
        id state = [[self currentState] stateByApplyingMove:m];
        [stateHistory addObject:state];
    }
    [moveHistory addObject:m];
    return [self currentState];
}

- (id)undo
{
    if (mutableStates) {
        [[self currentState] undoTransformWithMove:[self lastMove]];

    } else {
        if ([moveHistory count] + 1 != [stateHistory count])
            [NSException raise:@"corruption"
                        format:@"Corruption: state & move count disagrees"];
        [stateHistory removeLastObject];
    }
    
    /* in both cases we now remove the last move */
    [moveHistory removeLastObject];
    return [self currentState];
}

- (double)abWithAlpha:(double)alpha beta:(double)beta plyLeft:(unsigned)ply
{
    NSArray *mvs = [self movesAvailable];
    
    if (![mvs count])
        foundEnd = YES;
    if (![mvs count] || ply <= 0)
        return [self currentFitness];
    
    id m, iter = [mvs objectEnumerator];
    while (m = [iter nextObject]) {
        [self move:m];
        double sc = -[self abWithAlpha:-beta beta:-alpha plyLeft:ply-1];
        alpha = alpha > sc ? alpha : sc;
        [self undo];
    }
    
    return alpha;
}

#pragma mark Search methods

/**
Performs a fixed-depth search to the given @p ply.
Returns the best move found.
 */
- (id)moveFromSearchWithPly:(unsigned)ply
{
    double alpha = -INFINITY;
    double beta  = +INFINITY;
    
    id best = nil;
    NSArray *mvs = [self movesAvailable];
    NSEnumerator *iter = [mvs objectEnumerator];
    for (id m; m = [iter nextObject]; ) {
        
        [self move:m];
        double sc = -[self abWithAlpha:-beta beta:-alpha plyLeft:ply-1];
        if (sc > alpha) {
            alpha = sc;
            best = m;
        }
        [self undo];
    }
    
    return best;
}

/**
Performs a fixed-depth search to the given @p ply and applies the best move found.
 */
- (id)applyMoveFromSearchWithPly:(unsigned)ply
{
    id best = [self moveFromSearchWithPly:ply];
    return best ? [self applyMove:best] : nil;
}

/**
Performs an iterative search for up to @p interval seconds.
Return the best move found.

Fractional seconds are supported, so an interval of 0.3 makes for a
search that lasts up to 300 milliseconds.
 */
- (id)moveFromSearchWithInterval:(NSTimeInterval)interval
{
    id best = nil;
    
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:interval/2.0];

    NSArray *mvs = [self movesAvailable];
    for (unsigned ply = 1;; ply++) {

        unsigned leafCount = 0;
        id bestAtThisPly = nil;

        double alpha = -INFINITY;
        double beta  = +INFINITY;

        /** @todo When searching to ply N+1, order the moves so we
            search the most promising one from search to ply N.
            This has the potential of speeding up search a lot.
         */
        NSEnumerator *iter = [mvs objectEnumerator];

        for (id m; m = [iter nextObject]; ) {
        
            /* Reset the 'reached a leaf state' indicator. */
            foundEnd = NO;

            /* Check if we have any time left. */
            if ([date compare:[NSDate date]] < 0)
                goto time_is_up;

            [self move:m];
            double sc = -[self abWithAlpha:-beta beta:-alpha plyLeft:ply-1];
            if (sc > alpha) {
                alpha = sc;
                bestAtThisPly = m;
            }
            [self undo];
            
            if (foundEnd)
                leafCount++;
        }

        /* If we got here then we should replace the current best move,
           since we just finished a search to a deeper level than before.
         */
        best = bestAtThisPly;
        plyReached = ply;

        /* If we found a leaf state for every move, then we're done. We
           don't need to search deeper.
         */
        if (leafCount == [mvs count])
            break;
            
    }

time_is_up:
    return best;
}

/**
Performs an iterative search for up to @p interval seconds and applies the best move found.

Fractional seconds are supported, so an interval of 0.3 makes for a
search that lasts up to 300 milliseconds.
 */
- (id)applyMoveFromSearchWithInterval:(NSTimeInterval)interval
{
    id best = [self moveFromSearchWithInterval:interval];
    return best ? [self applyMove:best] : nil;
}    

#pragma mark Methods

/**
Apply the given move to the current state.
Returns the new current state.
*/
- (id)applyMove:(id)m
{
    id moves = [self movesAvailable];
    if (NSNotFound == [moves indexOfObject:m]) {
        /* Check that move is in the current allowed move list */
        [NSException raise:@"illegalmove"
                    format:@"%@ is not a legal move", m];
    }

    return [self move:m];
}


/**
Undo one position from the given state.
Returns the new current state.
*/
- (id)undoLastMove
{
    if (![moveHistory count]) {
        [NSException raise:@"undo"
                    format:@"No moves to undo"];
    }
    return [self undo];
}

/** Returns the current state. */
- (id)currentState
{
    return [stateHistory lastObject];
}

/** Returns the last move that was applied. */
- (id)lastMove
{
    return [moveHistory lastObject];
}

/** Returns a count of the number of moves since the initial state. */
- (unsigned)countMoves
{
    return [moveHistory count];
}

/**
Returns 1 or 2, depending on whose turn it is to move.
Player "1" is arbitrarily defined to be the player whose turn it is to play at the start of the game, which is not necessarily the same as the state itself thinks of as player 1 (if it thinks of the players in those terms; it may use @"a" or @"b" instead).
*/
- (unsigned)playerTurn
{
    return ([self countMoves] % 2) + 1;
}

/**
Returns 1 or 2 for the winning player, or 0 if the game ended in a draw.
*/
- (unsigned)winner
{
    double score = [[self currentState] endStateScore];
    if (!score)
        return 0;
    unsigned player = [self playerTurn];
    return score > 0 ? player : 3 - player;
}


/** Returns true if the game is finished, false otherwise. */
- (BOOL)isGameOver
{
    NSArray *a = [self movesAvailable];
    return [a count] ? NO : YES;
}

/**
Return the depth reached by the last iterative search. The returned value is undefined if no iterative search has been executed yet.
 */
- (unsigned)plyReachedForSearch
{
    return plyReached;
}

/** Returns true if the current player has no option but to pass. */
- (BOOL)currentPlayerMustPass
{
    id mvs = [self movesAvailable];
    if (mvs && [mvs count] == 1)
        if ([[mvs lastObject] isKindOfClass:[NSNull class]])
            return YES;
    return NO;
}

#pragma mark Simple forwarders

/** Returns currentFitness from the current state. */
- (double)currentFitness
{
    return [[self currentState] currentFitness];
}

/** Returns available moves from the current state. */
- (NSArray *)movesAvailable
{
    return [[self currentState] movesAvailable];
}


@end

