---
title: Uploading files
description: Learn how to upload files.
sidebar_label: Uploading files
---

Marten gives you the ability to interact with uploaded files. These files are made available with each HTTP request object, and it is also possible to validate them using schemas. The following document explains how to expect and manipulate uploaded files, and what are their associated characteristics.

## Accessing uploaded files

Uploaded files are made available in the [`#data`](pathname:///api/dev/Marten/HTTP/Request.html#data%3AParams%3A%3AData-instance-method) hash-like object of any HTTP request object (instance of [`Marten::HTTP::Request`](pathname:///api/dev/Marten/HTTP/Request.html)). These file objects are instances of the [`Marten::HTTP::UploadedFile`](pathname:///api/dev/Marten/HTTP/UploadedFile.html) class.

For example, you could access and process an `uploaded_file` file originating from an HTML form using a handler like this:

```crystal
class ProcessUploadedFileHandler < Marten::Handler
  def post
    file = request.data["uploaded_file"].as(Marten::HTTP::UploadedFile)
    respond "Processed file: #{file.filename}"
  end
end
```

[`Marten::HTTP::UploadedFile`](pathname:///api/dev/Marten/HTTP/UploadedFile.html) objects give you access to the following key methods, which allow you to interact with the uploaded file and its content:

* `#filename` returns the name of the uploaded file
* `#size` returns the size of the uploaded file
* `#io` returns a regular [`IO`](https://crystal-lang.org/api/IO.html) object allowing to read the content of the file and interact with it

:::info Where are uploaded files stored?
All uploaded files are automatically persisted to a temporary file in the system's temporary directory (usually this corresponds to the `/tmp` folder).
:::

## Expecting uploaded files with schemas

If you use [schemas](../schemas/introduction.md) to validate input data (such as form data), then it's worth noting that you can explicitly define that you expect files in the validated data. The simplest way to do that is to make use of the [`file`](../schemas/reference/fields.md#file) or [`image`](../schemas/reference/fields.md#image) schema field.

For example, you could define the following schema:

```crystal
class UploadFileSchema < Marten::Schema
  field :uploaded_file, :file
end
```

And use it in a regular [schema generic handler](../handlers-and-http/reference/generic-handlers.md#processing-a-schema) like this:

```crystal
class UploadFileHandler < Marten::Handlers::Schema
  schema UploadFileSchema
  template_name "upload_file.html"
  success_url "/"

  def process_valid_schema
    file = schema.validated_data["uploaded_file"]
    # Do something with the uploaded file...

    super
  end
end
```

The presence/absence of the file (and - optionally - some of its attributes) will be validated according to the schema definition when `POST` requests are processed by the handler.

## Persisting uploaded files in model records

Models can define [`file`](../models-and-databases/reference/fields.md#file) or [`image`](../models-and-databases/reference/fields.md#image) fields and persist "references" of uploaded files in their rows. This allows "retaining" specific uploaded files and associating their references with specific model records.

For example, we could modify the handler in the previous section so that it persists and associate the uploaded file to a new `Attachment` record as follows:

```crystal
class UploadFileHandler < Marten::Handlers::Schema
  schema UploadFileSchema
  template_name "upload_file.html"
  success_url "/"

  def process_valid_schema
    file = schema.validated_data["uploaded_file"]
    // highlight-next-line
    Attachment.create!(uploaded_file: file)

    super
  end
end
```

Here, the `UploadFileHandler` inherits from the [`Marten::Handlers::Schema`](pathname:///api/dev/Marten/Handlers/Schema.html) generic handler. It would also make sense to leverage the [`Marten::Handlers::RecordCreate`](pathname:///api/dev/Marten/Handlers/RecordCreate.html) generic handler to process the schema and create the `Attachment` record at the same time.
