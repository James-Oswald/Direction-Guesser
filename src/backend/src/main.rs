use ntex::web;

#[web::get("/")]
async fn index() -> impl web::Responder {
    "Hello, World!"
}

#[web::get("/{name}")]
async fn hello(name: web::types::Path<String>) -> impl web::Responder {
    web::HttpResponse::Ok()
        .content_type("text/plain")
        //THIS IS FOR THE DEMO, DO NOT DO THIS IN PRODUCTION GET RID OF THIS SOON
        .set_header(ntex::http::header::ACCESS_CONTROL_ALLOW_ORIGIN, "*")
        .body(format!("Hello {}!", &name))
}

#[ntex::main]
async fn main() -> std::io::Result<()> {
    web::HttpServer::new(|| web::App::new().service(index).service(hello))
        .bind(("127.0.0.1", 8080))?
        .run()
        .await
}