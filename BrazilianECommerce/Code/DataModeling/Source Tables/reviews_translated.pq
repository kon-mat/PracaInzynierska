let
  // Wczytanie danych z pliku CSV do tabeli
  Source = Csv.Document(
    File.Contents(
      "D:\Programowanie\PracaDyplomowa\BrazilianECommerce\Dataset\reviews_translated.csv"
    ), 
    [Delimiter = ",", Columns = 8, Encoding = 65001, QuoteStyle = QuoteStyle.Csv]
  ), 

  // Ustawienie pierwszego wiersza jako nagłówków kolumn
  #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]), 

  // Zmiana typów danych kolumn na odpowiednie typy
  #"Changed Column Types" = Table.TransformColumnTypes(
    #"Promoted Headers", 
    {
      {"", Int64.Type}, 
      {"review_id", type text}, 
      {"order_id", type text}, 
      {"review_score", Int64.Type}, 
      {"review_comment_title", type text}, 
      {"review_comment_message", type text}, 
      {"review_creation_date", type datetime}, 
      {"review_answer_timestamp", type datetime}
    }
  ), 

  // Zmiana nazw kolumn na bardziej czytelne
  #"Renamed Columns" = Table.RenameColumns(
    #"Changed Column Types", 
    {
      {"", "Review Id"}, 
      {"review_score", "Score"}, 
      {"review_comment_title", "Title"}, 
      {"review_comment_message", "Comment"}, 
      {"review_creation_date", "Creation Date"}, 
      {"review_answer_timestamp", "Answer Timestamp"}
    }
  ), 

  // Usunięcie duplikatów
  #"Removed Duplicates" = Table.Distinct(#"Renamed Columns")
in
  #"Removed Duplicates"