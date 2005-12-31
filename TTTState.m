//
//  TTTState.m
//  AlphaBeta
//
//  Created by Stig Brautaset on 11/12/2005.
//  Copyright 2005 Stig Brautaset. All rights reserved.
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
        player = 1;
    }
    return self;
}

- (int)player
{
    return player;
}

- (void)applyMove:(id)m
{
    int row = [m row];
    int col = [m col];

    if (row > 2 || row < 0 || col > 2 || col < 0) {
        [NSException raise:@"not a valid move" format:@"Invalid move (%d, %d)", row, col];
    }
    else if (!board[col][row]) {
        board[col][row] = player;
        player = 3 - player;
    }
    else {
        [NSException raise:@"square busy" format:@"Move already taken (%d, %d)", row, col];
    }
}

- (void)undoMove:(id)m
{
    int row = [m row];
    int col = [m col];

    if (row > 2 || row < 0 || col > 2 || col < 0) {
        [NSException raise:@"not a valid move" format:@"Invalid move (%d, %d)", row, col];
    }
    else if (board[col][row]) {
        board[col][row] = 0;
        player = 3 - player;
    }
    else {
        [NSException raise:@"square not taken" format:@"Move not taken (%d, %d)", row, col];
    }
}

static float calcFitness(int me, int counts[3])
{
    int you = 3 - me;
    float score = 0.0;
    if (counts[me] && !counts[you]) {
        score += counts[me] * counts[me];
    }
    else if (!counts[me] && counts[you]) {
        score -= counts[you] * counts[you];
    }
    return abs(score) == 9 ? score * 100 : score;
}


- (float)fitness
{
    int i, j, me;
    float score = 0.0;
    int countd1[3] = {0};
    int countd2[3] = {0};

    me = [self player];
    for (i = 0; i < 3; i++) {
        int counth[3] = {0};
        int countv[3] = {0};
        for (j = 0; j < 3; j++) {
            counth[board[i][j]]++;
            countv[board[j][i]]++;
        }
        countd1[board[i][i]]++;
        countd2[board[i][2-i]]++;
        score += calcFitness(me, counth);
        score += calcFitness(me, countv);
    }
    score += calcFitness(me, countd1);
    score += calcFitness(me, countd2);
    return score;
}

- (NSMutableArray *)listAvailableMoves
{
    NSMutableArray *moves = [[NSMutableArray new] autorelease];
    if (abs([self fitness]) > 100) {
        return moves;
    }
    int i, j;
    for (i = 0; i < 3; i++) {
        for (j = 0; j < 3; j++) {
            if (!board[i][j]) {
                [moves addObject:[[TTTMove alloc] initWithCol:i andRow:j]];
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
        if (i < 2) {
            [s appendFormat:@" "];
        }
    }
    return s;
}

@end
