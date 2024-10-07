let
  Source = Csv.Document(
    File.Contents(
      "D:\Programowanie\PracaDyplomowa\BrazilianECommerce\Dataset\olist_customers_dataset.csv"
    ),
    [Delimiter = ",", Columns = 5, Encoding = 1250, QuoteStyle = QuoteStyle.None]
  ),
  #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
  #"Changed Type" = Table.TransformColumnTypes(
    #"Promoted Headers",
    {
      {"customer_id", type text},
      {"customer_unique_id", type text},
      {"customer_zip_code_prefix", Int64.Type},
      {"customer_city", type text},
      {"customer_state", type text}
    }
  ),
  #"Removed Other Columns" = Table.SelectColumns(#"Changed Type", {"customer_unique_id"}),
  #"Removed Duplicates" = Table.Distinct(#"Removed Other Columns"),
  #"Added Index" = Table.AddIndexColumn(
    #"Removed Duplicates",
    "Customer Unique Id",
    1,
    1,
    Int64.Type
  )
in
  #"Added Index"