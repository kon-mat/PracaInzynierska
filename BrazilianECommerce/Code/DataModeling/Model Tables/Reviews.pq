let
  // Wczytanie danych z pliku CSV do tabeli
  Source = Csv.Document(
    File.Contents(
      "D:\Programowanie\PracaInzynierska\BrazilianECommerce\Dataset\reviews_translated.csv"
    ), 
    [Delimiter = ",", Columns = 8, Encoding = 65001, QuoteStyle = QuoteStyle.Csv]
  ), 

  // Ustawienie pierwszego wiersza na nagłówki kolumn
  #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]), 

  // Podzielenie kolumn na datę i czas
  #"Split Review Creation Date Column" = Table.SplitColumn(
    #"Promoted Headers", 
    "review_creation_date", 
    Splitter.SplitTextByDelimiter(" ", QuoteStyle.None), 
    {"review_creation_date.1", "review_creation_date.2"}
  ), 
  #"Split Review Answer Timestamp Column" = Table.SplitColumn(
    #"Split Review Creation Date Column", 
    "review_answer_timestamp", 
    Splitter.SplitTextByDelimiter(" ", QuoteStyle.None), 
    {"review_answer_timestamp.1", "review_answer_timestamp.2"}
  ), 

  // Usunięcie pustych kolumn i kolumny z niepotrzebnymi danymi
  #"Removed Unnecessary Columns" = Table.RemoveColumns(
    #"Split Review Answer Timestamp Column", 
    {"", "review_creation_date.2"}
  ), 

  // Zmiana typów danych kolumn na odpowiednie
  #"Changed Column Types" = Table.TransformColumnTypes(
    #"Removed Unnecessary Columns", 
    {
      {"review_id", type text}, 
      {"order_id", type text}, 
      {"review_score", Int64.Type}, 
      {"review_comment_title", type text}, 
      {"review_comment_message", type text}, 
      {"review_creation_date.1", type date}, 
      {"review_answer_timestamp.1", type date}, 
      {"review_answer_timestamp.2", type time}
    }
  ), 

  // Zmiana nazw kolumn na bardziej zrozumiałe
  #"Renamed Columns" = Table.RenameColumns(
    #"Changed Column Types", 
    {
      {"review_score", "Score"}, 
      {"review_comment_title", "Title"}, 
      {"review_comment_message", "Comment"}, 
      {"review_creation_date.1", "Creation Date"}, 
      {"review_answer_timestamp.1", "Answer Date"}, 
      {"review_answer_timestamp.2", "Answer Time"}
    }
  ), 

  // Usunięcie zduplikowanych wierszy, aby zachować unikalne rekordy
  #"Removed Duplicates" = Table.Distinct(#"Renamed Columns"), 

  // Połączenie z tabelą 'olist_orders_dataset' na podstawie kolumny 'order_id'
  #"Merged With Orders Dataset" = Table.NestedJoin(
    #"Removed Duplicates", 
    {"order_id"}, 
    olist_orders_dataset, 
    {"order_id"}, 
    "olist_orders_dataset", 
    JoinKind.LeftOuter
  ), 

  // Rozwinięcie tabeli 'olist_orders_dataset', aby uzyskać kolumnę 'Order Id'
  #"Expanded Orders Dataset" = Table.ExpandTableColumn(
    #"Merged With Orders Dataset", 
    "olist_orders_dataset", 
    {"Order Id"}, 
    {"Order Id"}
  ), 

  // Usunięcie kolumn, które są już zintegrowane z innych tabel i są zbędne
  #"Removed Unnecessary Columns1" = Table.RemoveColumns(
    #"Expanded Orders Dataset", 
    {"review_id", "order_id"}
  ), 

  // Zmiana kolejności kolumn dla lepszej organizacji i czytelności
  #"Reordered Columns" = Table.ReorderColumns(
    #"Removed Unnecessary Columns1", 
    {
      "Order Id", 
      "Score", 
      "Title", 
      "Comment", 
      "Creation Date", 
      "Answer Date", 
      "Answer Time"
    }
  )
in
  #"Reordered Columns"