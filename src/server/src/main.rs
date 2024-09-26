use bastion::prelude::*;
use ntex::web;
use ntex::web::{App, HttpRequest, HttpResponse, HttpServer, Responder};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::sync::{Arc, Mutex};
use uuid::Uuid;

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
type SessionMap = Arc<Mutex<HashMap<String, ChildRef>>>;
// username -> User
type UserMap = Arc<Mutex<HashMap<String, User>>>;

fn spawn_user_session(username: String) -> ChildRef
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
                    let msg = ctx.recv().await?;
                    if let Ok(task) = msg.downcast::<String>()
                    {
                        println!("Session for {} doing: {}", username_clone, task);
                    }
                    ctx.reply(format!("done {}", username_clone)).unwrap();
                }
                Ok(())
            }
        })
    })
    .expect("Failed to spawn user session")
}

async fn pos_user_handler(
    body: web::types::Json<User>,
    path: web::types::Path<(String,)>,
    user_map: web::types::Data<UserMap>,) -> impl Responder
{
    let new_user = body.into_inner();
    let (username,) = path.into_inner();
    let mut map = user_map.lock().unwrap();

    if map.contains_key(&username) {
        return HttpResponse::build(418).body("User already exists.");
    } else {
        map.insert(username.clone(), new_user);
        return HttpResponse::Ok().body("User successfully created.")
    }
}

async fn get_user_handler(
    req: HttpRequest,
    path: web::types::Path<(String,)>,
    user_map: web::types::Data<UserMap>,
    session_map: web::types::Data<SessionMap>,) -> impl Responder
{
    let (username,) = path.into_inner();
    let session_id = req.headers().get("SessionID").and_then(|val| val.to_str().ok());

    let user_map = user_map.lock().unwrap();
    let session_map = session_map.lock().unwrap();

    if let Some(user, session_id) = (user_map.get(&username), session_id) {
        if let Some(sess_user) = session_map.get(session_id) {
            // if current session matches. then return full data
            println!("Session ID matched for user {}", username);
            return HttpResponse::Ok().json(user);
        } else {
            // else return public data
            let public_data = User {
                username: user.username.clone(),
                password: String::from("***"),
            };
            return HttpResponse::Ok().json(public_data)
        }
    } else {
        return HttpResponse::build(403).body("User does not exist.")
    }
}

async fn put_user_handler(
    req: HttpRequest,
    path: web::types::Path<(String,)>,
    update_value: web::types::Json<String>,
    user_map: web::types::Data<UserMap>,
    session_map: web::types::Data<SessionMap>,) -> impl Responder
{
    let (username,) = path.into_inner();
    let session_id = req.headers().get("SessionID").and_then(|val| val.to_str().ok());

    let session_map = session_map.lock().unwrap();
    let mut user_map = user_map.lock().unwrap();

    if let (Some(user), Some(sess_user)) = (user_map.get_mut(&username), session_id.and_then(|sid| session_map.get(sid))) {
        user.password = update_value.into_inner(); //whatever we want update to do, just pw rn
        return HttpResponse::Ok().json(user);
    } else {
        return HttpResponse::build(403).body("Incorrect sessionId for user.")
    }
}

async fn post_user_login_handler(
    body: web::types::Json<User>,
    path: web::types::Path<(String,)>,
    user_map: web::types::Data<UserMap>,
    session_map: web::types::Data<SessionMap>,) -> impl Responder
{
    let login_user = body.into_inner();
    let (username,) = path.into_inner();
    let map = user_map.lock().unwrap();

    if let Some(user) = map.get(&username)
    {
        if user.password == login_user.password
        {
            // generate new session ID -> spawns a child process for the user session -> stores the session ID and child pid
            let session_id = Uuid::new_v4().to_string();
            let session_process = spawn_user_session(username.clone());
            let mut session_map = session_map.lock().unwrap();
            session_map.insert(session_id.clone(), session_process);
            return HttpResponse::Ok().json(session_id); //returns id token
        } else {
            return HttpResponse::BadRequest().body("Invalid password.")
        }
    } else {
        return HttpResponse::BadRequest().body("Invalid username.")
    }
}

async fn post_user_logout_handler(
    body: web::types::Json<String>,
    path: web::types::Path<(String,)>,
    session_map: web::types::Data<SessionMap>,) -> impl Responder
{
    let session_id = body.into_inner();
    let (username,) = path.into_inner();
    let mut session_map = session_map.lock().unwrap();

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

    // sharing state
    let user_map = web::types::Data::new(Arc::new(Mutex::new(HashMap::new())));
    let session_map = web::types::Data::new(Arc::new(Mutex::new(HashMap::new())));

    //hardcoded test user
    {
        let mut users = user_map.lock().unwrap();
        users.insert(
            "user1".to_string(),
            User {
                username: "user".to_string(),
                password: "password".to_string(),
            },
        );
    }

    HttpServer::new(move ||
    {
        App::new()
            .app_data(user_map.clone())
            .app_data(session_map.clone())
            .service(
                web::resource("/users/{username}")
                    .route(web::post().to(pos_user_handler))
                    .route(web::get().to(get_user_handler))
                    .route(web::put().to(put_user_handler))
            )
            .service(
                web::resource("/users/{username}/login")
                    .route(web::post().to(post_user_login_handler))
            )
            .service(
                web::resource("/users/{username}/logout")
                    .route(web::post().to())
            )
    })
    .bind("127.0.0.1:8080")?
    .run()
    .await?;

    Bastion::stop();
    Ok(())
}
