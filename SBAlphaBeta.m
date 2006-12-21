/*
Copyright (C) 2006 Stig Brautaset. All rights reserved.

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

#import <SBAlphaBeta/SBAlphaBeta.h>
#import <SBAlphaBeta/SBAlphaBetaSearcher.h>

/** 
Generic implementation of the Alpha-Beta algorithm.

The SBAlphaBeta class is a generic implementation of the Alpha-Beta
algorithm (also known as 'minimax search with alpha-beta pruning').
*/

@implementation SBAlphaBeta

- (id)init
{
    if (self = [super init]) {
        [self setMaxPly:3];
        [self setMaxTime:0.3];
        reachedPly = -1;
    }
    return self;
}

/** Initialise an SBAlphaBeta object with a starting state */
- (id)initWithState:(id)st
{
    if (self = [self init]) {
        [self setState:st];
    }
    return self;
}

/** Search to the default fixed depth */
- (id)fixedDepthSearch
{
    return [self fixedDepthSearchWithPly:[self maxPly]];
}

/** Search to the specified fixed depth */
- (id)fixedDepthSearchWithPly:(unsigned)depth
{
    [self setSearcher: [[SBAlphaBetaFixedSearcher new] autorelease]];
    return [self searchWithLimit:[NSNumber numberWithInt:depth]];
}

/** Perform an iterative search for the default time */
- (id)iterativeSearch
{
    return [self iterativeSearchWithTime:[self maxTime]];
}

/** Perform an iterative search for the given time */
- (id)iterativeSearchWithTime:(NSTimeInterval)time
{
    [self setSearcher: [[SBAlphaBetaIterativeSearcher new] autorelease]];
    id st = [self searchWithLimit:[NSNumber numberWithDouble:time]];
    reachedPly = [searcher reachedPly];
    return st;
}

/** Return the ply (depth) reached by the last iterative search, or -1 if no
  iterative search has been performed yet. */
- (int)reachedPly
{
    return reachedPly;
}

/** Return the default depth of search for fixed-depth searches. */
- (unsigned)maxPly
{
    return maxPly;
}

/** Set the default depth of search for fixed-depth searches. */
- (void)setMaxPly:(unsigned)ply
{
    maxPly = ply;
}

/** Return the default time to search for when doing an iterative search. */
- (NSTimeInterval)maxTime
{
    return maxTime;
}

/** Set the default time to search for when doing an iterative search. */
- (void)setMaxTime:(NSTimeInterval)time
{
    maxTime = time;
}

@end

