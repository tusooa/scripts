#ifndef HOVERBUTTON_H
#define HOVERBUTTON_H
#define HB_PARENT KPushButton
#include <qlabel.h>
#include <kpushbutton.h>
#include <qboxlayout.h>
#include <qlist.h>
class HoverButton : public HB_PARENT
{
  Q_OBJECT
  
 public:
  HoverButton(QWidget *parent=0);
  void setPixmap(QPixmap pix);
  void setWindow(WId id);
  WId getWindow();
  QString getLauncher();
  void setLauncher(QString str);
  //void setLauncher(QList<const char *> str);
  //void setLauncher(QString str);
  //void setMessage(QString str);
 private:
  QLabel *label;
  QVBoxLayout *layout;
  WId window;
  QString launcher;
  //QString message;
 private slots:
   void switchToWindow();
   void startLauncher();
   void iconifyWindow();
   //   void showMessage();
   //void hideMessage();
 signals:
  void mouseHoverIn();
  void mouseHoverOut();
  void rightClicked();
 protected:
  bool event(QEvent * event);
};
#endif
