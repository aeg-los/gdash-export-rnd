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
#ifndef CAVEOBJECTFILL_HPP_INCLUDED
#define CAVEOBJECTFILL_HPP_INCLUDED

#include "config.h"

#include "cave/object/caveobject.hpp"

/// A cave objects which fills the inside of an area set by a border.
class CaveFill : public CaveObject {
protected:
    Coordinate start;               ///< Starting coordinate of the filling.
    GdElement fill_element;         ///< Fill with this element.

public:
    CaveFill(CaveObject::Type type, Coordinate _start, GdElementEnum _fill_element);
    CaveFill(CaveObject::Type type): CaveObject(type) {}
    Coordinate get_start_coordinate() const {
        return start;
    }

public:
    virtual void create_drag(Coordinate current, Coordinate displacement);
    virtual void move(Coordinate current, Coordinate displacement);
    virtual void move(Coordinate displacement);
    virtual std::string get_coordinates_text() const;
    virtual GdElementEnum get_characteristic_element() const;
};

#endif
