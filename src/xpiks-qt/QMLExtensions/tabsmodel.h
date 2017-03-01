/*
 * This file is a part of Xpiks - cross platform application for
 * keywording and uploading images for microstocks
 * Copyright (C) 2014-2017 Taras Kushnir <kushnirTV@gmail.com>
 *
 * Xpiks is distributed under the GNU General Public License, version 3.0
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef TABSMODEL_H
#define TABSMODEL_H

#include <QAbstractListModel>
#include <QSortFilterProxyModel>
#include <QString>
#include <QVector>
#include <vector>
#include <utility>

namespace QMLExtensions {
    class TabsModel : public QAbstractListModel
    {
        Q_OBJECT
    public:
        explicit TabsModel(QObject *parent = 0);

    private:
        enum TabsModel_Roles {
            TabIconPathRole = Qt::UserRole + 1,
            TabComponentPathRole
        };

    private:
        struct TabModel {
            QString m_TabIconPath;
            QString m_TabComponentPath;
            unsigned int m_CacheTag;
        };

        // QAbstractItemModel interface
    public:
        virtual int rowCount(const QModelIndex &parent) const override;
        virtual QVariant data(const QModelIndex &index, int role) const override;
        virtual QHash<int, QByteArray> roleNames() const override;

    public:
        void addSystemTab(const QString &iconPath, const QString &componentPath);
        void addPluginTab(const QString &iconPath, const QString &componentPath);
        bool isActiveTab(int index);
        void escalateTab(int index);
        bool touchTab(int index);

    private:
        void recacheTab(int index);
        void addTab(const QString &iconPath, const QString &componentPath);
        void rebuildCache();

    private:
        QVector<TabModel> m_TabsList;
        // <cache tag, tab index>
        std::vector<std::pair<unsigned int, int> > m_LRUcache;
    };

    class DependentTabsModel: public QSortFilterProxyModel
    {
        Q_OBJECT
    public:
        Q_INVOKABLE void openTab(int index);

    protected:
        virtual void doOpenTab(int index) = 0;
        TabsModel *getTabsModel() const;
        int getOriginalIndex(int index) const;
    };

    class ActiveTabsModel: public DependentTabsModel
    {
        Q_OBJECT
    public:
        explicit ActiveTabsModel(QObject *parent = 0);

    public slots:
        void onInactiveTabOpened(int index);

        // QSortFilterProxyModel interface
    protected:
        virtual bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;\

        // DependentTabsModel interface
    protected:
        virtual void doOpenTab(int index) override;
    };

    class InactiveTabsModel: public DependentTabsModel
    {
        Q_OBJECT
    public:
        explicit InactiveTabsModel(QObject *parent = 0);

    signals:
        void tabOpened(int index);

        // QSortFilterProxyModel interface
    protected:
        virtual bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;

        // DependentTabsModel interface
    protected:
        virtual void doOpenTab(int index) override;
    };
}

#endif // TABSMODEL_H