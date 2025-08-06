//
//  CollectionViewItem.m
//  Example
//
//  Created by hulilei on 2021/9/14.
//

#import "CollectionViewItem.h"

@interface CollectionViewItem ()
@property (weak) IBOutlet NSImageView *icon;
@property (weak) IBOutlet NSTextField *lable;

@end

@implementation CollectionViewItem

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}
-(void)setRepresentedObject:(id)representedObject{
    [super setRepresentedObject:representedObject];
    if(representedObject){
        NSDictionary *data = representedObject;
        NSString *image = data[@"image"];
        self.icon.image = [NSImage imageNamed:image];
        self.icon.tag = [data[@"tag"] integerValue];
        NSString *title = data[@"title"];
        self.lable.stringValue = title;
//        NSClickGestureRecognizer *tap = [[NSClickGestureRecognizer alloc]init];
//        tap.action = @selector(lableTap);
//        tap.target = self;
//        [self.lable addGestureRecognizer:tap];
//        
//        
//        NSClickGestureRecognizer *gesture = [[NSClickGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewClick:)];
//        gesture.numberOfClicksRequired = 1;
//        [self.icon addGestureRecognizer:gesture];
    }
    [self updateStatus];
}
- (void)lableTap{
    NSLog(@"lableTap NSGestureRecognizer set action");
}
- (void)imageViewClick:(NSClickGestureRecognizer *)ges{
    NSLog(@"imageTap NSGestureRecognizer init action");
}
-(void)updateStatus{
    if (self.selected) {
        self.view.layer.backgroundColor = [NSColor lightGrayColor ].CGColor;
    }else{
        self.view.layer.backgroundColor = [NSColor clearColor ].CGColor;
    }
}
@end
