# Direction Guesser

An interactive, cross-platform, phone application to gather
geo-spatial reasoning ability.

## Installation

This project uses a server-client architecture, where the server and
client are written using different technologies.

To build the server, download and install [Rust +
Cargo](https://doc.rust-lang.org/cargo/getting-started/installation.html).

To build the (mobile) client, download and install the
[Flutter](https://docs.flutter.dev/get-started/install) SDK.

Invoke [MAKE(1)](https://man.netbsd.org/make.1) to produce binaries
for both. If building for release, invoke
[MAKE(1)](https://man.netbsd.org/make.1) with `RELEASE=1`.

The resulting binaries will be located under the `.build/` directory.

## Contributing

Pull requests are welcome. For major changes, please open an issue first
to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License

[AGPLv3](https://choosealicense.com/licenses/agpl-3.0/)
