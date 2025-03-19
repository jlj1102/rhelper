//
//  main.h
//  RyujinxKeyboard
//
//  Created by Stossy11 on 11/02/2025.
//

#ifdef __cplusplus
extern "C" {
#endif

void showAlert(const char *title, const char *message, bool showCancel);

void showKeyboardAlert(const char *title, const char *message, const char *placeholder);

const char *getKeyboardInput();

void clearKeyboardInput();

#ifdef __cplusplus
}
#endif
