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

#ifndef GD_SDLPIXMAP
#define GD_SDLPIXMAP

#include "config.h"

#include <SDL.h>

#include "gfx/pixmap.hpp"

class Pixbuf;

class SDLPixmap: public Pixmap {
protected:
    SDL_Surface *surface;

    SDLPixmap(const SDLPixmap&);                // copy ctor not implemented
    SDLPixmap& operator=(const SDLPixmap&);     // operator= not implemented
    SDLPixmap(SDL_Surface *surface_) : surface(surface_) {}

public:
    friend class SDLPixbufFactory;
    friend class SDLAbstractScreen;

    ~SDLPixmap();

    virtual int get_width() const;
    virtual int get_height() const;
};

#endif

