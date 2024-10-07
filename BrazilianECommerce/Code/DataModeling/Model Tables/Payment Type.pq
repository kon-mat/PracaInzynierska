let
  // Wczytanie danych z pliku CSV o nazwie "olist_order_payments_dataset.csv"
  Source = Csv.Document(
    File.Contents(
      "D:\Programowanie\PracaDyplomowa\BrazilianECommerce\Dataset\olist_order_payments_dataset.csv"
    ), 
    [Delimiter = ",", Columns = 5, Encoding = 1250, QuoteStyle = QuoteStyle.None]
  ), 

  // Ustawienie pierwszego wiersza jako nagłówków kolumn
  #"Promote Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]), 

  // Zmiana typów danych kolumn na odpowiednie:
  // - "order_id" na tekst, 
  // - "payment_sequential" i "payment_installments" na liczbę całkowitą (Int64),
  // - "payment_value" na typ walutowy
  #"Change Column Types" = Table.TransformColumnTypes(
    #"Promote Headers", 
    {
      {"order_id", type text}, 
      {"payment_sequential", Int64.Type}, 
      {"payment_type", type text}, 
      {"payment_installments", Int64.Type}, 
      {"payment_value", Currency.Type}
    }
  ), 

  // Filtrowanie wierszy w celu usunięcia pustych "order_id"
  #"Filter Empty Order IDs" = Table.SelectRows(
    #"Change Column Types", 
    each [order_id] <> null and [order_id] <> ""
  ), 

  // Zmiana nazw kolumn na bardziej zrozumiałe
  #"Rename Columns" = Table.RenameColumns(
    #"Filter Empty Order IDs", 
    {
      {"payment_sequential", "Payment Sequential"}, 
      {"payment_type", "Brasil Payment Type"}, 
      {"payment_installments", "Payment Installment"}, 
      {"payment_value", "Payment Value"}
    }
  ), 

  // Wybór tylko kolumny "Brasil Payment Type" do dalszej analizy
  #"Select Payment Type Column" = Table.SelectColumns(#"Rename Columns", {"Brasil Payment Type"}), 

  // Usunięcie zduplikowanych wierszy
  #"Remove Duplicates" = Table.Distinct(#"Select Payment Type Column"), 

  // Dodanie warunkowej kolumny, aby "boleto" zmienić na "bank_ticket"
  #"Add Conditional Payment Type Column" = Table.AddColumn(
    #"Remove Duplicates", 
    "Payment Type", 
    each if [Brasil Payment Type] = "boleto" then "bank_ticket" else [Brasil Payment Type], 
    type text
  ), 

  // Dodanie indeksu dla każdej metody płatności
  #"Add Payment Type Index" = Table.AddIndexColumn(
    #"Add Conditional Payment Type Column", 
    "Payment Type Id", 
    1, 
    1, 
    Int64.Type
  ), 

  // Zmiana kolejności kolumn, aby "Payment Type Id" była pierwsza
  #"Reorder Columns" = Table.ReorderColumns(
    #"Add Payment Type Index", 
    {"Payment Type Id", "Brasil Payment Type", "Payment Type"}
  ), 

  // Zamiana podkreśleń na spacje w kolumnie "Payment Type"
  #"Replace Underscores With Spaces" = Table.ReplaceValue(
    #"Reorder Columns", 
    "_", 
    " ", 
    Replacer.ReplaceText, 
    {"Payment Type"}
  ), 
  
  // Zamiana pierwszej litery każdego słowa w kolumnie "Payment Type" na wielką literę
  #"Capitalize Each Word In Payment Type" = Table.TransformColumns(
    #"Replace Underscores With Spaces", 
    {{"Payment Type", Text.Proper, type text}}
  )
in
  #"Capitalize Each Word In Payment Type"