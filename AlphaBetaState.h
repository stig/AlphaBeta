//
//  AlphaBetaState.h
//  AlphaBeta
//
//  Created by Stig Brautaset on 17/12/2005.
//  Copyright 2005 Stig Brautaset. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol AlphaBetaState

- (float)fitness;
- (NSMutableArray *)listAvailableMoves;
- (void)applyMove:(id)m;
- (void)undoMove:(id)m;
- (BOOL)canUndo;

@end
