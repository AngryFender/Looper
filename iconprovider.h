#ifndef ICONPROVIDER_H
#define ICONPROVIDER_H
#include <QQuickImageProvider>
#include <QFileIconProvider>
#include <QMimeDatabase>
#include <QFileInfo>
#include <QDebug>
#include <QObject>


class IconProvider : public QQuickImageProvider
{

public:
    IconProvider();
    QPixmap requestPixmap(const QString &id, QSize *size, const QSize &requestedSize);

protected:
    QFileIconProvider fileIconsProvider;
    QMimeDatabase     mimeDatabase;
};

#endif // ICONPROVIDER_H
