// Chris Joakim, Microsoft, August 2021

namespace CosmosConsole22{

    using System;
    using System.Threading.Tasks;
    using System.Collections.Generic;
    using Microsoft.Azure.Cosmos;
    using Microsoft.Azure.Cosmos.Core;
    using Newtonsoft.Json;

    public class CosmosQueryUtil : CosmosBaseUtil {
        
        public CosmosQueryUtil(CosmosClient client, bool verbose = false) {

            this.client  = client;
            this.verbose = verbose;
        }
        
        public async Task<QueryResponse> CountDocuments(string predicate, bool verbose = false)
        {
            QueryResponse respObj = new QueryResponse();
            string sql = null;
            
            try {
                sql = $"SELECT COUNT(1) FROM c {predicate.Trim()}";
                respObj.sql = sql;
                if (verbose) {
                    Console.WriteLine($"countDocuments - sql: {sql}");
                }
                QueryDefinition queryDefinition = new QueryDefinition(sql);
                QueryRequestOptions requestOptions = new QueryRequestOptions();
                FeedIterator<dynamic> queryResultSetIterator =
                    this.currentContainer.GetItemQueryIterator<dynamic>(
                        queryDefinition, requestOptions: requestOptions);

                while (queryResultSetIterator.HasMoreResults) {
                    FeedResponse<dynamic> feedResponse =
                        await queryResultSetIterator.ReadNextAsync();
                    respObj.statusCode = feedResponse.StatusCode;
                    respObj.elapsedMs  = feedResponse.Diagnostics.GetClientElapsedTime().TotalMilliseconds;
                    foreach (var item in feedResponse) {
                        // Item is an instance of Newtonsoft.Json.Linq.JObject
                        string value = item.Property("$1").First.ToString();
                        respObj.AddItem(int.Parse(value));
                    }
                }
            }
            catch (Exception e) {
                Console.WriteLine($"CountDocuments {sql} -> Exception {e}");
            }
            return respObj;
        }

        public async Task<QueryResponse> ExecuteQuery(string sql, bool verbose = false) {
            QueryResponse respObj = new QueryResponse();
            try {
                if (verbose) {
                    Console.WriteLine($"ExecuteQuery - sql: {sql}");
                }
                QueryDefinition qDef = new QueryDefinition(sql);
                QueryRequestOptions qOpts = new QueryRequestOptions();      
                FeedIterator<dynamic> qIter = 
                    this.currentContainer.GetItemQueryIterator<dynamic>(
                        qDef, requestOptions: qOpts);

                while (qIter.HasMoreResults) {
                    FeedResponse<dynamic> feedResponse = await qIter.ReadNextAsync();
                    respObj.statusCode = feedResponse.StatusCode;
                    respObj.elapsedMs  = feedResponse.Diagnostics.GetClientElapsedTime().TotalMilliseconds;
                    respObj.IncrementRequestCharge(feedResponse.RequestCharge);
                    foreach (var item in feedResponse) {
                        respObj.AddItem(item);
                    }
                }
            }
            catch (Exception e) {
                Console.WriteLine($"CountDocuments {sql} -> Exception {e}");
            }
            return respObj;
        }

        public async Task<ItemResponse<GenericDocument>> DeleteGenericDocument(GenericDocument doc)
        {
            ItemResponse<GenericDocument> response =
                await this.currentContainer.DeleteItemAsync<GenericDocument>(
                    doc.id, new PartitionKey(doc.pk));
            return response;
        }
    }
}