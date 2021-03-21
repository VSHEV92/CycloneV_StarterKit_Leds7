#include "mainwindow.h"
#include "ui_mainwindow.h"

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);
    ui->BitRate->addItem("115200");
    ui->BitRate->addItem("9600");
    ui->Port->addItem("COM4");

    uart_port.setDataBits(QSerialPort::Data8);
    uart_port.setParity(QSerialPort::NoParity);
    uart_port.setStopBits(QSerialPort::OneStop);
    uart_port.setFlowControl(QSerialPort::NoFlowControl);
}

MainWindow::~MainWindow()
{
    delete ui;
}


void MainWindow::on_Start_clicked()
{
    bool status;
    ui->LED0_Value->setEnabled(true);
    ui->LED1_Value->setEnabled(true);
    ui->LED2_Value->setEnabled(true);
    ui->LED3_Value->setEnabled(true);
    ui->Stop->setEnabled(true);
    ui->Start->setDisabled(true);
    ui->Port->setDisabled(true);
    ui->BitRate->setDisabled(true);

    uart_port.setPortName(ui->Port->currentText());
    QString BaudRate = (ui->BitRate->currentText());
    uart_port.setBaudRate((qint32)BaudRate.toUInt());
    status = uart_port.open(QIODevice::WriteOnly);
    if (!status) exit(1);
}

void MainWindow::on_Stop_clicked()
{
    ui->LED0_Value->setDisabled(true);
    ui->LED1_Value->setDisabled(true);
    ui->LED2_Value->setDisabled(true);
    ui->LED3_Value->setDisabled(true);
    uart_port.close();
    ui->Start->setEnabled(true);
    ui->Stop->setDisabled(true);
    ui->Port->setEnabled(true);
    ui->BitRate->setEnabled(true);
}

void MainWindow::on_LED3_Value_valueChanged(int arg1)
{
    QByteArray data;
    data.resize(2);
    data[0] = 0xF3;
    data[1] = arg1;
    uart_port.write(data);
}

void MainWindow::on_LED2_Value_valueChanged(int arg1)
{
    QByteArray data;
    data.resize(2);
    data[0] = 0xF2;
    data[1] = arg1;
    uart_port.write(data);
}

void MainWindow::on_LED1_Value_valueChanged(int arg1)
{
    QByteArray data;
    data.resize(2);
    data[0] = 0xF1;
    data[1] = arg1;
    uart_port.write(data);
}

void MainWindow::on_LED0_Value_valueChanged(int arg1)
{
    QByteArray data;
    data.resize(2);
    data[0] = 0xF0;
    data[1] = arg1;
    uart_port.write(data);
}
