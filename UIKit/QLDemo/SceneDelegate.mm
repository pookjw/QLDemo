//
//  SceneDelegate.m
//  QLDemo
//
//  Created by Jinwoo Kim on 6/6/24.
//

#import "SceneDelegate.h"
#import <QuickLook/QuickLook.h>
#import <objc/message.h>
#import <objc/runtime.h>
#import <TargetConditionals.h>

@interface AlternativeSceneDelegate : UIResponder <UIWindowSceneDelegate>
@end

@implementation AlternativeSceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    
}

@end

__attribute__((objc_direct_members))
@interface SceneDelegate () <QLPreviewControllerDataSource, QLPreviewControllerDelegate>
@property (retain, nonatomic, readonly) NSArray<NSURL *> *URLs;
@end

@implementation SceneDelegate
@synthesize URLs = _URLs;

- (void)dealloc {
    [_window release];
    [_URLs release];
    [super dealloc];
}

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    UIWindow *window = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)scene];
    
    UIViewController *rootViewController = [UIViewController new];
    
    rootViewController.view.backgroundColor = UIColor.systemPinkColor;
    
    __weak auto weakSelf = self;
    
    UIButton *presentPreviewControllerButton = [UIButton systemButtonWithPrimaryAction:[UIAction actionWithTitle:@"QLPreviewController" image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        QLPreviewController *previewController = [QLPreviewController new];
        previewController.dataSource = self;
        previewController.delegate = self;
        
        [rootViewController presentViewController:previewController animated:YES completion:nil];
        [previewController release];
    }]];
    
    UIButton *previewSceneActivationButton = [UIButton systemButtonWithPrimaryAction:[UIWindowSceneActivationAction actionWithIdentifier:nil alternateAction:nil configurationProvider:^UIWindowSceneActivationConfiguration * _Nullable(__kindof UIWindowSceneActivationAction * _Nonnull action) {
        /*
         <UISceneConfiguration: 0x60000175c800; name: 0x0; role: UISceneSessionRoleQuickLook> {
             sceneClass = 0x0;
             delegateClass = QLDetachedSceneDelegate;
             storyboard = 0x0;
         }
         */
        
#if TARGET_OS_IOS
//         QLPreviewController이 뜨게 하는건 options 같음
        QLPreviewSceneActivationConfiguration *configuration = [[QLPreviewSceneActivationConfiguration alloc] initWithItemsAtURLs:weakSelf.URLs options:nil];
        UIWindowSceneActivationConfiguration *cofig_2 = [[UIWindowSceneActivationConfiguration alloc] initWithUserActivity:configuration.userActivity];
        
        UIWindowSceneActivationRequestOptions *options = configuration.options;
        
//        UISceneConfiguration *sceneConfiguration = [[UISceneConfiguration alloc] initWithName:nil sessionRole:@"UISceneSessionRoleQuickLook"];
//        sceneConfiguration.delegateClass = AlternativeSceneDelegate.class;
//        object_setInstanceVariable(options, "_quickLookSceneConfiguration", sceneConfiguration);
//        [sceneConfiguration release];
        cofig_2.options = configuration.options;
        [configuration release];
        
        return [cofig_2 autorelease];
        
//        UIWindowSceneActivationConfiguration *config_3 = [[UIWindowSceneActivationConfiguration alloc] initWithUserActivity:[[[NSUserActivity alloc] initWithActivityType:@"ff"] autorelease]];
//        
//        UIWindowSceneActivationRequestOptions *options = [UIWindowSceneActivationRequestOptions new];
//        options.placement = [UIWindowSceneProminentPlacement prominentPlacement];
//        
//        config_3.options = options;
//        [options release];
//        
//        return [config_3 autorelease];
#else
        return nil;  
#endif
    }]];
    
    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[presentPreviewControllerButton, previewSceneActivationButton]];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.distribution = UIStackViewDistributionFillProportionally;
    stackView.alignment = UIStackViewAlignmentFill;
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    [rootViewController.view addSubview:stackView];
    
    [NSLayoutConstraint activateConstraints:@[
        [stackView.centerXAnchor constraintEqualToAnchor:rootViewController.view.centerXAnchor],
        [stackView.centerYAnchor constraintEqualToAnchor:rootViewController.view.centerYAnchor]
    ]];
    
    [stackView release];
    
    window.rootViewController = rootViewController;
    [rootViewController release];
    
    self.window = window;
    [window makeKeyAndVisible];
    [window release];
}

- (NSArray<NSURL *> *)URLs {
    if (auto URLs = _URLs) return URLs;
    
    NSURL *samplePhotosURL = [NSBundle.mainBundle.bundleURL URLByAppendingPathComponent:@"sample_photos" isDirectory:YES];
    NSError * _Nullable error = nil;
    NSArray<NSURL *> *URLs = [[NSFileManager.defaultManager contentsOfDirectoryAtURL:samplePhotosURL includingPropertiesForKeys:nil options:0 error:&error] sortedArrayUsingComparator:^NSComparisonResult(NSURL * _Nonnull obj1, NSURL * _Nonnull obj2) {
        return [obj1.lastPathComponent compare:obj2.lastPathComponent];
    }];
    
    assert(error == nil);
    
    _URLs = [URLs retain];
    return URLs;
}

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return self.URLs.count;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    return self.URLs[index];
}

@end
