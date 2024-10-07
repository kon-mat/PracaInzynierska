let
  // Wczytanie danych z pliku CSV
  Source = Csv.Document(
    File.Contents(
      "D:\Programowanie\PracaDyplomowa\BrazilianECommerce\Dataset\product_category_name_translation.csv"
    ),
    [Delimiter = ",", Columns = 2, Encoding = 65001, QuoteStyle = QuoteStyle.None]
  ),
  
  // Ustawienie pierwszego wiersza na nagłówki kolumn
  #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),

  // Zmiana typów danych kolumn na odpowiednie
  #"Changed Type" = Table.TransformColumnTypes(
    #"Promoted Headers",
    {{"product_category_name", type text}, {"product_category_name_english", type text}}
  ),
  
  // Zmiana nazw kolumn na bardziej zrozumiałe
  #"Renamed Columns" = Table.RenameColumns(
    #"Changed Type",
    {
      {"product_category_name", "Brasil Category Name"},
      {"product_category_name_english", "Category Name"}
    }
  ),
  
  // Dodanie indeksu do każdej kategorii
  #"Added Index" = Table.AddIndexColumn(#"Renamed Columns", "Category Id", 1, 1, Int64.Type),
  
  // Zmiana kolejności kolumn, aby "Category Id" była pierwsza
  #"Reordered Columns" = Table.ReorderColumns(
    #"Added Index",
    {"Category Id", "Brasil Category Name", "Category Name"}
  )
in
  #"Reordered Columns"
