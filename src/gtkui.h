/*
 * Copyright (c) 2007, 2008 Czirkos Zoltan <cirix@fw.hu>
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
#ifndef _GD_UI_H
#define _GD_UI_H

#include <gtk/gtkwidget.h>
#include <gtk/gtklabel.h>

#define GD_ICON_CAVE_EDITOR "cave-editor"
#define GD_ICON_EDITOR_MOVE "editor-move"
#define GD_ICON_EDITOR_JOIN "editor-add-join"
#define GD_ICON_EDITOR_POINT "editor-add-point"
#define GD_ICON_EDITOR_FREEHAND "editor-add-freehand"
#define GD_ICON_EDITOR_LINE "editor-add-line"
#define GD_ICON_EDITOR_RECTANGLE "editor-add-rectangle"
#define GD_ICON_EDITOR_FILLRECT "editor-add-filled-rectangle"
#define GD_ICON_EDITOR_RASTER "editor-add-raster"
#define GD_ICON_EDITOR_FILL_BORDER "editor-add-fill-border"
#define GD_ICON_EDITOR_FILL_REPLACE "editor-add-fill-replace"
#define GD_ICON_EDITOR_MAZE "editor-add-maze"
#define GD_ICON_EDITOR_MAZE_UNI "editor-add-maze-uni"
#define GD_ICON_EDITOR_MAZE_BRAID "editor-add-maze-braid"
#define GD_ICON_SNAPSHOT "snapshot"
#define GD_ICON_RESTART_LEVEL "restart-level"
#define GD_ICON_RANDOM_FILL "random-fill"
#define GD_ICON_TO_TOP "to-top"
#define GD_ICON_TO_BOTTOM "to-bottom"
#define GD_ICON_REMOVE_MAP "remove-map"
#define GD_ICON_FLATTEN_CAVE "flatten-cave"
#define GD_ICON_AWARD "icon-award"

void gd_create_stock_icons(void);

GdkPixbuf *gd_icon(void);
GdkPixmap **gd_create_title_animation(void);

void gd_preferences(GtkWidget *parent);

void gd_show_highscore(GtkWidget *parent, Cave *cave, gboolean show_clear_button, Cave *highlight_cave, int highlight_rank);

gboolean gd_open_caveset_in_ui(const char *filename, gboolean highscore_load_from_bdcff);

void gd_save_caveset_as(GtkWidget *parent);
void gd_save_caveset(GtkWidget *parent);
void gd_open_caveset(GtkWidget *parent, const char *directory);

gboolean gd_ask_overwrite(const char *filename);

gboolean gd_discard_changes(GtkWidget *parent);

void gd_warningmessage(const char *primary, const char *secondary);
void gd_errormessage(const char *primary, const char *secondary);
void gd_infomessage(const char *primary, const char *secondary);

gboolean gd_question_yesno(const char *primary, const char *secondary);

void gd_load_internal(GtkWidget *parent, int i);

GtkWidget *gd_label_new_printf(const char *format, ...);
GtkWidget *gd_label_new_printf_centered(const char *format, ...);
void gd_label_set_markup_printf(GtkLabel *label, const char *format, ...);

void gd_show_errors(GtkWidget *parent);
void gd_show_last_error(GtkWidget *parent);

#endif
