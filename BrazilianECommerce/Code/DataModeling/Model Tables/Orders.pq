let
  // Wczytanie danych z pliku CSV
  Source = Csv.Document(
    File.Contents(
      "D:\Programowanie\PracaInzynierska\BrazilianECommerce\Dataset\olist_order_items_dataset.csv"
    ), 
    [Delimiter = ",", Columns = 7, Encoding = 1250, QuoteStyle = QuoteStyle.None]
  ), 

  // Ustawienie pierwszego wiersza na nagłówki kolumn
  #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]), 

  // Rozdzielenie kolumny 'shipping_limit_date' na oddzielne kolumny 'Data' i 'Godzina'
  #"Split Column by Delimiter" = Table.SplitColumn(
    #"Promoted Headers", 
    "shipping_limit_date", 
    Splitter.SplitTextByDelimiter(" ", QuoteStyle.None), 
    {"shipping_limit_date_Date", "shipping_limit_date_Time"}
  ), 

  // Zmiana typów danych kolumn na odpowiednie
  #"Changed Column Types" = Table.TransformColumnTypes(
    #"Split Column by Delimiter", 
    {
      {"order_id", type text}, 
      {"order_item_id", Int64.Type}, 
      {"product_id", type text}, 
      {"seller_id", type text}, 
      {"shipping_limit_date_Date", type date}, 
      {"shipping_limit_date_Time", type time}, 
      {"price", Currency.Type}, 
      {"freight_value", Currency.Type}
    }
  ), 

  // Zmiana nazw kolumn na bardziej zrozumiałe
  #"Renamed Columns" = Table.RenameColumns(
    #"Changed Column Types", 
    {
      {"order_item_id", "Item Id"}, 
      {"shipping_limit_date_Date", "Shipping Limit Date"}, 
      {"shipping_limit_date_Time", "Shipping Limit Time"}, 
      {"price", "Price"}, 
      {"freight_value", "Freight Value"}
    }
  ), 

  // Połączenie z tabelą 'olist_orders_dataset' na podstawie kolumny 'order_id'
  #"Merged With Orders Dataset" = Table.NestedJoin(
    #"Renamed Columns", 
    {"order_id"}, 
    olist_orders_dataset, 
    {"order_id"}, 
    "olist_orders_dataset", 
    JoinKind.LeftOuter
  ), 

  // Rozwinięcie tabeli 'olist_orders_dataset', aby uzyskać kolumnę 'Order Id'
  #"Expanded Orders Dataset" = Table.ExpandTableColumn(
    #"Merged With Orders Dataset", 
    "olist_orders_dataset", 
    {"Order Id"}, 
    {"Order Id"}
  ), 

  // Połączenie z tabelą 'olist_products_dataset' na podstawie kolumny 'product_id'
  #"Merged With Products Dataset" = Table.NestedJoin(
    #"Expanded Orders Dataset", 
    {"product_id"}, 
    olist_products_dataset, 
    {"product_id"}, 
    "olist_products_dataset", 
    JoinKind.LeftOuter
  ), 

  // Rozwinięcie tabeli 'olist_products_dataset', aby uzyskać kolumnę 'Product Id'
  #"Expanded Products Dataset" = Table.ExpandTableColumn(
    #"Merged With Products Dataset", 
    "olist_products_dataset", 
    {"Product Id"}, 
    {"Product Id"}
  ), 

  // Połączenie z tabelą 'olist_sellers_dataset' na podstawie kolumny 'seller_id'
  #"Merged With Sellers Dataset" = Table.NestedJoin(
    #"Expanded Products Dataset", 
    {"seller_id"}, 
    olist_sellers_dataset, 
    {"seller_id"}, 
    "olist_sellers_dataset", 
    JoinKind.LeftOuter
  ), 

  // Rozwinięcie tabeli 'olist_sellers_dataset', aby uzyskać kolumnę 'Seller Id'
  #"Expanded Sellers Dataset" = Table.ExpandTableColumn(
    #"Merged With Sellers Dataset", 
    "olist_sellers_dataset", 
    {"Seller Id"}, 
    {"Seller Id"}
  ), 

  // Usunięcie kolumn, które są już zintegrowane z innych tabel i są zbędne
  #"Removed Unnecessary Columns" = Table.RemoveColumns(
    #"Expanded Sellers Dataset", 
    {"order_id", "product_id", "seller_id"}
  ), 

  // Zmiana kolejności kolumn dla lepszej organizacji i czytelności
  #"Reordered Columns" = Table.ReorderColumns(
    #"Removed Unnecessary Columns", 
    {
      "Order Id", 
      "Product Id", 
      "Seller Id", 
      "Item Id", 
      "Shipping Limit Date", 
      "Shipping Limit Time", 
      "Price", 
      "Freight Value"
    }
  )
in
  #"Reordered Columns"