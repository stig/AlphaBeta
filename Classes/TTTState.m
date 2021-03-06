/*
Copyright (c) 2006,2007 Stig Brautaset. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

  Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

  Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

  Neither the name of the author nor the names of its contributors may be used
  to endorse or promote products derived from this software without specific
  prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/


#import "TTTState.h"

@implementation TTTState

- (id)init
{
    if (self = [super init]) {
        for (int i = 0; i < 3; i++) {
            for (int j = 0; j < 3; j++) {
                board[i][j] = 0;
            }
        }
        player = 1;
    }
    return self;
}

- (int)winner
{
    int t1 = 3, t2 = 3;
    for (int i = 0; i < 3; i++) {
        int j, tv = 3, th = 3;
        for (j = 0; j < 3; j++) {
            th &= board[i][j];  /* horizontally? */
            tv &= board[j][i];  /* vertically? */
        }
        
        /* Vertical or Horisontal winning line? */
        if (tv || th)
            return tv + th;

        t1 &= board[i][i];      /* diagonally (1) */
        t2 &= board[i][2-i];    /* diagonally (2) */
    }
    if (t1 || t2)
        return t1 + t2;
    
    return 0;
}

- (BOOL)isDraw
{
    return ![self winner];
}

- (BOOL)isWin
{
    return [self winner] == player;
}

static double calcFitness(int me, int counts[3])
{
    int you = 3 - me;
    double score = 0.0;
    if (counts[me] && !counts[you]) {
        score += counts[me] * counts[me];
    }
    else if (!counts[me] && counts[you]) {
        score -= counts[you] * counts[you];
    }
    return abs(score) == 9 ? score * 100 : score;
}


- (double)fitness
{
    int i, j, me;
    double score = 0.0;
    int countd1[3] = {0};
    int countd2[3] = {0};

    me = player;
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

- (NSArray *)legalMoves
{
    NSMutableArray *moves = [NSMutableArray array];
    if (abs([self fitness]) > 100) {
        return moves;
    }
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            if (!board[i][j]) {
                [moves addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                    [NSNumber numberWithInt: i], @"col",
                    [NSNumber numberWithInt: j], @"row",
                    nil]];
            }
        }
    }
    return moves;
}

- (NSString *)description
{
    NSMutableString *s = [NSMutableString string];
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            [s appendFormat:@"%d", board[j][i]];
        }
        if (i < 2) {
            [s appendFormat:@" "];
        }
    }
    return s;
}

- (void)applyMove:(id)m
{
    int row = [[m objectForKey:@"row"] intValue];
    int col = [[m objectForKey:@"col"] intValue];

    if (row > 2 || row < 0 || col > 2 || col < 0) {
        [NSException raise:@"not a valid move" format:@"Invalid move (%d, %d)", row, col];

    } else if (board[col][row]) {
        [NSException raise:@"square busy" format:@"Move already taken (%d, %d)", row, col];
    }
    
    board[col][row] = player;
    player = 3 - player;
}

- (id)copyWithZone:(NSZone *)zone
{
    return NSCopyObject(self, 0, zone);
}

@end
