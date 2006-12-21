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
#import <TTT/TTTMove.h>

@implementation TTTUnit

- (void)setUp
{
    ab = [SBAlphaBeta new];
    st = [TTTState new];
    moves = nil;
}

- (void)tearDown
{
    [ab release];
    [st release];
}

- (void)testMove
{
    id move = [TTTMove moveWithCol:2 andRow:1];
    STAssertTrue([move col] == 2, nil);
    STAssertTrue([move row] == 1, nil);
    STAssertEqualObjects([move description], @"(2,1)", nil);
}

- (void)testAvailMovesAndFitness
{
    [ab setState:st];
    
    id cs = [ab state];
    STAssertEqualObjects([cs description], @"000 000 000", nil);
    STAssertEquals([[cs movesAvailable] count], (unsigned)9, nil);
    STAssertEqualsWithAccuracy([cs currentFitness], (float)0.0, 0.000001, nil);
    
    [ab move:[TTTMove moveWithCol:0 andRow:0]];
    [ab move:[TTTMove moveWithCol:1 andRow:0]];
    [ab move:[TTTMove moveWithCol:0 andRow:1]];
    [ab move:[TTTMove moveWithCol:2 andRow:0]];
    [ab move:[TTTMove moveWithCol:0 andRow:2]];
    
    cs = [ab state];
    STAssertEqualObjects([cs description], @"122 100 100", nil);
    STAssertEquals([[cs movesAvailable] count], (unsigned)0, nil);
    STAssertEqualsWithAccuracy([cs currentFitness], (float)-901.0, 0.000001, nil);
    
    [ab undo];
    [ab undo];
    [ab move:[TTTMove moveWithCol:0 andRow:2]]; // player 2
    [ab move:[TTTMove moveWithCol:2 andRow:0]];
    [ab move:[TTTMove moveWithCol:1 andRow:1]];
    [ab move:[TTTMove moveWithCol:2 andRow:1]];

    cs = [ab state];
    STAssertEqualObjects([cs description], @"121 121 200", nil);
    STAssertEquals([[cs movesAvailable] count], (unsigned)2, nil);
    STAssertEqualsWithAccuracy([cs currentFitness], (float)1.0, 0.000001, nil);

    [ab move:[TTTMove moveWithCol:2 andRow:2]];
    [ab move:[TTTMove moveWithCol:1 andRow:2]];
    
    cs = [ab state];
    STAssertEqualObjects([cs description], @"121 121 212", nil);
    STAssertEquals([[cs movesAvailable] count], (unsigned)0, nil);
    STAssertEqualsWithAccuracy([cs currentFitness], (float)0.0, 0.000001, nil);
    
}

- (void)testAvailMoves
{
    STAssertNotNil(moves = [st movesAvailable], nil);
    STAssertEquals([moves count], (unsigned)9, nil);
    int i;
    for (i = 0; i < 9; i++) {
        id s;
        switch (i) {
            case 0: s = @"(0,0)"; break;
            case 1: s = @"(0,1)"; break;
            case 2: s = @"(0,2)"; break;
            case 3: s = @"(1,0)"; break;
            case 4: s = @"(1,1)"; break;
            case 5: s = @"(1,2)"; break;
            case 6: s = @"(2,0)"; break;
            case 7: s = @"(2,1)"; break;
            case 8: s = @"(2,2)"; break;
        }
        id m = [moves objectAtIndex:i];
        STAssertEqualObjects([m description], s, nil);
        [st applyMove:m];
        STAssertTrue(![[st description] isEqualToString:@"000 000 000"], nil);
        [st undoMove:m];
        STAssertEqualObjects([st description], @"000 000 000", nil);
    }
}

- (void)testFitness
{
    STAssertTrue([st player] == 1, nil);
    STAssertEqualObjects([st description], @"000 000 000", nil);
    STAssertEquals([st currentFitness], (float)0.0, nil);
    [st applyMove:[TTTMove moveWithCol:0 andRow:0]];
    STAssertEqualsWithAccuracy([st currentFitness], (float)-3.0, 0.0001, nil);
    [st applyMove:[TTTMove moveWithCol:0 andRow:1]];
    STAssertEqualsWithAccuracy([st currentFitness], (float)1.0, 0.0001, nil);
    [st applyMove:[TTTMove moveWithCol:1 andRow:1]];
    STAssertEqualsWithAccuracy([st currentFitness], (float)-7.0, 0.0001, nil);
}

- (void)testState
{
    STAssertTrue([st player] == 1, nil);
    STAssertEqualObjects([st description], @"000 000 000", nil);
    
    int i;
    for (i = 9; i > 2; i--) {
        STAssertNotNil(moves = [st movesAvailable], nil);
        STAssertEquals([moves count], (unsigned)i, nil);
        id m = [moves objectAtIndex:0];
        [st applyMove:m];
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

- (void)testInitAndSetState
{
    STAssertNotNil(ab, @"got nil back");
    STAssertNil([ab state], @"did not get expected state back");
    [ab setState:st];
    STAssertTrue([ab state] == st, @"did not get expected state back");
    STAssertThrows([ab setState:nil], @"can set state when already set");
    STAssertThrows([ab setState:st], @"can set state when already set");
    STAssertEquals([ab countMoves], (unsigned)0, nil);
    STAssertEquals([ab isGameOver], (BOOL)NO, nil);
}

- (void)testMaxPly
{
    STAssertEquals([ab maxPly], (unsigned)3, nil);
    [ab setMaxPly:5];
    STAssertEquals([ab maxPly], (unsigned)5, nil);
}

- (void)testFullRun
{
    [ab setMaxPly:9];
    [ab setState:st];

    STAssertEqualObjects([[ab fixedDepthSearch] description], @"100 000 000", nil);
    STAssertEqualObjects([[ab fixedDepthSearch] description], @"100 020 000", nil);
    STAssertEqualObjects([[ab fixedDepthSearch] description], @"100 120 000", nil);
    
    STAssertEqualObjects([[ab fixedDepthSearch] description], @"100 120 200", nil);
    STAssertEqualObjects([[ab fixedDepthSearch] description], @"101 120 200", nil);
    STAssertEqualObjects([[ab fixedDepthSearch] description], @"121 120 200", nil);
    
    STAssertEqualObjects([[ab fixedDepthSearch] description], @"121 120 210", nil);
    STAssertEqualObjects([[ab fixedDepthSearch] description], @"121 122 210", nil);
    STAssertEqualObjects([[ab fixedDepthSearch] description], @"121 122 211", nil);
    
    STAssertEquals([ab winner], 0, @"draw (as you would expect)");
}

- (void)testIterativeRun
{
    [ab setState:st];
    STAssertEquals([ab reachedPly], (int)-1, nil);
    int i;
    for (i = 0; i < 9; i++) {
        STAssertNoThrow([ab iterativeSearch], nil);
        STAssertTrue([ab reachedPly] > 0, nil);
        STAssertTrue([ab reachedPly] < 10, nil);
        id m = [ab lastMove];
        [ab undo];
        STAssertNoThrow([ab fixedDepthSearchWithPly:[ab reachedPly]], nil);
        STAssertEqualObjects([[ab lastMove] description], [m description], nil);
    }
    STAssertThrows([ab iterativeSearch], @"didn't throw?");
    STAssertEquals([ab countMoves], (unsigned)9, nil);
}

- (void)testFindMoves
{
    [ab setMaxPly:2];   // states below assumes a ply 2 search
    [ab setState:st];
    STAssertNil([ab lastMove], nil);
    
    STAssertNotNil([ab fixedDepthSearch], nil);
    STAssertEqualObjects([[ab state] description], @"000 010 000", nil);
    STAssertEquals([ab countMoves], (unsigned)1, nil);
    STAssertEqualsWithAccuracy([[ab state] currentFitness], (float)-4.0, 0.1, nil);
    STAssertEqualsWithAccuracy([ab currentFitness], (float)-4.0, 0.1, nil);
    STAssertEqualObjects([[ab lastMove] description], @"(1,1)", nil);
    
    [ab fixedDepthSearch];
    STAssertEqualObjects([[ab state] description], @"200 010 000", nil);
    STAssertEquals([ab countMoves], (unsigned)2, nil);
    STAssertEqualsWithAccuracy([[ab state] currentFitness], (float)1.0, 0.1, nil);
    STAssertEqualsWithAccuracy([ab currentFitness], (float)1.0, 0.1, nil);
    STAssertEqualObjects([[ab lastMove] description], @"(0,0)", nil);
}

@end
