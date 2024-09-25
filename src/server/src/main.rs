use bastion::prelude::*;
use ntex::http::StatusCode;
use ntex::web::{App, HttpRequest, HttpResponse, HttpServer, Responder};
use std::collections::HashMap;
use std::sync::{Arc, Mutex};
use ntex::web;
use serde::{Deserialize, Serialize};

// user
#[derive(Deserialize, Serialize, Clone)]
struct User
{
    username: String,
    password: String,
    email: Option<String>,
    age: Option<u32>,
    gender: Option<String>,
}

// sessionId -> child process reference
//type SessionMap = Arc<Mutex<HashMap<String, ChildrenRef>>>; //when bastion is implemented
type SessionMap = Mutex<HashMap<String, String>>;
// username -> User
type UserMap = Mutex<HashMap<String, User>>;

struct Store {
    session_map: SessionMap,
    user_map: UserMap,
}

//not for demo
fn spawn_user_session(username: String) -> ChildrenRef
{
    Bastion::children(|children|
    {
        children.with_exec(move |ctx|
        {
            let username_clone = username.clone();
            async move
            {
                loop
                {
                    // user handlers
                    if let Ok(msg) = ctx.recv().await
                    {
                        // TODO
                    }
                }
                Ok(())
            }
        })
    })
    .expect("Failed to spawn user session")
}
//not for demo
fn spawn_game_process() -> ChildrenRef
{
    Bastion::children(|children|
    {
        children.with_exec(|ctx|
            {
            async move
            {
                loop
                {
                    // game handlers
                    if let Ok(msg) = ctx.recv().await
                    {
                        // TODO
                    }
                }
                Ok(())
            }
        })
    })
    .expect("Failed to spawn game process")
}

async fn post_user_handler(
    body: web::types::Json<User>,
    path: web::types::Path<(String,)>,
    store: web::types::State<Arc<Store>>) -> impl Responder
{
    let new_user = body.into_inner();
    let (username,) = path.into_inner();
    let mut map = store.user_map.lock().unwrap();

    if map.contains_key(&username) {
        return HttpResponse::BadRequest().body("User already exists.");
    } else {
        map.insert(username.clone(), new_user);
        return HttpResponse::Ok().body("User successfully created.")
    }
}

async fn get_user_handler(
    req: HttpRequest,
    path: web::types::Path<(String,)>,
    store: web::types::State<Arc<Store>>,) -> impl Responder
{
    let (username,) = path.into_inner();
    let session_id = req.headers().get("SessionID").and_then(|val| val.to_str().ok()).unwrap();

    let user_map = store.user_map.lock().unwrap();
    let session_map = store.session_map.lock().unwrap();


    if let (Some(user), Some(sess_user)) = (user_map.get(&username), session_map.get(session_id)) {
        if sess_user == &username {
            // if current session matches. then return full data
            println!("Session ID matched for user {}", username);
            return HttpResponse::Ok().json(user);
        } else {
            // else return public data
            let public_data = User {
                username: user.username.clone(),
                password: String::from("***"),
                age: user.age.clone(),
                email: user.email.clone(),
                gender: user.gender.clone()
            };
            return HttpResponse::Ok().json(&public_data)
        }
    } else {
        return HttpResponse::BadRequest().body("User does not exist.")
    }
}

async fn put_user_handler(
    req: HttpRequest,
    path: web::types::Path<(String,)>,
    update_value: web::types::Json<String>,
    store: web::types::State<Arc<Store>>,) -> impl Responder
{
    let (username,) = path.into_inner();
    let session_id = req.headers().get("SessionID").and_then(|val| val.to_str().ok());

    let session_map = store.session_map.lock().unwrap();
    let mut user_map = store.user_map.lock().unwrap();

    if let (Some(user), Some(sess_user)) = (user_map.get_mut(&username), session_id.and_then(|sid| session_map.get(sid))) {
        if sess_user == &username {
            user.password = update_value.into_inner(); //whatever we want update to do, just pw rn
            return HttpResponse::Ok().json(user);
        } else {
            return HttpResponse::Unauthorized().body("Incorrect sessionId for user.");
        }
    } else {
        return HttpResponse::BadRequest().body("User does not exist");
    }
}

async fn post_user_login_handler(
    body: web::types::Json<User>,
    path: web::types::Path<(String,)>,
    store: web::types::State<Arc<Store>>,) -> impl Responder
{
    let login_user = body.into_inner();
    let (username,) = path.into_inner();
    let map = store.user_map.lock().unwrap();

    if let Some(user) = map.get(&username)
    {
        if user.password == login_user.password
        {
            let session_id = format!("session-{}", username); //will revamp session ID generation to be better when

            let mut session_map = store.session_map.lock().unwrap();
            session_map.insert(session_id.clone(), username.clone());
            return HttpResponse::Ok().json(&session_id); //returns id token
        } else {
            return HttpResponse::BadRequest().body("Invalid password.")
        }
    } else {
        return HttpResponse::BadRequest().body("Invalid username.")
    }
}

async fn post_user_logout_handler(
    body: web::types::Json<String>,
    store: web::types::State<Arc<Store>>,) -> impl Responder
{
    let session_id = body.into_inner();
    let mut session_map = store.session_map.lock().unwrap();

    if session_map.remove(&session_id).is_some() {
        return HttpResponse::Ok().body("User successfully logged out.")
    } else {
        return HttpResponse::BadRequest().body("Invalid sessionId.")
    }
}

#[ntex::main]
async fn main() -> std::io::Result<()>
{
    Bastion::init();
    Bastion::start();

    let store = Arc::new(Store {
        user_map: Mutex::new(HashMap::new()),
        session_map: Mutex::new(HashMap::new()),
    });

    //hardcoded test user
    {
        let mut users = store.user_map.lock().unwrap();
        users.insert(
            "user1".to_string(),
            User
            {
                username: "user".to_string(),
                password: "password".to_string(),
                age: None,
                email: None,
                gender: None
            },
        );
    }

    HttpServer::new(move ||
    {
         // cloning arc to share it // shared ownership rust closure bs, but it doesnt error anymore
        let store_clone = store.clone();

        App::new()
            .state(store_clone)
            .service(
                web::resource("/users/{username}")
                    .route(web::post().to(post_user_handler))
                    .route(web::get().to(get_user_handler))
                    .route(web::put().to(put_user_handler))
            )
            .service(
                web::resource("/users/{username}/login")
                    .route(web::post().to(post_user_login_handler))
            )
            .service(
                web::resource("/users/{username}/logout")
                    .route(web::post().to(post_user_logout_handler))
            )
    })
    .bind("127.0.0.1:8080")?
    .run()
    .await?;

    Bastion::stop();
    Ok(())
}
