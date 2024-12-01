import pog
import gleam/io
import app/sql
import app/models/item.{type Item, create_item}
import app/web.{type Context, Context}
import gleam/json
import gleam/list
import gleam/result
import gleam/string
import gleam/option.{Some, None, unwrap}
import wisp.{type Request, type Response}


pub fn items_middleware(
  _req: Request,
  ctx: Context,
  handle_request: fn(Context) -> Response,
) {
  let db_result = {
    case sql.list_items(ctx.db) {
      Ok(items) -> {
        io.debug(items)
        items
      }
      Error(_) -> pog.Returned(0,[])
    }
  }
  let pog.Returned(_count, db_items) = db_result

  let items = create_items_from_db(db_items)

  let ctx = Context(..ctx, items: items)

  handle_request(ctx)
}

fn create_items_from_db(items: List(sql.ListItemsRow)) -> List(Item) {
  items
  |> list.map(fn(item) {
    let sql.ListItemsRow(id, title, completed, _,_) = item
    create_item(Some(id), title, unwrap(completed, False))
  })
}

fn todos_to_json(items: List(Item)) -> String {
  "["
  <> items
  |> list.map(item_to_json)
  |> string.join(",")
  <> "]"
}

fn item_to_json(item: Item) -> String {
  json.object([
    #("id", json.string(item.id)),
    #("title", json.string(item.title)),
    #("completed", json.bool(item.item_status_to_bool(item.status))),
  ])
  |> json.to_string
}

// Create new items via post
pub fn post_create_item(req: Request, ctx: Context) {
  use form <- wisp.require_form(req)

  let current_items = ctx.items

  let result = {
    use item_title <- result.try(list.key_find(form.values, "todo_title"))
    let new_item = create_item(None, item_title, False)
    let _create_result = sql.create_item(ctx.db, new_item.id, new_item.title, item.item_status_to_bool(new_item.status))
    list.append(current_items, [new_item])
    |> todos_to_json
    |> Ok
  }

  case result {
    Ok(todos) -> {
      wisp.redirect("/")
      |> wisp.set_cookie(req, "items", todos, wisp.PlainText, 60 * 60 * 24)
    }
    Error(_) -> {
      wisp.bad_request()
    }
  }
}

//Delete entire item from datastore
pub fn delete_item(_req: Request, ctx: Context, item_id: String) {
  let _result = sql.delete_item(ctx.db, item_id)

  wisp.redirect("/")
}

pub fn patch_toggle_todo(_req: Request, ctx: Context, item_id: String) {
  let current_items = ctx.items
  let result = {
    use item <- result.try(
      list.find(current_items, fn(item) { item.id == item_id }),
    )
    let _query_result = sql.update_item_completion(ctx.db, item_id, !item.item_status_to_bool(item.status))
    |> Ok
  }

  case result {
    Ok(_) ->
      wisp.redirect("/")
    Error(_) -> wisp.bad_request()
  }
}
