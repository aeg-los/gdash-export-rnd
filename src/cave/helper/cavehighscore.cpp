/*
 * Copyright (c) 2007-2013, Czirkos Zoltan http://code.google.com/p/gdash/
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:

 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.

 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR
 * ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
 * CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#include "config.h"

#include <algorithm>
#include "cave/helper/cavehighscore.hpp"

/// Check if the achieved score will be put on the list.
/// @param score The score to be checked.
/// @return true, if the score is a highscore, and can be put on the list.
bool HighScoreTable::is_highscore(int score) const {
    /* if score is above zero AND bigger than the last one */
    if (score > 0 && (table.size() < GD_HIGHSCORE_NUM || score > table.back().score))
        return true;

    return false;
}

/* for sorting. compares two highscores. */
static bool highscore_compare(const HighScore &a, const HighScore &b) {
    return b.score < a.score;
}

/// Adds a player with some score to the highscore table.
/// Returns the new rank.
/// @param name The name of the player.
/// @param score The score achieved.
/// @return The index in the table, or -1 if did not fit.
int HighScoreTable::add(const std::string &name, int score) {
    if (!is_highscore(score))
        return -1;

    /* add to the end */
    table.push_back(HighScore(name, score));
    sort(table.begin(), table.end(), highscore_compare);
    /* if too big, remove the lowest ones (after sorting) */
    if (table.size() > GD_HIGHSCORE_NUM)
        table.resize(GD_HIGHSCORE_NUM);

    /* and find it so we can return an index */
    for (unsigned int i = 0; i < table.size(); i++)
        if (table[i].name == name && table[i].score == score)
            return i;

    return -1;
}
