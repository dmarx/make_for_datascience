CREATE TABLE experiments
    (id                INTEGER PRIMARY KEY AUTOINCREMENT
    ,task_name         TEXT
    ,model_name        TEXT
    ,commit_id         TEXT
    ,created_date      DATE
    ,last_updated_date DATE
    );
    
CREATE TABLE results
    (id           INTEGER PRIMARY KEY AUTOINCREMENT
    ,exp_id       INTEGER
    ,result_name  TEXT
    ,created_date DATE
    );

CREATE TABLE results_data_numeric
    (id              INTEGER PRIMARY KEY AUTOINCREMENT
    ,result_id       INTEGER
    ,result_row      INTEGER
    ,result_field    TEXT      
    ,value           NUMBER
    );

CREATE TABLE results_data_text
    (id              INTEGER PRIMARY KEY AUTOINCREMENT
    ,result_id       INTEGER
    ,result_row      INTEGER
    ,result_field    TEXT      
    ,value           TEXT
    );