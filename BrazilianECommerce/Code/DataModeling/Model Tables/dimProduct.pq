let
  // Wczytanie danych z pliku CSV
  Source = Csv.Document(
    File.Contents(
      "D:\Programowanie\PracaDyplomowa\BrazilianECommerce\Dataset\olist_products_dataset.csv"
    ),
    [Delimiter = ",", Columns = 9, Encoding = 1250, QuoteStyle = QuoteStyle.None]
  ),

  // Ustawienie pierwszego wiersza na nagłówki kolumn
  #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),

  // Zmiana typów danych kolumn na odpowiednie
  #"Changed Type" = Table.TransformColumnTypes(
    #"Promoted Headers",
    {
      {"product_id", type text},
      {"product_category_name", type text},
      {"product_name_lenght", Int64.Type},
      {"product_description_lenght", Int64.Type},
      {"product_photos_qty", Int64.Type},
      {"product_weight_g", Int64.Type},
      {"product_length_cm", Int64.Type},
      {"product_height_cm", Int64.Type},
      {"product_width_cm", Int64.Type}
    }
  ),

  // Usunięcie kolumn, które nie są potrzebne do dalszej analizy
  #"Removed Columns" = Table.RemoveColumns(
    #"Changed Type",
    {"product_name_lenght", "product_description_lenght"}
  ),

  // Zmiana nazw kolumn na bardziej zrozumiałe
  #"Renamed Columns" = Table.RenameColumns(
    #"Removed Columns",
    {
      {"product_photos_qty", "Photos Quantity"},
      {"product_weight_g", "Weight (g)"},
      {"product_length_cm", "Length (cm)"},
      {"product_height_cm", "Height (cm)"},
      {"product_width_cm", "Width (cm)"}
    }
  ),

  // Dodanie indeksu do każdej pozycji produktu
  #"Added Index" = Table.AddIndexColumn(#"Renamed Columns", "Product Id", 1, 1, Int64.Type),

  // Połączenie tabeli z wymiarami kategorii na podstawie nazwy kategorii produktu
  #"Merged Queries" = Table.NestedJoin(
    #"Added Index",
    {"product_category_name"},
    dimCategory,
    {"Brasil Category Name"},
    "dimCategory",
    JoinKind.LeftOuter
  ),

  // Rozwinięcie tabeli kategorii, aby uzyskać identyfikator kategorii
  #"Expanded dimCategory" = Table.ExpandTableColumn(
    #"Merged Queries",
    "dimCategory",
    {"Category Id"},
    {"Category Id"}
  ),

  // Usunięcie kolumn, które nie są już potrzebne po dołączeniu tabeli kategorii
  #"Removed Columns1" = Table.RemoveColumns(
    #"Expanded dimCategory",
    {"product_id", "product_category_name"}
  ),

  // Zmiana kolejności kolumn w tabeli, aby uzyskać pożądany układ
  #"Reordered Columns" = Table.ReorderColumns(
    #"Removed Columns1",
    {
      "Product Id",
      "Category Id",
      "Photos Quantity",
      "Weight (g)",
      "Length (cm)",
      "Height (cm)",
      "Width (cm)"
    }
  )
in
  #"Reordered Columns"
