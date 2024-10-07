let
  // Wczytanie danych z pliku CSV o nazwie "olist_orders_dataset.csv"
  Source = Csv.Document(
    File.Contents(
      "D:\Programowanie\PracaInzynierska\BrazilianECommerce\Dataset\olist_orders_dataset.csv"
    ), 
    [Delimiter = ",", Columns = 8, Encoding = 1250, QuoteStyle = QuoteStyle.None]
  ), 

  // Ustawienie pierwszego wiersza jako nagłówki kolumn
  #"Promote Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]), 

  // Rozdzielenie kolumn zawierających daty i godziny na dwie kolumny: datę i godzinę
  #"Split Column by Delimiter for Purchase Timestamp" = Table.SplitColumn(
    #"Promote Headers", 
    "order_purchase_timestamp", 
    Splitter.SplitTextByDelimiter(" ", QuoteStyle.None), 
    {"order_purchase_timestamp_Date", "order_purchase_timestamp_Time"}
  ), 

  // Rozdzielenie kolumn zawierających daty i godziny na dwie kolumny: datę i godzinę
  #"Split Column by Delimiter for Approval Date" = Table.SplitColumn(
    #"Split Column by Delimiter for Purchase Timestamp", 
    "order_approved_at", 
    Splitter.SplitTextByDelimiter(" ", QuoteStyle.None), 
    {"order_approved_at_Date", "order_approved_at_Time"}
  ), 

  // Rozdzielenie kolumn zawierających daty i godziny na dwie kolumny: datę i godzinę
  #"Split Column by Delimiter for Carrier Delivery Date" = Table.SplitColumn(
    #"Split Column by Delimiter for Approval Date", 
    "order_delivered_carrier_date", 
    Splitter.SplitTextByDelimiter(" ", QuoteStyle.None), 
    {"order_delivered_carrier_date_Date", "order_delivered_carrier_date_Time"}
  ), 

  // Rozdzielenie kolumn zawierających daty i godziny na dwie kolumny: datę i godzinę
  #"Split Column by Delimiter for Customer Delivery Date" = Table.SplitColumn(
    #"Split Column by Delimiter for Carrier Delivery Date", 
    "order_delivered_customer_date", 
    Splitter.SplitTextByDelimiter(" ", QuoteStyle.None), 
    {"order_delivered_customer_date_Date", "order_delivered_customer_date_Time"}
  ), 

  // Rozdzielenie kolumn zawierających daty i godziny na dwie kolumny: datę i godzinę
  #"Split Column by Delimiter for Estimated Delivery Date" = Table.SplitColumn(
    #"Split Column by Delimiter for Customer Delivery Date", 
    "order_estimated_delivery_date", 
    Splitter.SplitTextByDelimiter(" ", QuoteStyle.None), 
    {"order_estimated_delivery_date_Date", "order_estimated_delivery_date_Time"}
  ), 

  // Usunięcie kolumny z godziną szacowanej daty dostawy
  #"Remove Estimated Delivery Time Column" = Table.RemoveColumns(
    #"Split Column by Delimiter for Estimated Delivery Date", 
    {"order_estimated_delivery_date_Time"}
  ), 

  // Zmiana typów danych kolumn na odpowiednie:
  // - Kolumny z identyfikatorami na tekst,
  // - Kolumny z datami na typ daty
  #"Change Column Types" = Table.TransformColumnTypes(
    #"Remove Estimated Delivery Time Column", 
    {
      {"order_id", type text}, 
      {"customer_id", type text}, 
      {"order_status", type text}, 
      {"order_purchase_timestamp_Date", type date}, 
      {"order_approved_at_Date", type date}, 
      {"order_delivered_carrier_date_Date", type date}, 
      {"order_delivered_customer_date_Date", type date}, 
      {"order_estimated_delivery_date_Date", type date}, 
      {"order_purchase_timestamp_Time", type time}, 
      {"order_approved_at_Time", type time}, 
      {"order_delivered_carrier_date_Time", type time}, 
      {"order_delivered_customer_date_Time", type time}
    }
  ), 

  // Zmiana nazw kolumn na bardziej zrozumiałe
  #"Rename Columns" = Table.RenameColumns(
    #"Change Column Types", 
    {
      {"order_status", "Status"}, 
      {"order_purchase_timestamp_Date", "Purchase Date"}, 
      {"order_purchase_timestamp_Time", "Purchase Time"}, 
      {"order_approved_at_Date", "Approval Purchase Date"}, 
      {"order_approved_at_Time", "Approval Purchase Time"}, 
      {"order_delivered_carrier_date_Date", "Carrier Delivery Date"}, 
      {"order_delivered_carrier_date_Time", "Carrier Delivery Time"}, 
      {"order_delivered_customer_date_Date", "Customer Delivery Date"}, 
      {"order_delivered_customer_date_Time", "Customer Delivery Time"}, 
      {"order_estimated_delivery_date_Date", "Estimated Delivery Date"}
    }
  ), 

  // Dodanie indeksu do każdego zamówienia
  #"Add Index To Orders" = Table.AddIndexColumn(
    #"Rename Columns", 
    "Order Id", 
    1, 
    1, 
    Int64.Type
  ), 

  // Połączenie z tabelą olist_customers_dataset na podstawie kolumny "customer_id"
  #"Merge With Customers Table" = Table.NestedJoin(
    #"Add Index To Orders", 
    {"customer_id"}, 
    olist_customers_dataset, 
    {"customer_id"}, 
    "olist_customers_dataset", 
    JoinKind.LeftOuter
  ), 

  // Rozwinięcie tabeli olist_customers_dataset, aby uzyskać kolumnę "Customer Unique Id"
  #"Expand Customers Table" = Table.ExpandTableColumn(
    #"Merge With Customers Table", 
    "olist_customers_dataset", 
    {"Customer Unique Id"}, 
    {"Customer Unique Id"}
  ), 

  // Połączenie z tabelą dimOrderStatus na podstawie kolumny "Status"
  #"Merge With Order Status Table" = Table.NestedJoin(
    #"Expand Customers Table", 
    {"Status"}, 
    #"Order Status", 
    {"Status"}, 
    "Order Status", 
    JoinKind.LeftOuter
  ), 

  // Rozwinięcie tabeli dimOrderStatus, aby uzyskać kolumnę "Status Id"
  #"Expand Order Status Table" = Table.ExpandTableColumn(
    #"Merge With Order Status Table", 
    "Order Status", 
    {"Status Id"}, 
    {"Status Id"}
  ), 

  // Usunięcie kolumn niepotrzebnych do dalszej analizy
  #"Remove Unnecessary Columns" = Table.RemoveColumns(
    #"Expand Order Status Table", 
    {"order_id", "customer_id", "Status"}
  ), 

  // Zmiana kolejności kolumn, aby "Order Id" była pierwsza
  #"Reorder Columns" = Table.ReorderColumns(
    #"Remove Unnecessary Columns", 
    {
      "Order Id", 
      "Customer Unique Id", 
      "Status Id", 
      "Purchase Date", 
      "Purchase Time", 
      "Approval Purchase Date", 
      "Approval Purchase Time", 
      "Carrier Delivery Date", 
      "Carrier Delivery Time", 
      "Customer Delivery Date", 
      "Customer Delivery Time", 
      "Estimated Delivery Date"
    }
  )
in
  #"Reorder Columns"