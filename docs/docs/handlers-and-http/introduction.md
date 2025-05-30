---
title: Introduction to handlers
description: Learn how to define handlers and respond to HTTP requests.
sidebar_label: Introduction
---

Handlers are classes whose responsibility is to process web requests and to return responses. They implement the necessary logic allowing to return this response, which can involve processing form data through the use of [schemas](../schemas.mdx) for example, retrieving [model records](../models-and-databases.mdx) from the database, etc. They can return responses corresponding to HTML pages, JSON objects, redirects, ...

## Writing handlers

At their core, handlers are subclasses of the [`Marten::Handler`](pathname:///api/dev/Marten/Handlers/Base.html) class. These classes are usually defined under a `handlers` folder, at the root of a Marten project or application. Here is an example of a very simple handler:

```crystal
class SimpleHandler < Marten::Handler
  def dispatch
    respond "Hello World!"
  end
end
```

The above handler returns a `200 OK` response containing a short text, regardless of the incoming HTTP request method.

Handlers are initialized from a [`Marten::HTTP::Request`](pathname:///api/dev/Marten/HTTP/Request.html) object and an optional set of routing parameters. Their inner logic is executed when calling the `#dispatch` method, which _must_ return a [`Marten::HTTP::Response`](pathname:///api/dev/Marten/HTTP/Response.html) object.

When the `#dispatch` method is explicitly overridden, it is responsible for applying different logics in order to handle the various incoming HTTP request methods. For example, a handler might display an HTML page containing a form when handling a `GET` request, and it might process possible form data when handling a `POST` request:

```crystal
class FormHandler < Marten::Handler
  def dispatch
    if request.method == 'POST'
      # process form data
    else
      # return HTML page
    end
  end
end
```

It should be noted that this "dispatching" logic based on the incoming request method does not have to live inside an overridden `#dispatch` method. By default, each handler provides methods whose names match HTTP method verbs. This allows writing the logic allowing to process `GET` requests by overriding the `#get` method for example, or to process `POST` requests by overriding the `#post` method:

```crystal
class FormHandler < Marten::Handler
  def get
    # return HTML page
  end

  def post
    # process form data
  end
end
```

:::info
If a handler's logic is defined like in the above example, trying to access such handler via another HTTP verb (eg. `DELETE`) will automatically result in a "Not allowed" response (405).
:::

### The `request` and `response` objects

As mentioned previously, a handler is always initialized from an incoming HTTP request object (instance of [`Marten::HTTP::Request`](pathname:///api/dev/Marten/HTTP/Request.html)) and is required to return an HTTP response object (instance of [`Marten::HTTP::Response`](pathname:///api/dev/Marten/HTTP/Response.html)) as part of its `#dispatch` method.

The `request` object gives access to a set of useful information and attributes associated with the incoming request. Things like the HTTP request verb, headers, or query parameters can be accessed through this object. The most common methods that you can use are listed below:

| Method | Description |
| ----------- | ----------- |
| `#body` | Returns the raw body of the request as a string. |
| `#cookies` | Returns a hash-like object (instance of [`Marten::HTTP::Cookies`](pathname:///api/dev/Marten/HTTP/Cookies.html)) containing the cookies associated with the request. |
| `#data` | Returns a hash-like object (instance of [`Marten::HTTP::Params::Data`](pathname:///api/dev/Marten/HTTP/Params/Data.html)) containing the request data. |
| `#flash` | Returns a hash-like object (instance of [`Marten::HTTP::FlashStore`](pathname:///api/dev/Marten/HTTP/FlashStore.html)) containing the flash messages available to the current request. |
| `#headers` | Returns a hash-like object (instance of [`Marten::HTTP::Headers`](pathname:///api/dev/Marten/HTTP/Headers.html)) containing the headers embedded in the request. |
| `#host` | Returns the host associated with the considered request. |
| `#method` | Returns the considered HTTP request method (`GET`, `POST`, `PUT`, etc). |
| `#query_params` | Returns a hash-like object (instance of [`Marten::HTTP::Params::Query`](pathname:///api/dev/Marten/HTTP/Params/Query.html)) containing the HTTP GET parameters embedded in the request. |
| `#session` | Returns a hash-like object (instance of [`Marten::HTTP::Session::Store::Base`](pathname:///api/dev/Marten/HTTP/Session/Store/Base.html)) corresponding to the session store for the current request. |

The `response` object corresponds to the HTTP response that is returned to the client. Response objects can be created by initializing the [`Marten::HTTP::Response`](pathname:///api/dev/Marten/HTTP/Response.html) class directly (or one of its subclasses) or by using [response helper methods](#response-helper-methods). Once initialized, these objects can be mutated to further configure what is sent back to the browser. The most common methods that you can use in this regard are listed below:

| Method | Description |
| ----------- | ----------- |
| `#content` | Returns the content of the response as a string. |
| `#content_type` | Returns the content type of the response as a string. |
| `#cookies` | Returns a hash-like object (instance of [`Marten::HTTP::Cookies`](pathname:///api/dev/Marten/HTTP/Cookies.html)) containing the cookies that will be sent with the response. |
| `#headers` | Returns a hash-like object (instance of [`Marten::HTTP::Headers`](pathname:///api/dev/Marten/HTTP/Headers.html)) containg the headers that will be used for the response. |
| `#status` | Returns the status of the response (eg. 200 or 404). |

### Parameters

Handlers are mapped to URLs through a [routing configuration](#mapping-handlers-to-urls). Some routes require parameters that are used by the handler to retrieve objects or perform any arbirtary logic. These parameters can be accessed by using the `#params` method, which returns a hash of all the parameters that were used to initialize the considered handler.

For example such parameters can be used to retrieve a specific model instance:

```crystal
class FormHandler < Marten::Handler
  def get
    if (record = MyModel.get(id: params["id"]))
      respond "Record found: #{record}"
    else
      respond "Record not found!", status: 404
    end
  end
end
```

:::tip
Note that you can use either strings or symbols when interacting with the routing parameters returned by the `#params` method.
:::

### Response helper methods

Technically, it is possible to forge HTTP responses by instantiating the [`Marten::HTTP::Response`](pathname:///api/dev/Marten/HTTP/Response.html) class directly (or one of its subclasses such as [`Marten::HTTP::Response::Found`](pathname:///api/dev/Marten/HTTP/Response/Found.html) for example). That being said, Marten provides a set of helper methods that can be used to conveniently forge responses for various use cases:

#### `respond`

You already saw `#respond` in action in the [first example](#writing-handlers). Basically, `#respond` allows forging an HTTP response by specifying a content, a content type, and a status code:

```crystal
respond("Response content", content_type: "text/html", status: 200)
```

Unless specified, the `content_type` is set to `text/html` and the `status` is set to `200`.

:::tip
You can also express the `status` of the response as a symbol that must comply with the values of the [`HTTP::Status`](https://crystal-lang.org/api/HTTP/Status.html) enum. For example:

```crystal
respond("Response content", content_type: "text/html", status: :ok)
```
:::

#### `render`

`render` allows returning an HTTP response whose content is generated by rendering a specific [template](../templates.mdx). The template can be rendered by specifying a context hash or named tuple. For example:

```crystal
render("path/to/template.html", context: { foo: "bar" }, content_type: "text/html", status: 200)
```

Unless specified, the `content_type` is set to `text/html` and the `status` is set to `200`.

:::tip
You can also express the `status` of the response as a symbol that must comply with the values of the [`HTTP::Status`](https://crystal-lang.org/api/HTTP/Status.html) enum. For example:

```crystal
render("path/to/template.html", context: { foo: "bar" }, content_type: "text/html", status: :ok)
```
:::

#### `redirect`

`#redirect` allows forging a redirect HTTP response. It requires a `url` and accepts an optional `permanent` argument in order to define whether a permanent redirect is returned (301 Moved Permanently) or a temporary one (302 Found):

```crystal
redirect("https://example.com", permanent: true)
```

Unless explicitly specified, `permanent` will automatically be set to `false`.

#### `#head`

`#head` allows constructing a response containing headers but without actual content. The method accepts a status code only:

```crystal
head(404)
```

:::tip
You can also express the `status` of the response as a symbol that must comply with the values of the [`HTTP::Status`](https://crystal-lang.org/api/HTTP/Status.html) enum. For example:

```crystal
head :not_found
```
:::

#### `json`

`json` allows forging an HTTP response with the `application/json` content type. It can be used with a raw JSON string, or any serializable object:

```crystal
json({ foo: "bar" }, status: 200)
```

Unless specified, the `status` is set to `200`.

:::tip
You can also express the `status` of the response as a symbol that must comply with the values of the [`HTTP::Status`](https://crystal-lang.org/api/HTTP/Status.html) enum. For example:

```crystal
json({ foo: "bar" }, status: :ok)
```
:::

### Callbacks

It is possible to define callbacks in order to bind methods and logics to specific events in the lifecycle of your handlers. For example, it is possible to define callbacks that run before a handler's `#dispatch` method gets executed, or after it!

Please head over to the [Handler callbacks](./callbacks.md) guide in order to learn more about handler callbacks.

### Generic handlers

Marten provides a set of generic handlers that can be used to perform common application tasks such as displaying lists of records, deleting entries, or rendering [templates](../templates/introduction.md). This saves developers from reinventing common patterns.

Please head over to the [Generic handlers](./generic-handlers.md) guide in order to learn more about available generic handlers.

### Global template context

All handlers have access to a [`#context`](pathname:///api/dev/Marten/Handlers/Base.html#context-instance-method) method that returns a [template](../templates/introduction.md) context object. This "global" context object is available for the lifetime of the considered handler and can be mutated in order to define which variables are made available to the template runtime when rendering templates through the use of the [`#render`](#render) helper method or when rendering templates as part of subclasses of the [`Marten::Handlers::Template`](./generic-handlers.md#rendering-a-template) generic handler. 

To modify this context object effectively, it's recommended to utilize [`before_render`](./callbacks.md#before_render) callbacks, which are invoked just before rendering a template within a handler. For example, this can be achieved as follows when using a [`Marten::Handlers::Template`](./generic-handlers.md#rendering-a-template) subclass:

```crystal
class MyHandler < Marten::Handlers::Template
  template_name "app/my_template.html"
  before_render :add_variable_to_context

  private def add_variable_to_context : Nil
    context["foo"] = "bar"
  end
end
```

### Returning errors

It is easy to forge any error response by leveraging the `#respond` or `#head` helpers that were mentioned [previously](#response-helper-methods). Using these helpers, it is possible to forge HTTP responses that are associated with specific error status codes and specific contents. For example:

```crystal
class MyHandler < Marten::Handler
  def get
    respond "Content not found", status: 404
  end
end
```

It should be noted that Marten also support a couple of exceptions that can be raised to automatically trigger default error handlers. For example [`Marten::HTTP::Errors::NotFound`](pathname:///api/dev/Marten/HTTP/Errors/NotFound.html) can be raised from any handler to force a 404 Not Found response to be returned. Default error handlers can be returned automatically by the framework in many situations (eg. a record is not found, or an unhandled exception is raised); you can learn more about them in [Error handlers](./error-handlers.md).

### Exceptions handling

Marten lets you define callback methods that are invoked when certain exceptions are encountered during the execution of your handler's `#dispatch` method. These exception handling callbacks can be defined by using the [`#rescue_from`](pathname:///api/dev/Marten/Handlers/ExceptionHandling.html#rescue_from(*exception_klasses%2C**kwargs%2C%26block)-macro) macro, which accepts one or more exception classes and an exception handler that can be specified by a trailing `:with` option containing the name of a method to invoke or a block containing the exception handling logic.

For example, the following handler will react to possible `Auth::UnauthorizedUser` exceptions by calling the `#handle_unauthorized_user` private method:

```crystal
class ProfileHandler < Marten::Handlers::Template
  include RequireSignedInUser

  template_name "auth/profile.html"

  rescue_from Auth::UnauthorizedUser, with: :handle_unauthorized_user

  private def handle_unauthorized_user
    head :forbidden
  end
end
```

And the following handler will do exactly the same by invoking the specified block:

```crystal
class ProfileHandler < Marten::Handlers::Template
  include RequireSignedInUser

  template_name "auth/profile.html"

  rescue_from Auth::UnauthorizedUser do
    head :forbidden
  end
end
```

It is worth mentioning that exception handling callbacks are inherited and that they are searched bottom-up in the inheritance hierarchy.

:::warning
Your exception handling callbacks should return [`Marten::HTTP::Response`](pathname:///api/dev/Marten/HTTP/Response.html) objects. If that's not the case, then your exception handling callback logic will be executed but the original exception will be allowed to "bubble up" (which will likely result in a server error).
:::

## Mapping handlers to URLs

Handlers define the logic allowing to handle incoming HTTP requests and return corresponding HTTP responses. In order to define which handler gets called for a specific URL (and what are the expected URL parameters), handlers need to be associated with a specific route. This configuration usually takes place in the `config/routes.rb` configuration file, where you can define "paths" and associate them to your handler classes:

```crystal title="config/routes.cr"
Marten.routes.draw do
  path "/", HomeHandler, name: "home"
  path "/articles", ArticlesHandler, name: "articles"
  path "/articles/<pk:int>", ArticleDetailHandler, name: "article_detail"
end
```

Please refer to [Routing](./routing.md) for more information regarding routes configuration.

## Using cookies

Handlers are able to interact with a cookies store, that you can use to store small amounts of data on the client. This data will be persisted across requests, and will be made accessible with every incoming request.

The cookies store is an instance of [`Marten::HTTP::Cookies`](pathname:///api/dev/Marten/HTTP/Cookies.html) and provides a hash-like interface allowing to retrieve and store data. Handlers can access it through the use of the `#cookies` method. Here is a very simple example of how to interact with cookies:

```crystal
class MyHandler < Marten::Handler
  def get
    cookies[:foo] = "bar"
    respond "Hello World!"
  end
end
```

It should be noted that the cookies store gives access to two sub stores: an encrypted one and a signed one.

`cookies.encrypted` allows defining cookies that will be signed and encrypted. Whenever a cookie is requested from this store, the raw value of the cookie will be decrypted. This is useful to create cookies whose values can't be read nor tampered by users:

```crystal
cookies.encrypted[:secret_message] = "Hello!"
```

`cookies.signed` allows defining cookies that will be signed but not encrypted. This means that whenever a cookie is requested from this store, the signed representation of the corresponding value will be verified. This is useful to create cookies that can't be tampered by users, but it should be noted that the actual data can still be read by the client.

```crystal
cookies.signed[:signed_message] = "Hello!"
```

Please refer to [Cookies](./cookies.md) for more information around using cookies.

## Using sessions

Handlers can interact with a session store, which you can use to store small amounts of data that will be persisted between requests. How much data you can persist in this store depends on the session backend being used. The default backend persists session data using an encrypted cookie. Cookies have a 4K size limit, which is usually sufficient in order to persist things like a user ID and flash messages.

The session store is an instance of [`Marten::HTTP::Session::Store::Base`](pathname:///api/dev/Marten/HTTP/Session/Store/Base.html) and provides a hash-like interface. Handlers can access it through the use of the `#session` method. For example:

```crystal
class MyHandler < Marten::Handler
  def get
    session[:foo] = "bar"
    respond "Hello World!"
  end
end
```

Please refer to [Sessions](./sessions.md) for more information regarding configuring sessions and the available backends.

## Using the flash store

The flash store provides a way to pass basic string messages from one handler to the next one. Any string value that is set in this store will be available to the next handler processing the next request, and then it will be cleared out. Such mechanism provides a convenient way of creating one-time notification messages (such as alerts or notices).

The flash store is an instance [`Marten::HTTP::FlashStore`](pathname:///api/dev/Marten/HTTP/FlashStore.html) and provides a hash-like interface. Handlers can access it through the use of the `#flash` method. For example:

```crystal
class MyHandler < Marten::Handler
  def post
    flash[:notice] = "Article successfully created!"
    redirect("/success")
  end
end
```

In the above example, the handler creates a flash message before returning a redirect response to another URL. It is up to the handler processing this URL to decide what to do with the flash message; this can involve rendering it as part of a base template for example.

Note that it is possible to explicitly keep the current flash messages so that they remain all accessible to the next handler processing the next request. This can be done by using the `flash.keep` method, which can take an optional argument in order to keep the message associated with a specific key only.

```crystal
flash.keep       # keeps all the flash messages for the next request
flash.keep(:foo) # keeps the message associated with the "foo" key only
```

The reverse operation is also possible: you can decide to discard all the current flash messages so that none of them will remain accessible to the next handler processing the next request. This can be done by using the `flash.discard` method, which can take an optional argument in order to discard the message associated with a specific key only.

```crystal
flash.discard       # discards all the flash messages
flash.discard(:foo) # discards the message associated with the "foo" key only
```

## Streaming responses

The [`Marten::HTTP::Response::Streaming`](pathname:///api/dev/Marten/HTTP/Response/Streaming.html) response class gives you the ability to stream a response from Marten to the browser. However, unlike a standard response, this specialized class requires initialization from an [iterator](https://crystal-lang.org/api/Iterator.html) of strings instead of a content string. This approach proves to be beneficial if you intend to generate lengthy responses or responses that consume excessive memory (a classic example of this is the generation of large CSV files).

Compared to a regular [`Marten::HTTP::Response`](pathname:///api/dev/Marten/HTTP/Response.html) object, the [`Marten::HTTP::Response::Streaming`](pathname:///api/dev/Marten/HTTP/Response/Streaming.html) class operates differently in two ways:

* Instead of initializing it with a content string, it requires initialization from an [iterator](https://crystal-lang.org/api/Iterator.html) of strings.
* The response content is not directly accessible. The only way to obtain the actual response content is by iterating through the streamed content iterator, which can be accessed through the [`Marten::HTTP::Response::Streaming#streamed_content`](pathname:///api/dev/Marten/HTTP/Response/Streaming.html#streamed_content%3AIterator(String)-instance-method) method. However, this is handled by Marten itself when sending the response to the browser, so you shouldn't need to worry about it.

To generate streaming responses, you can either instantiate [`Marten::HTTP::Response::Streaming`](pathname:///api/dev/Marten/HTTP/Response/Streaming.html) objects directly, or you can also leverage the [`#respond`](pathname:///api/dev/Marten/Handlers/Base.html#respond(streamed_content%3AIterator(String)%2Ccontent_type%3DHTTP%3A%3AResponse%3A%3ADEFAULT_CONTENT_TYPE%2Cstatus%3D200)-instance-method) helper method, which works similarly to the [`#respond`](#respond) variant for response content strings.

For example, the following handler generates a CSV and streams its content by leveraging the [`#respond`](pathname:///api/dev/Marten/Handlers/Base.html#respond(streamed_content%3AIterator(String)%2Ccontent_type%3DHTTP%3A%3AResponse%3A%3ADEFAULT_CONTENT_TYPE%2Cstatus%3D200)-instance-method) helper method:

```crystal
require "csv"

class StreamingTestHandler < Marten::Handler
  def get
    respond(streaming_iterator, content_type: "text/csv")
  end

  private def streaming_iterator
    csv_io = IO::Memory.new
    csv_builder = CSV::Builder.new(io: csv_io)

    (1..1000000).each.map do |idx|
      csv_builder.row("Row #{idx}", "Val #{idx}")

      row_content = csv_io.to_s

      csv_io.rewind
      csv_io.flush

      row_content
    end
  end
end
```

:::caution
When considering streaming responses, it is crucial to understand that the process of streaming ties up a worker process for the entire response duration. This can significantly impact your worker's performance, so it's essential to use this approach only when necessary. Generally, it's better to carry out expensive content generation tasks outside the request-response cycle to avoid any negative impact on your worker's performance.
:::
