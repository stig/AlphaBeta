//
//  TTTUnit.m
//  AlphaBeta
//
//  Created by Stig Brautaset on 11/12/2005.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "TTTUnit.h"
#import "TTTState.h"

@implementation TTTUnit

- (void)testMove
{
    id move = [[TTTMove alloc] initWithX:2 andY:1];
    STAssertTrue([move x] == 2, nil);
    STAssertTrue([move y] == 1, nil);
    STAssertTrue([[move string] isEqualToString:@"21"], nil);
}

- (void)testAvailMoves
{
    id st = [[TTTState alloc] init];
    NSMutableArray *moves;
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

- (void)testState
{
    id st = [[TTTState alloc] init];
    NSMutableArray *moves;
    
    STAssertTrue([st playerTurn] == 1, nil);
    STAssertTrue([[st string] isEqualToString:@"000000000"], @"is the initial state");
    STAssertTrue([st fitnessValue] == 0.0, @"initial state is neutral");
    
    STAssertNotNil(moves = [st listAvailableMoves], nil);
    STAssertTrue([moves count] == 9, @"got %d moves", [moves count]);
    
    id m = [moves objectAtIndex:0];
    [st applyMove:m];
    STAssertTrue([st playerTurn] == 2, nil);
    STAssertTrue([[st string] isEqualToString:@"100000000"], @"got: %@", [st string]);

    [moves release];
    STAssertNotNil(moves = [st listAvailableMoves], nil);
    STAssertTrue([moves count] == 8, @"got %d moves", [moves count]);
    m = [moves objectAtIndex:0];
    [st applyMove:m];
    STAssertTrue([[st string] isEqualToString:@"100200000"], @"got: %@", [st string]);
    
    [moves release];
    STAssertNotNil(moves = [st listAvailableMoves], nil);
    STAssertTrue([moves count] == 7, @"got %d moves", [moves count]);
    m = [moves objectAtIndex:0];
    [st applyMove:m];
    STAssertTrue([[st string] isEqualToString:@"100200100"], @"got: %@", [st string]);
    
    [moves release];
    STAssertNotNil(moves = [st listAvailableMoves], nil);
    STAssertTrue([moves count] == 6, @"got %d moves", [moves count]);
    m = [moves objectAtIndex:0];
    [st applyMove:m];
    STAssertTrue([[st string] isEqualToString:@"120200100"], @"got: %@", [st string]);

    [moves release];
    STAssertNotNil(moves = [st listAvailableMoves], nil);
    STAssertTrue([moves count] == 5, @"got %d moves", [moves count]);
    m = [moves objectAtIndex:0];
    [st applyMove:m];
    STAssertTrue([[st string] isEqualToString:@"120210100"], @"got: %@", [st string]);
    
    [moves release];
    STAssertNotNil(moves = [st listAvailableMoves], nil);
    STAssertTrue([moves count] == 4, @"got %d moves", [moves count]);
    m = [moves objectAtIndex:0];
    [st applyMove:m];
    STAssertTrue([[st string] isEqualToString:@"120210120"], @"got: %@", [st string]);    

    [moves release];
    STAssertNotNil(moves = [st listAvailableMoves], nil);
    STAssertTrue([moves count] == 3, @"got %d moves", [moves count]);
    m = [moves objectAtIndex:0];
    [st applyMove:m];
    STAssertTrue([[st string] isEqualToString:@"121210120"], @"got: %@", [st string]);    
    
    [moves release];
    STAssertNotNil(moves = [st listAvailableMoves], nil);
    STAssertTrue([moves count] == 2, @"got %d moves", [moves count]);
    m = [moves objectAtIndex:0];
    [st applyMove:m];
    STAssertTrue([[st string] isEqualToString:@"121212120"], @"got: %@", [st string]);    
    
    [moves release];
    STAssertNotNil(moves = [st listAvailableMoves], nil);
    STAssertTrue([moves count] == 1, @"got %d moves", [moves count]);
    m = [moves objectAtIndex:0];
    [st applyMove:m];
    STAssertTrue([[st string] isEqualToString:@"121212121"], @"got: %@", [st string]);
    
    [moves release];
    STAssertNotNil(moves = [st listAvailableMoves], nil);
    STAssertTrue([moves count] == 0, @"no possible moves left");
}


@end
