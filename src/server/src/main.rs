mod actors;
use crate::actors::db;

fn main () {
    let mut db = db::Actor::new("app.db");

    // db.insert("foo", "bar");
    // db.dump();
    db.undump();

    println!("{:?}", db);
}
