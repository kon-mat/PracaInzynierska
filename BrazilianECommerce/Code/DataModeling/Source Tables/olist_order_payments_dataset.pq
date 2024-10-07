let
  Source = Csv.Document(
    File.Contents(
      "D:\Programowanie\PracaDyplomowa\BrazilianECommerce\Dataset\olist_order_payments_dataset.csv"
    ),
    [Delimiter = ",", Columns = 5, Encoding = 1250, QuoteStyle = QuoteStyle.None]
  ),
  #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
  #"Changed Type" = Table.TransformColumnTypes(
    #"Promoted Headers",
    {
      {"order_id", type text},
      {"payment_sequential", Int64.Type},
      {"payment_type", type text},
      {"payment_installments", Int64.Type},
      {"payment_value", Currency.Type}
    }
  ),
  #"Filtered Rows" = Table.SelectRows(#"Changed Type", each true),
  #"Renamed Columns" = Table.RenameColumns(
    #"Filtered Rows",
    {
      {"payment_sequential", "Payment Sequential"},
      {"payment_type", "Brasil Payment Type"},
      {"payment_installments", "Payment Installment"},
      {"payment_value", "Payment Value"}
    }
  )
in
  #"Renamed Columns"