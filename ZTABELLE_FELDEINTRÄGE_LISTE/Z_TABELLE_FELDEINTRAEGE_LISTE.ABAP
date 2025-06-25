Report Z_TABELLE_FELDEINTRAEGE_LISTE.

"Ausgabe mit ALV Tabelle
TYPES: BEGIN OF ty_output,        " Struktur für die Ausgabe definieren
         field TYPE string,       " Feld für den Namen des ABAP-Feldes
         count TYPE string,       " Feld für die Anzahl der Einträge
       END OF ty_output.          " Ende der Strukturdefinition

DATA: lt_dynamic_table TYPE REF TO data,        " Dynamische Tabelle zur Speicherung der Daten
      lt_counts TYPE TABLE OF string,           " Tabelle für die Zählwerte als String
      lt_output TYPE TABLE OF ty_output,        " Tabelle für die ALV-Ausgabe (Struktur aus ty_output)
      lv_count TYPE i,                          " Variable für die Zählung der Einträge pro Feld
      lv_field TYPE string,                     " Variable für den Feldnamen
      lv_field_name TYPE string,                " Variable für den Namen des Feldes
      lv_count_str TYPE string.                 " Variable für die Zählung als String

DATA: go_alv TYPE REF TO cl_salv_table,                 " Referenz auf ALV-Tabelle
      go_functions TYPE REF TO cl_salv_functions_list,  " Referenz auf ALV-Funktionstasten
      go_columns TYPE REF TO cl_salv_columns_table,     " Referenz auf ALV-Spalten
      go_display TYPE REF TO cl_salv_display_settings.  " Referenz auf ALV-Anzeigeeinstellungen

FIELD-SYMBOLS: <fs_field> TYPE any,             " Field-Symbol für die einzelnen Felder der Struktur
               <fs_structure> TYPE any,         " Field-Symbol für die gesamte Struktur
               <fs_table> TYPE STANDARD TABLE.  " Field-Symbol für die dynamische Tabelle

PARAMETERS: p_eingab TYPE tabname OBLIGATORY.   " Eingabeparameter für den Tabellennamen


START-OF-SELECTION.

* Dynamische Tabellen- und Arbeitsbereichserstellung
TRY.
    CREATE DATA lt_dynamic_table TYPE TABLE OF (p_eingab).  " Erstelle dynamische Tabelle basierend auf Eingabeparameter
  CATCH cx_sy_create_data_error.
    WRITE: / 'Fehler: Ungültige Tabellennamen-Eingabe'.     " Fehlerbehandlung, wenn der Tabellenname ungültig is
    RETURN.
ENDTRY.

ASSIGN lt_dynamic_table->* TO <fs_table>.   " Weist das Field-Symbol <fs_table> auf die dynamisch erstellte Tabelle zu

* Einträge aus der dynamischen Tabelle lesen
SELECT * FROM (p_eingab) INTO TABLE <fs_table>.   " Daten aus der dynamischen Tabelle in die Tabelle <fs_table> lesen

* Falls keine Einträge vorhanden sind
IF <fs_table> IS INITIAL.    " Überprüfen, ob die Tabelle leer ist
  WRITE: / 'Keine Einträge in Tabelle', p_eingab, 'gefunden'.   " Falls leer, Fehlermeldung anzeigen
  RETURN.
ENDIF.

* Loop über die Struktur, um jedes Feld zu prüfen
DO.
  ASSIGN COMPONENT sy-index OF STRUCTURE <fs_table>[ 1 ] TO <fs_field>.   " Weist das Field-Symbol <fs_field> auf das aktuelle Feld der Struktur zu

  IF sy-subrc <> 0.   " Wenn kein weiteres Feld vorhanden ist, verlässt der Loop
    EXIT.             " Keine weiteren Felder vorhanden
  ENDIF.

  CLEAR lv_count.     " Zählt die Vorkommen eines Feldes zurücksetzen

   LOOP AT <fs_table> ASSIGNING <fs_structure>.   " Schleife über alle Einträge in der Tabelle
    ASSIGN COMPONENT sy-index OF STRUCTURE <fs_structure> TO <fs_field>.  " Weist das Field-Symbol <fs_field> auf das aktuelle Feld in der Struktur zu

    IF <fs_field> IS NOT INITIAL.   " Wenn das Feld nicht leer ist
      lv_count = lv_count + 1.      " Erhöhe die Zählvariable
    ENDIF.
  ENDLOOP.

* Feldname ermitteln
  lv_field_name = cl_abap_typedescr=>describe_by_data( <fs_field> )->get_relative_name( ).  " Ermittelt den Namen des aktuellen Feldes

  " Zähler in String umwandeln
  lv_count_str = lv_count.        " Umwandeln der Zählung in einen String
  CONCATENATE lv_field_name ':' lv_count_str INTO lv_field SEPARATED BY space.  " Erstelle einen String mit Feldname und Zähler
  APPEND lv_field TO lt_counts.   " Füge den String in die Zähltabelle lt_counts hinzu
ENDDO.

* Ausgabe in Tabelle formatieren
LOOP AT lt_counts INTO DATA(lv_output_str).  " Schleife über die Zähltabelle lt_counts
  CLEAR lv_field_name.  " Zähler zurücksetzen
  CLEAR lv_count_str.

  SPLIT lv_output_str AT ':' INTO lv_field_name lv_count_str.  " Splitte den String in Feldnamen und Zähler

  " Erstellen einer neuen Zeile in der Ausgabe
  APPEND VALUE #( field = lv_field_name count = lv_count_str ) TO lt_output.  " Füge das Ergebnis in die ALV-Ausgabetabelle lt_output ein
ENDLOOP.

cl_salv_table=>factory(
  importing r_salv_table = go_alv  " Erstelle ALV-Instanz und weise sie der Referenz go_alv zu
  changing t_table = lt_output ).  " Weist die ALV-Tabelle lt_output zu

* Funktionstasten (Sortieren, Filtern, Excel-Export etc.)
go_functions = go_alv->get_functions( ).  " Holt die Funktionstasten für den ALV
go_functions->set_all( abap_true ).  " Aktiviert alle Funktionstasten (Sortieren, Filtern, Excel-Export)

* Optimale Spaltenbreite
go_columns = go_alv->get_columns( ).  " Holt die Spalteneinstellungen für den ALV
go_columns->set_optimize( abap_true ).  " Setzt die automatische Optimierung der Spaltenbreite

* Titel und/oder Streifenmuster
go_display = go_alv->get_display_settings( ).  " Holt die Anzeigeeinstellungen für den ALV
go_display->set_list_header( value = 'Meine Liste' ).  " Setzt den Titel der Liste
go_display->set_striped_pattern( abap_true ).  " Aktiviert das Streifenmuster für die Zeilen

* Liste anzeigen
go_alv->display( ).  " Zeigt den ALV an


*Ausgabe ohne ALV -> einfache Liste
*DATA: lt_dynamic_table TYPE REF TO data,
*      lt_counts TYPE TABLE OF string,
*      lv_count TYPE i,
*      lv_field TYPE string,
*      lv_field_name TYPE string,
*      lv_count_str TYPE string.
*
*FIELD-SYMBOLS: <fs_field> TYPE any,
*               <fs_structure> TYPE any,
*               <fs_table> TYPE STANDARD TABLE.
*
*PARAMETERS: p_eingab TYPE tabname OBLIGATORY.
*
*START-OF-SELECTION.
*
** Dynamische Tabellen- und Arbeitsbereichserstellung
*TRY.
*    CREATE DATA lt_dynamic_table TYPE TABLE OF (p_eingab).
*  CATCH cx_sy_create_data_error.
*    WRITE: / 'Fehler: Ungültige Tabellennamen-Eingabe'.
*    RETURN.
*ENDTRY.
*
*ASSIGN lt_dynamic_table->* TO <fs_table>.
*
** Einträge aus der dynamischen Tabelle lesen
*SELECT * FROM (p_eingab) INTO TABLE <fs_table>.
*
** Falls keine Einträge vorhanden sind
*IF <fs_table> IS INITIAL.
*  WRITE: / 'Keine Einträge in Tabelle', p_eingab, 'gefunden'.
*  RETURN.
*ENDIF.
*
** Loop über die Struktur, um jedes Feld zu prüfen
*DO.
*  ASSIGN COMPONENT sy-index OF STRUCTURE <fs_table>[ 1 ] TO <fs_field>.
*
*  IF sy-subrc <> 0.
*    EXIT. " Keine weiteren Felder vorhanden
*  ENDIF.
*
*  CLEAR lv_count.
*
*  LOOP AT <fs_table> ASSIGNING <fs_structure>.
*    ASSIGN COMPONENT sy-index OF STRUCTURE <fs_structure> TO <fs_field>.
*
*    IF <fs_field> IS NOT INITIAL.
*      lv_count = lv_count + 1.
*    ENDIF.
*  ENDLOOP.
*
** Feldname ermitteln
*  lv_field_name = cl_abap_typedescr=>describe_by_data( <fs_field> )->get_relative_name( ).
*
*  " Zähler in String umwandeln
*  lv_count_str = lv_count.
*  CONCATENATE lv_field_name ':' lv_count_str INTO lv_field SEPARATED BY space.
*  APPEND lv_field TO lt_counts.
*ENDDO.
*
** Ergebnis ausgeben
*LOOP AT lt_counts INTO DATA(lv_output).
*  WRITE: / lv_output.
*ENDLOOP.
