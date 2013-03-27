#import "QuickDialogController+Navigation.h"
#import "QRootBuilder.h"
#import "QuickDialog.h"

@implementation QuickDialogController(Navigation)

- (void)displayViewController:(UIViewController *)newController {
    if ([newController isKindOfClass:[UINavigationController class]]) {
        [self presentModalViewController:newController animated:YES];
    }
    else if (self.navigationController != nil){
        [self.navigationController pushViewController:newController animated:YES];
    } else {
        [self presentModalViewController:[[UINavigationController alloc] initWithRootViewController:newController] animated:YES];
    }
}

- (void)displayViewController:(UIViewController *)newController withPresentationMode:(QPresentationMode)mode {
    if (mode==QPresentationModeNormal) {
        [self displayViewController:newController];
    } else if (mode == QPresentationModePopover || mode == QPresentationModeNavigationInPopover) {
        [self displayViewControllerInPopover:newController withNavigation:mode==QPresentationModeNavigationInPopover];
    } else if (mode == QPresentationModeModalForm) {
        UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController :newController];
        newController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(dismissModalViewController)];
        navigation.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentModalViewController:navigation animated:YES];
    }  else if (mode == QPresentationModeModalFullScreen) {
        UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController :newController];
        newController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(dismissModalViewController)];
        navigation.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentModalViewController:navigation animated:YES];
    }  else if (mode == QPresentationModeModalPage) {
        UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController :newController];
        newController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(dismissModalViewController)];
        navigation.modalPresentationStyle = UIModalPresentationPageSheet;
        [self presentModalViewController:navigation animated:YES];
    }
}

- (void)displayViewControllerForRoot:(QRootElement *)root {
    QuickDialogController *newController = [self controllerForRoot: root];
    [self displayViewController:newController withPresentationMode:root.presentationMode];
}

- (void)dismissModalViewController {
    [self dismissModalViewControllerAnimated:YES];

}

- (void)displayViewControllerInPopover:(UIViewController *)newController withNavigation:(BOOL)navigation fromRect:(CGRect)position {

    if ([UIDevice currentDevice].userInterfaceIdiom!=UIUserInterfaceIdiomPad){
        [self displayViewController:newController];
        return;
    }

    UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:
        navigation ? [[UINavigationController alloc] initWithRootViewController :newController] : newController
    ];
    popoverController.popoverContentSize = CGSizeMake(320, 360);
    if ([newController respondsToSelector:@selector(setPopoverBeingPresented:)]) {
        [newController performSelector:@selector(setPopoverBeingPresented:) withObject:popoverController];
    } else {
        self.popoverForChildRoot = popoverController;
    }
    popoverController.delegate = self;

    [popoverController presentPopoverFromRect:position inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)displayViewControllerInPopover:(UIViewController *)newController withNavigation:(BOOL)navigation {

    CGRect position = [self.quickDialogTableView rectForRowAtIndexPath:self.quickDialogTableView.indexPathForSelectedRow];
    [self displayViewControllerInPopover:newController withNavigation:navigation fromRect:position];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    [self.quickDialogTableView reloadData];
    self.popoverForChildRoot = nil;
}

- (void)popToPreviousRootElementOnMainThread {
    if ([self popoverBeingPresented]!=nil){
        [self.popoverBeingPresented dismissPopoverAnimated:YES];
        if (self.popoverBeingPresented.delegate!=nil){
            [self.popoverBeingPresented.delegate popoverControllerDidDismissPopover:self.popoverBeingPresented];
        }
    }
    else if (self.navigationController!=nil && [self.navigationController.viewControllers objectAtIndex:0]!=self){
        [self.navigationController popViewControllerAnimated:YES];
    } else if (self.presentingViewController!=nil)
        [self dismissViewControllerAnimated:YES completion:nil];
    else {
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (void)popToPreviousRootElement {
    [self performSelectorOnMainThread:@selector(popToPreviousRootElementOnMainThread) withObject:nil waitUntilDone:YES];
}

@end
