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
  #"Renamed Columns" = Table.RenameColumns(
    #"Changed Type",
    {
      {"customer_zip_code_prefix", "Zip Code"},
      {"customer_city", "Customer City"},
      {"customer_state", "Customer State"}
    }
  ),
  #"Added Index" = Table.AddIndexColumn(#"Renamed Columns", "Customer Id", 1, 1, Int64.Type)
in
  #"Added Index"