#include "hoverbutton.h"
#include <qevent.h>
#include <iostream>
#include "window-lib.h"
#include <qstring.h>
#include <unistd.h>
//#include <qpixmap.h>
HoverButton::HoverButton(QWidget *parent) : HB_PARENT(parent)
{
  label = new QLabel();
  layout = new QVBoxLayout();
  setLayout(layout);
  layout->setMargin(0);
  layout->addWidget(label);
  setMinimumHeight(50);
  setMaximumHeight(50);
  setMinimumWidth(50);
  setMaximumWidth(50);
  window = 0;
  //launcher = QList<QString>();
}
void HoverButton::setPixmap(QPixmap pix)
{
  label->setPixmap(pix);
}
bool HoverButton::event(QEvent *event)
{
  if (event->type() == QEvent::HoverEnter) {
    emit mouseHoverIn();
    return true;
  }
  if (event->type() == QEvent::MouseButtonRelease) {
    QMouseEvent *mouseEvent = static_cast<QMouseEvent*>(event);
    if (mouseEvent->button() == Qt::RightButton) {
      emit rightClicked();
      return true;
    }
  }
  return QWidget::event(event);
}
void HoverButton::setWindow(WId id)
{
  window = id;
}

WId HoverButton::getWindow()
{
  //std::cout << "returning window\n";
  if (window) return window;
  return 0;
}
void HoverButton::switchToWindow()
{
  switchToOrIconify(window);
}
void HoverButton::iconifyWindow()
{
  iconify(window);
}

void HoverButton::setLauncher(QString str)
{
  launcher = str;
}
QString HoverButton::getLauncher()
{
  return launcher;
}
void HoverButton::startLauncher()
{
  pid_t pid = fork();
  if (pid < 0) {
    std::cout << "error: Unable to fork().\n";
    return;
  } else if (pid == 0) {
    //std::cout << "starting " << launcher[0].toStdString() << std::endl;
    if (system(launcher.toStdString().c_str())) {
      std::cout << "system() error: unable to run program.\n";
      exit(1);
    }
    exit(0);
  } else {
    //do nothing;
    //std::cout << "yes?\n";
  }
}

//void HoverButton::setMessage(QString str)
//{
//  message = str;
//}

//void HoverButton::showMessage()
//{
//  // todo
//}

//void HoverButton::hideMessage()
//{
//  // todo
//}
