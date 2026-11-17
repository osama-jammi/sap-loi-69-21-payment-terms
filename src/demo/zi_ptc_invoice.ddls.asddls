@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Factures fournisseurs payées (loi 69-21) - version démo'
define view entity ZI_PTC_INVOICE
  as select from zptc_invoice as Item
{
  key Item.company_code    as CompanyCode,
  key Item.doc_number      as AccountingDocument,
  key Item.fiscal_year     as FiscalYear,
      Item.supplier        as Supplier,
      Item.currency_code   as CompanyCodeCurrency,
      Item.invoice_date    as InvoiceDate,
      Item.due_date        as DueDate,
      Item.payment_date    as PaymentDate,
      Item.amount_ttc      as AmountTtc,
      dats_days_between( Item.due_date, Item.payment_date ) as DaysLate
}
where Item.payment_date is not initial
