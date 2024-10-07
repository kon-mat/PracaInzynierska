let
  // Wczytanie danych z pliku CSV do tabeli
  Source = Csv.Document(
    File.Contents(
      "D:\Programowanie\PracaDyplomowa\BrazilianECommerce\Dataset\olist_order_items_dataset.csv"
    ), 
    [Delimiter = ",", Columns = 7, Encoding = 1250, QuoteStyle = QuoteStyle.None]
  ), 

  // Ustawienie pierwszego wiersza jako nagłówków kolumn
  #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]), 

  // Zmiana typów danych kolumn na odpowiednie typy
  #"Changed Column Types" = Table.TransformColumnTypes(
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

  // Połączenie z tabelą olist_order_reviews_dataset na podstawie kolumny "order_id"
  #"Merged Order Reviews Dataset" = Table.NestedJoin(
    #"Changed Column Types", 
    {"order_id"}, 
    olist_order_reviews_dataset, 
    {"order_id"}, 
    "olist_order_reviews_dataset", 
    JoinKind.LeftOuter
  ), 

  // Rozwinięcie tabeli olist_order_reviews_dataset, aby uzyskać kolumnę "review_score"
  #"Expanded Order Reviews Dataset" = Table.ExpandTableColumn(
    #"Merged Order Reviews Dataset", 
    "olist_order_reviews_dataset", 
    {"review_score"}, 
    {"review_score"}
  ), 

  // Połączenie z tabelą olist_orders_dataset na podstawie kolumny "order_id"
  #"Merged Orders Dataset" = Table.NestedJoin(
    #"Expanded Order Reviews Dataset", 
    {"order_id"}, 
    olist_orders_dataset, 
    {"order_id"}, 
    "olist_orders_dataset", 
    JoinKind.LeftOuter
  ), 

  // Rozwinięcie tabeli olist_orders_dataset, aby uzyskać kolumnę "Order Id"
  #"Expanded Orders Dataset" = Table.ExpandTableColumn(
    #"Merged Orders Dataset", 
    "olist_orders_dataset", 
    {"Order Id"}, 
    {"Order Id"}
  ), 

  // Połączenie z tabelą olist_sellers_dataset na podstawie kolumny "seller_id"
  #"Merged Sellers Dataset" = Table.NestedJoin(
    #"Expanded Orders Dataset", 
    {"seller_id"}, 
    olist_sellers_dataset, 
    {"seller_id"}, 
    "olist_sellers_dataset", 
    JoinKind.LeftOuter
  ), 

  // Rozwinięcie tabeli olist_sellers_dataset, aby uzyskać kolumnę "Seller Id"
  #"Expanded Sellers Dataset" = Table.ExpandTableColumn(
    #"Merged Sellers Dataset", 
    "olist_sellers_dataset", 
    {"Seller Id"}, 
    {"Seller Id"}
  ), 

  // Usunięcie zbędnych kolumn, pozostawiając tylko "Seller Id", "Order Id" i "review_score"
  #"Removed Other Columns" = Table.SelectColumns(
    #"Expanded Sellers Dataset", 
    {"Seller Id", "Order Id", "review_score"}
  ), 

  // Usunięcie duplikatów
  #"Removed Duplicates" = Table.Distinct(#"Removed Other Columns"), 

  // Grupowanie wierszy według "Seller Id" i obliczanie średniej oceny dla każdego sprzedawcy
  #"Grouped Rows" = Table.Group(
    #"Removed Duplicates", 
    {"Seller Id"}, 
    {{"Seller Rating", each List.Average([review_score]), type nullable number}}
  )
in
  #"Grouped Rows"