# 📊 Power Query M Snippets – Modelado de Datos

Este repositorio recopila ejemplos y funciones en **lenguaje M (Power Query)** diseñados para facilitar el **modelado de datos en Power BI**.  
El objetivo es ofrecer fragmentos de código reutilizables y buenas prácticas que aceleren el desarrollo de modelos tabulares claros, consistentes y escalables.

---

## 🚀 Contenido

- **Tablas calendario**
  - Calendario dinámico basado en rango de fechas de la fact table
  - Columnas auxiliares (Año, Mes, Trimestre, Semana, Día del año…)
  - Banderas para filtros rápidos (`ES_HOY`, `MES_ACTUAL`, `ULTIMOS_30_DIAS`…)

- **Dimensiones**
  - Scripts para derivar tablas de producto, cliente o geografía
  - Estandarización de campos y claves

- **Funciones auxiliares**
  - Limpieza y transformación de datos
  - Generación de columnas de ordenación (`YYYYMM`, `ORDEN_TRIMESTRE`, etc.)
  - Patrones reutilizables para diferentes proyectos

- **Buenas prácticas**
  - Separación clara de hechos y dimensiones
  - Ejemplos de relaciones y claves sustitutas
  - Tips para mantener modelos robustos

---

## 🛠️ Uso

1. Copia el código M desde los snippets que necesites.  
2. En Power BI / Power Query, ve a **Inicio > Editor avanzado**.  
3. Pega el código y adáptalo a tu modelo.  
4. Marca las tablas de calendario como **Date Table** en Power BI.  

---

## 📚 Ejemplos

- [Tabla calendario dinámica]
- [Dimensión producto]
- [Funciones auxiliares]

---

## 🤝 Contribuciones

Este repositorio está abierto a mejoras.  
Si tienes funciones o patrones útiles en M que quieras compartir, ¡haz un pull request o abre un issue!  

---

## 📌 Licencia

Este proyecto está bajo licencia MIT.  
Úsalo, modifícalo y compártelo libremente en tus proyectos.  

---

✨ **Power Query + Buen modelado = Modelos más claros y analítica más potente.**



## ⚠️ Disclaimer

El código de este repositorio se comparte **“tal cual”**, con fines educativos y de apoyo a la comunidad.  
No me hago responsable de errores, pérdidas de datos o problemas derivados de su uso en entornos productivos.  

👉 Recomendación: prueba siempre los snippets en un entorno de desarrollo antes de aplicarlos en proyectos reales.
