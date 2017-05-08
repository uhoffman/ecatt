*--------------------------------------------------------------------
*
*  Bestellpositionen aus ERP übernehmen
*  und neue Bestellungen sowie WE-Transport erzeugen
*
*  Es werden n UB Bestellungen mit m Positionen aus einer existierenden
*  Bestellung erzeugt und die Avisierung bis zum Schritt 'Übernahme'
*  durchgeführt
*
*---------------------------------------------------------------------

*--- zu kopierende Bestellungnummer übernehmen
LV_PARAM = I_BEST2COPY.
*--- Selektionskriterium definieren
ABAP.
  data lv_ebeln   type ebeln.
  DATA l_line     TYPE line.
  lv_ebeln = lv_param.
  CONCATENATE 'EBELN = ''' lv_ebeln '''' INTO l_line .
  MOVE: l_line TO ls_options.
ENDABAP.
APPEND ( LT_OPTIONS , ls_options ).

*--- Ergebnissparameter zusammenstellen
LS_FIELDS-FIELDNAME = 'EBELN'.
APPEND ( LT_FIELDS , ls_fields ).
LS_FIELDS-FIELDNAME = 'MATNR'.
APPEND ( LT_FIELDS , ls_fields ).
LS_FIELDS-FIELDNAME = 'MENGE'.
APPEND ( LT_FIELDS , ls_fields ).

*--- Zugriff auf Tabelle EKPO
FUN ( RFC_READ_TABLE , TABLE_PARA , Z_CLNT ).

*--- Anzahl der zu übernhemenden Positionen einschränken
L_MAX = I_ANZ_POSITIONEN.

*--- Positionstabelle zusammenstellen
ABAP.
  data lt_adata    TYPE TABLE OF tab512.
  data lv_dummy    type string.

  FIELD-SYMBOLS: <fs_data>    TYPE tab512.

  lt_adata = lt_data.

  LOOP AT lt_adata ASSIGNING <fs_data>.
    if sy-tabix > l_max.
      exit.
    endif.
    LS_POSITION-ARTIKEL_ID = <fs_data>+10(18).
    LS_POSITION-BESTELLMENGE = <fs_data>+28.
    CONDENSE LS_POSITION-BESTELLMENGE NO-GAPS.
    SPLIT LS_POSITION-BESTELLMENGE AT '.' INTO LS_POSITION-BESTELLMENGE
    lv_dummy.
    APPEND LS_POSITION TO Lt_POSITIONs.
  ENDLOOP.

ENDABAP.

*--- Gewünschte Anzahl Bestellungen anlegen
DO ( I_ANZ_BESTELLUNG ).
  REF ( Y_30_MS_ZM_ZUB_MASS_ANLEGEN , BESTELL_PARAMS_2 ).
  LS_BESTELLUNG-MARKT_ID = I_MARKT_ID.
  APPEND ( LT_BESTELLUNG , LS_BESTELLUNG ).
ENDDO.

*--- Avisierung durchführen
REF ( Y_30_MS_AVIS_THM_MISCH_MASS , AVISIERUNG_2 , Z_CLNT ).
