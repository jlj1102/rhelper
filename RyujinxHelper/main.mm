//
//  main.mm
//  RyujinxKeyboard
//
//  Created by Stossy11 on 11/02/2025.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef void (^SwiftCallback)(NSString *result);
    
static char *keyboardInput = NULL;

UIWindowScene *getMainDeviceWindowScene() {
    for (UIWindowScene *scene in UIApplication.sharedApplication.connectedScenes) {
        if ([scene isKindOfClass:[UIWindowScene class]]) {
            if (scene.screen == UIScreen.mainScreen) {
                return scene;
            }
        }
    }
    
    for (UIWindowScene *scene in UIApplication.sharedApplication.connectedScenes) {
        if ([scene isKindOfClass:[UIWindowScene class]]) {
            return scene;
        }
    }
    
    return nil;
}
    
void showKeyboardAlert(const char *title, const char *message, const char *placeholder) {
    NSString *alertTitle = [NSString stringWithUTF8String:title];
    NSString *alertMessage = [NSString stringWithUTF8String:message];
    NSString *alertPlaceholder = [NSString stringWithUTF8String:placeholder];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindowScene *activeScene = getMainDeviceWindowScene();
        if (!activeScene) {
            return;
        }
        
        UIWindow *popupWindow = [[UIWindow alloc] initWithWindowScene:activeScene];
        popupWindow.frame = UIScreen.mainScreen.bounds;
        popupWindow.windowLevel = UIWindowLevelAlert + 1;
        popupWindow.backgroundColor = [UIColor clearColor];
        
        UIViewController *tempViewController = [[UIViewController alloc] init];
        popupWindow.rootViewController = tempViewController;
        [popupWindow makeKeyAndVisible];
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                                                 message:alertMessage
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = alertPlaceholder;
        }];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action) {
            NSString *inputText = alertController.textFields.firstObject.text;
            
            if (keyboardInput) {
                free(keyboardInput);
                keyboardInput = NULL;
            }
            
            if (inputText.length > 0) {
                keyboardInput = strdup([inputText UTF8String]);
            }
            
            popupWindow.hidden = YES;
            popupWindow.rootViewController = nil;
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction *action) {
            if (keyboardInput) {
                free(keyboardInput);
            }
            keyboardInput = strdup("");
            
            popupWindow.hidden = YES;
            popupWindow.rootViewController = nil;
        }];
        
        [alertController addAction:okAction];
        [alertController addAction:cancelAction];
        
        [tempViewController presentViewController:alertController animated:YES completion:nil];
    });
}

void showAlert(const char *title, const char *message, bool showCancel) {
    NSString *alertTitle = [NSString stringWithUTF8String:title];
    NSString *alertMessage = [NSString stringWithUTF8String:message];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindowScene *activeScene = getMainDeviceWindowScene();
        if (!activeScene) {
            return;
        }
        
        UIWindow *popupWindow = [[UIWindow alloc] initWithWindowScene:activeScene];
        popupWindow.frame = UIScreen.mainScreen.bounds;
        popupWindow.windowLevel = UIWindowLevelAlert + 1;
        popupWindow.backgroundColor = [UIColor clearColor];
        
        UIViewController *tempViewController = [[UIViewController alloc] init];
        popupWindow.rootViewController = tempViewController;
        [popupWindow makeKeyAndVisible];
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                                                 message:alertMessage
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action) {
            popupWindow.hidden = YES;
            popupWindow.rootViewController = nil;
        }];
        
        [alertController addAction:okAction];
        
        if (showCancel) {
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:^(UIAlertAction *action) {
                popupWindow.hidden = YES;
                popupWindow.rootViewController = nil;
            }];
            [alertController addAction:cancelAction];
        }
        
        [tempViewController presentViewController:alertController animated:YES completion:nil];
    });
}

const char *getKeyboardInput() {
    if (keyboardInput) {
        return keyboardInput;
    }
    return NULL;
}

void clearKeyboardInput() {
    if (keyboardInput) {
        free(keyboardInput);
        keyboardInput = NULL;
    }
}

static NSMutableDictionary<NSString*, SwiftCallback> *callbackStore;

void RegisterCallback(NSString *identifier, SwiftCallback callback) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        callbackStore = [NSMutableDictionary new];
    });

    if (identifier && callback) {
        @synchronized(callbackStore) {
            callbackStore[identifier] = [callback copy]; // copy blocks
        }
    }
}

void TriggerCallback(const char *cIdentifier) {
    if (!cIdentifier) return;

    // Convert C string to NSString
    NSString *identifier = [NSString stringWithUTF8String:cIdentifier];
    if (!identifier) return;

    SwiftCallback callback = nil;
    @synchronized(callbackStore) {
        callback = callbackStore[identifier];
        if (callback) {
            [callbackStore removeObjectForKey:identifier]; // optional: remove after call
        }
    }
    if (callback) {
        callback(identifier);
    }
}

#ifdef __cplusplus
}
#endif
