let
    // 1. Obtener la fecha mínima y máxima desde la tabla de ventas
    FECHA_MIN = List.Min(#"Ventas por Familia"[FECHA]),
    FECHA_MAX = List.Max(#"Ventas por Familia"[FECHA]),

    // 2. Crear lista continua de fechas
    LISTA_FECHAS = List.Dates(Date.From(FECHA_MIN), Duration.Days(Date.From(FECHA_MAX) - Date.From(FECHA_MIN)) + 1, #duration(1,0,0,0)),
    TABLA_FECHAS = Table.FromList(LISTA_FECHAS, Splitter.SplitByNothing(), {"FECHA"}),
    TABLA_FECHAS_TIPO = Table.TransformColumnTypes(TABLA_FECHAS, {{"FECHA", type date}}),

    // 3. Obtener fecha actual para comparaciones
    HOY = Date.From(DateTime.LocalNow()),

    // 4. Columnas de calendario
    AÑO = Table.AddColumn(TABLA_FECHAS_TIPO, "AÑO", each Date.Year([FECHA]), Int64.Type),
    MES_NUMERO = Table.AddColumn(AÑO, "MES_NUMERO", each Date.Month([FECHA]), Int64.Type),
    MES_NOMBRE = Table.AddColumn(MES_NUMERO, "MES_NOMBRE", each Date.ToText([FECHA], "MMMM", "es-ES"), type text),
    DIA = Table.AddColumn(MES_NOMBRE, "DIA", each Date.Day([FECHA]), Int64.Type),
    DIA_SEMANA_NUMERO = Table.AddColumn(DIA, "DIA_SEMANA_NUMERO", each Date.DayOfWeek([FECHA], Day.Monday) + 1, Int64.Type),
    DIA_SEMANA_NOMBRE = Table.AddColumn(DIA_SEMANA_NUMERO, "DIA_SEMANA_NOMBRE", each Date.ToText([FECHA], "dddd", "es-ES"), type text),
    SEMANA_AÑO = Table.AddColumn(DIA_SEMANA_NOMBRE, "SEMANA_AÑO", each Date.WeekOfYear([FECHA], Day.Monday), Int64.Type),
    SEMANA_MES = Table.AddColumn(SEMANA_AÑO, "SEMANA_MES", each Number.RoundDown((Date.Day([FECHA]) - 1) / 7) + 1, Int64.Type),
    TRIMESTRE = Table.AddColumn(SEMANA_MES, "TRIMESTRE", each Date.QuarterOfYear([FECHA]), Int64.Type),
    DIA_AÑO = Table.AddColumn(TRIMESTRE, "DIA_AÑO", each Date.DayOfYear([FECHA]), Int64.Type),
    FIN_DE_SEMANA = Table.AddColumn(DIA_AÑO, "FIN_DE_SEMANA", each if Date.DayOfWeek([FECHA], Day.Monday) + 1 >= 6 then "SI" else "NO", type text),

    // 5. Marcas temporales
    ES_HOY = Table.AddColumn(FIN_DE_SEMANA, "ES_HOY", each if [FECHA] = HOY then "SI" else "NO", type text),
    MES_ACTUAL = Table.AddColumn(ES_HOY, "MES_ACTUAL", each if Date.Month([FECHA]) = Date.Month(HOY) and Date.Year([FECHA]) = Date.Year(HOY) then "SI" else "NO", type text),
    SEMANA_ACTUAL = Table.AddColumn(MES_ACTUAL, "SEMANA_ACTUAL", each if Date.WeekOfYear([FECHA], Day.Monday) = Date.WeekOfYear(HOY, Day.Monday) and Date.Year([FECHA]) = Date.Year(HOY) then "SI" else "NO", type text),
    ULTIMOS_30_DIAS = Table.AddColumn(SEMANA_ACTUAL, "ULTIMOS_30_DIAS", each if [FECHA] >= Date.AddDays(HOY, -30) and [FECHA] <= HOY then "SI" else "NO", type text),

    // 6. Mes y año en texto + campo de ordenación
    MES_ANO = Table.AddColumn(ULTIMOS_30_DIAS, "MES_ANO", each Text.Upper(Date.ToText([FECHA], "MMMM", "es-ES")) & " " & Text.From(Date.Year([FECHA])), type text),
    ORDEN_MES_ANO = Table.AddColumn(MES_ANO, "ORDEN_MES_ANO", each 
        Text.PadStart(Text.From(Date.Year(Date.From([FECHA]))), 4, "0") &
        Text.PadStart(Text.From(Date.Month(Date.From([FECHA]))), 2, "0"),
        type text
    ),
    #"Filas ordenadas" = Table.Sort(ORDEN_MES_ANO,{{"FECHA", Order.Descending}})

in
    #"Filas ordenadas"
