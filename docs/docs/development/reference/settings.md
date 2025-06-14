---
title: Settings
description: Settings reference.
sidebar_label: Settings
---

This page provides a reference for all the available settings that can be used to configure Marten projects.

## Common settings

### `allowed_hosts`

Default: `[] of String`

An explicit array of allowed hosts for the application.

The application has to be explicitly configured to serve a list of allowed hosts. This is to mitigate HTTP Host header attacks. The strings in this array can correspond to regular domain names or subdomains (eg. `example.com` or `www.example.com`); when this is the case the Host header of the incoming request will be checked to ensure that it exactly matches one of the configured allowed hosts.

It is also possible to match all the subdomains of a specific domain by prepending a `.` at the beginning of the host string. For example `.example.com` will matches `example.com`, `www.example.com`, `sub.example.com`, or any other subdomains. Finally, the special `*` string can be used to match any Host value, but this wildcard value should be used with caution as you wouldn't be protected against Host header attacks.

It should be noted that this setting is automatically set to the following array when a project is running in [debug mode](#debug) (unless it is explicitly set):

```crystal
[".localhost", "127.0.0.1", "[::1]"]
```

### `cache_store`

Default: `Marten::Cache::Store::Memory.new`

The global cache store instance.

This setting allows to configure the cache store returned by the [`Marten#cache`](pathname:///api/dev/Marten.html#cache%3ACache%3A%3AStore%3A%3ABase-class-method) method (which can be used to perform low-level caching operations), and which is also leveraged for other caching features such as template fragment caching. Please refer to [Caching](../../caching.mdx) to learn more about the caching features provided by Marten.

By default, the global cache store is set to be an in-memory cache (instance of [`Marten::Cache::Store::Memory`](pathname:///api/dev/Marten/Cache/Store/Memory.html)). In test environments you might want to use the "null store" by assigning an instance of the [`Marten::Cache::Store::Null](pathname:///api/dev/Marten/Cache/Store/Null.html) to this setting. Additional caching store shards are also maintained under the umbrella of the Marten project or by the community itself and can be used as part of your application depending on your caching requirements. These backends are listed in the [caching stores backend reference](../../caching/reference/stores.md).

### `date_input_formats`

Default:

```crystal
[
  "%Y-%m-%d",  # '2024-10-25'
  "%m/%d/%Y",  # '10/25/2024'
  "%m/%d/%y",  # '10/25/06'
  "%b %d %Y",  # 'Oct 25 2024'
  "%b %d, %Y", # 'Oct 25, 2024'
  "%d %b %Y",  # '25 Oct 2024'
  "%d %b, %Y", # '25 Oct, 2024'
  "%B %d %Y",  # 'October 25 2024'
  "%B %d, %Y", # 'October 25, 2024'
  "%d %B %Y",  # '25 October 2024'
  "%d %B, %Y", # '25 October, 2024'
]
```

An array of default date input formats.

This array of default date input formats is used by the [`date` schema field](../../schemas/reference/fields.md#date) to parse date values from strings. Note that the date input formats coming from locales will be used with priority over the formats defined in this array.

### `date_time_input_formats`

Default:

```crystal
[
  "%Y-%m-%d %H:%M:%S",    # '2024-10-25 14:30:00'
  "%Y-%m-%d %H:%M:%S.%f", # '2024-10-25 14:30:00.000000'
  "%Y-%m-%d %H:%M",       # '2024-10-25 14:30'
  "%m/%d/%Y %H:%M:%S",    # '10/25/2024 14:30:00'
  "%m/%d/%Y %H:%M:%S.%f", # '10/25/2024 14:30:00.000000'
  "%m/%d/%Y %H:%M",       # '10/25/2024 14:30'
]
```

An array of default date input formats.

This array of default date input formats is used by the [`date_time` schema field](../../schemas/reference/fields.md#date_time) to parse date time values from strings. Note that the date time input formats coming from locales will be used with priority over the formats defined in this array.

### `debug`

Default: `false`

A boolean allowing to enable or disable debug mode.

When running in debug mode, Marten will automatically provide detailed information about raised exceptions (including tracebacks) and incoming HTTP requests. As such this mode is mostly useful for development environments.

### `host`

Default: `"127.0.0.1"`

The host the HTTP server running the application will be listening on.

### `installed_apps`

Default: `[] of Marten::Apps::Config.class`

An array of the installed app classes. Each Marten application must define a subclass of [`Marten::Apps::Config`](pathname:///api/dev/Marten/Apps/Config.html). When those subclasses are specified in the `installed_apps` setting, the applications' models, migrations, assets, and templates will be made available to the considered project. Please refer to [Applications](../applications.md) to learn more about applications.

### `log_backend`

Default: `Log::IOBackend.new(...)`

The log backend used by the application. Any `Log::Backend` object can be used, which can allow to easily configure how logs are formatted for example.

### `log_level`

Default: `Log::Severity::Info`

The default log level used by the application. Any severity defined in the [`Log::Severity`](https://crystal-lang.org/api/Log/Severity.html) enum can be used.

:::info
This setting exclusively controls the log level for the Marten server. To set the log level for [management commands](../management-commands.md), use the `--log-level` command option (see [Shared options](../management-commands.md#shared-options)).
:::

### `middleware`

Default: `[] of Marten::Middleware.class`

An array of middlewares used by the application. For example:

```crystal
config.middleware = [
  Marten::Middleware::Session,
  Marten::Middleware::I18n,
  Marten::Middleware::GZip,
]
```

Middlewares are used to "hook" into Marten's request / response lifecycle. They can be used to alter or implement logics based on incoming HTTP requests and the resulting HTTP responses. Please refer to [Middlewares](../../handlers-and-http/middlewares.md) to learn more about middlewares.

### `port`

Default: `8000`

The port the HTTP server running the application will be listening on.

### `port_reuse`

Default: `true`

A boolean indicating whether multiple processes can bind to the same HTTP server port.

### `referrer_policy`

Default: `"same-origin"`

The value to use for the [Referrer-Policy](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Referrer-Policy) header when the associated middleware is used. This header controls the amount of referrer information sent along with requests from your site to other origins, enhancing user privacy and security.

Possible values for the Referrer-Policy header include:

- `no-referrer`: The Referer header will be omitted entirely. No referrer information is sent with requests.
- `no-referrer-when-downgrade`: The Referer header will not be sent to less secure destinations (e.g., from HTTPS to HTTP), but will be sent to same or more secure destinations.
- `origin`: Only the origin of the document is sent as the referrer.
- `origin-when-cross-origin`: The full URL is sent as the referrer when performing a same-origin request, but only the origin is sent for cross-origin requests.
- `same-origin`: The Referer header is sent with same-origin requests, but not with cross-origin requests.
- `strict-origin`: Only the origin is sent as the referrer, and only for same-origin requests.
- `strict-origin-when-cross-origin`: The full URL is sent as the referrer when performing a same-origin request, but only the origin is sent for cross-origin requests. No referrer information is sent to less secure destinations.
- `unsafe-url`: The full URL is always sent as the referrer, regardless of the request's security.

This setting will be used by the [`Marten::Middleware::ReferrerPolicy`](../../handlers-and-http/reference/middlewares.md#referrer-policy-middleware) middleware when inserting the Referrer-Policy header in HTTP responses. By configuring this setting, you can control how much referrer information is included with requests from your site to other origins.

### `request_max_parameters`

Default: `1000`

The maximum number of allowed parameters per request (such as GET or POST parameters).

A large number of parameters will require more time to process and might be the sign of a denial-of-service attack, which is why this setting can be used. This protection can also be disabled by setting `request_max_parameters` to `nil`.

### `root_path`

Default: `nil`

The root path of the application.

The root path of the application specifies the actual location of the project sources in your system. This can prove helpful in scenarios where the project was compiled in a specific location different from the final destination where the project sources (and the `lib` folder) are copied. For instance, platforms like Heroku often fall under this category. By configuring the root path, you can ensure that your application correctly locates the required project sources and avoids any discrepancies arising from inconsistent source paths. This can prevent issues related to missing dependencies or missing app-related files (eg. locales, assets, or templates) and make your application more robust and reliable.

For example, deploying a Marten app on Heroku will usually involves setting the root path as follows:

```crystal
config.root_path = "/app"
```

### `secret_key`

Default: `""`

A secret key used for cryptographic signing for the considered Marten project.

The secret key should be set to a unique and unpredictable string value. The secret key can be used by Marten to encrypt or sign messages (eg. for cookie-based sessions), or by other authentication applications.

:::warning
The `secret_key` setting value **must** be kept secret. You should never commit this setting value to source control (instead, consider loading it from environment variables for example).
:::

### `time_zone`

Default: `Time::Location.load("UTC")`

The default time zone used by the application when it comes to storing date times in the database and displaying them. Any [`Time::Location`](https://crystal-lang.org/api/Time/Location.html) object can be used.

### `trailing_slash`

Default: `:do_nothing`

The trailing slash behavior applied in case an incoming request URL does not match any of the configured routes.

This setting allows you to configure whether an HTTP permanent redirect (301) should be issued when an incoming URL that does not match any of the configured routes either ends with a slash or does not. Three values are supported:

* `:do_nothing` - No redirect is issued (this is the default behavior).
* `:add` - If the incoming URL does not end with a slash and does not match any routes, a redirect is issued to the same URL with a trailing slash appended.
* `:remove` - If the incoming URL ends with a slash and does not match any routes, a redirect is issued to the same URL with the trailing slash removed.

### `unsupported_http_method_strategy`

Default: `:deny`

The strategy to use when an unsupported HTTP method is encountered.

This setting allows you to configure the strategy to use when a handler processes an unsupported HTTP method. The default strategy is `:deny`, which means that the application will return a 405 Method Not Allowed response when an unsupported HTTP method is encountered. The other available strategy is `:hide`, which will results in 404 Not Found responses to be returned instead.

### `use_x_forwarded_host`

Default: `false`

A boolean indicating whether the `X-Forwarded-Host` header is used to look for the host. This setting can be enabled if the Marten application is served behind a proxy that sets this header.

### `use_x_forwarded_port`

Default: `false`

A boolean indicating if the `X-Forwarded-Port` header is used to determine the port of a request. This setting can be enabled if the Marten application is served behind a proxy that sets this header.

### `use_x_forwarded_proto`

Default: `false`

A boolean indicating if the `X-Forwarded-Proto` header is used to determine whether a request is secure. This setting can be enabled if the Marten application is served behind a proxy that sets this header. For example, if such proxy sets this header to `https`, Marten will assume that the request is secure at the application level **only** if `use_x_forwarded_proto` is set to `true`.

### `handler400`

Default: `Marten::Handlers::Defaults::BadRequest`

The handler class that should generate responses for Bad Request responses (HTTP 400). Please refer to [Error handlers](../../handlers-and-http/error-handlers.md) to learn more about error handlers.

### `handler403`

Default: `Marten::Handlers::Defaults::PermissionDenied`

The handler class that should generate responses for Permission Denied responses (HTTP 403). Please refer to [Error handlers](../../handlers-and-http/error-handlers.md) to learn more about error handlers.

### `handler404`

Default: `Marten::Handlers::Defaults::PageNotFound`

The handler class that should generate responses for Not Found responses (HTTP 404). Please refer to [Error handlers](../../handlers-and-http/error-handlers.md) to learn more about error handlers.

### `handler500`

Default: `Marten::Handlers::Defaults::ServerError`

The handler class that should generate responses for Internal Error responses (HTTP 500). Please refer to [Error handlers](../../handlers-and-http/error-handlers.md) to learn more about error handlers.

### `x_frame_options`

Default: `"DENY"`

The value to use for the X-Frame-Options header when the associated middleware is used. The value of this setting will be used by the [`Marten::Middleware::XFrameOptions`](../../handlers-and-http/reference/middlewares.md#x-frame-options-middleware) middleware when inserting the X-Frame-Options header in HTTP responses.

## Assets settings

Assets settings allow configuring how Marten should interact with [assets](../../assets/introduction.md). These settings are all available under the `assets` namespace:

```crystal
config.assets.root = "assets"
config.assets.url = "/assets/"
```

### `app_dirs`

Default: `true`

A boolean indicating whether assets should be looked for inside installed application folders. When this setting is set to `true`, this means that assets provided by installed applications will be collected by the `collectassets` command (please refer to [Asset handling](../../assets/introduction.md) for more details regarding how to manage assets in your project).

### `dirs`

Default: `[] of String`

An array of directories where assets should be looked for. The order of these directories is important as it defines the order in which assets are searched for.

It should be noted that path objects or symbols can also be used to configure this setting:

```crystal
config.assets.dirs = [
  Path["src/path1/assets"],
  :"src/path2/assets",
]
```

### `manifests`

Default: `[] of String`

An array of paths to manifest JSON files to use to resolve assets URLs. Manifest files will be used to return the right fingerprinted asset path for a generic path, which can be useful if your asset bundling strategy support this. You can read more about this capability in [Asset manifests and fingerprinting](../../assets/introduction.md#asset-manifests-and-fingerprinting).

### `max_age`

Defaults: `3600`

Allows to set the max-age directive value used as part of the Cache-Control header that is set by the [`Marten::Middleware::AssetServing`](../../handlers-and-http/reference/middlewares.md#asset-serving-middleware) middleware.

### `root`

Default: `"assets"`

A string containing the absolute path where collected assets will be persisted (when running the `collectassets` command). By default, assets will be persisted in a folder that is relative to the Marten project's directory. Obviously, this folder should be empty before running the `collectassets` command in order to not overwrite existing files: assets should be defined as part of your applications' `assets` folders instead.

:::info
This setting is only used if `assets.storage` is `nil`.
:::

### `storage`

Default: `nil`

An optional storage object, which must be an instance of a subclass of [`Marten::Core::Store::Base`](pathname:///api/dev/Marten/Core/Storage/Base.html). This storage object will be used when collecting asset files to persist them in a given location.

By default this setting value is set to `nil`, which means that a [`Marten::Core::Store::FileSystem`](pathname:///api/dev/Marten/Core/Storage/FileSystem.html) storage is automatically constructed by using the `assets.root` and `assets.url` setting values: in this situation, asset files are collected and persisted in a local directory, and it is expected that they will be served from this directory by the web server running the application.

A specific storage can be set instead to ensure that collected assets are persisted somewhere else in the cloud and served from there (for example in an Amazon's S3 bucket). When this is the case, the `assets.root` and `assets.url` setting values are basically ignored and are overridden by the use of the specified storage.

### `url`

Default: `"/assets/"`

The base URL to use when exposing asset URLs. This base URL will be used by the default [`Marten::Core::Store::FileSystem`](pathname:///api/dev/Marten/Core/Storage/FileSystem.html) storage to construct asset URLs. For example, requesting a `css/App.css` asset might generate a `/assets/css/App.css` URL by default.

:::info
This setting is only used if `assets.storage` is `nil`.
:::

## CSRF settings

CSRF settings allow configuring how Cross-Site Request Forgeries (CSRF) attack protection measures are implemented within the considered Marten project. Please refer to [Cross-Site Request Forgery protection](../../security/csrf.md) for more details about this topic.

The following settings are all available under the `csrf` namespace:

```crystal
config.csrf.protection_enabled = true
config.csrf.cookie_name = "csrf-token"
```

### `cookie_domain`

Default: `nil`

An optional domain to use when setting the CSRF cookie. This can be used to share the CSRF cookie across multiple subdomains for example. For example, setting this option to `.example.com` will make it possible to send a POST request from a form on one subdomain (eg. `foo.example.com`) to another subdomain (eg. `bar.example.com `).

### `cookie_http_only`

Default: `false`

A boolean indicating whether client-side scripts should be prevented from accessing the CSRF token cookie. If this option is set to `true`, Javascript scripts won't be able to access the CSRF cookie.

### `cookie_max_age`

Default: `31_556_952` (approximately one year)

The max age (in seconds) of the CSRF cookie.

### `cookie_name`

Default: `"csrftoken"`

The name of the cookie to use for the CSRF token. This cookie name should be different than any other cookies created by your application.

### `cookie_same_site`

Default: `"Lax"`

The value of the [SameSite flag](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie/SameSite) to use for the CSRF cookie. Accepted values are `"Lax"`, `"Strict"`, or `"None"`.

### `cookie_secure`

Default: `false`

A boolean indicating whether to use a secure cookie for the CSRF cookie. Setting this to `true` will force browsers to send the cookie with an encrypted request over the HTTPS protocol only.

### `protection_enabled`

Default: `true`

A boolean indicating if the CSRF protection is enabled globally. When set to `true`, handlers will automatically perform a CSRF check to protect unsafe requests (ie. requests whose methods are not `GET`, `HEAD`, `OPTIONS`, or `TRACE`). Regardless of the value of this setting, it is always possible to explicitly enable or disable CSRF protection on a per-handler basis. See [Cross-Site Request Forgery protection](../../security/csrf.md) for more details.

### `session_key`

Default: `"csrftoken"`

The name of the session key to use for the CSRF token. This session key should be different than any other session key created by your application.

:::info
This value is only relevant if [`use_session`](#use_session) is set to `true`.
:::

### `trusted_origins`

Default: `[] of String`

An array of trusted origins.

These origins will be trusted for CSRF-protected requests (such as POST requests) and they will be used to check either the `Origin` or the `Referer` header depending on the request scheme. This is done to ensure that a specific subdomain such as `sub1.example.com` cannot issue a POST request to `sub2.example.com`. To enable CSRF-protected requests over different origins, it's possible to add trusted origins to this array. For example `https://sub1.example.com` can be configured as a trusted domain that way, but it's possible to allow CSRF-protected requests for all the subdomains of a specific domain by using `https://*.example.com`.

For example:

```crystal
config.csrf.trusted_origins = [
  "https://*.example.com",
  "https://other.example.org",
]
```

### `use_session`

Default: `false`

A boolean indicating whether the CSRF token should be stored inside a session.
If set to `true`, the CSRF token will be stored [in a session](../../handlers-and-http/sessions.md) rather than in a cookie.

## Content-Security-Policy settings

These settings allow configuring how the [`Marten::Middleware::ContentSecurityPolicy`](../../handlers-and-http/reference/middlewares.md#content-security-policy-middleware) middleware behaves and the actual directives of the Content-Security-Policy header that are set by this middleware.

```crystal
config.content_security_policy.report_only = true
config.content_security_policy.default_policy.default_src = [:self, "other"]
```

Please refer to [Content Security Policy](../../security/content-security-policy.md) to learn more about the Content-Security-Policy header protection.

:::tip
[Content-Security-Policy](https://www.w3.org/TR/CSP/) is a complicated header and there are possibly many values you may need to tweak. Make sure you understand it before configuring the below settings.
:::

### `default_policy`

Default: `Marten::HTTP::ContentSecurityPolicy.new`

The default Content-Security-Policy object.

This [`Marten::HTTP::ContentSecurityPolicy`](pathname:///api/dev/Marten/HTTP/ContentSecurityPolicy.html) object will be used to set the Content-Security-Policy header when the [`Marten::Middleware::ContentSecurityPolicy`](../../handlers-and-http/reference/middlewares.md#content-security-policy-middleware) middleware is used.

All the attributes that can be set on this [`Marten::HTTP::ContentSecurityPolicy`](pathname:///api/dev/Marten/HTTP/ContentSecurityPolicy.html) object through the use of methods such as [`#default_src=`](pathname:///api/dev/Marten/HTTP/ContentSecurityPolicy.html#default_src%3D(value%3AArray|Nil|String|Symbol|Tuple)-instance-method) or [`#frame_src=`](pathname:///api/dev/Marten/HTTP/ContentSecurityPolicy.html#frame_src%3D(value%3AArray|Nil|String|Symbol|Tuple)-instance-method) can also be used directly on the `content_security_policy` setting object. For example:

```crystal
config.content_security_policy.default_src = [:self, "other"]
config.content_security_policy.block_all_mixed_content = true
```

### `nonce_directives`

Default: `["script-src", "style-src"]`

An array of directives where a dynamically-generated nonce will be included.

For example, if this setting is set to `["script-src"]`, a `nonce-<b64-value>` value will be added to the `script-src` directive in the Content-Security-Policy header value.

### `report_only`

Default: `false`

A boolean indicating whether policy violations are reported without enforcing them.

If this setting is set to `true`, the [`Marten::Middleware::ContentSecurityPolicy`](../../handlers-and-http/reference/middlewares.md#content-security-policy-middleware) middleware will set a [Conten-Security-Policy-Report-Only](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only) header instead of the regular Content-Security-Policy header. Doing so can be useful to experiment with policies without enforcing them.

## Database settings

These settings allow configuring the databases used by the considered Marten project. At least one default database must be configured if your project makes use of [models](../../models-and-databases/introduction.md), and additional databases can optionally be configured as well.

```crystal
# Default database
config.database do |db|
  db.backend = :sqlite
  db.name = "default_db.db"
end

# Additional database
config.database :other do |db|
  db.backend = :sqlite
  db.name = "other_db.db"
end
```

Configuring other database backends such as MariaDB, MySQL or PostgreSQL usually involves specifying more connection parameters (eg. user, password, etc). As such, you must define a block to configure the appropriate database options when calling the [`#database`](pathname:///api/dev/Marten/Conf/GlobalSettings.html#database(id%3DDB%3A%3AConnection%3A%3ADEFAULT_CONNECTION_NAME%2Curl%3AString|Nil%3Dnil%2C%26)-instance-method) method. For example:

```crystal
config.database do |db|
  db.backend = :postgresql
  db.host = "localhost"
  db.name = "my_db"
  db.user = "my_user"
  db.password = "my_password"
end
```

It is worth mentioning that some cloud providers only provide a connection string in order to connect to a specific database (usually in a `DATABASE_URL` environment variable). In this situation, it is possible to automatically configure the database backend by providing the connection URL to the [`#database`](pathname:///api/dev/Marten/Conf/GlobalSettings.html#database%28id%3DDB%3A%3AConnection%3A%3ADEFAULT_CONNECTION_NAME%2Curl%3AString%7CNil%3Dnil%29-instance-method) method as well. This technique can be used for configuring both the default database and additional databases too. For example:

```crystal
# Default database
config.database url: "postgres://my_user:my_db@localhost:1234/db"

# Additional database
config.database :my_other_db, url: "sqlite://other_db.db?journal_mode=wal&synchronous=normal"
```

:::tip
You can combine both database configuration techniques mentioned above if needed. Indeed you can configure a database through the use of a connection string and also further customize the database by opening a block and setting additional options:

```crystal
# Configure db with a URL and a block
config.database url: "postgres://my_user:my_db@localhost:1234/db" do |db|
  db.retry_delay = 1.0
end
```
:::

The following sections provide details on all the available database configuration options.

### `backend`

Default: `nil`

The database backend to use for connecting to the considered database. Marten supports three backends presently:

* `:mysql`
* `:postgresql`
* `:sqlite`

### `checkout_timeout`

Default: `5.0`

The number of seconds to wait for a connection to become available when the max pool size is reached.

### `host`

Default: `nil`

A string containing the host used to connect to the database. No value means that the host will be localhost.

### `initial_pool_size`

Default: `1`

The initial number of connections created for the database connections pool.

### `max_idle_pool_size`

Default: `1`

The maximum number of idle connections for the database connections pool. Concretely, this means that when released, a connection will be closed only if there are already `max_idle_pool_size` idle connections.

### `max_pool_size`

Default: `0`

The maximum number of connections that will be held by the database connections pool. When set to `0`, this means that there is no limit to the number of connections.

### `name`

Default: `nil`

The name of the database to connect to. If you use the `sqlite` backend, this can be a string or a `Path` object containing the path (absolute or relative) to the considered database path.

### `options`

Default: `{} of String => String`

A set of additional database options. This setting can be used to set additional database options that may be required in order to connect to the database at hand.

For example:

```crystal
config.database do |db|
  db.backend = :postgresql
  db.host = "localhost"
  db.name = "my_db"
  db.user = "my_user"
  db.password = "my_password"
  // highlight-next-line
  db.options = {"sslmode" => "disable"}
end
```

The options that you can set here will vary based on your chosen database backend. For example, you could set the `sslmode` option for PostgreSQL databases or some [pragma options](https://github.com/crystal-lang/crystal-sqlite3?tab=readme-ov-file#setting-pragmas) for SQLite3 databases.

Please refer to the applicable DB binding shard documentation for more details about the available options:

* [crystal-pg](https://github.com/will/crystal-pg) (PostgreSQL)
* [crystal-mysql](https://github.com/crystal-lang/crystal-mysql) (MariaDB, MySQL)
* [crystal-sqlite3](https://github.com/crystal-lang/crystal-sqlite3) (SQLite3)

### `password`

Default: `nil`

A string containing the password to use to connect to the configured database.

### `port`

Default: `nil`

The port to use to connect to the configured database. No value means that the default port will be used.

### `retry_attempts`

Default: `1`

The maximum number of attempts to retry re-establishing a lost connection.

### `retry_delay`

Default: `1.0`

The delay to wait between each retry at re-establishing a lost connection.

### `user`

Default: `nil`

A string containing the name of the user that should be used to connect to the configured database.

## Emailing settings

Emailing settings allow configuring emailing-related settings. Please refer to [Emailing](../../emailing.mdx) for more details about how to define and send emails in your projects.

The following settings are all available under the `emailing` namespace:

```crystal
config.emailing.from_address = "no-reply@example.com"
config.emailing.backend = Marten::Emailing::Backend::Development.new(print_emails: true)
```

### `backend`

Default: `Marten::Emailing::Backend::Development.new`

The backend to use when it comes to send emails. Emailing backends define _how_ emails are actually sent.

By default, a development backend (instance of [`Marten::Emailing::Backend::Dev`](pathname:///api/dev/Marten/Emailing/Backend/Development.html)) is used: this backend "collects" all the emails that are "delivered" by default (which can be used in specs in order to test sent emails), but it can also be configured to print email details to the standard output if necessary (see the [emailing backend reference](../../emailing/reference/backends.md) for more details about this capability).

Additional emailing backend shards are also maintained under the umbrella of the Marten project or by the community itself and can be used as part of your application depending on your specific email sending requirements. These backends are listed in the [emailing backend reference](../../emailing/reference/backends.md#other-backends).

### `from_address`

Default: `"webmaster@localhost"`

The default from address used in emails. Email definitions that don't specify a "from" address explicitly will use this email address automatically for the sender email. It should be noted that this from email address can be defined as a string or as a [`Marten::Emailing::Address`](pathname:///api/dev/Marten/Emailing/Address.html) object (which allows to specify the name AND the address of the sender email).

## I18n settings

I18n settings allow configuring internationalization-related settings. Please refer to [Internationalization](../../i18n.mdx) for more details about how to leverage translations and localized content in your projects.

:::info
Marten makes use of [crystal-i18n](https://crystal-i18n.github.io/) to handle translations and locales. Further [configuration options](https://crystal-i18n.github.io/configuration.html) are also provided by this shard and can be leveraged by any Marten projects if necessary.
:::

The following settings are all available under the `i18n` namespace:

```crystal
config.i18n.default_locale = :fr
```

### `available_locales`

Default: `nil`

Allows defining the locales that can be activated to perform translation lookups and localizations. For example:

```crystal
config.i18n.available_locales = [:en, :fr]
```

### `default_locale`

Default: `"en"`

The default locale used by the Marten project.

### `fallbacks`

Default: `["en"]`

The locale fallbacks of the project.

By configuring locale fallbacks, you can force your project to try to lookup translations in other (configured) locales if the current locale the translation is requested into is missing.

The specified fallbacks can be:

* a hash or a named tuple defining the chains of fallbacks to use for specific locales.
* a simple array of fallbacks. In that case, this chain of fallbacked locales will be used as a default for all the available locales when translations are missing.
* an `I18n::Locale::Fallbacks` object, allowing you to specify a general default fallback array and fallback mappings at the same time (see the [crystal-i18n documentation](https://crystal-i18n.github.io/configuration.html#fallbacks)).

For example:

```crystal
# Simple fallback chain used by all configured locales:
config.i18n.fallbacks = ["en-US", "en"]

# Locale-specific fallback chains:
config.i18n.fallbacks = {"en-CA" => ["en-US", "en"], "fr-CA" => "fr"}

# Default fallback chain and locale-specific fallback chains:
config.i18n.fallbacks = ::I18n::Locale::Fallbacks.new(
  {"fr-CA-special": ["fr-CA", "fr", "en"]},
  default: ["en"]
)
```

### `locale_cookie_name`

Default: `"marten_locale"`

The name of the cookie to use for saving the locale of the current user and activating the right locale (when the [`Marten::Middleware::I18n`](../../handlers-and-http/reference/middlewares.md#i18n-middleware) middleware is used). See [Internationalization](../../i18n/introduction.md) to learn more about this capability.

## Media files settings

Media files settings allow configuring how Marten should interact with [media files](../../files/managing-files.md). These settings are all available under the `media_files` namespace:

```crystal
config.media_files.root = "files"
config.media_files.url = "/files/"
```

### `root`

Default: `"media"`

A string containing the absolute path where uploaded files will be persisted. By default uploaded files will be persisted in a folder that is relative to the Marten project's directory.

:::info
This setting is only used if `media_files.storage` is `nil`.
:::

### `storage`

Default: `nil`

An optional storage object, which must be an instance of a subclass of [`Marten::Core::Store::Base`](pathname:///api/dev/Marten/Core/Storage/Base.html). This storage object will be used when uploading files to persist them in a given location.

By default, this setting value is set to `nil`, which means that a [`Marten::Core::Store::FileSystem`](pathname:///api/dev/Marten/Core/Storage/FileSystem.html) storage is automatically constructed by using the `media_files.root` and `media_files.url` setting values: in this situation, media files are persisted in a local directory, and it is expected that they will be served from this directory by the web server running the application.

A specific storage can be set instead to ensure that uploaded files are persisted somewhere else in the cloud and served from there (for example in an Amazon's S3 bucket). When this is the case, the `media_files.root` and `media_files.url` setting values are basically ignored and are overridden by the use of the specified storage.

### `url`

Default: `"/media/"`

The base URL to use when exposing media files URLs. This base URL will be used by the default [`Marten::Core::Store::FileSystem`](pathname:///api/dev/Marten/Core/Storage/FileSystem.html) storage to construct media files URLs. For example, requesting a `foo/bar.txt` file might generate a `/media/foo/bar.txt` URL by default.

:::info
This setting is only used if `media_files.storage` is `nil`.
:::

## Method overriding settings

Method overriding settings allow configuring how the [`MethodOverride`](../../handlers-and-http/reference/middlewares.md#method-override-middleware) middleware should handle HTTP method overrides in forms. These settings are all available under the `method_override` namespace:

```crystal
config.method_override.allowed_methods = ["DELETE", "PATCH", "PUT"]
config.method_override.http_header_name = "X-Http-Method-Override"
config.method_override.input_name = "_method"
```

### `allowed_methods`

Default: `["DELETE", "PATCH", "PUT"]`

An array of HTTP methods that are allowed to be overridden using the `input_name` mechanism. This provides a layer of control, preventing the usage of arbitrary HTTP methods in overrides.

### `http_header_name`

Default: `X-Http-Method-Override`

The name of the HTTP header used to signal a method override.

### `input_name`

Default: `_method`

The name of the form input field (or query parameter) used to signal a method override.

## Sessions settings

Sessions settings allow configuring how Marten should handle [sessions](../../handlers-and-http/introduction.md#using-sessions). These settings are all available under the `sessions` namespace:

```crystal
config.sessions.cookie_name = "_sessions"
config.sessions.store = :cookie
```

### `cookie_domain`

Default: `nil`

An optional domain to use when setting the session cookie. This can be used to share the session cookie across multiple subdomains.

### `cookie_http_only`

Default: `false`

A boolean indicating whether client-side scripts should be prevented from accessing the session cookie. If this option is set to `true`, Javascript scripts won't be able to access the session cookie.

### `cookie_max_age`

Default: `1_209_600` (two weeks)

The max age (in seconds) of the session cookie.


### `cookie_name`

Default: `"sessionid"`

The name of the cookie to use for the session token. This cookie name should be different than any other cookies created by your application.

### `cookie_same_site`

Default: `"Lax"`

The value of the [SameSite flag](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie/SameSite) to use for the session cookie. Accepted values are `"Lax"`, `"Strict"`, or `"None"`.

### `cookie_secure`

Default: `false`

A boolean indicating whether to use a secure cookie for the session cookie. Setting this to `true` will force browsers to send the cookie with an encrypted request over the HTTPS protocol only.

### `store`

Default: `"cookie"`

A string containing the identifier of the store used to handle sessions.

By default, sessions are stored within a single cookie. Cookies have a 4K size limit, which is usually sufficient to persist things like a user ID and flash messages. Other stores can be implemented and leveraged to store sessions data; see [Sessions](../../handlers-and-http/sessions.md) for more details about this capability.

## SSL redirect settings

SSL redirect settings allow to configure how Marten should redirect non-HTTPS requests to HTTPS when the [`Marten::Middleware::SSLRedirect`](../../handlers-and-http/reference/middlewares.md#ssl-redirect-middleware) middleware is used:

```crystal
config.ssl_redirect.host = "example-redirect.com"
config.exempted_paths = [/^\/no-ssl\/$/]
```

### `exempted_paths`

Default: `[] of Regex | String`

Allows to set the array of paths that should be exempted from HTTPS redirects. Both strings and regexes are accepted.

### `host`

Default: `nil`

Allows to set the host that should be used when redirecting non-HTTPS requests. If set to `nil`, the HTTPS redirect will be performed using the request's host.

## Strict transport security policy settings

Strict transport security policy settings allow to configure how Marten should set the HTTP Strict-Transport-Security response header when the [`Marten::Middleware::StrictTransportSecurity`](../../handlers-and-http/reference/middlewares.md#strict-transport-security-middleware) middleware is used:

```crystal
config.strict_transport_security.max_age = 3_600
config.strict_transport_security.include_sub_domains = true
```

### `include_sub_domains`

Default: `false`

Defines whether the `includeSubDomains` directive should be inserted into the HTTP Strict-Transport-Security response header. When this directive is set, this means that the policy will also apply to all the site's subdomains.

:::caution
You should be careful when enabling this option as this will prevent browsers from connecting to your site's subdomains using HTTP for the duration defined by the [`max_age`](#max_age) setting.
:::

### `max_age`

Default: `nil`

Defines the duration in seconds that browsers should remember that the web app must be accessed using HTTPS only. A `nil` value means that the HTTP Strict-Transport-Security response header is not inserted in responses (which is equivalent to not using the [`Marten::Middleware::StrictTransportSecurity`](../../handlers-and-http/reference/middlewares.md#strict-transport-security-middleware) middleware).

:::caution
You should be careful when defining a value for this setting because this will prevent browsers from connecting to your site using HTTP for the duration you specified.
:::

### `preload`

Default: `false`

Defines whether the `preload` directive should be inserted into the HTTP Strict-Transport-Security response header. Setting this to `true` means that you allow your site to be submitted to the [HSTS browser preload list](https://hstspreload.org/) by browsers.

## Templates settings

Templates settings allow configuring how Marten discovers and renders [templates](../../templates.mdx). These settings are all available under the `templates` namespace:

```crystal
config.templates.app_dirs = false
config.templates.cached = false
```

### `app_dirs`

Default: `true`

A boolean indicating whether templates should be looked for inside installed application folders (local `templates` directories). When this setting is set to `true`, this means that templates provided by installed applications can be loaded and rendered by the templates engine. Otherwise, it would not be possible to load and render these application templates.

### `cached`

Default: `false`

A boolean indicating whether templates should be kept in a memory cache upon being loaded and parsed. This setting should likely be set to `false` in development environments (where changes to templates are frequent) and set to `true` in production environments (to avoid loading and parsing the same templates multiple times).

### `context_producers`

Default: `[] of Marten::Template::ContextProducer.class`

An array of context producer classes. Context producers are helpers that ensure that common variables are automatically inserted in the template context whenever a template is rendered. See [Using context producers](../../templates/introduction.md#using-context-producers) to learn more about this capability.

### `dirs`

Default: `[] of String`

An array of directories where templates should be looked for. The order of these directories is important as it defines the order in which templates are searched for when requesting a template for a given path (eg. `foo/bar/template.html`).

It should be noted that path objects or symbols can also be used to configure this setting:

```crystal
config.templates.dirs = [
  Path["src/path1/templates"],
  :"src/path2/templates",
]
```

### `isolated_inclusions`

Default: `false`

A boolean option enabling or disabling isolated inclusions of templates when using the [`include`](../../templates/reference/tags.md#include) template tag. When set to `true`, included templates won't have access to variables from the outer context by default, unless the `contextual` modifier is used with the `include` template tag. Conversely, when set to `false`, included templates will have access to the outer context's variables by default, unless explicitly disabled with the `isolated` modifier of the `include` template tag.

### `loaders`

Default: `nil`

Overwrites the loading mechanism of templates. Takes an array of classes inheriting from `Marten::Template::Loader::Base`. Customize this to load templates from various sources like databases or in-memory structures. For example, to load templates from a file system:

```crystal
config.templates.loaders = [Marten::Template::Loader::FileSystem.new("/path/to/templates")] of Marten::Template::Loader::Base
```

### `strict_variables`

Default: `false`

A boolean allowing to enable or disable the [strict variables](../../templates/introduction.md#strict-variables) for templates. When this setting is set to `true`, unknown variables encountered in templates will result in [`Marten::Template::Errors::UnknownVariable`](pathname:///api/dev/Marten/Template/Errors/UnknownVariable.html) exceptions to be raised. When set to `false`, unknown variables will simply be treated as `nil` values in templates.
