# GitHub API recipes

Command recipes for `address-pr-comments`. `OWNER`/`REPO` come from the target repo; `NUM` is a PR number.

## Setup values

```bash
ME=$(gh api user -q .login)                    # your login — for the "is this comment mine?" check
gh repo view --json owner,name -q '.owner.login + "/" + .name'   # OWNER/REPO of current repo
```

## Scope: your open, non-draft PRs

```bash
gh pr list --author @me --state open \
  --json number,isDraft,headRefName,title \
  -q '.[] | select(.isDraft==false)'
# add: --repo OWNER/REPO  to target a specific project
```

## Inline review threads (primary source)

```bash
gh api graphql -F owner=OWNER -F repo=REPO -F pr=NUM -f query='
query($owner:String!,$repo:String!,$pr:Int!){
  repository(owner:$owner,name:$repo){
    pullRequest(number:$pr){
      reviewThreads(first:100){ nodes{
        isResolved
        comments(first:100){ nodes{ databaseId author{login} body path line diffHunk } }
      }}
    }
  }
}'
```

- A thread is **unaddressed** when the *last* node in `comments.nodes` has `author.login != ME`.
- Reply to a thread using the **first** comment's `databaseId` (see below).
- `isResolved` is informational only — you do not resolve threads.

## Review summaries and general PR comments

```bash
# Review summary bodies (a review submitted with a body, no inline anchor)
gh api repos/OWNER/REPO/pulls/NUM/reviews -q '.[] | {id, user: .user.login, state, body}'

# General (non-inline) PR conversation comments
gh api repos/OWNER/REPO/issues/NUM/comments -q '.[] | {id, user: .user.login, body}'
```

Same rule: unaddressed when the latest one isn't yours.

## Replying (leave threads open — never resolve)

```bash
# Reply inside an inline review thread — COMMENT_ID = first comment's databaseId
gh api --method POST repos/OWNER/REPO/pulls/NUM/comments/COMMENT_ID/replies -f body='...'

# Reply to a general PR comment (posts a new conversation comment)
gh api --method POST repos/OWNER/REPO/issues/NUM/comments -f body='...'
```

## Checkout / push

```bash
gh pr checkout NUM        # switch to the PR branch
git push                  # add commits only — never --force, never rebase/amend
```
