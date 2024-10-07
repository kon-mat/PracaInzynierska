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

  // Zmiana nazw kolumn na bardziej zrozumiałe
  #"Renamed Columns" = Table.RenameColumns(
    #"Changed Type",
    {
      {"order_status", "Status"},
      {"order_purchase_timestamp", "Purchase Timestamp"},
      {"order_approved_at", "Approval Purchase Timestamp"},
      {"order_delivered_carrier_date", "Carrier Delivery Date"},
      {"order_delivered_customer_date", "Customer Delivery Date"},
      {"order_estimated_delivery_date", "Estimated Delivery Date"}
    }
  ),

  // Dodanie indeksu do każdego zamówienia
  #"Added Index" = Table.AddIndexColumn(#"Renamed Columns", "Order Id", 1, 1, Int64.Type),

  // Połączenie z tabelą olist_customers_dataset na podstawie kolumny "customer_id"
  #"Merged Queries" = Table.NestedJoin(
    #"Added Index",
    {"customer_id"},
    olist_customers_dataset,
    {"customer_id"},
    "olist_customers_dataset",
    JoinKind.LeftOuter
  ),

  // Rozwinięcie tabeli olist_customers_dataset, aby uzyskać kolumnę "Customer Id"
  #"Expanded olist_customers_dataset" = Table.ExpandTableColumn(
    #"Merged Queries",
    "olist_customers_dataset",
    {"Customer Id"},
    {"Customer Id"}
  ),

  // Połączenie z tabelą dimOrderStatus na podstawie kolumny "Status"
  #"Merged Queries1" = Table.NestedJoin(
    #"Expanded olist_customers_dataset",
    {"Status"},
    dimOrderStatus,
    {"Status"},
    "dimOrderStatus",
    JoinKind.LeftOuter
  ),

  // Rozwinięcie tabeli dimOrderStatus, aby uzyskać kolumnę "Status Id"
  #"Expanded dimOrderStatus" = Table.ExpandTableColumn(
    #"Merged Queries1",
    "dimOrderStatus",
    {"Status Id"},
    {"Status Id"}
  ),

  // Usunięcie kolumn niepotrzebnych do dalszej analizy
  #"Removed Columns" = Table.RemoveColumns(
    #"Expanded dimOrderStatus",
    {"order_id", "customer_id", "Status"}
  ),

  // Zmiana kolejności kolumn, aby "Order Id" była pierwsza
  #"Reordered Columns" = Table.ReorderColumns(
    #"Removed Columns",
    {
      "Order Id",
      "Customer Id",
      "Status Id",
      "Purchase Timestamp",
      "Approval Purchase Timestamp",
      "Carrier Delivery Date",
      "Customer Delivery Date",
      "Estimated Delivery Date"
    }
  ),

  // Dodanie kolumny z datą zakupu wyodrębnioną z "Purchase Timestamp"
  #"Inserted Purchase Date" = Table.AddColumn(
    #"Reordered Columns",
    "Purchase Date",
    each Date.From([Purchase Timestamp]),
    type date
  )
in
  #"Inserted Purchase Date"
