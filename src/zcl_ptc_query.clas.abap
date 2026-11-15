CLASS zcl_ptc_query DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
ENDCLASS.

CLASS zcl_ptc_query IMPLEMENTATION.
  METHOD if_rap_query_provider~select.

    DATA lt_result TYPE STANDARD TABLE OF zc_ptc_summary WITH EMPTY KEY.

    SELECT * FROM zi_ptc_invoice
      WHERE DaysLate > 0
      INTO TABLE @DATA(lt_inv).

    SELECT * FROM zptc_param
      ORDER BY valid_from DESCENDING
      INTO TABLE @DATA(lt_param).

    LOOP AT lt_inv INTO DATA(ls_inv).

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

      READ TABLE lt_result ASSIGNING FIELD-SYMBOL(<ls_res>)
           WITH KEY Supplier   = ls_inv-Supplier
                    FiscalYear = lv_yr
                    Quarter    = lv_quarter.
      IF sy-subrc <> 0.
        APPEND VALUE #( Supplier   = ls_inv-Supplier
                        FiscalYear = lv_yr
                        Quarter    = lv_quarter
                        Currency   = 'MAD' ) TO lt_result ASSIGNING <ls_res>.
      ENDIF.
      <ls_res>-InvoiceCount = <ls_res>-InvoiceCount + 1.
      <ls_res>-Amount       = <ls_res>-Amount + lv_amount.
      <ls_res>-Penalty      = <ls_res>-Penalty + lv_penalty.
    ENDLOOP.

    IF io_request->is_data_requested( ).
      io_response->set_data( lt_result ).
    ENDIF.
    IF io_request->is_total_numb_of_rec_requested( ).
      io_response->set_total_number_of_records( lines( lt_result ) ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
