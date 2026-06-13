## __Status:__ Accepted

## __Contect:__ Need to quickly impement ETL piepine MVP for notification logic.

## __Decision:__ Using n8n with a buit-in SQLite database.

## __Consequences (Positive):__ Lightning-fast start, no additional container (PostgreSQL), minimal memory consumption (FinOps).

## __Consequences (Negative):__ More difficult to scale if moving to a multi-node model in the future.
