// Chris Joakim, Microsoft, August 2021

namespace CosmosConsole22 {
    
    using System;
    using System.Net;
    using System.Threading.Tasks;
    using System.Collections.Generic;
    using Microsoft.Azure.Cosmos;
    using Microsoft.Azure.Documents;
    using Microsoft.Azure.Cosmos.Core;
    using Newtonsoft.Json;
    using DocumentFormat.OpenXml.Wordprocessing;
    
    public class CosmosAdminUtil  : CosmosBaseUtil {
        
        public CosmosAdminUtil(CosmosClient client, bool verbose=false) {

            this.client  = client;
            this.verbose = verbose;
        }
        public async Task<List<string>> ListDatabases() {
            List<string> dbList = new List<string>();
            using (FeedIterator<DatabaseProperties> iterator = 
                client.GetDatabaseQueryIterator<DatabaseProperties>())
            {
                while(iterator.HasMoreResults)
                {
                    foreach (DatabaseProperties db in await iterator.ReadNextAsync())
                    {
                        Console.WriteLine(db.Id);
                        dbList.Add(db.Id);
                    }
                }
            }
            return dbList;
        }
        public async Task<DatabaseResponse> CreateDatabase(string name, int sharedRu) {
            if (sharedRu > 0) {
                if (sharedRu < 4000) {  // min sharedRu value is 4000
                    ThroughputProperties props = ThroughputProperties.CreateAutoscaleThroughput(4000);
                    return await client.CreateDatabaseIfNotExistsAsync(name, throughputProperties: props);
                }
                else {
                    ThroughputProperties props = ThroughputProperties.CreateAutoscaleThroughput(sharedRu);
                    return await client.CreateDatabaseIfNotExistsAsync(name, throughputProperties: props);
                }
            }
            else {
                return await client.CreateDatabaseIfNotExistsAsync(name);
            }
        }
        
        public async Task<Database> GetDatabase(string name) {
            try {
                Database db = client.GetDatabase(name);
                return await db.ReadAsync();
            }
            catch (Exception e) {
                Console.WriteLine($"GetDatabase {name} -> Exception {e}");
                return null;
            }
        }

        public async Task<int> UpdateDatabaseThroughput(string name, int sharedRu) {
            try {
                Database db = client.GetDatabase(name);
                ThroughputProperties props = ThroughputProperties.CreateAutoscaleThroughput(sharedRu);
                ThroughputResponse resp = await db.ReplaceThroughputAsync(props);
                return (int) resp.StatusCode;
            }
            catch (Exception e) {
                Console.WriteLine($"UpdateDatabaseThroughput {name} {sharedRu} -> Exception {e}");
                return -1;
            }
        }

        public async Task<int> DeleteDatabase(string dbname) {
            try {
                Database db = await GetDatabase(dbname);
                DatabaseResponse deleteResponse = await db.DeleteAsync();
                Console.WriteLine($"DeleteDatabase {dbname} response code: {deleteResponse.StatusCode}");
                return(int)deleteResponse.StatusCode;
            }
            catch (Exception e) {
                Console.WriteLine(e);
                return -1;
            }
        }

        public async Task<List<string>> ListContainers(string dbname) {
            List<string> containerList = new List<string>();
            try {
                Database db = await GetDatabase(dbname);
                FeedIterator<ContainerProperties> iterator = 
                    db.GetContainerQueryIterator<ContainerProperties>();
                FeedResponse<ContainerProperties> containers = 
                    await iterator.ReadNextAsync().ConfigureAwait(false);
                foreach (var container in containers) {
                    containerList.Add(container.Id);
                }
            }
            catch (Exception e) {
                Console.WriteLine(e);
                throw;
            }
            return containerList;
        }
        
        public async Task<string> CreateContainer(string dbname, string cname, string pk, int ru) {
            //int oneYear = 60 * 60 * 24 * 365;
            
            try {
                Database db = await GetDatabase(dbname);
                if (db == null) {
                    return null;
                }
                ContainerProperties cp = new ContainerProperties {
                    Id = cname,
                    PartitionKeyPath = pk,
                    AnalyticalStoreTimeToLiveInSeconds = -1
                };
                Container container = null;
                
                if (ru > 0) {
                    container = await db.CreateContainerIfNotExistsAsync(cp, ru);
                }
                else {
                    container = await db.CreateContainerIfNotExistsAsync(cp);
                }
                return container.Id;
            }
            catch (Exception e) {
                Console.WriteLine(e);
                return null;
            }      
        }

        public async Task<int> DeleteContainer(string dbname, string cname) {
            try {
                Database db = await GetDatabase(dbname);
                Container container = db.GetContainer(cname);
                ContainerResponse resp = await container.DeleteContainerAsync();
                return(int)resp.StatusCode;
            }
            catch (Exception e) {
                Console.WriteLine(e);
                return -1;
            }  
        }
        
        public async Task<int> UpdateContainerThroughput(string dbname, string cname, int ru) {
            try {
                Database db = await GetDatabase(dbname);
                Container container = db.GetContainer(cname);
                ThroughputResponse resp = await container.ReplaceThroughputAsync(ru);
                return(int)resp.StatusCode;
            }
            catch (Exception e) {
                Console.WriteLine(e);
                return -1;
            }  
        }

        public async Task<int> TruncateContainer() {
            // delete up to 1-million docs (100 * 10000 => 1000000) from given container
            int deleteOperationCount = 0;
            try {
                bool continueToProcess = true;
                int  loopCount = 0;
                
                List<GenericDocument> genericDocs = await ReadGenericDocuments(100);
                while (continueToProcess) {
                    loopCount++;
                    if (loopCount < 10000) {
                        if (genericDocs.Count < 1) {
                            continueToProcess = false;
                        }
                        else {
                            foreach (GenericDocument gd in genericDocs) {
                                ItemResponse<GenericDocument> ir = 
                                    await currentContainer.DeleteItemAsync<GenericDocument>(
                                        gd.id, gd.GetPartitionKey());
                                deleteOperationCount++;
                                Console.WriteLine($"{loopCount} {deleteOperationCount} {ir.StatusCode} {ir.RequestCharge} {gd.ToJson()}");
                            }
                            genericDocs = await ReadGenericDocuments(100);
                        }
                    }
                    else {
                        continueToProcess = false;
                        Console.Write($"TruncateContainer loopCount exceeded: {loopCount}");
                    }
                }
            }
            catch (Exception e) {
                Console.WriteLine(e);
            }
            return deleteOperationCount;
        }

        private async Task<List<GenericDocument>> ReadGenericDocuments(int maxCount) {
            List<GenericDocument> genericDocs = new List<GenericDocument>();
            string sql = $"SELECT c.id, c.pk FROM c offset 0 limit {maxCount}";
            QueryDefinition queryDefinition = new QueryDefinition(sql);
            QueryRequestOptions requestOptions = new QueryRequestOptions();
            FeedIterator<dynamic> queryResultSetIterator =
                currentContainer.GetItemQueryIterator<dynamic>(
                    queryDefinition, requestOptions: requestOptions);
            while (queryResultSetIterator.HasMoreResults) {
                FeedResponse<dynamic> feedResponse =
                    await queryResultSetIterator.ReadNextAsync();
                foreach (var item in feedResponse) {
                    // Item is an instance of Newtonsoft.Json.Linq.JObject
                    GenericDocument gd = new GenericDocument();
                    gd.id = (string) item.Property("id");
                    gd.pk = (string) item.Property("pk");
                    genericDocs.Add(gd);
                }
            }
            return genericDocs;
        }
    }
}