#include <kconfiggroup.h>

#define WINDOW_CPP
#include "window.h"
#include "window-lib.h"
#include <iostream>
#include <stdlib.h>
#include <kicon.h>
#include <qpainter.h>
#include <qimage.h>
#include "app.h"
#include <kapplication.h>

TaskWin::TaskWin(QWidget *parent) : KMainWindow(parent)
{
  commonSize = QSize(50, 50);
  buttonSize = QSize(45, 45);
  iconSize = buttonSize;
  Display *dd = XOpenDisplay(NULL);
  root = RootWindow(dd, DefaultScreen(dd));
  bigSize = QSize(DisplayHeight(dd, DefaultScreen(dd)), 50);
  XFree(dd);
  initXpm();
  initConf();
  initLaunchers();

  mainWidget = new QWidget();
  layout = new QVBoxLayout(mainWidget);
  initButton();
  setCentralWidget(mainWidget);
  connect(kapp, SIGNAL(WindowPropertyChanged(Window, Atom)), this, SLOT(handlePropertyNotify(Window, Atom)));
  space = new QSpacerItem(buttonSize.width(), buttonSize.height());
  layout->addSpacerItem(space); //how to hide???
  //  mainWidget->resize(50, 50);
  
  resize(commonSize);
  setStyleSheet("background:transparent;");
  setAttribute(Qt::WA_TranslucentBackground);
  setAttribute(Qt::WA_AlwaysShowToolTips);
  setWindowFlags(Qt::FramelessWindowHint);
  setWindowHints(winId());
  setGeometry(0, 0, commonSize.width(), commonSize.height());
  setStrut(winId(), size().width(), 0, 0, 0);
  //setupGUI();
}

void TaskWin::initConf()
{
  QString configPath = getenv("XDG_CONFIG_HOME");
  if (configPath == QString()) {
    configPath = getenv("HOME");
    configPath.append("/.config");
  }
  configPath += "/Scripts/taskmanager";
  config = new KConfig(configPath);
}

void TaskWin::initLaunchers()
{
  KConfigGroup launchersGroup(config, "Launchers");
  int i = 0;
  QList<QString> list = launchersGroup.groupList();
  qSort(list);
  for (;i < list.count();i++ ) {
    KConfigGroup group(&launchersGroup, list[i]);
    launchers << new HoverButton();
    launchers[i]->setLauncher(group.readEntry("command", QString("ls")));
//std::cout << "icon:\"" <<group.readEntry("icon", "kde").toStdString()<<"\"" <<std::endl;
    launchers[i]->setPixmap(KIcon(group.readEntry("icon", "kde")).pixmap(iconSize));
    // FIXME: Launcher list will be closed when the mouse goes on the tooltip.
    //launchers[i]->setToolTip(group.readEntry("name", list[i]));
    connect(launchers[i], SIGNAL(clicked()), launchers[i], SLOT(startLauncher()));
    //connect(launchers[i], SIGNAL(mouseHoverIn()), launchers[i], SLOT(showMessage()));
    //connect(launchers[i], SIGNAL(mouseHoverOut()), launchers[i], SLOT(hideMessage()));
  }
}

void TaskWin::initXpm()
{
  static const char * const triangleXpm[] = {
"9 9 2 1",
"       c None",
".      c #FFFFFF",
"..       ",
"....     ",
"......   ",
"........ ",
".........",
"........ ",
"......   ",
"....     ",
"..       "};
  triangle = QImage(triangleXpm);
}

void TaskWin::initButton()
{
  button = new HoverButton();
  button->setPixmap(KIcon("kde").pixmap(iconSize));
  connect(button, SIGNAL(mouseHoverIn()), this, SLOT(showLaunchers()));
  //connect(button, SIGNAL(mouseHoverOut()), this, SLOT(hideLaunchers()));
  layout->addWidget(button);
  button->resize(buttonSize);
}

void TaskWin::updateIcon(HoverButton *hb)
{
  QPixmap pixmap = getWindowIcon(hb->getWindow(),iconSize);
  //QPixmap icon(buttonSize);
  QPainter painter(&pixmap);
  //painter.drawPixmap(buttonSize.width()-iconSize.width(), 0, pixmap);
  painter.drawImage(0, buttonSize.height()/2-9/2, triangle);//*准备*支持分组
  hb->setPixmap(pixmap);
  //hb->show();
  //std::cout << "update icon\n";
}

void TaskWin::showApps()
{
  //if (!buttons.empty()) return;
  //std::cout << "showApps\n";
  //QList<WId> oldWindows = windows;
  windows = getWindowList();
  //QList<QWidget*> buttons;
  int pos = 0;
  //QImage triangle(triangleXpm);
  for (;pos < windows.count();pos++) {
    //    KIcon icon;
    //icon.addPixmap(getWindowIcon(windows.at(pos)));
    HoverButton *thisButton;
    if (!(thisButton = getFromWindowList(windows[pos]))) {
      buttons << new HoverButton();
      thisButton = buttons.last();
      thisButton->setToolTip(getWindowTitle(windows[pos]));
      thisButton->setWindow(windows[pos]);
      updateIcon(thisButton);
      connect(thisButton, SIGNAL(clicked()), thisButton, SLOT(switchToWindow()));
      connect(thisButton, SIGNAL(rightClicked()), thisButton, SLOT(iconifyWindow()));
      //connect(thisButton, SIGNAL(mouseHoverIn()), thisButton, SLOT(showMessage()));
      //connect(thisButton, SIGNAL(mouseHoverOut()), thisButton, SLOT(hideMessage()));
      layout->addWidget(thisButton);
      thisButton->show();
    }
  }
  // remove old windows
  for (pos = 0;pos < buttons.count();pos++) {
    HoverButton * thisButton = buttons[pos];
    if (windows.indexOf(thisButton->getWindow()) == -1/* && thisButton->getLauncher() == QString()*//* is not a launcher */) {
      thisButton->hide();
      layout->removeWidget(thisButton);
      buttons.removeAt(pos);
      pos--;
      thisButton->~HoverButton();
    }
  }
  setMaximumHeight(bigSize.height());
  //resize(bigSize);
}

void TaskWin::hideApps()
{
  int pos = 0;
  for (;pos < windows.count();pos++) {
    layout->removeWidget(buttons[pos]);
    //buttons[pos]->~HoverButton();
  }
  //buttons.clear();
  //windows.clear();
  //resize(commonSize);
  //setMaximumSize(commonSize);
  //std::cout << "Size:"<< size().width() << "x" << size().height() <<"\n";
}
//void TaskWin::reshowApps()
//{
//  int pos = 0;
//  for (;pos < windows.count();pos++) {
//    layout->addWidget(buttons[pos]);
//    //buttons[pos]->~HoverButton();
//  }
//}

HoverButton * TaskWin::getFromWindowList(WId window)
{
  //std::cout << "this window:" << window << "\n";
  for (int i=0; i < buttons.count(); i++) {
    //std::cout << buttons.at(i)->getWindow() << "\n";
    if (buttons.at(i)->getWindow() == window) {
      return buttons.at(i);
    }
  }
  return 0;
}

void TaskWin::handlePropertyNotify(Window window, Atom atom)
{
  //std::cout << "PropertyNotify\n";
  if (window == root && atom == 483) { // 483, atom _NET_CLIENT_LIST
    //hideApps();
    showApps();
    return;
  }
  HoverButton *hb = getFromWindowList(window);
  if (!hb) {
    return;
  }
  // FIXME: It doesn't work!
  if (atom == 372) { // 372, _NET_WM_ICON
    //hideApps();
    //showApps();
    updateIcon(hb);
    hb->show();
    return;
  }
  if (atom == 757) { // _WM_NAME
    //std::cout << window << " title changed\n";
    hb->setToolTip(getWindowTitle(window));
  }
}

bool TaskWin::event(QEvent *event)
{
  if (event->type() == QEvent::HoverLeave) {
    hideLaunchers();
    return true;
  }
  return QWidget::event(event);
}

void TaskWin::showLaunchers()
{
  int pos = 0;
  for (; pos < launchers.count(); pos++) {
    layout->insertWidget(pos+1, launchers[pos]);
    launchers[pos]->show();
  }
}

void TaskWin::hideLaunchers()
{
  for (int pos = 0; pos < launchers.count();pos++) {
    launchers[pos]->hide();
    layout->removeWidget(launchers[pos]);
  }
}
