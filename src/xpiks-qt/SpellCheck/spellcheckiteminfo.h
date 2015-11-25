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

#ifndef SPELLCHECKITEMINFO_H
#define SPELLCHECKITEMINFO_H

#include <QSet>
#include <QString>
#include <QTextDocument>

namespace SpellCheck {
    class SpellCheckErrorsHighlighter;

    class SpellCheckItemInfo
    {
    public:
        SpellCheckItemInfo();

    public:
        void setDescriptionErrors(const QSet<QString> &errors);
        void setTitleErrors(const QSet<QString> &errors);
        void createHighlighterForDescription(QTextDocument *document);
        void createHighlighterForTitle(QTextDocument *document);

    private:
        QSet<QString> m_ErrorsInDescription;
        QSet<QString> m_ErrorsInTitle;
        SpellCheckErrorsHighlighter *m_TitleErrorsHighlighter;
        SpellCheckErrorsHighlighter *m_DescriptionErrorsHighlighter;
    };
}

#endif // SPELLCHECKITEMINFO_H
