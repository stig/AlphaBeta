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

- (void)testFitness
{
    STAssertTrue([st player] == 1, nil);
    STAssertEqualObjects([st description], @"000 000 000", nil);
    STAssertEquals([ab currentFitness], (double)0.0, nil);
    [ab applyMove:[self moveWithCol:0 andRow:0]];
    STAssertEqualsWithAccuracy([ab currentFitness], (double)-3.0, 0.0001, nil);
    [ab applyMove:[self moveWithCol:0 andRow:1]];
    STAssertEqualsWithAccuracy([ab currentFitness], (double)1.0, 0.0001, nil);
    [ab applyMove:[self moveWithCol:1 andRow:1]];
    STAssertEqualsWithAccuracy([ab currentFitness], (double)-7.0, 0.0001, nil);
}

- (void)testState
{
    STAssertTrue([st player] == 1, nil);
    STAssertEqualObjects([st description], @"000 000 000", nil);
    
    int i;
    for (i = 9; i > 2; i--) {
        STAssertNotNil(moves = [ab movesAvailable], nil);
        STAssertEquals([moves count], (unsigned)i, nil);
        id m = [moves objectAtIndex:0];
        st = [ab applyMove:m];
        STAssertTrue([st player] == i % 2 + 1, @"expected(%d): %d, got: %d", i, i % 2 + 1, [st player]);
        
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
}

- (void)testInit
{
    STAssertNotNil(ab, nil);
    STAssertTrue([ab currentState] == st, @"did get expected state back");
    STAssertEquals([ab countMoves], (unsigned)0, nil);
    STAssertEquals([ab isGameOver], (BOOL)NO, nil);
}

- (void)testFullRun
{
    STAssertEqualObjects([[ab applyMoveFromSearchWithPly:9] description], @"100 000 000", nil);
    STAssertEqualObjects([[ab applyMoveFromSearchWithPly:9] description], @"100 020 000", nil);
    STAssertEqualObjects([[ab applyMoveFromSearchWithPly:9] description], @"100 120 000", nil);
    
    STAssertEqualObjects([[ab applyMoveFromSearchWithPly:9] description], @"100 120 200", nil);
    STAssertEqualObjects([[ab applyMoveFromSearchWithPly:9] description], @"101 120 200", nil);
    STAssertEqualObjects([[ab applyMoveFromSearchWithPly:9] description], @"121 120 200", nil);
    
    STAssertEqualObjects([[ab applyMoveFromSearchWithPly:9] description], @"121 120 210", nil);
    STAssertEqualObjects([[ab applyMoveFromSearchWithPly:9] description], @"121 122 210", nil);
    STAssertEqualObjects([[ab applyMoveFromSearchWithPly:9] description], @"121 122 211", nil);
}

- (void)testIterativeRun
{
    unsigned i;
    for (i = 0; i < 9; i++) {
        id m1, m2;
        STAssertEquals([ab countMoves], i, nil);
        STAssertNoThrow(m1 = [ab moveFromSearchWithInterval:0.3], nil);
        STAssertTrue([ab plyReachedForSearch] > 0, nil);
        STAssertTrue([ab plyReachedForSearch] < 10, nil);
        STAssertNoThrow(m2 = [ab moveFromSearchWithPly:[ab plyReachedForSearch]], nil);
        STAssertEqualObjects([m1 description], [m2 description], @"%@", [ab currentState]);
        STAssertNotNil([ab applyMove:m2], nil);
    }
    STAssertThrows([ab applyMoveFromSearchWithInterval:1.0], nil);
    STAssertEquals([ab countMoves], (unsigned)9, nil);
}

- (void)testFindMoves
{
    STAssertNil([ab lastMove], nil);
    
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
