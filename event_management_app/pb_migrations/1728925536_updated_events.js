/// <reference path="../pb_data/types.d.ts" />
migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("p8klmgyiw7hc6k6")

  collection.createRule = "createdBy.isAdmin = true"
  collection.updateRule = "createdBy.isAdmin = true"
  collection.deleteRule = "createdBy.isAdmin = true"

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("p8klmgyiw7hc6k6")

  collection.createRule = null
  collection.updateRule = null
  collection.deleteRule = null

  return dao.saveCollection(collection)
})
