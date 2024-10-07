let
  // Wczytanie danych z pliku CSV do tabeli
  Source = Csv.Document(
    File.Contents(
      "D:\Programowanie\PracaDyplomowa\BrazilianECommerce\Dataset\olist_order_payments_dataset.csv"
    ), 
    [Delimiter = ",", Columns = 5, Encoding = 1250, QuoteStyle = QuoteStyle.None]
  ), 

  // Ustawienie pierwszego wiersza na nagłówki kolumn
  #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]), 

  // Zmiana typów danych kolumn na odpowiednie typy
  #"Changed Column Types" = Table.TransformColumnTypes(
    #"Promoted Headers", 
    {
      {"order_id", type text}, 
      {"payment_sequential", Int64.Type}, 
      {"payment_type", type text}, 
      {"payment_installments", Int64.Type}, 
      {"payment_value", Currency.Type}
    }
  ), 

  // Filtrowanie wierszy - obecnie nie filtrujemy żadnych danych, więc krok ten jest zbędny
  #"Filtered Rows" = Table.SelectRows(#"Changed Column Types", each true), 

  // Zmiana nazw kolumn na bardziej zrozumiałe
  #"Renamed Columns" = Table.RenameColumns(
    #"Filtered Rows", 
    {
      {"payment_sequential", "Payment Sequential"}, 
      {"payment_type", "Brasil Payment Type"}, 
      {"payment_installments", "Payment Installment"}, 
      {"payment_value", "Payment Value"}
    }
  )
in
  #"Renamed Columns"