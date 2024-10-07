let
  Source = Csv.Document(
    File.Contents(
      "D:\Programowanie\PracaDyplomowa\BrazilianECommerce\Dataset\product_category_name_translation.csv"
    ),
    [Delimiter = ",", Columns = 2, Encoding = 65001, QuoteStyle = QuoteStyle.None]
  ),
  #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
  #"Changed Type" = Table.TransformColumnTypes(
    #"Promoted Headers",
    {{"product_category_name", type text}, {"product_category_name_english", type text}}
  ),
  #"Renamed Columns" = Table.RenameColumns(
    #"Changed Type",
    {
      {"product_category_name", "Brasil Category Name"},
      {"product_category_name_english", "Category Name"}
    }
  ),
  #"Added Index" = Table.AddIndexColumn(#"Renamed Columns", "Category Id", 1, 1, Int64.Type)
in
  #"Added Index"