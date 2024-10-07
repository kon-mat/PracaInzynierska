let
  // Wczytanie danych z pliku CSV o nazwie "product_category_name_translation.csv"
  Source = Csv.Document(
    File.Contents("D:\Programowanie\PracaDyplomowa\BrazilianECommerce\Dataset\product_category_name_translation.csv"), 
    [Delimiter = ",", Columns = 2, Encoding = 65001, QuoteStyle = QuoteStyle.None]
  ),

  // Promowanie pierwszego wiersza na nagłówki kolumn
  #"Promote Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),

  // Zmiana typów danych kolumn na odpowiednie: 
  // "product_category_name" i "product_category_name_english" na typ tekstowy
  #"Change Column Types" = Table.TransformColumnTypes(
    #"Promote Headers", 
    {{"product_category_name", type text}, {"product_category_name_english", type text}}
  ),

  // Zmiana nazw kolumn na bardziej czytelne: 
  // "product_category_name" → "Brasil Category Name", "product_category_name_english" → "Category Name"
  #"Rename Columns" = Table.RenameColumns(
    #"Change Column Types", 
    {
      {"product_category_name", "Brasil Category Name"}, 
      {"product_category_name_english", "Category Name"}
    }
  ),

  // Dodanie indeksu do każdej kategorii, zaczynając od 1, pod nazwą "Category Id"
  #"Add Category Index" = Table.AddIndexColumn(#"Rename Columns", "Category Id", 1, 1, Int64.Type),

  // Zmiana kolejności kolumn, aby "Category Id" była pierwsza
  #"Reorder Columns" = Table.ReorderColumns(
    #"Add Category Index", 
    {"Category Id", "Brasil Category Name", "Category Name"}
  ),

  // Zamiana podkreśleń (_) na spacje w kolumnie "Category Name"
  #"Replace Underscores With Spaces" = Table.ReplaceValue(
    #"Reorder Columns", 
    "_", 
    " ", 
    Replacer.ReplaceText, 
    {"Category Name"}
  ),

  // Zamiana pierwszej litery każdego słowa w kolumnie "Category Name" na wielką literę
  #"Capitalize Each Word In Category Name" = Table.TransformColumns(
    #"Replace Underscores With Spaces", 
    {{"Category Name", Text.Proper, type text}}
  ),

  // Zamiana "Cds" na "CDs" w kolumnie "Category Name"
  #"Replace CDs" = Table.ReplaceValue(
    #"Capitalize Each Word In Category Name", 
    "Cds", 
    "CDs", 
    Replacer.ReplaceText, 
    {"Category Name"}
  ),

  // Zamiana "Dvds" na "DVDs" w kolumnie "Category Name"
  #"Replace DVDs" = Table.ReplaceValue(
    #"Replace CDs", 
    "Dvds", 
    "DVDs", 
    Replacer.ReplaceText, 
    {"Category Name"}
  ),

  // Zamiana "Pc Gamer" na "PC Gamer" w kolumnie "Category Name"
  #"Replace PC Gamer" = Table.ReplaceValue(
    #"Replace DVDs", 
    "Pc Gamer", 
    "PC Gamer", 
    Replacer.ReplaceText, 
    {"Category Name"}
  )
in
  #"Replace PC Gamer"