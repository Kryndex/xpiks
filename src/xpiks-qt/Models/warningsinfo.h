/*
 * This file is a part of Xpiks - cross platform application for
 * keywording and uploading images for microstocks
 * Copyright (C) 2014-2015 Taras Kushnir <kushnirTV@gmail.com>
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

#ifndef WARNINGSINFO_H
#define WARNINGSINFO_H

#include <QStringList>
#include <QString>
#include "artiteminfo.h"

namespace Models {
    class WarningsInfo
    {
    public:
        WarningsInfo(ArtItemInfo *itemInfo) :
            m_ArtworkInfo(itemInfo)
        {}

        ~WarningsInfo() { delete m_ArtworkInfo; }

    public:
        void addWarning(const QString &warning) { m_WarningsList.append(warning); }
        ArtworkMetadata *getArtworkMetadata() const { return m_ArtworkInfo->getOrigin(); }
        void clearWarnings() { m_WarningsList.clear(); }
        bool hasWarnings() const { return m_WarningsList.length() > 0; }

    public:
        const QString &getFilePath() const { return m_ArtworkInfo->getOrigin()->getFilepath(); }
        const QStringList &getWarnings() const { return m_WarningsList; }
        int getIndex() const { return m_ArtworkInfo->getOriginalIndex(); }

    private:
        QStringList m_WarningsList;
        ArtItemInfo *m_ArtworkInfo;
    };
}

#endif // WARNINGSINFO_H