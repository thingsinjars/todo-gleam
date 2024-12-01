import decode/zero
import gleam/option.{type Option}
import pog

/// Runs the `delete_item` query
/// defined in `./src/app/sql/delete_item.sql`.
///
/// > 🐿️ This function was generated automatically using v2.0.3 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn delete_item(db, arg_1) {
  let decoder = zero.map(zero.dynamic, fn(_) { Nil })

  let query = "delete from
  items
where
  id = $1"

  pog.query(query)
  |> pog.parameter(pog.text(arg_1))
  |> pog.returning(zero.run(_, decoder))
  |> pog.execute(db)
}

/// Runs the `update_item_completion` query
/// defined in `./src/app/sql/update_item_completion.sql`.
///
/// > 🐿️ This function was generated automatically using v2.0.3 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn update_item_completion(db, arg_1, arg_2) {
  let decoder = zero.map(zero.dynamic, fn(_) { Nil })

  let query = "update
  items
set
  completed = $2
where
  id = $1"

  pog.query(query)
  |> pog.parameter(pog.text(arg_1))
  |> pog.parameter(pog.bool(arg_2))
  |> pog.returning(zero.run(_, decoder))
  |> pog.execute(db)
}

/// Runs the `create_item` query
/// defined in `./src/app/sql/create_item.sql`.
///
/// > 🐿️ This function was generated automatically using v2.0.3 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_item(db, arg_1, arg_2, arg_3) {
  let decoder = zero.map(zero.dynamic, fn(_) { Nil })

  let query = "insert into
  items (id, title, completed)
values
  ($1, $2, $3)"

  pog.query(query)
  |> pog.parameter(pog.text(arg_1))
  |> pog.parameter(pog.text(arg_2))
  |> pog.parameter(pog.bool(arg_3))
  |> pog.returning(zero.run(_, decoder))
  |> pog.execute(db)
}

/// A row you get from running the `list_items` query
/// defined in `./src/app/sql/list_items.sql`.
///
/// > 🐿️ This type definition was generated automatically using v2.0.3 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type ListItemsRow {
  ListItemsRow(
    id: String,
    title: String,
    completed: Option(Bool),
    created_at: Option(pog.Timestamp),
    updated_at: Option(pog.Timestamp),
  )
}

/// Runs the `list_items` query
/// defined in `./src/app/sql/list_items.sql`.
///
/// > 🐿️ This function was generated automatically using v2.0.3 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn list_items(db) {
  let decoder = {
    use id <- zero.field(0, zero.string)
    use title <- zero.field(1, zero.string)
    use completed <- zero.field(2, zero.optional(zero.bool))
    use created_at <- zero.field(3, zero.optional(timestamp_decoder()))
    use updated_at <- zero.field(4, zero.optional(timestamp_decoder()))
    zero.success(ListItemsRow(id:, title:, completed:, created_at:, updated_at:),
    )
  }

  let query = "select
  *
from
  items
order by
  updated_at"

  pog.query(query)
  |> pog.returning(zero.run(_, decoder))
  |> pog.execute(db)
}

// --- Encoding/decoding utils -------------------------------------------------

/// A decoder to decode `timestamp`s coming from a Postgres query.
///
fn timestamp_decoder() {
  use dynamic <- zero.then(zero.dynamic)
  case pog.decode_timestamp(dynamic) {
    Ok(timestamp) -> zero.success(timestamp)
    Error(_) -> {
      let date = pog.Date(0, 0, 0)
      let time = pog.Time(0, 0, 0, 0)
      zero.failure(pog.Timestamp(date:, time:), "timestamp")
    }
  }
}
