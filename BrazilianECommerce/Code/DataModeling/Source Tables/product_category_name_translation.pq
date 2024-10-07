let
  // Wczytanie danych z pliku CSV do tabeli
  Source = Csv.Document(
    File.Contents(
      "D:\Programowanie\PracaDyplomowa\BrazilianECommerce\Dataset\product_category_name_translation.csv"
    ), 
    [Delimiter = ",", Columns = 2, Encoding = 65001, QuoteStyle = QuoteStyle.None]
  ), 

  // Ustawienie pierwszego wiersza na nagłówki kolumn
  #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]), 

  // Zmiana typów danych kolumn na odpowiednie typy
  #"Changed Column Types" = Table.TransformColumnTypes(
    #"Promoted Headers", 
    {
      {"product_category_name", type text}, 
      {"product_category_name_english", type text}
    }
  ), 

  // Zmiana nazw kolumn na bardziej zrozumiałe
  #"Renamed Columns" = Table.RenameColumns(
    #"Changed Column Types", 
    {
      {"product_category_name", "Brasil Category Name"}, 
      {"product_category_name_english", "Category Name"}
    }
  ), 

  // Dodanie indeksu do każdej kategorii
  #"Added Index" = Table.AddIndexColumn(
    #"Renamed Columns", 
    "Category Id", 
    1, 
    1, 
    Int64.Type
  )
in
  #"Added Index"