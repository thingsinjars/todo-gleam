import gleam/option.{Some}
import gleam/erlang/process
import mist
import wisp
import wisp/wisp_mist
import pog

import app/router
import app/web.{Context}
import dot_env
import dot_env/env

pub fn main() {
  wisp.configure_logger()

  dot_env.new()
  |> dot_env.set_path(".env")
  |> dot_env.set_debug(False)
  |> dot_env.load

  // Start a database connection pool.
  // Typically you will want to create one pool for use in your program
  let db =
    pog.default_config()
    |> pog.host("localhost")
    |> pog.user("postgres")
    |> pog.password(Some("postgres"))
    |> pog.database("postgres")
    |> pog.pool_size(15)
    |> pog.connect

  let assert Ok(secret_key_base) = env.get_string("SECRET_KEY_BASE")

  let ctx = Context(static_directory: static_directory(), items: [], db: db)

  let handler = router.handle_request(_, ctx)

  let assert Ok(_) =
    wisp_mist.handler(handler, secret_key_base)
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http
  process.sleep_forever()
}

fn static_directory() {
  let assert Ok(priv_directory) = wisp.priv_directory("dash")
  priv_directory <> "/static"
}