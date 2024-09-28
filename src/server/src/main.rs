use std::collections::{HashMap};
use std::path::Path;
use std::error::Error;
use std::fs::File;
use std::io::BufReader;
use std::io::Write;

use actix::prelude::*;
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Clone, Debug)]
#[derive(MessageResponse)]
pub struct Data {
    pub username: String,
    pub password: String,
}

#[derive(Serialize, Deserialize, Clone)]
pub struct Store {
    dict: HashMap<String, Data>,
}

impl Default for Store {
    fn default() -> Store {
        Store {
            dict: HashMap::new(),
        }
    }
}

fn read_from_file<P>(path: P) -> Result<Store, Box<dyn Error>>
where
    P: AsRef<Path>
{
    let file = File::options()
        .read(true)
        .open(path)?;
    let unread_json = BufReader::new(file);

    let read_json = serde_json::from_reader(unread_json)?;

    Ok(read_json)
}

fn unread_to_file<P>(path: P, data: Store) -> Result<Store, Box<dyn Error>>
where
    P: AsRef<Path>
{
    let mut file = File::options()
        .write(true)
        .read(true)
        .create(true)
        .open(path)?;
    let unread_data = serde_json::to_string(&data)?;

    file.write_all(unread_data.as_bytes());

    Ok(data)
}

impl Actor for Store {
    type Context = Context<Self>;

    fn started(&mut self, _: &mut Context<Self>) {
        if let Ok(recovered_store) = read_from_file("db.json") {
            self.dict = recovered_store.dict;
        }
    }
}

#[derive(Message)]
#[rtype(Data)]
pub struct Get {
    pub key: String,
}

impl Handler<Get> for Store {
    type Result = Data;

    fn handle(&mut self, msg: Get, _: &mut Context<Self>) -> Self::Result {
        self.dict.get(&msg.key).unwrap().clone()
    }
}

#[derive(Message)]
#[rtype(result = "()")]
pub struct Put {
    pub key: String,
    pub value: Data
}

impl Handler<Put> for Store {
    type Result = ();

    fn handle(&mut self, msg: Put, _: &mut Context<Self>) {
        self.dict.insert(msg.key,msg.value);
        unread_to_file("db.json", self.clone());
    }
}

#[actix::main]
async fn main() {
    let addr = Store::start(Store::default());
    // let res1 = addr.send(Put {
    //     key: "foo".to_string(),
    //     value: Data {
    //         username: "abc".to_string(),
    //         password: "123".to_string(),
    //     },
    // }).await;

    let res = addr.send(Get {
        key: "foo".to_string(),
    }).await;

    match res {
        Ok(result) => println!("{result:?}"),
        _ => println!("Communication to the actor has failed"),
    };

}
