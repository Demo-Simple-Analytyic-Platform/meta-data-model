# Ingestion of **Currency Exchange Rates** (webtable from Yahoo) [Back to readme](../../../README.md#tutorials-ingestions)

This tutorial will help you design an `ingestion`-dataset which will incrementally load `Exchange Rates` from the [Yahoo Finance](https://finance.yahoo.com/quote/EURUSD%3DX/history)-website for a specific `Currency` of `US Dollar`. We\`ll be making use of the following languages, Technologies adn Tooling. Assumtions are made that the reader is familair and has some experience with the below mentioned *Languages*, *Technologies* and *Tooling*.

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

As an **analyst**, I want to access **historical Exchange Rates** for **US Dollar x Euro (USDEUR=X)**, So that I can **convert US Dollar to Euro of Stock Trading Information** and **calculate trading performance metrics** such as **losses, gains, and yield (rendement)** all in **EURO** currency.

### Additionals Infomation

Loading trade data for the last 5 year should give a good impression of what is happing with the share. Next to **US Dollar (USD)**, also make ***Canadian Dollar (CAD)*** aviablable.

### Implentation

As in the previous tutorial of [Stock Trading Information](1-Stock-Trade-Information.md) we\`ll start with a Exploration of the dataset structure, do the mapping in the `meta-data-editor` and Deploy the new dataset, Run the data pipeline and validate. Repeat for the `Canadian Dollar`.

## Exploration of the dataset structure ([back to top](#ingestion-of-currency-exchange-rates-webtable-from-yahoo-back-to-readme))

Before we start designing the dataset, we must understand what the structure of the dataset is. For this purpose we\`ll be reusing various existing python procedures. As before in tutorial of [Stock-Trade-Information](1-Stock-Trade-Information.md) We\`ll perform the same steps, only we\`ll not explian in the same level of detail.

With webpages, what you see, is not always what you get. The python data pipeline is basically a web-scrapper and the `table` we want to extract maybe presentated differently on the webpage and is in html. So the first step is to fetch the dataset manually.

### goto website

The historical exchange rates for US Dollar can be found on the website of [yahoo](https://finance.yahoo.com/) here we can search for the desired information.

Our first result is `https://finance.yahoo.com/quote/EURUSD%3DX`, however these are not historcal data. Exploring the website further, we`ll find link/button "Historical Data". By clicking this the website load a table with trade infromation on a daily basis for the past year. More exploration of the website reviels that specific periodes can be selected. Let do only the last 5 Days.

The url is now : `https://finance.yahoo.com/quote/EURUSD%3DX/history/?period1=1753192134&period2=1753623412`

Let desect the URL

- `https://finance.yahoo.com/quote/` (this seems fixed, note it is same a in tutorial of [Stock-Trade-Information](1-Stock-Trade-Information.md))
- EURUSD%3DX/ (This correlates with the Currency we have requested information on)
- history/ (seems to indicate the retrieved info is historical)
- ?period1=1752577325&period2=1753008901 (This show there are 2 periods-parameters both followed by number, deeper investication learns the these numbers are in the epoch-format and thus represent 2 point in time)

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
fp_git_folder = input(f"Git-Folderpath  : ")
nm_your_repo  = input(f"Repository Name : ")
# if you don't want type in the folder/file path on runtime.
#fp_git_folder = "path-to-your-git-folder"
#nm_your_repo  = "name-of-your-repository"

# Set the path to the modules directory
fp_modules    = f"{fp_git_folder}/{nm_your_repo}/4-processing-python"
sys.path.insert(0, fp_modules) 

# Import Modules
from modules import source as src  # type: ignore

# Extract web table
df = src.web_table_anonymous_web (
    wtb_1_any_ds_url   = "https://finance.yahoo.com/quote/",
    wtb_2_any_ds_path  = "EURUSD%3DX/history/?period1=1752577325&period2=1753008901",
    wtb_3_any_ni_index = "0",
    is_debugging       = "1"
)

print(df.columns)

````

As we can seen the result, below, is the same as what we have seen in tutorial [Stock Trade Infromation](1-Stock-Trade-Information.md), this helpfull, as we can reuse all the information gathered there and apply if here as well. We could use the `copy`-feature again.

````python
Index(['Date', 'Open', 'High', 'Low', 'Close Close price adjusted for splits.',
       'Adj Close Adjusted close price adjusted for splits and dividend and/or capital gain distributions.',
       'Volume'],
      dtype='object')
````

As before while reusing the `copy`-feature in the `meta-data-editor`-tooling we need to find a `dataset` to copy and identify the attributes/information that need adjusitng for the use of ingesting the `Exchange Rate for the USD x EUR`. In the Table below all attribute values are identified and mapped to the new values.

| Attribute         | Copied Values| Change it to |
|:---               |:---       |:---       |
| Name              | `Regions Financial Corporation (RF) - Copy` | `US Dollar x Euro (EURUSD=X)` |
| Table             | `RF_copy` | `eur_x_usd` |
| wtb_2_any_ds_path | `RF/history/?period1=<@ni_previous_epoch>&period2=<@ni_current_epoch>` | `EURUSD%3DX/history/?period1=<@ni_previous_epoch>&period2=<@ni_current_epoch>` |

## Deployemnt

After `copying` and `adjusing` the metadata defintions for `US Dollar x Euro (EURUSD=X)` we can "update" the `source query` by using the `create source query from attribute`-button. We can Save the definitions to the repository and `Deploy` to the `Development` by clicking `Deploy to Development`-button.

## Run and Validate

After deployment of the dataset, a data pipeline can be run by reusing the [`python`-script](./1-Stock-Trade-Information/2-Test-and-Validate.py) from the tutorial [Stock Trade Infromation](1-Stock-Trade-Information.md) and adjusitng it for the `schema` and `table` names used.

After running the script the result should give a dataset that would look something like

| Date         | Open  | High  | Low   | Close Close price adjusted for splits. | Adj Close Adjusted close price adjusted for splits and dividend and/or capital gain distributions. |
|:---          |:---   |:---   |:---   |:---   |:---   |
| Jul 25, 2025 | 1.1752 | 1.1763 | 1.171 | 1.1744 | 1.1744 |
| Jul 25, 2025 | 1.1756 | 1.1761 | 1.1707 | 1.1756 | 1.1756 |
| Jul 24, 2025 | 1.1774 | 1.1788 | 1.1733 | 1.1774 | 1.1774 |
| Jul 23, 2025 | 1.1739 | 1.1753 | 1.1712 | 1.1739 | 1.1739 |
| Jul 22, 2025 | 1.1695 | 1.1749 | 1.168 | 1.1695 | 1.1695 |
| Jul 21, 2025 | 1.1631 | 1.1717 | 1.1615 | 1.1631 | 1.1631 |
| Jul 18, 2025 | 1.1615 | 1.167 | 1.1613 | 1.1615 | 1.1615 |
| Jul 17, 2025 | 1.1636 | 1.1636 | 1.1569 | 1.1636 | 1.1636 |
| Jul 16, 2025 | 1.1607 | 1.1717 | 1.1564 | 1.1607 | 1.1607 |
| Jul 15, 2025 | 1.1666 | 1.1692 | 1.1602 | 1.1666 | 1.1666 |

## Implementing EUR x CAD

It would be save to conclude that most, if not all webtable on the yahoo finance website have the same structure. This Is very nice of them, so for now if we\`ll need more `trading`-information we can use the `copy`-feature in the `meta-dat-editor`.

For the `Exchange Rates` for `EUR x CAD` would should use the `copy`-feature and adjust the `metadata`-definitions accorddenly. We should replace `US Dollar` with `Canadian Dollar` and `USD` with `CAD`.

After deployment, run and validation the should look simular to `US Dollar` information.

## All Done

With the help of the `copy`-feature in the `meta-data-editor` adding new `Ingestion`-dataset to het `model` is relatively easy. Thi  concludes thsi tutorial.