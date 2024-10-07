let
  Source = Csv.Document(
    File.Contents(
      "D:\Programowanie\PracaDyplomowa\BrazilianECommerce\Dataset\olist_orders_dataset.csv"
    ),
    [Delimiter = ",", Columns = 8, Encoding = 1250, QuoteStyle = QuoteStyle.None]
  ),
  #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
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
  #"Added Index" = Table.AddIndexColumn(#"Renamed Columns", "Order Id", 1, 1, Int64.Type)
in
  #"Added Index"