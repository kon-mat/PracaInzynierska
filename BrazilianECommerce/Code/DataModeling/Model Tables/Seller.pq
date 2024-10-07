let
  // Wczytanie danych z pliku CSV o nazwie "olist_sellers_dataset.csv"
  Source = Csv.Document(
    File.Contents(
      "D:\Programowanie\PracaInzynierska\BrazilianECommerce\Dataset\olist_sellers_dataset.csv"
    ), 
    [Delimiter = ",", Columns = 4, Encoding = 65001, QuoteStyle = QuoteStyle.None]
  ), 

  // Ustawienie pierwszego wiersza jako nagłówki kolumn
  #"Promote Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]), 

  // Zmiana typów danych kolumn na odpowiednie:
  // - Kolumny z identyfikatorami na tekst,
  // - Kolumny z kodem pocztowym na liczbę całkowitą
  #"Change Column Types" = Table.TransformColumnTypes(
    #"Promote Headers", 
    {
      {"seller_id", type text}, 
      {"seller_zip_code_prefix", Int64.Type}, 
      {"seller_city", type text}, 
      {"seller_state", type text}
    }
  ), 

  // Zmiana nazw kolumn na bardziej zrozumiałe
  #"Rename Columns" = Table.RenameColumns(
    #"Change Column Types", 
    {
      {"seller_zip_code_prefix", "Zip Code"}, 
      {"seller_city", "Seller City"}, 
      {"seller_state", "Seller State Abbr."}
    }
  ), 

  // Dodanie indeksu do każdej pozycji sprzedawcy, numerując je od 1
  #"Add Index To Sellers" = Table.AddIndexColumn(
    #"Rename Columns", 
    "Seller Id", 
    1, 
    1, 
    Int64.Type
  ), 

  // Usunięcie kolumny "seller_id", ponieważ indeks "Seller Id" jest teraz używany jako unikalny identyfikator
  #"Remove Seller Id Column" = Table.RemoveColumns(
    #"Add Index To Sellers", 
    {"seller_id"}
  ), 

  // Połączenie danych z tabelą stanów (dimState) na podstawie kolumny "Seller State Abbr."
  #"Merge With State Table" = Table.NestedJoin(
    #"Remove Seller Id Column", 
    {"Seller State Abbr."}, 
    State, 
    {"Abbreviation"}, 
    "State", 
    JoinKind.LeftOuter
  ), 

  // Rozwinięcie kolumny "State" w celu dodania pełnej nazwy stanu
  #"Expand State Table" = Table.ExpandTableColumn(
    #"Merge With State Table", 
    "State", 
    {"State"}, 
    {"State"}
  ), 

  // Zmiana nazwy kolumny "State" na "Seller State"
  #"Rename State Column" = Table.RenameColumns(
    #"Expand State Table", 
    {{"State", "Seller State"}}
  ), 

  // Zmiana kolejności kolumn, aby "Seller Id" była pierwsza
  #"Reorder Columns" = Table.ReorderColumns(
    #"Rename State Column", 
    {"Seller Id", "Zip Code", "Seller City", "Seller State Abbr."}
  ), 

  // Połączenie danych z tabelą ocen sprzedawców na podstawie kolumny "Seller Id"
  #"Merge With Seller Ratings" = Table.NestedJoin(
    #"Reorder Columns", 
    {"Seller Id"}, 
    #"olist_order_items_dataset (seller rating)", 
    {"Seller Id"}, 
    "olist_order_items_dataset (seller rating)", 
    JoinKind.LeftOuter
  ), 

  // Rozwinięcie tabeli ocen sprzedawców, aby uzyskać kolumnę "Seller Rating"
  #"Expand Seller Ratings" = Table.ExpandTableColumn(
    #"Merge With Seller Ratings", 
    "olist_order_items_dataset (seller rating)", 
    {"Seller Rating"}, 
    {"Seller Rating"}
  )
in
  #"Expand Seller Ratings"