let
  // Wczytanie danych z pliku CSV o nazwie "olist_orders_dataset.csv"
  Source = Csv.Document(
    File.Contents("D:\Programowanie\PracaInzynierska\BrazilianECommerce\Dataset\olist_orders_dataset.csv"),
    [Delimiter = ",", Columns = 8, Encoding = 1250, QuoteStyle = QuoteStyle.None]
  ),

  // Promowanie pierwszego wiersza na nagłówki kolumn
  #"Promote Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),

  // Konwersja typów danych kolumn na odpowiednie:
  // - Kolumny tekstowe dla "order_id", "customer_id", "order_status"
  // - Typ daty/godziny dla pozostałych kolumn
  #"Change Column Types" = Table.TransformColumnTypes(
    #"Promote Headers",
    {
      {"order_id", type text},
      {"customer_id", type text},
      {"order_status", type text},
      {"order_purchase_timestamp", type datetime},
      {"order_approved_at", type datetime},
      {"order_delivered_carrier_date", type datetime},
      {"order_delivered_customer_date", type datetime},
      {"order_estimated_delivery_date", type datetime}
    }
  ),

  // Zachowanie tylko kolumny "order_status" (filtracja zbędnych danych)
  #"Keep Order Status Column" = Table.SelectColumns(#"Change Column Types", {"order_status"}),

  // Usunięcie zduplikowanych wierszy
  #"Remove Duplicates" = Table.Distinct(#"Keep Order Status Column"),

  // Dodanie indeksu do każdego unikalnego statusu zamówienia
  #"Add Status Index" = Table.AddIndexColumn(#"Remove Duplicates", "Status Id", 1, 1, Int64.Type),

  // Zmiana nazwy kolumny z "order_status" na "Status"
  #"Rename Order Status Column" = Table.RenameColumns(#"Add Status Index", {{"order_status", "Status"}}),

  // Zmiana kolejności kolumn, aby "Status Id" była pierwsza
  #"Reorder Columns" = Table.ReorderColumns(#"Rename Order Status Column", {"Status Id", "Status"})
in
  #"Reorder Columns"