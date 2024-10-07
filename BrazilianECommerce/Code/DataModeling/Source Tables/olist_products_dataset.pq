let
  Source = Csv.Document(
    File.Contents(
      "D:\Programowanie\PracaDyplomowa\BrazilianECommerce\Dataset\olist_products_dataset.csv"
    ),
    [Delimiter = ",", Columns = 9, Encoding = 1250, QuoteStyle = QuoteStyle.None]
  ),
  #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
  #"Changed Type" = Table.TransformColumnTypes(
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
  #"Removed Columns" = Table.RemoveColumns(
    #"Changed Type",
    {"product_name_lenght", "product_description_lenght"}
  ),
  #"Renamed Columns" = Table.RenameColumns(
    #"Removed Columns",
    {
      {"product_photos_qty", "Photos Quantity"},
      {"product_weight_g", "Weight (g)"},
      {"product_length_cm", "Length (cm)"},
      {"product_height_cm", "Height (cm)"},
      {"product_width_cm", "Width (cm)"}
    }
  ),
  #"Added Index" = Table.AddIndexColumn(#"Renamed Columns", "Product Id", 1, 1, Int64.Type)
in
  #"Added Index"