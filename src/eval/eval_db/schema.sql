CREATE TABLE experiments
    (id                INTEGER PRIMARY KEY AUTOINCREMENT
    ,model_name        TEXT
    ,commit_id         TEXT
    ,created_date      DATE
    ,last_updated_date DATE
    );
    
CREATE TABLE results
    (id          INTEGER PRIMARY KEY AUTOINCREMENT,
    ,exp_id      INTEGER
    ,result_name TEXT
    );

CREATE TABLE results_data 
    (id              INTEGER PRIMARY KEY AUTOINCREMENT,
    ,result_id       INTEGER
    ,field_id        INTEGER
    ,field_value_txt TEXT
    ,field_value_nmr NUMBER
    );
