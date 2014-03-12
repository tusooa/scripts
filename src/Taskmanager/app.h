#ifndef APP_H
#define APP_H
#include <kapplication.h>
#include <X11/Xlib.h>
class App : public KApplication
{
  Q_OBJECT
 public:
  App();
 signals:
  void WindowPropertyChanged(Window window, Atom atom);
 protected:
  bool x11EventFilter(XEvent *event);
};
#endif
