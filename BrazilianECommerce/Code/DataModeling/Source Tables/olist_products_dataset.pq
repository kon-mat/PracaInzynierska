let
  // Wczytanie danych z pliku CSV do tabeli
  Source = Csv.Document(
    File.Contents(
      "D:\Programowanie\PracaDyplomowa\BrazilianECommerce\Dataset\olist_products_dataset.csv"
    ), 
    [Delimiter = ",", Columns = 9, Encoding = 1250, QuoteStyle = QuoteStyle.None]
  ), 

  // Ustawienie pierwszego wiersza na nagłówki kolumn
  #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]), 

  // Zmiana typów danych kolumn na odpowiednie typy
  #"Changed Column Types" = Table.TransformColumnTypes(
    #"Promoted Headers", 
    {
      {"product_id", type text}, 
      {"product_category_name", type text}, 
      {"product_name_lenght", Int64.Type}, 
      {"product_description_lenght", Int64.Type}, 
      {"product_photos_qty", Int64.Type}, 
      {"product_weight_g", Int64.Type}, 
      {"product_length_cm", Int64.Type}, 
      {"product_height_cm", Int64.Type}, 
      {"product_width_cm", Int64.Type}
    }
  ), 

  // Usunięcie kolumn, które są zbędne
  #"Removed Unnecessary Columns" = Table.RemoveColumns(
    #"Changed Column Types", 
    {"product_name_lenght", "product_description_lenght"}
  ), 

  // Zmiana nazw kolumn na bardziej zrozumiałe
  #"Renamed Columns" = Table.RenameColumns(
    #"Removed Unnecessary Columns", 
    {
      {"product_photos_qty", "Photos Quantity"}, 
      {"product_weight_g", "Weight (g)"}, 
      {"product_length_cm", "Length (cm)"}, 
      {"product_height_cm", "Height (cm)"}, 
      {"product_width_cm", "Width (cm)"}
    }
  ), 

  // Dodanie indeksu do każdego produktu
  #"Added Index" = Table.AddIndexColumn(
    #"Renamed Columns", 
    "Product Id", 
    1, 
    1, 
    Int64.Type
  )
in
  #"Added Index"