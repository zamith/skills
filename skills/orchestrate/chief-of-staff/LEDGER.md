# Ledger format

The ledger directory (from the brief's Setup section) contains three files.

## now.md: the live board (rewritten, under 80 lines)

```
# <slug> — updated <YYYY-MM-DD HH:MM>
Chief session: <name from ListAgents>

## Queue
- [Q3] <worker>: push branch to open PR? a) push b) hold. Rec: a

## Streams
### <stream name>
| worker | id | status | PR | last |
| <worker> | 3f9a | needs-decision | #123 | 10-07 waiting Q3 |

## Next
- <work the user has mentioned but not yet dispatched>
```

When a queue item is answered, remove it from `now.md` and log the answer.

## log.md: append-only, one line per event

```
2026-10-07 14:02 spawn <worker> (3f9a) — <task>
2026-10-07 15:40 Q3 answered a → relayed
2026-10-07 16:10 learned → brief: <fact>
```

## decisions.md: user decisions that outlive a ticket

Append each with its date and the reason given. Before queuing a new question, check this file so you never ask the same thing twice.
