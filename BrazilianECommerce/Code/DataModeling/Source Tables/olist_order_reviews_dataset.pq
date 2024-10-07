let
  Source = Csv.Document(
    File.Contents(
      "D:\Programowanie\PracaDyplomowa\BrazilianECommerce\Dataset\olist_order_reviews_dataset.csv"
    ), 
    [Delimiter = ",", Columns = 7, Encoding = 65001, QuoteStyle = QuoteStyle.Csv]
  ), 
  #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars = true]), 
  #"Changed Type" = Table.TransformColumnTypes(
    #"Promoted Headers", 
    {
      {"review_id", type text}, 
      {"order_id", type text}, 
      {"review_score", Int64.Type}, 
      {"review_comment_title", type text}, 
      {"review_comment_message", type text}, 
      {"review_creation_date", type datetime}, 
      {"review_answer_timestamp", type datetime}
    }
  )
in
  #"Changed Type"