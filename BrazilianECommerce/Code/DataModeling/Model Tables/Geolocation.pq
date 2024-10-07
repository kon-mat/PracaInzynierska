let

  // Wczytanie danych z pliku CSV
  Source = Csv.Document(
    File.Contents(
      "D:\Programowanie\PracaDyplomowa\BrazilianECommerce\Dataset\olist_geolocation_dataset.csv"
    ),
    [Delimiter = ",", Columns = 5, Encoding = 65001, QuoteStyle = QuoteStyle.None]
  ),
  // Promowanie pierwszego wiersza na nagłówki kolumn
  #"Promote Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
  // Konwersja typów kolumn na odpowiednie
  #"Change Column Types" = Table.TransformColumnTypes(
    #"Promote Headers",
    {
      {"geolocation_zip_code_prefix", Int64.Type},
      {"geolocation_lat", type number},
      {"geolocation_lng", type number},
      {"geolocation_city", type text},
      {"geolocation_state", type text}
    }
  ),
  // Usunięcie zduplikowanych wierszy
  #"Remove Duplicates" = Table.Distinct(#"Change Column Types"),
  // Dodanie zakresu dla szerokości geograficznej (Latitude) - początkowy zakres
  #"Add Latitude Range Start" = Table.AddColumn(
    #"Remove Duplicates",
    "lat_range_1",
    each
      if [geolocation_lat] < 0 then
        (Number.RoundUp([geolocation_lat] / 3)) * 3
      else
        (Number.RoundDown([geolocation_lat] / 3)) * 3,
    Int64.Type
  ),
  // Dodanie zakresu dla szerokości geograficznej (Latitude) - końcowy zakres
  #"Add Latitude Range End" = Table.AddColumn(
    #"Add Latitude Range Start",
    "lat_range_2",
    each if [lat_range_1] < 0 then [lat_range_1] - 3 else [lat_range_1] + 3,
    Int64.Type
  ),
  // Dodanie zakresu dla długości geograficznej (Longitude) - początkowy zakres
  #"Add Longitude Range Start" = Table.AddColumn(
    #"Add Latitude Range End",
    "lng_range_1",
    each
      if [geolocation_lng] < 0 then
        (Number.RoundUp([geolocation_lng] / 3)) * 3
      else
        (Number.RoundDown([geolocation_lng] / 3)) * 3,
    Int64.Type
  ),
  // Dodanie zakresu dla długości geograficznej (Longitude) - końcowy zakres
  #"Add Longitude Range End" = Table.AddColumn(
    #"Add Longitude Range Start",
    "lng_range_2",
    each if [lng_range_1] < 0 then [lng_range_1] - 3 else [lng_range_1] + 3,
    Int64.Type
  ),
  // Połączenie początkowego i końcowego zakresu szerokości geograficznej w jeden zakres
  #"Combine Latitude Ranges" = Table.AddColumn(
    #"Add Longitude Range End",
    "lat_range",
    each
      if [lat_range_1] < 0 then
        "(" & Number.ToText([lat_range_1]) & ") - (" & Number.ToText([lat_range_2]) & ")"
      else
        Number.ToText([lat_range_1]) & " - " & Number.ToText([lat_range_2]),
    Text.Type
  ),
  // Połączenie początkowego i końcowego zakresu długości geograficznej w jeden zakres
  #"Combine Longitude Ranges" = Table.AddColumn(
    #"Combine Latitude Ranges",
    "lng_range",
    each
      if [lng_range_1] < 0 then
        "(" & Number.ToText([lng_range_1]) & ") - (" & Number.ToText([lng_range_2]) & ")"
      else
        Number.ToText([lng_range_1]) & " - " & Number.ToText([lng_range_2]),
    Text.Type
  ),
  // Stworzenie pełnego zakresu współrzędnych geograficznych (Latitude i Longitude)
  #"Create Coordinate Range" = Table.AddColumn(
    #"Combine Longitude Ranges",
    "coordinates_range",
    each "[" & [lng_range] & "] ; [" & [lat_range] & "]",
    Text.Type
  ),
  // Wybór tylko niezbędnych kolumn
  #"Select Necessary Columns" = Table.SelectColumns(
    #"Create Coordinate Range",
    {"geolocation_zip_code_prefix", "coordinates_range", "geolocation_lat", "geolocation_lng"}
  ),
  // Grupowanie danych według kodu pocztowego i zakresu współrzędnych
  #"Group By Zip And Coordinates" = Table.Group(
    #"Select Necessary Columns",
    {"geolocation_zip_code_prefix", "coordinates_range"},
    {
      {"latitude", each List.Average([geolocation_lat]), type nullable number},
      {"longitude", each List.Average([geolocation_lng]), type nullable number},
      {"number_of_coordinates", each Table.RowCount(_), Int64.Type}
    }
  ),
  // Sortowanie wierszy po liczbie współrzędnych
  #"Sort By Coordinate Density" = Table.Sort(
    #"Group By Zip And Coordinates",
    {{"number_of_coordinates", Order.Descending}}
  ),
  // Usunięcie duplikatów na podstawie kodu pocztowego
  #"Remove Duplicate Zip Codes" = Table.Distinct(
    #"Sort By Coordinate Density",
    {"geolocation_zip_code_prefix"}
  ),
  // Wybór niezbędnych kolumn po usunięciu duplikatów
  #"Select Final Columns" = Table.SelectColumns(
    #"Remove Duplicate Zip Codes",
    {"geolocation_zip_code_prefix", "latitude", "longitude"}
  ),
  // Zmiana nazw kolumn na bardziej zrozumiałe
  #"Rename Columns For Clarity" = Table.RenameColumns(
    #"Select Final Columns",
    {
      {"geolocation_zip_code_prefix", "Zip Code Prefix"},
      {"latitude", "Latitude"},
      {"longitude", "Longitude"}
    }
  )
in
  #"Rename Columns For Clarity"