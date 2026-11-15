*"* use this source file for your ABAP unit test classes
CLASS ltc_penalty DEFINITION FINAL FOR TESTING
  RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    METHODS exemple_3_mois FOR TESTING.
    METHODS pas_de_retard  FOR TESTING.
ENDCLASS.

CLASS ltc_penalty IMPLEMENTATION.
  METHOD exemple_3_mois.
    cl_abap_unit_assert=>assert_equals(
      exp = 3950
      act = zcl_ptc_penalty=>compute( iv_amount_ttc = 100000
                                      iv_days_late  = 90
                                      iv_key_rate   = '2.25' ) ).
  ENDMETHOD.
  METHOD pas_de_retard.
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = zcl_ptc_penalty=>compute( iv_amount_ttc = 100000
                                      iv_days_late  = 0
                                      iv_key_rate   = '2.25' ) ).
  ENDMETHOD.
ENDCLASS.
