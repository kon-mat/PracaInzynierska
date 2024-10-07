let
  // Wczytanie danych z pliku CSV o nazwie "olist_customers_dataset.csv"
  Source = Csv.Document(
    File.Contents(
      "D:\Programowanie\PracaDyplomowa\BrazilianECommerce\Dataset\olist_customers_dataset.csv"
    ), 
    [Delimiter = ",", Columns = 5, Encoding = 1250, QuoteStyle = QuoteStyle.None]
  ), 

  // Ustawienie pierwszego wiersza na nagłówki kolumn
  #"Promote Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]), 

  // Zmiana typów danych kolumn na odpowiednie:
  // - Kolumny z identyfikatorami na tekst,
  // - Kolumna z kodem pocztowym na liczbę całkowitą
  #"Change Column Types" = Table.TransformColumnTypes(
    #"Promote Headers", 
    {
      {"customer_id", type text}, 
      {"customer_unique_id", type text}, 
      {"customer_zip_code_prefix", Int64.Type}, 
      {"customer_city", type text}, 
      {"customer_state", type text}
    }
  ), 

  // Usunięcie duplikatów wierszy na podstawie kolumny "customer_unique_id"
  #"Remove Duplicates By Unique Id" = Table.Distinct(
    #"Change Column Types", 
    {"customer_unique_id"}
  ), 

  // Zmiana nazw kolumn na bardziej zrozumiałe
  #"Rename Columns" = Table.RenameColumns(
    #"Remove Duplicates By Unique Id", 
    {
      {"customer_zip_code_prefix", "Zip Code"}, 
      {"customer_city", "Customer City"}, 
      {"customer_state", "Customer State Abbr."}
    }
  ), 

  // Połączenie z tabelą "olist_customers_dataset" na podstawie kolumny "customer_id"
  #"Merge With Customers Dataset" = Table.NestedJoin(
    #"Rename Columns", 
    {"customer_id"}, 
    olist_customers_dataset, 
    {"customer_id"}, 
    "olist_customers_dataset", 
    JoinKind.LeftOuter
  ), 

  // Rozwinięcie tabeli "olist_customers_dataset", aby uzyskać kolumny "Customer Id" i "Customer Unique Id"
  #"Expand Customers Dataset" = Table.ExpandTableColumn(
    #"Merge With Customers Dataset", 
    "olist_customers_dataset", 
    {"Customer Id", "Customer Unique Id"}, 
    {"Customer Id", "Customer Unique Id"}
  ), 

  // Usunięcie kolumn, które nie są już potrzebne po połączeniu
  #"Remove Unnecessary Columns After Merge" = Table.RemoveColumns(
    #"Expand Customers Dataset", 
    {"customer_id", "customer_unique_id"}
  ), 

  // Zmiana kolejności kolumn, aby uzyskać pożądany układ
  #"Reorder Columns" = Table.ReorderColumns(
    #"Remove Unnecessary Columns After Merge", 
    {"Customer Unique Id", "Customer Id", "Zip Code", "Customer City", "Customer State Abbr."}
  ), 

  // Połączenie tabeli klientów z tabelą zamówień na podstawie kolumny "Customer Unique Id"
  #"Merge With Orders Dataset" = Table.NestedJoin(
    #"Reorder Columns", 
    {"Customer Unique Id"}, 
    #"olist_orders_dataset (transactions)", 
    {"Customer Unique Id"}, 
    "olist_orders_dataset (first_transaction)", 
    JoinKind.LeftOuter
  ), 

  // Rozwinięcie tabeli zamówień, aby uzyskać kolumny "First Transaction Date" i "Last Transaction Date"
  #"Expand Orders Dataset" = Table.ExpandTableColumn(
    #"Merge With Orders Dataset", 
    "olist_orders_dataset (first_transaction)", 
    {"First Transaction Date", "Last Transaction Date"}, 
    {"First Transaction Date", "Last Transaction Date"}
  )
in
  #"Expand Orders Dataset"