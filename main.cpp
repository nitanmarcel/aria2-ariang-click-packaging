#include <QGuiApplication>
#include <QCoreApplication>
#include <QUrl>
#include <QString>
#include <QQuickView>
#include <QDir>
#include <QStandardPaths>
#include <QProcess>

#include "qhttpserver.hpp"
#include "qhttpserverconnection.hpp"
#include "qhttpserverrequest.hpp"
#include "qhttpserverresponse.hpp"

#include <map>
#include <stdlib.h>

std::map<std::string, std::string> mimes;

int main(int argc, char *argv[])
{
    QString applicationName = "ariang.nitanmarcel";

    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication *app = new QGuiApplication(argc, (char**)argv);
    app->setApplicationName(applicationName);

    qDebug() << "Starting app from main.cpp";
    
    QString clickConfigPath = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation) + QDir::separator() + applicationName;
    QString clockStoragePath = QStandardPaths::writableLocation(QStandardPaths::DataLocation) + QDir::separator() + applicationName;

    qDebug() << "Config path" << clickConfigPath;
    QDir clickConfigDir(clickConfigPath);
    QString ariaConfigPath = clickConfigPath + QDir::separator() + "aria.conf";
    QFile ariaConfigFile(ariaConfigPath);
    
    QFile prebuildAriaConfigFile("aria2.conf");

    if (!clickConfigDir.exists())
        clickConfigDir.mkpath(".");

    if (!ariaConfigFile.exists())
        prebuildAriaConfigFile.copy(ariaConfigPath);

    qputenv("LD_PRELOAD", "");

    QString program = QDir::currentPath() + "/bin/aria2c";
    QStringList arguments;
    arguments << "--conf-path=" + ariaConfigPath;
    arguments << "--enable-rpc";
    arguments << "--rpc-allow-origin-all";
    arguments << "--dir=" + clockStoragePath + QDir::separator() + "/Downloads";

    QProcess aria;
    aria.start(program, arguments);

    mimes[".html"] = "text/html";
    mimes[".css"] = "text/css";
    mimes[".js"] = "application/javascript";
    mimes[".woff2"] = "application/font-woff2";
    mimes[".png"] = "image/png";
    mimes[".icon"] = "image/x-icon";
    mimes[".ico"] = "image/x-icon";
    mimes[".eot"] = "application/octet-stream";
    mimes[".svg"] = "image/svg+xml";

    qhttp::server::QHttpServer server;
    server.listen(QHostAddress::LocalHost, 6888,
                  [](qhttp::server::QHttpRequest *req, qhttp::server::QHttpResponse *res)
                  {
                      QString docname = "./www" + (req->url().toString()==("/") ?("/index.html"):req->url().toString());
                      if (!QFile(docname).exists())
                          docname = QString("./www/index.html");
                      QFile doc(docname);
                      doc.open(QFile::ReadOnly);

                      res->addHeader("Content-Length", QString::number(doc.size()).toUtf8());
                      res->addHeader("Connection", "keep-alive");

                      auto doc_str = docname.toStdString();
                      auto doc_ext = doc_str.substr(doc_str.find_last_of('.'));
                      if (mimes.count(doc_ext) > 0)
                          res->addHeader("Content-Type", mimes[doc_ext].data());
                      else
                          res->addHeader("Content-Type", "application/octet-stream");
                      res->setStatusCode(qhttp::TStatusCode::ESTATUS_OK);
                      res->write(doc.readAll());
                  });

    QQuickView *view = new QQuickView();
    view->setSource(QUrl("qrc:/Main.qml"));
    view->setResizeMode(QQuickView::SizeRootObjectToView);
    view->show();

    return app->exec();
}
