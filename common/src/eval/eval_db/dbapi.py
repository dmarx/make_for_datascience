import sqlite3

class DbAPI(object):
    def __init__(self, db_name='data/modeling_results.db'):
        self.db_name = db_name
        self.init_db()
        
    def init_db(self):
        self.conn = sqlite3.connect(self.db_name)
        c=self.conn.cursor()
        try:
            c.execute('SELECT 1 FROM experiments')
        except:
            with open('src/eval/eval_db/schema.sql') as f:
                c.executescript(f.read())
        c.close()
        
if __name__ == "__main__":
    DbAPI().init_db()