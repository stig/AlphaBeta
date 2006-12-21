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

- (int)winner
{
    int i, t1 = 3, t2 = 3;
    
    for (i = 0; i < 3; i++) {
        int j, tv = 3, th = 3;
        for (j = 0; j < 3; j++) {
            th &= board[i][j];  /* horizontally? */
            tv &= board[j][i];  /* vertically? */
        }
        if (tv || th)
            return tv + th; /* only one can win... */

        t1 &= board[i][i];      /* diagonally (1) */
        t2 &= board[i][2-i];    /* diagonally (2) */
    }
    if (t1 || t2)
        return t1 + t2;
    
    return 0;
}


- (int)player
{
    return player;
}

- (id)applyMove:(id)m
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
    return self;
}

- (id)undoMove:(id)m
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
    return self;
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


- (float)currentFitness
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

- (NSArray *)movesAvailable
{
    NSMutableArray *moves = [NSMutableArray array];
    if (abs([self currentFitness]) > 100) {
        return moves;
    }
    int i, j;
    for (i = 0; i < 3; i++) {
        for (j = 0; j < 3; j++) {
            if (!board[i][j]) {
                [moves addObject:[TTTMove moveWithCol:i andRow:j]];
            }
        }
    }
    return moves;
}

- (NSString *)description
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
