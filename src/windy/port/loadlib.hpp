#ifndef LOADLIB_HPP
#define LOADLIB_HPP
#include <windows.h>
#include <stdlib.h>
#include <iostream>
#include <fstream>
#include <stdexcept>
HINSTANCE dll;
#include "defs.hpp.part"

void croak(const char * string)
{
  std::ofstream of("windy.err.txt", std::ios_base::app);
  of << string << std::endl;
  of.close();
  std::cout << string << std::endl;
  throw std::runtime_error(string);
}

void loadLibs()
{
  if (! (dll = LoadLibrary("Message.dll"))) {
    croak("cannot load dll.");
  }
#include "load.hpp.part"
}

void freeLibs()
{
  FreeLibrary(dll);
}
#endif
