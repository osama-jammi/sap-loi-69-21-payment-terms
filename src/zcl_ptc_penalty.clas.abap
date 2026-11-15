CLASS zcl_ptc_penalty DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    " Pénalité en MAD pour une facture payée en retard (loi 69-21)
    " iv_key_rate en % (ex. 2.25), iv_days_late = jours après l'échéance
    CLASS-METHODS compute
      IMPORTING iv_amount_ttc TYPE decfloat34
                iv_days_late  TYPE i
                iv_key_rate   TYPE decfloat34
      RETURNING VALUE(rv_penalty) TYPE decfloat34.
ENDCLASS.

CLASS zcl_ptc_penalty IMPLEMENTATION.
  METHOD compute.
    IF iv_days_late <= 0.
      rv_penalty = 0.
      RETURN.
    ENDIF.
    " mois ou fraction de mois de retard
    DATA(lv_months) = ( iv_days_late + 29 ) DIV 30.
    " 1er mois : taux directeur, ensuite +0,85 % par mois
    rv_penalty = iv_amount_ttc *
                 ( iv_key_rate + ( lv_months - 1 ) * '0.85' ) / 100.
  ENDMETHOD.
ENDCLASS.
