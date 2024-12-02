# Direction Guesser

An interactive, cross-platform, phone application to gather
geo-spatial reasoning ability.

## Installation

This project uses a server-client architecture, where the server and
client are written using different technologies.

To build the server, first download and install
[Elixir](https://elixir-lang.org/install.html). Now run the following
to setup sqlite:

```
$ cd src/server/

$ mix ecto.migrate

06:59:18.803 [info] == Running 20241001140627 App.DB.Migrations.CreateUsers.change/0 forward

06:59:18.804 [info] create table users

06:59:18.805 [info] == Migrated 20241001140627 in 0.0s

```

Now the server can be ran locally on your machine by:

```
$ iex -S mix run
...
```

To build the (mobile) client, download and install the
[Flutter](https://docs.flutter.dev/get-started/install) SDK.

<!-- Invoke [MAKE(1)](https://man.netbsd.org/make.1) to produce binaries -->
<!-- for both. If building for release, invoke -->
<!-- [MAKE(1)](https://man.netbsd.org/make.1) with `RELEASE=1`. -->

<!-- The resulting binaries will be located under the `.build/` directory. -->

## Contributing

Pull requests are welcome. For major changes, please open an issue first
to discuss what you would like to change.

Please make sure to update tests as appropriate.
