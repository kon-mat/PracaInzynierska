let
  // Wczytanie danych z pliku CSV
  Source = Csv.Document(
    File.Contents(
      "D:\Programowanie\PracaDyplomowa\BrazilianECommerce\Dataset\olist_customers_dataset.csv"
    ),
    [Delimiter = ",", Columns = 5, Encoding = 1250, QuoteStyle = QuoteStyle.None]
  ),

  // Ustawienie pierwszego wiersza na nagłówki kolumn
  #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),

  // Zmiana typów danych kolumn na odpowiednie
  #"Changed Type" = Table.TransformColumnTypes(
    #"Promoted Headers",
    {
      {"customer_id", type text},
      {"customer_unique_id", type text},
      {"customer_zip_code_prefix", Int64.Type},
      {"customer_city", type text},
      {"customer_state", type text}
    }
  ),

  // Zmiana nazw kolumn na bardziej zrozumiałe
  #"Renamed Columns" = Table.RenameColumns(
    #"Changed Type",
    {
      {"customer_zip_code_prefix", "Zip Code"},
      {"customer_city", "Customer City"},
      {"customer_state", "Customer State"}
    }
  ),

  // Dodanie indeksu do każdej pozycji klienta
  #"Added Index" = Table.AddIndexColumn(#"Renamed Columns", "Customer Id", 1, 1, Int64.Type),

  // Połączenie tabeli klientów z dodatkową tabelą na podstawie "customer_unique_id"
  #"Merged Queries" = Table.NestedJoin(
    #"Added Index",
    {"customer_unique_id"},
    #"olist_customers_dataset (unique_id)",
    {"customer_unique_id"},
    "olist_customers_dataset (unique_id)",
    JoinKind.LeftOuter
  ),

  // Rozwinięcie tabeli połączonej, aby uzyskać dodatkowy identyfikator unikalnego klienta
  #"Expanded olist_customers_dataset (unique_id)" = Table.ExpandTableColumn(
    #"Merged Queries",
    "olist_customers_dataset (unique_id)",
    {"Customer Unique Id"},
    {"Customer Unique Id"}
  ),

  // Usunięcie kolumn, które nie są już potrzebne po połączeniu
  #"Removed Columns" = Table.RemoveColumns(
    #"Expanded olist_customers_dataset (unique_id)",
    {"customer_id", "customer_unique_id"}
  ),

  // Zmiana kolejności kolumn, aby uzyskać pożądany układ
  #"Reordered Columns" = Table.ReorderColumns(
    #"Removed Columns",
    {"Customer Id", "Customer Unique Id", "Zip Code", "Customer City", "Customer State"}
  )
in
  #"Reordered Columns"
