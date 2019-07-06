#include <QApplication>
#include <QQmlApplicationEngine>
#include "iconprovider.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    engine.addImageProvider(QLatin1String("iconProvider"), new IconProvider());
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
