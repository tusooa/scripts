#include <stdio.h>
#include <windows.h>
typedef void (__stdcall *f_ptr)();
HINSTANCE dll;
f_ptr func;

int main(int argc, char **argv, char **env)
{
  int ret;
  if (! (dll = LoadLibrary("interp.dll"))) {
    printf("cannot load dll.");
    return 1;
  }
  printf("Loaded.");
  if (! (func = (f_ptr)GetProcAddress(dll, "about"))) {
    printf("cannot load `about'.");
    return 1;
  }
  func();
  ret = FreeLibrary(dll);
  if (ret == 0) {
    printf("error%s\n", GetLastError());
  }
  return 0;
}
