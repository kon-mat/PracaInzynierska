let
   // Utwórz listę dat zaczynając od 2013-01-01 na 3650 dni
   Source = List.Dates(#date(2016, 1, 1), 1096, #duration(1, 0, 0, 0)), 

   // Konwertuj listę na tabelę
   #"Converted to Table" = Table.FromList(
      Source, 
      Splitter.SplitByNothing(), 
      null, 
      null, 
      ExtraValues.Error
   ), 

   // Zmień nazwę kolumny na "Date"
   #"Renamed Columns" = Table.RenameColumns(#"Converted to Table", {{"Column1", "Date"}}), 

   // Zmień typ kolumny "Date" na datę
   #"Changed Type" = Table.TransformColumnTypes(#"Renamed Columns", {{"Date", type date}}), 

   // Wstaw kolumnę Date Key w formacie RRRRMMDD
   #"Inserted Date Key" = Table.AddColumn(
      #"Changed Type", 
      "Date Key", 
      each Date.Year([Date]) * 10000 + Date.Month([Date]) * 100 + Date.Day([Date]), 
      Int64.Type
   ), 

   // Wstaw kolumnę Day of Month
   #"Inserted Day of Month" = Table.AddColumn(
      #"Inserted Date Key", 
      "Day of Month", 
      each Date.Day([Date]), 
      Int64.Type
   ), 

   // Wstaw kolumnę Week Day Number (poniedziałek jako 1, niedziela jako 7)
   #"Inserted Week Day Number" = Table.AddColumn(
      #"Inserted Day of Month", 
      "Week Day Number", 
      each Date.DayOfWeek([Date], Day.Monday) + 1, 
      Int64.Type
   ), 

   // Wstaw kolumnę Week Day (skrót nazwy, np. Pon, Wt)
   #"Inserted Week Day" = Table.AddColumn(
      #"Inserted Week Day Number", 
      "Week Day", 
      each Date.ToText([Date], "ddd"), 
      type text
   ), 

   // Wstaw kolumnę Year Number
   #"Inserted Year Number" = Table.AddColumn(
      #"Inserted Week Day", 
      "Year Number", 
      each Date.Year([Date]), 
      Int64.Type
   ), 

   // Wstaw kolumnę Year jako tekst
   #"Inserted Year" = Table.AddColumn(
      #"Inserted Year Number", 
      "Year", 
      each Text.From(Date.Year([Date])), 
      type text
   ), 

   // Wstaw kolumnę Quarter Number
   #"Inserted Quarter Number" = Table.AddColumn(
      #"Inserted Year", 
      "Quarter Number", 
      each Date.QuarterOfYear([Date]), 
      Int64.Type
   ), 

   // Wstaw kolumnę Quarter (np. Q1, Q2)
   #"Inserted Quarter" = Table.AddColumn(
      #"Inserted Quarter Number", 
      "Quarter", 
      each "Q" & Text.From(Date.QuarterOfYear([Date])), 
      type text
   ), 

   // Wstaw kolumnę Quarter Year (np. Q1 2024)
   #"Inserted Quarter Year" = Table.AddColumn(
      #"Inserted Quarter", 
      "Quarter Year", 
      each "Q" & Text.From(Date.QuarterOfYear([Date])) & " " & Text.From(Date.Year([Date])), 
      type text
   ), 

   // Wstaw kolumnę Month Number
   #"Inserted Month Number" = Table.AddColumn(
      #"Inserted Quarter Year", 
      "Month Number", 
      each Date.Month([Date]), 
      Int64.Type
   ), 

   // Wstaw kolumnę Month (skrót nazwy, np. Sty, Lut)
   #"Inserted Month" = Table.AddColumn(
      #"Inserted Month Number", 
      "Month", 
      each Date.ToText([Date], "MMM"), 
      type text
   ), 

   // Wstaw kolumnę Year Month Number (np. 202401 dla stycznia 2024)
   #"Inserted Year Month Number" = Table.AddColumn(
      #"Inserted Month", 
      "Year Month Number", 
      each Date.Year([Date]) * 100 + Date.Month([Date]), 
      Int64.Type
   ), 

   // Wstaw kolumnę Month Year (np. Sty 2024)
   #"Inserted Month Year" = Table.AddColumn(
      #"Inserted Year Month Number", 
      "Month Year", 
      each Date.ToText([Date], "MMM") & " " & Text.From(Date.Year([Date])), 
      type text
   ), 

   // Wstaw kolumnę Week Number
   #"Inserted Week Number" = Table.AddColumn(
      #"Inserted Month Year", 
      "Week Number", 
      each Date.WeekOfYear([Date]), 
      Int64.Type
   ), 

   // Wstaw kolumnę Week (np. W01, W02)
   #"Inserted Week" = Table.AddColumn(
      #"Inserted Week Number", 
      "Week", 
      each "W" & Number.ToText(Date.WeekOfYear([Date]), "00"), 
      type text
   ), 

   // Wstaw kolumnę Week Year (np. W01-2024)
   #"Inserted Week Year" = Table.AddColumn(
      #"Inserted Week", 
      "Week Year", 
      each "W" & Number.ToText(Date.WeekOfYear([Date]), "00") & "-" & Text.From(Date.Year([Date])), 
      type text
   ), 

   // Wstaw kolumnę Week Year Order (np. 202401 dla pierwszego tygodnia 2024)
   #"Inserted Week Year Order" = Table.AddColumn(
      #"Inserted Week Year", 
      "Week Year Order", 
      each Date.Year([Date]) * 100 + Date.WeekOfYear([Date]), 
      Int64.Type
   ), 

   // Wstaw kolumnę Adjusted Week Number dla systemu dat ISO
   #"Inserted Week Number Adj." = Table.AddColumn(
      #"Inserted Week Year Order", 
      "Week Number Adj.", 
      each 
         if Number.RoundDown(
            (Date.DayOfYear([Date]) - (Date.DayOfWeek([Date], Day.Monday) + 1) + 10) / 7
         )
            = 0
         then
            Number.RoundDown(
               (
                  Date.DayOfYear(#date(Date.Year([Date]) - 1, 12, 31))
                     - (Date.DayOfWeek(#date(Date.Year([Date]) - 1, 12, 31), Day.Monday) + 1)
                     + 10
               )
                  / 7
            )
         else if (
            Number.RoundDown(
               (Date.DayOfYear([Date]) - (Date.DayOfWeek([Date], Day.Monday) + 1) + 10) / 7
            )
               = 53 and (Date.DayOfWeek(#date(Date.Year([Date]), 12, 31), Day.Monday) + 1 < 4)
         )
         then
            1
         else
            Number.RoundDown(
               (Date.DayOfYear([Date]) - (Date.DayOfWeek([Date], Day.Monday) + 1) + 10) / 7
            ), 
      Int64.Type
   ), 

   // Wstaw kolumnę Adjusted Week Year Order dla systemu dat ISO
   #"Inserted Week Year Order Adj." = Table.AddColumn(
      #"Inserted Week Number Adj.", 
      "Week Year Order Adj.", 
      each 
         if Date.Month([Date]) = 1 and [#"Week Number Adj."] > 50 then
            (Date.Year([Date]) - 1) * 100 + [#"Week Number Adj."]
         else if Date.Month([Date]) = 12 and [#"Week Number Adj."] = 1 then
            (Date.Year([Date]) + 1) * 100 + [#"Week Number Adj."]
         else
            Date.Year([Date]) * 100 + [#"Week Number Adj."], 
      Int64.Type
   ), 

   // Wstaw kolumnę Day of Year Number
   #"Inserted Day of Year Number" = Table.AddColumn(
      #"Inserted Week Year Order Adj.", 
      "Day of Year Number", 
      each Date.DayOfYear([Date]), 
      Int64.Type
   ), 

   // Wstaw kolumnę Start of Week (data poniedziałku danego tygodnia)
   #"Inserted Start of Week" = Table.AddColumn(
      #"Inserted Day of Year Number", 
      "Start of Week", 
      each Date.StartOfWeek([Date], Day.Monday), 
      type date
   ), 

   // Wstaw kolumnę End of Week (data niedzieli danego tygodnia)
   #"Inserted End of Week" = Table.AddColumn(
      #"Inserted Start of Week", 
      "End of Week", 
      each Date.EndOfWeek([Date], Day.Monday), 
      type date
   ), 

   // Wstaw kolumnę Start of Month (pierwsza data danego miesiąca)
   #"Inserted Start of Month" = Table.AddColumn(
      #"Inserted End of Week", 
      "Start of Month", 
      each Date.StartOfMonth([Date]), 
      type date
   ), 

   // Wstaw kolumnę End of Month (ostatnia data danego miesiąca)
   #"Inserted End of Month" = Table.AddColumn(
      #"Inserted Start of Month", 
      "End of Month", 
      each Date.EndOfMonth([Date]), 
      type date
   ), 

   // Wstaw kolumnę Start of Quarter (pierwsza data danego kwartału)
   #"Inserted Start of Quarter" = Table.AddColumn(
      #"Inserted End of Month", 
      "Start of Quarter", 
      each Date.StartOfQuarter([Date]), 
      type date
   ), 

   // Wstaw kolumnę End of Quarter (ostatnia data danego kwartału)
   #"Inserted End of Quarter" = Table.AddColumn(
      #"Inserted Start of Quarter", 
      "End of Quarter", 
      each Date.EndOfQuarter([Date]), 
      type date
   ), 

   // Wstaw kolumnę Start of Year (pierwsza data danego roku)
   #"Inserted Start of Year" = Table.AddColumn(
      #"Inserted End of Quarter", 
      "Start of Year", 
      each Date.StartOfYear([Date]), 
      type date
   ), 

   // Wstaw kolumnę End of Year (ostatnia data danego roku)
   #"Inserted End of Year" = Table.AddColumn(
      #"Inserted Start of Year", 
      "End of Year", 
      each Date.EndOfYear([Date]), 
      type date
   ), 

   // Wstaw kolumnę Day Type (klasyfikacja jako "Dzień roboczy" lub "Dzień wolny")
   #"Inserted Day Type" = Table.AddColumn(
      #"Inserted End of Year", 
      "Day Type", 
      each 
         if Date.DayOfWeek([Date], Day.Monday) = 5 or Date.DayOfWeek([Date], Day.Monday) = 6 then
            "Dzień wolny"
         else if Date.DayOfWeek([Date], Day.Monday) >= 0 and Date.DayOfWeek([Date], Day.Monday) <= 4 then
            "Dzień roboczy"
         else
            "Inny", 
      type text
   ), 

   // Wstaw kolumnę Date Previous Week (data tego samego dnia w poprzednim tygodniu)
   #"Inserted Date Previous Week" = Table.AddColumn(
      #"Inserted Day Type", 
      "Date Previous Week", 
      each Date.AddDays([Date], - 7), 
      type date
   ), 

   // Wstaw kolumnę Date Previous Month (data tego samego dnia w poprzednim miesiącu)
   #"Inserted Date Previous Month" = Table.AddColumn(
      #"Inserted Date Previous Week", 
      "Date Previous Month", 
      each Date.AddMonths([Date], - 1), 
      type date
   ), 

   // Wstaw kolumnę Date Previous Quarter (data tego samego dnia w poprzednim kwartale)
   #"Inserted Date Previous Quarter" = Table.AddColumn(
      #"Inserted Date Previous Month", 
      "Date Previous Quarter", 
      each Date.AddQuarters([Date], - 1), 
      type date
   ), 

   // Wstaw kolumnę Date Previous Year (data tego samego dnia w poprzednim roku)
   #"Inserted Date Previous Year" = Table.AddColumn(
      #"Inserted Date Previous Quarter", 
      "Date Previous Year", 
      each Date.AddYears([Date], - 1), 
      type date
   ), 

   // Wstaw kolumnę Month Days (liczba dni w danym miesiącu)
   #"Inserted Month Days" = Table.AddColumn(
      #"Inserted Date Previous Year", 
      "Month Days", 
      each Date.DaysInMonth([Date]), 
      Int64.Type
   ), 

   // Wstaw kolumnę Quarter Days (liczba dni w danym kwartale)
   #"Inserted Quarter Days" = Table.AddColumn(
      #"Inserted Month Days", 
      "Quarter Days", 
      each Duration.Days(Date.EndOfQuarter([Date]) - Date.StartOfQuarter([Date])) + 1, 
      Int64.Type
   ), 

   // Wstaw kolumnę Year Days (liczba dni w danym roku)
   #"Inserted Year Days" = Table.AddColumn(
      #"Inserted Quarter Days", 
      "Year Days", 
      each if Date.IsLeapYear(Date.Year([Date])) then 366 else 365, 
      Int64.Type
   )
in
    #"Inserted Year Days"