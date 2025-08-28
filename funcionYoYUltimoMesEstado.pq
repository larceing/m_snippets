// fnYoY_UltimoMes_Status
// Compara el último mes disponible vs mismo mes del año anterior y devuelve YoY_% + Estado.
// Parámetros: tbl, dateCol, entityCol, valueCol, optionalDeadband (por defecto 0.005 = 0,5%)
(tbl as table, dateCol as text, entityCol as text, valueCol as text, optionalDeadband as nullable number) as table =>
let
    Deadband = if optionalDeadband = null then 0.005 else optionalDeadband,
    T1    = Table.TransformColumnTypes(tbl, {{dateCol, type date}}),
    AddYM = Table.AddColumn(T1, "AñoMes", each Date.Year(Record.Field(_, dateCol))*100 + Date.Month(Record.Field(_, dateCol)), Int64.Type),
    ByYM  = Table.Group(AddYM, {entityCol, "AñoMes"}, {{"TotalMes", each List.Sum(Table.Column(_, valueCol)), type number}}),
    LastYM  = List.Max(ByYM[AñoMes]),
    PrevYM  = let y = Number.IntegerDivide(LastYM, 100) in (y - 1)*100 + (LastYM - y*100),
    Curr  = Table.SelectRows(ByYM, each [AñoMes] = LastYM),
    Prev  = Table.SelectRows(ByYM, each [AñoMes] = PrevYM),
    Join  = Table.NestedJoin(Curr, {entityCol}, Prev, {entityCol}, "Prev", JoinKind.LeftOuter),
    Exp   = Table.ExpandTableColumn(Join, "Prev", {"TotalMes"}, {"TotalMes_AñoPrev"}),
    AddΔ  = Table.AddColumn(Exp, "YoY_Δ", each if [TotalMes_AñoPrev] <> null then [TotalMes] - [TotalMes_AñoPrev] else null, type number),
    AddPct= Table.AddColumn(AddΔ, "YoY_%", each if [TotalMes_AñoPrev] = null or [TotalMes_AñoPrev] = 0 then null else [YoY_Δ] / [TotalMes_AñoPrev], type number),
    AddSt = Table.AddColumn(AddPct, "Estado",
            each let p = [YoY_%] in
                 if p = null then "SIN DATO"
                 else if p >  Deadband then "SUBE"
                 else if p < -Deadband then "BAJA"
                 else "IGUAL", type text)
in
    AddSt


// Semáforo por Artículo, margen neutro 1%
//fnYoY_UltimoMes_Status(Ventas, "Fecha", "IdArticulo", "Importe", 0.01)
