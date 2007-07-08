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

#import "TTTUnit.h"

@implementation TTTUnit

- (void)setUp
{
    st = [TTTState new];
    ab = [SBAlphaBeta newWithState:st];
    moves = nil;
}

- (void)tearDown
{
    [ab release];
    [st release];
}

- (id)moveWithCol:(int)c andRow:(int)r
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInt: r], @"row",
        [NSNumber numberWithInt: c], @"col",
        nil];
}

- (void)testAvailMovesAndFitness
{
    id cs = [ab currentState];
    STAssertEqualObjects([cs description], @"000 000 000", nil);
    STAssertEquals([[cs movesAvailable] count], (unsigned)9, nil);
    STAssertEqualsWithAccuracy([cs currentFitness], (double)0.0, 0.000001, nil);
    
    [ab applyMove:[self moveWithCol:0 andRow:0]];
    [ab applyMove:[self moveWithCol:1 andRow:0]];
    [ab applyMove:[self moveWithCol:0 andRow:1]];
    [ab applyMove:[self moveWithCol:2 andRow:0]];
    [ab applyMove:[self moveWithCol:0 andRow:2]];
    
    cs = [ab currentState];
    STAssertEqualObjects([cs description], @"122 100 100", nil);
    STAssertEquals([[cs movesAvailable] count], (unsigned)0, nil);
    STAssertEqualsWithAccuracy([cs currentFitness], (double)-901.0, 0.000001, nil);
    
    [ab undoLastMove];
    [ab undoLastMove];
    [ab applyMove:[self moveWithCol:0 andRow:2]]; // player 2
    [ab applyMove:[self moveWithCol:2 andRow:0]];
    [ab applyMove:[self moveWithCol:1 andRow:1]];
    [ab applyMove:[self moveWithCol:2 andRow:1]];

    cs = [ab currentState];
    STAssertEqualObjects([cs description], @"121 121 200", nil);
    STAssertEquals([[cs movesAvailable] count], (unsigned)2, nil);
    STAssertEqualsWithAccuracy([cs currentFitness], (double)1.0, 0.000001, nil);

    [ab applyMove:[self moveWithCol:2 andRow:2]];
    [ab applyMove:[self moveWithCol:1 andRow:2]];
    
    cs = [ab currentState];
    STAssertEqualObjects([cs description], @"121 121 212", nil);
    STAssertEquals([[cs movesAvailable] count], (unsigned)0, nil);
    STAssertEqualsWithAccuracy([cs currentFitness], (double)0.0, 0.000001, nil);
    
}

- (void)testAvailMoves
{
    STAssertNotNil(moves = [st movesAvailable], nil);
    STAssertEquals([moves count], (unsigned)9, nil);
    int i;
    for (i = 0; i < 9; i++) {
        id m2;
        switch (i) {
            case 0: m2 = [self moveWithCol:0 andRow:0]; break;
            case 1: m2 = [self moveWithCol:0 andRow:1]; break;
            case 2: m2 = [self moveWithCol:0 andRow:2]; break;
            case 3: m2 = [self moveWithCol:1 andRow:0]; break;
            case 4: m2 = [self moveWithCol:1 andRow:1]; break;
            case 5: m2 = [self moveWithCol:1 andRow:2]; break;
            case 6: m2 = [self moveWithCol:2 andRow:0]; break;
            case 7: m2 = [self moveWithCol:2 andRow:1]; break;
            case 8: m2 = [self moveWithCol:2 andRow:2]; break;
        }
        id m = [moves objectAtIndex:i];
        STAssertEqualObjects(m, m2, nil);
        st = [ab applyMove:m];
        STAssertTrue(![[st description] isEqualToString:@"000 000 000"], nil);
        st = [ab undoLastMove];
        STAssertEqualObjects([st description], @"000 000 000", nil);
    }
}

- (void)testLastMove
{
    STAssertNil([ab lastMove], nil);

    [ab applyMove:[self moveWithCol:0 andRow:0]];
    STAssertNotNil([ab lastMove], nil);

    [ab undoLastMove];
    STAssertNil([ab lastMove], nil);
}

- (void)testCountMoves
{
    STAssertEquals([ab countMoves], (unsigned)0, nil);

    [ab applyMove:[self moveWithCol:0 andRow:0]];
    STAssertEquals([ab countMoves], (unsigned)1, nil);
    
    [ab applyMove:[self moveWithCol:0 andRow:1]];
    STAssertEquals([ab countMoves], (unsigned)2, nil);
    
    [ab undoLastMove];
    STAssertEquals([ab countMoves], (unsigned)1, nil);    
}

- (void)testPlayerTurn
{
    STAssertEquals(st->player, (unsigned)1, nil);
    STAssertEquals([ab playerTurn], (unsigned)1, nil);
    
    st = [ab applyMove:[self moveWithCol:0 andRow:0]];
    STAssertEquals(st->player, (unsigned)2, nil);
    STAssertEquals([ab playerTurn], (unsigned)2, nil);
    
    st = [ab applyMove:[self moveWithCol:0 andRow:1]];
    STAssertEquals(st->player, (unsigned)1, nil);
    STAssertEquals([ab playerTurn], (unsigned)1, nil);

    st = [ab undoLastMove];
    STAssertEquals(st->player, (unsigned)2, nil);
    STAssertEquals([ab playerTurn], (unsigned)2, nil);
}

- (void)testFitness
{
    STAssertEquals([ab currentFitness], (double)0.0, nil);

    [ab applyMove:[self moveWithCol:0 andRow:0]];
    STAssertEqualsWithAccuracy([ab currentFitness], (double)-3.0, 0.0001, nil);

    [ab applyMove:[self moveWithCol:0 andRow:1]];
    STAssertEqualsWithAccuracy([ab currentFitness], (double)1.0, 0.0001, nil);

    [ab applyMove:[self moveWithCol:1 andRow:1]];
    STAssertEqualsWithAccuracy([ab currentFitness], (double)-7.0, 0.0001, nil);
}

- (void)testStateAndMoves
{
    STAssertEqualObjects([[ab currentState] description], @"000 000 000", nil);

    unsigned i;
    for (i = 9; i > 2; i--) {
        STAssertNotNil(moves = [ab movesAvailable], nil);
        STAssertEquals([moves count], i, nil);
        id m = [moves objectAtIndex:0];
        st = [ab applyMove:m];
        
        id s = nil;
        switch (i) {
            case 9: s = @"100 000 000"; break;
            case 8: s = @"100 200 000"; break;
            case 7: s = @"100 200 100"; break;
            case 6: s = @"120 200 100"; break;
            case 5: s = @"120 210 100"; break;
            case 4: s = @"120 210 120"; break;
            case 3: s = @"121 210 120"; break;
        }
        STAssertEqualObjects([st description], s, @"got(%d): %@", i, [st description]);
    }
    STAssertEquals([ab winner], (unsigned)1, nil);
}

- (void)testInit
{
    STAssertNotNil(ab, nil);
    STAssertTrue([ab currentState] == st, @"did get expected state back");
    STAssertEquals([ab countMoves], (unsigned)0, nil);
    STAssertEquals([ab isGameOver], (BOOL)NO, nil);
}

- (void)testFullRunReachesDraw
{
    id states = [NSArray arrayWithObjects:
        @"100 000 000", @"100 020 000", @"100 120 000",
        @"100 120 200", @"101 120 200", @"121 120 200",
        @"121 120 210", @"121 122 210", @"121 122 211",
        nil];
    
    for (int i = 0; [ab applyMoveFromSearchWithPly:9]; i++) {
        id s = [[ab currentState] description];
        STAssertEqualObjects(s, [states objectAtIndex:i], nil);
    }
    
    /* Turns out the only winning move is not to play. */
    STAssertEquals([ab winner], (unsigned)0, @"reached a draw");
}

- (void)testIterativeRun
{
    for (unsigned i = 0; i < 9; i++) {
        id m1, m2;
        STAssertEquals([ab countMoves], i, nil);
        STAssertNoThrow(m1 = [ab moveFromSearchWithInterval:0.3], nil);
        STAssertTrue([ab plyReachedForSearch] > 0, nil);
        STAssertTrue([ab plyReachedForSearch] < 10, nil);
        STAssertNoThrow(m2 = [ab moveFromSearchWithPly:[ab plyReachedForSearch]], nil);
        STAssertEqualObjects([m1 description], [m2 description], @"%@", [ab currentState]);
        STAssertNotNil([ab applyMove:m2], nil);
    }
    STAssertNil([ab applyMoveFromSearchWithInterval:1.0], nil);
    STAssertEquals([ab countMoves], (unsigned)9, nil);
}

- (void)testFixedPlySearch
{
    STAssertNotNil([ab applyMoveFromSearchWithPly:1], nil);
    STAssertEqualObjects([[ab currentState] description], @"000 010 000", nil);
    STAssertEquals([ab countMoves], (unsigned)1, nil);
    STAssertEqualsWithAccuracy([ab currentFitness], (double)-4.0, 0.1, nil);
    STAssertEqualObjects([ab lastMove], [self moveWithCol:1 andRow:1], nil);
    
    [ab applyMoveFromSearchWithInterval:3];
    STAssertEqualObjects([[ab currentState] description], @"200 010 000", nil);
    STAssertEquals([ab countMoves], (unsigned)2, nil);
    STAssertEqualsWithAccuracy([ab currentFitness], (double)1.0, 0.1, nil);
    STAssertEqualObjects([ab lastMove], [self moveWithCol:0 andRow:0], nil);
}

@end
