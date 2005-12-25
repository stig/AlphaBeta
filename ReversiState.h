//
//  ReversiState.h
//  AlphaBeta
//
//  Created by Stig Brautaset on 18/12/2005.
//  Copyright 2005 Stig Brautaset. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlphaBetaState.h"

typedef struct _ReversiStateCount {
    int c[3];
} ReversiStateCount;

@interface ReversiState : NSObject <AlphaBetaStateWithCopy> {
    int player;
    int size;
    int **board;
}

- (int)size;
- (int)player;
- (NSString *)string;
- (id)initWithBoardSize:(int)theSize;
- (ReversiStateCount)countSquares;
@end
