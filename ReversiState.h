//
//  ReversiState.h
//  AlphaBeta
//
//  Created by Stig Brautaset on 18/12/2005.
//  Copyright 2005 Stig Brautaset. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AlphaBetaState.h"

@interface ReversiState : NSObject <AlphaBetaState> {
    int player;
    int size;
    int **board;
}

- (int)player;
- (NSString *)string;
- (id)initWithBoardSize:(int)theSize;
@end
