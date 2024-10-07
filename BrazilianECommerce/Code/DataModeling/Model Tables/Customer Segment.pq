let
  // Wczytanie danych z pliku CSV o nazwie "segments_rfm.csv"
  Source = Csv.Document(
    File.Contents("D:\Programowanie\PracaInzynierska\BrazilianECommerce\Dataset\segments_rfm.csv"), 
    [Delimiter = ",", Columns = 8, QuoteStyle = QuoteStyle.None]
  ),

  // Promowanie pierwszego wiersza na nagłówki kolumn
  #"Promote Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),

  // Konwersja typów kolumn na odpowiednie:
  // - "Index" na typ całkowity (Int64)
  // - "Segment", "Score", "Activity", "Actionable Tip" na typ tekstowy
  // - "R", "F", "M" na typ całkowity (Int64)
  #"Change Column Types" = Table.TransformColumnTypes(
    #"Promote Headers", 
    {
      {"Index", Int64.Type}, 
      {"Segment", type text}, 
      {"Score", type text}, 
      {"R", Int64.Type}, 
      {"F", Int64.Type}, 
      {"M", Int64.Type},
      {"Activity", type text},
      {"Actionable Tip", type text}
    }
  )
in
  #"Change Column Types"