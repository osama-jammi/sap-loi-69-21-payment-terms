@EndUserText.label: 'Pénalités par fournisseur et trimestre'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_PTC_QUERY'
@UI.headerInfo: { typeName: 'Pénalité', typeNamePlural: 'Pénalités' }
define custom entity ZC_PTC_SUMMARY
{
      @UI.lineItem:       [{ position: 10, label: 'Fournisseur' }]
      @UI.selectionField: [{ position: 10 }]
  key Supplier     : abap.char(10);
      @UI.lineItem:       [{ position: 20, label: 'Année' }]
  key FiscalYear   : abap.numc(4);
      @UI.lineItem:       [{ position: 30, label: 'Trimestre' }]
  key Quarter      : abap.numc(1);
      @UI.lineItem:       [{ position: 40, label: 'Nb factures' }]
      InvoiceCount : abap.int4;
      @UI.lineItem:       [{ position: 50, label: 'Montant TTC' }]
      @Semantics.amount.currencyCode: 'Currency'
      Amount       : abap.curr(15,2);
      @UI.lineItem:       [{ position: 60, label: 'Pénalité à payer' }]
      @Semantics.amount.currencyCode: 'Currency'
      Penalty      : abap.curr(15,2);
      Currency     : abap.cuky(5);
}
