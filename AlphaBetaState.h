//
//  AlphaBetaState.h
//  AlphaBeta
//
//  Created by Stig Brautaset on 17/12/2005.
//  Copyright 2005 Stig Brautaset. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AlphaBetaState
- (float)fitness;
- (NSMutableArray *)listAvailableMoves;
- (id)applyMove:(id)m;
@end

@protocol AlphaBetaStateWithCopy <AlphaBetaState, NSCopying>
@end

@protocol AlphaBetaStateWithUndo <AlphaBetaState>
- (id)undoMove:(id)m;
@end

