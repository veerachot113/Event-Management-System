/// <reference path="../pb_data/types.d.ts" />
migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("p8klmgyiw7hc6k6")

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "jmklplmw",
    "name": "participants",
    "type": "text",
    "required": false,
    "presentable": false,
    "unique": false,
    "options": {
      "min": null,
      "max": null,
      "pattern": ""
    }
  }))

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("p8klmgyiw7hc6k6")

  // remove
  collection.schema.removeField("jmklplmw")

  return dao.saveCollection(collection)
})
