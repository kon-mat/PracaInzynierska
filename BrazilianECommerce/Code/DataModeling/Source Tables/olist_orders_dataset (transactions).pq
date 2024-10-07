let
  // Wczytanie danych z pliku CSV do tabeli
  Source = Csv.Document(
    File.Contents(
      "D:\Programowanie\PracaInzynierska\BrazilianECommerce\Dataset\olist_orders_dataset.csv"
    ), 
    [Delimiter = ",", Columns = 8, Encoding = 1250, QuoteStyle = QuoteStyle.None]
  ), 

  // Ustawienie pierwszego wiersza na nagłówki kolumn
  #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]), 

  // Zmiana typów danych kolumn na odpowiednie typy
  #"Changed Column Types" = Table.TransformColumnTypes(
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

  // Zmiana nazw kolumn na bardziej opisowe
  #"Renamed Columns" = Table.RenameColumns(
    #"Changed Column Types", 
    {
      {"order_status", "Status"}, 
      {"order_purchase_timestamp", "Purchase Timestamp"}, 
      {"order_approved_at", "Approval Purchase Timestamp"}, 
      {"order_delivered_carrier_date", "Carrier Delivery Date"}, 
      {"order_delivered_customer_date", "Customer Delivery Date"}, 
      {"order_estimated_delivery_date", "Estimated Delivery Date"}
    }
  ), 

  // Dodanie indeksu do każdego rekordu
  #"Added Index" = Table.AddIndexColumn(
    #"Renamed Columns", 
    "Order Id", 
    1, 
    1, 
    Int64.Type
  ), 

  // Połączenie z tabelą olist_customers_dataset na podstawie kolumny "customer_id"
  #"Merged Queries" = Table.NestedJoin(
    #"Added Index", 
    {"customer_id"}, 
    olist_customers_dataset, 
    {"customer_id"}, 
    "olist_customers_dataset", 
    JoinKind.LeftOuter
  ), 

  // Rozwinięcie tabeli olist_customers_dataset, aby uzyskać kolumnę "Customer Unique Id"
  #"Expanded olist_customers_dataset" = Table.ExpandTableColumn(
    #"Merged Queries", 
    "olist_customers_dataset", 
    {"Customer Unique Id"}, 
    {"Customer Unique Id"}
  ), 

  // Wybór tylko potrzebnych kolumn
  #"Removed Other Columns" = Table.SelectColumns(
    #"Expanded olist_customers_dataset", 
    {"Customer Unique Id", "Purchase Timestamp"}
  ), 

  // Grupowanie według "Customer Unique Id" i obliczanie dat pierwszej i ostatniej transakcji
  #"Grouped Rows" = Table.Group(
    #"Removed Other Columns", 
    {"Customer Unique Id"}, 
    {
      {"First Transaction Date", each List.Min([Purchase Timestamp]), type nullable datetime}, 
      {"Last Transaction Date", each List.Max([Purchase Timestamp]), type nullable datetime}
    }
  ), 

  // Przekształcenie dat na początek miesiąca
  #"Calculated Start of Month" = Table.TransformColumns(
    #"Grouped Rows", 
    {
      {"First Transaction Date", Date.StartOfMonth, type datetime}, 
      {"Last Transaction Date", Date.StartOfMonth, type datetime}
    }
  ), 

  // Zmiana typów danych na daty
  #"Changed Column Types1" = Table.TransformColumnTypes(
    #"Calculated Start of Month", 
    {
      {"First Transaction Date", type date}, 
      {"Last Transaction Date", type date}
    }
  )
in
  #"Changed Column Types1"