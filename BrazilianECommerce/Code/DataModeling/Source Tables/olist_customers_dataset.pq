let
  // Wczytanie danych z pliku CSV do tabeli
  Source = Csv.Document(
    File.Contents(
      "D:\Programowanie\PracaDyplomowa\BrazilianECommerce\Dataset\olist_customers_dataset.csv"
    ), 
    [Delimiter = ",", Columns = 5, Encoding = 1250, QuoteStyle = QuoteStyle.None]
  ), 

  // Ustawienie pierwszego wiersza na nagłówki kolumn
  #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]), 

  // Zmiana typów danych kolumn na odpowiednie typy
  #"Changed Column Types" = Table.TransformColumnTypes(
    #"Promoted Headers", 
    {
      {"customer_id", type text}, 
      {"customer_unique_id", type text}, 
      {"customer_zip_code_prefix", Int64.Type}, 
      {"customer_city", type text}, 
      {"customer_state", type text}
    }
  ), 

  // Zmiana nazw kolumn na bardziej opisowe
  #"Renamed Columns" = Table.RenameColumns(
    #"Changed Column Types", 
    {
      {"customer_zip_code_prefix", "Zip Code"}, 
      {"customer_city", "Customer City"}, 
      {"customer_state", "Customer State"}
    }
  ), 

  // Dodanie indeksu do każdego rekordu
  #"Added Index" = Table.AddIndexColumn(
    #"Renamed Columns", 
    "Customer Id", 
    1, 
    1, 
    Int64.Type
  ), 

  // Połączenie z tabelą na podstawie kolumny "customer_unique_id"
  #"Merged Queries" = Table.NestedJoin(
    #"Added Index", 
    {"customer_unique_id"}, 
    #"olist_customers_dataset (unique_id)", 
    {"customer_unique_id"}, 
    "olist_customers_dataset (unique_id)", 
    JoinKind.LeftOuter
  ), 

  // Rozwinięcie tabeli połączonej, aby uzyskać kolumnę "Customer Unique Id"
  #"Expanded olist_customers_dataset (unique_id)" = Table.ExpandTableColumn(
    #"Merged Queries", 
    "olist_customers_dataset (unique_id)", 
    {"Customer Unique Id"}, 
    {"Customer Unique Id"}
  )
in
  #"Expanded olist_customers_dataset (unique_id)"