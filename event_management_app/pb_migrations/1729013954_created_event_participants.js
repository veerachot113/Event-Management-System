/// <reference path="../pb_data/types.d.ts" />
migrate((db) => {
  const collection = new Collection({
    "id": "7vmxwnnk8rcw3bh",
    "created": "2024-10-15 17:39:14.889Z",
    "updated": "2024-10-15 17:39:14.889Z",
    "name": "event_participants",
    "type": "base",
    "system": false,
    "schema": [
      {
        "system": false,
        "id": "1qyrx4ed",
        "name": "eventId",
        "type": "relation",
        "required": false,
        "presentable": false,
        "unique": false,
        "options": {
          "collectionId": "p8klmgyiw7hc6k6",
          "cascadeDelete": false,
          "minSelect": null,
          "maxSelect": 1,
          "displayFields": null
        }
      },
      {
        "system": false,
        "id": "buy4tkzs",
        "name": "userId",
        "type": "relation",
        "required": false,
        "presentable": false,
        "unique": false,
        "options": {
          "collectionId": "_pb_users_auth_",
          "cascadeDelete": false,
          "minSelect": null,
          "maxSelect": 1,
          "displayFields": null
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
  const collection = dao.findCollectionByNameOrId("7vmxwnnk8rcw3bh");

  return dao.deleteCollection(collection);
})
