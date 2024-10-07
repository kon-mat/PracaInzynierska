let
  // Wczytanie danych z pliku CSV do tabeli
  Source = Csv.Document(
    File.Contents(
      "D:\Programowanie\PracaDyplomowa\BrazilianECommerce\Dataset\reviews_translated.csv"
    ),
    [Delimiter = ",", Columns = 8, Encoding = 65001, QuoteStyle = QuoteStyle.Csv]
  ),

  // Ustawienie pierwszego wiersza na nagłówki kolumn
  #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),

  // Zmiana typów danych kolumn na odpowiednie typy
  #"Changed Type" = Table.TransformColumnTypes(
    #"Promoted Headers",
    {
      {"", Int64.Type},  // Pusta kolumna, zazwyczaj to numer wiersza lub inny niepotrzebny identyfikator
      {"review_id", type text},
      {"order_id", type text},
      {"review_score", Int64.Type},
      {"review_comment_title", type text},
      {"review_comment_message", type text},
      {"review_creation_date", type datetime},
      {"review_answer_timestamp", type datetime}
    }
  ),

  // Usunięcie pustej kolumny, która nie jest potrzebna
  #"Removed Columns" = Table.RemoveColumns(#"Changed Type", {""}),

  // Zmiana nazw kolumn na bardziej zrozumiałe
  #"Renamed Columns" = Table.RenameColumns(
    #"Removed Columns",
    {
      {"review_score", "Score"},
      {"review_comment_title", "Title"},
      {"review_comment_message", "Comment"},
      {"review_creation_date", "Creation Date"},
      {"review_answer_timestamp", "Answer Timestamp"}
    }
  ),

  // Usunięcie zduplikowanych wierszy, aby zachować unikalne rekordy
  #"Removed Duplicates" = Table.Distinct(#"Renamed Columns"),

  // Połączenie z tabelą olist_orders_dataset na podstawie kolumny "order_id"
  #"Merged Queries" = Table.NestedJoin(
    #"Removed Duplicates",
    {"order_id"},
    olist_orders_dataset,
    {"order_id"},
    "olist_orders_dataset",
    JoinKind.LeftOuter
  ),

  // Rozwinięcie tabeli olist_orders_dataset, aby uzyskać kolumnę "Order Id"
  #"Expanded olist_orders_dataset" = Table.ExpandTableColumn(
    #"Merged Queries",
    "olist_orders_dataset",
    {"Order Id"},
    {"Order Id"}
  ),

  // Usunięcie kolumn, które są już zintegrowane z innych tabel i są zbędne
  #"Removed Columns1" = Table.RemoveColumns(
    #"Expanded olist_orders_dataset",
    {"review_id", "order_id"}
  ),

  // Zmiana kolejności kolumn dla lepszej organizacji i czytelności
  #"Reordered Columns" = Table.ReorderColumns(
    #"Removed Columns1",
    {"Order Id", "Score", "Title", "Comment", "Creation Date", "Answer Timestamp"}
  )
in
  #"Reordered Columns"
