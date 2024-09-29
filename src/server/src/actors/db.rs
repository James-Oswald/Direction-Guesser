use std::collections::BTreeMap;
use std::error::Error;
use std::fs::File;
use std::io::BufReader;
use std::io::Write;

use serde::Serialize;
use tempfile::NamedTempFile;

/* NOTE: this cannot be a borrowed type (i.e. ``&'a str'') because
 * when we are undumping the DB, somebody somewhere has to own the
 * ``str'' to begin with -ak */
type PK = String;
type V  = String;

#[derive(Debug)]
pub struct Actor {
    dump_pathname: &'static str,
    rows: BTreeMap<PK, V>
}

impl Actor {
    pub fn new(dump_pathname: &'static str) -> Self {
        let mut new = Self {
            dump_pathname,
            rows: BTreeMap::new(),
        };
        new.undump();

        return new;
    }

    pub fn insert(&mut self, key: impl ToString, value: impl ToString) -> Option<V> {
        let result =
            self.rows.insert(key.to_string(), value.to_string());
        self.dump();

        return result;
    }

    pub fn get(&mut self, key: &PK) -> Option<&V> {
        return self.rows.get(key);
    }

    pub fn dump(&self) -> Result<(), Box<dyn Error>> {
        let mut atomic_file =
            NamedTempFile::new()?;
        let unread_data =
            serde_json::to_string(&self.rows)?;

        write!(atomic_file, "{}", unread_data)?;
        atomic_file.persist(self.dump_pathname)?;

        return Ok(());
    }

    pub fn undump(&mut self) -> Result<(), Box<dyn Error>> {
        /* NOTE: we cannot use ``serde_json::from_str'' because
         * obviously &str cannot leave it's defining scope here -ak */
        let unread_rows =
            BufReader::new(File::open(self.dump_pathname)?);
        let read_rows: BTreeMap<PK, V> =
            serde_json::from_reader(unread_rows)?;

        self.rows = read_rows;

        return Ok(());
    }
}
