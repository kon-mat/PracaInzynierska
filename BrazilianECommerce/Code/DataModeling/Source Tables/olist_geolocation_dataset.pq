let
  Source = Csv.Document(
    File.Contents(
      "D:\Programowanie\PracaDyplomowa\BrazilianECommerce\Dataset\olist_geolocation_dataset.csv"
    ),
    [Delimiter = ",", Columns = 5, Encoding = 65001, QuoteStyle = QuoteStyle.None]
  ),
  #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
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
  #"Removed Duplicates" = Table.Distinct(#"Changed Type")
in
  #"Removed Duplicates"