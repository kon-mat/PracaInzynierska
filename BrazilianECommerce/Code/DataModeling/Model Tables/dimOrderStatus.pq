let
  // Wczytanie danych z pliku CSV
  Source = Csv.Document(
    File.Contents(
      "D:\Programowanie\PracaDyplomowa\BrazilianECommerce\Dataset\olist_orders_dataset.csv"
    ),
    [Delimiter = ",", Columns = 8, Encoding = 1250, QuoteStyle = QuoteStyle.None]
  ),

  // Ustawienie pierwszego wiersza na nagłówki kolumn
  #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),

  // Zmiana typów danych kolumn na odpowiednie
  #"Changed Type" = Table.TransformColumnTypes(
    #"Promoted Headers",
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

  // Zachowanie tylko kolumny z statusem zamówienia
  #"Removed Other Columns" = Table.SelectColumns(#"Changed Type", {"order_status"}),

  // Usunięcie zduplikowanych wierszy
  #"Removed Duplicates" = Table.Distinct(#"Removed Other Columns"),

  // Dodanie indeksu do każdego unikalnego statusu zamówienia
  #"Added Index" = Table.AddIndexColumn(#"Removed Duplicates", "Status Id", 1, 1, Int64.Type),

  // Zmiana nazwy kolumny z "order_status" na "Status"
  #"Renamed Columns" = Table.RenameColumns(#"Added Index", {{"order_status", "Status"}}),

  // Zmiana kolejności kolumn, aby "Status Id" była pierwsza
  #"Reordered Columns" = Table.ReorderColumns(#"Renamed Columns", {"Status Id", "Status"})
in
  #"Reordered Columns"
