*&---------------------------------------------------------------------*
*& Include          ZUSER_NEU_TEST_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  Z_1000_PAI  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE z_1000_pai INPUT.
  CASE sy-ucomm.

    WHEN 'FCT_BACK' OR 'BACK' OR 'CANCEL' OR 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.

  IF sy-ucomm = 'FCT_ANLEGEN'.
    IF rb_mitarbeiter = 'X'.
      CALL SCREEN '2000'.
    ELSEIF rb_onlinekunde = 'X'.
      CALL SCREEN '3000'.
    ENDIF.
  ENDIF.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  Z_2000_PAI  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE z_2000_pai INPUT.
  CASE sy-ucomm.

    WHEN 'FCT_ANLEGEN'.
      IF lv_title IS NOT INITIAL AND lv_fname IS NOT INITIAL AND lv_lname  IS NOT INITIAL AND lv_user1 IS NOT INITIAL.
        PERFORM benutzername.
        PERFORM setdata.
        PERFORM usercreate.
        PERFORM favoriten.
        SET SCREEN '2001'.
      ELSE.
        MESSAGE 'Bitte alle Felder ausfüllen' TYPE 'I' DISPLAY LIKE 'I'.  "Fehlertext
      ENDIF.



    WHEN 'FCT_BACK' OR 'BACK' OR 'CANCEL' OR 'EXIT'.
      CALL SCREEN '1000'.

  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  Z_3000_PAI  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE z_3000_pai INPUT.
  CASE sy-ucomm.
    WHEN 'FCT_ANLEGEN'.
      IF lv_username IS NOT INITIAL AND lv_title IS NOT INITIAL AND lv_fname IS NOT INITIAL AND lv_lname  IS NOT INITIAL AND lv_email IS NOT INITIAL.
        "PERFORM shopuser.
        "SET SCREEN '3001'.
        MESSAGE 'Programm nicht ausführbar!' TYPE 'I' DISPLAY LIKE 'I'. "Fehlertext
      ELSE.
        CALL SCREEN '1000'.
      ENDIF.

    WHEN 'FCT_BACK' OR 'BACK' OR 'CANCEL' OR 'EXIT'.
      CALL SCREEN '1000'.
  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  Z_2001_PAI  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE z_2001_pai INPUT.
  CASE sy-ucomm.
    WHEN 'FCT_BACK' OR 'BACK' OR 'CANCEL' OR 'EXIT'.
      CALL SCREEN '1000'.

    WHEN 'FCT_WINKLERNOW'.
      CALL TRANSACTION 'ZWNOW02' WITHOUT AUTHORITY-CHECK.

    WHEN 'FCT_TABELLE'.
      "tabelle mit alle informationen muss noch programiert werden
      call screen '1000'.
  ENDCASE.
ENDMODULE.


*&---------------------------------------------------------------------*
*&      Module  Z_3001_PAI  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE z_3001_pai INPUT.
  CASE sy-ucomm.
    WHEN 'FCT_BACK' OR 'BACK' OR 'CANCEL' OR 'EXIT'.
      CALL SCREEN '1000'.
  ENDCASE.
ENDMODULE.
