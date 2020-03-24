import json
import boto3
from flask import Flask
from flask_restful import reqparse, Resource, Api
from elasticsearch import Elasticsearch, RequestsHttpConnection
from requests_aws4auth import AWS4Auth
from sentence_transformers import SentenceTransformer

app = Flask(__name__)
api = Api(app)
region = 'ap-southeast-2'
ssm = boto3.client('ssm', region_name=region)
es_parameter = ssm.get_parameter(Name='/KNNSearch/ESUrl')
host = es_parameter['Parameter']['Value']
service = 'es'
credentials = boto3.Session().get_credentials()
awsauth = AWS4Auth(credentials.access_key, credentials.secret_key,
                   region, service, session_token=credentials.token)

parser = reqparse.RequestParser()
parser.add_argument('question')
parser.add_argument('size')
parser.add_argument('min_score')

es = Elasticsearch(
    hosts=[{'host': host, 'port': 443}],
    http_auth=awsauth,
    use_ssl=True,
    verify_certs=True,
    connection_class=RequestsHttpConnection
)

transform_model = SentenceTransformer(
    'model/transformer-v1/')

# knn_index = {
#     "settings": {
#         "index.knn": True
#     },
#     "mappings": {
#         "properties": {
#             "question_vector": {
#                 "type": "knn_vector",
#                 "dimension": 256
#             }
#         }
#     }
# }


class SimilarQuestionList(Resource):
    def check_es_index(self):
        if not es.indices.exists(index="questions"):
            es.indices.create(
                index="questions",
                body=knn_index,
                ignore=400
            )

    def post(self):
        # self.check_es_index()
        args = parser.parse_args()
        sentence_embeddings = transform_model.encode([args
                                                      ["question"]])
        res = es.search(index="questions",
                        body={
                            "size": args.get("size", 5),
                            "_source": {
                                "exclude": ["question_vector"]
                            },
                            "min_score": args.get("min_score", 0.3),
                            "query": {
                                "knn": {
                                    "question_vector": {
                                        "vector": sentence_embeddings[0].tolist(),
                                        "k": args.get("size", 5)
                                    }
                                }
                            }
                        })
        return res, 201


class HealthCheck(Resource):
    def get(self):
        return "", 200


api.add_resource(SimilarQuestionList, '/search')
api.add_resource(HealthCheck, '/')

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8000)
