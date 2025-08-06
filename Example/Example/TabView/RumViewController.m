//
//  RumViewController.m
//  Example
//
//  Created by hulilei on 2023/3/31.
//

#import "RumViewController.h"
#import "FTMacOSSDK.h"
#import "FTResourceContentModel.h"
#import "FTResourceMetricsModel.h"
@interface RumViewController ()<NSTableViewDataSource,NSTableViewDelegate,NSURLSessionDelegate>
@property (nonatomic, strong) NSArray *datas;
@property (weak) IBOutlet NSTableView *mTableView;
@property (nonatomic, copy) NSString *rumKey;
@property (nonatomic, strong) NSURLSessionTaskMetrics *metrics API_AVAILABLE(ios(10.0));
@property (nonatomic, strong) NSData *data;

@end

@implementation RumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self createUI];
}
- (void)createUI{
    self.datas = @[@{@"Event":@"View",@"API":@"onCreateView:loadTime:"},
                   @{@"Event":@"View",@"API":@"startViewWithName:"},
                   @{@"Event":@"View",@"API":@"startViewWithName:property:"},
                   @{@"Event":@"View",@"API":@"stopView"},
                   @{@"Event":@"View",@"API":@"stopViewWithProperty:"},
                   @{@"Event":@"Action",@"API":@"addActionName:actionType:"},
                   @{@"Event":@"Action",@"API":@"addActionName:actionType:property:"},
                   @{@"Event":@"Error",@"API":@"addErrorWithType:message:stack:"},
                   @{@"Event":@"Error",@"API":@"addErrorWithType:message:stack:property:"},
                   @{@"Event":@"LongTask",@"API":@"addLongTaskWithStack:duration:"},
                   @{@"Event":@"LongTask",@"API":@"addLongTaskWithStack:duration:property:"},
                   @{@"Event":@"Resource",@"API":@"step1:startResourceWithKey:  step2:addResourceWithKey:metrics:content:  step3:stopResourceWithKey:"},
    ];
    self.mTableView.backgroundColor = [NSColor redColor];
    self.mTableView.usesAlternatingRowBackgroundColors = YES;
    [self.mTableView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleSourceList];
    self.mTableView.dataSource = self;
    self.mTableView.delegate = self;
    [self.mTableView reloadData];
    [self.mTableView setAction:@selector(clickRow)];
}
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return  self.datas.count;
}
-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSDictionary *data = self.datas[row];
    NSString *key = tableColumn.identifier;
    // Cell data
    NSString *value = [NSString stringWithFormat:@"%@", data[key]];
    // Create cell view based on table column identifier
    NSView *view = [tableView makeViewWithIdentifier:key owner:self];
   
    if (view == nil) {
    
        NSTableCellView *cellView = [NSTableCellView alloc].init;
        view = cellView;
        
        NSTextField *textField =  [NSTextField alloc].init;
        textField.translatesAutoresizingMaskIntoConstraints = NO;
        [textField setBezeled:NO];
        textField.maximumNumberOfLines = 3;
        textField.drawsBackground = NO;

        [cellView addSubview:textField];
        
        NSLayoutConstraint *topAnchor = [textField.topAnchor constraintEqualToAnchor:cellView.topAnchor constant:0];
        NSLayoutConstraint *bottomAnchor = [textField.bottomAnchor constraintEqualToAnchor:cellView.bottomAnchor constant:0];

        NSLayoutConstraint *leftAnchor = [textField.leftAnchor constraintEqualToAnchor:cellView.leftAnchor constant:0];

        NSLayoutConstraint *rightAnchor = [textField.rightAnchor constraintEqualToAnchor:cellView.rightAnchor constant:0];

        [NSLayoutConstraint activateConstraints:@[topAnchor,bottomAnchor,leftAnchor, rightAnchor]];
    }
    
    NSArray *subviews = view.subviews;
    if (subviews.count <= 0){
        return nil;
    }
    
    NSTextField *textField = subviews[0];

    if (value != nil) {
        textField.stringValue = value;
    }
    
    return view;
}
-(void)clickRow{
    switch (self.mTableView.clickedRow) {
        case 0:
            [[FTGlobalRumManager sharedManager] onCreateView:@"RumViewController" loadTime:@10000000];
            break;
        case 1:
            [[FTGlobalRumManager sharedManager] startViewWithName:@"RumViewController"];
            break;
        case 2:
            [[FTGlobalRumManager sharedManager] startViewWithName:@"RumViewController" property:@{@"view_property":@"custom_startView"}];
            break;
        case 3:
            [[FTGlobalRumManager sharedManager] stopView];
            break;
        case 4:
            [[FTGlobalRumManager sharedManager] stopViewWithProperty:@{@"view_property":@"custom_stopView"}];
            break;
        case 5:
            [[FTGlobalRumManager sharedManager] addActionName:@"[NSTableCellView]" actionType:@"click"];
            break;
        case 6:
            [[FTGlobalRumManager sharedManager] addActionName:@"[NSTableCellView]" actionType:@"click" property:@{@"action_property":@"addAction"}];
            break;
        case 7:
            [[FTGlobalRumManager sharedManager] addErrorWithType:@"macOS" message:@"ERROR_MESSAGE" stack:@"ERROR_STACK"];
            break;
        case 8:
            [[FTGlobalRumManager sharedManager] addErrorWithType:@"macOS" message:@"ERROR_MESSAGE" stack:@"ERROR_STACK" property:@{@"error_property":@"addError"}];
            break;
        case 9:
            [[FTGlobalRumManager sharedManager] addLongTaskWithStack:@"LongTask_Stack" duration:@1000000000];

            break;
        case 10:
            [[FTGlobalRumManager sharedManager] addLongTaskWithStack:@"LongTask_Stack" duration:@1000000000 property:@{@"longtask_property":@"addLongTask"}];
            break;
        case 11:
            [self manualRumResource];
            break;
        default:
            break;
    }
}
- (void)manualRumResource{
    self.rumKey = [[NSUUID UUID]UUIDString];
    NSString *urlStr = [[NSProcessInfo processInfo] environment][@"TRACE_URL"];

    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSURLSession *session=[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    [[FTGlobalRumManager sharedManager] startResourceWithKey:self.rumKey];
    NSURLSessionTask *task = [session dataTaskWithRequest:request];
    
    [task resume];
    
}
- (IBAction)doubleAction:(id)sender {
    NSLog(@"doubleAction");
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didFinishCollectingMetrics:(NSURLSessionTaskMetrics *)metrics API_AVAILABLE(macosx(10.12), ios(10.0), watchos(3.0), tvos(10.0)){
    self.metrics = metrics;
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data{
    self.data = data;

}
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{

    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;

    [[FTGlobalRumManager sharedManager] stopResourceWithKey:self.rumKey];
    
    FTResourceMetricsModel *metricsModel = [[FTResourceMetricsModel alloc]initWithTaskMetrics:self.metrics];


    FTResourceContentModel *content = [[FTResourceContentModel alloc]initWithRequest:task.currentRequest response:httpResponse data:self.data error:error];
    [[FTGlobalRumManager sharedManager] addResourceWithKey:self.rumKey metrics:metricsModel content:content];
}
@end
