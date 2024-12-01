# ToDo Db

An DB-backed version of:

[https://gleaming.dev/articles/building-your-first-gleam-web-app/](https://gleaming.dev/articles/building-your-first-gleam-web-app/)

[![Package Version](https://img.shields.io/hexpm/v/dash)](https://hex.pm/packages/dash)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/dash/)

```sh
gleam add dash@1
```

```gleam
import dash

pub fn main() {
  // TODO: An example of the project in use
}
```

Further documentation can be found at <https://hexdocs.pm/dash>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```

## SQL

```
CREATE TABLE items (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_items_updated_at
BEFORE UPDATE ON items
FOR EACH ROW
EXECUTE FUNCTION update_updated_at();
```
