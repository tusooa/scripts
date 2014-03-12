#include "kde-window.h"
#include <iostream>
void setWindowHints(WId id)
{
  KWindowSystem::setType(id, NET::Dock);
  KWindowSystem::setOnAllDesktops(id, true);
}

void setStrut(WId id, int left, int right, int top, int bottom)
{
  KWindowSystem::setStrut(id, left, right, top, bottom);
}

QString getWindowTitle(WId id)
{
  KWindowInfo info = KWindowSystem::windowInfo(id, NET::WMName);
  return info.name();
}


QList<WId> getWindowList()
{
  QList<WId> windows = KWindowSystem::windows();
  for (int i = 0; i < windows.count(); i++) {
    KWindowInfo window = KWindowSystem::windowInfo(windows.at(i), (NET::WMGeometry | NET::WMFrameExtents | NET::WMWindowType | NET::WMDesktop | NET::WMState | NET::XAWMState | NET::WMVisibleName));
    NET::WindowType type = window.windowType(NET::NormalMask | NET::DialogMask | NET::OverrideMask | NET::UtilityMask | NET::DesktopMask | NET::DockMask | NET::TopMenuMask | NET::SplashMask | NET::ToolbarMask | NET::MenuMask);
    
    std::cout << window.name().toStdString() << std::endl;
    if (type == NET::Desktop || type == NET::Dock || type == NET::TopMenu || type == NET::Splash || type == NET::Menu || type == NET::Toolbar || window.hasState(NET::SkipPager)) {
      windows.removeAt(i);
      i--;
      continue;
    }
    std::cout << window.name().toStdString() << " here" << std::endl;
  }
  return windows;
}
QPixmap getWindowIcon(WId window)
{
  QPixmap pix = KWindowSystem::icon(window);
  return pix;
}
QPixmap getWindowIcon(WId window, QSize size)
{
  QPixmap pix = KWindowSystem::icon(window, size.width(), size.height(), true);
  return pix;
}
void switchTo(WId window)
{
  KWindowSystem::activateWindow(window);
}
void iconify(WId window)
{
  KWindowSystem::minimizeWindow(window);
}
void switchToOrIconify(WId window)
{
  if (KWindowSystem::activeWindow() == window) {
    iconify(window);
  } else {
    switchTo(window);
  }
}
