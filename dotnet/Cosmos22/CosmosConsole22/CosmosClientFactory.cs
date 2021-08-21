// Chris Joakim, Microsoft, August 2021

namespace CosmosConsole22 {
    
    using System;
    using System.Threading.Tasks;
    using System.Collections.Generic;
    using Microsoft.Azure.Cosmos;
    using Newtonsoft.Json;
    
    public class CosmosClientFactory {

        private CosmosClientFactory() {
            // do not use a constructor; use the static methods instead
        }

        public static CosmosClient RegularClient() {
            
            string uri = Config.Singleton().GetCosmosUri();
            string key = Config.Singleton().GetCosmosKey();
            // Console.WriteLine($"uri: {uri}");
            // Console.WriteLine($"key: {key}");
            
            IReadOnlyList<string> prefRegionsList = Config.Singleton().GetCosmosPreferredRegions();
            //Console.WriteLine("prefRegionsList: " + JsonConvert.SerializeObject(prefRegionsList));

            CosmosClientOptions options = new CosmosClientOptions {
                ApplicationPreferredRegions = prefRegionsList
            };
            return new CosmosClient(uri, key, options);
        }
        
        public static CosmosClient BulkLoadingClient() {
            
            string uri = Config.Singleton().GetCosmosUri();
            string key = Config.Singleton().GetCosmosKey();
            IReadOnlyList<string> prefRegionsList = Config.Singleton().GetCosmosPreferredRegions();
            
            Console.WriteLine($"uri: {uri}");
            Console.WriteLine($"key: {key}");
            //Console.WriteLine("prefRegionsList: " + JsonConvert.SerializeObject(prefRegionsList));

            CosmosClientOptions options = new CosmosClientOptions {
                ApplicationPreferredRegions = prefRegionsList,
                ApplicationName = "Cosmos22",
                AllowBulkExecution = true,
                ConnectionMode = ConnectionMode.Direct,
                MaxRetryAttemptsOnRateLimitedRequests = 12
            };
            return new CosmosClient(uri, key, options);
        }
    }
}