//
//  ViewController.m
//  QLDemo
//
//  Created by Jinwoo Kim on 6/5/24.
//

#import "ViewController.h"
#import <QuickLookUI/QuickLookUI.h>
#import <objc/message.h>
#import <objc/runtime.h>

static void *URLsKey = &URLsKey;

@interface ViewController () <QLPreviewPanelDataSource, QLPreviewPanelDelegate>
@end

@implementation ViewController

- (IBAction)buttonDidTrigger:(NSButton *)sender {
    NSOpenPanel *openPanel = [NSOpenPanel new];
    
    openPanel.canChooseFiles = NO;
    openPanel.canChooseDirectories = YES;
    openPanel.allowsMultipleSelection = NO;
    openPanel.canCreateDirectories = YES;
    openPanel.showsHiddenFiles = YES;
    
    [openPanel runModal];
    
    NSURL *URL = openPanel.URL;
    assert(URL != nil);
    assert([URL startAccessingSecurityScopedResource]);
    
    QLPreviewPanel *previewPanel = [QLPreviewPanel sharedPreviewPanel];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError * _Nullable error = nil;
    NSArray<NSURL *> *contentsOfDirectory = [fileManager contentsOfDirectoryAtURL:URL includingPropertiesForKeys:nil options:0 error:&error];
    
    objc_setAssociatedObject(previewPanel, URLsKey, contentsOfDirectory, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    [previewPanel makeKeyAndOrderFront:nil];
    
    previewPanel.delegate = self;
    previewPanel.dataSource = self;
    [previewPanel reloadData];
}

- (NSInteger)numberOfPreviewItemsInPreviewPanel:(QLPreviewPanel *)panel {
    NSArray<NSURL *> *URLs = objc_getAssociatedObject(panel, URLsKey);
    return URLs.count;
}

- (id<QLPreviewItem>)previewPanel:(QLPreviewPanel *)panel previewItemAtIndex:(NSInteger)index {
    NSArray<NSURL *> *URLs = objc_getAssociatedObject(panel, URLsKey);
    return URLs[index];
}

@end
