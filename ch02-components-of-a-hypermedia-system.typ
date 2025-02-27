#import "lib/definitions.typ": *
#import "lib/snippets.typ": fielding-rest-thesis

== Components Of A Hypermedia System

A _hypermedia system_ consists of a number of components, including:

- A hypermedia, such as HTML.
- A network protocol, such as HTTP.
- A server that presents a hypermedia API responding to network requests with hypermedia responses.
- A client that properly interprets those responses.

In this chapter we will look at these components and their implementation in the
context of the web.

Once we have reviewed the major components of the web as a hypermedia system, we
will look at some key ideas behind this system --- especially as developed by
Roy Fielding in his dissertation, "Architectural Styles and the Design of
Network-based Software Architectures." We will see where the terms
REpresentational State Transfer (REST), RESTful and Hypermedia As The Engine Of
Application State (HATEOAS) come from, and we will analyze these terms in the
context of the web.

This should give you a stronger understanding of the theoretical basis of the
web as a hypermedia system, how it is supposed to fit together, and why
Hypermedia-Driven Applications are RESTful, whereas JSON APIs --- despite the
way the term REST is currently used in the industry --- are not.

=== Components Of A Hypermedia System <_components_of_a_hypermedia_system>

==== The Hypermedia <_the_hypermedia>
The fundamental technology of a hypermedia system is a hypermedia that allows a
client and server to communicate with one another in a dynamic, non-linear
fashion. Again, what makes a hypermedia a hypermedia is the presence of _hypermedia controls_:
elements that allow users to select non-linear actions within the hypermedia.
Users can
_interact_ with the media in a manner beyond simply reading from start to end.

We have already mentioned the two primary hypermedia controls in HTML, anchors
and forms, which allow a browser to present links and operations to a user
through a browser.

#index[Uniform Resource Locator (URL)]
In the case of HTML, these links and forms typically specify the target of their
operations using _Uniform Resource Locators (URLs)_:

/ Uniform Resource Locator: #[
    A uniform resource locator is a textual string that refers to, or
    _points to_ a location on a network where a _resource_ can be retrieved from, as
    well as the mechanism by which the resource can be retrieved.
  ]

A URL is a string consisting of various subcomponents:

#figure(caption: [URL Components],
```
[scheme]://[userinfo]@[host]:[port][path]?[query]#[fragment]
```)

Many of these subcomponents are not required, and are often omitted.

A typical URL might look like this:

#figure(caption: [A simple URL],
```
https://hypermedia.systems/book/contents/
```)

This particular URL is made up of the following components:
- A protocol or scheme (in this case, `https`)
- A domain (e.g., `hypermedia.systems`)
- A path (e.g., `/book/contents`)

This URL uniquely identifies a retrievable _resource_ on the internet, to which
an _HTTP Request_ can be issued by a hypermedia client that "speaks" HTTPS, such
as a web browser. If this URL is found as the reference of a hypermedia control
within an HTML document, it implies that there is a _hypermedia server_ on the
other side of the network that understands HTTPS as well, and that can respond
to this request with a _representation_ of the given resource (or redirect you
to another location, etc.)

Note that URLs are often not written out entirely within HTML. It is very common
to see anchor tags that look like this, for example:

#figure(caption: [A Simple Link],
```html
<a href="/book/contents/">Table Of Contents</a>
```)

Here we have a _relative_ hypermedia reference, where the protocol, host and
port are _implied_ to be that of the "current document," that is, the same as
whatever the protocol and server were to retrieve the current HTML page. So, if
this link was found in an HTML document retrieved from `https://hypermedia.systems/`,
then the implied URL for this anchor would be `https://hypermedia.systems/book/contents/`.

==== Hypermedia Protocols <_hypermedia_protocols>
The hypermedia control (link) above tells a browser: "When a user clicks on this
text, issue a request to
`https://hypermedia.systems/book/contents/` using the Hypertext Transfer
Protocol," or HTTP.

HTTP is the _protocol_ used to transfer HTML (hypermedia) between browsers
(hypermedia clients) and servers (hypermedia servers) and, as such, is the key
network technology that binds the distributed hypermedia system of the web
together.

HTTP version 1.1 is a relatively simple network protocol, so lets take a look at
what the `GET` request triggered by the anchor tag would look like. This is the
request that would be sent to the server found at
`hypermedia.systems`, on port `80` by default:

#figure(
```http
GET /book/contents/ HTTP/1.1
Accept: text/html,*/*
Host: hypermedia.systems
```)

The first line specifies that this is an HTTP `GET` request. It then specifies
the path of the resource being requested. Finally, it contains the HTTP version
for this request.

After that are a series of HTTP _request headers_: individual lines of
name/value pairs separated by a colon. The request headers provide
_metadata_ that can be used by the server to determine exactly how to respond to
the client request. In this case, with the `Accept`
header, the browser is saying it would prefer HTML as a response format, but
will accept any server response.

Next, it has a `Host` header that specifies which server the request has been
sent to. This is useful when multiple domains are hosted on the same host.

An HTTP response from a server to this request might look something like this:

#figure(
```http
HTTP/1.1 200 OK
Content-Type: text/html; charset=utf-8
Content-Length: 870
Server: Werkzeug/2.0.2 Python/3.8.10
Date: Sat, 23 Apr 2022 18:27:55 GMT

<html lang="en">
<body>
  <header>
    <h1>HYPERMEDIA SYSTEMS</h1>
  </header>
  ...
</body>
</html>
```)

In the first line, the HTTP Response specifies the HTTP version being used,
followed by a _response code_ of `200`, indicating that the given resource was
found and that the request succeeded. This is followed by a string, `OK` that
corresponds to the response code. (The actual string doesn’t matter, it is the
response code that tells the client the result of a request, as we will discuss
in more detail below.)

After the first line of the response, as with the HTTP Request, we see a series
of _response headers_ that provide metadata to the client to assist in
displaying the _representation_ of the resource correctly.

Finally, we see some new HTML content. This content is the HTML
_representation_ of the requested resource, in this case a table of contents of
a book. The browser will use this HTML to replace the entire content in its
display window, showing the user this new page, and updating the address bar to
reflect the new URL.

===== HTTP methods <_http_methods>

#index[HTTP methods]
#index[HTTP methods][GET]
#index[HTTP methods][POST]
#index[HTTP methods][PUT]
#index[HTTP methods][PATCH]
#index[HTTP methods][DELETE]
The anchor tag above issued an HTTP `GET`, where `GET` is the
_method_ of the request. The particular method being used in an HTTP request is
perhaps the most important piece of information about it, after the actual
resource that the request is directed at.

There are many methods available in HTTP; the ones of most practical importance
to developers are the following:

/ `GET`: #[
    A GET request retrieves the representation of the specified resource. GET
    requests should not mutate data.
  ]

/ `POST`: #[
    A POST request submits data to the specified resource. This will often result in
    a mutation of state on the server.
  ]

/ `PUT`: #[
    A PUT request replaces the data of the specified resource. This results in a
    mutation of state on the server.
  ]

/ `PATCH`: #[
    A PATCH request replaces the data of the specified resource. This results in a
    mutation of state on the server.
  ]

/ `DELETE`: #[
    A DELETE request deletes the specified resource. This results in a mutation of
    state on the server.
  ]

These methods _roughly_ line up with the
"Create/Read/Update/Delete" or #indexed[CRUD] pattern found in many
applications:- `POST` corresponds with Creating a resource.- `GET` corresponds
with Reading a resource.- `PUT` and `PATCH` correspond with Updating a
resource.- `DELETE` corresponds, well, with Deleting a resource.

#sidebar[Put vs. Post][
While HTTP Actions correspond roughly to CRUD, they are not the same. The
technical specifications for these methods make no such connection, and are
often somewhat difficult to read. Here, for example, is the documentation on the
distinction between a `POST` and a `PUT` from
#link("https://www.rfc-editor.org/rfc/rfc9110")[RFC-9110].

#blockquote(
  attribution: [RFC-9110, https:\/\/www.rfc-editor.org/rfc/rfc9110\#section-9.3.4],
)[
  The target resource in a POST request is intended to handle the enclosed
  representation according to the resource’s own semantics, whereas the enclosed
  representation in a PUT request is defined as replacing the state of the target
  resource. Hence, the intent of PUT is idempotent and visible to intermediaries,
  even though the exact effect is only known by the origin server.
]

In plain terms, a `POST` can be handled by a server pretty much however it
likes, whereas a `PUT` should be handled as a "replacement" of the resource,
although the language, once again allows the server to do pretty much whatever
it would like within the constraint of being
#link(
  "https://developer.mozilla.org/en-US/docs/Glossary/Idempotent",
)[_idempotent_].
]

In a properly structured HTML-based hypermedia system you would use an
appropriate HTTP method for the operation a particular hypermedia control
performs. For example, if a hypermedia control such as a button
_deletes_ a resource, ideally it should issue an HTTP `DELETE`
request to do so.

A strange thing about HTML, though, is that the native hypermedia controls can
only issue HTTP `GET` and `POST` requests.

Anchor tags always issue a `GET` request.

Forms can issue either a `GET` or `POST` using the `method` attribute.

Despite the fact that HTML --- the world’s most popular hypermedia --- has been
designed alongside HTTP (which is the Hypertext Transfer Protocol, after all!):
if you wish to issue `PUT`, `PATCH` or `DELETE` requests you currently _have to_ resort
to JavaScript to do so. Since a
`POST` can do almost anything, it ends up being used for any mutation on the
server, and `PUT`, `PATCH` and `DELETE` are left aside in plain HTML-based
applications.

This is an obvious shortcoming of HTML as a hypermedia; it would be wonderful to
see this fixed in the HTML specification. For now, in Chapter 4, we’ll discuss
ways to get around this.

===== HTTP response codes <_http_response_codes>
HTTP request methods allow a client to tell a server _what_ to do to a given
resource. HTTP responses contain _response codes_, which tell a client what the
result of the request was. HTTP response codes are numeric values that are
embedded in the HTTP response, as we saw above.

The most familiar response code for web developers is probably `404`, which
stands for "Not Found." This is the response code that is returned by web
servers when a resource that does not exist is requested from them.

#index[HTTP response][codes]
HTTP breaks response codes up into various categories:

/ `100`-`199`: Informational responses that provide information about how the server is
  processing the response.

/ `200`-`299`: Successful responses indicating that the request succeeded.

/ `300`-`399`: Redirection responses indicating that the request should be sent to some other
  URL.

/ `400`-`499`: Client error responses indicating that the client made some sort of bad request
  (e.g., asking for something that didn’t exist in the case of `404` errors).

/ `500`-`599`: Server error responses indicating that the server encountered an error
  internally as it attempted to respond to the request.

Within each of these categories there are multiple response codes for specific
situations.

Here are some of the more common or interesting ones:

/ `200 OK`: The HTTP request succeeded.

/ `301 Moved Permanently`: The URL for the requested resource has moved to a new location permanently, and
  the new URL will be provided in the `Location` response header.

/ `302 Found`: The URL for the requested resource has moved to a new location temporarily, and
  the new URL will be provided in the `Location` response header.

/ `303 See Other`: The URL for the requested resource has moved to a new location, and the new URL
  will be provided in the `Location` response header. Additionally, this new URL
  should be retrieved with a `GET` request.

/ `401 Unauthorized`: The client is not yet authenticated (yes, authenticated, despite the name) and
  must be authenticated to retrieve the given resource.

/ `403 Forbidden`: The client does not have access to this resource.

/ `404 Not Found`: The server cannot find the requested resource.

/ `500 Internal Server Error`: The server encountered an error when attempting to process the response.

There are some fairly subtle differences between HTTP response codes (and, to be
honest, some ambiguities between them). The difference between a `302` redirect
and a `303` redirect, for example, is that the former will issue the request to
the new URL using the same HTTP method as the initial request, whereas the
latter will always use a `GET`. This is a small but often crucial difference, as
we will see later in the book.

A well crafted Hypermedia-Driven Application will take advantage of both HTTP
methods and HTTP response codes to create a sensible hypermedia API. You do not
want to build a Hypermedia-Driven Application that uses a `POST` method for all
requests and responds with `200 OK` for every response, for example. (Some JSON
Data APIs built on top of HTTP do exactly this!)

When building a Hypermedia-Driven Application, you want, instead, to go
"with the grain" of the web and use HTTP methods and response codes as they were
designed to be used.

===== Caching HTTP responses <_caching_http_responses>

#index[HTTP response][caching]
A constraint of REST (and, therefore, a feature of HTTP) is the notion of
caching responses: a server can indicate to a client (as well as intermediary
HTTP servers) that a given response can be cached for future requests to the
same URL.

#index[HTTP response header][Cache-Control]
The cache behavior of an HTTP response from a server can be indicated with the `Cache-Control` response
header. This header can have a number of different values indicating the
cacheability of a given response. If, for example, the header contains the value `max-age=60`,
this indicates that a client may cache this response for 60 seconds, and need
not issue another HTTP request for that resource until that time limit has
expired.

#index[HTTP response header][Vary]
Another important caching-related response header is `Vary`. This response
header can be used to indicate exactly what headers in an HTTP Request form the
unique identifier for a cached result. This becomes important to allow the
browser to correctly cache content in situations where a particular header
affects the form of the server response.

#index[HTTP response header][custom]
#index[HX-Request][about]
A common pattern in htmx-powered applications, for example, is to use a custom
header set by htmx, `HX-Request`, to differentiate between
"normal" web requests and requests submitted by htmx. To properly cache the
response to these requests, the `HX-Request` request header must be indicated by
the `Vary` response header.

A full discussion of caching HTTP responses is beyond the scope of this chapter;
see the
#link(
  "https://developer.mozilla.org/en-US/docs/Web/HTTP/Caching",
)[MDN Article on HTTP Caching]
if you would like to know more on the topic.

==== Hypermedia Servers <_hypermedia_servers>
Hypermedia servers are any server that can respond to an HTTP request with an
HTTP response. Because HTTP is so simple, this means that nearly any programming
language can be used to build a hypermedia server. There are a vast number of
libraries available for building HTTP-based hypermedia servers in nearly every
programming language imaginable.

This turns out to be one of the best aspects of adopting hypermedia as your
primary technology for building a web application: it removes the pressure to
adopt JavaScript as a backend technology. If you use a JavaScript-heavy Single
Page Application-based front end, and you use JSON Data APIs, you are going to
feel significant pressure to deploy JavaScript on the back end as well.

In this latter situation, you already have a ton of code written in JavaScript.
Why maintain two separate code bases in two different languages? Why not create
reusable domain logic on the client-side as well as the server-side? Now that
JavaScript has excellent server-side technologies available like Node and Deno,
why not just use a single language for everything?

In contrast, building a Hypermedia-Driven Application gives you a lot more
freedom in picking the back end technology you want to use. Your decision can be
based on the domain of your application, what languages and server software you
are familiar with or are passionate about, or just what you feel like trying
out.

You certainly aren’t writing your server-side logic in HTML! And every major
programming language has at least one good web framework and templating library
that can be used to handle HTTP requests cleanly.

If you are doing something in big data, perhaps you’d like to use Python, which
has tremendous support for that domain.

If you are doing AI work, perhaps you’d like to use Lisp, leaning on a language
with a long history in that area of research.

Maybe you are a functional programming enthusiast and want to use OCaml or
Haskell. Perhaps you just really like Julia or Nim.

These are all perfectly valid reasons for choosing a particular server-side
technology!

By using hypermedia as your system architecture, you are freed up to adopt any
of these choices. There simply isn’t a large JavaScript code base on the front
end pressuring you to adopt JavaScript on the back end.

#sidebar[Hypermedia On Whatever you'd Like (HOWL)][
  In the htmx community we call this (with tongue in cheek) the HOWL stack:
  Hypermedia On Whatever you’d Like. The htmx community is multi-language and
  multi-framework, there are rubyists as well as pythonistas, lispers as well as
  haskellers. There are even JavaScript enthusiasts! All these languages and
  frameworks are able to adopt hypermedia, and are able to still share techniques
  and offer support to one another because they share a common underlying
  architecture: they are all using the web as a hypermedia system.

  Hypermedia, in this sense, provides a "universal language" for the web that we
  can all use.
]

==== Hypermedia Clients <_hypermedia_clients>

#index[web browsers]
We now come to the final major component in a hypermedia system: the hypermedia
client. Hypermedia _clients_ are software that understand how to interpret a
particular hypermedia, and the hypermedia controls within it, properly. The
canonical example, of course, is the web browser, which understands HTML and can
present it to a user to interact with. Web browsers are incredibly sophisticated
pieces of software. (So sophisticated, in fact, that they are often re-purposed
away from being a hypermedia client, to being a sort of cross-platform virtual
machine for launching Single Page Applications.)

Browsers aren’t the only hypermedia clients out there, however. In the last
section of this book we will look at Hyperview, a mobile-oriented hypermedia.
One of the outstanding features of Hyperview is that it doesn’t simply provide a
hypermedia, HXML, but also provides a
_working hypermedia client_ for that hypermedia. This makes building a proper
Hypermedia-Driven Application with Hyperview extremely easy.

A crucial feature of a hypermedia system is what is known as _the uniform interface_.
We discuss this concept in depth in the next section on REST. What is often
ignored in discussions about hypermedia is how important the hypermedia client
is in taking advantage of this uniform interface. A hypermedia client must know
how to properly interpret and present hypermedia controls found in a hypermedia
response from a hypermedia server for the whole hypermedia system to hang
together. Without a sophisticated client that can do this, hypermedia controls
and a hypermedia-based API are much less useful.

This is one reason why JSON APIs have rarely adopted hypermedia controls
successfully: JSON APIs are typically consumed by code that is expecting a fixed
format and that isn’t designed to be a hypermedia client. This is totally
understandable: building a good hypermedia client is hard! For JSON API clients
like this, the power of hypermedia controls embedded within an API response is
irrelevant and often simply annoying:

#blockquote(
  attribution: [Freddie Karlbom,
    https:\/\/techblog.commercetools.com/graphql-and-rest-level-3-hateoas-70904ff1f9cf],
)[
  The short answer to this question is that HATEOAS isn’t a good fit for most
  modern use cases for APIs. That is why after almost 20 years, HATEOAS still
  hasn’t gained wide adoption among developers. GraphQL on the other hand is
  spreading like wildfire because it solves real-world problems.
]

HATEOAS will be described in more detail below, but the takeaway here is that a
good hypermedia client is a necessary component within a larger hypermedia
system.

=== REST <_rest>
Now that we have reviewed the major components of a hypermedia system, it’s time
to look more deeply into the concept of REST. The term "REST" comes from Roy
Fielding’s PhD dissertation on the architecture of the web. Fielding wrote his
dissertation at U.C. Irvine, after having helped build much of the
infrastructure of the early web, including the Apache web server. Roy was
attempting to formalize and describe the novel distributed computing system that
he had helped to build.

We are going to focus on what we feel is the most important section of
Fielding’s writing, from a web development perspective: Section 5.1. This
section contains the core concepts (Fielding calls them
_constraints_) of Representational State Transfer, or REST.

Before we get into the muck, however, it is important to understand that
Fielding discusses REST as a _network architecture_, that is, as an entirely
different way to architect a distributed system. And, further, as a novel
network architecture that should be _contrasted_ with earlier approaches to
distributed systems.

It is also important to emphasize that, at the time Fielding wrote his
dissertation, JSON APIs and AJAX did not exist. He was describing the early web,
with HTML being transferred over HTTP by early browsers, as a hypermedia system.

Today, in a strange turn of events, the term "REST" is mainly associated with
JSON Data APIs, rather than with HTML and hypermedia. This is extremely funny
once you realize that the vast majority of JSON Data APIs aren’t RESTful, in the
original sense, and, in fact, _can’t_
be RESTful, since they aren’t using a natural hypermedia format.

To re-emphasize: REST, as coined by Fielding, describes the
_pre-API web_, and letting go of the current, common usage of the term REST to
simply mean "a JSON API" is necessary to develop a proper understanding of the
idea.

==== The "Constraints" of REST <_the_constraints_of_rest>

#index[Fielding, Roy]
#index[REST][constraints]
In his dissertation, Fielding defines various "constraints" to describe how a
RESTful system must behave. This approach can feel a little round-about and
difficult to follow for many people, but it is an appropriate approach for an
academic document. Given a bit of time thinking about the constraints he
outlines and some concrete examples of those constraints it will become easy to
assess whether a given system actually satisfies the architectural requirements
of REST or not.

Here are the constraints of REST Fielding outlines:- It is a client-server
architecture (section 5.1.2).- It must be stateless; (section 5.1.3) that is,
every request contains all information necessary to respond to that request.- It
must allow for caching (section 5.1.4).- It must have a _uniform interface_ (section
5.1.5).- It is a layered system (section 5.1.6).- Optionally, it can allow for
Code-On-Demand (section 5.1.7), that is, scripting.

Let’s go through each of these constraints in turn and discuss them in detail,
looking at how (and to what extent) the web satisfies each of them.

==== The Client-Server Constraint <_the_client_server_constraint>
See
#link(
  "https://www.ics.uci.edu/~fielding/pubs/dissertation/rest_arch_style.htm#sec_5_1_2",
)[Section 5.1.2]
for the Client-Server constraint.

The REST model Fielding was describing involved both _clients_
(browsers, in the case of the web) and _servers_ (such as the Apache Web Server
he had been working on) communicating via a network connection. This was the
context of his work: he was describing the network architecture of the World
Wide Web, and contrasting it with earlier architectures, notably thick-client
networking models such as the Common Object Request Broker Architecture (CORBA).

It should be obvious that any web application, regardless of how it is designed,
will satisfy this requirement.

==== The Statelessness Constraint <_the_statelessness_constraint>
See
#link(
  "https://www.ics.uci.edu/~fielding/pubs/dissertation/rest_arch_style.htm#sec_5_1_3",
)[Section 5.1.3]
for the Stateless constraint.

As described by Fielding, a RESTful system is stateless: every request should
encapsulate all information necessary to respond to that request, with no side
state or context stored on either the client or the server.

In practice, for many web applications today, we actually violate this
constraint: it is common to establish a _session cookie_ that acts as a unique
identifier for a given user and that is sent along with every request. While
this session cookie is, by itself, not stateful (it is sent with every request),
it is typically used as a key to look up information stored on the server, in
what is usually termed "the session."

This session information is typically stored in some sort of shared storage
across multiple web servers, holding things like the current user’s email or id,
their roles, partially created domain objects, caches, and so forth.

This violation of the Statelessness REST architectural constraint has proven to
be useful for building web applications and does not appear to have had a major
impact on the overall flexibility of the web. But it is worth bearing in mind that
even Web 1.0 applications often violate the purity of REST in the interest of
pragmatic trade-offs.

And it must be said that sessions _do_ cause additional operational complexity
headaches when deploying hypermedia servers; these may need shared access to
session state information stored across an entire cluster. So Fielding was
correct in pointing out that an ideal RESTful system, one that did not violate
this constraint, would be simpler and therefore more robust.

==== The Caching Constraint <_the_caching_constraint>
See
#link(
  "https://www.ics.uci.edu/~fielding/pubs/dissertation/rest_arch_style.htm#sec_5_1_4",
)[Section 5.1.4]
for the Caching constraint.

This constraint states that a RESTful system should support the notion of
caching, with explicit information on the cache-ability of responses for future
requests of the same resource. This allows both clients as well as intermediary
servers between a given client and final server to cache the results of a given
request.

As we discussed earlier, HTTP has a sophisticated caching mechanism via response
headers that is often overlooked or underutilized when building hypermedia
applications. Given the existence of this functionality, however, it is easy to
see how this constraint is satisfied by the web.

==== The Uniform Interface Constraint <_the_uniform_interface_constraint>
Now we come to the most interesting and, in our opinion, most innovative
constraint in REST: that of the _uniform interface_.

This constraint is the source of much of the _flexibility_ and
_simplicity_ of a hypermedia system, so we are going to spend some time on it.

See
#link(
  "https://www.ics.uci.edu/~fielding/pubs/dissertation/rest_arch_style.htm#sec_5_1_5",
)[Section 5.1.5]
for the Uniform Interface constraint.

In this section, Fielding says:

#blockquote(
  attribution: fielding-rest-thesis,
)[
  The central feature that distinguishes the REST architectural style from other
  network-based styles is its emphasis on a uniform interface between components…​
  In order to obtain a uniform interface, multiple architectural constraints are
  needed to guide the behavior of components. REST is defined by four interface
  constraints: identification of resources; manipulation of resources through
  representations; self-descriptive messages; and, hypermedia as the engine of
  application state
]

So we have four sub-constraints that, taken together, form the Uniform Interface
constraint.

===== Identification of resources <_identification_of_resources>
In a RESTful system, resources should have a unique identifier. Today the
concept of Universal Resource Locators (URLs) is common, but at the time of
Fielding’s writing they were still relatively new and novel.

What might be more interesting today is the notion of a _resource_, thus being
identified: in a RESTful system, _any_ sort of data that can be referenced, that
is, the target of a hypermedia reference, is considered a resource. URLs, though
common enough today, end up solving the very complex problem of uniquely
identifying any and every resource on the internet.

===== Manipulation of resources through representations <_manipulation_of_resources_through_representations>
In a RESTful system, _representations_ of the resource are transferred between
clients and servers. These representations can contain both data and metadata
about the request (such as "control data" like an HTTP method or response code).
A particular data format or
_media type_ may be used to present a given resource to a client, and that media
type can be negotiated between the client and the server.

We saw this latter aspect of the uniform interface in the `Accept`
header in the requests above.

===== Self-descriptive messages <_self_descriptive_messages>

#index[self-descriptive messages]
The Self-Descriptive Messages constraint, combined with the next one, HATEOAS,
form what we consider to be the core of the Uniform Interface, of REST and why
hypermedia provides such a powerful system architecture.

The Self-Descriptive Messages constraint requires that, in a RESTful system,
messages must be _self-describing_.

This means that _all information_ necessary to both display
_and also operate_ on the data being represented must be present in the
response. In a properly RESTful system, there can be no additional
"side" information necessary for a client to transform a response from a server
into a useful user interface. Everything must "be in" the message itself, in the
form of hypermedia controls.

This might sound a little abstract so let’s look at a concrete example.

Consider two different potential responses from an HTTP server for the URL `https://example.com/contacts/42`.

Both responses will return information about a contact, but each response will
take very different forms.

The first implementation returns an HTML representation:

#figure(
```html
<html lang="en">
<body>
<h1>Joe Smith</h1>
<div>
    <div>Email: joe@example.bar</div>
    <div>Status: Active</div>
</div>
<p>
    <a href="/contacts/42/archive">Archive</a>
</p>
</body>
</html>
```)

The second implementation returns a JSON representation:

#figure(
```json
{
  "name": "Joe Smith",
  "email": "joe@example.org",
  "status": "Active"
}
```)

What can we say about the differences between these two responses?

One thing that may initially jump out at you is that the JSON representation is
smaller than the HTML representation. Fielding notes exactly this trade-off when
using a RESTful architecture:

#blockquote(
  attribution: fielding-rest-thesis,
)[
  The trade-off, though, is that a uniform interface degrades efficiency, since
  information is transferred in a standardized form rather than one which is
  specific to an application’s needs.
]

So REST _trades off_ representational efficiency for other goals.

To understand these other goals, first notice that the HTML representation has a
hyperlink in it to navigate to a page to archive the contact. The JSON
representation, in contrast, does not have this link.

What are the ramifications of this fact for a _client_ of the JSON API?

#index[JSON API][vs. HTML]
What this means is that the JSON API client must know _in advance_
exactly what other URLs (and request methods) are available for working with the
contact information. If the JSON client is able to update this contact in some
way, it must know how to do so from some source of information _external_ to the
JSON message. If the contact has a different status, say "Archived", does this
change the allowable actions? If so, what are the new allowable actions?

The source of all this information might be API documentation, word of mouth or,
if the developer controls both the server and the client, internal knowledge.
But this information is implicit and _outside_
the response.

Contrast this with the hypermedia (HTML) response. In this case, the hypermedia
client (that is, the browser) needs only to know how to render the given HTML.
It doesn’t need to understand what actions are available for this contact: they
are simply encoded _within_ the HTML response itself as hypermedia controls. It
doesn’t need to understand what the status field means. In fact, the client
doesn’t even know what a contact is!

The browser, our hypermedia client, simply renders the HTML and allows the user,
who presumably understands the concept of a Contact, to make a decision on what
action to pursue from the actions made available in the representation.

This difference between the two responses demonstrates the crux of REST and
hypermedia, what makes them so powerful and flexible: clients (again, web
browsers) don’t need to understand _anything_ about the underlying resources
being represented.

Browsers only (only! As if it is easy!) need to understand how to interpret and
display hypermedia, in this case HTML. This gives hypermedia-based systems
unprecedented flexibility in dealing with changes to both the backing
representations and to the system itself.

===== Hypermedia As The Engine of Application State (HATEOAS) <_hypermedia_as_the_engine_of_application_state_hateoas>

The final sub-constraint on the Uniform Interface is that, in a RESTful system,
hypermedia should be "the engine of application state." This is sometimes
abbreviated as "#indexed[HATEOAS]", although Fielding prefers to use the
terminology "the hypermedia constraint" when discussing it.

This constraint is closely related to the previous self-describing message
constraint. Let us consider again the two different implementations of the
endpoint `/contacts/42`, one returning HTML and one returning JSON. Let’s update
the situation such that the contact identified by this URL has now been
archived.

What do our responses look like?

The first implementation returns the following HTML:

#figure(
```html
<html lang="en">
<body>
<h1>Joe Smith</h1>
<div>
    <div>Email: joe@example.bar</div>
    <div>Status: Archived</div>
</div>
<p>
    <a href="/contacts/42/unarchive">Unarchive</a>
</p>
</body>
</html>
```)

The second implementation returns the following JSON representation:

#figure(
```json
{
  "name": "Joe Smith",
  "email": "joe@example.org",
  "status": "Archived"
}
```)

The important point to notice here is that, by virtue of being a self-describing
message, the HTML response now shows that the "Archive" operation is no longer
available, and a new "Unarchive" operation has become available. The HTML
representation of the contact _encodes_
the state of the application; it encodes exactly what can and cannot be done
with this particular representation, in a way that the JSON representation does
not.

A client interpreting the JSON response must, again, understand not only the
general concept of a Contact, but also specifically what the
"status" field with the value "Archived" means. It must know exactly what
operations are available on an "Archived" contact, to appropriately display them
to an end user. The state of the application is not encoded in the response, but
rather conveyed through a mix of raw data and side channel information such as
API documentation.

Furthermore, in the majority of front end SPA frameworks today, this contact
information would live _in memory_ in a JavaScript object representing a model
of the contact, while the page data is held in the browser’s
#link(
  "https://developer.mozilla.org/en-US/docs/Web/API/Document_Object_Model",
)[Document Object Model]
(DOM). The DOM would be updated based on changes to this model, that is, the DOM
would "react" to changes to this backing JavaScript model.

This approach is certainly _not_ using Hypermedia As The Engine Of Application
State: rather, it is using a JavaScript model as the engine of application
state, and synchronizing that model with a server and with the browser.

With the HTML approach, the Hypermedia is, indeed, The Engine Of Application
State: there is no additional model on the client side, and all state is
expressed directly in the hypermedia, in this case HTML. As state changes on the
server, it is reflected in the representation (that is, HTML) sent back to the
client. The hypermedia client (a browser) doesn’t know anything about contacts,
what the concept of "Archiving" is, or anything else about the particular domain
model for this response: it simply knows how to render HTML.

Because a hypermedia client doesn’t need to know anything about the server model
beyond how to render hypermedia to a client, it is incredibly flexible with
respect to the representations it receives and displays to users.

===== HATEOAS & API churn <_hateoas_api_churn>
This last point is critical to understanding the flexibility of hypermedia, so
let’s look at a practical example of it in action. Consider a situation where a
new feature has been added to the web application with these two end points.
This feature allows you to send a message to a given Contact.

How would this change each of the two responses—​HTML and JSON—​from the server?

The HTML representation might now look like this:

#figure(
```html
<html lang="en">
<body>
<h1>Joe Smith</h1>
<div>
    <div>Email: joe@example.bar</div>
    <div>Status: Active</div>
</div>
<p>
    <a href="/contacts/42/archive">Archive</a>
    <a href="/contacts/42/message">Message</a>
</p>
</body>
</html>
```)

The JSON representation, on the other hand, might look like this:

#figure(
```json
{
  "name": "Joe Smith",
  "email": "joe@example.org",
  "status": "Active"
}
```)

Note that, once again, the JSON representation is unchanged. There is no
indication of this new functionality. Instead, a client must _know_
about this change, presumably via some shared documentation between the client
and the server.

Contrast this with the HTML response. Because of the uniform interface of the
RESTful model and, in particular, because we are using Hypermedia As The Engine
of Application State, no such exchange of documentation is necessary! Instead,
the client (a browser) simply renders the new HTML with this operation in it,
making this operation available for the end user without any additional coding
changes.

A pretty neat trick!

Now, in this case, if the JSON client is not properly updated, the error state
is relatively benign: a new bit of functionality is simply not made available to
users. But consider a more severe change to the API: what if the archive
functionality was removed? Or what if the URLs or the HTTP methods for these
operations changed in some way?

In this case, the JSON client may be broken in a much more serious manner.

The HTML response, however, would simply be updated to exclude the removed
options or to update the URLs used for them. Clients would see the new HTML,
display it properly, and allow users to select whatever the new set of
operations happens to be. Once again, the uniform interface of REST has proven
to be extremely flexible: despite a potentially radically new layout for our
hypermedia API, clients continue to work.

An important fact emerges from this: due to this flexibility, hypermedia APIs _do not have the versioning headaches that JSON Data APIs do_.

Once a Hypermedia-Driven Application has been "entered into" (that is, loaded
through some entry point URL), all functionality and resources are surfaced
through self-describing messages. Therefore, there is no need to exchange
documentation with the client: the client simply renders the hypermedia (in this
case HTML) and everything works out. When a change occurs, there is no need to
create a new version of the API: clients simply retrieve updated hypermedia,
which encodes the new operations and resources in it, and display it to users to
work with.

==== Layered System <_layered_system>
The final "required" constraint on a RESTful system that we will consider is The
Layered System constraint. This constraint can be found in
#link(
  "https://www.ics.uci.edu/~fielding/pubs/dissertation/rest_arch_style.htm#sec_5_1_6",
)[Section 5.1.6]
of Fielding’s dissertation.

To be frank, after the excitement of the uniform interface constraint, the "layered
system" constraint is a bit of a let down. But it is still worth understanding
and it is actually utilized effectively by The web. The constraint requires that
a RESTful architecture be "layered," allowing for multiple servers to act as
intermediaries between a client and the eventual "source of truth" server.

These intermediary servers can act as proxies, transform intermediate requests
and responses and so forth.

A common modern example of this layering feature of REST is the use of Content
Delivery Networks (CDNs) to deliver unchanging static assets to clients more
quickly, by storing the response from the origin server in intermediate servers
more closely located to the client making a request.

This allows content to be delivered more quickly to the end user and reduces
load on the origin server.

Not as exciting for web application developers as the uniform interface, at
least in our opinion, but useful nonetheless.

==== An Optional Constraint: Code-On-Demand <_an_optional_constraint_code_on_demand>
We called The Layered System constraint the final "required" constraint because
Fielding mentions one additional constraint on a RESTful system. This Code On
Demand constraint is somewhat awkwardly described as
"optional" (Section 5.1.7).

In this section, Fielding says:

#blockquote(
  attribution: fielding-rest-thesis,
)[
  REST allows client functionality to be extended by downloading and executing
  code in the form of applets or scripts. This simplifies clients by reducing the
  number of features required to be pre-implemented. Allowing features to be
  downloaded after deployment improves system extensibility. However, it also
  reduces visibility, and thus is only an optional constraint within REST.
]

So, scripting was and is a native aspect of the original RESTful model of the
web, and thus should of course be allowed in a Hypermedia-Driven Application.

However, in a Hypermedia-Driven Application the presence of scripting should _not_ change
the fundamental networking model: hypermedia should continue to be the engine of
application state, server communication should still consist of hypermedia
exchanges rather than, for example, JSON data exchanges, and so on. (JSON Data
API’s certainly have their place; in Chapter 10 we’ll discuss when and how to
use them).

Today, unfortunately, the scripting layer of the web, JavaScript, is quite often
used to _replace_, rather than augment the hypermedia model. We will elaborate
in a later chapter what scripting that does not replace the underlying
hypermedia system of the web looks like.

=== Conclusion <_conclusion>
After this deep dive into the components and concepts behind hypermedia systems
--- including Roy Fielding’s insights into their operation --- we hope you have
much better understanding of REST, and in particular, of the uniform interface
and HATEOAS. We hope you can see _why_ these characteristics make hypermedia
systems so flexible.

If you were not aware of the full significance of REST and HATEOAS before now,
don’t feel bad: it took some of us over a decade of working in web development,
and building a hypermedia-oriented library to boot, to understand the special
nature of HTML, hypermedia and the web!

#html-note[HTML5 Soup][
#blockquote(attribution: [Confucius])[
  The beginning of wisdom is to call things by their right names.
]

Elements like `<section>`, `<article>`, `<nav>`, `<header>`, `<footer>`,
`<figure>` have become a sort of shorthand for HTML.

By using these elements, a page can make false promises, like
`<article>` elements being self-contained, reusable entities, to clients like
browsers, search engines and scrapers that can’t know better. To avoid this:

- Make sure that the element you’re using fits your use case. Check the HTML spec.

- Don’t try to be specific when you can’t or don’t need to. Sometimes,
  `<div>` is fine.

#index[HTML][spec]
The most authoritative resource for learning about HTML is the HTML
specification. The current specification lives on
#link("https://html.spec.whatwg.org/multipage").#footnote[The single-page version is too slow to load and render on most computers.
  There’s also a "developers’ edition" at /dev, but the standard version has nicer
  styling.] There’s no need to rely on hearsay to keep up with developments in
HTML.

Section 4 of the spec features a list of all available elements, including what
they represent, where they can occur, and what they are allowed to contain. It
even tells you when you’re allowed to leave out closing tags!
]
