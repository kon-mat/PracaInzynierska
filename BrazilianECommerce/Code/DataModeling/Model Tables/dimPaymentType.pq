let
  // Wczytanie danych z pliku CSV
  Source = Csv.Document(
    File.Contents(
      "D:\Programowanie\PracaDyplomowa\BrazilianECommerce\Dataset\olist_order_payments_dataset.csv"
    ),
    [Delimiter = ",", Columns = 5, Encoding = 1250, QuoteStyle = QuoteStyle.None]
  ),

  // Ustawienie pierwszego wiersza na nagłówki kolumn
  #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),

  // Zmiana typów danych kolumn na odpowiednie
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

  // Filtrowanie wierszy, aby usunąć te z pustym order_id
  #"Filtered Rows" = Table.SelectRows(#"Changed Type", each [order_id] <> null and [order_id] <> ""),

  // Zmiana nazw kolumn na bardziej zrozumiałe
  #"Renamed Columns" = Table.RenameColumns(
    #"Filtered Rows",
    {
      {"payment_sequential", "Payment Sequential"},
      {"payment_type", "Brasil Payment Type"},
      {"payment_installments", "Payment Installment"},
      {"payment_value", "Payment Value"}
    }
  ),

  // Wybór tylko kolumny "Brasil Payment Type" do dalszej analizy
  #"Removed Other Columns" = Table.SelectColumns(#"Renamed Columns", {"Brasil Payment Type"}),

  // Usunięcie zduplikowanych wierszy
  #"Removed Duplicates" = Table.Distinct(#"Removed Other Columns"),

  // Dodanie kolumny warunkowej, zmieniającej wartość "boleto" na "bank_ticket"
  #"Added Conditional Column" = Table.AddColumn(
    #"Removed Duplicates",
    "Payment Type",
    each if [Brasil Payment Type] = "boleto" then "bank_ticket" else [Brasil Payment Type],
    type text
  ),

  // Dodanie indeksu do każdej metody płatności
  #"Added Index" = Table.AddIndexColumn(
    #"Added Conditional Column",
    "Payment Type Id",
    1,
    1,
    Int64.Type
  ),
  
  // Zmiana kolejności kolumn, aby "Payment Type Id" była pierwsza
  #"Reordered Columns" = Table.ReorderColumns(
    #"Added Index",
    {"Payment Type Id", "Brasil Payment Type", "Payment Type"}
  )
in
  #"Reordered Columns"