# LinkFetcher

Simple scraper that searches for all href links in a given domain.

### Technologies
This project was developed using Elixr/Phoenix Liveview and Floki + Crawly as tools to help scrape the pages.

### Setup

> ⚠️ You must have [elixir](https://github.com/asdf-vm/asdf-elixir), [erlang](https://github.com/asdf-vm/asdf-erlang) and [docker compose](https://docs.docker.com/compose/gettingstarted/) installed in order to run this application.

1. Runing the db
`docker compose up -d`

2. Fetching dependencies
`mix deps.get`

3. Running migrations and setting up DB
`mix ecto.setup`

4. Running tests
`mix test`

5. Running the server
`mix phx.server`

**Congratulations! Now you can access the page at http://localhost:4000**

If it is your first time, you'll have to create an account. If it is not, simple click signin and start scraping!
