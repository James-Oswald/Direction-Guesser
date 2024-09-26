use native_db::{native_db, ToKey};
use native_model::{native_model, Model};
use serde::{Deserialize, Serialize};

pub type Item = v1::Item;
pub type ItemKey = v1::ItemKey;

pub mod v1 {
    use super::*;

    #[derive(Serialize, Deserialize, PartialEq, Debug)]
    #[native_model(id = 1, version = 1)]
    #[native_db]
    pub struct Item {
        #[primary_key]
        pub id: u32,
        #[secondary_key]
        pub name: String,
    }
}
