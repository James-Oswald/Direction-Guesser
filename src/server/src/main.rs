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
type SessionMap = Arc<Mutex<HashMap<String, String>>>; 
// username -> User
type UserMap = Arc<Mutex<HashMap<String, User>>>;

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

async fn create_user_handler(
    body: web::types::Json<User>,
    path: web::types::Path<(String,)>,
    user_map: web::types::State<UserMap>,) -> impl Responder 
{
    let new_user = body.into_inner();
    let (username,) = path.into_inner();
    let mut map = user_map.lock().unwrap();

    if map.contains_key(&username) 
    {
        return HttpResponse::BadRequest().body("User already exists.");
    }

    map.insert(username.clone(), new_user);
    HttpResponse::Ok().body("User successfully created.")
}

async fn get_user_handler(
    req: HttpRequest,
    path: web::types::Path<(String,)>,
    user_map: web::types::State<UserMap>,
    session_map: web::types::State<SessionMap>,) -> impl Responder 
{
    let (username,) = path.into_inner();
    let session_id = req.headers().get("SessionID").and_then(|val| val.to_str().ok());
    let user_map = user_map.lock().unwrap();

    if let Some(user) = user_map.get(&username) 
    {
        if let Some(session_id) = session_id
        {
            let session_map = session_map.lock().unwrap();
            if let Some(sess_user) = session_map.get(session_id) 
            {// if current session matches. then return full data
                if sess_user == &username 
                {
                    println!("Session ID matched for user {}", username);
                    return HttpResponse::Ok().json(user);
                }
            } 
        }
        // else return public data 
        let public_data = User 
        {
            username: user.username.clone(),
            password: String::from("***"), 
            age: user.age.clone(),
            email: user.email.clone(),
            gender: user.gender.clone()
        };
        HttpResponse::Ok().json(&public_data)
    } else 
    {
        HttpResponse::BadRequest().body("User does not exist.")
    }
}

async fn update_user_handler(
    req: HttpRequest,
    path: web::types::Path<(String,)>,
    update_value: web::types::Json<String>,
    user_map: web::types::State<UserMap>,
    session_map: web::types::State<SessionMap>,) -> impl Responder 
{
    let (username,) = path.into_inner();
    let session_id = req.headers().get("SessionID").and_then(|val| val.to_str().ok());
    let session_map = session_map.lock().unwrap();

    if let Some(sess_user) = session_id.and_then(|sid| session_map.get(sid)) 
    {
        if sess_user == &username
        {
            let mut user_map = user_map.lock().unwrap();
            if let Some(user) = user_map.get_mut(&username) 
            {
                user.password = update_value.into_inner(); //whatever we want update to do, just pw rn
                return HttpResponse::Ok().json(user); 
            }
        }
    }
    HttpResponse::Unauthorized().body("Incorrect sessionId for user.")
}

async fn login_user_handler(
    body: web::types::Json<User>,
    path: web::types::Path<(String,)>,
    user_map: web::types::State<UserMap>,
    session_map: web::types::State<SessionMap>,) -> impl Responder 
{
    let login_user = body.into_inner();
    let (username,) = path.into_inner();
    let map = user_map.lock().unwrap();

    if let Some(user) = map.get(&username) 
    {
        if user.password == login_user.password 
        {
            let session_id = format!("session-{}", username); //will revamp session ID generation to be better when 

            let mut session_map = session_map.lock().unwrap();
            session_map.insert(session_id.clone(), username.clone());

            // 5. Return the session ID as the token to the client
            return HttpResponse::Ok().json(&session_id);
        }
    }
    HttpResponse::BadRequest().body("Invalid username/password combination.")
}

async fn logout_user_handler(
    body: web::types::Json<String>,
    session_map: web::types::State<SessionMap>,) -> impl Responder 
{
    let session_id = body.into_inner();
    let mut session_map = session_map.lock().unwrap();

    if session_map.remove(&session_id).is_some() 
    {
        HttpResponse::Ok().body("User successfully logged out.")
    } else 
    {
        HttpResponse::BadRequest().body("Invalid sessionId.")
    }
}

#[ntex::main]
async fn main() -> std::io::Result<()> 
{
    Bastion::init();
    Bastion::start();

   
    let user_map: Arc<Mutex<HashMap<String, User>>> = Arc::new(Mutex::new(HashMap::new()));
    let session_map: Arc<Mutex<HashMap<String, ChildrenRef>>> = Arc::new(Mutex::new(HashMap::new()));

    //hardcoded test user
    {
        let mut users = user_map.lock().unwrap();
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
        let user_map_clone = user_map.clone();     
        let session_map_clone = session_map.clone();

        App::new()
            .state(user_map_clone)
            .state(session_map_clone)
            .service(
                web::resource("/users/{username}")
                    .route(web::post().to(create_user_handler)) // Create user
                    .route(web::get().to(get_user_handler)) // Get user
                    .route(web::put().to(update_user_handler)) // Update user
            )
            .service(
                web::resource("/users/{username}/login")
                    .route(web::post().to(login_user_handler)) // Login user
            )
            .service(
                web::resource("/users/{username}/logout")
                    .route(web::post().to(logout_user_handler)) // Logout user
            )
    })
    .bind("127.0.0.1:8080")?
    .run()
    .await?;

    Bastion::stop();
    Ok(())
}
