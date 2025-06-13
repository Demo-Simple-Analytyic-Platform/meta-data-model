# meta-data-model

This SQL Server Project will form the core of Meta-Data-Model for the deployment and processing logic. It works in Conjunction with "meta-data-definition"-repository which should hold the meta-data-definitions for model (project). This repositories holds both as a template to work/copy from. Below you`ll find instruction on to get started.

## How to get Started

To use this repository, new repositories must be created under you own control, surely for the model part. The `meta-data-model`-part can be used as is. But you won't have control over it, Better to make you own copy perhabs. The `meta-data-model`-part has all the database schemas, table, view, functions and procedures for `Deployment`- and internal data `Processing`- logic.
To keep `Models` lean and easy deployable, it would be good practic bundel related `datasets` per `model` the framework allows for referencing other `Models` and reusing the `datasets`.

To start using the framework the following step must be under taken.

## 1. Meta-Data-Model

The "***Meta-Data-Model***" should go into separate repository, for it is the database logic and workings of the tooling/framework. it controls the deployment "**Datasets**" and processing "**Data Pipelines**". The steps below will assume your as engineer have access and deployment right to the target database.

> ***Note:*** If you are content with the workings of the framework as is and have no intentions on modifying it, steps 3, 4, 5 and 6 can be skipped. The solution can be deployed from the *Visual Studio*-solution named "***meta-data-model.sln***" in the `\git\template\meta-data-model\`-folder.

1. Create a local folder on the root, name it `git` with a subfolder named `template`. This where you'll be storing/cloning the local versions of repositories.
2. Clone this [repo](https://github.com/mehmetmisset/linkedin-article-1-data-ingestion-transformation-requirements.git) to the `\git\template\`-folder. remember, this repo is publicly accessiable and `readonly` for all but the `owners`.
3. Create new git repository named `meta-data-model`, which under the `your` own contro. pre-populate the git inore file with "*Visual Studio*"-stuff. If forgotten, not to worry, just copy-paste then `.gitinore`-file from the `template`.
4. Clone `your` repo to `\git\`-folder, to make if locally aviable.
5. Copy the content including subfolder and all files of folder `\git\template\meta-data-model\` to `\git\meta-data-model\`-folder, `.vs`-folder can be ignored if avialable.
6. Open the *Visual Studio*-solution named "***meta-data-model.sln***" from the `\git\meta-data-model\`-folder.
7. Commit the changes to the branch and push to the remote.
8. Now you can "*publish*" the `Project` named `meta-data-model` to your target database.

The deployment- processing- logic has now be installed.

## 2. Meta-Data-Definition for a Model

Per `Model` a repository should be created, unlike the `meta-data-model`, these must be under you own control, for here the `meta-data-definitions` will be stored. The following steps should be taken to start utilizing the framework, we'll assume you have already executed steps 1 till up on 7 for the [1. Meta-Data-Model](#1-meta-data-model).

1. Create new git repository and give it the name of your `Model`,  make sure the name of the repo has a maximum of 16 characters. So short, compact and functional will do the trick.
2. Clone this new repository to your local `\git\`-folder, make sure the folder-name is equal to the name of the repository.
3. Copy the files and folders (including subfolder and files) from `\git\template\meta-data-definitions\`-folder.
4. Open the *Visual Studio*-solution named "***meta-data-definitions.sln***" from the `\git\<name-of-your-model>\`-folder.
5. Rename the *Visual Studio*-solution to the name of your model. With one `Model` this may seems for zelles, but more `Models` may be needed and keeping them apart woudl be tricky if they all have the same "*solution*"-name.
6. Navigate to `\git\<name-of-your-model>\2-meta-data-definitions\1-Frontend\`-folder and open the Microsoft Access File to start the `Frontend`-application. The application will try to determine the path to the repository, this will only work in the repository name is no longer the 16 characatere, otherwise the application wil give an error prompting you to shorten the name.
7. Navigate to the `Settings`-tab and click on import and the on export, this will ensure all the meta-data-defintion sql-files are in place.
8. Commit the changes to the branch and push to the remote.
9. Now you can "*publish*" the `Model` to your target database.

The deployment of your data solution should be done in few seconds, depending on the connection and speed/power of hte target database. The deployment time will increase when more and more dataset are added to the `Model`.

> ***Note:*** Different `Models` can be deployed to the same target database. `Datasets` referenced from another `Model` which are deployed to the same dataset are NOT deployed double. If the referenced `Dataset` is deployed to a different target database, it will be treaded as if it were a "*Ingestion*"-dataset, the required paramateres will be extracted form de `Model`-information.


