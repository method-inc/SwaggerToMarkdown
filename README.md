Here at Skookum we write a lot of REST services.  REST services provides a great integration point between frontend and backend developers.  This makes it easy to split work into large units, frontend development and backend development.  Frontend developers write tremendously awesome user interfaces with clean markup and a performant and responsive user experience.  Backend developers write testable, maintainable, performant, and robust service code.  The REST service specification is the glue that holds it all together.  A specification allows frontend developers to start immediately by mocking the REST service responses with real data.  A specification allows backend developers to start writing unit tests to ensure their code meets the desired state.

We all agree a REST service specification is a great tool to streamline and enhance our development process.  We also all agree that writing documention is about as fun as a root canal.  I have found a great tool to make this process easier-Swagger-UI [https://github.com/wordnik/swagger-ui].  The Swagger set of tools is an entire toolset revolved around generating REST service documentation.  At its core is the Swagger specification.  Here is an example:

```javascript
{
  "apiVersion":"0.2",
  "swaggerVersion":"1.1-SNAPSHOT",
  "basePath":"http://petstore.swagger.wordnik.com/api",
  "resourcePath":"/store",
  "apis":[
    {
      "path":"/store.{format}/order/{orderId}",
      "description":"Operations about store",
      "operations":[
        {
          "httpMethod":"GET",
          "summary":"Find purchase order by ID",
          "notes":"For valid response try integer IDs with value <= 5. Anything above 5 or nonintegers will generate API errors",
          "responseClass":"Order",
          "nickname":"getOrderById",
          "parameters":[
            {
              "name":"orderId",
              "description":"ID of pet that needs to be fetched",
              "paramType":"path",
              "required":true,
              "allowMultiple":false,
              "dataType":"string"
            }
          ],
          "errorResponses":[
            {
              "code":400,
              "reason":"Invalid ID supplied"
            },
            {
              "code":404,
              "reason":"Order not found"
            }
          ]
        },
        {
          "httpMethod":"DELETE",
          "summary":"Delete purchase order by ID",
          "notes":"For valid response try integer IDs with value < 1000. Anything above 1000 or nonintegers will generate API errors",
          "responseClass":"void",
          "nickname":"deleteOrder",
          "parameters":[
            {
              "name":"orderId",
              "description":"ID of the order that needs to be deleted",
              "paramType":"path",
              "required":true,
              "allowMultiple":false,
              "dataType":"string"
            }
          ],
          "errorResponses":[
            {
              "code":400,
              "reason":"Invalid ID supplied"
            },
            {
              "code":404,
              "reason":"Order not found"
            }
          ]
        }
      ]
    }
  ]
}
```

Swagger-UI is a tool that will transform the Swagger specification into a fully functional REST client that allows developers not only to view the REST documentation, but also interact with the REST API.  You can view example requests, example responses, and even input arguments and see how the responses change.  Overall its an awesome discovery tool and really helps developers, both frontend for discovery, and backend for testing and demoing.

In our use of Swagger-UI we came across one issue though.  Swagger-UI is only good if users have access to the tool.  If however you aren't able to put Swagger-UI in a public space, the users will not be able to view the documentation or interact with the API.  For example if you and your clients are on different networks, and the API should not be exposed on the public web.  This leads you back to writing your own API documentation by hand again and losing the power of the Swagger specification.

Well one handy thing about a specification is that, well its a specification.  This means as developers we know it follows very specific rules.  We can write tools that interact with that specification.  So I decided to write a Swagger-to-Markdown script.  This script can be found here https://github.com/Skookum/SwaggerToMarkdown/blob/master/swagger-to-markdown.rb.  It takes a number of parameters, but the main parameters it takes is the Swagger specification for your API.  It will traverse your specification and generate a static Markdown file that contains a lot of the same information as the dynamic Swagger-UI tool.  It writes out all the operations, their arguments, their error codes, and will even perform curl operations to generate example responses and example requests.  Here is an example markdown file that was generated with our script.

    ./swagger-to-markdown.rb -r resources.json -p parameters.json -n Demo -o test.md -s pet.json

or reading from a remote server:

    ./swagger-to-markdown.rb -r resources.json -p parameters.json -n Demo -o test.md -s http://petstore.swagger.wordnik.com/api/pet.json

One thing to note is that this remote read is not performing any type of validation so please use this only on trusted resources.

#Demo 0.2 REST API
Base Path: http://petstore.swagger.wordnik.com/api

[Please add API specific content here]


##General Considerations
[Please add API specific content here]


##Pet Resource
Operations about pets

###Find pet by ID

Returns a pet when ID < 10. ID > 10 or nonintegers will simulate API error conditions
####Definition


    GET /pet.{format}/{petId}

####Arguments
* **petId** - ID of pet that needs to be fetched


####Example Request
    curl http://petstore.swagger.wordnik.com/api/pet.json/1

####Example Response
    {
      "id": 1,
      "category": {
        "id": 2,
        "name": "Cats"
      },
      "name": "Cat 1",
      "photoUrls": [
        "url1",
        "url2"
      ],
      "tags": [
        {
          "id": 1,
          "name": "tag1"
        },
        {
          "id": 2,
          "name": "tag2"
        }
      ],
      "status": "available"
    }

####Potential Errors
* **400** - Invalid ID supplied
* **404** - Pet not found


###Add a new pet to the store

[Please add operation information to the notes section]

####Definition


    POST /pet.{format}

####Arguments
* [Please add a name for argument] - Pet object that needs to be added to the store


####Example Request
    curl -X POST -H "Content-Type:application/json" -d '{ "id": 1, "category": { "id": 2, "name": "Cats" }, "name": "Cat 1", "photoUrls": [ "url1", "url2" ], "tags": [ { "id": 1, "name": "tag1" }, { "id": 2, "name": "tag2" } ], "status": "available" }' http://petstore.swagger.wordnik.com/api/pet.json

####Example Response
    "SUCCESS"

####Potential Errors
* **405** - Invalid input


###Update an existing pet

[Please add operation information to the notes section]

####Definition


    PUT /pet.{format}

####Arguments
* [Please add a name for argument] - Pet object that needs to be updated in the store


####Example Request
    curl -X PUT -H "Content-Type:application/json" -d '{ "id": 1, "category": { "id": 2, "name": "Cats" }, "name": "Cat 1", "photoUrls": [ "url1", "url2" ], "tags": [ { "id": 1, "name": "tag1" }, { "id": 2, "name": "tag2" } ], "status": "available" }' http://petstore.swagger.wordnik.com/api/pet.json

####Example Response
    "SUCCESS"

####Potential Errors
* **400** - Invalid ID supplied
* **404** - Pet not found
* **405** - Validation exception

Now we have another tool in our toolbox.  For now this script lives in one of our organization's repositories, but once I clean it up a little more I plan on giving it over to Wordnik.  I hope others will find a use for this script.
