let
  // Wczytanie danych z pliku CSV o nazwie "brazil_states.csv"
  Source = Csv.Document(
    File.Contents("D:\Programowanie\PracaInzynierska\BrazilianECommerce\Dataset\brazil_states.csv"),
    [Delimiter = ",", Columns = 3, Encoding = 65001, QuoteStyle = QuoteStyle.None]
  ),

  // Promowanie pierwszego wiersza na nagłówki kolumn
  #"Promote Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),

  // Konwersja typów kolumn na odpowiednie (Abbreviation, State, Region)
  #"Change Column Types" = Table.TransformColumnTypes(
    #"Promote Headers",
    {{"Abbreviation", type text}, {"State", type text}, {"Region", type text}}
  )
in
  #"Change Column Types"