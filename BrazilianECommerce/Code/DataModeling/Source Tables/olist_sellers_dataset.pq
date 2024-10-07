let
  // Wczytanie danych z pliku CSV do tabeli
  Source = Csv.Document(
    File.Contents(
      "D:\Programowanie\PracaDyplomowa\BrazilianECommerce\Dataset\olist_sellers_dataset.csv"
    ), 
    [Delimiter = ",", Columns = 4, Encoding = 65001, QuoteStyle = QuoteStyle.None]
  ), 

  // Ustawienie pierwszego wiersza na nagłówki kolumn
  #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]), 

  // Zmiana typów danych kolumn na odpowiednie typy
  #"Changed Column Types" = Table.TransformColumnTypes(
    #"Promoted Headers", 
    {
      {"seller_id", type text}, 
      {"seller_zip_code_prefix", Int64.Type}, 
      {"seller_city", type text}, 
      {"seller_state", type text}
    }
  ), 

  // Zmiana nazw kolumn na bardziej opisowe
  #"Renamed Columns" = Table.RenameColumns(
    #"Changed Column Types", 
    {
      {"seller_zip_code_prefix", "Zip Code"}, 
      {"seller_city", "Seller City"}, 
      {"seller_state", "Seller State"}
    }
  ), 

  // Dodanie indeksu do każdego rekordu
  #"Added Index" = Table.AddIndexColumn(
    #"Renamed Columns", 
    "Seller Id", 
    1, 
    1, 
    Int64.Type
  )
in
  #"Added Index"