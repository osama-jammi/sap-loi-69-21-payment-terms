CLASS zcl_ptc_run DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_ptc_run IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

    TYPES: BEGIN OF ty_sum,
             supplier TYPE zi_ptc_invoice-Supplier,
             yr       TYPE n LENGTH 4,
             quarter  TYPE n LENGTH 1,
             nb       TYPE i,
             amount   TYPE decfloat34,
             penalty  TYPE decfloat34,
           END OF ty_sum.
    DATA lt_sum TYPE SORTED TABLE OF ty_sum
         WITH UNIQUE KEY supplier yr quarter.

    " factures fournisseurs payées en retard
    SELECT * FROM zi_ptc_invoice
      WHERE DaysLate > 0
      INTO TABLE @DATA(lt_inv).

    IF lt_inv IS INITIAL.
      out->write( 'Aucune facture en retard trouvée' ).
      RETURN.
    ENDIF.

    " taux directeur par période (le plus récent en premier)
    SELECT * FROM zptc_param
      ORDER BY valid_from DESCENDING
      INTO TABLE @DATA(lt_param).

    IF lt_param IS INITIAL.
      out->write( 'Table ZPTC_PARAM vide : lance ZCL_PTC_INIT_PARAM' ).
      RETURN.
    ENDIF.

    LOOP AT lt_inv INTO DATA(ls_inv).

      " taux valable à la date du paiement
      DATA(lv_rate) = CONV decfloat34( 0 ).
      LOOP AT lt_param INTO DATA(ls_param)
           WHERE valid_from <= ls_inv-PaymentDate.
        lv_rate = ls_param-key_rate.
        EXIT.
      ENDLOOP.

      DATA(lv_amount)  = CONV decfloat34( abs( ls_inv-AmountTtc ) ).
      DATA(lv_penalty) = zcl_ptc_penalty=>compute(
                           iv_amount_ttc = lv_amount
                           iv_days_late  = ls_inv-DaysLate
                           iv_key_rate   = lv_rate ).

      DATA(lv_yr)      = CONV numc4( ls_inv-PaymentDate(4) ).
      DATA(lv_month)   = CONV i( ls_inv-PaymentDate+4(2) ).
      DATA(lv_quarter) = CONV numc1( ( lv_month - 1 ) DIV 3 + 1 ).

      READ TABLE lt_sum ASSIGNING FIELD-SYMBOL(<ls_sum>)
           WITH TABLE KEY supplier = ls_inv-Supplier
                          yr       = lv_yr
                          quarter  = lv_quarter.
      IF sy-subrc <> 0.
        INSERT VALUE #( supplier = ls_inv-Supplier
                        yr       = lv_yr
                        quarter  = lv_quarter )
               INTO TABLE lt_sum ASSIGNING <ls_sum>.
      ENDIF.
      <ls_sum>-nb      = <ls_sum>-nb + 1.
      <ls_sum>-amount  = <ls_sum>-amount + lv_amount.
      <ls_sum>-penalty = <ls_sum>-penalty + lv_penalty.
    ENDLOOP.

    DATA(lv_total) = CONV decfloat34( 0 ).
    LOOP AT lt_sum INTO DATA(ls_sum).
      out->write( |{ ls_sum-supplier } | &&
                  |T{ ls_sum-quarter }/{ ls_sum-yr } : | &&
                  |{ ls_sum-nb } factures, { ls_sum-amount } MAD, | &&
                  |pénalité { ls_sum-penalty } MAD| ).
      lv_total = lv_total + ls_sum-penalty.
    ENDLOOP.
    out->write( |TOTAL à payer au Trésor : { lv_total } MAD| ).
  ENDMETHOD.
ENDCLASS.
