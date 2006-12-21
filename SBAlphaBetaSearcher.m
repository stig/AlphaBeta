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

#import "SBAlphaBetaSearcher.h"

@implementation SBAlphaBetaFixedSearcher

- (float)abWithAlpha:(float)alpha beta:(float)beta plyLeft:(unsigned)ply
{
    NSArray *mvs = [state movesAvailable];

    if (![mvs count])
        foundEnd = YES;
    if (![mvs count] || ply <= 0)
        return [state currentFitness];

    id m, iter = [mvs objectEnumerator];
    while (m = [iter nextObject]) {
        [state applyMove:m];
        float sc = -[self abWithAlpha:-beta beta:-alpha plyLeft:ply-1];
        alpha = alpha > sc ? alpha : sc;
        [state undoMove:m];
    }
    
    return alpha;
}

- (void)dealloc
{
    [state release];
    [super dealloc];
}

- (BOOL)foundEnd
{
    return foundEnd;
}

- (void)setState:(id)this
{
    if (state != this) {
        [state release];
        state = [this retain];
    }
}

- (id)moveFromState:(id)this withLimit:(id)limit
{
    [self setState:this];

    float alpha = -INFINITY;
    float beta  = +INFINITY;
    int reachedEnd = 0;
    
    id m, best = nil;
    NSArray *mvs = [state movesAvailable];
    NSEnumerator *iter = [mvs objectEnumerator];
    while (m = [iter nextObject]) {
        foundEnd = NO;

        [state applyMove:m];
        float sc = -[self abWithAlpha:-beta beta:-alpha plyLeft:[limit intValue]-1];
        if (sc > alpha) {
            alpha = sc;
            best = m;
        }
        [state undoMove:m];

        if (foundEnd)
            reachedEnd++;
    }
    if (reachedEnd == [mvs count])
        foundEnd = YES;

    return best;
}
@end

@implementation SBAlphaBetaIterativeSearcher

- (id)init
{
    if (self = [super init]) {
        reachedPly = -1;
    }
    return self;
}

- (int)reachedPly
{
    return reachedPly;
}

- (id)moveFromState:(id)theState withLimit:(id)limit
{
    id best = nil;
    int ply;
    
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:[limit doubleValue]/3.0];
    for (ply = 1;; ply++) {
        if ([date compare:[NSDate date]] < 0 || [self foundEnd])
            break;

        best = [super moveFromState:theState withLimit:[NSNumber numberWithInt:ply]];
        reachedPly = ply;
    }
    
    return best;
}

@end
    
