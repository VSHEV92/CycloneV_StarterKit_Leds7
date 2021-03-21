#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QSerialPort>
#include <QDebug>

QT_BEGIN_NAMESPACE
namespace Ui { class MainWindow; }
QT_END_NAMESPACE

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

private slots:
    void on_Start_clicked();

    void on_Stop_clicked();

    void on_LED3_Value_valueChanged(int arg1);

    void on_LED2_Value_valueChanged(int arg1);

    void on_LED1_Value_valueChanged(int arg1);

    void on_LED0_Value_valueChanged(int arg1);

private:
    Ui::MainWindow *ui;
    QSerialPort uart_port;
};
#endif // MAINWINDOW_H
