
#import <UIKit/UIKit.h>
#import "THClientGridItem.h"

@class THClientGridView;

@protocol THClientGridViewDataSource <NSObject>
-(NSUInteger)numberOfItemsInGridView:(THClientGridView*)gridView;
-(THClientGridItem*)gridView:(THClientGridView*)gridView viewAtIndex:(NSUInteger)index;
-(void)gridView:(THClientGridView*)gridView didSelectViewAtIndex:(NSUInteger)index;
-(void)gridView:(THClientGridView*)gridView didDeleteViewAtIndex:(NSUInteger)index;
-(void)gridView:(THClientGridView*)gridView didRenameViewAtIndex:(NSUInteger)index newName:(NSString*)newName;
@end

@protocol THClientGridViewDelegate <NSObject>
-(CGSize) gridItemSizeForGridView:(THClientGridView*) view;
-(CGPoint) gridItemPaddingForGridView:(THClientGridView*) view;
-(CGPoint) gridPaddingForGridView:(THClientGridView*) view;
@end

@interface THClientGridView : UIScrollView <TFClientGridItemDelegate, UIGestureRecognizerDelegate>
{
}

@property (nonatomic, weak) id<THClientGridViewDataSource> dataSource;
@property (nonatomic, weak) id<THClientGridViewDelegate> gridDelegate;
@property (readonly) NSMutableArray *items;
@property (nonatomic) BOOL editing;

- (void)reloadData;
@end