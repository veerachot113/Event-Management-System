/// <reference path="../pb_data/types.d.ts" />
migrate((db) => {
  const collection = new Collection({
    "id": "br0j8i1echgyplm",
    "created": "2024-10-16 19:31:50.849Z",
    "updated": "2024-10-16 19:31:50.849Z",
    "name": "sss",
    "type": "base",
    "system": false,
    "schema": [
      {
        "system": false,
        "id": "sl7mx5pl",
        "name": "f",
        "type": "text",
        "required": false,
        "presentable": false,
        "unique": false,
        "options": {
          "min": null,
          "max": null,
          "pattern": ""
        }
      }
    ],
    "indexes": [],
    "listRule": null,
    "viewRule": null,
    "createRule": null,
    "updateRule": null,
    "deleteRule": null,
    "options": {}
  });

  return Dao(db).saveCollection(collection);
}, (db) => {
  const dao = new Dao(db);
  const collection = dao.findCollectionByNameOrId("br0j8i1echgyplm");

  return dao.deleteCollection(collection);
})
