//
//  TTTState.m
//  AlphaBeta
//
//  Created by Stig Brautaset on 11/12/2005.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "TTTState.h"

@implementation TTTState

- (id)init
{
    if (self = [super init]) {
        int i, j;
        for (i = 0; i < 3; i++) {
            for (j = 0; j < 3; j++) {
                board[i][j] = 0;
            }
        }
        playerTurn = 1;
    }
    return self;
}

- (int)playerTurn
{
    return playerTurn;
}

- (void)applyMove:(id)m
{
    int row = [m y];
    int col = [m x];
    
    if (row > 2 || row < 0 || col > 2 || col < 0) {
        [NSException raise:@"not a valid move" format:@"Invalid move (%d, %d)", row, col];
    }
    else if (!board[col][row]) {
        board[col][row] = playerTurn;
        playerTurn = 3 - playerTurn;
    }
    else {
        [NSException raise:@"square busy" format:@"Move already taken (%d, %d)", row, col];   
    }
}

- (float)fitnessValue
{
    return 0.0;
}

- (NSMutableArray *)listAvailableMoves
{
    NSMutableArray *moves = [[NSMutableArray alloc] init];
    int i, j;
    for (i = 0; i < 3; i++) {
        for (j = 0; j < 3; j++) {
            if (!board[i][j]) {
                [moves addObject:[[TTTMove alloc] initWithX:i andY:j]];
            }
        }
    }
    return moves;
}

- (NSString *)string
{
    NSMutableString *s = [NSMutableString string];
    int i, j;
    for (i = 0; i < 3; i++) {
        for (j = 0; j < 3; j++) {
            [s appendFormat:@"%d", board[j][i]];
        }
    }
    return s;
}
@end
