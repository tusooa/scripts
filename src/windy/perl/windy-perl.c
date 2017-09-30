#include "windy-perl.h"
#include <stdio.h>
typedef char* (__stdcall *f_ptr)();
HINSTANCE dll;
f_ptr func;

const char * msg() {
  if ((dll = LoadLibrary("Message.dll")) == NULL) {
    printf("cannot load dll.");
    //printf("last err: %s",GetLastError());
    return "fail";
  }
  printf("Loaded.");
  if (! (func = (f_ptr)GetProcAddress(dll, "msg"))) {
    printf("cannot load msg.");
    return "fail";
  }
  return "mew mew~";
}
