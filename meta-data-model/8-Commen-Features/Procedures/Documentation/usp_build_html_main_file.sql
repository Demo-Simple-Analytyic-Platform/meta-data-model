CREATE PROCEDURE mdm.usp_build_html_page_main

  /* Input Parameter(s) */
  @ip_is_debugging BIT = 0,
  @ip_is_testing   BIT = 0


AS DECLARE /* Local Variable(s) : Converted from */
  
  /* JSON-Array and helpers to hold Infromation for the HTML text. */
  @nm_part NVARCHAR(128),
  @ni_grp INT,
  @mx_grp INT,
  @tx_grp NVARCHAR(MAX),
  @ni_dst INT,
  @mx_dst INT,
  @tx_dst NVARCHAR(MAX),
  @is_ingestion BIT,

  /* Helpers File Text*/
  @ml CHAR(32)      = (SELECT id_model FROM mdm.current_model),
  @id NVARCHAR(32)  = '-1',
  @db BIT           = @ip_is_debugging,
  @tx NVARCHAR(MAX) = '',
  @nl NVARCHAR(1)   = CHAR(10),
  @st NVARCHAR(32),
  @cl NVARCHAR(32);

BEGIN
    
  /* Turn off Effected Row */
  SET NOCOUNT ON;
    
  /* Turn off Warnings */
  SET ANSI_WARNINGS OFF;

  IF (1=1 /* Groups and Datasets */) BEGIN
  
  DROP TABLE IF EXISTS ##html_grp;  
  SELECT * INTO ##html_grp
  FROM [ohg].[group] 
  WHERE meta_is_active = 1;

  DROP TABLE IF EXISTS ##html_dst;  
  SELECT * INTO ##html_dst
  FROM [dta].[dataset] 
  WHERE meta_is_active = 1
  /* !!! Exclude the "Data Quality" dataset that are "generated". !!! */
  AND   nm_target_schema NOT IN ('dqm', 'dq_result', 'dq_totals', 'dta_dq_aggregates');

  END

  IF (1=1 /* Build HTML-file */) BEGIN
    
    /* Clean out existing Text */
    DELETE FROM mdm.html_file_text WHERE id_model = @ml AND id_dataset = @id;

    IF (1=1 /* Build <head> part of file. */) BEGIN
      EXEC f @ml, @id, @tx;   SET @tx = N'<!DOCTYPE html>';
      EXEC f @ml, @id, @tx;   SET @tx = N'<html lang="en-US">';
      EXEC f @ml, @id, @tx;   SET @tx = N'  ';
      EXEC f @ml, @id, @tx;   SET @tx = N'  <title>Documentation of "Simple Analytic Data Platform"</title>';
      EXEC f @ml, @id, @tx;   SET @tx = N'  ';
      EXEC f @ml, @id, @tx;   SET @tx = N'  <head>';
      EXEC f @ml, @id, @tx;   SET @tx = N'    ';
      EXEC f @ml, @id, @tx;   SET @tx = N'    <meta charset="UTF-8">';
      EXEC f @ml, @id, @tx;   SET @tx = N'    <meta http-equiv="Content-Type"          content="text/html; charset=UTF-8">';
      EXEC f @ml, @id, @tx;   SET @tx = N'    <meta http-equiv="X-UA-Compatible"       content="IE=edge">';
      EXEC f @ml, @id, @tx;   SET @tx = N'    <meta name="viewport"                    content="width=device-width, initial-scale=1.0">';
      EXEC f @ml, @id, @tx;   SET @tx = N'    <meta name="msapplication-tap-highlight" content="no">';
      EXEC f @ml, @id, @tx;   SET @tx = N'    ';
      EXEC f @ml, @id, @tx;   SET @tx = N'    <link rel="stylesheet" href="../../css/document-tree.css">';
      EXEC f @ml, @id, @tx;   SET @tx = N'    <link rel="stylesheet" href="../../css/roboto.css">';
      EXEC f @ml, @id, @tx;   SET @tx = N'    <link rel="stylesheet" href="../../css/mermaid.css" />';
      EXEC f @ml, @id, @tx;   SET @tx = N'    <link rel="stylesheet" href="../../css/material_icons.css" />';
      EXEC f @ml, @id, @tx;   SET @tx = N'    ';
      EXEC f @ml, @id, @tx;   SET @tx = N'    <script type="text/javascript" src="../../js/mermaid.js"></script>';
      EXEC f @ml, @id, @tx;   SET @tx = N'    <script type="text/javascript" src="../../js/jquery-2.1.1.min.js"></script>';
      EXEC f @ml, @id, @tx;   SET @tx = N'    <style>' 
      EXEC f @ml, @id, @tx;   SET @tx = N'        .dataset {' 
      EXEC f @ml, @id, @tx;   SET @tx = N'            cursor: pointer;' 
      EXEC f @ml, @id, @tx;   SET @tx = N'            user-select: none;' 
      EXEC f @ml, @id, @tx;   SET @tx = N'        }' 
      EXEC f @ml, @id, @tx;   SET @tx = N'        .folder {' 
      EXEC f @ml, @id, @tx;   SET @tx = N'            cursor: pointer;' 
      EXEC f @ml, @id, @tx;   SET @tx = N'            user-select: none;' 
      EXEC f @ml, @id, @tx;   SET @tx = N'        }' 
      EXEC f @ml, @id, @tx;   SET @tx = N'        .nested {' 
      EXEC f @ml, @id, @tx;   SET @tx = N'            display: none;' 
      EXEC f @ml, @id, @tx;   SET @tx = N'        }' 
      EXEC f @ml, @id, @tx;   SET @tx = N'        .active {' 
      EXEC f @ml, @id, @tx;   SET @tx = N'            display: block;' 
      EXEC f @ml, @id, @tx;   SET @tx = N'        }' 
      EXEC f @ml, @id, @tx;   SET @tx = N'    </style>' 
      EXEC f @ml, @id, @tx;   SET @tx = N'    ';
      EXEC f @ml, @id, @tx;   SET @tx = N'  </head>';
      EXEC f @ml, @id, @tx;   SET @tx = N'  ';
    END
    IF (1=1 /* Build HTML <body>-element */) BEGIN

      EXEC f @ml, @id, @tx;       SET @tx = N'  <body>';
      EXEC f @ml, @id, @tx;       SET @tx = N'    ';
      EXEC f @ml, @id, @tx;       SET @tx = N'    <div style="display: flex; width: 100%; height: 100vh;">';
      
      EXEC f @ml, @id, @tx;       SET @tx = N'      <div id="foolders" style="width: 25%; overflow-y: auto;">'
      
      EXEC f @ml, @id, @tx;       SET @tx = N'        <ul id="myUL">'

      IF (1=1 /* Begin : List All Ingestion(s) BY Group */) BEGIN
    
        SET @nm_part = 'Ingestion';
        SET @is_ingestion = 1;
    
        EXEC f @ml, @id, @tx;     SET @tx = N'          <li><!-- Begin: ' + @nm_part + N'(s) by Group --><span class="folder">📁 ' + @nm_part + '(s) by Group</span>';
        EXEC f @ml, @id, @tx;     SET @tx = N'            <ul class="nested"><!-- List All ' + @nm_part + '(s) Dataset By Group -->'; 
        
        SET @ni_grp = 0; 
        SET @tx_grp = (SELECT * FROM ##html_grp WHERE id_group IN (SELECT id_group FROM ##html_dst WHERE is_ingestion = @is_ingestion) ORDER BY fn_group ASC FOR JSON AUTO);
        SET @mx_grp = mdm.json_count(@tx_grp); 
        WHILE (@ni_grp < @mx_grp) BEGIN 
        
          EXEC f @ml, @id, @tx;   SET @tx = N'              <li class="details" id="group/' + ISNULL(mdm.json_value(@ni_grp, @tx_grp, 'id_group'),'n/a') + N'"><span class="folder">📁 ' + ISNULL(mdm.json_value(@ni_grp, @tx_grp, 'fn_group'),'n/a') + N'</span>';
          EXEC f @ml, @id, @tx;   SET @tx = N'                <ul class="nested">'; 
          
          SET @ni_dst = 0;
          SET @tx_dst = (SELECT * FROM ##html_dst WHERE id_group = mdm.json_value(@ni_grp, @tx_grp, 'id_group') ORDER BY fn_dataset ASC FOR JSON AUTO);
          SET @mx_dst = mdm.json_count(@tx_dst);
          WHILE (@ni_dst < @mx_dst) BEGIN
            
            EXEC f @ml, @id, @tx; SET @tx = N'                  <li class="dataset" id="datasets/' + ISNULL(mdm.json_value(@ni_dst, @tx_dst, 'id_dataset'),'n/a') + N'.html">📄 ' + ISNULL(mdm.json_value(@ni_dst, @tx_dst, 'fn_dataset'),'n/a') + N'</li>'; 
            
          SET @ni_dst += 1; END
          
          EXEC f @ml, @id, @tx;   SET @tx = N'                </ul>';
          EXEC f @ml, @id, @tx;   SET @tx = N'              </li>'; 
        
        SET @ni_grp += 1; END
        
        EXEC f @ml, @id, @tx;     SET @tx = N'            </ul>';
        EXEC f @ml, @id, @tx;     SET @tx = N'         </li><!-- End: ' + @nm_part + '(s) by Group -->';
      
      END

      IF (1=1 /* Begin : List All Transformation(s) BY Group */) BEGIN

        SET @nm_part = 'Transformation';
        SET @is_ingestion = 0;
    
        EXEC f @ml, @id, @tx;     SET @tx = N'          <li><!-- Begin: ' + @nm_part + N'(s) by Group --><span class="folder">📁 ' + @nm_part + '(s) by Group</span>';
        EXEC f @ml, @id, @tx;     SET @tx = N'            <ul class="nested"><!-- List All ' + @nm_part + '(s) Dataset By Group -->'; 
        
        SET @ni_grp = 0; 
        SET @tx_grp = (SELECT * FROM ##html_grp WHERE id_group IN (SELECT id_group FROM ##html_dst WHERE is_ingestion = @is_ingestion) ORDER BY fn_group ASC FOR JSON AUTO);
        SET @mx_grp = mdm.json_count(@tx_grp); 
        WHILE (@ni_grp < @mx_grp) BEGIN 
        
          EXEC f @ml, @id, @tx;   SET @tx = N'              <li class="details" id="group/' + ISNULL(mdm.json_value(@ni_grp, @tx_grp, 'id_group'),'n/a') + N'"><span class="folder">📁 ' + ISNULL(mdm.json_value(@ni_grp, @tx_grp, 'fn_group'),'n/a') + N'</span>';
          EXEC f @ml, @id, @tx;   SET @tx = N'                <ul class="nested">'; 
          
          SET @ni_dst = 0;
          SET @tx_dst = (SELECT * FROM ##html_dst WHERE id_group = mdm.json_value(@ni_grp, @tx_grp, 'id_group') ORDER BY fn_dataset ASC FOR JSON AUTO);
          SET @mx_dst = mdm.json_count(@tx_dst);
          WHILE (@ni_dst < @mx_dst) BEGIN
            
            EXEC f @ml, @id, @tx; SET @tx = N'                  <li class="dataset" id="datasets/' + ISNULL(mdm.json_value(@ni_dst, @tx_dst, 'id_dataset'),'n/a') + N'.html">📄 ' + ISNULL(mdm.json_value(@ni_dst, @tx_dst, 'fn_dataset'),'n/a') + N'</li>'; 
            
          SET @ni_dst += 1; END
          
          EXEC f @ml, @id, @tx;   SET @tx = N'                </ul>';
          EXEC f @ml, @id, @tx;   SET @tx = N'              </li>'; 
        
        SET @ni_grp += 1; END
        
        EXEC f @ml, @id, @tx;     SET @tx = N'            </ul>';
        EXEC f @ml, @id, @tx;     SET @tx = N'         </li><!-- End: ' + @nm_part + '(s) by Group -->';
        
      END
                 
      EXEC f @ml, @id, @tx;       SET @tx = N'        </ul><!-- End myUL -->';
      
      EXEC f @ml, @id, @tx;       SET @tx = N'      </div>';
      EXEC f @ml, @id, @tx;       SET @tx = N'      <div style="width: 75%;">' 
      EXEC f @ml, @id, @tx;       SET @tx = N'        <iframe id="iframe-dataset" src="" width="100%" height="100%">'
      EXEC f @ml, @id, @tx;       SET @tx = N'        </iframe>';
      EXEC f @ml, @id, @tx;       SET @tx = N'      </div>';
      EXEC f @ml, @id, @tx;       SET @tx = N'    </div>';
      EXEC f @ml, @id, @tx;       SET @tx = N'    <script>'
      EXEC f @ml, @id, @tx;       SET @tx = N'      document.querySelectorAll(''.folder'').forEach(folder => {'
      EXEC f @ml, @id, @tx;       SET @tx = N'        folder.addEventListener(''click'', function() {'
      EXEC f @ml, @id, @tx;       SET @tx = N'          this.parentElement.querySelector(''.nested'').classList.toggle(''active'');'
      EXEC f @ml, @id, @tx;       SET @tx = N'          this.classList.toggle(''folder-open'');'
      EXEC f @ml, @id, @tx;       SET @tx = N'        });'
      EXEC f @ml, @id, @tx;       SET @tx = N'      });'
      EXEC f @ml, @id, @tx;       SET @tx = N'      document.querySelectorAll(''.dataset'').forEach(detail => {'
      EXEC f @ml, @id, @tx;       SET @tx = N'        detail.addEventListener(''click'', function() {'
      EXEC f @ml, @id, @tx;       SET @tx = N'          const iframe = document.getElementById(''iframe-dataset'');'
      EXEC f @ml, @id, @tx;       SET @tx = N'          iframe.src = this.id;'
      EXEC f @ml, @id, @tx;       SET @tx = N'        });'
      EXEC f @ml, @id, @tx;       SET @tx = N'      });'
      EXEC f @ml, @id, @tx;       SET @tx = N'    </script>'
      EXEC f @ml, @id, @tx;       SET @tx = N'    ';
      EXEC f @ml, @id, @tx;       SET @tx = N'  </body>';
      EXEC f @ml, @id, @tx;       SET @tx = N'  ';

    END
    IF (1=1 /* Build HTML </html>-element (end) */) BEGIN

      EXEC f @ml, @id, @tx;       SET @tx = N'</html>';
      EXEC f @ml, @id, @tx;       SET @tx = N'';
      EXEC f @ml, @id, @tx;       -- Write the last line.
        
    END

    IF (@ip_is_debugging = 1 /* Output HTML */ ) BEGIN
        SET @tx = ''; SELECT @tx += @nl + html.tx FROM (
            SELECT TOP 1000 tx = tx_line, ni = ni_line
            FROM mdm.html_file_text
            WHERE id_dataset = @id
            ORDER BY ni ASC
        ) AS html; EXEC gnc_commen.to_concol_window @tx;
    END
  
  END
  
  /* All Done */
  RETURN 0

END
GO
