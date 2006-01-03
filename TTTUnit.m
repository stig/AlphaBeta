//
//  TTTUnit.m
//  AlphaBeta
//
//  Created by Stig Brautaset on 11/12/2005.
//  Copyright 2005 Stig Brautaset. All rights reserved.
//

#import "TTTUnit.h"
#import "TTTMove.h"

@implementation TTTUnit

- (void)setUp
{
    ab = [[AlphaBeta alloc] init];
    st = [[TTTState alloc] init];
    moves = nil;
}

- (void)tearDown
{
    [ab release];
    [st release];
}

- (void)testMove
{
    id move = [[TTTMove alloc] initWithCol:2 andRow:1];
    STAssertTrue([move col] == 2, nil);
    STAssertTrue([move row] == 1, nil);
    STAssertTrue([[move string] isEqualToString:@"21"], nil);
}

- (void)testAvailMovesAndFitness
{
    [ab setState:st];
    
    id cs = [ab currentState];
    STAssertEqualObjects([cs string], @"000 000 000", nil);
    STAssertEquals([[cs listAvailableMoves] count], (unsigned)9, nil);
    STAssertEqualsWithAccuracy([cs fitness], (float)0.0, 0.000001, nil);
    
    [ab move:[TTTMove newWithCol:0 andRow:0]];
    [ab move:[TTTMove newWithCol:1 andRow:0]];
    [ab move:[TTTMove newWithCol:0 andRow:1]];
    [ab move:[TTTMove newWithCol:2 andRow:0]];
    [ab move:[TTTMove newWithCol:0 andRow:2]];
    
    cs = [ab currentState];
    STAssertEqualObjects([cs string], @"122 100 100", nil);
    STAssertEquals([[cs listAvailableMoves] count], (unsigned)0, nil);
    STAssertEqualsWithAccuracy([cs fitness], (float)-901.0, 0.000001, nil);
    
    [ab undo];
    [ab undo];
    [ab move:[TTTMove newWithCol:0 andRow:2]]; // player 2
    [ab move:[TTTMove newWithCol:2 andRow:0]];
    [ab move:[TTTMove newWithCol:1 andRow:1]];
    [ab move:[TTTMove newWithCol:2 andRow:1]];

    cs = [ab currentState];
    STAssertEqualObjects([cs string], @"121 121 200", nil);
    STAssertEquals([[cs listAvailableMoves] count], (unsigned)2, nil);
    STAssertEqualsWithAccuracy([cs fitness], (float)1.0, 0.000001, nil);

    [ab move:[TTTMove newWithCol:2 andRow:2]];
    [ab move:[TTTMove newWithCol:1 andRow:2]];
    
    cs = [ab currentState];
    STAssertEqualObjects([cs string], @"121 121 212", nil);
    STAssertEquals([[cs listAvailableMoves] count], (unsigned)0, nil);
    STAssertEqualsWithAccuracy([cs fitness], (float)0.0, 0.000001, nil);
    
}

- (void)testAvailMoves
{
    STAssertNotNil(moves = [st listAvailableMoves], nil);
    STAssertEquals([moves count], (unsigned)9, nil);
    int i;
    for (i = 0; i < 9; i++) {
        id s;
        switch (i) {
            case 0: s = @"00"; break;
            case 1: s = @"01"; break;
            case 2: s = @"02"; break;
            case 3: s = @"10"; break;
            case 4: s = @"11"; break;
            case 5: s = @"12"; break;
            case 6: s = @"20"; break;
            case 7: s = @"21"; break;
            case 8: s = @"22"; break;
        }
        id m = [moves objectAtIndex:i];
        STAssertEqualObjects([m string], s, nil);
        [st applyMove:m];
        STAssertTrue(![[st string] isEqualToString:@"000 000 000"], nil);
        [st undoMove:m];
        STAssertEqualObjects([st string], @"000 000 000", nil);
    }
}

- (void)testFitness
{
    STAssertTrue([st player] == 1, nil);
    STAssertEqualObjects([st string], @"000 000 000", nil);
    STAssertEquals([st fitness], (float)0.0, nil);
    [st applyMove:[[TTTMove alloc] initWithCol:0 andRow:0]];
    STAssertEqualsWithAccuracy([st fitness], (float)-3.0, 0.0001, nil);
    [st applyMove:[[TTTMove alloc] initWithCol:0 andRow:1]];
    STAssertEqualsWithAccuracy([st fitness], (float)1.0, 0.0001, nil);
    [st applyMove:[[TTTMove alloc] initWithCol:1 andRow:1]];
    STAssertEqualsWithAccuracy([st fitness], (float)-7.0, 0.0001, nil);
}

- (void)testState
{
    STAssertTrue([st player] == 1, nil);
    STAssertEqualObjects([st string], @"000 000 000", nil);
    
    int i;
    for (i = 9; i > 2; i--) {
        STAssertNotNil(moves = [st listAvailableMoves], nil);
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
        STAssertEqualObjects([st string], s, @"got(%d): %@", i, [st string]);
    }
}

- (void)testInitAndSetState
{
    STAssertNotNil(ab, @"got nil back");
    STAssertNil([ab currentState], @"did not get expected state back");
    [ab setState:st];
    STAssertTrue([ab currentState] == st, @"did not get expected state back");
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

    STAssertEqualObjects([[ab aiMove] string], @"100 000 000", nil);
    STAssertEqualObjects([[ab aiMove] string], @"100 020 000", nil);
    STAssertEqualObjects([[ab aiMove] string], @"100 120 000", nil);
    
    STAssertEqualObjects([[ab aiMove] string], @"100 120 200", nil);
    STAssertEqualObjects([[ab aiMove] string], @"101 120 200", nil);
    STAssertEqualObjects([[ab aiMove] string], @"121 120 200", nil);
    
    STAssertEqualObjects([[ab aiMove] string], @"121 120 210", nil);
    STAssertEqualObjects([[ab aiMove] string], @"121 122 210", nil);
    STAssertEqualObjects([[ab aiMove] string], @"121 122 211", nil);    
}

- (void)testFindMoves
{
    [ab setMaxPly:2];   // states below assumes a ply 2 search
    [ab setState:st];
    STAssertNil([ab lastMove], nil);
    
    STAssertNotNil([ab aiMove], nil);
    STAssertEqualObjects([[ab currentState] string], @"000 010 000", nil);
    STAssertEquals([ab countMoves], (unsigned)1, nil);
    STAssertEqualsWithAccuracy([[ab currentState] fitness], (float)-4.0, 0.1, nil);
    STAssertEqualsWithAccuracy([ab fitness], (float)-4.0, 0.1, nil);
    STAssertEqualObjects([[ab lastMove] string], @"11", nil);
    
    [ab aiMove];
    STAssertEqualObjects([[ab currentState] string], @"200 010 000", nil);
    STAssertEquals([ab countMoves], (unsigned)2, nil);
    STAssertEqualsWithAccuracy([[ab currentState] fitness], (float)1.0, 0.1, nil);
    STAssertEqualsWithAccuracy([ab fitness], (float)1.0, 0.1, nil);
    STAssertEqualObjects([[ab lastMove] string], @"00", nil);
}

@end
