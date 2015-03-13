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
#ifndef GD_REPLAYSAVERACTIVITY
#define GD_REPLAYSAVERACTIVITY


/* the replay saver thing only works in the sdl version */
#ifdef HAVE_SDL

#include "framework/app.hpp"
#include "gfx/cellrenderer.hpp"
#include "sdl/sdlscreen.hpp"
#include "sdl/sdlpixbuffactory.hpp"
#include "cave/gamerender.hpp"
#include "gfx/fontmanager.hpp"

class CaveStored;
class CaveReplay;
class GameControl;

/**
 * This activity plays a replay, and saves every animation frame to
 * a PNG file, along with the sound to a WAV file.
 * 
 * This is implemented using a normal GameControl object, but it is given
 * a special kind of Screen which can be saved to a PNG file. Also
 * the normal sound stream is closed, and a special stream is requested
 * from SDL with the dummy audio driver. A mixer callback func is also
 * registered for SDL_Mixer, which will save the audio data.
 * 
 * During saving the replay, the normal timer events which are forwarded
 * from the App are not used for the timing of the cave. The mixer callback
 * registered to SDL_Mixer also pushes SDL events (SDL_USEREVENT+1), which
 * are then sent to App::timer2_event() in sdlmain.cpp. This is used
 * to iterate the cave. The size of
 * the sound buffer is set to hold 20ms of sound data, so SDL_Mixer is
 * forced to generate us the events every 20ms - thus we can do an 50fps
 * animation.
 * 
 * During saving the replay, the image is shown to the user, but it is not
 * scaled, and there will be no sound. (As sound goes only to the memory
 * and the WAV file.) This does not take too much CPU power; compressing
 * the PNG files is eats much more.
 * 
 * The whole thing only works in the SDL version, it is not implemented
 * in the GTK game. Maybe it would be nice to put it in the GTK version
 * instead. */
class ReplaySaverActivity: public Activity {
public:
    /** Ctor.
     * The created Activity, when pushed, will start to record the replay.
     * When finishing, it will automatically quit. There is no way for
     * the user to cancel the saving.
     * @param app The parent app.
     * @param cave The cave which has the replay to record.
     * @param replay The replay to record to the files.
     * @param filename_prefix A filename prefix of the output files,
     *      to which .wav and _xxxxxx.png will be appended. */
    ReplaySaverActivity(App *app, CaveStored *cave, CaveReplay *replay, std::string const &filename_prefix);
    /** Destructor.
     * Has many things to do - write a WAV header, reinstall the normal mixer etc. */
    ~ReplaySaverActivity();
    virtual void redraw_event();
    /**
     * When the Activity is shown, it will install its own sound mixer. */
    virtual void shown_event();
    /** The timer2 event generated by the sound mixer will do the cave timing. */
    virtual void timer2_event();

private:
    /** The SDL_Mixer post mixing callback, which saves the WAV file
     * and sends SDL_USEREVENT+1-s to do the cave timing. */
    static void mixfunc(void *udata, Uint8 *stream, int len);
    /** Save sound preferences of the user, restart the SDL audio subsystem
     * with the required settings and install the mixer callbacks. */
    void install_own_mixer();
    /** Revert to the original sound preferences of the user. */
    void uninstall_own_mixer();

    /** Bytes written to the wav file. */
    unsigned int wavlen;
    /** Number of image frames written. */
    unsigned int frame;
    /** Sound settings reported by SDL. */
    int frequency, channels, bits;
    std::string filename_prefix;
    /** The WAV file opened for writing. */
    FILE *wavfile;
    
    // saved settings
    /** User's sound preference to be restored after replay saving. */
    bool saved_gd_sdl_sound;
    /** User's sound preference to be restored after replay saving. */
    bool saved_gd_sdl_44khz_mixing;
    /** User's sound preference to be restored after replay saving. */
    bool saved_gd_sdl_16bit_mixing;
    /** User's sound preference to be restored after replay saving. */
    bool saved_gd_show_name_of_game;
    /** User's sound preference to be restored after replay saving. */
    bool saved_gd_sound_stereo;
    /** SDL sound environment variable saved, to be restored after replay saving. */
    std::string saved_driver;

    /** This is a special SDL screen, which is a bitmap in memory.
     * During the replay, the drawing routine draws on this, and it can be saved to disk. */
    class SDLInmemoryScreen: public SDLAbstractScreen {
    public:
        SDLInmemoryScreen() {}
        virtual void set_title(char const *);
        virtual void configure_size();
        ~SDLInmemoryScreen();
        void save(char const *filename);
    };
    
    /** GameControl object which plays the replay. */
    GameControl *game;
    /** A PixbufFactory set to no scaling, no pal emulation. */
    SDLPixbufFactory pf;
    /** A font manager, which uses the pf PixbufFactory. */
    FontManager fm;
    /** A Screen, which is much like an image in memory, so it can be saved to PNG */
    SDLInmemoryScreen pm;
    /** A CellRenderer needed by the GameControl object. */
    CellRenderer cellrenderer;
    /** A GameRenderer, which will draw the cave. */
    GameRenderer gamerenderer;
};

#endif /* IFDEF HAVE_SDL */

#endif
