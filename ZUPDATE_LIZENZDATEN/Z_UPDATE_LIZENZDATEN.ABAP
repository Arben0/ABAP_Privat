*&---------------------------------------------------------------------*
*& Report Z_UPDATE_LIZENZDATEN
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Ersteller  : Arben Hajruli
*& Anforderer : David Thompson & Oktay Özdal
*& Datum      : 12.08.2024
*& Kommentar  : Benutzer Lizenzdaten ändern
*&
*&
*&---------------------------------------------------------------------*
*& Änderungen: Hier Anpassungen folgendermaßen eingeben
*&             #Ticketnr/Name/Datum - Kurzbeschreibung
*&             #Hajruli/20.12.2024 - anpassung - an falschem Programm gearbeitet, nichts wurde geändert, mögliche Erweiterung: mehrere Radio buttons als auswahl für lizenzdaten
*&
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
REPORT z_update_lizenzdaten.

" Program für email ändern
DATA: ls_user_uclass  TYPE bapiuclass,         " Struktur für die Benutzerklassifikation
      ls_user_uclassx TYPE bapiuclassx,        " Struktur für die Änderungsindikatoren
      lt_return       TYPE TABLE OF bapiret2,  " Tabelle für die Rückmeldungen der BAPI
      ls_return       TYPE bapiret2,           " Einzelne Rückmeldung
      lv_username     TYPE uname.              " Variable für den einzelnen Benutzernamen

" Selection-Screen für die Mehrfachselektion der Benutzernamen
SELECT-OPTIONS: so_user FOR lv_username.

START-OF-SELECTION.

  " Prüfen, ob Benutzernamen eingegeben wurden
  IF so_user[] IS INITIAL.
    WRITE: / 'Bitte geben Sie mindestens einen Benutzernamen ein.'.
    EXIT.
  ENDIF.

  " Initialisiere die Struktur für die Benutzerklassifikation
  CLEAR: ls_user_uclass, ls_user_uclassx.

  ls_user_uclass-lic_type = '53'.                 " Setzen des neuen Lizenztyps
  ls_user_uclass-country_surcharge = '0'.         " Landeszuschlag auf 0 setzen

  " Setzen der Änderungsindikatoren
  ls_user_uclassx-uclass = 'X'.                   " Markierung, dass die Benutzerklassifikation geändert wird

  " Schleife über alle ausgewählten Benutzernamen
  LOOP AT so_user INTO DATA(wa_user). "LOOP AT so_user INTO lv_username.

    " Benutzername extrahieren ohne Vergleichsoperatoren (LOW-Feld ist der tatsächliche Name)
    lv_username = wa_user-low.

    " Leeren der Rückmeldetabelle vor jedem BAPI-Aufruf
    CLEAR lt_return.

    " BAPI aufrufen, um die Lizenzdaten für jeden Benutzer zu ändern
    CALL FUNCTION 'BAPI_USER_CHANGE'
      EXPORTING
        username = lv_username                    " Benutzernamen übergeben
        uclass   = ls_user_uclass                 " Lizenzdaten übergeben
        uclassx  = ls_user_uclassx                " Änderungsindikatoren übergeben
      TABLES
        return   = lt_return.                     " Rückmeldungen in Tabelle lt_return einfügen

    " Prüfen, ob die Änderung erfolgreich war
    LOOP AT lt_return INTO ls_return.
      WRITE: / ls_return-message.  "'Benutzer:', lv_username, 'Typ:', ls_return-type, 'Nachricht:', ls_return-message.
    ENDLOOP.

    " BAPI-Transaktion bestätigen
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.  " Sicherstellen, dass die Transaktion abgeschlossen wird
  ENDLOOP.

  " Abschlussmeldung
  WRITE: / 'Lizenzdaten für alle ausgewählten Benutzer wurden aktualisiert.'.








*" Lizenzdaten für 1 Benutzer ändern
*DATA: lv_username     TYPE uname,                " Deklaration einer Variable für den Benutzernamen
*      ls_user_uclass  TYPE bapiuclass,           " Deklaration einer Struktur für die Benutzerklassifikation
*      ls_user_uclassx TYPE bapiuclassx,          " Deklaration einer Struktur für die Änderungsindikatoren der Benutzerklassifikation
*      lt_return       TYPE TABLE OF bapiret2.    " Deklaration einer internen Tabelle für Rückmeldungen der BAPI
*
*" Setzen des Benutzernamens auf 'MARI'
*lv_username = 'MARIMA'.
*
*" Initialisieren der Strukturen und Tabelle
*CLEAR: ls_user_uclass, ls_user_uclassx, lt_return.
*
*" Setzen der Lizenzdaten für den Benutzer
*ls_user_uclass-lic_type = '52'.                  " Setzen des Lizenztyps auf '11' (neuer Lizenztyp)
*ls_user_uclass-country_surcharge = '0'.          " Setzten des Landeszuschlages auf '0'%
*
*
*" Setzen der Änderungsindikatoren für die Benutzerklassifikation
*ls_user_uclassx-uclass = 'X'.                    " Indikator setzen, um das Feld 'uclass' als geändert zu markieren
**ls_user_uclassx-uclasssys = 'R'.                " Wird nicht verwendet, da nur 'uclass' geändert wird
*
*" Aufruf der BAPI-Funktion zum Ändern der Benutzerdaten
*CALL FUNCTION 'BAPI_USER_CHANGE'
*  EXPORTING
*    username = lv_username                       " Übergeben des Benutzernamens an die BAPI
*    uclass   = ls_user_uclass                    " Übergeben der Benutzerklassifikationsdaten an die BAPI
*    uclassx  = ls_user_uclassx                   " Übergeben der Änderungsindikatoren an die BAPI
*  TABLES
*    return   = lt_return.                         " Rückmeldungen der BAPI in die interne Tabelle lt_return einfügen
**   UCLASSSYS                =
*
*" Bestätigen der Transaktion, um die Änderungen zu speichern
*CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
** EXPORTING
**    wait = 'X'.                                 " Warten auf die Bestätigung der Transaktion
*
*" Rückmeldungen prüfen und ausgeben
*LOOP AT lt_return INTO DATA(ls_return).          " Schleife über die Rückmeldungen der BAPI
*  WRITE: "/ ls_return-type,                       " Ausgabe des Rückmeldungstyps (z.B. 'E' für Fehler)
*         "ls_return-id,                           " Ausgabe der Rückmeldung-ID
*         "ls_return-number,                       " Ausgabe der Rückmelde-Nr.
*         ls_return-message.                      " Ausgabe der Rückmeldungsnachricht
*ENDLOOP.

