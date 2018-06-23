# Full-Text Search

db.poc_cdep_collection.createIndex({"$**": "text"})
db.poc_cdep_collection.find(
    {"$text": {"$search": "dilma"}},
    {"score": {"$meta": "textScore"}}
).sort({
    "score": {"$meta": "textScore"}
}).toArray()

# biggest suppliers for some legislator at 2011 year

db.poc_cdep_collection.aggregate([
    {
        "$match": {
            "nuLegislatura": 2011,
            "txNomeParlamentar": "MARCOS ROGÉRIO"
        }
    },
    {
        "$group": {
            "_id": "$txtCNPJCPF",
            "value": {"$sum": "$vlrDocumento"}
        }
    },
    {
        "$sort": {
            "value": -1
        }
    }
]).toArray()

# biggest 10 suppliers

db.poc_cdep_collection.aggregate([
    {
        "$group": {
            "_id": "$txtCNPJCPF",
            "value": {"$sum": "$vlrDocumento"}
        }
    },
    {
        "$sort": {
            "value": -1
        }
    },
    {
        "$limit": 10
    }
]).toArray()

# all parties

db.poc_cdep_collection.distinct("sgPartido").sort()

# all legislatures

db.poc_cdep_collection.distinct("nuLegislatura").sort()

# For 2011 legislature, sum by legislator

db.poc_cdep_collection.aggregate([
    {
        "$match": {
            "nuLegislatura": 2011,
        }
    },
    {
        "$group": {
            "_id": "$txtCNPJCPF",
            "value": {"$sum": "$vlrDocumento"}
        }
    },
    {
        "$sort": {
            "value": -1
        }
    }
]).toArray()

# sum by legislator

db.poc_cdep_collection.aggregate([
    {
        "$group": {
            "_id": "$txtCNPJCPF",
            "value": {"$sum": "$vlrDocumento"}
        }
    },
    {
        "$sort": {
            "value": -1
        }
    },
]).toArray()


# sum by party

db.poc_cdep_collection.aggregate([
    {
        "$group": {
            "_id": "$sgPartido",
            "value": {"$sum": "$vlrDocumento"}
        }
    },
    {
        "$sort": {
            "value": -1
        }
    }
]).toArray()

# sum by legislator name

db.poc_cdep_collection.aggregate([
    {
        "$match": {
            "txNomeParlamentar": "MARCOS ROGÉRIO"
        }
    },
    {
        "$group": {
            "_id": "$txNomeParlamentar",
            "value": {"$sum": "$vlrDocumento"}
        }
    },
    {
        "$sort": {
            "value": -1
        }
    }
]).toArray()


# sum by legislator and legislature

db.poc_cdep_collection.aggregate([
    {
        "$group": {
            "_id": {
                "txNomeParlamentar": "$txNomeParlamentar",
                "nuLegislatura": "$nuLegislatura"
            },
            "value": {
                "$sum": "$vlrDocumento"
            }
        }
    },
    {
        "$group": {
            "_id": "$_id.txNomeParlamentar",
            "legislatures": {
                "$push": {
                    "value": "$value",
                    "nuLegislatura": "$_id.nuLegislatura"
                }
            }
        }
    },
    {
        "$sort": {
            "_id": 1
        }
    }
]).toArray()
