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




