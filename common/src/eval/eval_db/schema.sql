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
    
CREATE TABLE datasets
    (id              INTEGER PRIMARY KEY AUTOINCREMENT
    ,name            TEXT
    ,fpath           TEXT -- thought about adding a task field, but this should capture it
    ,description     TEXT
    ,created_date    DATE
    );
    
CREATE TABLE fields
    (id              INTEGER PRIMARY KEY AUTOINCREMENT
    ,dataset_id      INTEGER
    ,field_name      TEXT
    ,field_type      TEXT
    ,created_date    DATE
    );

CREATE TABLE field_stats
    (id           INTEGER PRIMARY KEY AUTOINCREMENT
    ,field_id     INT
    ,stat_name    TEXT
    ,stat_value   INT
    ,created_date DATE
    );

-- This is just for capturing the "table" attribute of the
-- data profiling report
CREATE TABLE field_values_table
    (id           INTEGER PRIMARY KEY AUTOINCREMENT
    ,field_id     INT
    ,value        TEXT
    ,freq         INT
    ,created_date DATE
    );

-- this is probably redundant, I think any flags will (could) get added as field values
CREATE TABLE field_flags
    (id           INTEGER PRIMARY KEY AUTOINCREMENT
    ,field_id     INT
    ,flag         TEXT
    ,created_date DATE
    );