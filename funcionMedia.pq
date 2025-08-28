// fnMediaAnualMensualizada
// Calcula la media anual (promedio de totales mensuales) por entidad.
// Parámetros:
//  - tbl: tabla de hechos (ej. Ventas)
//  - dateCol: nombre de la columna fecha (texto)
//  - entityCol: columna de entidad (Comercial/Cliente/Articulo) (texto)
//  - valueCol: columna numérica a agregar (texto)
//  - optionalYear: (opcional) año específico; si null, usa todo el rango

(tbl as table, dateCol as text, entityCol as text, valueCol as text, optionalYear as nullable number) as table =>
let
    // 1) Tipado y columnas auxiliares
    T1         = Table.TransformColumnTypes(tbl, {{dateCol, type date}}),
    AddYear    = Table.AddColumn(T1, "Año", each Date.Year(Record.Field(_, dateCol)), Int64.Type),
    AddAnoMes  = Table.AddColumn(AddYear, "AñoMes", each Date.Year(Record.Field(_, dateCol))*100 + Date.Month(Record.Field(_, dateCol)), Int64.Type),

    // 2) Filtro por año (si viene)
    TFil       = if optionalYear <> null 
                 then Table.SelectRows(AddAnoMes, each [Año] = optionalYear) 
                 else AddAnoMes,

    // 3) Total mensual por entidad (suma del valueCol por AñoMes)
    GroupMes   = Table.Group(
                    TFil,
                    {entityCol, "AñoMes"},
                    {{"TotalMes", each List.Sum(Table.Column(_, valueCol)), type number}}
                 ),

    // 4) Media de esos totales mensuales por entidad
    GroupEnt   = Table.Group(
                    GroupMes,
                    {entityCol},
                    {{"MediaMensualAnual", each List.Average(Table.Column(_, "TotalMes")), type number},
                     {"MesesContados",     each List.Count(  Table.Column(_, "TotalMes")), Int64.Type}}
                 )
in
    GroupEnt
