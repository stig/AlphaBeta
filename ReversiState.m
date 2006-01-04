//
//  ReversiState.m
//  AlphaBeta
//
//  Created by Stig Brautaset on 18/12/2005.
//  Copyright 2005 Stig Brautaset. All rights reserved.
//

#import "ReversiState.h"
#import "ReversiMove.h"

@implementation ReversiState

- (id)init
{
    return [self initWithBoardSize:8];
}

- (id)initWithBoardSize:(int)theSize
{
    if (self = [super init]) {
        size = theSize;
        player = 1;
        board = NSZoneMalloc([self zone], size * (sizeof(int*)));
        if (board) {
            board[0] = NSZoneMalloc([self zone], size * size * (sizeof(int)));
            if (board[0]) {
                int i, j;
                for (i = 1; i < size; i++) {
                    board[i] = board[0] + i * size;
                }
                for (i = 0; i < size; i++) {
                    for (j = 0; j < size; j++) {
                        board[i][j] = 0;
                    }
                }
                board[size/2-1][size/2] = player;
                board[size/2][size/2-1] = player;
                board[size/2-1][size/2-1] = 3 - player;
                board[size/2][size/2] = 3 - player;
            }
            else {
                [self release];
                return nil;
            }
        }
        else {
            [self release];
            return nil;
        }
    }
    return self;
}

- (id)initWithBoardSize:(int)sz andPlayer:(int)p
{
    self = [self initWithBoardSize:sz];
    player = p;
    return self;
}

- (int**)board
{
    return board;
}

- (int)player
{
    return player;
}

- (int)size
{
    return size;
}

- (id)copyWithZone:(NSZone *)zone
{
    ReversiState *copy = [[ReversiState allocWithZone:zone] initWithBoardSize:size andPlayer:player];
    int i, j;
    int **b = [copy board];
    for (i = 0; i < size; i++) {
        for (j = 0; j < size; j++) {
            b[i][j] = board[i][j];
        }
    }
    return copy;
}

- (void)dealloc
{
    if (board) {
        free(board[0]);
    }
    free(board);
    [super dealloc];
}

- (ReversiStateCount)countSquares
{
    int i, j;
    ReversiStateCount count = {{0}};
    for (i = 0; i < size; i++) {
        for (j = 0; j < size; j++) {
            count.c[ board[i][j] ]++;
        }
    }
    return count;
}

- (float)fitness
{
    NSArray *moves;
    int mine, diff, me, you;
    ReversiStateCount counts;

    me = player;
    you = 3 - me;

    moves = [self listAvailableMoves];
    if (!moves) {
        [NSException raise:@"unexpected" format:@"Unexpected return"];
    }
    else if (![moves count]) {
        counts = [self countSquares];
        mine = counts.c[me] - counts.c[you];
        return (float)(mine > 0 ? +100000.0 :
                       mine < 0 ? -100000.0 : 0);
    }

    mine = [moves count];

    player = 3 - player;
    moves = [self listAvailableMoves];
    player = 3 - player;

    diff = mine - [moves count];

    counts = [self countSquares];
    mine = counts.c[me] - counts.c[you];

    return (float)(diff + mine);
}

- (BOOL)validMove:(int)me col:(int)x row:(int)y
{
    int tx, ty;
    int not_me = 3 - me;

    /* slot must not already be occupied */
    if (board[x][y] != 0)
        return NO;

    /* left */
    for (tx = x - 1; tx >= 0 && board[tx][y] == not_me; tx--)
        ;
    if (tx >= 0 && tx != x - 1 && board[tx][y] == me)
        return YES;

    /* right */
    for (tx = x + 1; tx < size && board[tx][y] == not_me; tx++)
        ;
    if (tx < size && tx != x + 1 && board[tx][y] == me)
        return YES;

    /* up */
    for (ty = y - 1; ty >= 0 && board[x][ty] == not_me; ty--)
        ;
    if (ty >= 0 && ty != y - 1 && board[x][ty] == me)
        return YES;

    /* down */
    for (ty = y + 1; ty < size && board[x][ty] == not_me; ty++)
        ;
    if (ty < size && ty != y + 1 && board[x][ty] == me)
        return YES;

    /* up/left */
    tx = x - 1;
    ty = y - 1;
    while (tx >= 0 && ty >= 0 && board[tx][ty] == not_me) {
        tx--;
        ty--;
    }
    if (tx >= 0 && ty >= 0 && tx != x - 1 && ty != y - 1 && board[tx][ty] == me)
        return YES;

    /* up/right */
    tx = x - 1;
    ty = y + 1;
    while (tx >= 0 && ty < size && board[tx][ty] == not_me) {
        tx--;
        ty++;
    }
    if (tx >= 0 && ty < size && tx != x - 1 && ty != y + 1 && board[tx][ty] == me)
        return YES;

    /* down/right */
    tx = x + 1;
    ty = y + 1;
    while (tx < size && ty < size && board[tx][ty] == not_me) {
        tx++;
        ty++;
    }
    if (tx < size && ty < size && tx != x + 1 && ty != y + 1 && board[tx][ty] == me)
        return YES;

    /* down/left */
    tx = x + 1;
    ty = y - 1;
    while (tx < size && ty >= 0 && board[tx][ty] == not_me) {
        tx++;
        ty--;
    }
    if (tx < size && ty >= 0 && tx != x + 1 && ty != y - 1 && board[tx][ty] == me)
        return YES;

    return NO;
}

- (NSMutableArray *)listAvailableMoves
{
    NSMutableArray *moves = [NSMutableArray new];
    int me, i, j;

    me = player;
again:
    for (i = 0; i < size; i++) {
        for (j = 0; j < size; j++) {
            if ([self validMove:me col:i row:j]) {
                [moves addObject:[[ReversiMove alloc] initWithCol:i andRow:j]];
            }
        }
    }

    if (![moves count]) {
        if (me == player) {
            me = 3 - me;
            goto again;
        }
    }
    else if (me != player) {
        [moves removeAllObjects];
        [moves addObject:[ReversiMove newWithCol:-1 andRow:-1]];
    }

    return [moves autorelease];
}

- (id)applyMove:(id)m
{
    int x = [m col];
    int y = [m row];
    int me = player;
    int not_me = 3 - me;
    int tx, ty, flipped = 0;

    player = not_me;

    if (x == -1 && y == -1) {
        return self;
    }
    else if (x < 0 || x > (size-1) || y < 0 || y > (size-1)) {
        player = me;
        [NSException raise:@"illegal move" format:@"Illegal move"];
    }
    else if (board[x][y] != 0) {
        player = me;
        [NSException raise:@"square busy" format:@"Square busy"];
    }

    /* left */
    for (tx = x - 1; tx >= 0 && board[tx][y] == not_me; tx--)
        ;
    if (tx >= 0 && tx != x - 1 && board[tx][y] == me) {
        tx = x - 1;
        while (tx >= 0 && board[tx][y] == not_me) {
            board[tx][y] = me;
            tx--;
        }
        flipped++;
    }

    /* right */
    for (tx = x + 1; tx < size && board[tx][y] == not_me; tx++)
        ;
    if (tx < size && tx != x + 1 && board[tx][y] == me) {
        tx = x + 1;
        while (tx < size && board[tx][y] == not_me) {
            board[tx][y] = me;
            tx++;
        }
        flipped++;
    }

    /* up */
    for (ty = y - 1; ty >= 0 && board[x][ty] == not_me; ty--)
        ;
    if (ty >= 0 && ty != y - 1 && board[x][ty] == me) {
        ty = y - 1;
        while (ty >= 0 && board[x][ty] == not_me) {
            board[x][ty] = me;
            ty--;
        }
        flipped++;
    }

    /* down */
    for (ty = y + 1; ty < size && board[x][ty] == not_me; ty++)
        ;
    if (ty < size && ty != y + 1 && board[x][ty] == me) {
        ty = y + 1;
        while (ty < size && board[x][ty] == not_me) {
            board[x][ty] = me;
            ty++;
        }
        flipped++;
    }

    /* up/left */
    tx = x - 1;
    ty = y - 1;
    while (tx >= 0 && ty >= 0 && board[tx][ty] == not_me) {
        tx--;
        ty--;
    }
    if (tx >= 0 && ty >= 0 && tx != x - 1 && ty != y - 1 && board[tx][ty] == me) {
        tx = x - 1;
        ty = y - 1;
        while (tx >= 0 && ty >= 0 && board[tx][ty] == not_me) {
            board[tx][ty] = me;
            tx--;
            ty--;
        }
        flipped++;
    }

    /* up/right */
    tx = x - 1;
    ty = y + 1;
    while (tx >= 0 && ty < size && board[tx][ty] == not_me) {
        tx--;
        ty++;
    }
    if (tx >= 0 && ty < size && tx != x - 1 && ty != y + 1 && board[tx][ty] == me) {
        tx = x - 1;
        ty = y + 1;
        while (tx >= 0 && ty < size && board[tx][ty] == not_me) {
            board[tx][ty] = me;
            tx--;
            ty++;
        }
        flipped++;
    }

    /* down/right */
    tx = x + 1;
    ty = y + 1;
    while (tx < size && ty < size && board[tx][ty] == not_me) {
        tx++;
        ty++;
    }
    if (tx < size && ty < size && tx != x + 1 && ty != y + 1 && board[tx][ty] == me) {
        tx = x + 1;
        ty = y + 1;
        while (tx < size && ty < size && board[tx][ty] == not_me) {
            board[tx][ty] = me;
            tx++;
            ty++;
        }
        flipped++;
    }

    /* down/left */
    tx = x + 1;
    ty = y - 1;
    while (tx < size && ty >= 0 && board[tx][ty] == not_me) {
        tx++;
        ty--;
    }
    if (tx < size && ty >= 0 && tx != x + 1 && ty != y - 1 && board[tx][ty] == me) {
        tx = x + 1;
        ty = y - 1;
        while (tx < size && ty >= 0 && board[tx][ty] == not_me) {
            board[tx][ty] = me;
            tx++;
            ty--;
        }
        flipped++;
    }

    if (flipped) {
        board[x][y] = me;
        return self;
    }
    player = me;
    [NSException raise:@"illegal move" format:@"Move achieved nothing: %@ for player %d (on %@)", [m string], player, [self string]];
    return nil;
}

- (NSString *)string
{
    NSMutableString *s = [NSMutableString string];
    int i, j;
    for (i = 0; i < size; i++) {
        for (j = 0; j < size; j++) {
            [s appendFormat:@"%d", board[j][i]];
        }
        if (i < size - 1) {
            [s appendFormat:@" "];
        }
    }
    return s;
}


@end
