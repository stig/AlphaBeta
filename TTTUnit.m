//
//  TTTUnit.m
//  AlphaBeta
//
//  Created by Stig Brautaset on 11/12/2005.
//  Copyright 2005 Stig Brautaset. All rights reserved.
//

#import "TTTUnit.h"

@implementation TTTUnit

- (void)setUp
{
    st = [[TTTState alloc] init];
    STAssertTrue([st player] == 1, nil);
    STAssertTrue([[st string] isEqualToString:@"000000000"], @"is the initial state");
    
    ab = [[AlphaBeta alloc] initWithState:st];
    STAssertNotNil(ab, @"got nil back");
    STAssertTrue([ab currentState] == st, @"did not get expected state back");
    STAssertEquals([ab countMoves], (unsigned)0, nil);

    moves = nil;
}

- (void)tearDown
{
    [st release];
    [ab release];
    [moves release];
}

- (void)testMove
{
    id move = [[TTTMove alloc] initWithCol:2 andRow:1];
    STAssertTrue([move col] == 2, nil);
    STAssertTrue([move row] == 1, nil);
    STAssertTrue([[move string] isEqualToString:@"21"], nil);
}

- (void)testAvailMoves
{
    STAssertNotNil(moves = [st listAvailableMoves], nil);
    STAssertEquals([moves count], (unsigned)9, nil);
    id s;
    int i;
    for (i = 0; i < 9; i++) {
        id s2;
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
        s2 = [m string];
        STAssertTrue([s2 isEqualToString:s], @"expected %@, got %@", s, s2);
        [st applyMove:m];
        STAssertTrue(![[st string] isEqualToString:@"000000000"], nil);
        [st undoMove:m];
        STAssertTrue([[st string] isEqualToString:@"000000000"], nil);
    }
}

- (void)testFitness
{
    STAssertTrue([st player] == 1, nil);
    STAssertTrue([[st string] isEqualToString:@"000000000"], @"is the initial state");
    STAssertTrue([st fitness] == 0.0, @"got: %f", [st fitness]);
    [st applyMove:[[TTTMove alloc] initWithCol:0 andRow:0]];
    STAssertEqualsWithAccuracy([st fitness], (float)-3.0, 0.0001, @"got %f", [st fitness]);
    [st applyMove:[[TTTMove alloc] initWithCol:0 andRow:1]];
    STAssertEqualsWithAccuracy([st fitness], (float)1.0, 0.0001, @"got %f", [st fitness]);
    [st applyMove:[[TTTMove alloc] initWithCol:1 andRow:1]];
    STAssertEqualsWithAccuracy([st fitness], (float)-7.0, 0.0001, @"got %f", [st fitness]);
}

- (void)testState
{
    STAssertTrue([st player] == 1, nil);
    STAssertTrue([[st string] isEqualToString:@"000000000"], @"is the initial state");

    int i;
    for (i = 9; i > 0; i--) {
        STAssertNotNil(moves = [st listAvailableMoves], nil);
        STAssertTrue([moves count] == i, @"got %d moves", [moves count]);
        id m = [moves objectAtIndex:0];
        [st applyMove:m];
        STAssertTrue([st player] == i % 2 + 1, @"expected(%d): %d, got: %d", i, i % 2 + 1, [st player]);

        id s;
        switch (i) {
            case 9: s = @"100000000"; break;
            case 8: s = @"100200000"; break;
            case 7: s = @"100200100"; break;
            case 6: s = @"120200100"; break;
            case 5: s = @"120210100"; break;
            case 4: s = @"120210120"; break;
            case 3: s = @"121210120"; break;
            case 2: s = @"121212120"; break;
            case 1: s = @"121212121"; break;
        }
        STAssertTrue([[st string] isEqualToString:s], @"got(%d): %@", i, [st string]);
        id cp = [st copy];
        STAssertTrue(st != cp, @"copies are the same, but should not be");
        STAssertTrue([[cp string] isEqualToString:s], @"got(%d): %@", i, [cp string]);
        STAssertEquals([cp player], (int)[st player], @"got (%d): %d", i, [cp player]);
    }
}


- (void)testInitAndSetState
{
    [ab release];
    ab = [[AlphaBeta alloc] init];
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
    STAssertThrows([ab setMaxPly:-3], @"allowed negative ply");
    [ab setMaxPly:5];
    STAssertEquals([ab maxPly], (unsigned)5, nil);
}

- (void)testFindMoves
{
    [ab setMaxPly:2];   // states below assumes a ply 2 search
    STAssertNil([ab lastMove], nil);
    
    STAssertNotNil([ab aiMove], nil);
    NSString *s = [[ab currentState] string];
    STAssertTrue([s isEqualToString:@"000010000"], @"got: %@", s);
    STAssertEquals([ab countMoves], (unsigned)1, nil);
    STAssertEqualsWithAccuracy([[ab currentState] fitness], (float)-4.0, 0.1, nil);
    STAssertEqualsWithAccuracy([ab fitness], (float)-4.0, 0.1, nil);
    s = [[ab lastMove] string];
    STAssertTrue([s isEqualToString:@"11"], @"got: %@", s);
    
    [ab aiMove];
    s = [[ab currentState] string];
    STAssertTrue([s isEqualToString:@"200010000"], @"got: %@", s);
    STAssertEquals([ab countMoves], (unsigned)2, nil);
    STAssertEqualsWithAccuracy([[ab currentState] fitness], (float)1.0, 0.1, nil);
    STAssertEqualsWithAccuracy([ab fitness], (float)1.0, 0.1, nil);
    s = [[ab lastMove] string];
    STAssertTrue([s isEqualToString:@"00"], @"got: %@", s);
}

@end
