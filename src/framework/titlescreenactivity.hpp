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

#ifndef _GD_TITLESCREENAPPLET
#define _GD_TITLESCREENAPPLET

#include "framework/app.hpp"

class Pixmap;

class TitleScreenActivity: public Activity {
public:
    explicit TitleScreenActivity(App *app);
    virtual void redraw_event();
    virtual void keypress_event(KeyCode keycode, int gfxlib_keycode);
    virtual void timer_event(int ms_elapsed);
    virtual void shown_event();
    virtual void hidden_event();
    ~TitleScreenActivity();

private:
    const int scale;
    const int image_centered_threshold;
    std::vector<Pixmap *> animation;
    int frames, time_ms, animcycle;
    /* positions on screen */
    int image_h, y_gameline, y_caveline;
    bool show_status, alternate_status;
    int cavenum, levelnum;
    
    void clear_animation();
};

/**
 * A variable of this enum type stores the action which
 * should be done after finishing the App.
 * It is used outside the App, by the running environment! */
enum NextAction {
    StartTitle,    ///< Start the app with the title screen.
    StartEditor,   ///< Start the editor.
    Restart,       ///< Restart with new sound settings & etc.
    Quit           ///< Quit the program.
};

#endif
