#include "app.h"
#include <iostream>
App::App() : KApplication()
{}
bool App::x11EventFilter(XEvent *event)
{
  if (event->type == PropertyNotify) {
    emit WindowPropertyChanged(event->xproperty.window, event->xproperty.atom);
    return false;
  }
  return KApplication::x11EventFilter(event);
}
