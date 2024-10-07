let
  // Wczytanie danych z pliku CSV do tabeli
  Source = Csv.Document(
    File.Contents(
      "D:\Programowanie\PracaDyplomowa\BrazilianECommerce\Dataset\olist_customers_dataset.csv"
    ), 
    [Delimiter = ",", Columns = 5, Encoding = 1250, QuoteStyle = QuoteStyle.None]
  ), 

  // Ustawienie pierwszego wiersza na nagłówki kolumn
  #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]), 

  // Zmiana typów danych kolumn na odpowiednie typy
  #"Changed Column Types" = Table.TransformColumnTypes(
    #"Promoted Headers", 
    {
      {"customer_id", type text}, 
      {"customer_unique_id", type text}, 
      {"customer_zip_code_prefix", Int64.Type}, 
      {"customer_city", type text}, 
      {"customer_state", type text}
    }
  ), 

  // Wybór tylko kolumny "customer_unique_id" do dalszej analizy
  #"Selected Unique Customer Id Column" = Table.SelectColumns(
    #"Changed Column Types", 
    {"customer_unique_id"}
  ), 

  // Usunięcie zduplikowanych wartości w kolumnie "customer_unique_id"
  #"Removed Duplicates" = Table.Distinct(
    #"Selected Unique Customer Id Column"
  ), 

  // Dodanie indeksu do każdego unikalnego identyfikatora klienta
  #"Added Index" = Table.AddIndexColumn(
    #"Removed Duplicates", 
    "Customer Unique Id", 
    1, 
    1, 
    Int64.Type
  )
in
  #"Added Index"