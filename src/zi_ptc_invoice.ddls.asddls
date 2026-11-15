@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Factures fournisseurs payées (loi 69-21)'
define view entity ZI_PTC_INVOICE
  as select from I_OperationalAcctgDocItem as Item
{
  key Item.CompanyCode,
  key Item.AccountingDocument,
  key Item.FiscalYear,
  key Item.AccountingDocumentItem,
      Item.Supplier,
      Item.CompanyCodeCurrency,
      Item.DocumentDate                as InvoiceDate,
      Item.NetDueDate                  as DueDate,
      Item.ClearingDate                as PaymentDate,
      Item.AmountInCompanyCodeCurrency as AmountTtc,
      dats_days_between( Item.NetDueDate, Item.ClearingDate ) as DaysLate
}
where Item.FinancialAccountType = 'K'
  and Item.ClearingDate is not initial
