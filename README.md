## Install

### 1. **`docker-compose up -d`: Start Services in the Background**
This command starts all services defined in the Docker Compose file in the background, allowing you to continue using the terminal while the containers run.

### 2. **`docker-compose logs -f`: Follow Real-Time Logs of Services**
Use this command to monitor live logs from all services in the Compose file, updating continuously as the containers produce output.

### 3. **`docker-compose up -d wp-headless`: Start a Specific Service in the Background**
This command launches only the `wp-headless` service (as defined in the Docker Compose file) in the background, without affecting other services. It's useful when you want to restart or run a specific service without starting all other services.

### 4. **`cd frontend && yarn && yarn start`: Build and Run the Frontend Application**
- **`cd frontend`**: Changes the current directory to the `frontend` folder, which contains the source code for the frontend (likely a Nuxt.js or other JavaScript-based application).
- **`yarn`**: Installs all the required dependencies for the frontend application based on the `package.json` file.
- **`yarn start`**: Starts the frontend application server, making it accessible via the configured port (such as `http://localhost:3000`).

## Frontend

This starter kit provides two frontend containers:

- `frontend` container powered by the WP REST API is server-side rendered using Next.js, and exposed on port `3000`: [http://localhost:3000](http://localhost:3000)
- `frontend-graphql` container powered by GraphQL, exposed on port `3001`: [http://localhost:3001](http://localhost:3001)
- `docker-compose logs -f frontend` or `docker-compose logs -f frontend-base`

## Viewing Frontend Logs in Real Time

To monitor the logs of the frontend application running in your Docker containers, you can use either of the following commands depending on the container name:

### 1. `docker-compose logs -f frontend`
This command shows the real-time logs for the **frontend** container. It streams all log output from the running frontend application (e.g., Nuxt.js) and is useful for:

- Monitoring application status
- Viewing error and info messages
- Debugging issues during runtime

### 2. `docker-compose logs -f frontend-base`
If your container is named **frontend-base** (as defined in the `docker-compose.yml` file), use this command to stream logs in real time. It serves the same purpose as the above command but targets the **frontend-base** container.

Both commands allow you to debug and monitor the behavior of your frontend container while it's running.

## Backend

The `wp-headless` container exposes Apache on host port `8080`:

- Dashboard: [http://localhost:8080/wp-admin](http://localhost:8080/wp-admin) (default credentials `postlight`/`postlight`)
- REST API: [http://localhost:8080/wp-json](http://localhost:8080/wp-json)
- GraphQL API: [http://localhost:8080/graphql](http://localhost:8080/graphql)

This container includes some development tools:

    docker exec wp-headless composer --help
    docker exec wp-headless phpcbf --help
    docker exec wp-headless phpcs --help
    docker exec wp-headless phpunit --help
    docker exec wp-headless wp --info

Apache/PHP logs are available via `docker-compose logs -f wp-headless`.

## Database

The `db-headless` container exposes MySQL on host port `3307`:

    mysql -uwp_headless -pwp_headless -h127.0.0.1 -P3307 wp_headless

You can also run a mysql shell on the container:

    docker exec db-headless mysql -hdb-headless -uwp_headless -pwp_headless wp_headless

## Reinstall/Import

To reinstall WordPress from scratch, run:

    docker exec wp-headless wp db reset --yes && docker exec wp-headless install_wordpress

To import data from a mysqldump with `mysql`, run:

    docker exec db-headless mysql -hdb-headless -uwp_headless -pwp_headless wp_headless < example.sql
    docker exec wp-headless wp search-replace https://example.com http://localhost:8080

## Import Data from Another WordPress Installation

You can use a plugin called [WP Migrate DB Pro](https://deliciousbrains.com/wp-migrate-db-pro/) to connect to another WordPress installation and import data from it. (A Pro license will be required.)

To do so, first set `MIGRATEDB_LICENSE` & `MIGRATEDB_FROM` in `.env` and recreate containers to enact the changes.

    docker-compose up -d

Then run the import script:

    docker exec wp-headless migratedb_import

If you need more advanced functionality check out the available WP-CLI commands:

    docker exec wp-headless wp help migratedb

## Extend the REST and GraphQL APIs

At this point you can start setting up custom fields in the WordPress admin, and if necessary, creating [custom REST API endpoints](https://developer.wordpress.org/rest-api/extending-the-rest-api/adding-custom-endpoints/) in the Postlight Headless WordPress Starter theme.

The primary theme code is located in `wordpress/wp-content/themes/postlight-headless-wp`.

You can also [modify and extend the GraphQL API](https://wpgraphql.com/docs/getting-started/about), An example of creating a Custom Type and registering a Resolver is located in: `wordpress/wp-content/themes/postlight-headless-wp/inc/graphql`.

## REST & GraphQL JWT Authentication

To give WordPress users the ability to sign in via the frontend app, use something like the [WordPress Salt generator](https://api.wordpress.org/secret-key/1.1/salt/) to generate a secret for JWT, then define it in `wp-config.php`

For the REST API:

    define('JWT_AUTH_SECRET_KEY', 'your-secret-here');

For the GraphQL API:

    define( 'GRAPHQL_JWT_AUTH_SECRET_KEY', 'your-secret-here');

Make sure to read the [JWT REST](https://github.com/Tmeister/wp-api-jwt-auth) and [JWT GraphQL](https://github.com/wp-graphql/wp-graphql-jwt-authentication) documentation for more info.

## Linting

Remember to lint your code as you go.

To lint WordPress theme modifications, you can use [PHP_CodeSniffer](https://github.com/squizlabs/PHP_CodeSniffer) like this:

    docker exec -w /var/www/html/wp-content/themes/postlight-headless-wp wp-headless phpcs -v .

You may also attempt to autofix PHPCS errors:

    docker exec -w /var/www/html/wp-content/themes/postlight-headless-wp wp-headless phpcbf -v .

To lint and format the JavaScript apps, both [Prettier](https://prettier.io/) and [ESLint](https://eslint.org/) configuration files are included.

## Hosting

Most WordPress hosts don't also host Node applications, so when it's time to go live, you will need to find a hosting service for the frontend.

That's why we've packaged the frontend app in a Docker container, which can be deployed to a hosting provider with Docker support like Amazon Web Services or Google Cloud Platform. For a fast, easier alternative, check out [Now](https://zeit.co/now).

## Troubleshooting Common Errors

**Breaking Change Alert - Docker**

If you had the project already setup and then updated to a commit newer than `99b4d7b`, you will need to go through the installation process again because the project was migrated to Docker.
You will need to also migrate MySQL data to the new MySQL db container.

**Docker Caching**

In some cases, you need to delete the `wp-headless` image (not only the container) and rebuild it.

**CORS errors**

If you have deployed your WordPress install and are having CORS issues be sure to update `/wordpress/wp-content/themes/postlight-headless-wp/inc/frontend-origin.php` with your frontend origin URL.

See anything else you'd like to add here? Please send a pull request!

---
