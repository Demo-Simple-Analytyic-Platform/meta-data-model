# Ingestion of ***List of Currencies*** (Webtable from Wikipedia) [Back to readme](../../../README.md#tutorials-ingestions)

This tutorial will help you design an `ingestion`-dataset which will full load list from the [Wikipedia](https://en.wikipedia.org/wiki/List_of_circulating_currencies)-website for a specific for `Currency`. We\`ll be making use of the following languages, Technologies adn Tooling. Assumtions are made that the reader is familair and has some experience with the below mentioned *Languages*, *Technologies* and *Tooling*.

**Languages:**

![T-SQL](https://img.shields.io/badge/TSQL-purple?style=for-the-badge&labelColor=black&logo=TSQL&logoColor=white)
![PowerShell](https://img.shields.io/badge/PowerShell-darkgreen?style=for-the-badge&labelColor=black&logo=powershell&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&labelColor=black&logo=python&logoColor=white)
![HTML](https://img.shields.io/badge/HTML5-E34F26?style=for-the-badge&labelColor=black&logo=html5&logoColor=white)

**Technologies:**

![SQL-Server](https://img.shields.io/badge/SQL_Server-blue?style=for-the-badge&labelColor=black&logo=T-SQL&logoColor=white)
![Access](https://img.shields.io/badge/Microsoft%20Access-red?style=for-the-badge&labelColor=black&logo=microsoftaccess&logoColor=white)
![Git](https://img.shields.io/badge/Git-F05032?style=for-the-badge&labelColor=black&logo=git&logoColor=white)

**Tooling:**

![SSMS](https://img.shields.io/badge/SSMS-SQL%20Tools-darkblue?style=for-the-badge&labelColor=black&logo=microsoftsqlserver&logoColor=white)
![VS Code](https://img.shields.io/badge/VS%20Code-Editor-007ACC?style=for-the-badge&labelColor=black&logo=visualstudiocode&logoColor=white)

***Table of Content***

- [Ingestion of **Currency Exchange Rates** (webtable from Yahoo) Back to readme](#ingestion-of-currency-exchange-rates-webtable-from-yahoo-back-to-readme)
  - [User Story](#user-story)
    - [Additionals Infomation](#additionals-infomation)
  - [Exploration of the dataset structure (back to top)](#exploration-of-the-dataset-structure-back-to-top)
    - [goto website](#goto-website)
    - [Mapping](#mapping)
    - [Lets do the mapping](#lets-do-the-mapping)
  - [Deployemnt](#deployemnt)
  - [Run and Validate](#run-and-validate)
  - [Implementing EUR x CAD](#implementing-eur-x-cad)
  - [All Done](#all-done)

---

## User Story

As an **analyst**, I want to access **List of Currencies**, So that I can **provide more details to used currecies** when calculating **trading performance metrics** such as **losses, gains, and yield (rendement)** all in **EURO** currency. A public avialable source would met [wikipedia](https://en.wikipedia.org/wiki/List_of_circulating_currencies).

### Implentation

As in the previous tutorial of [Stock Trading Information](1-Stock-Trade-Information.md) and others we\`ll start with a Exploration of the dataset structure, do the mapping in the `meta-data-editor` and Deploy the new dataset, Run the data pipeline and validate. Since this is a webtable as wll, we can follow the same steps. 

## Exploration of the dataset structure ([back to top](#ingestion-of-list-of-currencies-webtable-from-wikipedia-back-to-readme))

Before we start designing the dataset, we must understand what the structure of the dataset is. For this purpose we\`ll be reusing various existing python procedures. As before in tutorial of [Stock-Trade-Information](1-Stock-Trade-Information.md) We\`ll perform the same steps, only we\`ll not explian in the same level of detail. Remember, with webpages, what you see, is not always what you get. The python data pipeline is basically a web-scrapper and the `table` we want to extract maybe presentated differently on the webpage and is in html. So the first step is to fetch the dataset manually.

### goto website

The historical exchange rates for US Dollar can be found on the website of [wikipedia](https://en.wikipedia.org/wiki/List_of_circulating_currencies) here we find various list related to currencies. We can us the browser to `inspect` the apparent 2nd table, and coutn the number of `<table` strings that appeer in the html-code, till arriving at the desired table, the number is 3, with this information lets look more carfully at the url.

Let desect the URL

- `https://en.wikipedia.org/wiki/List_of_circulating_currencies` (this seems fixed)
- `List_of_circulating_currencies` seems to point to the page `list of currencies`
- no informatione which can be used to filter for incremental loading
- information is in the 3rd table, since the python code start counit from 0, 2 would be the likely candidate for hte index.

### Mapping

The python procedure that extract the web-table is found `<your-git-folder>\<name-of-your-model>\4-processing-python\modules\`-folder and the `source.py`-file. The procedure is named `web_table_anonymous_web` and hase 4 input parameters.

- wtb_1_any_ds_url  (Base URL, the part that does not change)
- wtb_2_any_ds_path (Path, then dynamic part of URL that detemines the filtering of what information is loaded onto the webpage.)
- wtb_3_any_ni_index (Index of the Tables on the webpage)
- is_debugging (if set to true more detailed information is printed to consul window)

### Lets do the mapping

python: ***[example](1-Stock-Trade-Information/1-Explore-Webtable.py) Explore Webtable***

````python

# Add the directory containing the file to sys.path
import sys
# if you don't want type in the folder/file path on runtime.
fp_git_folder = "path-to-your-git-folder"
nm_your_repo  = "name-of-your-repository"

# Set the path to the modules directory
fp_modules    = f"{fp_git_folder}/{nm_your_repo}/4-processing-python"
sys.path.insert(0, fp_modules) 

# Import Modules
from modules import source as src  # type: ignore

# Extract web table
df = src.web_table_anonymous_web (
    wtb_1_any_ds_url   = "https://en.wikipedia.org/wiki/",
    wtb_2_any_ds_path  = "List_of_circulating_currencies",
    wtb_3_any_ni_index = "2",
    is_debugging       = "1"
)

````

As we can seen the result below, the column names seem to consist of two part, exploring the html-code wil confirm this, the header of the table has two row were some column are spanned. Regardless the pyhone prepared code will handle this.

````
Column Name:
------------------------------------
Currency_Currency
Symbol_or_abbrev_Symbol_or_abbrev
ISO_code_ISO_code
Fractional_unit_Name
Fractional_unit_No
Countries_territories_No
Countries_territories_Formal_users
------------------------------------

# Columns : 7
# Records : 22

------------------------------------
````

As before while reusing the `copy`-feature in the `meta-data-editor`-tooling we need to find a `dataset`, any `webtable`-dataset will do, the structure of the parameters is needed, not information. For the Grouping a new one would be approiated.
So let\`s select one and use the `copy`-feature and start editing the `new`-dataset.

### Adding new ***Group***

As said before a new ***Group*** would be best, this information coms from a different source being `Wikipedia`. Let open the list of ***Groups*** and add one named `PSA-002-Wikipedia`, for description `Wikipedia` will do, feel free to make it more suittable for your own needs. After You are done go back to the `detail`-form for `Dataset`, you may need th use the `F5`-button to refesch the list of ***Groups***.

![menu-show-group-list](../../images/meta-data-def/menu/menu-show-groups-list.png)

### Change Dataset Information

| Attribute          | Set to Value |
|:---                |:---       |
| Name               | `List of Currencies` |
| Schema             | `psa_wikipedia` |
| Table              | `currencies` |

### Change Attribute Information

| #   | BK | Column Name                        | Datatype      | Nullable | Attribute (Name)               | Attribute (Description) |
|:--- |:---|:---                                |:---           |:---      |:---                            |:---                     |
| 1   |    | Currency_Currency                  | NVARCHAR(999) | V        | Currency                       | Currency |
| 2   |    | Symbol_or_abbrev_Symbol_or_abbrev  | NVARCHAR(999) | V        | Symbol                         | Symbol |
| 3   | V  | ISO_code_ISO_code                  | NVARCHAR(999) | V        | ISO Code                       | ISO Code |
| 4   |    | Fractional_unit_Name               | NVARCHAR(999) | V        | Factional Unit Name            | Factional Unit Name |
| 5   |    | Fractional_unit_No                 | NVARCHAR(999) | V        | Factional Unit Number          | Factional Unit Number |
| 6   |    | Countries_territories_No           | NVARCHAR(999) | V        | # Countries / Territories      | # Countries / Territories |
| 7   |    | Countries_territories_Formal_users | NVARCHAR(999) | V        | Formal Countries / Territories | Formal Countries / Territories |

### Change Parameter Information

| Parameter | Value |
|:--- |:--- |
| wtb_1_any_ds_url   | `https://en.wikipedia.org/wiki/` |
| wtb_2_any_ds_path  | `List_of_circulating_currencies` |
| wth_3_any_ni_index | `2` | 

### SQL for Metadata-Attributes

| Attribute                    | Value |
|:---                          |:--- |
| Processing Type              | `Fullload` |
| SQL for `meta_dt_valid_from` | `GETDATE()` |
| SQL for `meta_dt_valid_till` | `'9999-12-31'` | 

### Source Query

After `copying` and `adjusing` the metadata defintions for `List of Currencies` we can "update" the `source query` by using the `create source query from attribute`-button. 

## Deployment

We can Save the definitions to the repository and `Deploy` to the `Development` by clicking `Deploy to Development`-button.

## Run and Validate

After deployment of the dataset, a data pipeline can be run by reusing the [`python`-script](./1-Stock-Trade-Information/2-Test-and-Validate.py) from the tutorial [Stock Trade Infromation](1-Stock-Trade-Information.md) and adjusitng it for the `schema` and `table` names used.

After running the script the result should give a dataset that would look something like

| | Currency_Currency | Symbol_<br>or_abbrev_<br>Symbol_or_<br>abbrev | ISO_code<br>_ISO_code | Fractional_<br>unit_Name | Fractional_<br>unit_No | Countries_<br>territories_<br>No | Countries<br>_territories_<br>Formal_users |
|---:|:---|:------------------------------------|:--------------------|:-----------------------|---------------------:|---------------------------:|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|  0 | Euro                     | €                                   | EUR                 | Cent                   |                  100 |                         43 | Akrotiri and Dhekelia, Andorra, Austria, Belgium, Croatia, Cyprus, Estonia, Finland (Åland), France (French Guiana, French Southern and Antarctic Lands, Guadeloupe, Martinique, Mayotte, Réunion, Saint Barthélemy, Saint Martin, Saint Pierre and Miquelon), Germany, Greece (Mount Athos), Ireland, Italy, Kosovo, Latvia, Lithuania, Luxembourg, Malta, Monaco, Montenegro, Netherlands, Portugal (Azores, Madeira), San Marino, Slovakia, Slovenia, Spain (Canary Islands, Ceuta, Melilla), Vatican City | 2025-08-01 21:15:03.070000 | 9999-12-31 00:00:00  | True             | 885893562DECDE708E419D4AEE724A7E | F771D01F206D6B296766802BB772516C | 3C95B1950CC758CD224F98C55DF5FA2F | 2025-08-01 21:15:03.093000 |
|  1 | United States dollar     | $                                   | USD                 | Cent                   |                  100 |                         19 | United States (American Samoa, Guam, Northern Mariana Islands, Puerto Rico, United States Virgin Islands), Bonaire, British Virgin Islands, Ecuador, El Salvador, Liberia, Marshall Islands, Micronesia, Palau, Panama, Saba, Sint Eustatius, Timor-Leste, Turks and Caicos Islands                                                                                                                   | 2025-08-01 21:15:03.070000 | 9999-12-31 00:00:00  | True             | E00536409ABF864F484D32AB5D41591A | BF50F78B66AA3C934DFE2482B94AA683 | C82F008B6C78BF37CA87C2E43D3C1E8A | 2025-08-01 21:15:03.093000 |
|  2 | Australian dollar        | $                                   | AUD                 | Cent                   |                  100 |                         11 | Australia (Ashmore and Cartier Islands, Australian Antarctic Territory, Christmas Island, Cocos Islands, Coral Sea Islands, Heard Island and McDonald Islands, Norfolk Island), Kiribati, Nauru, Tuvalu                                                                                                 | 2025-08-01 21:15:03.070000 | 9999-12-31 00:00:00  | True             | 3C50089A07637D6DA45B2928E72E9B99 | 162410279C747E8A549061A1BD7ABFF6 | C15918059A8759B7D4AA4EBFCA8F7E54 | 2025-08-01 21:15:03.093000 |
|  3 | Sterling                 | £                                   | GBP                 | Penny                  |                  100 |                         10 | United Kingdom (Bailiwick of Guernsey, Isle of Man, Jersey, Falkland Islands, Gibraltar, South Georgia and the South Sandwich Islands, Saint Helena, British Antarctic Territory, Tristan da Cunha) | 2025-08-01 21:15:03.070000 | 9999-12-31 00:00:00  | True             | 54B92967039F3827A9F074678FFEECFD | 56DCC91761B3234944AA17306C326BAB | ED6C49836E7E1E2BEAA843D19A988431 | 2025-08-01 21:15:03.093000 |
|  4 | Eastern Caribbean dollar | EC$                                 | XCD                 | Cent                   |                  100 |                          8 | Anguilla, Antigua and Barbuda, Dominica, Grenada, Montserrat, Saint Kitts and Nevis, Saint Lucia, Saint Vincent and the Grenadines                                                                                                       | 2025-08-01 21:15:03.070000 | 9999-12-31 00:00:00  | True             | 8F82719DAA17F95CC9E63DB77E26905B | 391B3D7F6E732CF7A54F45C0FB7A1B44 | B57059E01966953CD1214D7BEE8BE120 | 2025-08-01 21:15:03.093000 |

## All Done

With the help of the `copy`-feature in the `meta-data-editor` adding new `Ingestion`-dataset to het `model` is relatively easy. You could even choice to add `Template`-dataset for every type of source that would be used, copy from there.
