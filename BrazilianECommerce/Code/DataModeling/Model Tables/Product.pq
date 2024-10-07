let
  // Wczytanie danych z pliku CSV o nazwie "olist_products_dataset.csv"
  Source = Csv.Document(
    File.Contents(
      "D:\Programowanie\PracaInzynierska\BrazilianECommerce\Dataset\olist_products_dataset.csv"
    ), 
    [Delimiter = ",", Columns = 9, Encoding = 1250, QuoteStyle = QuoteStyle.None]
  ), 

  // Ustawienie pierwszego wiersza na nagłówki kolumn
  #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]), 

  // Zmiana typów danych kolumn na odpowiednie:
  // - Kolumny z danymi tekstowymi na tekst,
  // - Kolumny z liczbami całkowitymi na Int64
  // - Kolumna z wagą na Int64
  #"Change Column Types" = Table.TransformColumnTypes(
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

  // Usunięcie kolumn, które nie są potrzebne do dalszej analizy
  #"Remove Unnecessary Columns" = Table.RemoveColumns(
    #"Change Column Types", 
    {"product_name_lenght", "product_description_lenght"}
  ), 

  // Zmiana nazw kolumn na bardziej zrozumiałe
  #"Rename Columns" = Table.RenameColumns(
    #"Remove Unnecessary Columns", 
    {
      {"product_photos_qty", "Photos Quantity"}, 
      {"product_weight_g", "Weight (g)"}, 
      {"product_length_cm", "Length (cm)"}, 
      {"product_height_cm", "Height (cm)"}, 
      {"product_width_cm", "Width (cm)"}
    }
  ), 

  // Dodanie indeksu do każdej pozycji produktu
  #"Add Product Index" = Table.AddIndexColumn(
    #"Rename Columns", 
    "Product Id", 
    1, 
    1, 
    Int64.Type
  ), 

  // Połączenie tabeli produktów z tabelą kategorii na podstawie nazwy kategorii produktu
  #"Merge With Category Table" = Table.NestedJoin(
    #"Add Product Index", 
    {"product_category_name"}, 
    Category, 
    {"Brasil Category Name"}, 
    "Category", 
    JoinKind.LeftOuter
  ), 

  // Rozwinięcie tabeli kategorii, aby uzyskać identyfikator kategorii
  #"Expand Category Table" = Table.ExpandTableColumn(
    #"Merge With Category Table", 
    "Category", 
    {"Category Id"}, 
    {"Category Id"}
  ), 

  // Usunięcie kolumn, które nie są już potrzebne po dołączeniu tabeli kategorii
  #"Remove Unnecessary Columns After Merge" = Table.RemoveColumns(
    #"Expand Category Table", 
    {"product_id", "product_category_name"}
  ), 

  // Zmiana kolejności kolumn, aby uzyskać pożądany układ
  #"Reorder Columns" = Table.ReorderColumns(
    #"Remove Unnecessary Columns After Merge", 
    {
      "Product Id", 
      "Category Id", 
      "Photos Quantity", 
      "Weight (g)", 
      "Length (cm)", 
      "Height (cm)", 
      "Width (cm)"
    }
  ), 

  // Połączenie tabeli produktów z tabelą ocen produktów na podstawie identyfikatora produktu
  #"Merge With Product Rating Table" = Table.NestedJoin(
    #"Reorder Columns", 
    {"Product Id"}, 
    #"olist_order_items_dataset (product rating)", 
    {"Product Id"}, 
    "olist_order_items_dataset (product rating)", 
    JoinKind.LeftOuter
  ), 

  // Rozwinięcie tabeli ocen produktów, aby uzyskać ocenę produktu
  #"Expand Product Rating Table" = Table.ExpandTableColumn(
    #"Merge With Product Rating Table", 
    "olist_order_items_dataset (product rating)", 
    {"Product Rating"}, 
    {"Product Rating"}
  )
in
  #"Expand Product Rating Table"