#include <stdio.h>
#include <windows.h>
typedef char* (__stdcall *f_ptr)();
HINSTANCE dll;
f_ptr func;

int main(int argc, char **argv, char **env)
{
  if (! (dll = LoadLibrary("interp.dll"))) {
    printf("cannot load dll.");
    return 1;
  }
  printf("Loaded.");
  if (! (func = (f_ptr)GetProcAddress(dll, "perl_interp"))) {
    printf("cannot load msg.");
    return 1;
  }
  func();
  
  return 0;
}
