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

#ifndef COMMANDBASE_H
#define COMMANDBASE_H

namespace Commands {

    enum CommandType {
        AddArtworksCommandType,
        RemoveArtworksCommandType,
        CombinedEditCommandType,
        PasteKeywordsCommandType
    };

    class CommandResult;
    class CommandManager;

    class CommandBase
    {
    public:
        CommandBase(CommandType commandType):
            m_CommandType(commandType)
        {}
        virtual ~CommandBase() {}

    public:
        virtual CommandResult *execute(const CommandManager *commandManager) const = 0;
        CommandType getCommandType() const { return m_CommandType; }

    private:
        CommandType m_CommandType;
    };

    class CommandResult {
    public:
        CommandResult(){}
        ~CommandResult(){}
    };
}

#endif // COMMANDBASE_H