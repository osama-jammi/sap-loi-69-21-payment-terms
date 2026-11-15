CLASS zcl_ptc_init_param DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_ptc_init_param IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DELETE FROM zptc_param.
    INSERT zptc_param FROM TABLE @( VALUE #(
      ( valid_from = '20260101' key_rate = '2.25' default_days = 60 ) ) ).
    out->write( |Paramètres enregistrés : { sy-dbcnt } ligne(s)| ).
  ENDMETHOD.
ENDCLASS.
