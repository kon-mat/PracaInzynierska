let
  Source = Csv.Document(
    File.Contents(
      "D:\Programowanie\PracaDyplomowa\BrazilianECommerce\Dataset\olist_sellers_dataset.csv"
    ),
    [Delimiter = ",", Columns = 4, Encoding = 65001, QuoteStyle = QuoteStyle.None]
  ),
  #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
  #"Changed Type" = Table.TransformColumnTypes(
    #"Promoted Headers",
    {
      {"seller_id", type text},
      {"seller_zip_code_prefix", Int64.Type},
      {"seller_city", type text},
      {"seller_state", type text}
    }
  ),
  #"Renamed Columns" = Table.RenameColumns(
    #"Changed Type",
    {
      {"seller_zip_code_prefix", "Zip Code"},
      {"seller_city", "Seller City"},
      {"seller_state", "Seller State"}
    }
  ),
  #"Added Index" = Table.AddIndexColumn(#"Renamed Columns", "Seller Id", 1, 1, Int64.Type)
in
  #"Added Index"