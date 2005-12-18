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
    moves = nil;
}

- (void)tearDown
{
    [st release];
    [moves release];
}

- (void)testMove
{
    id move = [[TTTMove alloc] initWithX:2 andY:1];
    STAssertTrue([move x] == 2, nil);
    STAssertTrue([move y] == 1, nil);
    STAssertTrue([[move string] isEqualToString:@"21"], nil);
}

- (void)testAvailMoves
{
    STAssertNotNil(moves = [st listAvailableMoves], nil);
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
        s2 = [[moves objectAtIndex:i] string];
        STAssertTrue([s2 isEqualToString:s], @"expected %@, got %@", s, s2);
    }
}

- (void)testFitness
{    
    STAssertTrue([st playerTurn] == 1, nil);
    STAssertTrue([[st string] isEqualToString:@"000000000"], @"is the initial state");
    STAssertTrue([st fitness] == 0.0, @"got: %f", [st fitness]);
    [st applyMove:[[TTTMove alloc] initWithX:0 andY:0]];
    STAssertEqualsWithAccuracy([st fitness], (float)-3.0, 0.0001, @"got %f", [st fitness]);
    [st applyMove:[[TTTMove alloc] initWithX:0 andY:1]];
    STAssertEqualsWithAccuracy([st fitness], (float)1.0, 0.0001, @"got %f", [st fitness]);    
    [st applyMove:[[TTTMove alloc] initWithX:1 andY:1]];
    STAssertEqualsWithAccuracy([st fitness], (float)-7.0, 0.0001, @"got %f", [st fitness]);    
}

- (void)testState
{    
    STAssertTrue([st playerTurn] == 1, nil);
    STAssertTrue([[st string] isEqualToString:@"000000000"], @"is the initial state");
    
    int i;
    for (i = 9; i > 0; i--) {
        STAssertNotNil(moves = [st listAvailableMoves], nil);
        STAssertTrue([moves count] == i, @"got %d moves", [moves count]);
        id m = [moves objectAtIndex:0];
        [st applyMove:m];
        STAssertTrue([st playerTurn] == i % 2 + 1, @"expected(%d): %d, got: %d", i, i % 2 + 1, [st playerTurn]);
        
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
        STAssertEquals([cp playerTurn], (int)[st playerTurn], @"got (%d): %d", i, [cp playerTurn]);
    }
}

@end
