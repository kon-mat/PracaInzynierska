let
  // Wczytanie danych z pliku CSV do tabeli
  Source = Csv.Document(
    File.Contents(
      "D:\Programowanie\PracaDyplomowa\BrazilianECommerce\Dataset\olist_geolocation_dataset.csv"
    ), 
    [Delimiter = ",", Columns = 5, Encoding = 65001, QuoteStyle = QuoteStyle.None]
  ), 

  // Ustawienie pierwszego wiersza na nagłówki kolumn
  #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]), 

  // Zmiana typów danych kolumn na odpowiednie typy
  #"Changed Column Types" = Table.TransformColumnTypes(
    #"Promoted Headers", 
    {
      {"geolocation_zip_code_prefix", Int64.Type}, 
      {"geolocation_lat", type number}, 
      {"geolocation_lng", type number}, 
      {"geolocation_city", type text}, 
      {"geolocation_state", type text}
    }
  ), 

  // Usunięcie zduplikowanych wierszy
  #"Removed Duplicates" = Table.Distinct(#"Changed Column Types")
in
  #"Removed Duplicates"