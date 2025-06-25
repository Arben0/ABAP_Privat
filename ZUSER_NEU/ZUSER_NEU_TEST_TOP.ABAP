*&---------------------------------------------------------------------*
*& Include ZUSER_NEU_TEST_TOP                       - Report ZUSER_NEU_TEST
*&---------------------------------------------------------------------*
REPORT zuser_neu_test.

" Tables
TABLES: usr02,
        smen_buffc,
        smen_buffi,
        smenfavdat.

" Benutzername erstellen
TABLES: soud,
        adcp,
        adrp.
DATA: BEGIN OF str,
        usrnam     LIKE soud-usrnam,
        deleted    LIKE soud-deleted,
        usradr     LIKE soud-usradr,
        addrnumber LIKE adcp-addrnumber,
        persnumber LIKE adcp-persnumber,
        name_first LIKE adrp-name_first,
        name_last  LIKE adrp-name_last,
      END OF str.
DATA: itab LIKE str OCCURS 0.
"DATA: lv_username(12) TYPE c.
DATA: l_num TYPE numc01.
DATA: BEGIN OF str_bname,
        bname LIKE soud-usrnam,
      END OF str_bname.
DATA: itab_bname_del LIKE str_bname OCCURS 0.
DATA: itab_bname     LIKE str_bname OCCURS 0.
DATA: l_vname(12),
      l_nname(12).
DATA:  l_nname_ss TYPE ad_namelas.

" User-Create
DATA: lv_username       TYPE xubname,
      ls_user_logondata TYPE bapilogond,
      ls_user_defaults  TYPE bapidefaul,
      ls_user_password  TYPE bapipwd,
      ls_user_adress    TYPE bapiaddr3,
      ls_user_uclass    TYPE bapiuclass,
      lt_return         TYPE TABLE OF bapiret2.

" Rollen und Gruppen
DATA: lt_old_activity_groups TYPE TABLE OF bapiagr,
      lt_new_activity_groups TYPE TABLE OF bapiagr,
      lt_user_parameter      TYPE TABLE OF bapiparam,
      lt_user_groups         TYPE TABLE OF bapigroups,
      ls_bapiagr             TYPE bapiagr.

" Favoriten kopieren   (Mandant in P und Q 010 und E 100)
DATA: target         TYPE xubname,
      ls_zreport_run LIKE zreport_run ##NEEDED,
      mdtsrc         TYPE t000-mandt VALUE '100',
      mdttrg         TYPE t000-mandt VALUE '100'.

" Felder
DATA: lv_title    TYPE bapiaddr3-title_p,
      lv_fname    TYPE bapiaddr3-firstname,
      lv_lname    TYPE bapiaddr3-lastname,
      lv_user1    TYPE usr02-bname,
      lv_isnummer TYPE xubname,
      lv_email    TYPE bapiaddr3-e_mail.



" Button
DATA: rb_mitarbeiter TYPE c,
      rb_onlinekunde TYPE c.

" Listbox
DATA: lt_title TYPE vrm_values,
      ls_title TYPE vrm_value.
