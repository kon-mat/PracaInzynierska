let
  // Wczytanie danych z pliku CSV do tabeli
  Source = Csv.Document(
    File.Contents(
      "D:\Programowanie\PracaInzynierska\BrazilianECommerce\Dataset\olist_order_items_dataset.csv"
    ), 
    [Delimiter = ",", Columns = 7, Encoding = 1250, QuoteStyle = QuoteStyle.None]
  ), 

  // Ustawienie pierwszego wiersza na nagłówki kolumn
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

  // Połączenie z tabelą olist_products_dataset na podstawie kolumny "product_id"
  #"Merged Products Dataset" = Table.NestedJoin(
    #"Expanded Order Reviews Dataset", 
    {"product_id"}, 
    olist_products_dataset, 
    {"product_id"}, 
    "olist_products_dataset", 
    JoinKind.LeftOuter
  ), 

  // Rozwinięcie tabeli olist_products_dataset, aby uzyskać kolumnę "Product Id"
  #"Expanded Products Dataset" = Table.ExpandTableColumn(
    #"Merged Products Dataset", 
    "olist_products_dataset", 
    {"Product Id"}, 
    {"Product Id"}
  ), 

  // Usunięcie zbędnych kolumn, pozostawiając tylko "Product Id" i "review_score"
  #"Removed Other Columns" = Table.SelectColumns(
    #"Expanded Products Dataset", 
    {"Product Id", "review_score"}
  ), 

  // Grupowanie wierszy według "Product Id" i obliczanie średniej oceny dla każdego produktu
  #"Grouped Rows" = Table.Group(
    #"Removed Other Columns", 
    {"Product Id"}, 
    {{"Product Rating", each List.Average([review_score]), type nullable number}}
  )
in
  #"Grouped Rows"