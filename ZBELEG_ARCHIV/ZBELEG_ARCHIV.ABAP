*&---------------------------------------------------------------------*
*& Report ZBELEG_ARCHIV
*&---------------------------------------------------------------------*
*& Ersteller  : Arben Hajruli
*& Anforderer : Klinger Petra
*& Datum      : 04.02.2024
*& Kommentar  : Belege aus dem Archiv in Anlageliste (FB03) aufrufen mithilfe von
*&              und mit hilfe von belegnr, buchkreis, geschjahr automatisch speichern
*&
*&
*&---------------------------------------------------------------------*
*& Änderungen: Hier Anpassungen folgendermaßen eingeben
*&             #Ticketnr/Name/Datum - Kurzbeschreibung
*&
*&---------------------------------------------------------------------*
REPORT zbeleg_archiv.

" Definition der Eingabeparameter für den Benutzer
PARAMETERS: p_belnr TYPE belnr_d OBLIGATORY,   " Belegnummer (10 Stellen, Pflichtfeld)
            p_bukrs TYPE bukrs   OBLIGATORY,   " Buchungskreis (4 Stellen, Pflichtfeld)
            p_gjahr TYPE gjahr   OBLIGATORY.   " Geschäftsjahr (4 Stellen, Pflichtfeld)

AT SELECTION-SCREEN.
  PERFORM execute_gos_service.

FORM execute_gos_service.
  DATA: ls_object    TYPE borident,      " Struktur für die BOR-Identifikation eines Geschäftsobjekts
        lv_service   TYPE sgs_srvnam,    " Variable für den Service-Namen des GOS-Dienstes
        lv_no_commit TYPE sgs_cmode,     " Boolescher Parameter zur Steuerung von COMMIT-Verhalten (X = kein Commit)
        lv_popup     TYPE sgs_cmode,     " Boolescher Parameter zur Steuerung der Anzeige eines Popups (X = anzeigen)
        lv_rwmod     TYPE sgs_rwmod.     " Parameter für den Lese-/Schreibmodus

  " Aufbau der Objektinformationen für den GOS-Dienst
  ls_object-objtype = 'BKPF'. " Setzt den Objekttyp auf 'BKPF' (Belegkopf für FI-Dokumente)

  " Zusammensetzen des Objektschlüssels aus Buchungskreis, Belegnummer und Geschäftsjahr
  CONCATENATE p_bukrs p_belnr p_gjahr INTO ls_object-objkey.

  " Definition der Parameter für den Generic Object Services (GOS)-Aufruf
  lv_service   = 'VIEW_ATTA'.  " Der Service 'VIEW_ATTA' dient dazu, Anhänge anzuzeigen
  lv_no_commit = 'X'.          " Verhindert das automatische Commit (Sicherstellen, dass keine ungewollten DB-Änderungen erfolgen)
  lv_popup     = 'X'.          " Aktiviert ein Popup-Fenster für die Anzeige der Anhänge
  lv_rwmod     = 'E'.          " Setzt den Lese-/Schreibmodus auf 'E' (vermutlich für nur Lesemodus)

  " Aufruf der GOS-Funktion zum Anzeigen der Anhänge
  CALL FUNCTION 'GOS_EXECUTE_SERVICE'
    EXPORTING
      ip_service   = lv_service   " Übergabe des gewünschten GOS-Services
      is_object    = ls_object    " Übergabe des Objekts mit Objekttyp und Schlüssel
      ip_no_commit = lv_no_commit " Steuerung des Commit-Verhaltens
      ip_popup     = lv_popup     " Steuerung, ob ein Popup angezeigt wird
      ip_rwmod     = lv_rwmod     " Setzen des Lese-/Schreibmodus
    EXCEPTIONS
      OTHERS       = 1.           " Allgemeine Fehlerbehandlung (subrc = 1, falls Fehler auftritt)

  " Fehlerbehandlung: Falls die Funktion nicht erfolgreich war, wird eine Fehlermeldung ausgegeben
  IF sy-subrc <> 0.
    MESSAGE 'Fehler beim Anzeigen der Archiv-Anhänge' TYPE 'E'. " Ausgabe einer Fehlermeldung
  ENDIF.
ENDFORM.
