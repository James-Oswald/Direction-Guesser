use std::collections::HashMap;

use actix::prelude::{Context, Message, Handler, Addr, ResponseActFuture, Actor};
use actix::{ActorFutureExt, WrapFuture};
use serde::{Serialize, Deserialize};

use crate::db;
use crate::actors::DB_ADDR;


pub struct Supervisor {
    sid_map: HashMap<String, Addr<Child>>,
}

impl actix::Actor for Supervisor {
    type Context = Context<Self>;
}

impl Supervisor {
    pub fn new() -> Self {
        return Supervisor {
            sid_map: HashMap::new(),
        };
    }
}

#[derive(Message, Clone)]
#[rtype("Option<Addr<Child>>")]
pub struct Restore {
    pub username: String,
    pub password: String,
}

impl Handler<Restore> for Supervisor {
    type Result = ResponseActFuture<Self, Option<Addr<Child>>>;

    fn handle(&mut self, msg: Restore, _ctx: &mut Context<Self>) -> Self::Result {
        // NOTE: hahaha, i need to do this call send a message inside
        // of a handler? insanity! -ak
        let msg_1 = msg.clone();
        let msg_2 = msg.clone();
        Box::pin(async {
            let Restore { username, password } = msg_1;

            DB_ADDR.send(db::Get(username)).await
        }.into_actor(self).map(|res, _act, _ctx| {
            let Restore { username, password } = msg_2;

            if let Ok(Some(unread_user)) = res {
                let user: Child = serde_json::from_str(unread_user.as_str()).unwrap();

                if user.password == password {
                    // it's us! let us in!
                    if let Some(addr) = _act.sid_map.get(&username) {
                        return Some(addr.clone());
                    } else {
                        let addr = user.start();
                        _act.sid_map.insert(username, addr.clone());
                        return Some(addr.clone());
                    }
                } else {
                    // invalid password
                    return None;
                }
            } else {
                // invalid username
                return None;
            }
        }))
    }
}

#[derive(Message)]
#[rtype("Option<Child>")]
pub struct New {
    pub username: String,
    pub password: String,
    pub email:  Option<String>,
    pub age:    Option<u32>,
    pub gender: Option<String>,
}

#[derive(Deserialize, Serialize, Debug)]
pub struct Child {
    username: String,
    password: String,
    email:  Option<String>,
    age:    Option<u32>,
    gender: Option<String>,
}

impl actix::Actor for Child {
    type Context = Context<Self>;
}

impl actix::Supervised for Child {
    fn restarting(&mut self, _ctx: &mut Context<Self>) {
        println!("restarting");
    }
}

