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

#ifndef SPELLCHECKERRORSHIGHLIGHTER_H
#define SPELLCHECKERRORSHIGHLIGHTER_H

#include <QtGui>
#include <QSet>
#include <QString>

namespace SpellCheck {
    class SpellCheckErrorsHighlighter : public QSyntaxHighlighter
    {
    public:
        SpellCheckErrorsHighlighter(QTextDocument *document);

    public:
        void setErrorWords(const QSet<QString> &items);

    protected:
        virtual void highlightBlock(const QString &text);

    private:
        bool hasWrongSpelling(const QString &text, int start, int count) const;

    private:
        QSet<QString> m_WordsWithErrors;

    };
}

#endif // SPELLCHECKERRORSHIGHLIGHTER_H
