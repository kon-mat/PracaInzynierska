let
    // Wczytanie danych z dekompresji Base64 i utworzenie tabeli
    LoadData = Table.FromRows(
        Json.Document(
            Binary.Decompress(
                Binary.FromText("i45WMlSK1YlWMgKTxmDSBEyagkkzMGkOJi3ApCWYNDRQio0FAA==", BinaryEncoding.Base64), 
                Compression.Deflate
            )
        ), 
        let _t = ((type nullable text) meta [Serialized.Text = true]) 
        in type table [Rows = _t]
    ), 

    // Zmiana typu danych w kolumnie "Rows" na Int64
    ChangeTypeRows = Table.TransformColumnTypes(LoadData, {{"Rows", Int64.Type}}), 

    // Dodanie nowej kolumny "Columns" zawierającej listę wartości od 1 do 10
    AddColumn = Table.AddColumn(ChangeTypeRows, "Columns", each {1..10}), 

    // Rozwinięcie listy w kolumnie "Columns" do pojedynczych wierszy
    ExpandColumnsList = Table.ExpandListColumn(AddColumn, "Columns"), 

    // Zmiana typu danych w kolumnie "Columns" na Int64
    ChangeTypeColumns = Table.TransformColumnTypes(ExpandColumnsList, {{"Columns", Int64.Type}}), 

    // Dodanie kolumny indeksu "Value" zaczynającej się od 1
    AddIndex = Table.AddIndexColumn(ChangeTypeColumns, "Value", 1, 1, Int64.Type)
in
    AddIndex