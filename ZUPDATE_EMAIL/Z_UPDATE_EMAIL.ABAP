*&---------------------------------------------------------------------*
*& Report Z_UPDATE_EMAIL
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Ticket     : Ticketnummer
*& Ersteller  : Arben Hajruli
*& Anforderer : Norbert Hänle
*& Datum      : 17.07.2024
*& Kommentar  : CSV-Datei einlesen und anhand von Benutzername die E-Mail
*&              Adresse automatisch auf @winkler.com ändern
*&
*&
*&---------------------------------------------------------------------*
*& Änderungen: Hier Anpassungen folgendermaßen eingeben
*&             #Ticketnr/Name/Datum - Kurzbeschreibung
*&             #Hajruli/20.12.2024  - Erweiterung damit Benutzer mit Umlaut in Nachname auch die E-Mail geändert wird.
*&             #Hajruli/08.01.2025  - Erweiterung damit '@winkler-parts.ch' umgestellt wird
*&             #Hajruli/29.01.2025  - Erweiterung email alles in klein speichern,
*&
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
REPORT z_update_email.

" programm was funktioniert ohne umlaute
" Definition der Struktur für ALV-Ausgabe
TYPES: BEGIN OF ty_alv_output,
         username TYPE sy-uname,  " Benutzername
         message  TYPE c LENGTH 50,    " Nachricht für ALV-Ausgabe  " TYPE c LENGTH 50,
       END OF ty_alv_output.

" Deklaration der Datenobjekte
DATA: gt_ausgabe_tabelle        TYPE TABLE OF ty_alv_output,          " Tabelle zur Ausgabe der Ergebnisse
      lt_sorted_ausgabe_tabelle TYPE TABLE OF ty_alv_output,          " Tabelle für sortierte Ergebnisse
      go_alv                    TYPE REF TO cl_salv_table,            " Referenz auf ALV-Objekt
      go_functions              TYPE REF TO cl_salv_functions_list,   " Referenz auf ALV-Funktionen
      go_columns                TYPE REF TO cl_salv_columns_table,    " Referenz auf ALV-Spalten
      go_display                TYPE REF TO cl_salv_display_settings. " Referenz zur ALV-Anzeigeeinstellungen

" Deklaration der Variablen für Dateiverarbeitung und Benutzerdetails
DATA: p_file            TYPE string,          " Pfad zur CSV-Datei
      lf_ok             TYPE abap_bool,       " Flag zur Überprüfung der Dateiexistenz
      lt_lines          TYPE TABLE OF string, " Tabelle zum Speichern der CSV-Daten
      lf_line           TYPE string,          " Einzelne Zeile aus der CSV-Datei
      lt_columns        TYPE TABLE OF string, " Tabelle zum Speichern der Spaltenwerte
      lf_column         TYPE string,          " Einzelner Spaltenwert
      lv_username       TYPE sy-uname,        " Benutzername aus der CSV-Datei
      lv_email          TYPE string,          " Neue E-Mail-Adresse aus der CSV-Datei
      lv_vorname        TYPE string,          " Vorname aus der CSV-Datei
      lv_nachname       TYPE string,          " Nachname aus der CSV-Datei
      lv_old_email      TYPE string,          " Alte E-Mail-Adresse aus der CSV-Datei
      lv_expected_email TYPE string.          " Erwartete E-Mail-Adresse im Format vorname.nachname@winkler.com

" Auswahl der CSV-Datei vom Benutzer
PERFORM at_selection_screen_val_file CHANGING p_file.
IF p_file IS INITIAL.
  WRITE: / 'Keine CSV-Datei ausgewählt.'.     " Wenn keine Datei ausgewählt wurde, Ausgabe einer Fehlermeldung
  RETURN.
ENDIF.

" Überprüfen, ob die angegebene Datei existiert
PERFORM check_file_exists USING p_file CHANGING lf_ok.
IF lf_ok <> abap_true.
  WRITE: / 'CSV-Datei existiert nicht:', p_file. " Fehlermeldung ausgeben, wenn die Datei nicht gefunden wird
  RETURN.
ENDIF.

" CSV-Datei lesen
CALL METHOD cl_gui_frontend_services=>gui_upload
  EXPORTING
    filename = p_file
  CHANGING
    data_tab = lt_lines.

" Schleife-Verarbeite jede Zeile der CSV-Datei, beginnend ab der zweiten Zeile
LOOP AT lt_lines INTO lf_line FROM 2.
  " Spalten aus der aktuellen Zeile extrahieren
  CALL FUNCTION 'RSDS_CONVERT_CSV'
    EXPORTING
      i_data_sep       = ';'        " Trennzeichen für CSV
      i_esc_char       = '"'        " Escape-Zeichen für CSV
      i_record         = lf_line    " Einzelne Zeile aus der CSV-Datei
      i_field_count    = 9999       " Maximale Anzahl der Felder pro Zeile
    IMPORTING
      e_t_data         = lt_columns " Ergebnis: Tabelle mit den extrahierten Spalten
    EXCEPTIONS
      escape_no_close  = 1
      escape_improper  = 2
      conversion_error = 3
      OTHERS           = 4.

  " Alte E-Mail-Adresse aus der 1. Spalte lesen
  READ TABLE lt_columns INTO lf_column INDEX 1.
  IF sy-subrc = 0.
    lv_old_email = lf_column.
  ELSE.
    APPEND VALUE #( username = '' message = 'Spalte 1 (Alte E-Mail) nicht gefunden in Zeile' ) TO gt_ausgabe_tabelle.
    CONTINUE.
  ENDIF.

  " Überprüfen, ob die alte E-Mail-Adresse auf @winkler.de endet
  IF lv_old_email CS '@winkler.de' OR lv_old_email CS '@winkler-parts.ch'.
    " Benutzername aus der 7. Spalte lesen
    READ TABLE lt_columns INTO lf_column INDEX 7.
    IF sy-subrc = 0.
      lv_username = lf_column.
    ELSE.
      APPEND VALUE #( username = '' message = 'Spalte 7 (Benutzername) nicht gefunden in Zeile' ) TO gt_ausgabe_tabelle.
      CONTINUE.
    ENDIF.

    " Neue E-Mail-Adresse aus der 2. Spalte lesen
    READ TABLE lt_columns INTO lf_column INDEX 2.
    IF sy-subrc = 0.
      lv_email = lf_column.
    ELSE.
      APPEND VALUE #( username = '' message = 'Spalte 2 (Neue E-Mail) nicht gefunden in Zeile' ) TO gt_ausgabe_tabelle.
      CONTINUE.
    ENDIF.

    " Vorname aus der 5. Spalte lesen
    READ TABLE lt_columns INTO lf_column INDEX 5.
    IF sy-subrc = 0.
      lv_vorname = lf_column.
    ELSE.
      APPEND VALUE #( username = '' message = 'Spalte 5 (Vorname) nicht gefunden in Zeile' ) TO gt_ausgabe_tabelle.
      CONTINUE.
    ENDIF.

    " Nachname aus der 6. Spalte lesen
    READ TABLE lt_columns INTO lf_column INDEX 6.
    IF sy-subrc = 0.
      lv_nachname = lf_column.
    ELSE.
      APPEND VALUE #( username = '' message = 'Spalte 6 (Nachname) nicht gefunden in Zeile' ) TO gt_ausgabe_tabelle.
      CONTINUE.
    ENDIF.

    " Sonderzeichen und Umlaute in Vorname und Nachname behandeln
    PERFORM normalize_string USING lv_vorname CHANGING lv_vorname.
    PERFORM normalize_string USING lv_nachname CHANGING lv_nachname.

    " Benutzerdetails abrufen und aktualisieren
    PERFORM update_user_details USING lv_username lv_email lv_vorname lv_nachname.
  ENDIF.
ENDLOOP.

" ALV-Ausgabe sortieren
PERFORM sort_ausgabe_tabelle.

" ALV-Ausgabe
PERFORM display_alv.

" Form für die Dateiauswahl
FORM at_selection_screen_val_file CHANGING cf_filename TYPE string.
  DATA: lt_filetable TYPE filetable,    " Tabelle für Dateiauswahl
        ls_filetable TYPE file_table,   " Einzelner Eintrag in der Dateiauswahltabelle
        lf_action    TYPE i,            " Benutzeraktion (OK, Abbrechen etc.)
        lf_return    TYPE i.            " Rückgabewert des Dateiauswahldialogs

  " Öffnen des Dateiauswahldialogs
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      default_extension       = 'CSV'         " Standard-Dateierweiterung
      file_filter             = '*.CSV'       " Filter für CSV-Dateien
    CHANGING
      file_table              = lt_filetable  " Ergebnis der Dateiauswahl
      rc                      = lf_return     " Rückgabewert
      user_action             = lf_action     " Benutzeraktion (OK, Abbrechen etc.)
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.
  IF sy-subrc <> 0.
    " Fehlermeldung ausgeben, falls Dateiauswahl fehlschlägt
    MESSAGE ID   sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    RETURN.
  ENDIF.
  " Falls Benutzer OK gewählt hat
  IF    lf_action = cl_gui_frontend_services=>action_ok
    AND lf_return = 1.
    " Dateiname übernehmen
    READ TABLE lt_filetable INTO ls_filetable INDEX 1.
    IF sy-subrc IS INITIAL.
      cf_filename = ls_filetable-filename.
    ENDIF.
  ENDIF.
ENDFORM.

" Form für die Überprüfung, ob die Datei existiert
FORM check_file_exists USING uf_filename TYPE string CHANGING cf_ok TYPE abap_bool.
  DATA: lf_result TYPE c. " Ergebnis der Dateiexistenzprüfung

  " Überprüfen, ob die Datei vorhanden ist
  CALL METHOD cl_gui_frontend_services=>file_exist
    EXPORTING
      file                 = uf_filename
    RECEIVING
      result               = lf_result
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      wrong_parameter      = 3
      not_supported_by_gui = 4
      OTHERS               = 5.

  IF sy-subrc NE 0 OR lf_result NE abap_true.
    cf_ok = abap_false.   " Datei nicht vorhanden
  ELSE.
    cf_ok = abap_true.    " Datei vorhanden
  ENDIF.
ENDFORM.

" Form zur Normalisierung von Strings
FORM normalize_string USING input_string TYPE string CHANGING output_string TYPE string.
  DATA: temp_string TYPE string.

  " Umlaute und Sonderzeichen ersetzen
  temp_string = input_string.
  REPLACE ALL OCCURRENCES OF 'ä' IN temp_string WITH 'ae'.
  REPLACE ALL OCCURRENCES OF 'ö' IN temp_string WITH 'oe'.
  REPLACE ALL OCCURRENCES OF 'ü' IN temp_string WITH 'ue'.
  REPLACE ALL OCCURRENCES OF 'ł' IN temp_string WITH 'l'.
  REPLACE ALL OCCURRENCES OF 'ß' IN temp_string WITH 'ss'.
  REPLACE ALL OCCURRENCES OF 'Ä' IN temp_string WITH 'Ae'.
  REPLACE ALL OCCURRENCES OF 'Ö' IN temp_string WITH 'Oe'.
  REPLACE ALL OCCURRENCES OF 'Ü' IN temp_string WITH 'Ue'.

  " Nicht-deutsche Zeichen entfernen
  REPLACE ALL OCCURRENCES OF REGEX '[^a-zA-Z0-9.]' IN temp_string WITH ''.

  output_string = temp_string.
ENDFORM.


FORM update_user_details USING lv_username TYPE sy-uname
                              lv_email    TYPE string
                              lv_vorname  TYPE string
                              lv_nachname TYPE string.
  DATA: ls_user_address  TYPE bapiaddr3,   " Struktur für Adressdaten
        ls_user_addressx TYPE bapiaddr3x,  " Struktur für Adressdaten (X-Felder)
        lt_return        TYPE TABLE OF bapiret2, " Tabelle für Rückgabewerte
        ls_return        TYPE bapiret2.    " Einzelnes Rückgabefeld

  " Benutzerdetails abrufen
  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username = lv_username
    IMPORTING
      address  = ls_user_address
    TABLES
      return   = lt_return.

  " Fehlerüberprüfung
  READ TABLE lt_return INTO ls_return WITH KEY type = 'E'.
  IF sy-subrc = 0.
    APPEND VALUE #( username = lv_username message = |{ ls_return-message }| ) TO gt_ausgabe_tabelle.
    RETURN.
  ENDIF.

  " Erwartete E-Mail-Adresse im Format vorname.nachname@winkler.com erstellen
  CONCATENATE lv_vorname '.' lv_nachname '@winkler.com' INTO lv_expected_email.
  TRANSLATE lv_expected_email TO LOWER CASE.

  " Überprüfen, ob die aktuelle E-Mail-Adresse nicht im erwarteten Format ist
  IF ls_user_address-e_mail <> lv_expected_email.
    ls_user_address-e_mail = lv_expected_email.   " Neue E-Mail-Adresse setzen

    " Adressdaten aktualisieren
    CLEAR ls_user_addressx.
    ls_user_addressx-e_mail = 'X'.     " E-Mail-Adresse als geändert kennzeichnen

    CALL FUNCTION 'BAPI_USER_CHANGE'
      EXPORTING
        username = lv_username
        address  = ls_user_address
        addressx = ls_user_addressx
      TABLES
        return   = lt_return.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    " Fehlerüberprüfung
    READ TABLE lt_return INTO ls_return WITH KEY type = 'E'.
    IF sy-subrc = 0.
      APPEND VALUE #( username = lv_username message = |{ ls_return-message }| ) TO gt_ausgabe_tabelle.
    ELSE.
      APPEND VALUE #( username = lv_username message = 'E-Mail-Adresse erfolgreich aktualisiert.' ) TO gt_ausgabe_tabelle.
    ENDIF.
  ELSE.
    APPEND VALUE #( username = lv_username message = 'Benutzer hat bereits die erwartete E-Mail-Adresse.' ) TO gt_ausgabe_tabelle.
  ENDIF.
ENDFORM.


" Form zum Sortieren der Ausgabetabelle
FORM sort_ausgabe_tabelle.
  DATA: lt_temp_ausgabe_tabelle TYPE TABLE OF ty_alv_output,  " Temporäre Tabelle für nicht sortierte Ausgaben
        lt_successful           TYPE TABLE OF ty_alv_output,  " Tabelle für erfolgreiche Aktualisierungen
        lt_details_error        TYPE TABLE OF ty_alv_output,  " Tabelle für Detailfehler
        lt_not_found            TYPE TABLE OF ty_alv_output.  " Tabelle für nicht gefundene Benutzer

  " Trennen nach Meldungstypen
  LOOP AT gt_ausgabe_tabelle INTO DATA(ls_ausgabe).
    CASE ls_ausgabe-message.
      WHEN 'E-Mail-Adresse erfolgreich aktualisiert.'.
        APPEND ls_ausgabe TO lt_successful.
      WHEN 'Benutzer hat bereits die erwartete E-Mail-Adresse.'.
        APPEND ls_ausgabe TO lt_details_error.
      WHEN 'Benutzer existiert nicht'.
        APPEND ls_ausgabe TO lt_not_found.
      WHEN OTHERS.
        APPEND ls_ausgabe TO lt_temp_ausgabe_tabelle.
    ENDCASE.
  ENDLOOP.

  " Zusammenführen der sortierten Tabellen
  APPEND LINES OF lt_successful TO lt_sorted_ausgabe_tabelle.
  APPEND LINES OF lt_details_error TO lt_sorted_ausgabe_tabelle.
  APPEND LINES OF lt_not_found TO lt_sorted_ausgabe_tabelle.
  APPEND LINES OF lt_temp_ausgabe_tabelle TO lt_sorted_ausgabe_tabelle.
ENDFORM.

" Form zum Anzeigen der ALV-Ausgabe
FORM display_alv.
  TRY.
      " Instanz der Klasse cl_salv_table erzeugen
      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = go_alv
        CHANGING
          t_table      = lt_sorted_ausgabe_tabelle ).

      " Funktionstasten (Sortieren, Filtern, Excel-Export etc.)
      go_functions = go_alv->get_functions( ).
      go_functions->set_all( abap_true ).

      " Optimale Spaltenbreite
      go_columns = go_alv->get_columns( ).
      "go_columns->set_optimize( abap_true ).

      " Benutzername-Spalte anpassen
      go_columns->get_column( 'USERNAME' )->set_short_text( 'Benutzer' ).
      go_columns->get_column( 'USERNAME' )->set_long_text( 'Benutzername' ).
      go_columns->get_column( 'USERNAME' )->set_optimized( abap_true ).

      " Nachricht-Spalte anpassen
      go_columns->get_column( 'MESSAGE' )->set_short_text( 'Nachricht' ).
      go_columns->get_column( 'MESSAGE' )->set_long_text( 'Nachricht' ).
      go_columns->get_column( 'MESSAGE' )->set_optimized( abap_true ).

      " Titel und/oder Streifenmuster
      go_display = go_alv->get_display_settings( ).
      go_display->set_list_header( value = 'E-Mail Aktualisierungsbericht' ).
      go_display->set_striped_pattern( abap_false ).

      " Liste anzeigen
      go_alv->display( ).

    CATCH cx_salv_msg INTO DATA(lx_salv_msg).
      " Fehlerbehandlung, z.B. Fehlermeldung ausgeben
      MESSAGE lx_salv_msg TYPE 'E'.

    CATCH cx_salv_not_found INTO DATA(lx_salv_not_found).
      " Fehlermeldung ausgeben, wenn die ALV-Erstellung fehlschlägt
      MESSAGE 'Fehler bei der Erstellung der ALV-Anzeige: CX_SALV_NOT_FOUND' TYPE 'E'.
  ENDTRY.
ENDFORM.
