## Starting (Host)

```vim
:InstantStartServer 0.0.0.0 8080
:InstantStartSession
```

Share your IP with your pair: `hostname -I`

## Joining (Guest)

```vim
:InstantJoinSession 192.168.x.x 8080
```

## Stopping

```vim
:InstantStop
```

---

## Good Practices

**Before starting** — both open the same project root so relative paths match. If one person has a file open that the other doesn't, the buffer will sync content but won't auto-create the file on disk.

**Driver/Navigator** — decide who drives (types) and who navigates (reviews, directs). Swap every 20–30 min. Having two people typing everywhere at once gets chaotic fast.

**Use tmux splits** — keep a terminal pane open beside nvim for running tests, builds, and git commands. The person not driving can run `go test ./...` or check errors without interrupting the driver's flow.

**Communicate constantly** — say out loud before you move someone's cursor or make an edit in their area. instant.nvim has no concept of "requesting control", anyone can edit anything at any time.

**Keep sessions short** — 90 min max before a break. Pair programming is mentally intensive, especially when both cursors are moving.

**Stop and restart if things go out of sync** — if edits start appearing in the wrong place, `:InstantStop` on both sides and rejoin. Don't try to manually reconcile.

---

| Key | Action |
|---|---|
| `<leader>is` | Start server + session (prompts for port) |
| `<leader>ij` | Join a session (prompts for IP + port) |
| `<leader>ix` | Stop session |
| `<leader>ii` | Print your IP (to share with pair) |
