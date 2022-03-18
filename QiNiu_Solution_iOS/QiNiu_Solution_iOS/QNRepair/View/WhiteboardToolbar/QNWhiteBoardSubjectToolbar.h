//
//  LATSubjectToolbar.h
//  WhiteboardTest
//
//  Created by mac on 2021/5/19.
//

#import "QNWhiteBoardBaseToolbar.h"

NS_ASSUME_NONNULL_BEGIN

@interface QNWhiteBoardSubjectToolbar : QNWhiteBoardBaseToolbar <UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>

-(void)loadJsonDictionary;
@end

NS_ASSUME_NONNULL_END
