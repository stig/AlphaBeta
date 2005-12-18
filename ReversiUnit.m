//
//  ReversiUnit.m
//  AlphaBeta
//
//  Created by Stig Brautaset on 18/12/2005.
//  Copyright 2005 Stig Brautaset. All rights reserved.
//

#import "ReversiUnit.h"
#import "ReversiMove.h"

@implementation ReversiUnit

- (void)setUp
{
    st = [[ReversiState alloc] init];
    moves = nil;
}

- (void)tearDown
{
    [st release];
    [moves release];
}

- (void)testMove
{
    id move = [[ReversiMove alloc] initWithCol:2 andRow:1];
    STAssertTrue([move col] == 2, nil);
    STAssertTrue([move row] == 1, nil);
    STAssertTrue([[move string] isEqualToString:@"21"], nil);
}

- (void)testAvailMoves
{
    STAssertNotNil(moves = [st listAvailableMoves], nil);
    STAssertEquals([moves count], (unsigned)4, nil);
    id s;
    int i;
    for (i = 0; i < 4; i++) {
        id s2;
        switch (i) {
            case 0: s = @"23"; break;
            case 1: s = @"32"; break;
            case 2: s = @"45"; break;
            case 3: s = @"54"; break;
        }
        s2 = [[moves objectAtIndex:i] string];
        STAssertTrue([s2 isEqualToString:s], @"expected %@, got %@", s, s2);
    }
}

- (void)testStateAndFitness4x4
{
    [st release];
    st = [[ReversiState alloc] initWithBoardSize:4];
    
    STAssertTrue([st player] == 1, nil);
    STAssertTrue([st fitness] == 0.0, @"got: %f", [st fitness]);

    NSString *s = [st string];
    STAssertTrue([s isEqualToString:@"0000021001200000"], @"got: %@", s);

    [st applyMove:[[ReversiMove alloc] initWithCol:1 andRow:0]];
    STAssertEqualsWithAccuracy([st fitness], (float)-3.0, 0.0001, @"got %f", [st fitness]);
    s = [st string];
    STAssertTrue([s isEqualToString:@"0100011001200000"], @"got: %@", s);

    [st applyMove:[[ReversiMove alloc] initWithCol:2 andRow:0]];
    STAssertEqualsWithAccuracy([st fitness], (float)0.0, 0.0001, @"got %f", [st fitness]);
    s = [st string];
    STAssertTrue([s isEqualToString:@"0120012001200000"], @"got: %@", s);
    
    [st applyMove:[[ReversiMove alloc] initWithCol:3 andRow:3]];
    STAssertEqualsWithAccuracy([st fitness], (float)-1.0, 0.0001, @"got %f", [st fitness]);    
    s = [st string];
    STAssertTrue([s isEqualToString:@"0120012001100001"], @"got: %@", s);
}


@end
