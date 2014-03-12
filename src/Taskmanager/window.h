#ifndef WINDOW_H
#define WINDOW_H
#include <kmainwindow.h>
#include <qevent.h>
#include <qboxlayout.h>
#include <qlist.h>
#include <X11/Xlib.h>
#include "hoverbutton.h"
#include <kconfig.h>
#include <QSpacerItem>
#ifndef WINDOW_CPP
#define _DEF extern
#else
#define _DEF
#endif
_DEF Window root;
//class HoverButton;
class TaskWin : public KMainWindow
{
  Q_OBJECT
  
  public:
    TaskWin (QWidget *parent=0);
    
  private:
    HoverButton *button;
    QVBoxLayout *layout;
    QWidget *mainWidget;
    void initButton();
    QList<HoverButton*> buttons;
    QList<HoverButton*> launchers;
    QList<WId> windows;
    QSize commonSize;
    QSize bigSize;
    QSize buttonSize;
    QSize iconSize;
    //static char *triangleXpm[48];
    QImage triangle;
    void initXpm();
    void initLaunchers();
    void updateIcon(HoverButton *hb);
    HoverButton *getFromWindowList(WId window);
    KConfig *config;
    void initConf();
    QSpacerItem *space;
  private slots:
    void showApps();
    void hideApps();
    void handlePropertyNotify(Window window, Atom atom);
    void showLaunchers();
    void hideLaunchers();
 protected:
    bool event(QEvent *event);
};

#endif
