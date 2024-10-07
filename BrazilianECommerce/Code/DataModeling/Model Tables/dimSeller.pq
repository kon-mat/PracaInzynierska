let
  // Wczytanie danych z pliku CSV
  Source = Csv.Document(
    File.Contents(
      "D:\Programowanie\PracaDyplomowa\BrazilianECommerce\Dataset\olist_sellers_dataset.csv"
    ),
    [Delimiter = ",", Columns = 4, Encoding = 65001, QuoteStyle = QuoteStyle.None]
  ),

  // Ustawienie pierwszego wiersza na nagłówki kolumn
  #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),

  // Zmiana typów danych kolumn na odpowiednie
  #"Changed Type" = Table.TransformColumnTypes(
    #"Promoted Headers",
    {
      {"seller_id", type text},
      {"seller_zip_code_prefix", Int64.Type},
      {"seller_city", type text},
      {"seller_state", type text}
    }
  ),

  // Zmiana nazw kolumn na bardziej zrozumiałe
  #"Renamed Columns" = Table.RenameColumns(
    #"Changed Type",
    {
      {"seller_zip_code_prefix", "Zip Code"},
      {"seller_city", "Seller City"},
      {"seller_state", "Seller State"}
    }
  ),

  // Dodanie indeksu do każdej pozycji sprzedawcy
  #"Added Index" = Table.AddIndexColumn(#"Renamed Columns", "Seller Id", 1, 1, Int64.Type),

  // Usunięcie kolumny "seller_id", ponieważ indeks "Seller Id" jest teraz używany
  #"Removed Columns" = Table.RemoveColumns(#"Added Index", {"seller_id"}),

  // Zmiana kolejności kolumn, aby "Seller Id" była pierwsza
  #"Reordered Columns" = Table.ReorderColumns(
    #"Removed Columns",
    {"Seller Id", "Zip Code", "Seller City", "Seller State"}
  )
in
  #"Reordered Columns"
