//
//  main.h
//  RyujinxKeyboard
//
//  Created by Stossy11 on 11/02/2025.
//

#ifdef __cplusplus
extern "C" {
#endif

typedef void (^SwiftCallback)(NSString *result);

void RegisterCallback(NSString *identifier, SwiftCallback callback);
void TriggerCallback(const char *cIdentifier);

void showAlert(const char *title, const char *message, bool showCancel);

void showKeyboardAlert(const char *title, const char *message, const char *placeholder);

const char *getKeyboardInput();

void clearKeyboardInput();

#ifdef __cplusplus
}
#endif
