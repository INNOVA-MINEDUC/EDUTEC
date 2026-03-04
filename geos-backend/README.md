# Guia Edutec Repository - Open Source

## Language Dictionaries

All Language Dictionaries were moved from the database to discrete JSON files located at `app/assets/lang-dictionaries/`. Do not use the dictionaries found in the database as they are deprecated/outdated. The files must be manually maintained and kept in sync between all languages.

`legacy/`: Contains the original language dictionaries moved from the database

`other directories/`: Keep new dictionaries contextually separated in directories.

### Endpoint: GET translation/:langCode/:dictionary?

The API's `GET translation/` endpoint was changed to respond these JSON files. It maintains its original signature (retro-compatible) but it adds a new optional `:dictionary` parameter for contextual dictionaries. If no `:dictionary` parameter is passed, it will default to the `legacy` dictionary.

## Back-end project

-   [Technical Documentation](https://github.com/EL-BID/geos-backend/blob/master/Documentaci%C3%B3n_T%C3%A9cnica_Guia_Edutec.pdf)

Access to other projects

-   [Front-end](https://github.com/EL-BID/geos-frontend)
-   [Database](https://github.com/EL-BID/geos-database)

---

_The Guia Edutec was originally developed by CIEB. The process of opening the code has made possible by financial support of Fundación ProFuturo._


## Acknowledgments / Reconocimientos

**Copyright © [2025]. Inter-American Development Bank ("IDB"). Authorized Use.**  
The procedures and results obtained based on the execution of this software are those programmed by the developers and do not necessarily reflect the views of the IDB, its Board of Executive Directors or the countries it represents.

**Copyright © [2025]. Banco Interamericano de Desarrollo ("BID"). Uso Autorizado.**  
Los procedimientos y resultados obtenidos con la ejecución de este software son los programados por los desarrolladores y no reflejan necesariamente las opiniones del BID, su Directorio Ejecutivo ni los países que representa.

### Support and Usage Documentation / Documentación de Soporte y Uso

**Copyright © [2025]. Inter-American Development Bank ("IDB").** The Support and Usage Documentation is licensed under the Creative Commons License CC-BY 4.0 license. The opinions expressed in the Support and Usage Documentation are those of its authors and do not necessarily reflect the opinions of the IDB, its Board of Executive Directors, or the countries it represents.

**Copyright © [2025]. Banco Interamericano de Desarrollo (BID).** La Documentación de Soporte y Uso está licenciada bajo la licencia Creative Commons CC-BY 4.0. Las opiniones expresadas en la Documentación de Soporte y Uso son las de sus autores y no reflejan necesariamente las opiniones del BID, su Directorio Ejecutivo ni los países que representa.
