/*
 * Copyright (c) 2007-2013, Czirkos Zoltan http://code.google.com/p/gdash/
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

#include "config.h"

#include "cave/object/caveobjectjoin.hpp"

#include <glib/gi18n.h>

#include "fileops/bdcffhelper.hpp"
#include "cave/caverendered.hpp"
#include "misc/printf.hpp"
#include "misc/util.hpp"
#include "cave/elementproperties.hpp"

std::string CaveJoin::get_bdcff() const
{
    return BdcffFormat(backwards?"AddBackward":"Add") << dist << search_element << put_element;
}

CaveJoin* CaveJoin::clone_from_bdcff(const std::string &name, std::istream &is) const
{
    Coordinate dist;
    GdElementEnum search, replace;
    if (!(is >> dist >> search >> replace))
        return NULL;

    bool backwards=gd_str_ascii_caseequal(name, "AddBackward");
    return new CaveJoin(dist, search, replace, backwards);
}

CaveJoin::CaveJoin(Coordinate _dist, GdElementEnum _search_element, GdElementEnum _put_element, bool _backward)
:   CaveObject(GD_JOIN),
    dist(_dist),
    search_element(_search_element),
    put_element(_put_element),
    backwards(_backward)
{
}

void CaveJoin::draw(CaveRendered &cave) const
{
    /* find every object, and put fill_element next to it. relative coordinates dx,dy */
    if (!backwards) {
        /* from top to bottom */
        for (int y=0; y<cave.h; y++)
            for (int x=0; x<cave.w; x++)
                if (cave.map(x, y)==search_element) {
                    /* these new coordinates should wrap around, too. that is needed by profi boulder caves. */
                    /* but they will be wrapped around by store_rc */
                    cave.store_rc(x+dist.x, y+dist.y, put_element, this);
                }
    } else {
        /* from bottom to top */
        for (int y=cave.h-1; y>=0; --y)
            for (int x=cave.w-1; x>=0; --x)
                if (cave.map(x, y)==search_element) {
                    /* these new coordinates should wrap around, too. that is needed by profi boulder caves. */
                    /* but they will be wrapped around by store_rc */
                    cave.store_rc(x+dist.x, y+dist.y, put_element, this);
                }
    }
}

PropertyDescription const CaveJoin::descriptor[] = {
    {"", GD_TAB, 0, N_("Draw")},
    {"", GD_TYPE_BOOLEAN_LEVELS, 0, N_("Levels"), GetterBase::create_new(&CaveJoin::seen_on), N_("Levels on which this object is visible.")},
    {"", GD_TYPE_ELEMENT, 0, N_("Search element"), GetterBase::create_new(&CaveJoin::search_element), N_("The element to look for. Every element found will generate an add element.")},
    {"", GD_TYPE_ELEMENT, 0, N_("Add element"), GetterBase::create_new(&CaveJoin::put_element), N_("The element to draw.")},
    {"", GD_TYPE_COORDINATE, 0, N_("Distance"), GetterBase::create_new(&CaveJoin::dist), N_("The distance to draw the new element at."), -40, 40},
    {"", GD_TYPE_BOOLEAN, 0, N_("Backwards"), GetterBase::create_new(&CaveJoin::backwards), N_("Normally the cave is searched from top to bottom, to find the search element, and draw the add element nearby. If the distance vector of the drawn element is pointing down or right, it might be feasible to do the search from bottom to top, so search elements are not overwritten before finding them, or "
        "the elements may be multiplied, if the search and add elements are the same. "
        "When drawing a join element, GDash automatically selects backward search, if needed - so this setting is provided for compatiblity of old caves only.")},
    {NULL},
};

PropertyDescription const* CaveJoin::get_description_array() const
{
    return descriptor;
}

std::string CaveJoin::get_coordinates_text() const
{
    return SPrintf("%+d,%+d") % dist.x % dist.y;
}

/// Drag a join object in the editor.
/// Sets displacement and guesses if backwards searching is needed.
/// Here it could be made automatic, as it is more intuitive, and
/// BDCFF can code backward searches as well.
void CaveJoin::create_drag(Coordinate current, Coordinate displacement)
{
    dist+=displacement;
    /* when just created, guess backwards flag. */
    if (dist.y>0 || (dist.y==0 && dist.x>0))
        backwards=true;
    else
        backwards=false;
}

void CaveJoin::move(Coordinate current, Coordinate displacement)
{
    dist+=displacement;
}

void CaveJoin::move(Coordinate displacement)
{
    dist+=displacement;
}

std::string CaveJoin::get_description_markup() const
{
    return SPrintf(_("Join <b>%s</b> to every <b>%s</b>, distance %+d,%+d"))
        % gd_element_properties[put_element].lowercase_name % gd_element_properties[search_element].lowercase_name % dist.x % dist.y;
}
