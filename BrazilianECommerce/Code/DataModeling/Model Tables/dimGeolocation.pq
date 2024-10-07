let
  // Wczytanie danych z pliku CSV
  Source = Csv.Document(
    File.Contents(
      "D:\Programowanie\PracaDyplomowa\BrazilianECommerce\Dataset\olist_geolocation_dataset.csv"
    ),
    [Delimiter = ",", Columns = 5, Encoding = 65001, QuoteStyle = QuoteStyle.None]
  ),

  // Ustawienie pierwszego wiersza na nagłówki kolumn
  #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),

  // Zmiana typów danych kolumn na odpowiednie
  #"Changed Type" = Table.TransformColumnTypes(
    #"Promoted Headers",
    {
      {"geolocation_zip_code_prefix", Int64.Type},
      {"geolocation_lat", type number},
      {"geolocation_lng", type number},
      {"geolocation_city", type text},
      {"geolocation_state", type text}
    }
  ),

  // Usunięcie zduplikowanych werszy
  #"Removed Duplicates" = Table.Distinct(#"Changed Type"),

  // Dodanie wartości 1 do zakresu z siatki dla wysokości geograficznej
  #"Added Custom" = Table.AddColumn(
    #"Removed Duplicates",
    "lat_range_1",
    each
      if [geolocation_lat] < 0 then
        (Number.RoundUp([geolocation_lat] / 3)) * 3
      else
        (Number.RoundDown([geolocation_lat] / 3)) * 3,
    Int64.Type
  ),

  // Dodanie wartości 2 do zakresu z siatki dla wysokości geograficznej
  #"Added Custom1" = Table.AddColumn(
    #"Added Custom",
    "lat_range_2",
    each if [lat_range_1] < 0 then [lat_range_1] - 3 else [lat_range_1] + 3,
    Int64.Type
  ),

  // Dodanie wartości 1 do zakresu z siatki dla szerokości geograficznej
  #"Added Custom2" = Table.AddColumn(
    #"Added Custom1",
    "lng_range_1",
    each
      if [geolocation_lng] < 0 then
        (Number.RoundUp([geolocation_lng] / 3)) * 3
      else
        (Number.RoundDown([geolocation_lng] / 3)) * 3,
    Int64.Type
  ),

  // Dodanie wartości 1 do zakresu z siatki dla szerokości geograficznej
  #"Added Custom3" = Table.AddColumn(
    #"Added Custom2",
    "lng_range_2",
    each if [lng_range_1] < 0 then [lng_range_1] - 3 else [lng_range_1] + 3,
    Int64.Type
  ),

  // Dodanie zakresu z siatki dla wysokości geograficznej
  #"Added Custom4" = Table.AddColumn(
    #"Added Custom3",
    "lat_range",
    each
      if [lat_range_1] < 0 then
        "(" & Number.ToText([lat_range_1]) & ") - (" & Number.ToText([lat_range_2]) & ")"
      else
        Number.ToText([lat_range_1]) & " - " & Number.ToText([lat_range_2]),
    Text.Type
  ),

  // Dodanie zakresu z siatki dla szerokości geograficznej
  #"Added Custom5" = Table.AddColumn(
    #"Added Custom4",
    "lng_range",
    each
      if [lng_range_1] < 0 then
        "(" & Number.ToText([lng_range_1]) & ") - (" & Number.ToText([lng_range_2]) & ")"
      else
        Number.ToText([lng_range_1]) & " - " & Number.ToText([lng_range_2]),
    Text.Type
  ),

  // Dodanie zakresu współrzędnych geograficznych
  #"Added Custom6" = Table.AddColumn(
    #"Added Custom5",
    "coordinates_range",
    each "[" & [lng_range] & "] ; [" & [lat_range] & "]",
    Text.Type
  ),

  // Wybór tylko niezbędnych kolumn do dalszej analizy
  #"Removed Other Columns" = Table.SelectColumns(
    #"Added Custom6",
    {"geolocation_zip_code_prefix", "coordinates_range", "geolocation_lat", "geolocation_lng"}
  ),

  // Zgrupowanie wierszy na podstawie zip_code oraz zakresu współrzędnych
  #"Grouped Rows" = Table.Group(
    #"Removed Other Columns",
    {"geolocation_zip_code_prefix", "coordinates_range"},
    {
      {"latitude", each List.Average([geolocation_lat]), type nullable number},
      {"longitude", each List.Average([geolocation_lng]), type nullable number},
      {"number_of_coordinates", each Table.RowCount(_), Int64.Type}
    }
  ),

  // Sortowanie zbioru po najbardziej zagęszczonych elementach siatki
  #"Sorted Rows" = Table.Sort(#"Grouped Rows", {{"number_of_coordinates", Order.Descending}}),

  // Usunięcie duplikatów na podstawie zip_code
  #"Removed Duplicates1" = Table.Distinct(#"Sorted Rows", {"geolocation_zip_code_prefix"}),

  // Usunięcie zbędnych kolumn
  #"Removed Other Columns1" = Table.SelectColumns(
    #"Removed Duplicates1",
    {"geolocation_zip_code_prefix", "latitude", "longitude"}
  ),

  // Zmiana nazw kolumn na bardziej zrozumiałe
  #"Renamed Columns" = Table.RenameColumns(
    #"Removed Other Columns1",
    {
      {"geolocation_zip_code_prefix", "Zip Code Prefix"},
      {"latitude", "Latitude"},
      {"longitude", "Longitude"}
    }
  )
in
  #"Renamed Columns"