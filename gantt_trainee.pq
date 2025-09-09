//Tabla de proyectos

let
  // Fechas base
  Today = Date.From(DateTime.LocalNow()),
  StartMin = #date(2025, 6, 1),

  // Utilidades
  DaysRange = Duration.Days(Today - StartMin) + 30,   // permitimos arranques hasta ~30 días en el futuro
  RandomBetween = (a as number, b as number) as number => Number.RoundDown(a + Number.Random() * (b - a + 1)),

  // Nombres "chulos" (5 elementos)
  NiceNames = {
    "Atlas Data",
    "Orion Connect",
    "Nebula Insights",
    "Vanguard Analytics",
    "Aurora Systems"
  },

  // Forzamos que uno esté en curso hoy (en progreso)
  InProgStart = Date.AddDays(Today, - RandomBetween(5, 20)),   // empezó hace 5..20 días
  InProgDur   = RandomBetween(15, 40),
  InProgEnd   = Date.AddDays(InProgStart, InProgDur - 1),

  // Generamos 5 proyectos
  ProjectsList =
    List.Transform({1..5}, (i) =>
      let
        // Para el proyecto 3, garantizamos que esté en curso hoy
        IsInProgress = (i = 3),
        PStart =
          if IsInProgress
          then InProgStart
          else Date.AddDays(StartMin, RandomBetween(0, DaysRange)),
        Dur   = if IsInProgress then InProgDur else RandomBetween(15, 40),
        PEnd  = Date.AddDays(PStart, Dur - 1),

        Rec = [
          ProjectIdx   = i,
          ProjectCode  = "P" & Text.PadStart(Text.From(i), 2, "0"),
          ProjectName  = NiceNames{ i - 1 },
          ProjectStart = PStart,
          ProjectEnd   = PEnd,
          DurationDays = Dur
        ]
      in
        Rec
    ),

  Projects = Table.FromRecords(
    ProjectsList,
    type table[
      ProjectIdx=Int64.Type,
      ProjectCode=text,
      ProjectName=text,
      ProjectStart=date,
      ProjectEnd=date,
      DurationDays=Int64.Type
    ]
  )
in
  Projects


// Tabla de Tareas

let
    Source = Projects,

    NameMap = [
        A = "Análisis de requisitos",
        B = "Desarrollo Backend",
        C = "Integración API",
        D = "QA Testing",
        E = "Despliegue en producción"
    ],
    DeptMap = [
        A = "PMO / Análisis",
        B = "Desarrollo",
        C = "DevOps / Integración",
        D = "QA / Testing",
        E = "Operaciones"
    ],

    HasEndCol = Table.HasColumns(Source, {"ProjectEnd"}),

    AddTasks = Table.AddColumn(
    Source, "TaskRecords",
    each
        let
            idx = [ProjectIdx],
            ps  = [ProjectStart],
            HasEndCol = Record.HasFields(_, "ProjectEnd"),
            pe  = if HasEndCol and [ProjectEnd] <> null then [ProjectEnd] else Date.AddDays(ps, 30),

            durA0 = 3 + Number.Mod(idx, 3),
            durB0 = 5 + Number.Mod(idx, 4),
            durC0 = 6 + Number.Mod(idx, 5),
            durD0 = 4 + Number.Mod(idx, 4),
            durE0 = 7 + Number.Mod(idx, 5),

            gA = Number.Mod(idx+0, 2),
            gB = Number.Mod(idx+1, 3),
            gC = 1 + Number.Mod(idx+2, 2),
            gD = 1,
            gE = 1,

            Astart = Date.AddDays(ps, gA),
            Aend   = Date.AddDays(Astart, durA0 - 1),

            Bstart = Date.AddDays(ps, gB),
            Bend   = Date.AddDays(Bstart, durB0 - 1),

            maxABend = if Aend > Bend then Aend else Bend,

            Cstart = Date.AddDays(maxABend, gC),
            Cend   = Date.AddDays(Cstart, durC0 - 1),

            Dstart = Date.AddDays(Cend, gD),
            Dend   = Date.AddDays(Dstart, durD0 - 1),

            maxCDend = if Cend > Dend then Cend else Dend,

            Estart0 = Date.AddDays(maxCDend, gE),
            Eend0   = Date.AddDays(Estart0, durE0 - 1),

            EendCap = if Eend0 > pe then pe else Eend0,
            durE    = Duration.Days(EendCap - Estart0) + 1,
            EstartFinal = if durE < 1 then pe else Estart0,
            EndFinal    = if durE < 1 then pe else EendCap,
            durEFix     = if durE < 1 then 1 else durE,

            recs = {
                [ProjectCode=[ProjectCode], TaskCode="A", TaskName=Record.Field(NameMap,"A") & " (" & [ProjectCode] & ")", Department=Record.Field(DeptMap,"A"), DurationDays=durA0, StartDate=Astart, EndDate=Aend],
                [ProjectCode=[ProjectCode], TaskCode="B", TaskName=Record.Field(NameMap,"B") & " (" & [ProjectCode] & ")", Department=Record.Field(DeptMap,"B"), DurationDays=durB0, StartDate=Bstart, EndDate=Bend],
                [ProjectCode=[ProjectCode], TaskCode="C", TaskName=Record.Field(NameMap,"C") & " (" & [ProjectCode] & ")", Department=Record.Field(DeptMap,"C"), DurationDays=durC0, StartDate=Cstart, EndDate=Cend],
                [ProjectCode=[ProjectCode], TaskCode="D", TaskName=Record.Field(NameMap,"D") & " (" & [ProjectCode] & ")", Department=Record.Field(DeptMap,"D"), DurationDays=durD0, StartDate=Dstart, EndDate=Dend],
                [ProjectCode=[ProjectCode], TaskCode="E", TaskName=Record.Field(NameMap,"E") & " (" & [ProjectCode] & ")", Department=Record.Field(DeptMap,"E"), DurationDays=durEFix, StartDate=EstartFinal, EndDate=EndFinal]
            }
        in
            recs,
    type list
),


    Expanded = Table.ExpandListColumn(AddTasks, "TaskRecords"),
    Tasks = Table.ExpandRecordColumn(
        Expanded,
        "TaskRecords",
        {"TaskCode","TaskName","Department","DurationDaysTask","StartDate","EndDate"},
        {"TaskCode","TaskName","Department","DurationDaysTask","StartDate","EndDate"}
    ),
    Typed = Table.TransformColumnTypes(
        Tasks,
        {
            {"ProjectCode", type text},
            {"TaskCode", type text},
            {"TaskName", type text},
            {"Department", type text},
            {"DurationDays", Int64.Type},
            {"StartDate", type date},
            {"EndDate", type date}
        }
    ),

AddIndex = Table.AddIndexColumn(Typed, "RowIndex", 0, 1, Int64.Type),
    AddSeq = Table.AddColumn(
        AddIndex,
        "TaskCompletionPercent",
        each
            let
                seq = {90, 70, 30, 60, 40, 90, 12.13},
                i = Number.Mod([RowIndex], List.Count(seq))
            in
                seq{i},
        type number
    ),
    RemoveIndex = Table.RemoveColumns(AddSeq, {"RowIndex"})
in
    RemoveIndex
