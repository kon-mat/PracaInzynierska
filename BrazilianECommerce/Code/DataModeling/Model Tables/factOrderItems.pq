let
  // Wczytanie danych z pliku CSV
  Source = Csv.Document(
    File.Contents(
      "D:\Programowanie\PracaDyplomowa\BrazilianECommerce\Dataset\olist_order_items_dataset.csv"
    ),
    [Delimiter = ",", Columns = 7, Encoding = 1250, QuoteStyle = QuoteStyle.None]
  ),

  // Ustawienie pierwszego wiersza na nagłówki kolumn
  #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),

  // Zmiana typów danych kolumn na odpowiednie
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

  // Zmiana nazw kolumn na bardziej zrozumiałe
  #"Renamed Columns" = Table.RenameColumns(
    #"Changed Type",
    {
      {"order_item_id", "Item Id"},
      {"shipping_limit_date", "Shipping Limit Date"},
      {"price", "Price"},
      {"freight_value", "Freight Value"}
    }
  ),

  // Połączenie z tabelą olist_orders_dataset na podstawie kolumny "order_id"
  #"Merged Queries" = Table.NestedJoin(
    #"Renamed Columns",
    {"order_id"},
    olist_orders_dataset,
    {"order_id"},
    "olist_orders_dataset",
    JoinKind.LeftOuter
  ),

  // Rozwinięcie tabeli olist_orders_dataset, aby uzyskać kolumnę "Order Id"
  #"Expanded olist_orders_dataset" = Table.ExpandTableColumn(
    #"Merged Queries",
    "olist_orders_dataset",
    {"Order Id"},
    {"Order Id"}
  ),

  // Połączenie z tabelą olist_products_dataset na podstawie kolumny "product_id"
  #"Merged Queries1" = Table.NestedJoin(
    #"Expanded olist_orders_dataset",
    {"product_id"},
    olist_products_dataset,
    {"product_id"},
    "olist_products_dataset",
    JoinKind.LeftOuter
  ),

  // Rozwinięcie tabeli olist_products_dataset, aby uzyskać kolumnę "Product Id"
  #"Expanded olist_products_dataset" = Table.ExpandTableColumn(
    #"Merged Queries1",
    "olist_products_dataset",
    {"Product Id"},
    {"Product Id"}
  ),

  // Połączenie z tabelą olist_sellers_dataset na podstawie kolumny "seller_id"
  #"Merged Queries2" = Table.NestedJoin(
    #"Expanded olist_products_dataset",
    {"seller_id"},
    olist_sellers_dataset,
    {"seller_id"},
    "olist_sellers_dataset",
    JoinKind.LeftOuter
  ),

  // Rozwinięcie tabeli olist_sellers_dataset, aby uzyskać kolumnę "Seller Id"
  #"Expanded olist_sellers_dataset" = Table.ExpandTableColumn(
    #"Merged Queries2",
    "olist_sellers_dataset",
    {"Seller Id"},
    {"Seller Id"}
  ),

  // Usunięcie kolumn, które są już zintegrowane z innych tabel i są zbędne
  #"Removed Columns" = Table.RemoveColumns(
    #"Expanded olist_sellers_dataset",
    {"order_id", "product_id", "seller_id"}
  ),

  // Zmiana kolejności kolumn dla lepszej organizacji i czytelności
  #"Reordered Columns" = Table.ReorderColumns(
    #"Removed Columns",
    {
      "Order Id",
      "Product Id",
      "Seller Id",
      "Item Id",
      "Shipping Limit Date",
      "Price",
      "Freight Value"
    }
  )
in
  #"Reordered Columns"
