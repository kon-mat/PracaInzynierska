let
  Source = Csv.Document(
    File.Contents(
      "D:\Programowanie\PracaDyplomowa\BrazilianECommerce\Dataset\olist_order_items_dataset.csv"
    ),
    [Delimiter = ",", Columns = 7, Encoding = 1250, QuoteStyle = QuoteStyle.None]
  ),
  #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
  #"Changed Type" = Table.TransformColumnTypes(
    #"Promoted Headers",
    {
      {"order_id", type text},
      {"order_item_id", Int64.Type},
      {"product_id", type text},
      {"seller_id", type text},
      {"shipping_limit_date", type datetime},
      {"price", Currency.Type},
      {"freight_value", Currency.Type}
    }
  ),
  #"Renamed Columns" = Table.RenameColumns(
    #"Changed Type",
    {
      {"order_item_id", "Item Id"},
      {"shipping_limit_date", "Shipping Limit Date"},
      {"price", "Price"},
      {"freight_value", "Freight Value"}
    }
  )
in
  #"Renamed Columns"