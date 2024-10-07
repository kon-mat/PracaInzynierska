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
  #"Changed Type" = Table.TransformColumnTypes(
    #"Promoted Headers",
    {
      {"order_id", type text},
      {"payment_sequential", Int64.Type},
      {"payment_type", type text},
      {"payment_installments", Int64.Type},
      {"payment_value", Currency.Type}
    }
  ),

  // Filtrowanie wierszy, aby usunąć te z pustymi lub null wartościami w kolumnie "order_id"
  #"Filtered Rows" = Table.SelectRows(#"Changed Type", each [order_id] <> null and [order_id] <> ""),

  // Zmiana nazw kolumn na bardziej opisowe
  #"Renamed Columns" = Table.RenameColumns(
    #"Filtered Rows",
    {
      {"payment_sequential", "Payment Sequential"},
      {"payment_type", "Brasil Payment Type"},
      {"payment_installments", "Payment Installment"},
      {"payment_value", "Payment Value"}
    }
  ),

  // Połączenie z tabelą olist_orders_dataset na podstawie kolumny "order_id"
  #"Merged Queries" = Table.NestedJoin(
    #"Renamed Columns",
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

  // Połączenie z tabelą dimPaymentType na podstawie kolumny "Brasil Payment Type"
  #"Merged Queries1" = Table.NestedJoin(
    #"Expanded olist_orders_dataset",
    {"Brasil Payment Type"},
    dimPaymentType,
    {"Brasil Payment Type"},
    "dimPaymentType",
    JoinKind.LeftOuter
  ),

  // Rozwinięcie tabeli dimPaymentType, aby uzyskać kolumnę "Payment Type Id"
  #"Expanded dimPaymentType" = Table.ExpandTableColumn(
    #"Merged Queries1",
    "dimPaymentType",
    {"Payment Type Id"},
    {"Payment Type Id"}
  ),

  // Usunięcie kolumn, które są już zintegrowane z innych tabel i są zbędne
  #"Removed Columns" = Table.RemoveColumns(
    #"Expanded dimPaymentType",
    {"order_id", "Brasil Payment Type"}
  ),

  // Zmiana kolejności kolumn dla lepszej organizacji i czytelności
  #"Reordered Columns" = Table.ReorderColumns(
    #"Removed Columns",
    {"Order Id", "Payment Type Id", "Payment Sequential", "Payment Installment", "Payment Value"}
  )
in
  #"Reordered Columns"
