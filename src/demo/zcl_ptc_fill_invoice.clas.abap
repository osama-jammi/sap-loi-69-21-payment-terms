CLASS zcl_ptc_fill_invoice DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_ptc_fill_invoice IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

    DATA lt_inv TYPE STANDARD TABLE OF zptc_invoice WITH EMPTY KEY.

    TYPES: BEGIN OF ty_sup,
             id   TYPE c LENGTH 10,
             name TYPE c LENGTH 40,
           END OF ty_sup.
    DATA(lt_sup) = VALUE STANDARD TABLE OF ty_sup WITH EMPTY KEY(
      ( id = '1000001' name = 'Osama Jammi Logistique SARL' )
      ( id = '1000002' name = 'Osama Jammi Transport SA' )
      ( id = '1000003' name = 'Osama Jammi Fournitures' ) ).

    DATA(lv_base) = CONV d( '20260105' ).

    DO 24 TIMES.
      DATA(lv_idx)  = sy-index.
      DATA(ls_sup)  = lt_sup[ ( lv_idx - 1 ) MOD 3 + 1 ].

      DATA(lv_invoice) = CONV d( lv_base + ( lv_idx * 10 ) ).
      DATA(lv_due)     = CONV d( lv_invoice + 60 ).
      " 1 facture sur 4 payée dans les délais, les autres en retard de 20 à 100 jours
      DATA(lv_late)    = COND i( WHEN lv_idx MOD 4 = 0 THEN 0
                                 ELSE ( lv_idx MOD 5 + 1 ) * 20 ).

      APPEND VALUE #( company_code  = '1010'
                      doc_number    = |{ 5100000000 + lv_idx }|
                      fiscal_year   = '2026'
                      supplier      = ls_sup-id
                      supplier_name = ls_sup-name
                      invoice_date  = lv_invoice
                      due_date      = lv_due
                      payment_date  = lv_due + lv_late
                      amount_ttc    = lv_idx * 12500
                      currency_code = 'MAD' ) TO lt_inv.
    ENDDO.

    DELETE FROM zptc_invoice.
    INSERT zptc_invoice FROM TABLE @lt_inv.
    out->write( |Factures de démonstration enregistrées : { sy-dbcnt }| ).
  ENDMETHOD.
ENDCLASS.
