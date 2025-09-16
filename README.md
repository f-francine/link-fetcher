# LinkFetcher

Simple scraper that searches for all href links in a given domain.

<img width="760" height="259" alt="image" src="https://github.com/user-attachments/assets/b54e88e3-e5c8-4ff5-85e6-8c4a6f761ad8" />

### Technologies
This project was developed using the technologies bellow:

 - Programming language:   **Elixir**                                         
 - Web Framework:         **Phoenix+Liveview+PubSub for realtime updates**
 - Dabase:                **Postgres**                                       
 - Job processing:        **Oban**                                           
 - Scrape/Crawler tool:   **Crawly + Floki**                                 

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

### Features

- SignUp/SignIn
  - When you either sign up or sign in, you'll be redirected to the `/pages` endpoint and a session for your user_id will be created
  - you cannot access any `/pages` endpoint without a session. If you try to do so, you'll be redirected to `/signin`
- Scrape
  - You can enter a webpage to be scraped. An async job will be encharged of running the operation. When the operation is finished, the scraped page will show on the menu.
  - The scrape will look for href links. All links found will be shown in the details page. You can access it just by clicking on the page card.
  - PubSub was used for live updates, so if you have the same account opened in two browsers, after the scrape is finished, both windows will be synced at the same time, automatically.
  - <img width="1887" height="1039" alt="image" src="https://github.com/user-attachments/assets/ad99e4a6-588f-4373-bbac-bcc142d212c8" />

