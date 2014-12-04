#ifndef ARTWORKSDIRECTORIES_H
#define ARTWORKSDIRECTORIES_H

#include <QAbstractListModel>
#include <QStringList>
#include <QPair>
#include <QSet>

namespace Models {
    class ArtworksDirectories : public QAbstractListModel {
        Q_OBJECT
    public:
        ArtworksDirectories(QObject *parent = 0);
        ArtworksDirectories(const ArtworksDirectories &copy):
            m_DirectoriesList(copy.m_DirectoriesList), m_DirectoriesHash(copy.m_DirectoriesHash) {}
        ~ArtworksDirectories() {}

    public:
        enum ArtworksDirectoriesRoles {
            PathRole = Qt::UserRole + 1,
            UsedImagesCountRole
        };

    public:
        void beginAccountingFiles(const QStringList &items);
        void endAccountingFiles();
    public:
        int getNewItemsCount(const QStringList &items) const;
        bool accountFile(const QString &filepath);
        void removeFile(const QString &filepath);
        void removeDirectory(const QString &directory);
        void removeDirectory(int index)
        {
            const QString &directory = m_DirectoriesList[index];
            m_DirectoriesHash.remove(directory);

            beginRemoveRows(QModelIndex(), index, index);
            m_DirectoriesList.removeAt(index);
            endRemoveRows();
        }

    public:
        int rowCount(const QModelIndex & parent = QModelIndex()) const;
        QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const;

    protected:
        QHash<int, QByteArray> roleNames() const;
    private:
        QStringList m_DirectoriesList;
        QHash<QString, int> m_DirectoriesHash;
    };
}

Q_DECLARE_METATYPE (Models::ArtworksDirectories)

#endif // ARTWORKSDIRECTORIES_H
