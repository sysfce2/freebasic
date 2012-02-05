' ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
'< main program generated by utility                       GladeToBac V3.0.0.1 >
'< Hauptprogramm erzeugt von                                                   >
'< Generated at / Generierung am                             2011-09-15, 12:27 >
' -----------------------------------------------------------------------------
'< Program info:                                                               >
CONST PROJ_NAME = "FB_Calc" '                                                  >
CONST PROJ_DESC = "Taschenrechner" '                                           >
CONST PROJ_VERS = "0.0" '                                                      >
CONST PROJ_YEAR = "2011" '                                                     >
CONST PROJ_AUTH = "" '                                                         >
CONST PROJ_MAIL = "Thomas{ dot ]Freiherr[ AT ]gmx[ dot }net" '                 >
CONST PROJ_WEBS = "www.freebasic-portal.de" '                                  >
CONST PROJ_LICE = "GNU General Public License v3" '                            >
'<                                                                             >
'< Description / Beschreibung:                                                 >
'<                                                                             >
'<                                                                             >
'< License / Lizenz:                                                           >
'<                                                                             >
'< This program is free software: you can redistribute it and/or modify        >
'< it under the terms of the GNU General Public License as published by        >
'< the Free Software Foundation, either version 3 of the License, or           >
'< (at your option) any later version.                                         >
'<                                                                             >
'< This program is distributed in the hope that it will be useful, but         >
'< WITHOUT ANY WARRANTY; without even the implied warranty of                  >
'< MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU           >
'< General Public License for more details.                                    >
'<                                                                             >
'< You should have received a copy of the GNU General Public License along     >
'< with this program.  If not, see <http://www.gnu.org/licenses/>.             >
'<                                                                             >
' -----------------------------------------------------------------------------
'< Please prefer GNU GENERAL PUBLIC LICENSE to support open software.          >
'< For more information please visit:                       http://www.fsf.org >
'<                                                                             >
'< Bitte bevorzugen Sie die GNU GENERAL PUBLIC LICENSE und                     >
'< unterstuetzen Sie mit Ihrem Programm die freie Software                     >
'< Mehr Informationen finden Sie unter:                     http://www.fsf.org >
' -----------------------------------------------------------------------------
'<  GTK+tobac:                     general init / Allgemeine Initialisierungen >
    #DEFINE __FB_GTK3__ '                                GTK-3 / GTK-3 Version >
    #INCLUDE "gtk/gtk.bi" '                      GTK+library / GTK+ Bibliothek >
    gtk_init(@__FB_ARGC__, @__FB_ARGV__) '             start GKT / GTK starten >
    #INCLUDE "libintl.bi" '                           load lib / Lib laden >
    bindtextdomain(PROJ_NAME, EXEPATH & "/locale") '               path / Pfad >
    bind_textdomain_codeset(PROJ_NAME, "UTF-8") '   set encoding / Zeichensatz >
    textdomain(PROJ_NAME) '                               Filename / Dateiname >
'<  GTK+tobac:                                           end block / Blockende >
' vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv


' place your source code here / eigenen Quelltext hier einfuegen
ENUM OP
  Clear
  Result
  Plus
  Minus
  Multiplication
  Division
END ENUM

DECLARE SUB Calc(BYVAL O AS OP)

DIM SHARED AS INTEGER CLEAR_DISPLAY = 1
DIM SHARED AS STRING D_SEP
IF VAL("0.1") <> 0.1 THEN D_SEP = "," ELSE D_SEP = "."


' ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
'<  GTK+tobac:                                  load GTK stuff / GTK Anbindung >
    #INCLUDE "tobac/FB_Calc_tobac.bas" '                     Signale & GUI-XML >
'<  GTK+tobac:                                           end block / Blockende >
' vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv


' here widgets are known, place your source code here
' hier sind die Widgets bekannt, eigenen Quelltext einfuegen
SUB Calc(BYVAL O AS OP)
  STATIC AS STRING stack

  VAR entry = GTK_ENTRY(GUI.EntDisplay)
  VAR disp = VAL(*gtk_entry_get_text(entry))
  IF O = Op.Clear THEN
    stack = "" : disp = 0.0
  ELSE
    VAR p = LEN(stack) - 8
    WHILE LEN(stack)
      SELECT CASE AS CONST ASC(RIGHT(stack, 1))
      CASE Op.Plus
        IF O > Op.Minus THEN EXIT WHILE
        disp += CVD(MID(stack, p, 8))
      CASE Op.Minus
        IF O > Op.Minus THEN EXIT WHILE
        disp = CVD(MID(stack, p, 8)) - disp
      CASE Op.Multiplication
        disp *= CVD(MID(stack, p, 8))
      CASE Op.Division
        IF disp = 0.0 THEN
          gtk_entry_set_text(entry, *__("Error"))
          CLEAR_DISPLAY = 1
          stack = ""
          EXIT SUB
        END IF
        disp = CVD(MID(stack, p, 8)) / disp
      END SELECT
      stack = LEFT(stack, p - 1)
      p -= 9
    WEND
    IF O <> Op.Result THEN stack &= MKD(disp) & CHR(O)
    CLEAR_DISPLAY = 1
  END IF

  gtk_entry_set_text(entry, STR(disp))

END SUB

gtk_button_set_label(GTK_BUTTON(GUI.butD), D_SEP)


' ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
'<  GTK+tobac:           run GTK main, then end / GTK Hauptschleife, dann Ende >
    gtk_builder_connect_signals(GUI.XML, 0) '                 Signale anbinden >
    gtk_widget_show_all(GTK_WIDGET(GUI.winMain)) '     Hauptfenster darstellen >
    gtk_main() '                                     main loop / Hauptschleife >
    g_object_unref(GUI.XML) '                   dereference / Referenz abbauen >
'<  GTK+tobac:                                           end block / Blockende >
' vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv


' you may unref files here / ggf. Dateien hier schliessen


END 0 ' finish with return code 0 / Ende mit Returncode 0
